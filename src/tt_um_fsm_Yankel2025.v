module tt_um_fsm_Yankel2025 (
  input        clk,
  input        rst_n,    // Reset activo en bajo
  input        ena,
  input  [7:0] ui_in,
  output [7:0] uo_out,
  input  [7:0] uio
  output [7:0] uio_oe
);
  wire [7:0] sw = ui_in;  // sw[8:0]
  wire btnC = ~rst_n;
  wire [2:0] led;
  
    reg cerrar,medio,abrir;    // variables internas de acciones de usuario
    reg auto; 
    wire [1:0] Sensor;    // variable interna para recibir la instruccion del sensor
    wire Ssupe,Smedi,Sinfe;    // variables para obtener el valor de los sensores de la persiana
    reg [24:0] clk_nuevo;    // señal de reloj para escalar
    wire reseteo;    // reinicio de datos de entrada
    wire arriba, abajo;    // acciones de la persiana
    
    assign reseteo = btnC;    // guarda señal de reinicio
    assign Sensor = sw[4:3];    // recibe señal de sensor
    assign Sinfe = sw[5];    // recibe señales de los sensores de la persiana
    assign Smedi = sw[6];
    assign Ssupe = sw[7];
    
    always @(posedge clk)    // escalado de tiempo de la señal de reloj interna de 100MHz
        clk_nuevo <= clk_nuevo + 1;
    
    
    always @(posedge clk_nuevo[24], posedge reseteo)
        begin
            if (reseteo) begin
                cerrar <= 1'b0;
                medio <= 1'b0;
                abrir <= 1'b0;
                auto <= 1'b0;
            end else begin
              case (sw[2:0])
                3'b001: begin cerrar <= 1; medio <= 0; abrir <= 0; auto <= 0; end
                3'b010: begin cerrar <= 0; medio <= 1; abrir <= 0; auto <= 0; end
                3'b011: begin cerrar <= 0; medio <= 0; abrir <= 1; auto <= 0; end
                3'b100: begin cerrar <= 0; medio <= 0; abrir <= 0; auto <= 1; end
                default: begin cerrar <= 0; medio <= 0; abrir <= 0; auto <= 0; end
            endcase
            end
        end
    
    
    // Llamada a funcion de Maquina de Estado Finito (FSM) y regreso de accion de maquina
    FSM_Persiana persianas(.abierta(abrir),.media(medio),.cerrada(cerrar),.automatico(auto),
                      .Reloj(clk_nuevo[24]),.reset(reseteo),.Ssup(Ssupe),.Smed(Smedi),.Sinf(Sinfe),
                      .sensor(Sensor),.subir(arriba),.bajar(abajo));
     
    assign led[2] = clk_nuevo[24];    // muestra señal de reloj       
    assign led[1] = arriba;    // muestra si esta subiendo persiana
    assign led[0] = abajo;    // muestra si esta bajando persiana

  assign uo_out  = {5'b00000, led};  // sólo usamos bits 2:0
  assign uio_out = 8'b00000000;      // no estamos manejando salida bidireccional
  assign uio_oe = 8'b11111111;    // Configura todos los pines uio como salidas
    
endmodule
