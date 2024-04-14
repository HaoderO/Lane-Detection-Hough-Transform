module delay_bit #
(
    parameter  DLY_CYCLE  = 8
) 
(
    input       rst_n   ,
    input       clk     ,
    input       i_data  ,

    output reg  o_data
);

reg [6:0] data_dx;

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n) 
        data_dx <= 7'd0;
    else 
        data_dx <= {data_dx[5:0],i_data};
end  

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        o_data <= 1'b0;
    end
    else begin
        o_data <= data_dx[6];
    end    
end  

endmodule