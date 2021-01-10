`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/26 12:33:24
// Design Name: 
// Module Name: sp6
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sp6(
			input ext_clk_25m,	//外部输入25MHz时钟信号
			input ext_rst_n,	//外部输入复位信号，低电平有效
			output reg beep	//蜂鸣器控制信号，1--响，0--不响
		);
 
//-------------------------------------
reg[19:0] cnt;		//20位计数器
 
	//cnt计数器进行0-999999的循环计数，即ext_clk_25m时钟的1000000分频，对应cnt一个周期为25Hz
always @ (posedge ext_clk_25m or negedge ext_rst_n)	
	if(!ext_rst_n) cnt <= 20'd0;
	else if(cnt < 20'd999_999) cnt <= cnt+1'b1;
	else cnt <= 20'd0;
 
//-------------------------------------
 
	//产生频率为25Hz，占空比为50%的蜂鸣器发声信号
always @ (posedge ext_clk_25m or negedge ext_rst_n) 
	if(!ext_rst_n) beep <= 1'b0;
	else if(cnt < 20'd500_000) beep <= 1'b1;	//蜂鸣器响
	else beep <= 1'b0;		//蜂鸣器不响
 
endmodule
