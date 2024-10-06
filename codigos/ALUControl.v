module ALUControl (
    input [2:0] ALUop,        
    input [2:0] funct3,          
    output reg [2:0] out        
);

always @(*)
begin
    if (ALUop == 3'b000)
    begin
        out = 3'b101;
    end
    else
    begin
        case({ALUop, funct3})
            6'b001_001 : out = 3'b011;
            6'b001_010 : out = 3'b100;
            6'b010_010 : out = 3'b000;
            6'b011_010 : out = 3'b000;
            6'b100_000 : out = 3'b000;
            6'b100_111 : out = 3'b010;
            6'b100_001 : out = 3'b001;
        endcase
    end
end
endmodule