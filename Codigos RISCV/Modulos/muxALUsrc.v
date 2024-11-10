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

//Test bench sencillo para verificar que si el selector es cero sale A, de ser 1 sale B
module muxALUsrc_tb;

    reg sel;                   
    reg [31:0] A, B;           
    wire [31:0] out;          

    muxALUsrc uut (
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