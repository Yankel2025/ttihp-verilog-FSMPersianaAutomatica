

module tt_um_fsm_Yankel2025 (
  input wire  [8:0] sw,
  input wire btnC,
  input wire clk,
  output reg [2:0] led
);
    
    logic wire cerrar,medio,abrir;    // variables internas de acciones de usuario
    logic wire auto; 
    logic wire [1:0] Sensor;    // variable interna para recibir la instruccion del sensor
    logic wire Ssupe,Smedi,Sinfe;    // variables para obtener el valor de los sensores de la persiana
    logic wire[24:0] clk_nuevo;    // señal de reloj para escalar
    logic wire reseteo;    // reinicio de datos de entrada
    logic wire arriba, abajo;    // acciones de la persiana
    
    assign reseteo = btnC;    // guarda señal de reinicio
    assign Sensor = sw[5:4];    // recibe señal de sensor
    assign Sinfe = sw[6];    // recibe señales de los sensores de la persiana
    assign Smedi = sw[7];
    assign Ssupe = sw[8];
    
    always_ff @(posedge clk)    // escalado de tiempo de la señal de reloj interna de 100MHz
        clk_nuevo <= clk_nuevo + 1;
    
    
    always_ff @(posedge clk_nuevo[24], posedge reseteo)
        begin
            if (reseteo) begin
                cerrar <= 1'b0;
                medio <= 1'b0;
                abrir <= 1'b0;
                auto <= 1'b0;
            end else begin
                if (sw[3:0] == 4'b0001 ) begin
                    cerrar <= 1'b1;
                    medio <= 1'b0;
                    abrir <= 1'b0;
                    auto <= 1'b0;
                end
                if (sw[3:0] == 4'b0010 ) begin
                    cerrar <= 1'b0;
                    medio <= 1'b1;
                    abrir <= 1'b0;
                    auto <= 1'b0;
                end
                if (sw[3:0] == 4'b0100 ) begin
                    cerrar <= 1'b0;
                    medio <= 1'b0;
                    abrir <= 1'b1;
                    auto <= 1'b0;
                end
                if (sw[3:0] == 4'b1000 ) begin
                    cerrar <= 1'b0;
                    medio <= 1'b0;
                    abrir <= 1'b0;
                    auto <= 1'b1;
                end
            end
        end
    
    
    // Llamada a funcion de Maquina de Estado Finito (FSM) y regreso de accion de maquina
    FSM_Persianas persianas(.abierta(abrir),.media(medio),.cerrada(cerrar),.automatico(auto),
                      .Reloj(clk_nuevo[24]),.reset(reseteo),.Ssup(Ssupe),.Smed(Smedi),.Sinf(Sinfe),
                      .sensor(Sensor),.subir(arriba),.bajar(abajo));
     
    assign led[2] = clk_nuevo[24];    // muestra señal de reloj       
    assign led[1] = arriba;    // muestra si esta subiendo persiana
    assign led[0] = abajo;    // muestra si esta bajando persiana
    
endmodule
