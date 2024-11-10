//Modulo encargado de sumar 4 a la direccion de memoria actual
module PCmas4(input [31:0] actual, 
    output [31:0] siguiente
    );

    assign siguiente = 32'd4 + actual;
endmodule

//El testbench tiene como finalidad verificar que la salida siempre sea el actual mas 4
module PCmas4_tb;
    reg [31:0] actual;
    wire [31:0] siguiente;

    PCmas4 uut (
        .actual(actual),
        .siguiente(siguiente)
    );

    initial begin
        actual = 32'h00000000;
        #10;
        if (siguiente != 32'h00000004)
            $display("Prueba Fallida: Para dirección 0, salida esperada es 4, pero se obtuvo %h", siguiente);
        else
            $display("Prueba 1 Exitosa: actual = %h, siguiente = %h", actual, siguiente);

        actual = 32'h00000004;
        #10;
        if (siguiente != 32'h00000008)
            $display("Prueba Fallida: Para dirección 4, salida esperada es 8, pero se obtuvo %h", siguiente);
        else
            $display("Prueba 2 Exitosa: actual = %h, siguiente = %h", actual, siguiente);

        $display("Test completo.");
        $finish;
    end
endmodule
