module DataMemory(
input clk, reset, MemWrite, MemRead,
input [31:0] direccion, escritura_datos,
output [31:0] leer_datos 
);

reg [31:0] memoria_datos [31:0];
always @(posedge clk or posedge reset)
begin

    if (reset)
    begin
        for (integer k = 0; k < 32; k = k + 1)
        begin
        memoria_datos[k] = 32'h0;
        end
    end
    else if (MemWrite)
    begin
        memoria_datos[direccion] = escritura_datos;
    end
end
assign leer_datos = (MemRead) ? memoria_datos[direccion] : 32'b00;
endmodule