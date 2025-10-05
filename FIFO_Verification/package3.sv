package FIFO_scoreboard_pkg;
  import shared_pkg::*;
  import FIFO_transaction_pkg::*;

  class FIFO_scoreboard;

    bit [FIFO_WIDTH-1:0] data_out_ref;
    reg [3:0] size;
    logic [FIFO_WIDTH-1:0] fifo_mem[$];                            
    int count = 0;
    function new();
      error_count   = 0;
      correct_count = 0;
    endfunction

    task check_data(FIFO_transaction F_txn);
      reference_model(F_txn);
      if (F_txn.data_out == data_out_ref) begin
        correct_count++;
      end else begin
        $display("[WRONG] data_out mismatch at %0t: DUT=%h REF=%h", 
                  $time, F_txn.data_out, data_out_ref);
        error_count++;
      end

    endtask

    task reference_model(FIFO_transaction F_txn);
       size = fifo_mem.size();
      if(!F_txn.rst_n) begin
        data_out_ref = 0;
        fifo_mem.delete(); 
        size = fifo_mem.size();  
      end
      else begin
        size = fifo_mem.size();
        case ({F_txn.wr_en,F_txn.rd_en})
        2'b10: begin
           if (size != 8) begin
            fifo_mem.push_back(F_txn.data_in);
            data_out_ref = data_out_ref;
      end
    end

    // Read only
    2'b01: begin
      if (size != 0) begin
        data_out_ref = fifo_mem.pop_front();
      end
    end

    // Read + Write simultaneously
    2'b11: begin
      if (size == 0) begin
        fifo_mem.push_back(F_txn.data_in);
      end
      else if (size == 8) begin
        data_out_ref = fifo_mem.pop_front();
      end
      else begin
        data_out_ref = fifo_mem.pop_front();
        fifo_mem.push_back(F_txn.data_in);
      end
    end

   endcase
      end
    endtask

  endclass

endpackage
