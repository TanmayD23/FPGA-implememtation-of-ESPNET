module DDR_controller #(
                        // DDR parameters
                        parameter ddr4_address_width = 28,
                        ddr4_command_width = 3, 
                        ddr4_data_width = 576, 
                        ddr4_mask_width = 72,                        
                        ddr4_write = 1'b0,
                        ddr4_read = 1'b1,
                        ddr4_cmd_write = 3'd0,
                        ddr4_cmd_read = 3'd1,
                        bram_addr_width = 5,                        
                        
                        // internal signals
                        rw_count_width = 6,                                                     // Width of the counter which counts the number of reads and writes
                        fsm_state_width = 2,                                                    // Width of the fsm state register                                               
                        CBR_start = 3'd0,                                                       // State to indicate the start of the CBR
                        CBR = 3'd1,                                                             // State for the CBR block
                        DSB_start = 3'd2,                                                       // State to indicate the start of DSB
                        DSB = 2'd3,                                                             // State for the DSB block
                        DPRBB1_start = 3'd4,                                                    // State to indicate the start of DPRBB1
                        DPRBB1 = 3'd5,                                                          // State for the DPRBB block with 64 input and output
                        DPRBB2_start = 3'd6,                                                    // State to indicate the start of DPRBB2                         
                        DPRBB2 = 3'd7,                                                          // State for the DPRBB block with 128 input and output 
                        write = 1'b0,                                                           // Write state of the controller
                        read = 1'b1,                                                            // Read state of the controller
                        cmd_write = 3'd0,                                                       // Write command given to the DDR
                        cmd_read = 3'd1,                                                        // Read command given to the DDR   
                        
                        // FSM signals                                                                    
                        tile_count_width = 15,                                                  // Width of the tile count =er  
                        fsm_count_width = 5,                                                    // width of the register which keeps track of the number of times a stste is repeated
                        
                        // Frontend parameters
                        IA_width = 17*1024,                                                     // Width of thr output data given by the IA module
                        wts_bram_addr_width = 4,                                                // Width of the address given to the weights BRAM
                        fe_arbiter_ctrl_width = 3,                                              // Width of the frontend arbiter control signal
                        addr_width_IA = 5,                                                      // Width of the address given to the IA BRAMs (both address and data) 
                        concat_width = 8*256,                                                   // Width of the concat number for 256 OAs
                        
                        // Backend parameters
                        be_arbiter_ctrl_width = 4,                                              // Width of the backend arbiter control signal
                        accum_data_mask_width = 1360                                           // Width of the mask signal applied to the accumulator                                                                        
                        )
                      (
                      // DDR outputs to the system
                      input c0_ddr4_ui_clk,                                                     // clock from the DDR controller ip
                      input c0_ddr4_ui_clk_sync_rst,                                            // reset signel form the DDR contoroller ip
                      input c0_init_calib_complete,                                             // Signal that indicates thet the calibration is completed
                      
                      //DDR inputs from the DDR controller
                      output reg [ddr4_address_width-1:0]c0_ddr4_app_addr,                      // Address given to the DDR4 
                      output [ddr4_command_width-1:0]c0_ddr4_app_cmd,                           // COmmand given to the DDR$ 
                      output c0_ddr4_app_en,                                                    // 
                      output c0_ddr4_app_hi_pri,
                      output [ddr4_data_width-1:0]c0_ddr4_app_wdf_data,                         // Write data given to the DDR4 
                      output c0_ddr4_app_wdf_end,                                               // Write data end signal
                      output [ddr4_mask_width-1:0]c0_ddr4_app_wdf_mask,                         // Mask signal for the DDR4 
                      output c0_ddr4_app_wdf_wren,                                              // Write enable signal
                      
                      // DDR inputs to the DDR controller
                      input [ddr4_data_width-1:0]c0_ddr4_app_rd_data,                           // Read data form the DDR4
                      input c0_ddr4_app_rd_data_end,                                            // Read end signal from DDR4
                      input c0_ddr4_app_rd_data_valid,                                          // Read data valid signal from DDR4
                      input c0_ddr4_app_rdy,                                                    // it tells that the DDR4 is ready to accept commands
                      input c0_ddr4_app_wdf_rdy,  
                      
                      // Controls of read BRAM                      
                      output [ddr4_data_width-1:0]data_to_bram, 
                      output reg [bram_addr_width-1:0]bram_rd_addra,       
                      output reg [bram_addr_width-1:0]bram_rd_addrb,              
                      output bram_rd_ena,
                      output bram_rd_enb,
                      output bram_rd_wea, //
                      output bram_rd_web,
                      
                      // Controls of write BRAM
                      input [ddr4_data_width-1:0]data_to_ddr,
                      output reg [bram_addr_width-1:0]bram_wr_addra, 
                      output reg [bram_addr_width-1:0]bram_wr_addrb,
                      output bram_wr_ena, 
                      output bram_wr_enb,
                      output bram_wr_wea,
                      output bram_wr_web,                                                                                           
                      
                      // Frontend signals
                      output [fe_arbiter_ctrl_width-1:0]fe_arbiter_ctrl,                        // Signal to control the frontend arbiter (both data and address arbiters)
                      output [wts_bram_addr_width-1:0]wts_bram_addr,                            // Address for the weights ROM
                      output wts_rom_enable,                                                    // Enable signal for the wts ROM
                      output IA_ram_enable,                                                     // Enable signal for the IA BRAM (both data and address)
                      output [addr_width_IA-1:0]address_IA,                                     // Address given to the IA BRAM (Both data and address BRAMs)
                      output address_rf_enable,                                                 // Enable signal for the address register file
                      output [concat_width-1:0]concat_no,                                       // This signal is used ion case we are concatnating the OAs
                      
                      // Backend signals
                      output adder_enable,                                                      // Signal to enable the adder tree
                      output be_arbiter_ctrl,                                                   // Signal to control the backend arbiter                                   
                      output accum_reset,                                                       // SIgnal to reset the accumulator
                      output accum_enable,                                                      // Signal to enable the accumulator
                      output accum_data_select,                                                 // Signal to select between the data coming from the BRAM and that coming from the adder
                      output [accum_data_mask_width-1:0]accum_data_mask                         // Signal to mask the data coming from the BRAM to accumulator                                                                                                                                                                                                                                                                                                                                                                        
                      );      
                                                            
    reg [rw_count_width-1:0]rw_counter;                                                         // Register to count the number of read/write operations performed
    reg [tile_count_width-1:0]tile_counter;                                                     // Register to count the number of tiles done till now   
    reg [fsm_count_width-1:0]fsm_counter;                                                       // Register to oount the number of internal states of the FSM
        
    // Signals from the main controller
    reg [fsm_state_width-1:0]fsm_state;                                                         // Signal telling the controller about present fsm state
    reg [fsm_state_width-1:0]prev_state;                                                        // Register to store the previous state of the FSM
    reg [ddr4_address_width-1:0]start_address;                                                  // This signal tells the starting reading/writing address of the DDR4
    reg task_done;                                                                              // This signal tells the controller that the read/write task has been done
    reg stop;                                                                                   // This signal tells us when to stop reading/writing the DDR
    reg rw_state;                                                                               // Signal to tell the controller to read(1) or write(0)          
    
    reg [(ddr4_data_width*2)-1:0]bram_data_in;                                                  // Register to store the data coming from the DDR4 
    reg valid_wr_data;                                                                          // Register to store the valid signal from the DDR
    wire count_rst;                                                                             // Signal to reset the counter    
    
    reg change_state;                                                                           // Signal to change the state to next state        
    
    // DDR and BRAM signals
    assign c0_ddr4_app_en = (c0_init_calib_complete == 1'b1 && stop == 1'b0 && c0_ddr4_app_rdy == 1'b1);
    assign c0_ddr4_app_hi_pri = 1'b0;
    assign c0_ddr4_app_wdf_mask = {ddr4_mask_width{1'b0}};
    assign c0_ddr4_app_hi_pri = 1'b0;        
    assign c0_ddr4_app_wdf_data = data_to_ddr;
    assign c0_ddr4_app_wdf_wren = c0_ddr4_app_wdf_rdy == 1'b1 && bram_wr_ena;    
    assign c0_ddr4_app_wdf_end = c0_ddr4_app_wdf_rdy == 1'b1 && bram_wr_ena;        
    assign c0_ddr4_app_cmd = (rw_state == read) ? 3'd1:3'd0;
    
    
    assign rw_count_rst = (rw_counter == 4'd9 && rw_state == write) ? 1:0; // Originally there was no write
    assign bram_wr_ena = (rw_state == write) ? 1'b1:1'b0; // When we are in write state only then enable the write enable.
    
    assign bram_rd_wea = c0_ddr4_app_rd_data_end && c0_ddr4_app_rd_data_valid;
        
    always @(posedge c0_ddr4_ui_clk)
    begin
        if(c0_ddr4_ui_clk_sync_rst == 1'b1)
        begin
            fsm_state <= CBR;
            c0_ddr4_app_addr <= 28'd8;// This was origina{address_width{1'b0}};
            bram_rd_addra <= {bram_addr_width{1'b0}};
            bram_wr_addra <= {bram_addr_width{1'b0}};                                         
            bram_data_in <= {ddr4_data_width{1'b0}};
            rw_state <= write;
            rw_counter <= {rw_count_width{1'b0}};
            tile_counter <= {tile_count_width{1'b0}};
            fsm_counter <= {fsm_count_width{1'b0}};
            
            tile_counter <= 15'd0;
        end
        else 
        begin
            case({fsm_state,stop,change_state,rw_state})
                6'd0 :  begin                                                               // IN CBR start state when we are writing into thr DDR                            
                            rw_counter <= 6'd32; 
                            c0_ddr4_app_addr <= 28'd0;                                                
                        end
                6'd1 :  begin
                                                                                                                                                
                        end                      
                
            endcase
        end
    end
    
endmodule

