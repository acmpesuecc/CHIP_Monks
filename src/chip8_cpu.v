`timescale 1ns / 1ps

module chip8_cpu (
    input wire clk,
    input wire reset,
    input wire [7:0] mem_data_out,
    input wire [15:0] key_pressed,
    input wire collision,

    output reg mem_read,
    output reg [11:0] mem_addr_out,
    output reg [7:0] mem_data_in,
    output reg mem_write,
    output reg draw,
    output reg [5:0] x,
    output reg [4:0] y,
    output reg [7:0] sprite_data,
    output reg [3:0] draw_row_index
);

    reg [11:0]    pc;
    reg [11:0]    I;
    reg [7:0]     V[0:15];
    reg [15:0]    opcode;
    reg [3:0]     state;
    reg [3:0]     pc_data;
    reg [11:0]    stack[0:15];
    reg [7:0]     opcode_fh;
    reg [7:0]     opcode_sh;
    reg [7:0]     delay_timer,sound_timer; 
    reg [20:0]    one_hz;
    reg [3:0]     i;
    reg [3:0]     draw_row;
    wire [7:0] display_addr;
    wire        display_done;

    localparam FETCH1 = 0, FETCH1_WAIT = 1, FETCH2 = 2, FETCH2_WAIT = 3;
    localparam LASTFETCH = 4, EXECUTE = 5, LASTFETCH_WAIT = 6;
    localparam STORE = 7, RETRIEVE = 8, RETRIEVE_WAIT = 9;
    localparam DRAW_START = 10, DRAW_INC = 11, DRAW_FETCH = 12;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            pc <= 12'h200;
            state <= FETCH1;
            opcode <= 0;
            I <= 12'd0;
            opcode_fh <= 0;
            opcode_sh <= 0;
            mem_read <= 0;
            mem_write <= 0;
            delay_timer <= 0;
            pc_data <= 0;
            one_hz <= 0;
            sound_timer <= 0;
            draw <= 0;
            draw_row <= 0;
            draw_row_index <= 0;
            sprite_data <= 8'd0;
        end else begin
            // 1Hz timers
            if (one_hz == 833333) begin
                one_hz <= 0;
                if (delay_timer > 0)
                    delay_timer <= delay_timer - 1;
                if (sound_timer > 0)
                    sound_timer <= sound_timer - 1;
            end else
                one_hz <= one_hz + 1;

            if (collision)
                V[15] <= 1;

            mem_read <= 0;
            mem_write <= 0;

            case(state)
                FETCH1: begin
                    mem_addr_out <= pc;
                    mem_read <= 1;
                    state <= FETCH1_WAIT;
                end
                FETCH1_WAIT: state <= FETCH2;
                FETCH2: begin
                    opcode_fh <= mem_data_out;
                    mem_addr_out <= pc + 1;
                    mem_read <= 1;
                    state <= FETCH2_WAIT;
                end
                FETCH2_WAIT: state <= LASTFETCH;
                LASTFETCH: begin
                    opcode_sh <= mem_data_out;
                    state <= LASTFETCH_WAIT;
                end
                LASTFETCH_WAIT: begin
                    opcode <= {opcode_fh, opcode_sh};
                    state <= EXECUTE;
                end

                EXECUTE: begin
                    case(opcode[15:12])
                        4'hD: begin
                            draw_row <= 0;
                            draw_row_index <= 0;
                            mem_read <= 1;
                            mem_addr_out <= I;
                            state <= DRAW_START;
                        end
                        default: begin
                            pc <= pc + 2;
                            state <= FETCH1;
                        end
                    endcase
                end

                DRAW_START: begin
                    draw <= 1;
                    x <= V[opcode[11:8]][5:0];
                    y <= V[opcode[7:4]][4:0];
                    draw_row_index <= draw_row;
                    sprite_data <= mem_data_out;

                    if (display_done) begin
                        draw <= 0;
                        if (draw_row == opcode[3:0] - 1) begin
                            pc <= pc + 2;
                            state <= FETCH1;
                        end else begin
                            draw_row <= draw_row + 1;
                            mem_addr_out <= I + draw_row + 1;
                            mem_read <= 1;
                            state <= DRAW_FETCH;
                        end
                    end
                end

                DRAW_FETCH: begin
                    sprite_data <= mem_data_out;
                    state <= DRAW_START;
                end

                STORE: begin 
                    mem_addr_out <= I + i;
                    mem_data_in <= V[i];
                    mem_write <= 1;

                    if (i == opcode[11:8]) begin
                        pc <= pc + 2;
                        state <= FETCH1;
                    end else begin
                        i <= i+1;
                        state <= STORE;
                    end
                end

                RETRIEVE: begin
                    if(i <= opcode[11:8]) begin
                        mem_addr_out <= I + i;
                        mem_read <= 1;
                    end else begin
                        pc <= pc + 2;
                        state <= FETCH1;
                    end
                end

                RETRIEVE_WAIT: begin
                    V[i] <= mem_data_out;
                    i <= i + 1;
                    state <= RETRIEVE;  
                end

                default: state <= FETCH1;
            endcase
        end
    end

endmodule
