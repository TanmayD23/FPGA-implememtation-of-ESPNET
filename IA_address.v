module IA_address #(
                    // Row arbiter parameters
                    parameter row_addr_width = 2304*4,      // Width of the total data output of row arbiter
                    row_arbiter_width = 2304,               // Width of the data received by the row arbiter
                    
                    // Col arbiter parameters
                    col_arbiter_width = 2560,               // Width of the data received by the col arbiter
                    col_addr_width = 2560*4,                // Width of the total data output of col arbiter                                     
                    
                    // BRAM parameters                                                                                                  
                    ram_address_width = 5                   // As the depth is only of 32 data
                    )
                   (
                    // General signals
                    input clock,
                    input reset,
                    
                    // BRAM signals
                    input addr_bram_enable,                     // Enable signal for the row and col BRAM 
                    input [ram_address_width-1:0]ram_address,   // Address width for the row and col BRAM
                    output [row_addr_width-1:0]row_addr_out,    // Width of the col data from BRAM
                    output [col_addr_width-1:0]col_addr_out,    // Width of the row data from BRAM                    
                    
                    // Arbiter signals
                    input [2:0]arbiter_ctrl                    // Control signal to the arbiter                                                            
                    );        
    
    // Wire connecting the ram to arbiter
    wire [row_arbiter_width-1:0]row_arb_in;
    wire [col_arbiter_width-1:0]col_arb_in;
    
    blk_mem_gen_1 addr_row_ram(
                               .clka(clock),
                               .addra(ram_address),
                               .douta(row_arb_in),
                               .ena(addr_bram_enable)
                               );            
                               
    blk_mem_gen_2 addr_col_ram(
                               .clka(clock),
                               .addra(ram_address),
                               .douta(col_arb_in),
                               .ena(addr_bram_enable)
                               );    
    
    row_arbiter row_arbiter(
                            .clock(clock),
                            .reset(reset),
                            .row_addr_in(row_arb_in),
                            .control(arbiter_ctrl),
                            .row_addr_1(row_addr_out[((3*row_arbiter_width)-1)+:row_arbiter_width]),
                            .row_addr_2(row_addr_out[((2*row_arbiter_width)-1)+:row_arbiter_width]),
                            .row_addr_3(row_addr_out[(row_arbiter_width-1)+:row_arbiter_width]),
                            .row_addr_4(row_addr_out[0+:row_arbiter_width])                
                            );
                
    col_arbiter col_arbiter(
                            .clock(clock),
                            .reset(reset),
                            .col_addr_in(col_arb_in),
                            .control(arbiter_ctrl),
                            .col_addr_1(col_addr_out[((3*col_arbiter_width)-1)+:col_arbiter_width]),
                            .col_addr_2(col_addr_out[((2*col_arbiter_width)-1)+:col_arbiter_width]),
                            .col_addr_3(col_addr_out[(col_arbiter_width-1)+:col_arbiter_width]),
                            .col_addr_4(col_addr_out[0+:col_arbiter_width])                
                            );                
    
endmodule
