module ProgramCounter (
    input clk,                      
    input reset,                    
    input [31:0] pc_in,
    output reg [31:0] pc_out,             
    input pc_write                       
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0;  
        end
        else 
        begin
            pc_out <= pc_out + 32'd4;  
        end
    end

endmodule

module PCmas4(input [31:0] actual, 
output [31:0] siguiente
);

assign siguiente = 32'd4 + actual;
endmodule
