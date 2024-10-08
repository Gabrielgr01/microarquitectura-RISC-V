module ALU (
    input [31:0] A,        
    input [31:0] B,        
    input [2:0] control,   
    output reg [31:0] result,
    output reg comp, 
    output reg zero         
    );

    always @(*) begin
        case (control)
            3'b000: result = A + B;               
            3'b001: result = A << B;              
            3'b010: result = A & B;               
            3'b011: comp = (A != 0 || B != 0 ) ? 32'b1 : 32'b0; 
            3'b100: comp = (A >= B) ? 32'b1 : 32'b0;
            3'b101: result = B;  
            default: result = 32'b0;              
        endcase

    
        zero = (result == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule


module logica_and(
input branch,
input comparacion,
output and_out

);

assign and_out = branch & comparacion;

endmodule
