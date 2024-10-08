module ImmGen(
input [6:0] opcode,
input [31:0] instruccion,
output reg [31:0] Imm
);

always @(*)
begin
    Imm = 32'b0; 
    case(opcode)
    7'b0110111 : Imm = instruccion[31:12]<<12;
    7'b0010011 : Imm = {{20{instruccion[31]}}, instruccion[31:20]};
    7'b0000011 : Imm = {{20{instruccion[31]}}, instruccion[31:20]};
    7'b0100011 : Imm = {{20{instruccion[31]}}, instruccion[31:25], instruccion[11:7]};
    7'b1100011 : Imm = {{19{instruccion[31]}}, instruccion[31], instruccion[30:25], instruccion[11:8], 1'b0};
    7'b1101111 : Imm = {{19{instruccion[31]}}, instruccion[30:21], instruccion[20], instruccion[19:12], 1'b0};
    default: Imm = 32'b0;
    endcase

end
endmodule