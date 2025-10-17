`timescale 1ns / 1ps

module chip8_cpu_keypad_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] mem_data_out;
    reg [15:0] key_pressed;
    reg collision;

    // Outputs
    wire mem_read;
    wire [11:0] mem_addr_out;
    wire [7:0] mem_data_in;
    wire mem_write;
    wire draw;
    wire [5:0] x;
    wire [4:0] y;
    wire [7:0] sprite_data;
    wire [3:0] draw_row_index;

    // Instantiate the CPU
    chip8_cpu uut (
        .clk(clk),
        .reset(reset),
        .mem_data_out(mem_data_out),
        .key_pressed(key_pressed),
        .collision(collision),
        .mem_read(mem_read),
        .mem_addr_out(mem_addr_out),
        .mem_data_in(mem_data_in),
        .mem_write(mem_write),
        .draw(draw),
        .x(x),
        .y(y),
        .sprite_data(sprite_data),
        .draw_row_index(draw_row_index)
    );

    // Simple memory model
    reg [7:0] memory [0:4095];

    // Clock generation (50MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Memory read logic
    always @(posedge clk) begin
        if (mem_read) begin
            mem_data_out <= memory[mem_addr_out];
        end
    end

    // Memory write logic
    always @(posedge clk) begin
        if (mem_write) begin
            memory[mem_addr_out] <= mem_data_in;
        end
    end

    // Test program
    initial begin
        $display("=== Starting CPU Keypad Opcode Tests ===\n");
        
        // Initialize
        reset = 1;
        key_pressed = 16'h0000;
        collision = 0;
        mem_data_out = 8'h00;
        
        // Clear memory
        integer i;
        for (i = 0; i < 4096; i = i + 1) begin
            memory[i] = 8'h00;
        end
        
        // Load test program at 0x200
        // Test 1: EX9E - Skip if key pressed
        memory[12'h200] = 8'hE0;  // E09E - Skip if key 0 pressed
        memory[12'h201] = 8'h9E;
        memory[12'h202] = 8'h60;  // 6001 - Set V0 = 1 (should be skipped)
        memory[12'h203] = 8'h01;
        memory[12'h204] = 8'h61;  // 6102 - Set V1 = 2
        memory[12'h205] = 8'h02;
        
        // Test 2: EXA1 - Skip if key NOT pressed
        memory[12'h206] = 8'hE1;  // E1A1 - Skip if key 1 NOT pressed
        memory[12'h207] = 8'hA1;
        memory[12'h208] = 8'h62;  // 6203 - Set V2 = 3 (should be skipped)
        memory[12'h209] = 8'h03;
        memory[12'h20A] = 8'h63;  // 6304 - Set V3 = 4
        memory[12'h20B] = 8'h04;
        
        // Test 3: FX0A - Wait for key press
        memory[12'h20C] = 8'hF4;  // F40A - Wait for key, store in V4
        memory[12'h20D] = 8'h0A;
        memory[12'h20E] = 8'h65;  // 6505 - Set V5 = 5 (executes after key press)
        memory[12'h20F] = 8'h05;
        
        // Test 4: FX29 - Set I to sprite location
        memory[12'h210] = 8'h66;  // 6605 - Set V6 = 5
        memory[12'h211] = 8'h05;
        memory[12'h212] = 8'hF6;  // F629 - Set I to sprite for digit 5
        memory[12'h213] = 8'h29;
        
        // Test 5: FX33 - BCD conversion
        memory[12'h214] = 8'h67;  // 67FF - Set V7 = 255
        memory[12'h215] = 8'hFF;
        memory[12'h216] = 8'hA3;  // A300 - Set I = 0x300
        memory[12'h217] = 8'h00;
        memory[12'h218] = 8'hF7;  // F733 - Store BCD of V7 at I
        memory[12'h219] = 8'h33;
        
        // Release reset
        #100;
        reset = 0;
        $display("Reset released, PC = 0x200\n");
        
        // Test 1: EX9E - Skip if key pressed
        $display("=== Test 1: EX9E (Skip if key pressed) ===");
        key_pressed[0] = 1'b1;  // Press key 0
        #2000;
        $display("Key 0 pressed, should skip next instruction");
        $display("V0 should be 0 (instruction skipped): V0 = %d", uut.V[0]);
        $display("V1 should be 2: V1 = %d", uut.V[1]);
        if (uut.V[0] == 0 && uut.V[1] == 2)
            $display("PASS: EX9E working correctly\n");
        else
            $display("FAIL: EX9E not working\n");
        
        key_pressed[0] = 1'b0;  // Release key
        
        // Test 2: EXA1 - Skip if key NOT pressed
        $display("=== Test 2: EXA1 (Skip if key NOT pressed) ===");
        #2000;
        $display("Key 1 NOT pressed, should skip next instruction");
        $display("V2 should be 0 (instruction skipped): V2 = %d", uut.V[2]);
        $display("V3 should be 4: V3 = %d", uut.V[3]);
        if (uut.V[2] == 0 && uut.V[3] == 4)
            $display("PASS: EXA1 working correctly\n");
        else
            $display("FAIL: EXA1 not working\n");
        
        // Test 3: FX0A - Wait for key press
        $display("=== Test 3: FX0A (Wait for key press) ===");
        $display("CPU should wait for key press...");
        #2000;
        $display("V5 should still be 0: V5 = %d", uut.V[5]);
        
        #5000;
        $display("Pressing key 7...");
        key_pressed[7] = 1'b1;  // Press key 7
        
        #2000;
        $display("V4 should be 7 (key pressed): V4 = %d", uut.V[4]);
        $display("V5 should be 5 (next instruction executed): V5 = %d", uut.V[5]);
        if (uut.V[4] == 7 && uut.V[5] == 5)
            $display("PASS: FX0A working correctly\n");
        else
            $display("FAIL: FX0A not working\n");
        
        key_pressed[7] = 1'b0;  // Release key
        
        // Test 4: FX29 - Set I to sprite location
        $display("=== Test 4: FX29 (Set I to sprite location) ===");
        #2000;
        $display("V6 = %d", uut.V[6]);
        $display("I should be %d (5 * 5): I = %d", 5*5, uut.I);
        if (uut.I == 25)
            $display("PASS: FX29 working correctly\n");
        else
            $display("FAIL: FX29 not working\n");
        
        // Test 5: FX33 - BCD conversion
        $display("=== Test 5: FX33 (BCD conversion) ===");
        #3000;
        $display("V7 = %d", uut.V[7]);
        $display("I = 0x%h", uut.I);
        $display("Memory[I] (hundreds) = %d", memory[12'h300]);
        $display("Memory[I+1] (tens) = %d", memory[12'h301]);
        $display("Memory[I+2] (ones) = %d", memory[12'h302]);
        if (memory[12'h300] == 2 && memory[12'h301] == 5 && memory[12'h302] == 5)
            $display("PASS: FX33 working correctly (255 = 2,5,5)\n");
        else
            $display("FAIL: FX33 not working\n");
        
        $display("\n=== All Keypad Opcode Tests Complete ===");
        #1000;
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("chip8_cpu_keypad_tb.vcd");
        $dumpvars(0, chip8_cpu_keypad_tb);
    end

endmodule