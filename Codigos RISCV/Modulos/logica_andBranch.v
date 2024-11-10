//Modulo encargado de realizar el and entre le señal de branch y si se cumple la condicion 
module logica_andBranch(
    //Tiene como entrada la señal de control branch y el resultado de la condicion, la salida es el and de estas señales
    input branch,
    input comparacion,
    output and_out
    );
    assign and_out = branch & comparacion;
endmodule

`timescale 1ns / 1ps

//Test bench encargado de asegurar el correcto funcionamiento de la logica and
module logica_andBranch_tb;

    reg branch;               
    reg comparacion;          
    wire and_out;             

    logica_andBranch uut (
        .branch(branch),
        .comparacion(comparacion),
        .and_out(and_out)
    );


    initial begin
        branch = 0;
        comparacion = 0;
        #10;
        $display("branch = %b, comparacion = %b, out esperado = 0, out obtenido = %b", branch, comparacion, and_out);
        if (and_out !== 0)
            $display("Incorrecto");
        else
            $display("Correcto");


        branch = 0;
        comparacion = 1;
        #10;
        $display("branch = %b, comparacion = %b, out esperado = 0, out obtenido = %b", branch, comparacion, and_out);
        if (and_out !== 0)
            $display("Incorrecto");
        else
            $display("Correcto");

        branch = 1;
        comparacion = 0;
        #10;
        $display("branch = %b, comparacion = %b, out esperado = 0, out obtenido = %b", branch, comparacion, and_out);
        if (and_out !== 0)
            $display("Incorrecto");
        else
            $display("Correcto");

        branch = 1;
        comparacion = 1;
        #10;
        $display("branch = %b, comparacion = %b, out esperado = 1, out obtenido = %b", branch, comparacion, and_out);
        if (and_out !== 1)
            $display("Incorrecto");
        else
            $display("Correcto");

        $finish;
    end
endmodule
