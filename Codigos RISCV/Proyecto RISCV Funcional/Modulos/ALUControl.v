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

//Este test bench comprueba que cada combinacion de ALUop y Funct3 dan como resultado el codigo esperado
module ALUControl_tb;
    reg [2:0] ALUop;
    reg [2:0] funct3;
    wire [2:0] out;

    ALUControl uut (
        .ALUop(ALUop),
        .funct3(funct3),
        .out(out)
    );

    initial begin
        ALUop = 3'b000;
        funct3 = 3'b000;  
        #10;
        if (out !== 3'b101)
            $display("Error en caso de jump: Esperado 101, Obtenido = %b", out);
        else
            $display("Caso de salto exitoso: out = %b", out);

        ALUop = 3'b001;
        funct3 = 3'b001;
        #10;
        if (out !== 3'b011)
            $display("Error en combinación 001_001: Esperado 011, Obtenido = %b", out);
        else
            $display("Combinación 001_001 exitosa: out = %b", out);

        ALUop = 3'b001;
        funct3 = 3'b101;
        #10;
        if (out !== 3'b100)
            $display("Error en combinación 001_101: Esperado 100, Obtenido = %b", out);
        else
            $display("Combinación 001_101 exitosa: out = %b", out);

        ALUop = 3'b010;
        funct3 = 3'b010;
        #10;
        if (out !== 3'b000)
            $display("Error en combinación 010_010: Esperado 000, Obtenido = %b", out);
        else
            $display("Combinación 010_010 exitosa: out = %b", out);

        ALUop = 3'b011;
        funct3 = 3'b010;
        #10;
        if (out !== 3'b000)
            $display("Error en combinación 011_010: Esperado 000, Obtenido = %b", out);
        else
            $display("Combinación 011_010 exitosa: out = %b", out);

        ALUop = 3'b011;
        funct3 = 3'b000;
        #10;
        if (out !== 3'b000)
            $display("Error en combinación 011_000: Esperado 000, Obtenido = %b", out);
        else
            $display("Combinación 011_000 exitosa: out = %b", out);

        ALUop = 3'b100;
        funct3 = 3'b000;
        #10;
        if (out !== 3'b000)
            $display("Error en combinación 100_000: Esperado 000, Obtenido = %b", out);
        else
            $display("Combinación 100_000 exitosa: out = %b", out);

        ALUop = 3'b100;
        funct3 = 3'b111;
        #10;
        if (out !== 3'b010)
            $display("Error en combinación 100_111: Esperado 010, Obtenido = %b", out);
        else
            $display("Combinación 100_111 exitosa: out = %b", out);

        ALUop = 3'b100;
        funct3 = 3'b001;
        #10;
        if (out !== 3'b001)
            $display("Error en combinación 100_001: Esperado 001, Obtenido = %b", out);
        else
            $display("Combinación 100_001 exitosa: out = %b", out);

        ALUop = 3'b111;
        funct3 = 3'b111;
        #10;
        if (out !== 3'b000)
            $display("Error en caso por defecto: Esperado 000, Obtenido = %b", out);
        else
            $display("Caso por defecto exitoso: out = %b", out);

        $display("Test completo.");
        $finish;
    end
endmodule
