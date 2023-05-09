module Accumulator #(
                     parameter data_in_width = 1360*17,                         // width of the input data
                     data_out_width = 1360*(17+27),                             // width of the data given to the BRAM
                     address_in_width = 1360*27,                                // width of input address
                     stored_data_width = 44,                                    // width of one single stored data, it is data + address
                     data_locations = 1360,                                     // number of different data locations present
                     data_width = 17,                                           // width of one single data element
                     address_width = 27                                         // width of one sinhle addres element                     
                     )
                    (
                     input clock,
                     input reset,
                     input accumulator_reset,                                   // Special reset signal for the accumulator to make the register file 0
                     input enable,
                     input [data_in_width-1:0]data_in,                          // data input from the arbiter
                     input [address_in_width-1:0]address_in,                    // address input from the arbiter
                     input [data_locations-1:0]valid,                           // valid input from the arbiter telling whether the input is valid or not
                     input [data_out_width-1:0]bram_data_in,                     // Data from the BRAM
                     input data_select,                                         // Input to select data from the BRAM and arbiter 
                     input [data_locations-1:0]data_mask,                       // input to mask certain data locataions from the data coming from the BRAM                                  
                     output [data_out_width-1:0]data_out                         // data given to the BRAM                                             
                     );
                     
    integer j;
    genvar i;                     
                     
    reg [stored_data_width-1:0]stored_data[data_locations-1:0];
    wire [data_width-1:0]adder_in[data_locations-1:0];                                           // wires giving the input to the accumulator adder    
    wire [data_width-1:0]reg_adder_in[data_locations-1:0];                                       // wires giving the stored data to the adder
    
    wire [data_width-1:0]adder_out[data_locations-1:0];                                          // Wires giving the data from the adder to the register               
    
    generate
        for(i=0;i<data_locations;i=i+1)
        begin
            assign reg_adder_in[i] = stored_data[i][(stored_data_width-1)-:data_width];
            assign adder_in[i] = data_in[(data_width*i)+:data_width];
        
            Accum_adder Accum_adder(
                                    .enable(enable),
                                    .data_1(adder_in[i]),
                                    .data_2(reg_adder_in[i]),
                                    .sum(adder_out[i])
                                    );
                                    
            assign data_out[(stored_data_width*i)+:stored_data_width] = stored_data[i];                                    
        end        
    endgenerate
                                                 
    always @(posedge clock)
    begin
        if(reset == 1'b1 || accumulator_reset == 1'b1)
        begin
            for(j=0;j<data_locations;j=j+1)
            begin
                stored_data[j] <= {stored_data_width{1'b0}};                
            end
        end
        else if(enable == 1'b1)
        begin 
            for(j=0;j<data_locations;j=j+1)
            begin
                case({data_select,(data_mask[j] && valid[j])})
                2'd0 :  begin
                            stored_data[j][(stored_data_width-1)-:data_width] <= stored_data[j][(stored_data_width-1)-:data_width];
                            stored_data[j][0+:address_width] <= stored_data[j][0+:address_width];  
                        end
                
                2'd1 :  begin
                            stored_data[j][(stored_data_width-1)-:data_width] <= adder_out[j];
                            stored_data[j][0+:address_width] <= address_in[(address_width*j)+:address_width];
                        end
                        
                2'd2 :  begin
                            stored_data[j][(stored_data_width-1)-:data_width] <= stored_data[j][(stored_data_width-1)-:data_width];
                            stored_data[j][0+:address_width] <= stored_data[j][0+:address_width]; 
                        end
                        
                2'd3 :  begin
                            stored_data[j] <= bram_data_in[(stored_data_width*j)+:stored_data_width];
                        end                             
                endcase                                 
            end                                                                      //                                                                      
        end
        else
        begin
            for(j=0;j<data_locations;j=j+1)
            begin
                stored_data[j] <= stored_data[j];
            end
        end   
    end                         
                     
endmodule
