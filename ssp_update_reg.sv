module ssp_update_unit import ariane_pkg::*; (
    input  logic                     clk_i,    // Clock
    input  logic                     rst_ni,  // Asynchronous reset active low
    //input  xlen_t                    data_in, //ssp
    input  logic                     en, //lsu_ctrl_i.is_ss_op
    input  logic                     st_valid_i,
    input  logic                     ld_valid_i,
    output xlen_t                    data_out, //ssp
    input lsu_ctrl_t                 lsu_ctrl_i // control

);

lsu_ctrl_t lsu_ctrl_d,lsu_ctrl_q;
xlen_t ssp_q;
assign lsu_ctrl_d = lsu_ctrl_q;

always_comb begin: is_ssp_op
        if(st_valid_i || ld_valid_i) begin
        unique case(lsu_ctrl_q.operator)
                SSPOP_X1: ssp_q = ssp_q + (riscv::XLEN/8);
                SSPOP_X5: ssp_q = ssp_q + (riscv::XLEN/8);
                SSPOPCHK_X1: ssp_q = ssp_q + (riscv::XLEN/8);
                SSPOPCHK_X5: ssp_q = ssp_q + (riscv::XLEN/8);
                SSAMOSWAP: ssp_q = ssp_q - (riscv::XLEN/8);
                SSPRR: ssp_q = ssp_q; //+ (riscv::XLEN/8);
                SSPUSH_X1: ssp_q = ssp_q - (riscv::XLEN/8);
                SSPUSH_X5: ssp_q = ssp_q - (riscv::XLEN/8);
                default: ;
            endcase
        end
    
end

always_ff @(posedge clk_i or negedge rst_ni) begin
            if (~rst_ni) begin
               data_out <= '0;
               lsu_ctrl_q <= '0;
               ssp_q <= '0;
            end else 
            if(en) begin              
               lsu_ctrl_q <= lsu_ctrl_d;
            end 
            data_out <= ssp_q; //ssp
        end
endmodule