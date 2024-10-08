module Control(
input [6:0] opcode,
output reg branch, 
output reg jump,
output reg [2:0] ALUop,
output reg ALUsrc,
output reg MemWrite,
output reg regWrite,  
output reg MemRead,
output reg MemToReg
);

always @(*)
begin
    {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b0;
    case(opcode)
    7'b0110111 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b1010000_000;
    7'b1101111 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b1000001_000;
    7'b1100011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b0000010_001;
    7'b0000011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b1110100_010;
    7'b0100011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b1001000_011;
    7'b0010011 : {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b1010000_100;
    default: {ALUsrc, MemToReg, regWrite, MemWrite, MemRead, branch, jump, ALUop} = 10'b0;
    endcase
end
endmodule