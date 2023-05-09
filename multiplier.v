module multiplier #(
                    parameter IA_in_width = 17,
                    weight_in_width = 17,
                    product_width = 32,
                    product_out_width = 17
                    )
                    (
                     input [IA_in_width-1:0]data_1, // Data 1 is IA
                     input [weight_in_width-1:0]data_2, // Data 2 is weights
                     output [product_out_width-1:0]product_out
                     );
    wire [product_width-1:0]pro;                     
    assign pro = data_1[IA_in_width-2:0]*data_2[weight_in_width-2:0];
    assign product_out[16] = data_1[16] ^ data_2[16];
    assign product_out[15:0] = pro[15] ? pro[31:16] + 1 : pro[31:16];
    
endmodule
