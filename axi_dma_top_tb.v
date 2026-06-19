`timescale 1ns/1ps

module tb_axi_dma_top;

reg ACLK;
reg ARESETN;

reg [31:0] S_AXI_AWADDR;
reg S_AXI_AWVALID;
wire S_AXI_AWREADY;

reg [31:0] S_AXI_WDATA;
reg [3:0] S_AXI_WSTRB;
reg S_AXI_WVALID;
wire S_AXI_WREADY;

wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID;
reg S_AXI_BREADY;

reg [31:0] S_AXI_ARADDR;
reg S_AXI_ARVALID;
wire S_AXI_ARREADY;

wire [31:0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;
reg S_AXI_RREADY;

wire irq;

axi_dma_top DUT (
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

    .irq(irq)
);

always #5 ACLK = ~ACLK;

task axi_write;
    input [31:0] addr;
    input [31:0] data;
    begin
        @(posedge ACLK);
        S_AXI_AWADDR  <= addr;
        S_AXI_AWVALID <= 1;
        S_AXI_WDATA   <= data;
        S_AXI_WSTRB   <= 4'hF;
        S_AXI_WVALID  <= 1;
        S_AXI_BREADY  <= 1;

        wait(S_AXI_AWREADY && S_AXI_WREADY);

        @(posedge ACLK);
        S_AXI_AWVALID <= 0;
        S_AXI_WVALID  <= 0;

        wait(S_AXI_BVALID);

        @(posedge ACLK);
        S_AXI_BREADY <= 0;
    end
endtask

task axi_read;
    input [31:0] addr;
    begin
        @(posedge ACLK);
        S_AXI_ARADDR  <= addr;
        S_AXI_ARVALID <= 1;
        S_AXI_RREADY  <= 1;

        wait(S_AXI_ARREADY);

        @(posedge ACLK);
        S_AXI_ARVALID <= 0;

        wait(S_AXI_RVALID);

        $display("AXI READ Address = %h, Data = %h", addr, S_AXI_RDATA);

        @(posedge ACLK);
        S_AXI_RREADY <= 0;
    end
endtask

initial begin
    ACLK = 0;
    ARESETN = 0;

    S_AXI_AWADDR = 0;
    S_AXI_AWVALID = 0;
    S_AXI_WDATA = 0;
    S_AXI_WSTRB = 0;
    S_AXI_WVALID = 0;
    S_AXI_BREADY = 0;

    S_AXI_ARADDR = 0;
    S_AXI_ARVALID = 0;
    S_AXI_RREADY = 0;

    #30;
    ARESETN = 1;

    #20;

    axi_write(32'h00, 32'h10);
    axi_write(32'h04, 32'h20);
    axi_write(32'h08, 32'h04);
    axi_write(32'h14, 32'h01);
    axi_write(32'h0C, 32'h01);

    #100;

    axi_read(32'h10);

    #20;

    $display("DMA Transfer Completed");
    $display("RAM[20] = %h", DUT.RAM.ram[8'h20]);
    $display("RAM[21] = %h", DUT.RAM.ram[8'h21]);
    $display("RAM[22] = %h", DUT.RAM.ram[8'h22]);
    $display("RAM[23] = %h", DUT.RAM.ram[8'h23]);

    #50;
    $finish;
end

initial begin
    $dumpfile("axi_dma.vcd");
    $dumpvars(0, tb_axi_dma_top);
end

endmodule
