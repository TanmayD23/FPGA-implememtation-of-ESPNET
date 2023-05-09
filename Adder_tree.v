module adder_tree_4 #(
                      parameter data_width = 17408,                 // width of 1024 products each of width 17 bits
                      product_width = 17                            // Width of one product element                                           
                      )
                     (
                      input clock,
                      input reset,
                      input enable,                   
                      input signed [data_width-1:0]data_in,
                      output signed [(data_width/4)-1:0]sum_4                    
                      );
    wire signed [(data_width/2)-1:0]sm_1;              
                    
    genvar i;
    generate  
        for(i=0;i<512;i=i+1)
        begin
            Adder Adder_stage_1(clock,reset,enable,data_in[((2*i)*product_width)+:product_width],data_in[(((2*i)+1)*product_width)+:product_width],sm_1[(i*product_width)+:product_width]);
        end
    endgenerate         
    
    generate
        for(i=0;i<256;i=i+1)
        begin
            Adder Adder_stage_2(clock,reset,enable,sm_1[((2*i)*product_width)+:product_width],sm_1[(((2*i)+1)*product_width)+:product_width],sum_4[(i*product_width)+:product_width]);
        end
    endgenerate                  
endmodule
