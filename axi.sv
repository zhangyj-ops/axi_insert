///////////////////////
//module name: axi_stream_insert_header
//date: 2024/1/24
//author: Yunjie Zhang
///////////////////////

// Assumptions: 1. Assume data_in doesn't come in consecutive one byte
// 2. Assume header signal always comes no later than date signal

// useful boolean single-bit definitions
`define FALSE  1'h0
`define TRUE  1'h1

// standard delay - use after all non-blocking assignments
`define SD #1

// dummy DATA_BUFFER_ENTRY
localparam empty_dbuffer_entry = {
    32'h0, // data
    4'b0, // keep
    `FALSE, // last
    `FALSE  // busy bit
};

// dummy HEADER_BUFFER_ENTRY
localparam empty_hbuffer_entry = {
    32'h0, // header
    4'b0, // keep
    `TRUE, // inserted
    `FALSE  // busy bit
};

typedef struct packed {
    logic  [31:0] data;
    logic  [3:0]  keep;
    logic         last;
    logic         busy;
} DBUFFER_ENTRY;

typedef struct packed {
    logic  [31:0] header;
    logic  [3:0]  keep;
    logic         inserted;
    logic         busy;
} HBUFFER_ENTRY;


// Count te one-hot encoding of keep signal
// function 	    [DATA_WD:0] 	swar;
// 	input		[DATA_WD:0]		data_in;
// 	logic		[DATA_WD:0]		i;
// 		begin
// 				i	=	data_in;		
// 				i 	=	(i & 32'h5555_5555) + ({1'b0, i[DATA_WD:1]} & 32'h5555_5555);
// 				i 	=	(i & 32'h3333_3333) + ({1'b0, i[DATA_WD:2]} & 32'h3333_3333);
// 				i 	=	(i & 32'h0F0F_0F0F) + ({1'b0, i[DATA_WD:4]} & 32'h0F0F_0F0F);
// 				i 	= 	i * (32'h0101_0101);
// 				swar =	i[31:24];
// 		end
// endfunction



module axi #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8
) (
    input                        clk, // rising edge triggered
    input                        rst_n, // active low

    // AXI Stream input original data
    input                        valid_in,
    input   [DATA_WD-1 : 0]      data_in,
    input   [DATA_BYTE_WD-1 : 0] keep_in,
    input                        last_in,
    output                       ready_in, // 

    // AXI Stream output with header inserted
    output logic                      valid_out,
    output logic [DATA_WD-1 : 0]      data_out,
    output logic [DATA_BYTE_WD-1 : 0] keep_out,
    output logic                      last_out,
    input                        ready_out,

    // The header to be inserted to AXI Stream input
    input                        valid_insert,
    input   [DATA_WD-1 : 0]      header_insert,
    input   [DATA_BYTE_WD-1 : 0] keep_insert,
    output                       ready_insert //
);

// Your code here

    // // Signal type complement
    // reg                          valid_out;
    // reg     [DATA_WD-1 : 0]      data_out;
    // reg     [DATA_BYTE_WD-1 : 0] keep_out;
    // reg                          last_out;

    // Declare local registers and wires
    DBUFFER_ENTRY [1:0] dbuffer; // Structure for temporarily store data in packets. USe 2 entries for saving area and simplicity
    DBUFFER_ENTRY [1:0] dbuffer_next; // Sequential update

    HBUFFER_ENTRY hbuffer; // Structure for temporarily store header in packets
    HBUFFER_ENTRY hbuffer_next; // Sequential update

    // Issue variable
    // logic header_issue; // High when issued from hbuffer
    // assign issue = valid_out & ready_out; 
    logic data_issue_flag; // High when issued from dbuffer
    logic header_inserted_flag; // High when hbuffer header is inserted

    // last pulse record
    // TODO: monitor last_out is safer
    logic last_finished; // High when a last pulse pass dbuffer, flush the whole hbuffer
    assign last_finished = ~dbuffer[0].last & dbuffer[1].last; // Assume data_in doesn't come in consecutive one byte
    
    // Read data into internal registers for later processing

    // If first entry of data buffer is avalable, read in data (start); Or one dbuffer entry is issued
    assign ready_in = ~dbuffer[1].busy | data_issue_flag;

    // Update next state of buffer
    always_comb begin
        // ready_in = ~dbuffer[1].busy | data_issue_flag;
        dbuffer_next = dbuffer; // stall
        if (valid_in && ready_in) begin 
            // can read in now
            dbuffer_next[1] = dbuffer[0];
            dbuffer_next[0] = {data_in, keep_in, last_in, `TRUE};
            // dbuffer_next[0].data = data_in;
            // dbuffer_next[0].keep = keep_in;
            // dbuffer_next[0].last = last_in;
            // dbuffer_next[0].busy = `TRUE;
        end
        else if (ready_in) begin
            dbuffer_next[1] = dbuffer[0];
            dbuffer_next[0] = empty_dbuffer_entry;
        end
        // else if (data_issue_flag && last_out) begin
        //     dbuffer_next[1] = empty_dbuffer_entry;
        //     dbuffer_next[0] = empty_dbuffer_entry;
        // end
        if (last_finished) begin
            dbuffer_next[1] = empty_dbuffer_entry;
        end
    end


    // Read header

    // If last transaction has been finished (last pulse passed), read in header 
    assign ready_insert = ~hbuffer.busy;
    // Update next state of buffer
    always_comb begin
        hbuffer_next = hbuffer; // Originally not busy, then not busy before reading header
        // hbuffer_next.busy = hbuffer.busy & ~last_finished;
        if (last_finished) begin
            hbuffer_next = empty_hbuffer_entry; // clear hbuffer if last transaction finished
        end
        if (header_inserted_flag) begin
            hbuffer_next.inserted = `TRUE;
        end
        if (valid_insert && ready_insert) begin 
            // can read in now
            hbuffer_next = {header_insert, keep_insert, `FALSE, `TRUE};
            // hbuffer_next.header = header_insert;
            // hbuffer_next.keep = keep_in;
            // hbuffer_next.inserted = `FALSE;
            // hbuffer_next.busy = `TRUE;
        end
    end
    
    // Debug signals
    logic [3:0] header_ones;
    logic [3:0] header_zeros;    
    logic [3:0] data0_ones;
    logic [3:0] data0_zeros;

    always_comb begin
    header_ones = $countbits(hbuffer.keep, 1'b1);
    header_zeros = $countbits(hbuffer.keep, 1'b0);
    data0_ones = $countbits(dbuffer[0].keep, 1'b1);
    data0_zeros = $countbits(dbuffer[0].keep, 1'b0);
    end
    
    logic [31:0] data_out_h;
    assign data_out_h = hbuffer.header << 8 * $countbits(hbuffer.keep, 1'b0);
    logic [31:0] data_out_d;
    assign data_out_d = dbuffer[0].data >> 8 * $countbits(hbuffer.keep, 1'b1);

    // Insert and set data out
    always_comb begin
        data_issue_flag = `FALSE; // Default value
        header_inserted_flag = `FALSE;
        valid_out = `FALSE;
        data_out = 'h0;
        last_out = `FALSE;
        keep_out = 'b0;
        
        // TODO: Assume header signal always comes no later than date signal
        // Insert
        if (hbuffer.busy && !hbuffer.inserted && dbuffer[0].busy) begin
            valid_out = `TRUE; // Not inserted, always valid
            data_out = (hbuffer.header << 8 * $countbits(hbuffer.keep, 1'b0)) | dbuffer[0].data >> 8 * $countbits(hbuffer.keep, 1'b1); // Shift header and data and connect them with bit operation
            last_out = dbuffer[0].last & ($countbits(hbuffer.keep, 1'b1) + $countbits(dbuffer[0].keep, 1'b1) <= DATA_BYTE_WD); // If data goes to the last transaction, count the number of valid bits in header and last package 
            keep_out = dbuffer[0].last & ($countbits(hbuffer.keep, 1'b1) + $countbits(dbuffer[0].keep, 1'b1) <= DATA_BYTE_WD) ? dbuffer[0].keep << $countbits(hbuffer.keep, 1'b0) : {DATA_BYTE_WD{1'b1}};

            // Check whether can output
            if (ready_out && valid_out) begin
                data_issue_flag = `TRUE;
                header_inserted_flag = `TRUE;
            end
            
        end
        else if (hbuffer.busy && dbuffer[0].busy && dbuffer[1].busy) begin // Shift data based on keep in header buffer and output
            valid_out = `TRUE; // new data input, always valid
            data_out = (dbuffer[1].data << 8 * $countbits(hbuffer.keep, 1'b0)) | dbuffer[0].data >> 8 * $countbits(hbuffer.keep, 1'b1); // Shift header and data and connect them with bit operation
            last_out = dbuffer[0].last & ($countbits(hbuffer.keep, 1'b1) + $countbits(dbuffer[0].keep, 1'b1) <= DATA_BYTE_WD); // If data goes to the last transaction, count the number of valid bits in header and last package 
            keep_out = dbuffer[0].last & ($countbits(hbuffer.keep, 1'b1) + $countbits(dbuffer[0].keep, 1'b1) <= DATA_BYTE_WD) ? dbuffer[0].keep << $countbits(hbuffer.keep, 1'b0) : {DATA_BYTE_WD{1'b1}};
            
            // Check whether can output
            if (ready_out && valid_out) begin
                data_issue_flag = `TRUE;
                // hbuffer_next.inserted = `TRUE;
            end
        end
        else if (hbuffer.busy && dbuffer[1].busy) begin // only hbuffer and dbuffer[1] are busy
            valid_out = ($countbits(hbuffer.keep, 1'b1) + $countbits(dbuffer[1].keep, 1'b1) >= DATA_BYTE_WD) ? `TRUE : `FALSE; // Only valid when there's overflow in dbuffer 0
            data_out = dbuffer[1].data << 8 * $countbits(hbuffer.keep, 1'b0); // Shift overfloew data
            last_out = ($countbits(hbuffer.keep, 1'b1) + $countbits(dbuffer[1].keep, 1'b1) >= DATA_BYTE_WD) ? `TRUE : `FALSE; // is last if valid
            keep_out = dbuffer[1].keep << $countbits(hbuffer.keep, 1'b0);

            // case(hbuffer.keep)            
            //     // partial insert
            //     4'b0111: begin
            //         valid_out = (dbuffer[1].keep != 4'b1000) ? `TRUE : `FALSE;
            //         data_out = {dbuffer[1].data[23:0], 8'b0};
            //         last_out = (dbuffer[1].keep != 4'b1000) ? `TRUE : `FALSE; // is last if valid
            //         keep_out = dbuffer[1].keep << 1;
            //         // keep_out = (dbuffer[0].last & (dbuffer[0].keep == 4'b1000)) ? dbuffer[0].keep << 1 : 4'b1111;
            //     end
            //     4'b0011: begin
            //         valid_out = ((dbuffer[1].keep == 4'b1110) | (dbuffer[1].keep == 4'b1111)) ? `TRUE : `FALSE;
            //         data_out = {dbuffer[1].data[15:0], 16'b0};
            //         last_out = ((dbuffer[1].keep == 4'b1110) | (dbuffer[1].keep == 4'b1111)) ? `TRUE : `FALSE; // is last if valid
            //         keep_out = dbuffer[1].keep << 2;                  
            //     end
            //     4'b0001: begin
            //         valid_out = (dbuffer[1].keep == 4'b1111) ? `TRUE : `FALSE;
            //         data_out = {dbuffer[1].data[7:0], 24'b0};
            //         last_out = (dbuffer[1].keep == 4'b1111) ? `TRUE : `FALSE; // is last if valid
            //         keep_out = dbuffer[1].keep << 3;                    
            //     end        

            //     // whole insert
            //     4'b1111: begin
            //         valid_out = `TRUE;
            //         data_out = dbuffer[1].data;
            //         last_out = dbuffer[1].last;
            //         keep_out = dbuffer[1].keep;
            //     end

            //     // nothing insert
            //     4'b0000: begin
            //         valid_out = `FALSE;
            //         data_out = 32'h0;
            //         last_out = `FALSE;
            //         keep_out = 4'b0;
            //     end
            //     default: begin
            //         valid_out = `FALSE;
            //         data_out = 32'h0;
            //         last_out = `FALSE;
            //         keep_out = 4'b0;
            //     end

            // endcase
            // Check whether can output
            if (ready_out && valid_out) begin
                data_issue_flag = `TRUE;
                // hbuffer_next.inserted = `TRUE;
            end
        end

        
        
    end


    // Update sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reinitialize all data and signals
            dbuffer <= `SD {empty_dbuffer_entry, empty_dbuffer_entry};
            hbuffer <= `SD empty_hbuffer_entry;
        end
        else begin
            dbuffer <= `SD dbuffer_next;
            hbuffer <= `SD hbuffer_next;
        end
    end


    // function [DATA_BYTE_WD-1 : 0] num_ones; 
    //     input   [DATA_BYTE_WD-1 : 0]  value;
    //     logic   [DATA_BYTE_WD-1 : 0]  ones;

    //     integer i;

    //     always@(value) begin
    //         ones = 0;  //initialize count variable.
    //         for(i = 0;i < DATA_BYTE_WD; i = i + 1) begin   //for all the bits.
    //             ones = ones + value[i]; //Add the bit to the count.
    //         end
    //         num_ones = ones;
    //     end

    // endfunction

    // function [DATA_BYTE_WD-1 : 0] num_zeros; 
    //     input   [DATA_BYTE_WD-1 : 0]  value;
    //     logic   [DATA_BYTE_WD-1 : 0]  zeros;

    //     integer i;

    //     always@(value) begin
    //         ones = 0;  //initialize count variable.
    //         for(i = 0;i < DATA_BYTE_WD; i = i + 1) begin   //for all the bits.
    //             if (value[i] == 1'b0)
    //                 zeros = zeros + 1; //Add the bit to the count.
    //         end
    //         num_zeros = zeros;
    //     end

    // endfunction


endmodule