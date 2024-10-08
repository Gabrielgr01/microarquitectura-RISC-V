module mux2a1 (
       input sel,
       input [31:0] A,
       input [31:0] B,
       output [31:0] out
);

    assign out = (sel) ? B : A; 

endmodule


module logica_andBranch(
    input branch,
    input comparacion,
    output and_out
    );
    assign and_out = branch & comparacion;
endmodule


module sumador_branch(
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] out_suma
    );
    assign out_suma = input1 + (input2<<2);
endmodule