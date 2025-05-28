`timescale 1ns / 1ps

module Mealy(input wire [1:0] P,
             input wire Ssup,Smed,Sinf,reloj,reset,
             output reg subir,bajar);
                 
reg stop_actuador_subir,stop_actuador_bajar;
reg a,sub,baj;

parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;
reg [1:0] state, nextstate;

//NEXT STATE LOGIC
 always @(*) begin
        sub = ((~state[0]) & (~P[1]) & P[0]) | (P[1] & (~P[0])) & (~state[1]);
        baj = ((~state[1]) & state[0] & (~P[0])) | (state[1] & (~state[0])) & (~P[1]);
        
        case (state)
            S0: if ((P == 2'b01) && sub && ~baj) nextstate = S1;
                else if ((P == 2'b10) && sub && ~baj) nextstate = S2;
                else nextstate = S0;
            S1: if ((P == 2'b10) && sub && ~baj) nextstate = S2;
                else if ((P == 2'b00) && ~sub && baj) nextstate = S0;
                else nextstate = S1;
            S2: if ((P == 2'b00) && ~sub && baj) nextstate = S0;
                else if ((P == 2'b01) && ~sub && baj) nextstate = S1;
                else nextstate = S2;
            default: nextstate = S0;
        endcase 
    end

//REGISTRO
  always @(posedge reloj or posedge reset)
    if(reset) state<=S0;
    else state<=nextstate;

//OUTPUT LOGIC
 always @(*) begin
        a = Smed & P[0] & ~P[1];
        stop_actuador_subir = (Ssup & ~P[0] & P[1]) | baj | a;
        stop_actuador_bajar = (Sinf & ~P[0] & ~P[1]) | a | sub;
  end

always @(posedge reloj or posedge reset) begin
    if (reset)
        subir <= 1'b0;
    else if (sub)
        subir <= 1'b1;
    else if (stop_actuador_subir)
        subir <= 1'b0;
end
  
always @(posedge reloj or posedge reset) begin
    if (reset)
        bajar <= 1'b0;
    else if (baj)
        bajar <= 1'b1;
    else if (stop_actuador_bajar)
        bajar <= 1'b0;
end

endmodule
