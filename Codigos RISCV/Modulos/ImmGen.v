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

//Este testbench tiene como finalidad comprobar que el modulo genera los inmediatos en el orden correcto 
module ImmGen_tb;
    reg [6:0] opcode;
    reg [31:0] instruccion;
    wire [31:0] Imm;

    // Instanciación del módulo ImmGen
    ImmGen uut (
        .opcode(opcode),
        .instruccion(instruccion),
        .Imm(Imm)
    );

    initial begin
        // Prueba para el opcode 0110111 (LUI)
        opcode = 7'b0110111;
        instruccion = 32'b00010010001101000101011001111000;  
        #10;
        if (Imm !== 32'b00010010001101000101000000000000)
            $display("Error en LUI: Esperado 00010010001101000101000000000000, Obtenido = %b", Imm);
        else
            $display("LUI Exitoso: Imm = %b", Imm);

        // Prueba para el opcode 0010011 (I-type)
        opcode = 7'b0010011;
        instruccion = 32'b00000000001100011000000010010011;  
        #10;
        if (Imm !== 32'b00000000000000000000000000000011)
            $display("Error en ADDI: Esperado b00000000000000000000000000000011, Obtenido = %b", Imm);
        else
            $display("ADDI Exitoso: Imm = %b", Imm);

        // Prueba para el opcode 0000011 (Load)
        opcode = 7'b0000011;
        instruccion = 32'b00000000001100101100000001110011;  
        #10;
        if (Imm !== 32'b00000000000000000000000000000011)
            $display("Error en L: Esperado b00000000000000000000000000000011, Obtenido = %b", Imm);
        else
            $display("L Exitoso: Imm = %b", Imm);

        // Prueba para el opcode 0100011 (Store)
        opcode = 7'b0100011;
        instruccion = 32'b00000000101000110000001100010011;  
        #10;
        if (Imm !== 32'b00000000000000000000000000000110)
            $display("Error en S: Esperado 00000000000000000000000000000110, Obtenido = %b", Imm);
        else
            $display("S Exitoso: Imm = %b", Imm);

        // Prueba para el opcode 1100011 (Branch)
        opcode = 7'b1100011;
        instruccion = 32'b00000000111100110000001101100011;  
        #10;
        if (Imm !== 32'b00000000000000000000000000000110)
            $display("Error en B: Esperado 00000000000000000000000000000110, Obtenido = %b", Imm);
        else
            $display("B Exitoso: Imm = %b", Imm);

        // Prueba para el opcode 1101111 (J)
        opcode = 7'b1101111;
        instruccion = 32'b00000000000011110000000011111111;  
        #10;
        if (Imm !== 32'b00000000000011110000000000000000)
            $display("Error en J: Esperado b00000000000011110000000000000000, Obtenido = %b", Imm);
        else
            $display("J Exitoso: Imm = %b", Imm);

        // Prueba para un opcode no válido
        opcode = 7'b1111111;  
        instruccion = 32'b0;  
        #10;
        if (Imm !== 32'b0)
            $display("Error en caso por defecto: Esperado 00000000, Obtenido = %b", Imm);
        else
            $display("Caso por defecto exitoso: Imm = %b", Imm);

        $display("Test completo.");
        $finish;
    end
endmodule
