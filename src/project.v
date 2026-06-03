`default_nettype none

module tt_um_factory_test (
    input  wire [7:0] ui_in,    // [3:0]=Static,=Manual Sub-mode,=Btn Step,=Inverted Toggle
    output reg  [7:0] uo_out,   // Dedicated outputs 
    input  wire [7:0] uio_in,   // IOs: Input path (unused)
    output wire [7:0] uio_out,  // IOs: Output path (disabled)
    output wire [7:0] uio_oe,   // IOs: Enable path (configured as inputs)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock (100 Hz from demoboard)
    input  wire       rst_n     // reset_n - low to reset
);

  // Define the input clock frequency (100 Hz)
  localparam CLOCK_FREQ = 7'd100; 

  // 7-bit divider to count 100 clock cycles (1 second interval)
  reg [6:0] clk_div;
  wire clk_en_1hz;

  // Track operational indices
  reg [3:0] auto_index;
  reg [3:0] manual_index;     // Tracks manual up-counting button steps
  
  // Clean, registered variants of your physical control switches
  reg [3:0] registered_switches;
  reg       registered_toggle7;
  reg       registered_toggle4;
  
  // Heavy Debouncer Registers for Pin 6 (Requires 50ms sustained stability)
  reg [2:0] debounce_count;    
  reg       debounced_btn;     
  reg       btn_prev;          

  // Holds the muxed result index chosen for presentation
  reg [3:0] selected_index;

  // Holds the character look-up value
  reg [7:0] current_char;

  // 1. Synchronize physical static switches to the system clock
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      registered_switches <= 4'd0;
      registered_toggle7  <= 1'b0; // Default to Auto Mode (0) on reset
      registered_toggle4  <= 1'b0;
    end else begin
      registered_switches <= ui_in[3:0]; 
      registered_toggle7  <= ui_in[7];   
      registered_toggle4  <= ui_in[4];   
    end
  end

  // 2. Heavy Button Debouncer Logic for Pin 5
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      debounce_count <= 3'd0;
      debounced_btn  <= 1'b0;
      btn_prev       <= 1'b0;
    end else begin
      btn_prev <= debounced_btn; 
      
      if (ui_in[5] == debounced_btn) begin
        debounce_count <= 3'd0;  
      end else begin
        debounce_count <= debounce_count + 1'b1; 
        
        if (debounce_count >= 3'd4) begin
          debounced_btn  <= ui_in[5];
          debounce_count <= 3'd0;
        end
      end
    end
  end

  // 3. Clock Divider Logic (Runs in background for 1Hz auto-mode)
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      clk_div <= 7'd0;
    end else begin
      if (clk_div >= (CLOCK_FREQ - 1'b1)) begin
        clk_div <= 7'd0; 
      end else begin
        clk_div <= clk_div + 1'b1;
      end
    end
  end

  assign clk_en_1hz = (clk_div == (CLOCK_FREQ - 1'b1));

  // 4. Auto-Mode Index Counter (Changes every 1 second)
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      auto_index <= 4'd0;
    end else if (clk_en_1hz) begin
      auto_index <= auto_index + 1'b1; 
    end
  end

  // 5. Manual Button Up-Counting Index
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      manual_index <= 4'd0;
    end else if (debounced_btn && !btn_prev) begin
      manual_index <= manual_index + 1'b1; 
    end
  end

  // 6. Master Mode Multiplexer (Inverted Switch 7 Logic)
  always @(*) begin
    if (!registered_toggle7) begin
      selected_index = auto_index;           // Switch 7 LOW: Auto Mode (1 Hz)
    end else if (registered_toggle4) begin
      selected_index = manual_index;          // Switch 7 HIGH + Switch 4 HIGH: Button Step Mode
    end else begin
      selected_index = registered_switches;  // Switch 7 HIGH + Switch 4 LOW: Static Switches [3:0]
    end
  end

  // 7. Combinational ROM Lookup
  always @(*) begin
    case (selected_index)
      4'd0:  current_char = 8'b01110011; // P
      4'd1:  current_char = 8'b00000110; // I
      4'd2:  current_char = 8'b00111000; // L
      4'd3:  current_char = 8'b00000110; // I
      4'd4:  current_char = 8'b01110011; // P
      4'd5:  current_char = 8'b00000110; // I
      4'd6:  current_char = 8'b00110111; // N
      4'd7:  current_char = 8'b01110111; // A
      4'd8:  current_char = 8'b01101101; // S
      4'd9:  current_char = 8'b00111000; // L
      4'd10: current_char = 8'b01110111; // A
      4'd11: current_char = 8'b01101101; // S
      4'd12: current_char = 8'b01110111; // A
      4'd13: current_char = 8'b00111000; // L
      4'd14: current_char = 8'b00111000; // L
      4'd15: current_char = 8'b01111001; // E
      default: current_char = 8'h00;
    endcase
  end

  // 8. Output Buffer Registration
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      uo_out <= 8'h00;
    end else begin
      uo_out <= current_char; 
    end
  end

  // Disabling bidirectional IOs safely 
  assign uio_out = 8'h00; 
  assign uio_oe  = 8'h00; 

  // Clean tracking array block: Pin 6 is the single completely unused input pin
  wire [9:0] _unused_pins = {ena, ui_in[6], uio_in};

endmodule  // tt_um_factory_test
