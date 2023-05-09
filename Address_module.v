module Addr_module #(
                     // IA address parameters
                     parameter ram_address_width = 5,   // width of address given to the row ans col BRAMs
                     col_addr_width = 10240,            // width of the col address given by row_ram
                     row_addr_width = 9216,             // width of the row address given by col_ram                     
                     
                     // address array parameters
                     col_out_width = 11*256,            // width of the OA row address
                     row_out_width = 10*256,            // width of the OA col address
                     ch_out_width = 8*356,              // width of the OA ch address
                     concat_width = 8*256,              // width of the concat number for 1024 different elements                     
                     wts_rom_address_width = 60,        // width of the address section of the output given by the wts ROM                  
                     
                     // address rf parameters     
                     addr_row_width = 20,                // width of the row address of an element  
                     addr_col_width = 20,                // width of the col address of an element
                     addr_ker_width = 20                // width of the ker address of an element                                                                                                                                                                                                                                                               
                     )
                    (
                     // general signals
                     input clock,
                     input reset,         
                     
                     // IA address sigals  
                     input [2:0]arbiter_ctrl,                                           // control signal for thr arbiter in IA address module
                     input [ram_address_width-1:0]ram_address,                          // address to the BRAM in IA address module
                     input addr_bram_enable,                                            // enable signal for the BRAM in IA address module
                     
                     // Address register file inputs  
                     input addr_rf_enable,                                                   // Input to enable the register files
                     input [wts_rom_address_width-1:0]wts_rom_address,                  // input address for the register file                                                             
                                
                     // address array signals           
                     input [concat_width-1:0]concat_no,                                 // concat number
                     output [row_out_width-1:0]row_out,                                 // row address of the OA
                     output [col_out_width-1:0]col_out,                                 // col address of the OA
                     output [ch_out_width-1:0]ch_out                                    // kwr address of the OA
                     );     
                     
    wire [row_addr_width-1:0]row_addr_connector;           // Wire connecting IA_address to the row_arbiter    
    wire [col_addr_width-1:0]col_addr_connector;           // Wire connecting IA_address to the col_arbiter
    
    wire [addr_row_width-1:0]wts_row;                      // Wires connecting the row register file to the address array                                                         
    wire [addr_col_width-1:0]wts_col;                      // Wires connecting the col register file to the address array                                                               
    wire [addr_ker_width-1:0]wts_ker;                      // Wires connecting the ker register file to the address array                                                              
                         
    IA_address IA_address(
               .clock(clock),
               .reset(reset),
               .arbiter_ctrl(arbiter_ctrl),
               .ram_address(ram_address),
               .row_addr_out(row_addr_connector),
               .col_addr_out(col_addr_connector),
               .addr_bram_enable(addr_bram_enable)
               );                        
               
    Addr_reg_file Addr_reg_file(
                                .clock(clock),
                                .reset(reset),
                                .enable(addr_rf_enable),
                                .row_in(wts_rom_address[(addr_row_width+addr_ker_width)+:addr_row_width]),
                                .col_in(wts_rom_address[addr_ker_width+:addr_col_width]),
                                .ker_in(wts_rom_address[0+:addr_ker_width]),
                                .row_out(wts_row),
                                .col_out(wts_col),
                                .ker_out(wts_ker)
                                );                                                   
                          
    address_array address_array(
                  .clock(clock),
                  .reset(reset),
                  .ia_row(row_addr_connector),
                  .ia_col(col_addr_connector),
                  .wt_row(wts_row),
                  .wt_col(wts_col),
                  .wt_ker(wts_ker),
                  .concat_no(concat_no),
                  .new_ia_row(row_out),                  
                  .new_ia_col(col_out),                  
                  .new_ia_ch(ch_out)                  
                  );                              
                         
//    addr_pipeline address_pipe(
//                  .clock(clock),
//                  .reset(reset),
//                  .enable(enable_addr_pip),
//                  .control_1(wts_address_pip_ctrl),
//                  .row_in(wts_rom_address[(addr_row_width+addr_ker_width)+:addr_row_width]),
//                  .col_in(wts_rom_address[addr_ker_width+:addr_col_width]),
//                  .ker_in(wts_rom_address[0+:addr_ker_width]),
//                  .row_out(pip_row_out),                  
//                  .col_out(pip_col_out),                  
//                  .ker_out(pip_ker_out)                 
//                  );
                                                                                           
endmodule
