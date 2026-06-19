`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2026 12:08:02 PM
// Design Name: 
// Module Name: axi_lite_slave
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


module axi_lite_slave (
    input wire ACLK,
    input wire ARESETN,

    input wire [31:0] S_AXI_AWADDR,
    input wire S_AXI_AWVALID,
    output reg S_AXI_AWREADY,

    input wire [31:0] S_AXI_WDATA,
    input wire [3:0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output reg S_AXI_WREADY,

    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,
    input wire S_AXI_BREADY,

    input wire [31:0] S_AXI_ARADDR,
    input wire S_AXI_ARVALID,
    output reg S_AXI_ARREADY,

    output reg [31:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input wire S_AXI_RREADY,

    output reg [7:0] src_addr,
    output reg [7:0] dst_addr,
    output reg [7:0] length,
    output reg start,

    input wire busy,
    input wire done,
    output reg irq_enable
);

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        S_AXI_AWREADY <= 0;
        S_AXI_WREADY  <= 0;
        S_AXI_BVALID  <= 0;
        S_AXI_BRESP   <= 2'b00;
        S_AXI_ARREADY <= 0;
        S_AXI_RVALID  <= 0;
        S_AXI_RRESP   <= 2'b00;
        S_AXI_RDATA   <= 0;

        src_addr <= 0;
        dst_addr <= 0;
        length <= 0;
        start <= 0;
        irq_enable <= 0;
    end 
    else begin
        start <= 0;

        S_AXI_AWREADY <= 0;
        S_AXI_WREADY  <= 0;
        S_AXI_ARREADY <= 0;

        if (S_AXI_AWVALID && S_AXI_WVALID && !S_AXI_BVALID) begin
            S_AXI_AWREADY <= 1;
            S_AXI_WREADY  <= 1;
            S_AXI_BVALID  <= 1;
            S_AXI_BRESP   <= 2'b00;

            case (S_AXI_AWADDR[7:0])
                8'h00: src_addr <= S_AXI_WDATA[7:0];
                8'h04: dst_addr <= S_AXI_WDATA[7:0];
                8'h08: length   <= S_AXI_WDATA[7:0];
                8'h0C: start    <= S_AXI_WDATA[0];
                8'h14: irq_enable <= S_AXI_WDATA[0];
            endcase
        end

        if (S_AXI_BVALID && S_AXI_BREADY)
            S_AXI_BVALID <= 0;

        if (S_AXI_ARVALID && !S_AXI_RVALID) begin
            S_AXI_ARREADY <= 1;
            S_AXI_RVALID  <= 1;
            S_AXI_RRESP   <= 2'b00;

            case (S_AXI_ARADDR[7:0])
                8'h00: S_AXI_RDATA <= {24'd0, src_addr};
                8'h04: S_AXI_RDATA <= {24'd0, dst_addr};
                8'h08: S_AXI_RDATA <= {24'd0, length};
                8'h10: S_AXI_RDATA <= {30'd0, done, busy};
                8'h14: S_AXI_RDATA <= {31'd0, irq_enable};
                default: S_AXI_RDATA <= 32'd0;
            endcase
        end

        if (S_AXI_RVALID && S_AXI_RREADY)
            S_AXI_RVALID <= 0;
    end
end

endmodule
