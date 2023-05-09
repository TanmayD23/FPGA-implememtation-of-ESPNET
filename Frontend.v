module Frontend #(
                  // IA Module parameters
                  parameter IA_width = 17408,               // width of the output data given by the IA module
                  addr_width_ia = 11,                       // BRAM address width of IA RAM
                  
                  // mult_array parameters
                  product_width = 17408,                    // Width of the product output given by the multiplier                   
                  
                  // address_module parameters
                  col_out_width = 11*256,                   // width of col output from the address pipeline. The ectra bit is due to the sign bit
                  row_out_width = 10*256,                   // width of row output from the address pipeline. The extra bit is due to the sign bit
                  ch_out_width = 8*256,                     // width of ker output from the address pipeline
                  ram_address_width = 5,                    // width of the address given to the BRAM of address module
                  pool_width = 22,                          // width of the pool input
                  pool_out_width = 17,                      // width of the pool output 
                  wt_elem_addr_width = 60,                  // width of address of 4 elements
                  concat_width = 8*256,                     // width of the concat number for 1024 OAs   
                  
                  // wts rf parameters                 
                  bram_wts_width = 68,                      // Width of the wts data given by the wts BRAM.
                  
                  // wts BRAM parameters
                  wts_bram_addr_width = 4,                  // width of the address given to the weights BRAM
                  wts_bram_op_width = 128                   // width of the output given by the wts BRAM                                                                                                                                                                                                                                          
                  )
               (
                // General signals
                input clock,
                input reset,                      
                input [2:0]control_arbiter,                     // Control signal to all the arbiter                           
                
                // wts_bram signals
                input [wts_bram_addr_width-1:0]wts_bram_addr,   // address to the weights BRAM
                input enable_wts_rom,                           // enable signal for the wts ROM
                
                // IA_module signals
                input enable_IA_ram,                            // Enable signal to the IA BRAM 
                input [addr_width_ia-1:0]address_ia,            // Address to the IA BRAM
                
                // Pool signals
                input [pool_width-1:0]pool_in,
                input pool_enable,
                output [pool_out_width-1:0]avg_pool,
                output pool_done,
                
                // wts_rf signals
                input wts_rf_enable,
                
                // address rf controls
                input addr_rf_enable,
                input [2:0]addr_arbiter_ctrl,
                
                // multiplier array signals
                output [product_width-1:0]product,              // product output from the multiplier
                
                // address module signals                                         
                input addr_bram_enable,                         // enable signal for the address BRAM in the address module
                input [concat_width-1:0]concat_no,              // Concat number in case of concatnation                               
                input [ram_address_width-1:0]ram_address,       // address to the address BRAM in the address module
                output [row_out_width-1:0]row_out,              // row address of the OA
                output [col_out_width-1:0]col_out,              // col address of the OA
                output [ch_out_width-1:0]ch_out                 // ker address of the OA                                                                                                                                                                                                                                                                                                                                                                       
                );
                
    wire [IA_width-1:0]IA;      
    wire [bram_wts_width-1:0]rf_out; 
    
    wire [wt_elem_addr_width-1:0]wt_elem_addr;
    wire [bram_wts_width-1:0]bram_wts;
    
    wire [wts_bram_op_width-1:0]wts_bram_op;
    
    assign bram_wts = wts_bram_op[127:60];
    assign wt_elem_addr = wts_bram_op[59:0]; 
    
    assign weights = {{rf_out}};   
    
    IA_module IA_mod(
                 .reset(reset),
                 .clock(clock),
                 .control(control_arbiter),
                 .enable(enable_IA_ram),
                 .address(address_ia),
                 .IA_out(IA)
                 );           
                 
    avgPooling pool(
                    .clock(clock),
                    .input_data(pool_in),
                    .enable(pool_enable),
                    .avg_pool(avg_pool),
                    .avgPoolingDone(pool_done)
                    );                                         
                           
    multiplier_array mult_array(
                                .clock(clock),
                                .reset(reset),
                                .data_1(IA),
                                .data_2(rf_out),
                                .product(product)                        
                                );        
                        
    Addr_module address_mod(
                           .clock(clock),
                           .reset(reset),                                                                            
                           .ram_address(ram_address),
                           .addr_rf_enable(addr_rf_enable),
                           .arbiter_ctrl(addr_arbiter_ctrl),                                                    
                           .wts_rom_address(wt_elem_addr),
                           
                           .concat_no(concat_no),
                           .row_out(row_out),
                           .col_out(col_out),
                           .ch_out(ch_out),
                           
                           .addr_bram_enable(addr_bram_enable)                                    
                           );
                   
    Weights_rf Weights_rf(
                          .clock(clock),
                          .reset(reset),
                          .enable(wts_rf_enable),
                          .wts_in(bram_wts),
                          .wts_out(rf_out)
                          );                                             
                  
    blk_mem_gen_3 wts_bram(
                           .clka(clock),
                           .ena(enable_wts_rom),
                           .addra(wts_bram_addr),
                           .douta(wts_bram_op)
                           );                                                                                               
endmodule
