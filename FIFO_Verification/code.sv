/*
my edits:
1- reg [FIFO_WIDTH-1:0] mem [0:FIFO_DEPTH-1]; <- reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0] (due to it is unpacked); 
2- add this to write reset list  (wr_ack   <= 0;  overflow <= 0; data_out <= 0;)
3- add this overflow    <= 0; to 
      (	else if (wr_en && count < FIFO_DEPTH) begin
	    mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;)
4- make underflow reg due to it is a seq signal        
5- add this block since uderflow is seq
(always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    underflow <= 0;
  else if (rd_en && empty)
    underflow <= 1;   // pulse on rejected read
  else
    underflow <= 0;
end)
6- if (rd_ptr == FIFO_DEPTH-1)
			rd_ptr <= 0;
		else	         (to be a wrap up pinter)
7-	if (wr_ptr == FIFO_DEPTH-1) begin
			wr_ptr <= 0;
		end   	 (to be a wrap up pinter)
8- assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0; <- assign almostfull = (count == FIFO_DEPTH-2)? 1 : 0; 
9- else if ({wr_en, rd_en} == 2'b11) begin
			if (empty) begin
				count <= count + 1;
			end else if(full) begin
				count <= count - 1;
			end
		end	   to handle when read and write is asserted 
10-  assign f_if.almostfull = (count == FIFO_DEPTH-1)? 1 : 0;  change to -1 istead of -2 		
*/

module FIFO(fifo_if.DUT f_if);
 parameter FIFO_WIDTH = 16;
 parameter FIFO_DEPTH = 8;
 localparam max_fifo_addr = $clog2(FIFO_DEPTH);
 reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
 reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
 reg [max_fifo_addr:0] count;
    //FIFO_8
  `ifdef SIM
  always_comb begin
    if(!f_if.rst_n) begin 
	 count_rst: assert final(count == 0);
     wr_ptr_rst: assert final(wr_ptr == 0);
     rd_ptr_rst: assert final(rd_ptr == 0);
	 count_rst_c: cover final(count == 0);
     wr_ptr_rst_c: cover final(wr_ptr == 0);
     rd_ptr_rst_c: cover final(rd_ptr == 0);
    
	end
	  if (count == 1) begin
        alm_empty_check: assert final (f_if.almostempty == 1'b1);
	 end else if(count == 0) begin
        empty_check_comb: assert final (f_if.empty == 1'b1);
	 end else if (count == FIFO_DEPTH) begin
        full_check_comb: assert final (f_if.full == 1'b1);
	 end else if(count == FIFO_DEPTH-1) begin
        alm_full_check: assert final (f_if.almostfull == 1'b1); 
	 end

  end

property reset_check;
  @(posedge f_if.clk) !f_if.rst_n |-> (wr_ptr == 0 && rd_ptr == 0 && count == 0);
endproperty

property wr_ack_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (f_if.wr_en && !f_if.full) |=> f_if.wr_ack;
endproperty

property overflow_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (f_if.wr_en && f_if.full) |=> f_if.overflow;
endproperty

property underflow_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (f_if.rd_en && f_if.empty) |=> f_if.underflow;
endproperty

property empty_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (count == 0) |-> f_if.empty;
endproperty

property full_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (count == FIFO_DEPTH) |-> f_if.full;
endproperty

property almostfull_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (count == FIFO_DEPTH-1) |-> f_if.almostfull;
endproperty

property almostempty_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (count == 1) |-> f_if.almostempty;
endproperty

property wr_wrap_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (f_if.wr_en && !f_if.full && wr_ptr == FIFO_DEPTH-1) |=> (wr_ptr == 0);
endproperty

property rd_wrap_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n)
    (f_if.rd_en && !f_if.empty && rd_ptr == FIFO_DEPTH-1) |=> (rd_ptr == 0);
endproperty

property wr_threshold_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n) wr_ptr < FIFO_DEPTH;
endproperty

property rd_threshold_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n) rd_ptr < FIFO_DEPTH;
endproperty

property count_threshold_check;
  @(posedge f_if.clk) disable iff(!f_if.rst_n) count <= FIFO_DEPTH;
endproperty

property count_up_check;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en) && (!f_if.rd_en) && (!f_if.full) |=> (count == $past(count) + 1'b1);
endproperty

property count_down_check;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (!f_if.wr_en) && (f_if.rd_en) && (!f_if.empty) |=> (count == $past(count) - 1'b1);	
endproperty

property priority_check1;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en) && (f_if.rd_en) && (f_if.empty) |=> (count == $past(count) + 1'b1);
endproperty

property priority_check2;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en) && (f_if.rd_en) && (f_if.full) |=> (count == $past(count) - 1'b1);
endproperty

property wr_ptr_check;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en) && (count < FIFO_DEPTH) |=> (wr_ptr == $past(wr_ptr) + 1'b1);
endproperty

property rd_ptr_check;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.rd_en) && (count != 0) |=> (rd_ptr == $past(rd_ptr) + 1'b1);
endproperty


a1:assert property(reset_check);
a2:assert property(wr_ack_check);
a3:assert property(overflow_check);
a4:assert property(underflow_check);
a5:assert property(empty_check);
a6:assert property(full_check);
a7:assert property(almostfull_check);
a8:assert property(almostempty_check);
a9:assert property(wr_wrap_check);
a10:assert property(rd_wrap_check);
a11:assert property(wr_threshold_check);
a12:assert property(rd_threshold_check);
a13:assert property(count_threshold_check);
a14:assert property(count_up_check);
a15:assert property(count_down_check);
a16:assert property(priority_check1);
a17:assert property(priority_check2);
a18:assert property(wr_ptr_check);
a19:assert property(rd_ptr_check);


c1:cover property(reset_check);
c2:cover property(wr_ack_check);
c3:cover property(overflow_check);
c4:cover property(underflow_check);
c5:cover property(empty_check);
c6:cover property(full_check);
c7:cover property(almostfull_check);
c8:cover property(almostempty_check);
c9:cover property(wr_wrap_check);
c10:cover property(rd_wrap_check);
c11:cover property(wr_threshold_check);
c12:cover property(rd_threshold_check);
c13:cover property(count_threshold_check);
c14:cover property(count_up_check);
c15:cover property(count_down_check);
c16:cover property(priority_check1);
c17:cover property(priority_check2);
c18:cover property(wr_ptr_check);
c19:cover property(rd_ptr_check);
`endif

 always @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		wr_ptr <= 0;
        f_if.wr_ack   <= 0;
        f_if.overflow <= 0;
	end
	else if (f_if.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= f_if.data_in;
		f_if.wr_ack <= 1;
		if (wr_ptr == FIFO_DEPTH-1) begin
			wr_ptr <= 0;
		end
		else begin
		  wr_ptr <= wr_ptr + 1;
		end
		f_if.overflow <= 0;
	end
	else begin 
		f_if.wr_ack <= 0; 
		if (f_if.full == 1'b1 && f_if.wr_en == 1'b1)
			f_if.overflow <= 1;
		else
			f_if.overflow <= 0;
	end
end
always @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		rd_ptr <= 0;
		f_if.data_out <= 0;
	end
	else if (f_if.rd_en && count != 0) begin
		f_if.data_out <= mem[rd_ptr];
		if (rd_ptr == FIFO_DEPTH-1)
			rd_ptr <= 0;
		else	
		rd_ptr <= rd_ptr + 1;
	end
end
always @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({f_if.wr_en, f_if.rd_en} == 2'b10) && !f_if.full) 
			count <= count + 1;
		else if ( ({f_if.wr_en, f_if.rd_en} == 2'b01) && !f_if.empty)
			count <= count - 1;
		else if ({f_if.wr_en, f_if.rd_en} == 2'b11) begin
			if (f_if.empty) begin
				count <= count + 1;
			end else if(f_if.full) begin
				count <= count - 1;
			end
		end	
	end
end
always @(posedge f_if.clk or negedge f_if.rst_n) begin
  if (!f_if.rst_n)
    f_if.underflow <= 0;
  else if (f_if.rd_en && f_if.empty)
    f_if.underflow <= 1;   
  else
    f_if.underflow <= 0;
end
assign f_if.full = (count == FIFO_DEPTH)? 1 : 0;
assign f_if.empty = (count == 0)? 1 : 0; 
assign f_if.almostfull = (count == FIFO_DEPTH-1)? 1 : 0; 
assign f_if.almostempty = (count == 1)? 1 : 0;

endmodule

