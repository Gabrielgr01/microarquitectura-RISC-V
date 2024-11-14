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


`timescale 1ns / 1ps
//El test bench tiene como finalidad revisar si las combinaciones de opcode y funct3 generan las señales de control esperadas, se compara la generada con la esperada, de ser iguales es correcto de lo contrario es incorrecto
module Control_tb();

    reg [6:0] opcode;
    reg [2:0] funct3;
    wire branch, jump, ALUsrc, MemWrite, regWrite, MemRead, MemToReg, sb;
    wire [2:0] ALUop;


    reg [10:0] esperado;
    wire [10:0] resultado;

 
    assign resultado = {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, sb, ALUop};

    Control uut (
        .opcode(opcode),
        .funct3(funct3),
        .branch(branch),
        .jump(jump),
        .ALUop(ALUop),
        .ALUsrc(ALUsrc),
        .MemWrite(MemWrite),
        .regWrite(regWrite),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .sb(sb)
    );

    initial begin
        opcode = 7'b0110111;
        funct3 = 3'b000; 
        esperado = 11'b10100000_000;
        #10;
        $display("LUI: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        opcode = 7'b1101111;
        funct3 = 3'b000; 
        esperado = 11'b10000010_000;
        #10;
        $display("J: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        opcode = 7'b1100011;
        funct3 = 3'b000; 
        esperado = 11'b00000100_001;
        #10;
        $display("B: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        opcode = 7'b0000011;
        funct3 = 3'b010; 
        esperado = 11'b11101000_010;
        #10;
        $display("L: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        opcode = 7'b0100011;
        funct3 = 3'b000; 
        esperado = 11'b10010001_011;
        #10;
        $display("SB: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        opcode = 7'b0100011;
        funct3 = 3'b010; 
        esperado = 11'b10010000_011;
        #10;
        $display("SW: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        opcode = 7'b0010011;
        funct3 = 3'b000; 
        esperado = 11'b10100000_100;
        #10;
        $display("I: %s", (resultado === esperado) ? "Correcto" : "Incorrecto");

        $finish;
    end
endmodule

