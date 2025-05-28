`timescale 1ns / 1ps

module Moore(input wire ab,me,ba,auto,reloj,reset,
                 input wire [1:0] sensor,
                 output logic [1:0] P);
reg [1:0] nivel,state,nextstate;
 
// CODIFICACIÓN DE ENTRADAS
assign nivel[1]=(((~me)&(~ba)&sensor[1])&(~sensor[0])&auto)|ab;
assign nivel[0]=((~ab)&(~ba)&(~sensor[1])&sensor[0]&auto)|((~ab)&me);

//NEXT STATE LOGIC
always
begin
    if(nivel==(2'b00)|(2'b01)|(2'b10)) begin
        nextstate[1]=((~state[1])&(nivel[1]))|((~state[0])&nivel[1]); 
        nextstate[0]=((~state[1])&(~nivel[1])&(nivel[0]))|((~state[0])&(~nivel[1])&(nivel[0]));
    end
    else begin 
        nextstate=2'b10;
    end
 end 

//REGISTRO
always @(posedge reloj,posedge reset)
    if (reset) state<=2'b00;
    else state<=nextstate;
    
//OUTPUTS LOGIC
assign P=state;  
