module mux2a1 (
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
);

    assign out = (sel) ? B : A; 

endmodule
