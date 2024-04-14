module rho_cacl
(
    input               rst_n       ,
    input               clk         ,
    input  wire         interest_part,// 0：left，1：right
    input               in_vld      ,    
    input       [11:0]  x           ,
    input       [11:0]  y           ,
    input       [31:0]  phase       ,

    output reg          out_vld     ,    
    output reg  [27:0]  rho_data
);

parameter DATA_WIDTH = 12;
parameter DLY_CYCLE  = 18;

wire [11:0] x_dly;
wire [11:0] y_dly;

wire            cordic_vld   ;
wire  [31:0]    sin        ;
wire  [31:0]    cos        ;
wire  [31:0]    error      ;

delay_xbit # 
(
    .DATA_WIDTH (DATA_WIDTH     ),
    .DLY_CYCLE  (DLY_CYCLE      )
)
delay_x 
(
    .rst_n      (rst_n          ),
    .clk        (clk            ),
    .i_data     (x              ),
    .o_data     (x_dly          )
);

delay_xbit # 
(
    .DATA_WIDTH (DATA_WIDTH     ),
    .DLY_CYCLE  (DLY_CYCLE      )
)
delay_y 
(
    .rst_n      (rst_n          ),
    .clk        (clk            ),
    .i_data     (y              ),
    .o_data     (y_dly          )
);

cordic  cordic_inst 
(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .in_vld     (in_vld         ),
    .phase      (phase          ),

    .out_vld    (cordic_vld     ),
    .sin        (sin            ),
    .cos        (cos            ),
    .error      (error          )
);

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rho_data <= 28'd0;
    end
    else if(cordic_vld)
    begin
        if(interest_part==1'b1)
            rho_data <= ((x_dly*cos)>>16) + ((y_dly*sin)>>16) ;// 第一象限 ρ = xcos + ysin 
        else
            rho_data <= ((y_dly*sin)>>16) - ((x_dly*(~(cos - 1'b1)))>>16);// 第二象限 ρ = -xcos + ysin 
    end
end
// 信号
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        out_vld <= 1'b0;
    else
        out_vld <= cordic_vld;
end

endmodule