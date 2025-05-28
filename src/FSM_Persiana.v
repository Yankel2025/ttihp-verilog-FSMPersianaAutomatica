`timescale 1ns / 1ps

module FSM_Persiana(input wire abierta,media,cerrada,automatico,
                     input wire Reloj,reset,
                     input wire Ssup,Smed,Sinf,
                     input wire [1:0] sensor,
                     output wire subir, bajar);
wire [1:0] posicion;

FSM_moore moore(
  .ab(abierta),
  .me(media),
  .ba(cerrada),
  .auto(automatico),
  .reloj(Reloj),
  .reset(reset),
  .sensor(sensor),
  .P(posicion)
);

FSM_mealy mealy(
  .P(posicion),
  .Ssup(Ssup),
  .Smed(Smed),
  .Sinf(Sinf),
  .reloj(Reloj),
  .reset(reset),
  .subir(subir),
  .bajar(bajar)
);

endmodule
