`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 12:20:58 PM
// Design Name: 
// Module Name: axi_dma_top
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


module axi_dma_top (
    input wire ACLK,
    input wire ARESETN,

    input wire [31:0] S_AXI_AWADDR,
    input wire S_AXI_AWVALID,
    output wire S_AXI_AWREADY,

    input wire [31:0] S_AXI_WDATA,
    input wire [3:0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output wire S_AXI_WREADY,

    output wire [1:0] S_AXI_BRESP,
    output wire S_AXI_BVALID,
    input wire S_AXI_BREADY,

    input wire [31:0] S_AXI_ARADDR,
    input wire S_AXI_ARVALID,
    output wire S_AXI_ARREADY,

    output wire [31:0] S_AXI_RDATA,
    output wire [1:0] S_AXI_RRESP,
    output wire S_AXI_RVALID,
    input wire S_AXI_RREADY,

    output wire irq
);

wire [7:0] src_addr;
wire [7:0] dst_addr;
wire [7:0] length;
wire start;
wire busy;
wire done;
wire irq_enable;

wire mem_read;
wire mem_write;
wire [7:0] mem_addr;
wire [7:0] mem_rdata;
wire [7:0] mem_wdata;

axi_lite_slave AXI_SLAVE (
    .ACLK(ACLK),
    .ARESETN(ARESETN),

    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),

    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),

    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),

    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),

    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),

    .src_addr(src_addr),
    .dst_addr(dst_addr),
    .length(length),
    .start(start),

    .busy(busy),
    .done(done),
    .irq_enable(irq_enable)
);

dma_engine DMA_ENGINE (
    .clk(ACLK),
    .rst_n(ARESETN),

    .start(start),
    .src_addr(src_addr),
    .dst_addr(dst_addr),
    .length(length),

    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_rdata(mem_rdata),
    .mem_wdata(mem_wdata),

    .busy(busy),
    .done(done),
    .irq(irq),
    .irq_enable(irq_enable)
);

simple_ram RAM (
    .clk(ACLK),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata)
);

endmodule