`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 12:11:59 PM
// Design Name: 
// Module Name: dma_engine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dma_engine (
    input wire clk,
    input wire rst_n,

    input wire start,
    input wire [7:0] src_addr,
    input wire [7:0] dst_addr,
    input wire [7:0] length,

    output reg mem_read,
    output reg mem_write,
    output reg [7:0] mem_addr,
    input wire [7:0] mem_rdata,
    output reg [7:0] mem_wdata,

    output reg busy,
    output reg done,
    output reg irq,

    input wire irq_enable
);

parameter IDLE   = 3'b000;
parameter READ   = 3'b001;
parameter WRITE  = 3'b010;
parameter UPDATE = 3'b011;
parameter DONE   = 3'b100;

reg [2:0] state;
reg [7:0] src_reg;
reg [7:0] dst_reg;
reg [7:0] count;
reg [7:0] data_buffer;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        src_reg <= 0;
        dst_reg <= 0;
        count <= 0;
        data_buffer <= 0;

        mem_read <= 0;
        mem_write <= 0;
        mem_addr <= 0;
        mem_wdata <= 0;

        busy <= 0;
        done <= 0;
        irq <= 0;
    end 
    else begin
        mem_read <= 0;
        mem_write <= 0;
        done <= 0;
        irq <= 0;

        case (state)

            IDLE: begin
                busy <= 0;

                if (start && length != 0) begin
                    src_reg <= src_addr;
                    dst_reg <= dst_addr;
                    count <= 0;
                    busy <= 1;
                    state <= READ;
                end
            end

            READ: begin
                mem_read <= 1;
                mem_addr <= src_reg;
                data_buffer <= mem_rdata;
                state <= WRITE;
            end

            WRITE: begin
                mem_write <= 1;
                mem_addr <= dst_reg;
                mem_wdata <= data_buffer;
                state <= UPDATE;
            end

            UPDATE: begin
                src_reg <= src_reg + 1;
                dst_reg <= dst_reg + 1;
                count <= count + 1;

                if (count == length - 1)
                    state <= DONE;
                else
                    state <= READ;
            end

            DONE: begin
                busy <= 0;
                done <= 1;

                if (irq_enable)
                    irq <= 1;

                state <= IDLE;
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule

