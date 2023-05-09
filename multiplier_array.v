module multiplier_array #(
                          parameter IA_in_width = 4352*4,   // width of 1024 IA
                          weight_in_width = 17*4,           // width of 4 weights 
                          data_out_width = 17408,           // width of 1024 product data
                          IA_width = 17,                    // individual IA_width
                          weight_width = 17,                // individual weight_width
                          product_width = 17                //individual product width
                          )
                          (    
                           input reset,
                           input clock,                           
                           input [IA_in_width-1:0]data_1,           // Data 1 is IA
                           input [weight_in_width-1:0]data_2,       // Data 2 is weight
                           output reg [data_out_width-1:0]product
                           );
    genvar i;
    wire [data_out_width-1:0]pro;
    generate
        for(i=0;i<1024;i=i+1)
        begin
            multiplier m1(data_1[((i+1)*IA_width)-1:i*IA_width],data_2,pro[((i+1)*product_width)-1:i*product_width]);
        end
    endgenerate  
    
    always @(posedge clock)
    begin     
        if(reset == 1'b1)
        begin
            product <= 0;
        end
        else
        begin
            product <= pro;
        end
    end
endmodule
