`timescale 1ns / 1ps
///////////////////////
//module name: axi_stream_insert_header_tb
//date: 2024/1/24
//author: Yunjie Zhang
///////////////////////

// useful boolean single-bit definitions
`define FALSE  1'h0
`define TRUE  1'h1

// standard delay - use after all non-blocking assignments
`define SD #1


module axi_tb();
    parameter DATA_DEPTH =256;
    parameter DATA_WD = 32;
    parameter DATA_BYTE_WD = DATA_WD / 8;
    parameter DATA_CNT=DATA_DEPTH/DATA_WD;
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

    logic clk;
    logic rst_n;
    // AXI Stream input original data
    logic valid_in;
    logic [DATA_WD-1 : 0] data_in;
    logic [DATA_BYTE_WD-1 : 0] keep_in;
    logic last_in;
    wire ready_in;
    // AXI Stream output with header inserted
    wire valid_out;
    wire [DATA_WD-1 : 0] data_out;
    wire [DATA_BYTE_WD-1 : 0] keep_out;
    wire last_out;
    logic ready_out;
    // The header to be inserted to AXI Stream input
    logic valid_insert;
    logic [DATA_WD-1 : 0] header_insert;
    logic [DATA_BYTE_WD-1 : 0] keep_insert;
    wire ready_insert;
    logic [3:0]cnt,cnt1;

    axi DUT(
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .keep_in(keep_in),
        .last_in(last_in),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .data_out(data_out),
        .keep_out(keep_out),
        .last_out(last_out),
        .ready_out(ready_out),
        .valid_insert(valid_insert),
        .header_insert(header_insert),
        .keep_insert(keep_insert),
        .ready_insert(ready_insert)
    );
    initial begin

        $display("------------------------------------------------");
        $display("@@@TESTCASE 1 BASIC PARTIAL");
        $display("------------------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b0111;

        @(negedge clk)

        @(negedge clk)
        rst_n = 1'b1;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b0111;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'hEEFF0011;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h22334455;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h66778899;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h00AA8888;
        keep_in = 4'b1100;
        last_in = 1'b1;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);
        @(negedge clk)
        @(negedge clk)
        @(negedge clk)
        
        $display("------------------------------------------------");
        $display("@@@TESTCASE 2 BASIC PARTIAL OUT STALL");
        $display("------------------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b0111;

        @(negedge clk)

        @(negedge clk)
        rst_n = 1'b1;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b0111;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'hEEFF0011;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h22334455;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b0;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h22334455;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h66778899;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h00AA8888;
        keep_in = 4'b1100;
        last_in = 1'b1;
        ready_out = 1'b0;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h00AA8888;
        keep_in = 4'b1100;
        last_in = 1'b1;
        ready_out = 1'b0;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h00AA8888;
        keep_in = 4'b1100;
        last_in = 1'b1;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);
        @(negedge clk)
        @(negedge clk)
        @(negedge clk)

        $display("------------------------------------------------");
        $display("@@@TESTCASE 3 Nothing Inserted");
        $display("------------------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b0000;

        @(negedge clk)

        @(negedge clk)
        rst_n = 1'b1;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b0000;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'hEEFF0011;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h22334455;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h66778899;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h00AA8888;
        keep_in = 4'b1100;
        last_in = 1'b1;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);
        @(negedge clk)
        @(negedge clk)
        @(negedge clk)

        $display("------------------------------------------------");
        $display("@@@TESTCASE 4 Whole Inserted");
        $display("------------------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b1111;

        @(negedge clk)

        @(negedge clk)
        rst_n = 1'b1;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hFFEEDDCC;
        keep_insert = 4'b1111;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'hEEFF0011;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h22334455;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h66778899;
        keep_in = 4'b1111;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b1;//
        data_in = 32'h00AA8888;
        keep_in = 4'b1100;
        last_in = 1'b1;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);
        @(negedge clk)
        @(negedge clk)
        @(negedge clk)

        $display("------------------------------------------------");
        $display("@@@TESTCASE 5 Signle Byte Data");
        $display("------------------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;
        valid_in = `FALSE;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = `FALSE;
        ready_out = `TRUE;//
        valid_insert = `FALSE;
        header_insert = 32'h0;
        keep_insert = 4'b0;

        @(negedge clk)

        @(negedge clk)
        rst_n = 1'b1;
        valid_in = `TRUE;//
        data_in = 32'hAABBCCDD;
        keep_in = 4'b1111;
        last_in = `TRUE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hCC00FFEE;
        keep_insert = 4'b0011;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = `FALSE;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        @(negedge clk)
        @(negedge clk)
        valid_in = `TRUE;//
        data_in = 32'h00112233;
        keep_in = 4'b1110;
        last_in = `TRUE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hCC00FFEE;
        keep_insert = 4'b0001;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        @(negedge clk)
        @(negedge clk)
        valid_in = `TRUE;//
        data_in = 32'h44556677;
        keep_in = 4'b1100;
        last_in = `TRUE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hCC00FFEE;
        keep_insert = 4'b0011;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        @(negedge clk)
        @(negedge clk)
        valid_in = `TRUE;//
        data_in = 32'h8899AABB;
        keep_in = 4'b1000;
        last_in = `TRUE;
        ready_out = `TRUE;//
        valid_insert = `TRUE;
        header_insert = 32'hCC00FFEE;
        keep_insert = 4'b0011;

        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        valid_in = 1'b0;//
        data_in = 32'h0;
        keep_in = 4'b0;
        last_in = 1'b0;
        ready_out = 1'b1;//
        valid_insert = 1'b0;
        header_insert = 32'h0;
        keep_insert = 4'b0;
        
        $monitor("time = %d ,clk = %b, rst_n = %b, ready_in = %b, ready_insert = %b, valid_out = %b, data_out = %x, keep_out = %b, last_out = %b", $time ,clk, rst_n, ready_in, ready_insert, valid_out, data_out, keep_out, last_out);

        @(negedge clk)
        @(negedge clk)
        @(negedge clk)

        

        $finish;
    end


    always #10 clk=!clk;
endmodule