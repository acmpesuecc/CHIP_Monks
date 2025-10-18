`timescale 1ns / 1ps

module chip8_display (
    input wire clk,
    input wire reset,
    input wire draw,
    input wire [5:0] x,
    input wire [4:0] y,
    input wire [3:0] row_index,
    input wire [7:0] sprite_data,
    input wire [7:0] display_in,
    output reg [7:0] display_out,
    output reg [7:0] addr, 
    output reg collision,
    output reg done
);

    reg [7:0] display_mem [0:255]; // Internal 256-byte memory, changed from 2048 due to memory restriction
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            display_mem[i] = 8'b0;
    end

    // Mealy Model
    localparam IDLE   = 3'b000;
    localparam LOAD   = 3'b001;
    localparam UPDATE = 3'b010;
    localparam STORE  = 3'b011;
    localparam NEXT   = 3'b100;
    localparam FINISH = 3'b101;

    reg [2:0] state;
    reg [7:0] byte_index;
    reg [3:0] row_counter;
    reg [7:0] curr_byte;
    reg [7:0] new_byte;
    integer bit_offset;
    reg draw_latched;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            byte_index <= 0;
            row_counter <= 0;
            collision <= 0;
            done <= 0;
            addr <= 0;
            display_out <= 0;
            draw_latched <= 0;
        end else begin
            if (draw)
                draw_latched <= 1;
            else if (state == IDLE)
                draw_latched <= 0;

            display_out <= 0;

            case (state)
                IDLE: begin
                    done <= 0;
                    collision <= 0;
                    addr <= 0;
                    byte_index <= x >> 3;
                    row_counter <= 0;
                    if (draw_latched)
                        state <= LOAD;
                end

                LOAD: begin
                    curr_byte <= display_mem[byte_index];
                    addr <= byte_index;
                    state <= UPDATE;
                end

                UPDATE: begin
                    new_byte = curr_byte;
                    bit_offset = x[2:0];
                    new_byte = curr_byte ^ (sprite_data >> bit_offset); //XOR used to implement display
                    if (|(curr_byte & (sprite_data >> bit_offset))) //collision detected when 1 goes to 0
                        collision <= 1;
                    state <= STORE;
                end

                STORE: begin
                    display_mem[byte_index] <= new_byte;
                    display_out <= new_byte;
                    addr <= byte_index;
                    state <= NEXT;
                end

                NEXT: begin
                    byte_index <= byte_index + 1;
                    if (byte_index == ((x + 7) >> 3)) begin
                        // End of sprite row
                        if (row_counter + 1 == row_index + 1)
                            state <= FINISH;
                        else begin
                            row_counter <= row_counter + 1;
                            byte_index <= (x >> 3); // resetting byte indexed value
                            state <= LOAD;
                        end
                    end else
                        state <= LOAD;
                end

                FINISH: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
