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

`timescale 1ns / 1ps
//Test bench para asegurar que la salida del modulo siempre es input1 + (input2<<2)
module sumador_branch_tb;

    // Señales del banco de pruebas
    reg [31:0] input1;         // Contador de programa actual (PC)
    reg [31:0] input2;         // Offset para el salto
    wire [31:0] out_suma;      // Salida de la suma

    // Instancia del módulo sumador_branch
    sumador_branch uut (
        .input1(input1),
        .input2(input2),
        .out_suma(out_suma)
    );

    // Procedimiento de prueba
    initial begin
        // Caso de prueba 1: Caso básico
        input1 = 32'h00000010;  // Ejemplo de PC actual
        input2 = 32'h00000004;  // Ejemplo de offset de salto
        #10;
        $display("Valor esperado de out_suma = %h, Valor obtenido de out_suma = %h", input1 + input2, out_suma);
        if (out_suma !== input1 + input2)
            $display("Incorrecto");
        else
            $display("Correcto");
        $finish;
    end
endmodule
