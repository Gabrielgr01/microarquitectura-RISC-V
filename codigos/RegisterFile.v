module RegisterFile(input clk,
input reset,
input regWrite,
input [4:0] A1,
input [4:0] A2,
input [4:0] A3,
input [31:0] WD,
output [31:0] RS1,
output [31:0] RS2
);

reg [31:0] registros [31:0];

assign RS1 = registros[A1];
assign RS2 = registros[A2];

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        for (integer k = 0; k < 32; k = k + 1)
            begin
            registros[k] <= 32'h0;
            end
    end
    else if (regWrite && A3 != 5'b00000)
    begin
        registros[A3] <= WD;
    end
end
endmodule
