//Modulo que carga la siguiente direccion de la instruccion a memoria de instruccion 
module ProgramCounter (
    //Como entradas tiene el reloj del sistema, el reset y el pc actual, como salida tiene la direccion de  la siguiente instruccion 
        input clk,                      
        input reset,                    
        input [31:0] pc_in,
        output reg [31:0] pc_out                                   
    );
    initial begin
        pc_out = 32'b0; 
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0;  //En caso de haber reset se manda como salida la direccion 0
        end
        else 
        begin
            pc_out <= pc_in;  // Con cada flanco positivo de reloj se actualiza la direccion de instruccion 
        end
    end

endmodule

//Este test bench tiene como finalidad comprobar el funcionamiento del reset y la actualizacion de pc out dependiendo de pc in
module ProgramCounter_tb;
    reg clk;
    reg reset;
    reg [31:0] pc_in;
    wire [31:0] pc_out;
    
    ProgramCounter uut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;  
    initial begin
        clk = 0;
        reset = 0;
        pc_in = 32'h00000000;

        reset = 1;

        reset = 0;

        if (pc_out != 32'h00000000) 
            $display("Incorrecto");
        else
            $display("Correcto");

        pc_in = 32'h00000004;
        #10;
        if (pc_out != 32'h00000004) 
            $display("Incorrecto");
        else
            $display("Correcto");

        pc_in = 32'h00000008;
        #10;
        if (pc_out != 32'h00000008) 
            $display("Incorrecto");
        else
            $display("Correcto");

        pc_in = 32'h0000000C;
        #10;
        if (pc_out != 32'h0000000C) 
            $display("Incorrecto");
        else
            $display("Correcto");

        reset = 1;
        #10;
        if (pc_out != 32'h00000000) 
            $display("Incorrecto");
        else
            $display("Correcto");
        reset = 0;

        $finish;
    end
endmodule

