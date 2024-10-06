module RegFile(input clk,
input reset,
input regWrite,
input [19:15] A1,
input [24:20] A2,
input [11:7] A3,
input [31:0] WD,
output [31:0] RS1,
output [31:0] RS2
);

reg [31:0] registros [31:0];

assign RS1 = registros[A1];
assign RS2 = registros[A2];

always @(posedge clk)
begin
    if (reset == 1'b1)
    begin
        for (integer k = 0; k < 32; k = k + 1)
            begin
            registros[k] = 32'h0;
            end
    end
    else if (regWrite == 1'b1)
    begin
        registros[A3] = WD;
    end
end
endmodule
