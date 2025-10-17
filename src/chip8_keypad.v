module chip8_keypad (
    input wire clk,
    input wire reset,
    output reg [3:0] row,           // Row outputs to keypad
    input wire [3:0] col,           // Column inputs from keypad
    output reg [15:0] key_pressed   // 16-bit key state (1 = pressed)
);

    // State machine for scanning rows
    reg [1:0] scan_state;
    reg [15:0] key_debounce_0, key_debounce_1, key_debounce_2, key_debounce_3;
    reg [15:0] key_debounce_4, key_debounce_5, key_debounce_6, key_debounce_7;
    reg [15:0] key_debounce_8, key_debounce_9, key_debounce_10, key_debounce_11;
    reg [15:0] key_debounce_12, key_debounce_13, key_debounce_14, key_debounce_15;
    reg [15:0] key_state;           // Raw key state
    
    // Debounce threshold (adjust based on clock frequency)
    parameter DEBOUNCE_LIMIT = 16'hFFFF;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scan_state <= 2'b00;
            row <= 4'b1110;  // Start by scanning row 0
            key_pressed <= 16'h0000;
            key_state <= 16'h0000;
            key_debounce_0 <= 16'h0000;
            key_debounce_1 <= 16'h0000;
            key_debounce_2 <= 16'h0000;
            key_debounce_3 <= 16'h0000;
            key_debounce_4 <= 16'h0000;
            key_debounce_5 <= 16'h0000;
            key_debounce_6 <= 16'h0000;
            key_debounce_7 <= 16'h0000;
            key_debounce_8 <= 16'h0000;
            key_debounce_9 <= 16'h0000;
            key_debounce_10 <= 16'h0000;
            key_debounce_11 <= 16'h0000;
            key_debounce_12 <= 16'h0000;
            key_debounce_13 <= 16'h0000;
            key_debounce_14 <= 16'h0000;
            key_debounce_15 <= 16'h0000;
        end else begin
            // Scan rows one at a time
            case (scan_state)
                2'b00: begin  // Scan Row 0 (Keys 0,1,2,3)
                    row <= 4'b1110;
                    // Check columns
                    key_state[0] <= ~col[0];  // Key 1
                    key_state[1] <= ~col[1];  // Key 2
                    key_state[2] <= ~col[2];  // Key 3
                    key_state[3] <= ~col[3];  // Key C
                    scan_state <= 2'b01;
                end
                
                2'b01: begin  // Scan Row 1 (Keys 4,5,6,7)
                    row <= 4'b1101;
                    key_state[4] <= ~col[0];  // Key 4
                    key_state[5] <= ~col[1];  // Key 5
                    key_state[6] <= ~col[2];  // Key 6
                    key_state[7] <= ~col[3];  // Key D
                    scan_state <= 2'b10;
                end
                
                2'b10: begin  // Scan Row 2 (Keys 8,9,A,B)
                    row <= 4'b1011;
                    key_state[8] <= ~col[0];  // Key 7
                    key_state[9] <= ~col[1];  // Key 8
                    key_state[10] <= ~col[2]; // Key 9
                    key_state[11] <= ~col[3]; // Key E
                    scan_state <= 2'b11;
                end
                
                2'b11: begin  // Scan Row 3 (Keys C,D,E,F)
                    row <= 4'b0111;
                    key_state[12] <= ~col[0]; // Key A
                    key_state[13] <= ~col[1]; // Key 0
                    key_state[14] <= ~col[2]; // Key B
                    key_state[15] <= ~col[3]; // Key F
                    scan_state <= 2'b00;
                end
            endcase
            
            // Debounce logic for key 0
            if (key_state[0]) begin
                if (key_debounce_0 < DEBOUNCE_LIMIT) key_debounce_0 <= key_debounce_0 + 1;
                else key_pressed[0] <= 1'b1;
            end else begin
                key_debounce_0 <= 16'h0000;
                key_pressed[0] <= 1'b0;
            end
            
            // Debounce logic for key 1
            if (key_state[1]) begin
                if (key_debounce_1 < DEBOUNCE_LIMIT) key_debounce_1 <= key_debounce_1 + 1;
                else key_pressed[1] <= 1'b1;
            end else begin
                key_debounce_1 <= 16'h0000;
                key_pressed[1] <= 1'b0;
            end
            
            // Debounce logic for key 2
            if (key_state[2]) begin
                if (key_debounce_2 < DEBOUNCE_LIMIT) key_debounce_2 <= key_debounce_2 + 1;
                else key_pressed[2] <= 1'b1;
            end else begin
                key_debounce_2 <= 16'h0000;
                key_pressed[2] <= 1'b0;
            end
            
            // Debounce logic for key 3
            if (key_state[3]) begin
                if (key_debounce_3 < DEBOUNCE_LIMIT) key_debounce_3 <= key_debounce_3 + 1;
                else key_pressed[3] <= 1'b1;
            end else begin
                key_debounce_3 <= 16'h0000;
                key_pressed[3] <= 1'b0;
            end
            
            // Debounce logic for key 4
            if (key_state[4]) begin
                if (key_debounce_4 < DEBOUNCE_LIMIT) key_debounce_4 <= key_debounce_4 + 1;
                else key_pressed[4] <= 1'b1;
            end else begin
                key_debounce_4 <= 16'h0000;
                key_pressed[4] <= 1'b0;
            end
            
            // Debounce logic for key 5
            if (key_state[5]) begin
                if (key_debounce_5 < DEBOUNCE_LIMIT) key_debounce_5 <= key_debounce_5 + 1;
                else key_pressed[5] <= 1'b1;
            end else begin
                key_debounce_5 <= 16'h0000;
                key_pressed[5] <= 1'b0;
            end
            
            // Debounce logic for key 6
            if (key_state[6]) begin
                if (key_debounce_6 < DEBOUNCE_LIMIT) key_debounce_6 <= key_debounce_6 + 1;
                else key_pressed[6] <= 1'b1;
            end else begin
                key_debounce_6 <= 16'h0000;
                key_pressed[6] <= 1'b0;
            end
            
            // Debounce logic for key 7
            if (key_state[7]) begin
                if (key_debounce_7 < DEBOUNCE_LIMIT) key_debounce_7 <= key_debounce_7 + 1;
                else key_pressed[7] <= 1'b1;
            end else begin
                key_debounce_7 <= 16'h0000;
                key_pressed[7] <= 1'b0;
            end
            
            // Debounce logic for key 8
            if (key_state[8]) begin
                if (key_debounce_8 < DEBOUNCE_LIMIT) key_debounce_8 <= key_debounce_8 + 1;
                else key_pressed[8] <= 1'b1;
            end else begin
                key_debounce_8 <= 16'h0000;
                key_pressed[8] <= 1'b0;
            end
            
            // Debounce logic for key 9
            if (key_state[9]) begin
                if (key_debounce_9 < DEBOUNCE_LIMIT) key_debounce_9 <= key_debounce_9 + 1;
                else key_pressed[9] <= 1'b1;
            end else begin
                key_debounce_9 <= 16'h0000;
                key_pressed[9] <= 1'b0;
            end
            
            // Debounce logic for key 10
            if (key_state[10]) begin
                if (key_debounce_10 < DEBOUNCE_LIMIT) key_debounce_10 <= key_debounce_10 + 1;
                else key_pressed[10] <= 1'b1;
            end else begin
                key_debounce_10 <= 16'h0000;
                key_pressed[10] <= 1'b0;
            end
            
            // Debounce logic for key 11
            if (key_state[11]) begin
                if (key_debounce_11 < DEBOUNCE_LIMIT) key_debounce_11 <= key_debounce_11 + 1;
                else key_pressed[11] <= 1'b1;
            end else begin
                key_debounce_11 <= 16'h0000;
                key_pressed[11] <= 1'b0;
            end
            
            // Debounce logic for key 12
            if (key_state[12]) begin
                if (key_debounce_12 < DEBOUNCE_LIMIT) key_debounce_12 <= key_debounce_12 + 1;
                else key_pressed[12] <= 1'b1;
            end else begin
                key_debounce_12 <= 16'h0000;
                key_pressed[12] <= 1'b0;
            end
            
            // Debounce logic for key 13
            if (key_state[13]) begin
                if (key_debounce_13 < DEBOUNCE_LIMIT) key_debounce_13 <= key_debounce_13 + 1;
                else key_pressed[13] <= 1'b1;
            end else begin
                key_debounce_13 <= 16'h0000;
                key_pressed[13] <= 1'b0;
            end
            
            // Debounce logic for key 14
            if (key_state[14]) begin
                if (key_debounce_14 < DEBOUNCE_LIMIT) key_debounce_14 <= key_debounce_14 + 1;
                else key_pressed[14] <= 1'b1;
            end else begin
                key_debounce_14 <= 16'h0000;
                key_pressed[14] <= 1'b0;
            end
            
            // Debounce logic for key 15
            if (key_state[15]) begin
                if (key_debounce_15 < DEBOUNCE_LIMIT) key_debounce_15 <= key_debounce_15 + 1;
                else key_pressed[15] <= 1'b1;
            end else begin
                key_debounce_15 <= 16'h0000;
                key_pressed[15] <= 1'b0;
            end
        end
    end

endmodule