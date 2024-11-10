//mux para determinar la siguiente direccion de instruccion, si es 1 es jump y sale la direccion destino, de ser 0 es la instruccion secuencial o puede ser un branch
module muxJump (
       input sel, //sel es la señal de control jump, es la salida del muxPCsrc y B es la direccion de salto dada por el jump
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

`timescale 1ns / 1ps

//Test bench sencillo para verificar que si el selector es cero sale A, de ser 1 sale B
module muxJump_tb;

    reg sel;                   
    reg [31:0] A, B;           
    wire [31:0] out;          

    muxJump uut (
        .sel(sel),
        .A(A),
        .B(B),
        .out(out)
    );

    initial begin
        A = 32'h00000010;  
        B = 32'h00000020;  
        sel = 0;
        #10;  

  
        if (out !== A)
            $display("Incorrecto");
        else
            $display("Correcto");


        sel = 1;
        #10;  
        if (out !== B)
            $display("Incorrecto");
        else
            $display("Correcto");

        $finish;
    end
endmodule
