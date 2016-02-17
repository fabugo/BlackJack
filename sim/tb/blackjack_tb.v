// ------------------------------------------------------------------------------
// Universidade Estadual de Feira de Santana
// TEC 446 Automação do Projeto de Circuitos Integrados
// 2015.1
//
// Module: blackjack_tb
// Description: Simple testbench for Blackjack FSM
// ------------------------------------------------------------------------------
`timescale 1ns / 1ns

module blackjack_tb;

parameter ATRASO_INICIAL = 5;

reg CLK, RESET, STAY, HIT;
reg [3:0] CARD;
wire WIN, LOSE, TIE, DHIT, DSTAY;

reg [4:0] vPlayerHand, vDealerHand;
reg [3:0] i, game;

BlackJackFSM DUV (
  .clock(CLK),
  .reset(RESET),
  .stay(STAY),
  .hit(HIT),
  .card(CARD),
  .win(WIN),
  .lose(LOSE),
  .tie(TIE),
  .dhit(DHIT),
  .dstay(DSTAY) 	);

always
  #5 CLK = !CLK;

initial // time = 0 ------------------------------------------------------------
begin
  CLK = 1'b1;
  RESET = 1'b0;
  STAY = 1'b0;
  HIT = 1'b0;
  CARD = 4'b0000;
end

////////////////////////////////////////////////////////////////////////////////
// Game sequence                                                               /
////////////////////////////////////////////////////////////////////////////////
initial
begin

  // 10 games will be played ----------------------------------------------------
  for (game = 0; game < 10; game = game + 1)
  begin
    // Initial RESET -----------------------------------------------------------
    vPlayerHand = 0;
    vDealerHand = 0;
    CARD = 4'b0000;
    HIT = 1'b1;
    STAY = 1'b0;
    wait (CLK == 1'b0);                   // wait the falling edge of CLK
    #100 RESET = 1'b1;                    // time = x5
    #10 RESET = 1'b0;                     // time = x5
    #ATRASO_INICIAL;                      // time = x5

    // Initial card distribution -----------------------------------------------
    HIT = 1'b1;
    for ( i = 0 ; i < 4 ; i = i + 1 )
    begin
        #5 CARD = DATA_GAME(game, i);          // In the rising edge of CLK (time = x0)
        if (i % 2 == 0)
          vPlayerHand = vPlayerHand + CARD;
        else
          vDealerHand = vDealerHand + CARD;
        #5;                               // time = x5
    end
    HIT = 1'b0;

    // Player's turn -----------------------------------------------------------
    i = 4;
    while (DATA_GAME(game, i) != 0)       // zero denotes player stay
    begin
        #30 HIT = 1'b1;                   // time = x5
        #5  CARD = DATA_GAME(game, i);    // In the rising edge of CLK (time = x0)
        vPlayerHand = vPlayerHand + CARD;
        i = i + 1;
        #5 HIT = 1'b0;                    // time = x5
    end
    #30 STAY = 1'b1;                      // In the falling edge of CLK (time = x5)

    // Dealer's turn -----------------------------------------------------------
    i = i + 1;
	#20
    CARD = DATA_GAME(game, i);
    while (DSTAY == 1'b0)
    begin
        @(DHIT or DSTAY);
        if (DHIT == 1'b1)
        begin
            vDealerHand = vDealerHand + CARD;
            i = i + 1;
            CARD = DATA_GAME(game, i);
            #10;                              // time = x5
        end
    end

    // Decision ----------------------------------------------------------------
    #30                                 // time = x0
    if ({WIN,LOSE,TIE} == EXPECTED(game))
    begin
        case ({WIN,LOSE,TIE})
            3'b100:  $display("%d: Player wins!!! Test OK",game+1);
            3'b010:  $display("%d: Player lose!!! Test OK",game+1);
            3'b001:  $display("%d: Game drawn...  Test OK",game+1);
            default: $display("%d: Error!!!!!!!!!!!!!!!!!",game+1);
        endcase
    end
    else $display("Hard rapa is sweet but isn't soft. Fix the code.");

  end // ends a game ----------------------------------------------------------------
  # 100 $finish;
end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function [3:0] DATA_GAME;
input [3:0] ROW;
input [3:0] COL;
begin
    case (ROW)
      //  player's hand summing 21 points and dealer's hand summing below 21 points
      0:  case (COL)
            // Initial cards
            0: DATA_GAME = 1;  // Player (1)
            1: DATA_GAME = 9;  // Dealer (9)
            2: DATA_GAME = 1;  // Player (2)
            3: DATA_GAME = 9;  // Dealer (18)
            // Player's turn
            4: DATA_GAME = 1;  // Player (3)
            5: DATA_GAME = 1;  // Player (4)
            6: DATA_GAME = 2;  // Player (6)
            7: DATA_GAME = 2;  // Player (8)
            8: DATA_GAME = 2;  // Player (10)
            9: DATA_GAME = 2;  // Player (12)
            10: DATA_GAME = 3; // Player (15)
            11: DATA_GAME = 3; // Player (18)
            12: DATA_GAME = 3; // Player (21)
            13: DATA_GAME = 0; // Player stays
            // Dealer's turn
            14: DATA_GAME = 0; // Don't carry - game 0 finished (Player Wins)
            15: DATA_GAME = 0;
          endcase

      //  dealer's hand summing 21 points and player's hand summing below 21 points
      1:  case (COL)
            // Initial cards
            0: DATA_GAME = 9;   // Player (9)
            1: DATA_GAME = 1;   // Dealer (1)
            2: DATA_GAME = 9;   // Player (18)
            3: DATA_GAME = 1;   // Dealer (2)
            // Player's turn
            4: DATA_GAME = 0;   // Player stays
            // Dealer's turn
            5: DATA_GAME = 2;   // Dealer (3)
            6: DATA_GAME = 1;   // Dealer (4)
            7: DATA_GAME = 2;   // Dealer (6)
            8: DATA_GAME = 1;   // Dealer (8)
            9: DATA_GAME = 2;   // Dealer (10)
            10: DATA_GAME = 2;  // Dealer (12)
            11: DATA_GAME = 3;  // Dealer (15)
            12: DATA_GAME = 6;  // Dealer (21)
            13: DATA_GAME = 0;  // Don't carry - game 1 finished (Player Loses)
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      //  player's hand summing both below 21 points and above the dealer's hand summing
      2:  case (COL)
            // Initial cards
            0: DATA_GAME = 10; // Player (10)
            1: DATA_GAME = 3;  // Dealer (3)
            2: DATA_GAME = 10; // Player (20)
            3: DATA_GAME = 3;  // Dealer (6)
            // Player's turn
            4: DATA_GAME = 0;  // Player stays
            // Dealer's turn
            5: DATA_GAME = 2;  // Dealer (8)
            6: DATA_GAME = 4;  // Dealer (12)
            7: DATA_GAME = 3;  // Dealer (15)
            8: DATA_GAME = 1;  // Dealer (16)
            9: DATA_GAME = 1;  // Dealer (17)
            10: DATA_GAME = 0; // Don't carry - game 2 finished (Player Wins)
            11: DATA_GAME = 0;
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      //  dealer's hand summing both below 21 points and above the player's hand summing
      3:  case (COL)
            // Initial cards
            0: DATA_GAME = 3;   // Player (3)
            1: DATA_GAME = 10;  // Dealer (10)
            2: DATA_GAME = 3;   // Player (6)
            3: DATA_GAME = 4;   // Dealer (14)
            // Player's turn
            4: DATA_GAME = 2;   // Player (8)
            5: DATA_GAME = 2;   // Player (10)
            6: DATA_GAME = 4;   // Player (16)
            7: DATA_GAME = 3;   // Player (19)
            8: DATA_GAME = 0;   // Player stays
            // Dealer's turn
            9: DATA_GAME = 2;   // Dealer (16)
            10: DATA_GAME = 4;  // Dealer (20)
            11: DATA_GAME = 0;  // Don't carry - game 3 finished (Player Loses)
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      // player's hand summing until 21 points (--------- inclusive ----------) and the the dealer's hand summing above 21 points
      4:  case (COL)
            // Initial cards
            0: DATA_GAME = 10; // Player (10)
            1: DATA_GAME = 11; // Dealer (11)
            2: DATA_GAME = 11; // Player (21)
            3: DATA_GAME = 11; // Dealer (22)
            // Player's turn
            4: DATA_GAME = 0;  // Don't carry - game 4 finished (Player Wins)
            5: DATA_GAME = 0;
            6: DATA_GAME = 0;
            7: DATA_GAME = 0;
            8: DATA_GAME = 0;
            9: DATA_GAME = 0;
            10: DATA_GAME = 0;
            11: DATA_GAME = 0;
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      // player's hand summing until 21 points (inclusive) and the the dealer's hand summing above 21 points
      5:  case (COL)
            // Initial cards
            0: DATA_GAME = 5;   // Player (5)
            1: DATA_GAME = 3;   // Dealer (3)
            2: DATA_GAME = 5;   // Player (10)
            3: DATA_GAME = 4;   // Dealer (7)
            // Player's turn
            4: DATA_GAME = 2;   // Player (12)
            5: DATA_GAME = 4;   // Player (16)
            6: DATA_GAME = 1;   // Player (17)
            7: DATA_GAME = 2;   // Player (19)
            8: DATA_GAME = 0;   // Player stays
            // Dealer's turn
            9: DATA_GAME = 1;   // Dealer (8)
            10: DATA_GAME = 1;  // Dealer (9)
            11: DATA_GAME = 1;  // Dealer (10)
            12: DATA_GAME = 3;  // Dealer (13)
            13: DATA_GAME = 3;  // Dealer (16)
            14: DATA_GAME = 9;  // Dealer (25)
            15: DATA_GAME = 0;  // Don't carry - game 5 finished (Player Wins)
          endcase

      // dealer's hand summing until 21 points (--------- inclusive ----------) and the the player's hand summing above 21 points
      6:  case (COL)
            // Initial cards
            0: DATA_GAME = 11; // Player (11)
            1: DATA_GAME = 10; // Dealer (10)
            2: DATA_GAME = 11; // Player (22)
            3: DATA_GAME = 11; // Dealer (21)
            // Player's turn
            4: DATA_GAME = 0;  // Don't carry - game 6 finished (Player Loses)
            5: DATA_GAME = 0;
            6: DATA_GAME = 0;
            7: DATA_GAME = 0;
            8: DATA_GAME = 0;
            9: DATA_GAME = 0;
            10: DATA_GAME = 0;
            11: DATA_GAME = 0;
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      // dealer's hand summing until 21 points (inclusive) and the the player's hand summing above 21 points
      7:  case (COL)
            // Initial cards
            0: DATA_GAME = 5;   // Player (5)
            1: DATA_GAME = 3;   // Dealer (3)
            2: DATA_GAME = 5;   // Player (10)
            3: DATA_GAME = 4;   // Dealer (7)
            // Player's turn
            4: DATA_GAME = 7;   // Player (17)
            5: DATA_GAME = 10;  // Player (27)
            6: DATA_GAME = 0;   // Don't carry - game 7 finished (Player Loses)
            7: DATA_GAME = 0;
            8: DATA_GAME = 0;
            9: DATA_GAME = 0;
            10: DATA_GAME = 0;
            11: DATA_GAME = 0;
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      // player's hand sum equals to the dealer's hand sum, and such a sum is not above 21 points
      8:  case (COL)
            // Initial cards
            0: DATA_GAME = 11;   // Player (11)
            1: DATA_GAME = 10;   // Dealer (10)
            2: DATA_GAME = 10;   // Player (21)
            3: DATA_GAME = 11;   // Dealer (21)
            // Player's turn
            4: DATA_GAME = 0;   // Don't carry - game 8 finished (Game Drawn)
            5: DATA_GAME = 0;
            6: DATA_GAME = 0;
            7: DATA_GAME = 0;
            8: DATA_GAME = 0;
            9: DATA_GAME = 0;
            10: DATA_GAME = 0;
            11: DATA_GAME = 0;
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase

      // player's hand sum equals to the dealer's hand sum, and such a sum is not above 21 points
      9:  case (COL)
            // Initial cards
            0: DATA_GAME = 9; // Player (9)
            1: DATA_GAME = 7; // Dealer (7)
            2: DATA_GAME = 8; // Player (17)
            3: DATA_GAME = 9; // Dealer (16)
            // Player's turn
            4: DATA_GAME = 0; // Player stays
            // Dealer's turn
            5: DATA_GAME = 1; // Dealer (17)
            6: DATA_GAME = 0; // Don't carry - game 9 finished (Game Drawn)
            7: DATA_GAME = 0;
            8: DATA_GAME = 0;
            9: DATA_GAME = 0;
            10: DATA_GAME = 0;
            11: DATA_GAME = 0;
            12: DATA_GAME = 0;
            13: DATA_GAME = 0;
            14: DATA_GAME = 0;
            15: DATA_GAME = 0;
          endcase
    endcase
end
endfunction

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function [2:0] EXPECTED;
input [3:0] game;
begin
    case (game)////////WLT
      0: EXPECTED = 3'b100; // Player Wins
      1: EXPECTED = 3'b010; // Player Loses
      2: EXPECTED = 3'b100; // Player Wins
      3: EXPECTED = 3'b010; // Player Loses
      4: EXPECTED = 3'b100; // Player Wins
      5: EXPECTED = 3'b100; // Player Wins
      6: EXPECTED = 3'b010; // Player Loses
      7: EXPECTED = 3'b010; // Player Loses
      8: EXPECTED = 3'b001; // Game Drawn
      9: EXPECTED = 3'b001; // Game Drawn
      default: EXPECTED = 3'b001; // Game Drawn
    endcase
end
endfunction

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

initial
begin
  vPlayerHand = 0;
  vDealerHand = 0;
  //$display("\tTIME\tCLK\tRESET\tCARD\tP_SUM\tD_SUM\tHIT\tDHIT\tPHIT\tWIN\tLOSE\tTIE");
  //$monitor("%d\t%b\t%b\t%d\t%d\t%d\t%b\t%b\t%b\t%b\t%b\t%b",$time,CLK,RESET,CARD,vPlayerHand,vDealerHand,HIT,DHIT,DSTAY,WIN,LOSE,TIE);
end

endmodule
