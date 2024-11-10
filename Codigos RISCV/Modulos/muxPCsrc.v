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

//Test bench sencillo para verificar que si el selector es cero sale A, de ser 1 sale B
module muxPCsrc_tb;

    reg sel;                   
    reg [31:0] A, B;           
    wire [31:0] out;          

    muxPCsrc uut (
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