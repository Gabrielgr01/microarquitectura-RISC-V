//Modulo encargado de almacenar los registros necesarios para la ejecucion del programa, tambien permite leer datos ya existentes en los registros
module RegisterFile(
    //Tiene como entrada la señal de reloj, el reset, si se quiere escribir en el registro, las posibles direcciones a las que se accede y el valor del writeback. Como salidas tiene los valores que estaban almacenados
    //en las direcciones A1 o A2 
    input clk,
    input reset,
    input regWrite,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    output [31:0] RS1,
    output [31:0] RS2
    );
    //Se crean 32 registros de 32 bits cada uno
    reg [31:0] registros [31:0];
    //Se asigna que las salidas son los datos almacenados en los registros en las direcciones A1 y A2
    assign RS1 = registros[A1];
    assign RS2 = registros[A2];
    //Al inicio todo es cero
    initial begin
        for (integer i = 0; i < 32; i = i + 1)
        begin
            registros[i] = 32'h0;
        end
    end
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (integer k = 0; k < 32; k = k + 1)
                begin
                registros[k] <= 32'h0;
                end
        end
        //De forma sincrona u si existe la señal de escritura en registro se asigna el valor en WD a la direccion A3, menos si es 0, ya que es una direccion no accesible
        else if (regWrite && A3 != 5'b00000)
        begin
            registros[A3] <= WD;
        end
    end
endmodule

//Este testbench asegura que la lectura de los registros es correcta y que el reset funciona como se espera 
module RegisterFile_tb;
    reg clk;
    reg reset;
    reg regWrite;
    reg [4:0] A1, A2, A3;
    reg [31:0] WD;
    wire [31:0] RS1, RS2;

    RegisterFile uut (
        .clk(clk),
        .reset(reset),
        .regWrite(regWrite),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD(WD),
        .RS1(RS1),
        .RS2(RS2)
    );


    always #5 clk = ~clk;  

    initial begin
        clk = 0;
        reset = 0;
        regWrite = 0;
        //Se inician las direcciones para los registros que se quieren leer

        reset = 1;
        #10;
        reset = 0;

        A1 = 5'd0;
        A2 = 5'd1;
        #10;
        $display("Lectura inicial RS1 = %h, RS2 = %h", RS1, RS2);

    //se escribe en la direccion 2 el valor ABCD1234, esto comprueba que la escritura sea correcta 
        regWrite = 1;
        A3 = 5'd2;
        WD = 32'hABCD1234;
        #10;
    //Se desativa la señal regWrite y se verifica que en la direccion 2 se encuentre el valor escrito anteriorimente
        regWrite = 0;
        A1 = 5'd2;  
        #10;
        if (RS1 != 32'hABCD1234)
            $display("Prueba Fallida: Valor en registro[2] esperado: ABCD1234, obtenido: %h", RS1);
        else
            $display("Prueba Exitosa: Valor en registro[2] = %h", RS1);

        //se escribe en la direccion 0 el valor FFFFFFFF, esto comprueba que la escritura este deshabilitada para el registro 0
        regWrite = 1;
        A3 = 5'd0;
        WD = 32'hFFFFFFFF;
        #10;
        //Se desativa la señal regWrite y se verifica que en la direccion 2 se encuentre el valor cero y no FFFFFFFF
        regWrite = 0;
        A1 = 5'd0;
        #10;
        if (RS1 != 32'h00000000)
            $display("Prueba Fallida: registro[0] no se puede modificar, el valor actual es", RS1);
        else
            $display("Prueba Exitosa: registro[0] sigue siendo %h", RS1);

        reset = 1;
        #10;
        reset = 0;
        //Por ultimo se comprueba el reset
        A1 = 5'd2;
        #10;
        if (RS1 != 32'h00000000)
            $display("Prueba Fallida: Reset no puso registro[2] en 0, obtenido: %h", RS1);
        else
            $display("Prueba Exitosa: registros correctamente reseteados a %h", RS1);

        $display("Test completo.");
        $finish;
    end
endmodule
