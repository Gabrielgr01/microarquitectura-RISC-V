//Modulo encargado de almacenar datos en memoria, asi como recuperarlos de esta para escribir en el register file
module DataMemory(
    //Como entradas tiene el reloj, el reset, si se escribe o se lee memoria, si la operacion es un store byte, la direccion a la que se quiere acceder y los datos a escribir en caso de escritura de memoria. 
    //Como salida tiene los datos que se leen en caso de lectura de memoria
    input clk, reset, MemWrite, MemRead, sb,
    input [31:0] direccion, escritura_datos,
    output [31:0] leer_datos 
    );
    //Se crean 32 espacios de memoria, cada uno de 32 bits
    reg [31:0] memoria_datos [31:0];
    //tanto direccion palabra como offset son necesarios para implementar el store byte, direccion de palabra hace una division entre 4 para obtener la palabra y el offset son los primeros dos bits de la direccion, 
    //que indica si es el byte 0, 1, 2 o 3
    wire [4:0] direccion_palabra = direccion[6:2]; 
    wire [1:0] offset = direccion[1:0];
 //Se agrega un task que se puede llamar al final de la simulacion del modulo top, este task se encarga de hacer un dump de los contenidos de memoria a un archivo de texto para su revision
    task dump_memory;
        integer file, i;
        begin
            file = $fopen("data_memory_dump.txt", "w");
            if (file) begin
                for (i = 0; i < 32; i = i + 1) begin
                    $fwrite(file, "memoria_datos[%0d] = %h\n", i, memoria_datos[i]);
                end
                $fclose(file);
            end else begin
                $display("Error abriendo el archivo.");
            end
        end
    endtask


    //Se inician los valores en cero
    initial begin
        for (integer k = 0; k < 32; k = k + 1)
            begin
                memoria_datos[k] = 32'h0;
            end
        end
    //De forma sincrona se lee de memoria o se escribe en ella, se tiene una señal de control sb para las operaciones especiales para realizar un store byte
    always @(posedge clk or posedge reset)
    begin
    // En caso de reset todo se vuelve cero
        if (reset)
        begin
            for (integer k = 0; k < 32; k = k + 1)
            begin
                memoria_datos[k] = 32'h0;
            end
        end
        else if (MemWrite)
        begin
            if (sb)
            begin
                case (offset)
                    2'b11: memoria_datos[direccion_palabra][7:0]   = escritura_datos[7:0];
                    2'b10: memoria_datos[direccion_palabra][15:8]  = escritura_datos[7:0];
                    2'b01: memoria_datos[direccion_palabra][23:16] = escritura_datos[7:0];
                    2'b00: memoria_datos[direccion_palabra][31:24] = escritura_datos[7:0];
                endcase
            end
            else
            begin
                memoria_datos[direccion] = escritura_datos;
            end
        end
    end
    //En caso de querer leer datos se pregunta si hay señal de MemRead, de haberla se leen los contenidos en la direccion proporcionada
    assign leer_datos = (MemRead) ? memoria_datos[direccion] : 32'b0;

endmodule

//Este test bench tiene como finalidad comprobar la correcta escritura y lectura en la memoria de datos, asi como el funcionamiento de store byte
module tb_DataMemory;

  // Señales de entrada
  reg clk;
  reg reset;
  reg MemWrite;
  reg MemRead;
  reg sb;
  reg [31:0] direccion;
  reg [31:0] escritura_datos;

  wire [31:0] leer_datos;

  DataMemory uut (
    .clk(clk),
    .reset(reset),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .sb(sb),
    .direccion(direccion),
    .escritura_datos(escritura_datos),
    .leer_datos(leer_datos)
  );
    integer i;
    integer file;
    always #5 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
    MemWrite = 0;
    MemRead = 0;
    sb = 0;
    direccion = 0;
    escritura_datos = 0;
    
    // Reset
    #10;
    reset = 0;

    // Escribir 32 bits en la memoria en la dirección 5
    direccion = 5;
    escritura_datos = 32'hDEADBEEF;
    MemWrite = 1;
    #10;
    MemWrite = 0;

    // Leer desde la dirección 5
    MemRead = 1;
    #10;
    if (leer_datos !== 32'hDEADBEEF) $display("Lectura incorrecta");
    else $display("Lectura correcta");
    MemRead = 0;
    #10;


    // Probar Store Byte
    direccion = 10;  // Byte en dirección 10
    escritura_datos = 32'b00000000000001000101011001111111; 
    MemWrite = 1; 
    sb = 1;
    #10;
    MemWrite = 0;
    sb = 0; 
    direccion = 2;
    MemRead = 1;
    #10;
    // Verificar si solo el byte correcto fue almacenado en la direccion correcta
    $display("Datos leídos para store byte: %b", leer_datos);
    if (leer_datos[15:8] !== 8'b01111111) $display("Store byte incorrecto");
    else $display("Store byte correcto");
    MemRead = 0;
    uut.DataMemory.dump_memory();
    $finish;
  end
endmodule
