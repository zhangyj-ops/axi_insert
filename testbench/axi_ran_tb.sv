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
    // parameter DATA_DEPTH =256;
    parameter DATA_WD = 32;
    parameter DATA_BYTE_WD = DATA_WD / 8;
    // parameter DATA_CNT=DATA_DEPTH/DATA_WD;
    // parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);
    parameter CLOCK_PERIOD=20;
    parameter LENGTH = 3;

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
        clk = '0;
        forever  #(CLOCK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #(CLOCK_PERIOD*2) rst_n = 1'b1;
	    #(CLOCK_PERIOD*200)
	    $finish;
    end

    // valid random trigger
    integer seed;
    initial begin	                                 
        seed = 2;
    end

    // random valid_insert
    always_ff @(posedge clk or negedge rst_n)begin
            if(!rst_n)
                valid_insert <= `FALSE;	
            else
                valid_insert <=	{$random(seed)}%2;
    end

    // randomly generate the header data
    initial begin
        forever #(CLOCK_PERIOD)	begin
                header_insert = $random(seed);
                keep_insert = {$random(seed)}%2?({$random(seed)}%2?4'b0001:4'b0011):({$random(seed)}%2?4'b0111:4'b1111);
        end
    end

    // random ready_out
    always_ff @(posedge clk or negedge rst_n)begin
            if(!rst_n)
                ready_out <= `TRUE;	
            else
                ready_out <=	{$random(seed)}%2;
    end

    // count the number of data packet
    logic 	[3:0]   cnt = 0;
    always_ff @(posedge clk or negedge rst_n)begin
            if(!rst_n)
                    cnt <= 'd0;
            else if(ready_in && cnt == 0)
                    cnt <= cnt + 1;
            else if(ready_in && valid_in)
                    cnt <= cnt + 1;
            else if(cnt == (LENGTH+1)) 
                    cnt <= 'd0;
            else 
                cnt <= cnt;

    end

    // four packet of data in a row
    always_ff @(posedge clk or negedge rst_n)begin
            if(!rst_n)
                    data_in <= 32'h0			;
            else if(ready_in)
                case(cnt)
                    0: data_in <= $random(seed);
                    1: data_in <= $random(seed);				
                    2: data_in <= $random(seed);
                    3: data_in <= $random(seed);		
                    default: data_in <= 'b0;
                endcase
            else 
                data_in <= data_in;
    end

    // valid_in depend on ready signal
    always_ff @(posedge clk or negedge rst_n)begin
            if(!rst_n)
                    valid_in <= 0;
            else if(ready_in)
                case(cnt)
                    0: valid_in <= 1'b1;
                    1: valid_in <= 1'b1;
                    2: valid_in <= 1'b1;
                    3: valid_in <= 1'b1;	
                    default: valid_in <= 1'b0;	
                endcase
            else 
                    valid_in <= valid_in;
    end	

    // random keep_in for last packet
    always_ff @(posedge clk or negedge rst_n)begin
            if(!rst_n)
                    keep_in <= 'b0;
            else if(ready_in)
                case(cnt)
                    0: keep_in <= 4'b1111;
                    1: keep_in <= 4'b1111;
                    2: keep_in <= 4'b1111;
                    3: keep_in <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000);
                    default: keep_in <=	4'b0;
                endcase
            else 
                    keep_in <= keep_in;
    end

    // if cnt reaches last one then is last_in
    assign 		last_in	= (cnt == LENGTH + 1) ? 1: 0		;
    

    initial begin
        $display("------------------------------------------------");
        $display("@@@TESTCASE 1 BASIC PARTIAL");
        $display("------------------------------------------------");
    end

endmodule