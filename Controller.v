module Control_System #(
                        parameter addr_width_ia = 11, 
                        wts_bram_addr_width = 4,
                        concat_width = 8*256,
                        ram_address_width = 5,
                        bk_arbiter_op_locations = 27*1360                                                                    
                        )
                     (                                            
                      input reset,
                      input p_clock,
                      input n_clock,
                      output sys_reset,
                      output clock,
                      
                      // Frontend controls
                      output [2:0]control_arbiter,
                      output [wts_bram_addr_width-1 :0]wts_bram_addr,
                      output enable_wts_rom,
                      output enable_wts_ram,
                      output [addr_width_ia-1:0]address_ia,
                      output wts_rf_enable,
                      output addr_rf_enable,
                      output [2:0]addr_arbiter_ctrl,
                      output addr_bram_enable,
                      output [concat_width-1:0]concat_no,
                      output [ram_address_width-1:0]ram_address,
                      input pool_done,
                      
                      // Backend controls
                      output adder_enable,
                      output [3:0]bk_arbiter_ctrl,
                      output accumulator_reset,
                      output accumulator_enable,
                      output accum_data_select,
                      output [bk_arbiter_op_locations-1:0]accum_data_mask                      
                      );
                      
    DDR_controller ddr_controller(
                                  .c0_ddr4_ui_clk(clock),
                                  .c0_ddr4_ui_clk_sync_rst(reset),
                                  .c0_init_calib_complete(c0_init_calib_complete),
                                  .c0_ddr4_app_addr(c0_ddr4_app_addr),
                                  .c0_ddr4_app_cmd(c0_ddr4_app_cmd),
                                  .c0_ddr4_app_en(c0_ddr4_app_en),
                                  .c0_ddr4_app_hi_pri(c0_ddr4_app_hi_pri),
                                  .c0_ddr4_app_wdf_data(c0_ddr4_app_wdf_data),
                                  .c0_ddr4_app_wdf_end(c0_ddr4_app_edf_end),
                                  .c0_ddr4_app_wdf_mask(c0_ddr4_app_wdf_mask),
                                  .c0_ddr4_app_wdf_wren(c0_ddr4_app_wdf_wren),
                                  .c0_ddr4_app_rd_data(c0_ddr4_app_rd_data),
                                  .c0_ddr4_app_rd_data_end(c0_ddr4_app_rd_data_end),
                                  .c0_ddr4_app_rd_data_valid(c0_ddr4_app_rd_data_valid),
                                  .c0_ddr4_app_rdy(c0_ddr4_app_rdy),
                                  .c0_ddr4_app_wdf_rdy(c0_ddr4_app_wdf_rdy)                                 
                                  );    
                                  
    Data_controller Data_controller(
                                    .control_arbiter(control_arbiter),                                    
                                    .wts_bram_addr(wts_bram_addr),
                                    .enable_wts_rom(enable_wts_rom),
                                    .enable_wts_ram(enable_wts_ram),                                    
                                    .wts_rf_enable(wts_rf_enable),
                                    .rf_enable(addr_rf_enable),
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
