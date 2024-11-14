//Modulo encargado de realizar las operaciones logico aritmeticas 
module ALU (
    //Tiene como entradas los dos valores a los que se les va a aplicar las oepraciones logicas o aritmeticas y una señal de control que determina que operacion se va a realizar y como salida tiene el resultado
    //de la operacion, el resultado de las comparaciones logicas y una bandera de cero
    input [31:0] A,        
    input [31:0] B,        
    input [2:0] control,   
    output reg [31:0] result,
    output reg comp,  
    output reg cero         
    );

    always @(*) begin
    //de forma asincrona se evalua el valor de control y se realizan las operaciones correspondientes 
        case (control)
            3'b000: result = A + B;               
            3'b001: result = A << B;              
            3'b010: result = A & B;               
            3'b011: comp = (A != 0) ? 32'b1 : 32'b0; 
            3'b100: comp = (A >= B) ? 32'b1 : 32'b0;
            3'b101: result = B;  
            default: result = 32'b0;
            default: comp = 32'b0;              
        endcase

        
        cero = (result == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule

//El testbench tiene como finalidad comprobar que las operaciones e realicen correctamente y que los codigos correspondientes a cada operacion se lean correctamente y esten asociados a la operacion correspondiente
module ALU_tb;
    reg [31:0] A;
    reg [31:0] B;
    reg [2:0] control;
    wire [31:0] result;
    wire comp;
    wire cero;

    ALU uut (
        .A(A),
        .B(B),
        .control(control),
        .result(result),
        .comp(comp),
        .cero(cero)
    );

    initial begin
        A = 32'h00000003;
        B = 32'h00000004;
        control = 3'b000;
        #10;
        if (result !== 32'h00000007)
            $display("Error en Suma: Esperado 7, Obtenido = %h", result);
        else
            $display("Suma Exitosa: Resultado = %h", result);

        A = 32'h00000001;
        B = 32'h00000002;
        control = 3'b001;
        #10;
        if (result !== 32'h00000004)
            $display("Error en Shift Left: Esperado 4, Obtenido = %h", result);
        else
            $display("Shift Left Exitoso: Resultado = %h", result);

        A = 32'hFFFFFFFF;
        B = 32'h0F0F0F0F;
        control = 3'b010;
        #10;
        if (result !== 32'h0F0F0F0F)
            $display("Error en AND: Esperado 0F0F0F0F, Obtenido = %h", result);
        else
            $display("AND Exitoso: Resultado = %h", result);

        A = 32'h00000001;
        control = 3'b011;
        #10;
        if (comp !== 1'b1)
            $display("Error en Comparación de Desigualdad: Esperado 1, Obtenido = %b", comp);
        else
            $display("Comparación de Desigualdad Exitosa: Comp = %b", comp);

        A = 32'h00000000;
        control = 3'b011;
        #10;
        if (comp !== 1'b0)
            $display("Error en Comparación de Desigualdad: Esperado 0, Obtenido = %b", comp);
        else
            $display("Comparación de Desigualdad Exitosa: Comp = %b", comp);

        A = 32'h00000005;
        B = 32'h00000003;
        control = 3'b100;
        #10;
        if (comp !== 1'b1)
            $display("Error en Comparación Mayor o Igual: Esperado 1, Obtenido = %b", comp);
        else
            $display("Comparación Mayor o Igual Exitosa: Comp = %b", comp);

        A = 32'h00000002;
        B = 32'h00000003;
        control = 3'b100;
        #10;
        if (comp !== 1'b0)
            $display("Error en Comparación Mayor o Igual: Esperado 0, Obtenido = %b", comp);
        else
            $display("Comparación Mayor o Igual Exitosa: Comp = %b", comp);

        A = 32'h00000000;
        B = 32'h12345678;
        control = 3'b101;
        #10;
        if (result !== 32'h12345678)
            $display("Error en Pasar B: Esperado 12345678, Obtenido = %h", result);
        else
            $display("Pasar B Exitoso: Resultado = %h", result);

        // Finalizar la simulación
        $display("Test completo.");
        $finish;
    end
endmodule
