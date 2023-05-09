module Data_controller #(
                         parameter wts_bram_addr_width = 4,
                         apool_doner_width_ia = 11,
                         concat_width = 8*256,
                         ram_address_width = 5,
                         bk_arbiter_op_locations = 27*1360                                                  
                         )
                         (
                       // Frontend controls
                      output [2:0]control_arbiter,
                      output [wts_bram_addr_width-1 :0]wts_bram_addr,
                      output enable_wts_rom,
                      output enable_wts_ram,                      
                      output [apool_doner_width_ia-1:0]apool_doneress_ia,
                      output wts_rf_enable,
                      output reg rf_enable,
                      output [2:0]addr_arbiter_ctrl,
                      output addr_bram_enable,
                      output [concat_width-1:0]concat_no,
                      output [ram_address_width-1:0]ram_address,
                      input pool_done,
                      input reset,
                      input clock,
                      
                      // Backend controls
                      output reg adder_enable,
                      output [3:0]bk_arbiter_ctrl,
                      output accumulator_reset,
                      output accumulator_enable,
                      output accum_data_select,
                      output [bk_arbiter_op_locations-1:0]accum_data_mask
                       );
                            
 reg [2:0]p_state;
 reg[2:0] stop;
 reg [1:0] k=2'd0;
 reg ign, pd;
 reg [1:0]st;
 reg ck;
 always@(posedge clock)
 begin
   if(reset==1'b1)
     k=2'd0;
   if(stop==1'b1)
   begin
     k=k+2'd1;
     if(k==2'd2)
     begin
       k=2'd0;
       rf_enable=1'b1;     
     end
   end 
   else if(stop==1'b0)
   begin
     k=1'd0;
     rf_enable=1'b0;   
   end
   if(p_state==3'd0)
   begin
    rf_enable<=ck;
   end 
   if(reset==1'b1)
   begin
     p_state<=3'd0;
     st<=2'dz;
     stop<=1'b0;
   end
   if(p_state==3'd0)
    begin
     if((pool_done==1'b1 | pd==1'b1) & ign==1'b0)
     begin
       stop<=1'b1;
       stop<=1'b0;
       if(pool_done==1'b1 & pd==1'b0)
       st<=2'd1;
       else if(pd==1'b1)
       st<=2'd2;
       p_state<= 3'd4;
     end
     else if(ign==1'b1)
     begin
       stop<=1'b0;
       st<=2'dz;
       rf_enable<=1'b0;
       stop<=1'b0;
       p_state<=3'd2;
     end
    end
    else if(p_state==3'd1) 
    begin
      if(pool_done==1'b0 & pd==1'b0 & ign==1'b0 & stop==1'b1 & reset==1'b1)
      begin
       stop<=1'b0;
       st<=2'dz;
       stop<=1'b0;
       rf_enable<=ck;
       p_state<=3'd0;
      end
      else if(ign==1'b1)
      begin
       stop<=1'b0;
       st<=2'bz;
       rf_enable<=1'b0;
       stop<=1'b0;
       p_state<=3'd2;
      end
      else if((pool_done==1'b1 | pd==1'b1) & ign==1'b0 & stop==1'b1)
      begin
       stop<=1'b0;
       st<=2'bz;
       rf_enable<=1'b1;
       stop<=1'b1;
       p_state<=3'd5;
      end 
    end
    else if(p_state==3'd2) 
    begin
      if(pool_done==1'b0 & pd==1'b0 & ign==1'b0 & stop==1'b0)
      begin
       stop<=1'b1;
       st<=2'd0;
       rf_enable<=1'b1;
       stop<=1'b0;
       p_state<=3'd7; 
      end
      else if((pool_done==1'b1 | pd==1'b1) & ign==1'b0 & stop==1'b0)
      begin
       stop<=1'b0;
       st<=2'dz;
       rf_enable<=1'b0;
       stop<=1'b0;
       p_state<=3'd4;
     end
    end
    else if(p_state==3'd4) 
    begin
      if(ign==1'b1)
      begin   
       stop<=1'b0;
       st<=2'dz;
       rf_enable<=1'b0;
       stop<=1'b0;
       p_state<=3'd2;
      end
      else if((pool_done==1'b1 | pd==1'b1) & ign==1'b0 & stop==1'b0)
      begin
       stop<=1'b0;
       st<=1'bz;
       rf_enable<=1'b1;
       stop<=1'b1;
       p_state<=3'd5;
      end
      else if(pool_done==1'b0 & pd==1'b0 & ign==1'b0 & stop==1'b0  & rf_enable==1'b0)
      begin
       stop<=1'b1;
       st<=2'd0;
       rf_enable<=1'b1;
       stop<=1'b0;
       p_state<=3'd7;
      end
      else if(pool_done==1'b0 & pd==1'b0 & ign==1'b0 & stop==1'b0 & rf_enable==1'b1)
      begin
        stop<=1'b0;
        stop<=1'b0;
        st<=2'dz;
        rf_enable<=ck;
        p_state<=3'd0;
      end
    end
    else if(p_state==3'd5) 
    begin
     if(ign==1'b1)
     begin
       stop<=1'b0;
       st<=2'bz;
       rf_enable<=1'b0;
       stop<=1'b0;
       p_state<=3'd2;
     end
      else if(pool_done==1'b0 & pd==1'b0 & ign==1'b0  & stop==1'b1)
      begin
       stop<=1'b1;
       st<=2'd3;
       rf_enable<=1'b1;
       stop<=1'b1;
       p_state<=3'd1;
      end
    end
    else if(p_state==3'd7) 
    begin
      if(pool_done==1'b0 & pd==1'b0 & ign==1'b0 & stop==1'b0)
      begin
       stop<=1'b0;
       stop<=1'b0;
       st<=2'dz;
       rf_enable<=ck;
       p_state<=3'd0;
      end
      else if((pool_done==1'b1 | pd==1'b1) & ign==1'b0 & stop==1'b0)
      begin
       stop=1'b0;
       rf_enable<=1'b0;
       st<=2'dz;
       stop<=1'b0;
       p_state<=3'd4;
      end
      else if(ign==1'b1)
      begin
       stop<=1'b0;
       rf_enable<=1'b0;
       st<=2'dz;
       stop<=1'b0;
       p_state<=3'd2;
      end
    end
  end
endmodule
