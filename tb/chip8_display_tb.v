`timescale 1ns/1ps

module tb_chip8_display;
    reg clk = 0, reset = 0, draw = 0;
    reg [5:0] x = 10;
    reg [4:0] y = 4;
    reg [3:0] row_index = 0;
    reg [7:0] sprite_data = 8'b11110000;
    reg [7:0] display_in = 8'b00001111;
    wire [7:0] display_out;
    wire [7:0] addr;
    wire collision, done;

    chip8_display uut (
        .clk(clk), .reset(reset), .draw(draw),
        .x(x), .y(y), .row_index(row_index),
        .sprite_data(sprite_data),
        .display_in(display_in),
        .display_out(display_out),
        .addr(addr),
        .collision(collision),
        .done(done)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("chip8_display_tb.vcd");
        $dumpvars(0, tb_chip8_display);

        clk = 0;
        reset = 1;
        draw = 0;

        // Initialize display memory to zero to remove 'x' states
        
        for (i = 0; i < 64; i = i + 1) begin
            x = i % 64; // Here we simulate zeroing display by setting display_in = 0 and x,y accordingly
            y = 0;
            display_in = 8'b00000000;
            row_index = 0;
            #10;
        end

        #20;
        reset = 0;

        // initialize sprite and coords
        x = 6'd10;
        y = 5'd4;
        row_index = 4'd0;
        sprite_data = 8'b11110000;
        display_in = 8'b00001111;

        #20 draw = 1;
        #10 draw = 0;

        // run long enough to complete, withing 8000 constraint
        #8000 $finish;
    end
endmodule
