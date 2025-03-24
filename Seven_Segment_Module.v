`timescale 1ns / 1ps


module Seven_Segment_Module( //declaring inputs and outputs
    input clk, //100MHz bassy board
    input [3:0] min_ones,//0-9 ,9---1001
    input [3:0] min_tens,
    input [3:0] hrs_ones,
    input [3:0] hrs_tens,
    output reg [6:0] seg,
    output reg [3:0] an
);

//port identification - declaring wires and registers
reg [1:0] digit_display = 0; //used to detect where is my led now in from 4 leds for 4 leds 2bit required
reg [6:0] display [3:0];

reg [18:0] counter = 0;
parameter max_count = 500_000; //100MHz/100 Hz = 1M divided by 2 equals 500,000
wire [3:0] four_bit [3:0];//carry the values of minutes tens ones hours

//Assigning values that need to be reflected on the 7-segment display
assign four_bit[0] = min_ones;
assign four_bit[1] = min_tens;
assign four_bit[2] = hrs_ones;
assign four_bit[3] = hrs_tens;

// 100 Hz slow clock for enabling each segment at refresh rate of 10 ms
always @(posedge clk) begin      //clk display counter
    if (counter < max_count) begin
        counter = counter+1;
    end else begin
        digit_display <= digit_display + 1;
        counter <= 0;
    end
  
  //BCD to seven segment display, check for values for minutes and hours
case(four_bit[digit_display])
    4'b0000: display[digit_display] <= 7'b1000000; //0
    4'b0001: display[digit_display] <= 7'b1111001; //1
    4'b0010: display[digit_display] <= 7'b0100100; //2
    4'b0011: display[digit_display] <= 7'b0110000; //3
    4'b0100: display[digit_display] <= 7'b0011001; //4
    4'b0101: display[digit_display] <= 7'b0010010; //5
    4'b0110: display[digit_display] <= 7'b0000010; //6
    4'b0111: display[digit_display] <= 7'b1111000; //7
    4'b1000: display[digit_display] <= 7'b0000000; //8
    4'b1001: display[digit_display] <= 7'b0010000; //9
    4'b1010: display[digit_display] <= 7'b0001000; //A
    4'b1011: display[digit_display] <= 7'b0000011; //b
    4'b1100: display[digit_display] <= 7'b1000110; //C
    4'b1101: display[digit_display] <= 7'b0100001; //d
    4'b1110: display[digit_display] <= 7'b0000110; //E
    default: display[digit_display] <= 7'b0001110; //Otherwise, F
endcase

//enabling each segment and displaying the digit
case(digit_display) //cycles through display
    0: begin
        an <= 4'b1110;
        seg <= display[0];
    end
    
    1: begin
        an <= 4'b1101;
        seg <= display[1];
    end
    
    2: begin
        an <= 4'b1011;
        seg <= display[2];
    end
    
    3: begin
        an <= 4'b0111;
        seg <= display[3];
    end
endcase

end //slow clock end
endmodule
  

