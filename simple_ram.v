`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 12:13:55 PM
// Design Name: 
// Module Name: simple_ram
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

module simple_ram (
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [7:0] mem_addr,
    input wire [7:0] mem_wdata,
    output reg [7:0] mem_rdata
);

reg [7:0] ram [0:255];

integer i;

initial begin
    for (i = 0; i < 256; i = i + 1)
        ram[i] = 8'h00;

    ram[8'h10] = 8'hA5;
    ram[8'h11] = 8'h3C;
    ram[8'h12] = 8'hF0;
    ram[8'h13] = 8'h55;
end

always @(*) begin
    if (mem_read)
        mem_rdata = ram[mem_addr];
    else
        mem_rdata = 8'h00;
end

always @(posedge clk) begin
    if (mem_write)
        ram[mem_addr] <= mem_wdata;
end

endmodule
