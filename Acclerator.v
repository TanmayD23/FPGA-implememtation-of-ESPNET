module Acclerator #(
                    parameter product_width = 17408,
                    row_out_width = 11*256, 
                    col_out_width = 10*256,
                    ch_out_width = 8*256,
                    concat_width = 8*256,
                    ram_address_width = 5,
                    wts_bram_addr_width = 4,
                    accum_data_mask_width = 1360,
                    pool_width = 17,
                    bk_bram_data_width = 44*1360,
                    bk_row_in_width = 2560,
                    bk_col_in_width = 2816,
                    bk_ch_in_width = 2048,                    
                    addr_width_ia = 11              
                    )
                   (
                    input reset,
                    input clock                                  
                    );
                    
    wire [2:0]addr_arbiter_ctrl;
    wire [addr_width_ia-1:0]address_ia;    
    wire [concat_width-1:0]concat_no;
    wire [2:0]control_arbiter;
    wire [ram_address_width-1:0]ram_address;                  
    wire [wts_bram_addr_width-1:0]wts_bram_addr; 
    wire [accum_data_mask_width-1:0]accum_data_mask;
    wire [4:0]bk_arbiter_ctrl;
    wire [bk_bram_data_width-1:0]bk_bram_data_in;
    wire [pool_width-1:0]avg_pool;
    wire [bk_row_in_width-1:0]row_out; 
    wire [bk_col_in_width-1:0]col_out; 
    wire [bk_ch_in_width-1:0]ch_out; 
    wire [product_width-1:0]product;
                    
    Frontend frontend(
                      .clock(clock),
                      .reset(reset),
                      .control_arbiter(control_arbiter),
                      .wts_bram_addr(wts_bram_addr),
                      .enable_wts_rom(enable_wts_rom),
                      .enable_IA_ram(enable_wts_ram),
                      .address_ia(address_ia),
                      .wts_rf_enable(wts_rf_enable),
                      .addr_rf_enable(addr_rf_enable),
                      .addr_arbiter_ctrl(addr_arbiter_ctrl),
                      .product(product),
                      .addr_bram_enable(addr_bram_enable),
                      .concat_no(concat_no),
                      .ram_address(ram_address),
                      .avg_pool(avg_pool),
                      .pool_done(pool_done),
                      .row_out(row_out),
                      .col_out(col_out),
                      .ch_out(ch_out)
                      );             
                      
    Backend backend(
                    .clock(clock),
                    .reset(reset),
                    .products(product),
                    .adder_enable(adder_enable),
                    .row_in(row_out),
                    .col_in(col_out),
                    .ch_in(ch_out),
                    .arbiter_ctrl(bk_arbiter_ctrl),
                    .accumulator_reset(accumulator_reset),
                    .accumulator_enable(accumulator_enable),
                    .bram_data_in(bk_bram_data_in),
                    .avg_pool(avg_pool),
                    .accum_data_select(accum_data_select),
                    .accum_data_mask(accum_data_mask),
                    .accum_data_out(accum_data_out) 
                    );                             
                    
    Control_System Control_system(
                                   .clock(clock),
                                   .reset(reset),
                                   .control_arbiter(control_arbiter),
                                   .wts_bram_addr(wts_bram_addr),
                                   .enable_wts_rom(enable_wts_rom),
                                   .enable_wts_ram(enable_wts_ram),
                                   .address_ia(address_ia),
                                   .wts_rf_enable(wts_rf_enable),
                                   .addr_rf_enable(addr_rf_enable),
                                   .addr_arbiter_ctrl(addr_arbiter_ctrl),
                                   .addr_bram_enable(addr_bram_enable),
                                   .concat_no(concat_no),
                                   .pool_done(pool_done),
                                   .ram_address(ram_address),
                                   .adder_enable(adder_enable),
                                   .bk_arbiter_ctrl(bk_arbiter_ctrl),
                                   .accumulator_reset(accumulator_reset),
                                   .accumulator_enable(accumulator_enable),
                                   .accum_data_select(accum_data_select),
                                   .accum_data_mask(accum_data_mask)
                                   );                                                                                           
                    
endmodule
