//Modulo que carga la siguiente direccion de la instruccion a memoria de instruccion 
module ProgramCounter (
    //Como entradas tiene el reloj del sistema, el reset y el pc actual, como salida tiene la direccion de  la siguiente instruccion 
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
            pc_out <= 32'b0;  //En caso de haber reset se manda como salida la direccion 0
        end
        else 
        begin
            pc_out <= pc_in;  // Con cada flanco positivo de reloj se actualiza la direccion de instruccion 
        end
    end

endmodule

//Modulo encargado de sumar 4 a la direccion de memoria actual
module PCmas4(input [31:0] actual, 
    output [31:0] siguiente
    );

    assign siguiente = 32'd4 + actual;
endmodule

//Modulo encargado de cargar en memoria las instrucciones, asi como de enviar las instrucciones correspondientes a la direccion que le llega como entrada
module memoria_instruccion(
    //Como entrada tiene el reset y la direccion de la instruccion, como salida envia la instruccion ubicada en la direccion recibida.
    input reset,
    input [31:0] leer_direccion, 
    output reg [31:0] instruccion
    );
    //Se crea un regitro de 128 espacios, cada uno de 32 bits
    reg [31:0] memoria [127:0]; 

    initial
    begin 
        //Como paso inicial se ponen todos los registros en cero, esto para que tengan un valor definido 
        for (integer i = 0; i < 128; i = i + 1)
        begin
            memoria[i] = 32'h0;
        end
        //Se carga el .hex al registro
        $readmemh("memory_init_final.hex", memoria, 0, 127);
    end

    always @(*) 
    begin
    //De forma asicrona se leen las instrucciones, las direcciones se dividen entre 4 ya que llegan en multiplos de 4 (palabras)y para el archivo las instrucciones van 0, 1, 2....
        instruccion <= memoria[leer_direccion/4];
    end
    // En caso de ocurrir un reset tanto los espacios de memoria como la direccion se establecen como cero
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

//Modulo encargado de almacenar los registros necesarios para la ejecucion del programa, tambien permite leer datos ya existentes en los registros
module RegisterFile(
    //Tiene como entrada la señal de reloj, el reset, si se quiere escribir en el registro, las posibles direcciones a las que se accede y el valor del writeback. Como salidas tiene los valores que estaban almacenados
    //en las direcciones A1 o A2 
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
    //Se crean 32 registros de 32 bits cada uno
    reg [31:0] registros [31:0];
    //Se asigna que las salidas son los datos almacenados en los registros en las direcciones A1 y A2
    assign RS1 = registros[A1];
    assign RS2 = registros[A2];
    //Al inicio todo es cero
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
        //De forma sincrona u si existe la señal de escritura en registro se asigna el valor en WD a la direccion A3, menos si es 0, ya que es una direccion no accesible
        else if (regWrite && A3 != 5'b00000)
        begin
            registros[A3] <= WD;
        end
    end
endmodule

//Modulo encargado de generar los inmediatos necesarios para las distintas operaciones 
module ImmGen(
    //Tiene como input el opcode que identifica las distintas operaciones a realizar, tambien recibe la instruccion completa para poder extraer los bits necesarios para formar el inmediato, como salida tiene el 
    //inmediato generado
    input [6:0] opcode,
    input [31:0] instruccion,
    output reg [31:0] Imm
    );

    always @(*)
    begin
        Imm = 32'b0; 
        case(opcode)
        //Dependiendo del opcode se genera el inmediato y se realiza una extension de signo
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

//Modulo encargado de generar todas las posibles señales de control
module Control(
    //como input tiene el opcode de cada instruccion asi como el espacio de funct3, como output tiene todas las señales de control del sistema.
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
        //De forma asincrona evalua el opcode y con base en este genera los valores que tiene que tener cada señal de control, se asocian con e orden de los bits, pro ejemplo, ALUsrc siempre va a ser el valor
        //del primer bit del arreglo de 11 bits
        {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 10'b0;
        case(opcode)
        7'b0110111_ : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10100000_000;
        7'b1101111 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10000010_000;
        7'b1100011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b00000100_001;
        7'b0000011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b11101000_010;
        7'b0100011 : 
            case (funct3)
            //El caso del store es especial ya que puede ser sotre byte o store word y por esto ademas de evaluar el opcode evalua tambien el funct3 de la instruccion
                    3'b000: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10010001_011; 
                    3'b010: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10010000_011;
            endcase
        7'b0010011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop} = 11'b10100000_100;
        default: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 11'b0;
        endcase
    end
endmodule

//Modulo encargado de generar el codigo que le dice a la ALU que operacion va a realizar
module ALUControl (
    //tiene como entradas la señal ALUop que proviene de la unidad de control y funct3 para indicar la operacion especifica que se va a realizar, como salida tiene el codigo de operacion que le llega a la ALU
    input [2:0] ALUop,        
    input [2:0] funct3,          
    output reg [2:0] out        
    );

    always @(*)
    begin
        //Si no importa el funct3 significa que es jump por lo que es un caso especial
        if (ALUop == 3'b000)
        begin
            out = 3'b101;
        end
        else
        begin
            case({ALUop, funct3})
            //Evaluando ALUop y funct3 se genera el codigo de operacion de la ALU
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

//Modulo encargado de realizar las operaciones logico aritmeticas 
module ALU (
    //Tiene como entradas los dos valores a los que se les va a aplicar las oepraciones logicas o aritmeticas y una señal de control que determina que operacion se va a realizar y como salida tiene el resultado
    //de la operacion, el resultado de las comparaciones logicas y una bandera de cero
    input [31:0] A,        
    input [31:0] B,        
    input [2:0] control,   
    output reg [31:0] result,
    output reg comp,  
    output reg cero         
    );

    always @(*) begin
    //de forma asincrona se evalua el valor de control y se realizan las operaciones correspondientes 
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

        
        cero = (result == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule

//Modulo multiplexor encargado de escoger el origen del segundo arguemento que entra a la ALU
module muxALUsrc (
    //La señal sel es la señal de control ALUsrc, en caso de ser 1 sale B, que es un inmediato, en caso de ser cero sale A que viene del register file
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 

endmodule

//Modulo encargado de realizar el and entre le señal de branch y si se cumple la condicion 
module logica_andBranch(
    //Tiene como entrada la señal de control branch y el resultado de la condicion, la salida es el and de estas señales
    input branch,
    input comparacion,
    output and_out
    );
    assign and_out = branch & comparacion;
endmodule

//Modulo encargado de generar la direccion para un posible branch
module sumador_branch(
    //Como input1 tiene el pc actual, input 2 es la direccion a la que se quiere hacer el branch
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] out_suma
    );
    //Se suma la direccion actual a la direccion de branch, a esta se le aplica un shift a la izquierda para que sea en formato de palabra
    assign out_suma = input1 + input2;
endmodule

//Multiplexor encargado de definir el origen de la direccion de memoria siguiente
module muxPCsrc (
    //Como entrada tiene sel que es el resultado de aplicar el and a la señal de branch y a la comparacion logica que tiene como condicion el branch. A es la siguiente direccion secuencial y B es la direccion
    //de salto del branch
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

//mux para determinar la siguiente direccion de instruccion, si es 1 es jump y sale la direccion destino, de ser 0 es la instruccion secuencial o puede ser un branch
module muxJump (
       input sel, //sel es la señal de control jump, es la salida del muxPCsrc y B es la direccion de salto dada por el jump
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

//Modulo encargado de almacenar datos en memoria, asi como recuperarlos de esta para escribir en el register file
module DataMemory(
    //Como entradas tiene el reloj, el reset, si se escribe o se lee memoria, si la operacion es un store byte, la direccion a la que se quiere acceder y los datos a escribir en caso de escritura de memoria. 
    //Como salida tiene los datos que se leen en caso de lectura de memoria
    input clk, reset, MemWrite, MemRead, sb,
    input [31:0] direccion, escritura_datos,
    output [31:0] leer_datos 
    );
    //Se crean 32 espacios de memoria, cada uno de 32 bits
    reg [31:0] memoria_datos [31:0];
    //tanto direccion palabra como offset son necesarios para implementar el store byte, direccion de palabra hace una division entre 4 para obtener la palabra y el offset son los primeros dos bits de la direccion, 
    //que indica si es el byte 0, 1, 2 o 3
    wire [4:0] direccion_palabra = direccion[6:2]; 
    wire [1:0] offset = direccion[1:0];
 //Se agrega un task que se puede llamar al final de la simulacion del modulo top, este task se encarga de hacer un dump de los contenidos de memoria a un archivo de texto para su revision
    task dump_memoria;
        integer file, i;
        begin
            file = $fopen("data_memory_dump.txt", "w");
            if (file) begin
                for (i = 0; i < 32; i = i + 1) begin
                    $fwrite(file, "memoria_datos[%0d] = %h\n", i, memoria_datos[i]);
                end
                $fclose(file);
            end else begin
                $display("Error abriendo el archivo.");
            end
        end
    endtask


    //Se inician los valores en cero
    initial begin
        for (integer k = 0; k < 32; k = k + 1)
            begin
                memoria_datos[k] = 32'h0;
            end
        end
    //De forma sincrona se lee de memoria o se escribe en ella, se tiene una señal de control sb para las operaciones especiales para realizar un store byte
    always @(posedge clk or posedge reset)
    begin
    // En caso de reset todo se vuelve cero
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
    //En caso de querer leer datos se pregunta si hay señal de MemRead, de haberla se leen los contenidos en la direccion proporcionada
    assign leer_datos = (MemRead) ? memoria_datos[direccion] : 32'b0;

endmodule

//Modulo mux para determinar si se quiere hacer writeback desde memoria o desde la ALU
module muxMemtoReg (
       input sel, //sel es la señal de control memtoreg, A viene del data memory y B es la salida de la ALU
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

    ALU ALU (.A(RS1_top), .B(B_top), .control(ALUControlOut_top), .result(ALUResult_top), .comp(comp_top), .cero());

    muxALUsrc muxALUsrc (.sel(ALUsrc_top), .A(RS2_top), .B(Imm_top), .out(B_top));

    sumador_branch sumador_branch(.input1(pc_top), .input2(Imm_top), .out_suma(out_suma_top));

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
    clk = 0;              
    repeat (100) begin
        #5 clk = ~clk;  
    end
    uut.DataMemory.dump_memoria();
    $finish;
    end
endmodule




