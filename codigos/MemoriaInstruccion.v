module memoria_instruccion(
    input reset, 
    input [31:0] leer_direccion, 
    output [31:0] instruccion
);

reg [31:0] memoria [31:0];
assign instruccion = memoria[leer_direccion];

initial 
begin
        $readmemh("memory_init.hex", memoria);  
end

always @(posedge reset)
begin
    if (reset) begin
        for (integer k = 0; k < 32; k = k + 1)
            begin
            memoria[k] <= 32'h0;
            end
        end
    end
endmodule


