module IA_module #(
                        parameter data_width = 4352*4,                        
                        arbiter_op_width = 4352,
                        address_width = 5
                        )
                       (
                        // general signals
                        input reset,
                        input clock,
                        
                        // BRAM signals                        
                        input enable,
                        input [address_width-1:0]address,                        
                        output [data_width-1:0]IA_out,
                        
                        // Arbiter signals
                        input [2:0]control
                    );
    wire [arbiter_op_width-1:0]op[3:0];
    wire [arbiter_op_width-1:0]data; 
    wire [data_width-1:0]input_act;    
                                     
                                         
    assign IA_out = {op[0],op[1],op[2],op[3]};
    
    blk_mem_gen_0 blk_ram(
                          .clka(clock),
                          .addra(address),
                          .douta(data),
                          .ena(enable)
                          );
    
    arbiter arb(
                .reset(reset),
                .clock(clock),
                .data(data),
                .control(control),
                .op_1(op[0]),
                .op_2(op[1]),
                .op_3(op[2]),
                .op_4(op[3])
                );                                                                
endmodule
