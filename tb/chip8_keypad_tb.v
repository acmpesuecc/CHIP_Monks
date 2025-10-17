`timescale 1ns / 1ps

module chip8_keypad_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [3:0] col;

    // Outputs
    wire [3:0] row;
    wire [15:0] key_pressed;

    // Instantiate the keypad module
    chip8_keypad uut (
        .clk(clk),
        .reset(reset),
        .row(row),
        .col(col),
        .key_pressed(key_pressed)
    );

    // Clock generation (50MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 20ns period = 50MHz
    end

    // Test stimulus
    initial begin
        // Initialize
        $display("Starting Keypad Test");
        reset = 1;
        col = 4'b1111;  // No keys pressed (pull-up state)
        
        // Release reset
        #100;
        reset = 0;
        
        // Test 1: Press key '5' (Row 1, Col 1)
        $display("\n=== Test 1: Pressing Key 5 ===");
        #200;
        wait(row == 4'b1101);  // Wait for row 1 scan
        #20;
        col = 4'b1110;  // Col 0 pressed
        #200000;  // Wait for debounce
        $display("Key pressed register: %b", key_pressed);
        if (key_pressed[5]) 
            $display("PASS: Key 5 detected");
        else 
            $display("FAIL: Key 5 not detected");
        
        // Release key
        col = 4'b1111;
        #100000;
        
        // Test 2: Press key 'A' (Row 2, Col 0)
        $display("\n=== Test 2: Pressing Key A ===");
        wait(row == 4'b1011);  // Wait for row 2 scan
        #20;
        col = 4'b1110;  // Col 0 pressed
        #200000;
        $display("Key pressed register: %b", key_pressed);
        if (key_pressed[12]) 
            $display("PASS: Key A detected");
        else 
            $display("FAIL: Key A not detected");
        
        // Release key
        col = 4'b1111;
        #100000;
        
        // Test 3: Press key '0' (Row 3, Col 1)
        $display("\n=== Test 3: Pressing Key 0 ===");
        wait(row == 4'b0111);  // Wait for row 3 scan
        #20;
        col = 4'b1101;  // Col 1 pressed
        #200000;
        $display("Key pressed register: %b", key_pressed);
        if (key_pressed[13]) 
            $display("PASS: Key 0 detected");
        else 
            $display("FAIL: Key 0 not detected");
        
        // Release key
        col = 4'b1111;
        #100000;
        
        // Test 4: Multiple keys pressed
        $display("\n=== Test 4: Multiple Keys Pressed ===");
        wait(row == 4'b1110);  // Row 0
        #20;
        col = 4'b1100;  // Col 0 and 1 pressed
        #200000;
        $display("Key pressed register: %b", key_pressed);
        if (key_pressed[0] && key_pressed[1]) 
            $display("PASS: Multiple keys detected");
        else 
            $display("FAIL: Multiple keys not properly detected");
        
        col = 4'b1111;
        #100000;
        
        $display("\n=== Keypad Test Complete ===");
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | Row=%b | Col=%b | Keys=%h", 
                 $time, row, col, key_pressed);
    end

endmodule