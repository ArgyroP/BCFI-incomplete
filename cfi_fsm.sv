
module fsm(
    input logic         clk_i,
    input logic         rst_ni,
    output logic        elp_init,
    input logic [31:0]  instr,
    output logic        ex
    );
    
    logic telp_init,tex;
    localparam NO_LP_EXPECTED = 2'b00, LP_EXPECTED = 2'b01, ILLEGAL_INSTR_STATE = 2'b10;
    
    reg[1:0] state, nextstate;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        state <= NO_LP_EXPECTED; // Initial state
        telp_init <= 1'b0;
        tex <= 1'b0;
      end else begin
        state <= nextstate;
      end
    end

    always_comb begin : cfi_fsm
      nextstate = state; // Default next state: don't move
      
      case (state)
      NO_LP_EXPECTED : begin
          if(instr[6:0] == riscv::OpcodeJalr && 
           (instr[11:7]==5'd1 || instr[11:7]==5'd5))begin //catch indirect jump
                 telp_init =1'b1; // goes to csr_regfile to update csr_elp
                 nextstate = LP_EXPECTED;   
                 tex = 1'b0;
           end else nextstate = state;  
      end
      LP_EXPECTED : begin          
          if(instr[6:0] == riscv::OpcodeOpImm && instr[31:24] == 8'b10000011
             && instr[14:7] == 8'b10000000) begin //lpcll instruction
                telp_init = 1'b0;
                tex = 1'b0;
                $display("INSTR : %0b",instr);
                nextstate = NO_LP_EXPECTED; // update elp csr
             end else nextstate = ILLEGAL_INSTR_STATE;
      end
      ILLEGAL_INSTR_STATE: begin
          tex = 1'b1;
          telp_init =1'b1; //stays as it is
          nextstate = state;
          //$display("ILLEGAL INSTRUCTION STATE");
      end
      //default: nextstate = NO_LP_EXPECTED;
      endcase

     
     //$display("nextstate: %0h",nextstate);
    end

assign elp_init = telp_init;
assign ex = tex;

endmodule
