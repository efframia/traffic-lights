`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/25 22:13:13
// Design Name: 
// Module Name: sim_traffic_lights
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


module sim_traffic_lights;
reg clk;
reg rst;
reg sw0;
reg sw1;

wire [7:0]bit;
wire [7:0]seg;
wire [7:0]light;

dis_trafic_lights uut(
.clk(clk),
.rst(rst),
.sw0(sw0),
.sw1(sw1),
.bit(bit),
.seg(seg),
.light(light)
);
always #1 clk=~clk;
initial begin
clk=0;
rst=0;
sw0=0;
sw1=0;
#10 sw0=1;
#100 sw1=1;
#1000 rst=1;
#10000 $stop;
end
endmodule
