module ProgramCounter (
        input clk,                      
        input reset,                    
        input [31:0] pc_in,
        output reg [31:0] pc_out                                   
    );
    initial begin
        pc_out = 32'b0; 
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0;  
        end
        else 
        begin
            pc_out <= pc_in;  
        end
    end

endmodule

module PCmas4(
    input [31:0] actual, 
    output [31:0] siguiente
    );

    assign siguiente = 32'd4 + actual;
endmodule

module memoria_instruccion(
    input reset,
    input [31:0] leer_direccion, 
    output reg [31:0] instruccion
    );

    reg [31:0] memoria [127:0]; 

    initial
    begin 
        for (integer i = 0; i < 128; i = i + 1)
        begin
            memoria[i] = 32'h0;
        end
        $readmemh("memory_init_final.hex", memoria, 0, 127);
    end

    always @(*) 
    begin
        instruccion <= memoria[leer_direccion/4];
    end

    always @(posedge reset)
    begin
        if (reset) begin
            for (integer k = 0; k < 128; k = k + 1)
                begin
                memoria[k] <= 32'h0;  
            end
            instruccion <= 32'h0;
        end
    end
endmodule

module RegisterFile(
    input clk,
    input reset,
    input regWrite,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    output [31:0] RS1,
    output [31:0] RS2
    );

    reg [31:0] registros [31:0];
    assign RS1 = registros[A1];
    assign RS2 = registros[A2];

    initial begin
        for (integer i = 0; i < 32; i = i + 1)
        begin
            registros[i] = 32'h0;
        end
        registros[2] = 32;
    end

    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (integer k = 0; k < 32; k = k + 1)
                begin
                registros[k] <= 32'h0;
                end
        end
        else if (regWrite && A3 != 5'b00000)
        begin
            registros[A3] <= WD;
        end
    end
endmodule

module ImmGen(
    input [6:0] opcode,
    input [31:0] instruccion,
    output reg   [31:0] Imm
    );

    always @(*)
    begin
        Imm = 32'b0; 
        case(opcode)
        7'b0110111 : Imm = instruccion[31:12]<<12;
        7'b0010011 : Imm = {{20{instruccion[31]}}, instruccion[31:20]};
        7'b0000011 : Imm = {{20{instruccion[31]}}, instruccion[31:20]};
        7'b0100011 : Imm = {{20{instruccion[31]}}, instruccion[31:25], instruccion[11:7]};
        7'b1100011 : Imm = {{19{instruccion[31]}}, instruccion[31],  instruccion[7], instruccion[30:25], instruccion[11:8], 1'b0};
        7'b1101111 : Imm = {{11{instruccion[31]}}, instruccion[31],  instruccion[19:12], instruccion[20], instruccion[30:21], 1'b0};
        default: Imm = 32'b0;
        endcase
    end
endmodule

module Control(
    input [6:0] opcode,
    input [2:0] funct3,
    output reg branch, 
    output reg jump,
    output reg [2:0] ALUop,
    output reg ALUsrc,
    output reg MemWrite,
    output reg regWrite,  
    output reg MemRead,
    output reg MemToReg,
    output reg sb
    );

    always @(*)
    begin
        {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 10'b0;
        case(opcode)
        7'b0110111_ : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10100000_000;
        7'b1101111 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10000010_000;
        7'b1100011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b00000100_001;
        7'b0000011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b11101000_010;
        7'b0100011 : 
            case (funct3)
                    3'b000: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10010001_011; 
                    3'b010: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10010000_011;
            endcase
        7'b0010011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10100000_100;
        default: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 11'b0;
        endcase
    end
endmodule

module ALUControl (
    input [2:0] ALUop,        
    input [2:0] funct3,          
    output reg [2:0] out        
    );

    always @(*)
    begin
        if (ALUop == 3'b000)
        begin
            out = 3'b101;
        end
        else
        begin
            case({ALUop, funct3})
                6'b001_001 : out = 3'b011;
                6'b001_101 : out = 3'b100;
                6'b010_010 : out = 3'b000;
                6'b011_010 : out = 3'b000;
                6'b011_000 : out = 3'b000;
                6'b100_000 : out = 3'b000;
                6'b100_111 : out = 3'b010;
                6'b100_001 : out = 3'b001;
                default: out = 3'b000;
            endcase
        end
    end
endmodule

module ALU (
    input [31:0] A,        
    input [31:0] B,        
    input [2:0] control,   
    output reg [31:0] result,
    output reg comp,  
    output reg zero         
    );

    always @(*) begin
        case (control)
            3'b000: result = A + B;               
            3'b001: result = A << B;              
            3'b010: result = A & B;               
            3'b011: comp = (A != 0) ? 32'b1 : 32'b0; 
            3'b100: comp = (A >= B) ? 32'b1 : 32'b0;
            3'b101: result = B;  
            default: result = 32'b0;
            default: comp = 32'b0;              
        endcase

        
        zero = (result == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule

module muxALUsrc (
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 

endmodule

module logica_andBranch(
    input branch,
    input comparacion,
    output and_out
    );
    assign and_out = branch & comparacion;
endmodule

module sumador_restador_branch(
    input [31:0] input1,
    input [31:0] input2,
    input branch,
    input [2:0] control,       
    output reg [31:0] out_suma    
    );

    always @(*) begin
        out_suma = 32'b0;
        if (branch)
        begin
            case (control)
                3'b011: out_suma = input1 + input2;  
                3'b100: out_suma = input1 - (~input2 + 1);  
                default: out_suma = 32'b0;           
            endcase
        end
    end
endmodule


module muxPCsrc (
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

module muxJump (
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

module DataMemory(
    input clk, reset, MemWrite, MemRead, sb,
    input   [31:0] direccion, escritura_datos,
    output   [31:0] leer_datos 
    );

    reg [31:0] memoria_datos [31:0];
    wire [4:0] direccion_palabra = direccion[6:2]; 
    wire [1:0] offset = direccion[1:0]; 

    initial begin
        for (integer k = 0; k < 32; k = k + 1)
            begin
                memoria_datos[k] = 32'h0;
            end
        end

    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (integer k = 0; k < 32; k = k + 1)
            begin
                memoria_datos[k] = 32'h0;
            end
        end
        else if (MemWrite)
        begin
            if (sb)
            begin
                case (offset)
                    2'b11: memoria_datos[direccion_palabra][7:0]   = escritura_datos[7:0];
                    2'b10: memoria_datos[direccion_palabra][15:8]  = escritura_datos[7:0];
                    2'b01: memoria_datos[direccion_palabra][23:16] = escritura_datos[7:0];
                    2'b00: memoria_datos[direccion_palabra][31:24] = escritura_datos[7:0];
                endcase
            end
            else
            begin
                memoria_datos[direccion] = escritura_datos;
            end
        end
    end

    assign leer_datos = (MemRead) ? memoria_datos[direccion] : 32'b0;

endmodule

module muxMemtoReg (
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

module top(
    input clk, 
    input reset
    );
    wire [31:0] pc_top, instruccion_top, RS2_top, RS1_top , Imm_top, B_top, pcmas4_top, out_suma_top, muxPCsrcOut_top, pc_in_top, ALUResult_top, leer_datos_top, WD_top;
    wire regWrite_top, ALUsrc_top, branch_top, comp_top, and_top, jump_top, MemToReg_top, MemWrite_top, MemRead_top, sb_top;
    wire [2:0] ALUop_top, ALUControlOut_top;

    ProgramCounter ProgramCounter (.clk(clk), .reset(reset), .pc_in(pc_in_top), .pc_out(pc_top));

    PCmas4 PCmas4 (.actual(pc_top), .siguiente(pcmas4_top));

    memoria_instruccion memoria_instruccion (.reset(reset), .leer_direccion(pc_top), .instruccion(instruccion_top));

    RegisterFile RegisterFile (.clk(clk), .reset(reset), .regWrite(regWrite_top), .A1(instruccion_top[19:15]), .A2(instruccion_top[24:20]), .A3(instruccion_top[11:7]), .WD(WD_top), .RS1(RS1_top), .RS2(RS2_top));

    ImmGen ImmGen (.opcode(instruccion_top[6:0]), .instruccion(instruccion_top), .Imm(Imm_top));

    Control Control(.opcode(instruccion_top[6:0]), .funct3(instruccion_top[14:12]), .branch(branch_top), .jump(jump_top), .ALUop(ALUop_top), .ALUsrc(ALUsrc_top), .MemWrite(MemWrite_top), .regWrite(regWrite_top), .MemRead(MemRead_top), .MemToReg(MemToReg_top), .sb(sb_top));

    ALUControl ALUControl (.ALUop(ALUop_top), .funct3(instruccion_top[14:12]), .out(ALUControlOut_top));

    ALU ALU (.A(RS1_top), .B(B_top), .control(ALUControlOut_top), .result(ALUResult_top), .comp(comp_top), .zero());

    muxALUsrc muxALUsrc (.sel(ALUsrc_top), .A(RS2_top), .B(Imm_top), .out(B_top));

    sumador_restador_branch sumador_restador_branch(.branch(branch_top), .control(ALUControlOut_top), .input1(pc_top), .input2(Imm_top), .out_suma(out_suma_top));

    logica_andBranch logica_andBranch(.branch(branch_top), .comparacion(comp_top), .and_out(and_top));

    muxPCsrc muxPCsrc (.sel(and_top), .A(pcmas4_top), .B(out_suma_top), .out(muxPCsrcOut_top));

    muxJump muxJump (.sel(jump_top), .A(muxPCsrcOut_top), .B(pc_top + Imm_top), .out(pc_in_top));

    DataMemory DataMemory(.clk(clk), .reset(reset), .sb(sb_top), .MemWrite(MemWrite_top), .MemRead(MemRead_top), .direccion(ALUResult_top), .escritura_datos(RS2_top), .leer_datos(leer_datos_top));

    muxMemtoReg muxMemtoReg (.sel(MemToReg_top), .A(ALUResult_top), .B(leer_datos_top), .out(WD_top));
endmodule 

`timescale 1ns/1ns

module riscv_tb;

    reg clk, reset;

    top uut(.clk(clk), .reset(reset));
    initial begin
    $dumpfile("RISCV_tb.vcd");
    $dumpvars(0, uut);
    clk = 0;              // Inicializa el reloj en 0
        repeat (100) begin
            #5 clk = ~clk;    // Cambia el valor de `clk` cada 5 unidades de tiempo
        end
    end
endmodule




