module Address_calculate #(
                 parameter ia_col_bits = 10,    // width of col address of IA
                 ia_row_bits = 9,               // width of row address of IA
                 ia_ch_bits = 8,                // width of channel address of IA
                 wt_row_bits = 5,               // width of row address of wt
                 wt_col_bits = 5,               // width of col address of wt
                 ker_bits = 5,                   // width of kernel address of wt
                 concat_bits = 8                // width of concat number
                 )
                (
                 // General signals
                 input clock,
                 input reset,
                 
                 //input ia address                 
                 input [ia_row_bits-1:0]ia_row,                     // row address of IA
                 input [ia_col_bits-1:0]ia_col,                     // col address of IA
                 
                 //input wts address                
                 input [wt_row_bits-1:0]wt_row,                     // row address of weight
                 input [wt_col_bits-1:0]wt_col,                     // col address of weight
                 input [ker_bits-1:0]wt_kr,                         // kernel address of weight
                 
                 // concat no in case we are concatnating the IAs
                 input [concat_bits-1:0]concat_no,                  // conacat number in case we need to concat some OA
                 
                 // Output IA address
                 output reg [ia_row_bits:0]new_ia_row,              // row address of OA
                 output reg [ia_col_bits:0]new_ia_col,              // col address of OA
                 output reg [ia_ch_bits-1:0]new_ia_ch               // channel address of OA
                 );
    always @(posedge clock)
    begin
        if(ia_row >= wt_row)
        begin
            new_ia_row[ia_row_bits-1:0] <= ia_row - wt_row;
            new_ia_row[ia_row_bits] <= 0;
        end        
        else
        begin
            new_ia_row[ia_row_bits-1:0] <= wt_row - ia_row;
            new_ia_row[ia_row_bits] <= 1;
        end 
        
        if(ia_col >= wt_col)
        begin
            new_ia_col <= ia_row - wt_col;
        end        
        else
        begin
            new_ia_col[ia_col_bits-1:0] <= wt_col - ia_col;
            new_ia_col[ia_col_bits] <= 1;
        end                
        new_ia_ch <= concat_no + wt_kr;
    end    
                     
endmodule

module address_array #(
                       parameter ia_col_width = 2560*4,
                       ia_row_width = 2304*4,
                       wt_row_width = 5*4,
                       wt_col_width = 5*4,
                       ch_width = 2048*4,
                       kr_width = 1280*4,
                       concat_width = 2048,
                       ia_col_bits = 10,              // width of col address of IA
                       ia_row_bits = 9,               // width of row address of IA
                       ia_ch_bits = 8,                // width of channel address of IA
                       wt_row_bits = 5,               // width of row address of wt
                       wt_col_bits = 5,               // width of col address of wt
                       ker_bits = 5                   // width of kernel address of wt
                       )
                       (
                        input clock,
                        input reset,
                        
                        //input ia address                 
                        input [ia_row_width-1:0]ia_row,
                        input [ia_col_width-1:0]ia_col,
                        
                        //input wts address                
                        input [wt_row_width-1:0]wt_row,
                        input [wt_col_width-1:0]wt_col,
                        input [kr_width-1:0]wt_ker,
                         
                        // concat no in case we are concatnating the IAs
                        input [concat_width-1:0]concat_no,
                         
                        // Output IA address
                        output [ia_row_width:0]new_ia_row,
                        output [ia_col_width:0]new_ia_col,
                        output [ch_width-1:0]new_ia_ch                      
                        );
    genvar i;
    
    generate 
        for(i=0;i<256;i=i+1)
        begin
            Address_calculate ac(
                                 .clock(clock),
                                 .reset(reset),
                                 
                                 
                                 .ia_col(ia_col[(ia_col_bits*4*i)+:ia_col_bits]),
                                 .ia_row(ia_row[(ia_row_bits*4*i)+:ia_row_bits]),
                                 
                                 
                                 .wt_row(wt_row),
                                 .wt_col(wt_col),
                                 .wt_kr(wt_ker),
                                 
                                 
                                 .new_ia_col(new_ia_col[(ia_col_bits*i)+:ia_col_bits]),
                                 .new_ia_row(new_ia_row[(ia_row_bits*i)+:ia_row_bits]),
                                 .new_ia_ch(new_ia_ch[(ker_bits*i)+:ker_bits]),
                                 
                                 
                                 .concat_no(concat_no[(8*i)+:8])
                                 );
        end
    endgenerate                            
endmodule
