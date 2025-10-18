`timescale 1ns / 1ps

module chip8_cpu_tb();
    reg clk;
    reg reset;
    reg [7:0] mem_data_in;
    reg [15:0] key_pressed;

    wire mem_read;
    wire [11:0] mem_addr_out;
    wire [7:0] mem_data_out;
    wire mem_write;
    wire collision;
    wire draw;
    wire [5:0] x;
    wire [4:0] y;
    wire [7:0] sprite_data;
    wire [3:0] draw_row_index;

    wire [3:0] flag = 4'd0;

    reg [7:0] memory[0:4095];

    chip8_cpu DUT (
        .clk(clk),
        .reset(reset),
        .mem_data_out(mem_data_in),
        .key_pressed(key_pressed),
        .collision(collision),
        .mem_read(mem_read),
        .mem_addr_out(mem_addr_out),
        .mem_data_in(mem_data_out),
        .mem_write(mem_write),
        .draw(draw),
        .x(x),
        .y(y),
        .sprite_data(sprite_data),
        .draw_row_index(draw_row_index)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        key_pressed = 16'd0;
        reset = 1;
        #10;
        reset = 0;

        $readmemh("program_tb.mem", memory);
        $monitor("Time=%0t | clk=%b | reset=%b | mem_read=%b | mem_write=%b | mem_addr_out=%h | mem_data_in=%h | mem_data_out=%h | draw=%b | x=%d y=%d sprite=%h row_index=%d | collision=%b | PC=%h | Opcode=%h",
                 $time,
                 clk,
                 reset,
                 mem_read,
                 mem_write,
                 mem_addr_out,
                 mem_data_in,
                 mem_data_out,
                 draw,
                 x,
                 y,
                 sprite_data,
                 draw_row_index,
                 collision,
                 DUT.pc,
                 DUT.opcode
        );

        #8000;
        $finish;
    end

    always @(posedge clk) begin
        if (mem_read)
            mem_data_in <= memory[mem_addr_out];

        if (mem_write)
            memory[mem_addr_out] <= mem_data_out;
    end
endmodule
