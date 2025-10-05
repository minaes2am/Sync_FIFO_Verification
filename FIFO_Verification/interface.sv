interface fifo_if(clk);
 parameter FIFO_WIDTH = 16;
 parameter FIFO_DEPTH = 8;    
 input bit clk;
 logic [FIFO_WIDTH-1:0] data_in;
 logic rst_n, wr_en, rd_en;
 logic [FIFO_WIDTH-1:0] data_out;
 logic wr_ack, overflow, underflow;
 logic full, empty, almostfull, almostempty;

 modport DUT (
 input clk,
 input rst_n,
 input wr_en,
 input rd_en,
 input data_in,
 output data_out,
 output wr_ack,
 output overflow,
 output underflow,
 output full,
 output empty,
 output almostfull,
 output almostempty
 );

 modport TEST (
 input clk,
 output rst_n,
 output wr_en,
 output rd_en,
 output data_in,
 input data_out,
 input wr_ack,
 input overflow,
 input underflow,
 input full,
 input empty,
 input almostfull,
 input almostempty
 );

 modport MONITOR (
 input clk,
 input rst_n,
 input wr_en,
 input rd_en,
 input data_in,
 input data_out,
 input wr_ack,
 input overflow,
 input underflow,
 input full,
 input empty,
 input almostfull,
 input almostempty
 ); 

endinterface
