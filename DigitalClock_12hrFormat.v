`timescale 1ns / 1ps

module DigitalClock_12HrFormat(
    input clk,  
    input center, 
    input right, 
    input left,  
    input up,  
    input down,  
    output [6:0] seg,  // 7 segments of the display
    output [3:0] an,  // to enable 4 seven segment displays
    output AMPM_indicator_led,  
    output clock_mode_indicator_led  // indicates clock in clock mode when light is on
);


reg [31:0] counter = 0; 
parameter max_count = 100_000_000; 

// setting up ports for hours and minutes, clock display
reg [5:0] hrs, min, sec = 0; // hrs = 1 - 12, min = 0 - 59, sec = 0 - 59
reg [3:0] min_ones, min_tens, hrs_ones, hrs_tens = 0; // initially all bits set to 0
reg toggle = 0; // toggle between minutes and hours to change, 0 - minutes, 1 - hours

// assigning initial value to indicator leds (AM-PM/Clock mode)
reg pm = 0; // initially PM is set to zero
assign AMPM_indicator_led = pm;

reg clock_mode = 0;
assign clock_mode_indicator_led = clock_mode; // initially led is set to 0, means clock is not in clock mode

// Instantiation of the Seven Segment Module
Seven_Segment_Module SSM(clk, min_ones, min_tens, hrs_ones, hrs_tens , seg, an);

// ports for setting-up time (sec, min, hrs) on clock. By default clock is not working in clock mode,  
// and therefore using pushbuttons, time can be adjusted. When center button is pressed, then...  
// clock enters clock mode

parameter display_time = 1'b0;
parameter set_time = 1'b1;
reg current_mode = set_time;

// Setting-up 1 second increment for clock and adjusting the new set time
always @(posedge clk) begin
    case(current_mode)
        display_time: begin // Clock mode - 1:00AM to 11:59PM
            if (center) begin // If center button goes high, new time is adjusted, all counters are reset
                clock_mode <= 0;
                current_mode <= set_time;
                // Reset variables to prepare for set time mode
                counter <= 0;
                toggle <= 0;
                sec <= 0;
            end

            if (counter < max_count) begin // time
                counter <= counter + 1;
            end else begin
                counter <= 0;
                sec <= sec + 1;
            end
        end

        // setting-up hours and minutes to set a new time (Up and Down Buttons)
   set_time: begin
    if (center) begin // Push center button to commit time set and return to Clock mode
        clock_mode <= 1;
        current_mode <= display_time;
    end

    if (counter < (25_000_000)) begin // setting-up clock speed to 4Hz for pushbuttons
        counter <= counter + 1;
    end else begin
        counter <= 0;
        case (toggle)
            1'b0: begin // Minutes change
                if (up) begin // Inc minutes when you push BTN_up
                    min <= min + 1;
                end
                if (down) begin // Dec minutes when you push BTN_down
                    if (min > 0) begin
                        min <= min - 1;
                    end else if (hrs > 1) begin
                        hrs <= hrs - 1;
                        min <= 59;
                    end else if (hrs == 1) begin
                        hrs <= 12;
                        min <= 59;
                    end
                end
   // Toggle between hours and minutes to set a new time (Right and Left Buttons)
               if (left || right) begin // Push left/right button to swap between hours/minutes
                    toggle <= 1;
               end
            end//end1'b0
        
            1'b1: begin // Hours change
                if (up) begin // Inc hours when you push BTN_up
                    hrs <= hrs + 1;
                end
                if (down) begin // Dec minutes when you push BTN_down
                    if (hrs > 1) begin
                        hrs <= hrs - 1;
                    end else if (hrs == 1) begin
                        hrs <= 12;
                        // AM_PM <= ~AM_PM;
                    end
                end
                if (right || left) begin // Push left/right buttons to swap between hours/minutes
                    toggle <= 0;
                end
             end   
        endcase
        end
     end   //end set clock
   endcase //end case(current_mode)
   
// Digital Clock 12Hr format
if (sec >= 60) begin // After 60 seconds, increment minutes
    sec <= 0;
    min <= min + 1;
end
if (min >= 60) begin // After 60 minutes, increment hours
    min <= 0;
    hrs <= hrs + 1;
end
if (hrs >= 24) begin // After 24 hours, swap between AM and PM
    hrs <= 0;
end

// AM/PM Time
else begin
    min_ones <= min % 10; // 1's of minutes
    min_tens <= min / 10; // 10's of minutes
    if (hrs < 12) begin
        if (hrs == 0) begin // 12:00 AM
            hrs_ones <= 2;
            hrs_tens <= 1;
        end else begin
            hrs_ones<=hrs%10;//1's of hours
            hrs_tens<=hrs/10;
        end
        pm<=0;
    end else begin//end hours begin
        if(hrs==12) begin//12:00 begin
            hrs_ones<=2;
            hrs_tens<=1;
        end else begin //end begin
            hrs_ones<=(hrs-12)%10; //1's of hours
            hrs_tens<=(hrs-12)/10; //10's of hours
        end
        pm<=1;
     end                       
   end
 end   
 
 endmodule
