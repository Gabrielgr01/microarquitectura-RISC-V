//Modulo mux para determinar si se quiere hacer writeback desde memoria o desde la ALU
module muxMemtoReg (
       input sel, //sel es la señal de control memtoreg, A viene del data memory y B es la salida de la ALU
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
    );

    assign out = (sel) ? B : A; 
endmodule

//Test bench sencillo para verificar que si el selector es cero sale A, de ser 1 sale B
module muxMemtoReg_tb;

    reg sel;                   
    reg [31:0] A, B;           
    wire [31:0] out;          

    muxMemtoReg uut (
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