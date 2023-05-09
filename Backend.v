module Backend #(
                 parameter product_width = 17,                          // width of 1 product     
                 data_width = 17*1024,                                  // width of the products given by the multiplier            
                 sum_width = 17*256,                                    // width of 256 sums that are given by the adder tree   
                 arbiter_out_width = 17*1360,                           // width of the output given by the arbiter      
                 ddr_width = 8*27,
                 
                 // Address parameters                                                          
                 col_in_width = 11*256,                                // Width of the row address of all the elements
                 row_in_width = 10*256,                                // Width of the col address of all the elements                 
                 ch_in_width = 8*256,                                  // Width of the channel address of all the elements
                 row_width = 10,                                        // Width of one single row address
                 col_width = 11,                                        // Width of one single col address
                 ch_width = 8,                                          // Width of one single channel address
                 
                 // register filr parameters
                 rf_row_width = 10*256,                                 // Width of the row address given to the rf module
                 rf_col_width = 11*256,                                 // Width of the row address given to the rf module
                 rf_ch_width = 8*256,                                  // Width of the row address given to the rf module                                  
                 
                 // Arbiter parameters
                 arbiter_op_locations = 1360,                           // Number of locations to which the arbiter sends data
                 arbiter_addr_out_width = 27*1360,                      // width of the address given out by the arbiter
                 
                 // Accumulator parameters
                 bram_data_width = 44*1360,                             // width of the data givwn from the BRAM to the acucmulator
                 pool_width = 17                                            
                 )
                (                
                 // General signals
                 input clock,                               
                 input reset,
                 input [data_width-1:0]products,                                
                 
                 // Adder tree signals
                 input adder_enable,    
                 
                 // Address RF signals
                 input [row_in_width-1:0]row_in,
                 input [col_in_width-1:0]col_in,
                 input [ch_in_width-1:0]ch_in,
                 
                 // Backend_arbiter signals
                 input [3:0]arbiter_ctrl,                                       // Signal to direct the outputs of arbiter                                  
                 
                 // Accumulator signals
                 input accumulator_reset,
                 input accumulator_enable,
                 input [bram_data_width-1:0]bram_data_in,   
                 input accum_data_select,                                       // Signal to select the data between BRAM and the input data
                 input [pool_width-1:0]avg_pool,
                 input [arbiter_op_locations-1:0]accum_data_mask,               // Signal to mask the data coming from the BRAM
                 output [bram_data_width-1:0]accum_data_out, 
                 output [ddr_width-1:0]ddr_data                                                                                                                                                 
                 );     
                 
    wire [sum_width-1:0]arbiter_data_in;                    // Wires connecting the output of the adder to the backend arbiter    
    wire [arbiter_out_width-1:0]arbiter_out;                // Wires connecting to the accumulator 
           
    wire [arbiter_addr_out_width-1:0]arbiter_address_out;   // Wires carrying the address from the arbiter to the accumulator
    wire [arbiter_op_locations-1:0]addr_valid;              // Wires carrying the valid from the arbiter to the accumulator
    
    wire [rf_row_width-1:0]rf_row_out;                      // Wires connecting the row address of the register file to the backend arbiter module
    wire [rf_col_width-1:0]rf_col_out;                      // Wires connecting the col address of the register file to the backend arbiter module
    wire [rf_ch_width-1:0]rf_ch_out;                        // Wires connecting the ch address of the register file to the backend arbiter module                                                    
    
    adder_tree_4 adder_tree(
                            .clock(clock),
                            .reset(reset),
                            .enable(adder_enable),
                            .data_in(products),
                            .sum_4(arbiter_data_in)
                            );                                                                                         
                            
    address_rf address_rf(
                          .clock(clock),
                          .reset(reset),
                          .row_in(row_in),
                          .col_in(col_in),
                          .ch_in(ch_in),
                          .row_out(rf_row_out),
                          .col_out(rf_col_out),
                          .ch_out(rf_ch_out)
                          );                                                                                                                        
                 
    Backend_arbiter Backend_arbiter(
                                    .clock(clock),
                                    .reset(reset),
                                    .ctrl(arbiter_ctrl),
                                    .products(arbiter_data_in),
                                    .out(arbiter_out),
                                    .row_in(rf_row_out),
                                    .col_in(rf_col_out),
                                    .ch_in(rf_ch_out),
                                    .valid(addr_valid),
                                    .address_out(arbiter_address_out)
                                    );       
                                    
    Accumulator Accumulator(
                            .clock(clock),
                            .reset(reset),
                            .accumulator_reset(accumulator_reset),
                            .enable(accumulator_enable),
                            .data_in(arbiter_out),
                            .address_in(arbiter_address_out),
                            .valid(addr_valid),
                            .bram_data_in(bram_data_in),
                            .data_select(accum_data_select),
                            .data_mask(accum_data_mask),
                            .data_out(accum_data_out)
                            );                                                  
                 
endmodule
