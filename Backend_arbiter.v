module Backend_arbiter #(
                         parameter data_in_width = 256*17,                  // Width of the data thet is coming in
                         product_width = 17,                                // Width of one product element                         
                         output_locations = 1360,                           // Number of different locations possible for the products
                         output_width = 1360*17,                            // Number of output wires = number of output locaions*width of one product 
                         inp_no = 256,                                      // Number of input products                                             
                         
                         // Address parameters          
                         col_len = 32,                                      // Length of the tile taken   
                         col_in_width = 11*256,                             // Width of the row address of all the elements
                         row_in_width = 10*256,                             // Width of the col address of all the elements
                         ch_in_width = 8*256,                               // Width of the channel address of all the elements
                         row_width = 10,                                    // Width of one single row address
                         col_width = 11,                                    // Width of one single col address
                         ch_width = 8,                                      // Width of one single channel address
                         address_width = 27,                                // Width of one single address                         
                         address_out_width = 27*1360                        // Width of 1360 output addresses                                                            
                         )  
                        (
                         input clock,
                         input reset,                                                                            
                         input [3:0]ctrl,                                   // Control input to control the location of data flow 
                         input [data_in_width-1:0]products,                 // Input products    
                         output [output_width-1:0]out,                      // Output to the dofferent locations possible
                         
                         // Address controls
                         input [row_in_width-1:0]row_in,
                         input [col_in_width-1:0]col_in,
                         input [ch_in_width-1:0]ch_in,                        
                         output reg [output_locations-1:0]valid,
                         output [address_out_width-1:0]address_out                                                                                               
                         );
                         
    reg [product_width-1:0]op[output_locations-1:0];                        // register to store the outputs
    wire [product_width-1:0]inp[inp_no-1:0];                              // Wire connecting the input data to the combinational circuit    
    
    wire [row_width-1:0]row_inp[inp_no-1:0];                              // Wires connecting the row address input to the combinational circuit        
    wire [col_width-1:0]col_inp[inp_no-1:0];                              // Wires connecting the col address input to the combinational circuit        
    wire [ch_width-1:0]ch_inp[inp_no-1:0];                                // Wires connecting the ch address input to the combinational circuit
    
    reg [row_width-1:0]row_out[output_locations-1:0];                       // register to store the output row address          
    reg [col_width-1:0]col_out[output_locations-1:0];                       // register to store the output col address          
    reg [ch_width-1:0]ch_out[output_locations-1:0];                         // register to store the output ch address                  
    
    integer j;
            
    genvar i;    
                                 
    generate
        for(i=0;i<inp_no;i=i+1)
        begin
            assign inp[i] = products[(i*product_width)+:product_width];
            assign row_inp[i] = row_in[(i*row_width)+:row_width];            
            assign col_inp[i] = col_in[(i*col_width)+:col_width];            
            assign ch_inp[i] = ch_in[(i*ch_width)+:ch_width];            
        end
        
        for(i=0;i<output_locations;i=i+1)
        begin
            assign out[(i*product_width)+:product_width] = op[i];
            assign address_out[(i*address_width)+:address_width] = {row_out[i][row_width-2:0],col_out[i][col_width-2:0],ch_out[i][ch_width-1:0]};
        end              
    endgenerate                             
    
    
                             
    always @(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            for(j=0;j<output_locations;j=j+1)
            begin
                op[j] <= {product_width{1'b0}};
                
                valid[j] <= 1'b0;
                
                row_out[j] <= {row_width{1'b0}};
                col_out[j] <= {col_width{1'b0}};
                ch_out[j] <= {ch_width{1'b0}};
            end
        end
        else
        begin            
            case(ctrl)                
                4'd9 :  begin                                                                                                    // Multiplying with the element 9 of the kernel                     
                            for(j=0;j<256;j=j+1)                                                                                
                            begin
                                op[(output_locations - 1) - (4*j)] <= inp[(inp_no - 1) - j];                                   // Each 4th element is renewed while others are kept same//  
                                                                
                                // Address valid
                                valid[(output_locations - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);                                                                                        
                                valid[(output_locations - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[(output_locations - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[(output_locations - 1) - (4*j) - 3] <= 1'b0;   
                                
                                // Address
                                row_out[(output_locations - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[(output_locations - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[(output_locations - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];                                                                  
                            end               
                            
                            for(j=256;j<340;j=j+1)
                            begin                                                                
                                // Address valid
                                valid[(output_locations - 1) - (4*j)] <= 1'b0;                                                                 
                                valid[(output_locations - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[(output_locations - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[(output_locations - 1) - (4*j) - 3] <= 1'b0;
                            end                                                                                                                                                                   
                        end
                4'd8 :  begin                                                                                                    // Multiplying with the element 8 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - 4) - 1) - (4*j)] <= inp[(inp_no) - j];                                                                                                                
                                                               
                                // Address valid
                                valid[((output_locations - 4) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);                                                                                        
                                valid[((output_locations - 4) - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[((output_locations - 4) - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[((output_locations - 4) - 1) - (4*j) - 3] <= 1'b0;
                                
                                // Address
                                row_out[((output_locations - 4) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - 4) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - 4) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];                                                                                                                 
                            end  
                            
                            for(j=0;j<4;j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                valid[(output_locations - 1) - j] <= 1'b0;
                            end                            
                            
                            for(j=256;j<(340 - 1);j=j+1)
                            begin                              
                                // Address valid
                                valid[((output_locations - 4) - 1) - (4*j)] <= 1'b0;                                                                 
                                valid[((output_locations - 4) - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[((output_locations - 4) - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[((output_locations - 4) - 1) - (4*j) - 3] <= 1'b0;
                            end
                        end
                4'd7 :  begin                                                                                                    // Multiplying with the element 7 of the kernel
                            for (j=0;j<256;j=j+1)                                                                               
                            begin                                                                                               
                                op[((output_locations - (2*4)) - 1) - (4*j)] <= inp[(inp_no) - j];                                                                                 
                                
                                // Address valid 
                                valid[((output_locations - (2*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);                                                                                        
                                valid[((output_locations - (2*4)) - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[((output_locations - (2*4)) - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[((output_locations - (2*4)) - 1) - (4*j) - 3] <= 1'b0;    
                                
                                // Address
                                row_out[((output_locations - 8) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - 8) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - 8) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];                              
                            end                       
                            
                            for(j=0;j<8;j=j+1)
                            begin
                                 op[output_locations - 1 - j] <= {product_width{1'b0}};
                                 
                                 // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end                                                        
                            
                            for(j=256;j<(340-2);j=j+1)
                            begin
                                // Address valid
                                valid[((output_locations - (2*4)) - 1) - (4*j)] <= 1'b0;                                                                       
                                valid[((output_locations - (2*4)) - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[((output_locations - (2*4)) - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[((output_locations - (2*4)) - 1) - (4*j) - 3] <= 1'b0; 
                            end         
                        end                                                                                                      
                4'd6 :  begin                                                                                                    // Multiplying with the elwment 6 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - (col_len*4)) - 1) - (4*j)] <= inp[(inp_no) - j];                                                              
                                
                                // Address valid
                                valid[((output_locations - (col_len*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);                                                                                        
                                valid[((output_locations - (col_len*4)) - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[((output_locations - (col_len*4)) - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[((output_locations - (col_len*4)) - 1) - (4*j) - 3] <= 1'b0;          
                                
                                // Address
                                row_out[((output_locations - (col_len*4)) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - (col_len*4)) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - (col_len*4)) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];                   
                            end          
                            
                            for(j=0;j<(col_len*4);j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end  
                            
                            for(j=256;j< (340 - col_len);j=j+1)
                            begin
                                
                                // Address valid
                                valid[((output_locations - (col_len*4)) - 1) - (4*j)] <= 1'b0;                                                                       
                                valid[((output_locations - (col_len*4)) - 1) - (4*j) - 1] <= 1'b0;                                                                     
                                valid[((output_locations - (col_len*4)) - 1) - (4*j) - 2] <= 1'b0;                                                                     
                                valid[((output_locations - (col_len*4)) - 1) - (4*j) - 3] <= 1'b0;
                            end                                            
                        end
                4'd5 :  begin                                                                                                    // Multiplying with the element 5 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - ((col_len + 1)*4)) - 1) - (4*j)] <= inp[(inp_no) - j];                               
                                
                                // Address width
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]); 
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j) - 1] <= 1'b0;   
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j) - 2] <= 1'b0;   
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j) - 3] <= 1'b0; 
                                
                                // Address
                                row_out[((output_locations - ((col_len + 1)*4)) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - ((col_len + 1)*4)) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - ((col_len + 1)*4)) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];  
                            end    
                            
                            for(j=0;j<(col_len + 1)*4;j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end           
                            
                            for(j=256;j< (340 - col_len - 1);j=j+1)
                            begin                                
                                // Address valid
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j)] <= 1'b0;                                                                       
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j) - 1] <= 1'b0;                                                                       
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j) - 2] <= 1'b0;                                                                       
                                valid[((output_locations - ((col_len + 1)*4)) - 1) - (4*j) - 3] <= 1'b0;                                                                                                                                                                                                             
                            end                                        
                        end
                4'd4 :  begin                                                                                                    // Multiplying with the element 4 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - ((col_len + 2)*4)) - 1) - (4*j)] <= inp[(inp_no) - j];
                                
                                // Address valid
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);    
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j) + 1] <= 1'b0;       
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j) + 2] <= 1'b0;       
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j) + 3] <= 1'b0;       
                                
                                // Address
                                row_out[((output_locations - ((col_len + 2)*4)) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - ((col_len + 2)*4)) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - ((col_len + 2)*4)) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];
                            end                                             
                            
                            for(j=0;j<(col_len + 2)*4;j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end     
                            
                            for(j=256;j<(340 - col_len - 2);j=j+1)
                            begin                                
                                // Address valid
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j)] <= 1'b0;          
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j) - 1] <= 1'b0;          
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j) - 2] <= 1'b0;          
                                valid[((output_locations - ((col_len + 2)*4)) - 1) - (4*j) - 3] <= 1'b0;          
                            end                                
                       end
                4'd3 :  begin                                                                                                    // Multiplying with the element 3 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - ((2*col_len)*4)) - 1) - (4*j)] <= inp[(inp_no) - j];                               

                                // Address valid
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);           
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j) - 1] <= 1'b0;       
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j) - 2] <= 1'b0;       
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j) - 3] <= 1'b0;    
                                
                                // Address
                                row_out[((output_locations - ((col_len*2)*4)) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - ((col_len*2)*4)) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - ((col_len*2)*4)) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];   
                            end
                            
                            for(j=0;j<(2*col_len)*4;j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end
                            
                            for(j=256;j<(340 - (2*col_len));j=j+1)
                            begin                       
                                // Address valid
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j)] <= 1'b0;
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j) - 1] <= 1'b0;
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j) - 2] <= 1'b0;
                                valid[((output_locations - ((col_len*2)*4)) - 1) - (4*j) - 3] <= 1'b0;
                            end
                        end
                4'd2 :  begin                                                                                                    // Multiplying with the element 2 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - (((2*col_len) + 1)*4)) - 1) - (4*j)] <= inp[(inp_no) - j];
                         
                                // Address valid
                                valid[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);
                                valid[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j) - 1] <= 1'b0;
                                valid[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j) - 2] <= 1'b0;
                                valid[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j) - 3] <= 1'b0;
                                
                                // Address
                                row_out[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - (((col_len*2) + 1)*4)) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];
                            end
                            
                            for(j=0;j<((2*col_len) + 1)*4;j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end
                            
                            for(j=256;j<(340 - (2*col_len) - 1);j=j+1)
                            begin                             
                                // Address valid
                                valid[((output_locations - ((col_len*2) + 1)*4) - 1) - (4*j)] <= 1'b0;
                                valid[((output_locations - ((col_len*2) + 1)*4) - 1) - (4*j) - 1] <= 1'b0;
                                valid[((output_locations - ((col_len*2) + 1)*4) - 1) - (4*j) - 2] <= 1'b0;
                                valid[((output_locations - ((col_len*2) + 1)*4) - 1) - (4*j) - 3] <= 1'b0;                                                        
                            end
                        end
                4'd1 :  begin                                                                                                    // Multiplying with the element 1 of the kernel
                            for(j=0;j<256;j=j+1)
                            begin
                                op[((output_locations - ((2*col_len) + 2)*4) - 1) - (4*j)] <= inp[(inp_no) - j];
                             
                                // Address valid
                                valid[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j)] <= ~(row_in[((inp_no*row_width) - 1) - (row_width*j)] | col_in[((inp_no*col_width) - 1) - (col_width*j)]);
                                valid[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j) - 1] <= 1'b0;
                                valid[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j) - 2] <= 1'b0;
                                valid[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j) - 3] <= 1'b0;   
                                
                                // Address
                                row_out[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j)] <= row_inp[inp_no - 1 - j];                                                                  
                                col_out[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j)] <= col_inp[inp_no - 1 - j];                                                                  
                                ch_out[((output_locations - (((col_len*2) + 2)*4)) - 1) - (4*j)] <= ch_inp[inp_no - 1 - j];                            
                            end
                            
                             for(j=0;j<((2*col_len) + 2)*4;j=j+1)
                            begin
                                op[output_locations - 1 - j] <= {product_width{1'b0}};
                                
                                // Address valid
                                 valid[(output_locations - 1) - j] <= 1'b0;
                            end
                            
                            for(j=256;j<(340 - (2*col_len) - 2);j=j+1)
                            begin                              
                                // Address valid
                                valid[((output_locations - ((col_len*2) + 2)*4) - 1) - (4*j)] <= 1'b0;
                                valid[((output_locations - ((col_len*2) + 2)*4) - 1) - (4*j) - 1] <= 1'b0;
                                valid[((output_locations - ((col_len*2) + 2)*4) - 1) - (4*j) - 2] <= 1'b0;
                                valid[((output_locations - ((col_len*2) + 2)*4) - 1) - (4*j) - 3] <= 1'b0;
                            end
                        end
                default : begin
                                for(j=0;j<1360;j=j+1)
                                begin
                                    op[j] <= {product_width{1'b0}};
                                                                       
                                    // Address valid
                                    valid[j] <= 1'b0;
                                    
                                    row_out[j] <= {row_width{1'b0}};
                                    col_out[j] <= {col_width{1'b0}};
                                    ch_out[j] <= {ch_width{1'b0}};
                                end
                          end              
            endcase           
        end
    end        
                                                                                                                                                                          
endmodule
