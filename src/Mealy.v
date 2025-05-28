`timescale 1ns / 1ps

module FSM_mealy(input wire [1:0] P,
                 input wire Ssup,Smed,Sinf,reloj,reset,
                 output wire subir,bajar);
                 
logic stop_actuador_subir,stop_actuador_bajar;
logic a,sub,baj;

typedef enum logic reg [1:0] {S0,S1,S2} tipo_estado;
tipo_estado state, nextstate;

//NEXT STATE LOGIC
always begin
    sub=(((~state[0])&(~P[1])&P[0])|(P[1]&(~P[0])))&(~state[1]);
    baj=(((~state[1])&state[0]&(~P[0]))|(state[1]&(~state[0])))&(~P[1]);
    case (state)
        S0: if ((P==2'b01)&sub&(~baj)) nextstate<=S1;
            else if ((P==02'b10)&sub&(~baj)) nextstate<=S2;
            else nextstate<=S0;
        S1: if ((P==2'b10)&sub&(~baj)) nextstate<=S2;
            else if ((P==2'b00)&(~sub)&baj) nextstate<=S0;
            else nextstate<=S1;
        S2: if ((P==2'b00)&(~sub)&baj) nextstate<=S0;
            else if ((P==2'b01)&(~sub)&baj) nextstate<=S1;
            else nextstate<=S2;
        default: nextstate<=S2;
    endcase 
 end

//REGISTRO
always_ff @(posedge reloj, posedge reset)
    if(reset) state<=S0;
    else state<=nextstate;

//OUTPUT LOGIC
always 
begin
    a<=Smed&P[0]&(~P[1]);
    stop_actuador_subir<=(Ssup&(~P[0])&P[1])|baj|a;
    stop_actuador_bajar<=(Sinf&(~P[0])&(~P[1]))|a|sub;
end

always @(posedge stop_actuador_subir, posedge sub)    //control de actuador para subir persiana
    if (stop_actuador_subir) subir<=1'b0;
    else subir<=1'b1;
  
always @(posedge stop_actuador_bajar, posedge baj)    //control de actuador para bajar persiana
    if (stop_actuador_bajar) bajar=1'b0;
    else bajar<=1'b1;

endmodule
