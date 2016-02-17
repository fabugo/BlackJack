module BlackJackFSM(
	input clock,
	input reset,
	input stay,
	input hit,
	input wire [3:0] card,
	output reg win,
	output reg lose,
	output reg tie,
	output reg dhit,
	output reg dstay
	);

	localparam 	START  	= 3'b000,
				ONHANDS	= 3'b001,
				PTURN	= 3'b010,
				PASS	= 3'b011,
				DTURN	= 3'b100,
				RESULT	= 3'b101;

	reg [4:0] dhand;
	reg [4:0] phand;
	reg [2:0] state;
	reg [2:0] next_state;
	reg [1:0] countIni;
	reg delayHit;
	reg delayDHit;
	reg reqDhit;
	reg countPass;

	always @(negedge clock)begin
		if(state == 2 && hit)						delayHit <= 1;
		if(state == 4 && dhit)						delayDHit <=1;
	end
	always @(posedge clock or posedge reset) begin
		if(reset) 									state <= START;
		else 										state <= next_state;
		if(dhit)										dhit <= 0;
		else if(state == 4 && reqDhit)					dhit <= 1;
	end

	//distribuicao de cartas serial
	always @(negedge clock)begin
		case(state)
			ONHANDS:begin
				case(countIni)
					0:begin	if(card)begin 	phand = phand + card;
													countIni = countIni + 1;
													next_state = ONHANDS;
							end
					end
					1:begin	if(card)begin	dhand = dhand + card;
													countIni = countIni + 1;
													next_state = ONHANDS;
							end
					end
					2:begin	if(card)begin 	phand = phand + card;
													countIni = countIni + 1;
													next_state = ONHANDS;
							end
					end
					3:begin	if(card) begin 	dhand = dhand + card;
													next_state = PTURN;
							end
					end
				endcase
			end
			PASS:begin
				case(countPass)
					0:begin next_state = PASS;
							countPass = countPass + 1;
					end
					1:begin dhand = dhand + card;
							next_state = DTURN;
							countPass = 0;
					end
				endcase
			end
		endcase
	end

	//bloco combinaciona filho da puta
	always @(*) begin
	lose  = 0;	tie   = 0;	dstay = 0;	win   = 0;
		case(state)
			START:begin dhand = 0; phand = 0; countIni = 0;delayHit=0;dhit = 0;
						countPass = 0;reqDhit=0;delayDHit = 0;
													next_state = ONHANDS;
				 end
			PTURN:begin
				if(stay)							next_state = PASS;
				else if(delayHit == 1)begin			next_state = PTURN;
													phand = phand + card;
													delayHit = 0;
				end
				if(phand > 21)						next_state = RESULT;
			end
			DTURN:begin
				if(dhand > 16)						next_state = RESULT;
				else if(!dhit) 						reqDhit = 1;
				else if(delayDHit)begin				next_state = DTURN;
													dhand = dhand + card;
													delayDHit = 0;
													reqDhit = 0;
				end
			end
			RESULT:begin
				dstay = 1;
				next_state = RESULT;
				if(dhand == phand || (dhand > 21 && phand > 21))
													tie 	= 1;
				else if(dhand > phand && dhand <= 21 && phand <= 21)
													lose = 1;
				else if(phand > dhand && dhand <= 21 && phand <= 21)
													win = 1;
				else if(dhand <= 21 && phand > 21)
													lose = 1;
				else if(phand <= 21 && dhand > 21)
													win = 1;
			end
		endcase
	end
endmodule
