//Modulo encargado de cargar en memoria las instrucciones, asi como de enviar las instrucciones correspondientes a la direccion que le llega como entrada
module memoria_instruccion(
    //Como entrada tiene el reset y la direccion de la instruccion, como salida envia la instruccion ubicada en la direccion recibida.
    input reset,
    input [31:0] leer_direccion, 
    output reg [31:0] instruccion
    );
    //Se crea un regitro de 128 espacios, cada uno de 32 bits
    reg [31:0] memoria [127:0]; 

    initial
    begin 
        //Como paso inicial se ponen todos los registros en cero, esto para que tengan un valor definido 
        for (integer i = 0; i < 128; i = i + 1)
        begin
            memoria[i] = 32'h0;
        end
        //Se carga el .hex al registro
        $readmemh("memory_init.hex", memoria, 0, 127);
    end

    always @(*) 
    begin
    //De forma asicrona se leen las instrucciones, las direcciones se dividen entre 4 ya que llegan en multiplos de 4 (palabras)y para el archivo las instrucciones van 0, 1, 2....
        instruccion <= memoria[leer_direccion/4];
    end
    // En caso de ocurrir un reset tanto los espacios de memoria como la direccion se establecen como cero
    always @(posedge reset)
    begin
        if (reset) begin
            for (integer k = 0; k < 128; k = k + 1)
                begin
                memoria[k] <= 32'h0;  
            end
            instruccion <= 32'h0;
        end
    end
endmodule

//Este testbench tiene como finalidad comprobar la lectura correcta de el archivo de memoria y el funcionamiento del reset, se espera ver que en las direcciones dadas esten las instrucciones en el archivo .hex
module memoria_instruccion_tb;
    reg reset;
    reg [31:0] leer_direccion;
    wire [31:0] instruccion;

    memoria_instruccion uut (
        .reset(reset),
        .leer_direccion(leer_direccion),
        .instruccion(instruccion)
    );

    initial begin
        reset = 0;
        leer_direccion = 32'h00000000;

        #10;

        leer_direccion = 32'h00000000;  
        #10;
        $display("Instrucción en direccion 0: %h", instruccion);

        leer_direccion = 32'h00000004;  
        #10;
        $display("Instrucción en direccion 4: %h", instruccion);

        leer_direccion = 32'h00000008;  
        #10;
        $display("Instrucción en direccion 8: %h", instruccion);

        leer_direccion = 32'h0000000C;  
        #10;
        $display("Instrucción en direccion C: %h", instruccion);

        reset = 1;
        #10;
        reset = 0;
        #10;

        if (instruccion != 32'h0)
            $display("Prueba Fallida: Reset no puso instruccion en 0");
        else
            $display("Reset realizado correctamente, instruccion en 0");
        $finish;
    end
endmodule
