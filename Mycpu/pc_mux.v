module pc_mux(
    input  wire jumpM,
    input  wire jalM,
    input  wire jrM,
    input  wire pcsrcM,
    input  wire[31:0] excepttypeM,
    input  wire[31:0] pc_next_jump,
    input  wire[31:0] pc_next_jr,
    input  wire[31:0] pc_plus4F,
    input  wire[31:0] pc_branchM,
    input  wire[31:0] newpcM,
    output wire [31:0] pc_next
);
    assign pc_next = (|excepttypeM) ? newpcM :  // 注意优先级依次降低
                     jrM            ? pc_next_jr:
                     (jumpM|jalM)   ? pc_next_jump :
                     pcsrcM         ? pc_branchM : 
                                      pc_plus4F;
endmodule