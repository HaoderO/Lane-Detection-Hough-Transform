module delay_xbit #
(
    parameter  DATA_WIDTH  = 12,
    parameter  DLY_CYCLE   = 18
) 
(
    input                       rst_n   ,
    input                       clk     ,
    input      [11:0] i_data  ,
    output     [11:0] o_data
);

//generate
//    genvar i;
//    for (i=0;i<DATA_WIDTH;i=i+1)
//        begin:sync
//            delay_bit # 
//            (
//                .DLY_CYCLE  (DLY_CYCLE  )
//            )
//            delay_bit_inst 
//            (
//                .rst_n      (rst_n      ),
//                .clk        (clk        ),
//                .i_data     (i_data[i]  ),
//
//                .o_data     (o_data[i] )
//            );
//        end
//endgenerate

delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_0 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[0]  ),

    .o_data     (o_data[0] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_1 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[1]  ),

    .o_data     (o_data[1] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_2 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[2]  ),

    .o_data     (o_data[2] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_3 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[3]  ),

    .o_data     (o_data[3] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_4 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[4]  ),

    .o_data     (o_data[4] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_5 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[5]  ),

    .o_data     (o_data[5] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_6 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[6]  ),

    .o_data     (o_data[6] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_7 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[7]  ),

    .o_data     (o_data[7] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_8 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[8]  ),

    .o_data     (o_data[8] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_9 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[9]  ),

    .o_data     (o_data[9] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_10 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[10]  ),

    .o_data     (o_data[10] )
);
delay_bit # 
(
    .DLY_CYCLE  (DLY_CYCLE  )
)
delay_bit_11 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .i_data     (i_data[11]  ),

    .o_data     (o_data[11] )
);
endmodule