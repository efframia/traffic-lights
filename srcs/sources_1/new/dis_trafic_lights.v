`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/25 21:02:58
// Design Name: 
// Module Name: dis_trafic_lights
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


module dis_trafic_lights(
    input clk,
    input sw0,//高峰期开关
    input sw1,//紧急制动开关
    input rst,//复位
    
    output [7:0]bit,
    output [7:0]seg,
    output [7:0]light,
    output wire buzzer//蜂鸣器
    );
    wire key_l;//蜂鸣器控制信号
    reg [7:0]bit;//位选
    reg [7:0]seg;//段选
    
    reg [7:0]light;//控制led
    reg [3:0]data;
    reg [31:0]count;//分频计数器
    reg divclk;//分频
    reg temp;
    reg flag;
    reg [3:0]state;
    reg [7:0]num;//倒计时
    reg [7:0]red=8'b00110000,green=8'b00100000;//红灯30s，绿灯20s
    reg [7:0]red1=8'b00010000,green1=8'b01000000;//高峰期时，红灯10s，绿灯40s
    reg [7:0]hold=8'b10011001;//紧急制动后显示状态99
    reg key;//为其赋值0 or 1来控制蜂鸣器的响起与否
    
    sp6 beep0(.ext_clk_25m(clk),.ext_rst_n(key_l),.beep(buzzer));//与蜂鸣器模块连接
    assign key_l=key;
    always@(posedge clk)//分频模块
    if(count==32'd25000000)
        begin
            count<=32'd0;
            divclk<=~divclk;
        end
    else
    begin
        count<=count+1'b1;
    end
    
    always@(posedge clk)//为数码管赋初值，确定倒计时显示位置
    begin
        case(count[15])//在1s前完成
        1'd0:data=num[3:0];
        1'd1:data=num[7:4];
        endcase
        
        case(count[15])
        1'd0:bit=8'b00000100;
        1'd1:bit=8'b00001000;
        endcase
    end
    
    always@(posedge divclk)//主控制
    if(rst)//复位
    begin
    num<=red;
    light<=8'b00010000;   
    end 
    else if(sw1)//紧急制动开关启动，数码管显示99
    begin
    num<=hold;
    light<=8'b00010000;
    state<=4'b0000;
    temp<=0;
    end
    else
            begin
            if(!temp)//temp为0时，进入灯的闪烁状态机
                begin
                temp<=1;
                case(state)//状态机
                4'b0000:begin 
                if(!sw0)
                begin
                num<=red;//默认情况
                end
                else
                begin
                num<=red1;//高峰期
                end
                light<=8'b00010000;state<=4'b0001;key<=1'b0;end
                4'b0001:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b0010;key<=1'b0;end
                4'b0010:begin num[3:0]<=num[3:0]-1;light<=8'b00010000;state<=4'b0011;key<=1'b1;end
                4'b0011:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b0100;key<=1'b0;end
                4'b0100:begin num[3:0]<=num[3:0]-1;light<=8'b00010000;state<=4'b0101;key<=1'b1;end
                4'b0101:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b0110;key<=1'b0;end
                4'b0110:begin num[3:0]<=num[3:0]-1;light<=8'b00010000;state<=4'b0111;key<=1'b1;end
                4'b0111:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b1000;key<=1'b0;end
                4'b1000:begin 
                if(!sw0)
                begin
                num<=green;//默认情况
                end
                else
                begin
                num<=green1;//高峰期
                end
                light<=8'b00001000;state<=4'b1001;key<=1'b0;end
                4'b1001:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b1010;key<=1'b0;end
                4'b1010:begin num[3:0]<=num[3:0]-1;light<=8'b00001000;state<=4'b1011;key<=1'b1;end
                4'b1011:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b1100;key<=1'b0;end
                4'b1100:begin num[3:0]<=num[3:0]-1;light<=8'b00001000;state<=4'b1101;key<=1'b1;end
                4'b1101:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b1110;key<=1'b0;end
                4'b1110:begin num[3:0]<=num[3:0]-1;light<=8'b00001000;state<=4'b1111;key<=1'b1;end
                4'b1111:begin num[3:0]<=num[3:0]-1;light<=8'b00000000;state<=4'b0000;key<=1'b0;end
                default:light<=8'b00010000;
                endcase
                end        
            else 
            begin
            if(num==1||num==2||num==3||num==4||num==5||num==6||num==7||num==8)//控制最后倒计时
            temp<=0;
            else if(num>8)
                 if(num[3:0]==0)//倒计时个位为0
                 begin
                      if(flag==1)
                      begin
                      num[3:0]<=4'b1001;//个位变9
                      num[7:4]<=num[7:4]-1;//十位减1
                      flag<=0;
                      end
                      else
                      flag<=1;
                      end
                 else 
                      if(flag==1)
                      begin
                      num[3:0]<=num[3:0]-1;//个位减1
                      flag<=0;
                      end
                      else
                      flag<=1;
                      end           
                end
                
        always @(posedge clk)//由倒计时数据确定段选
                    begin
                        case(data)
                        4'h0:begin seg =  8'b00111111;end
                        4'h1:begin seg = 8'b00000110; end 
                        4'h2:begin seg = 8'b01011011; end
                        4'h3:begin seg = 8'b01001111; end
                        4'h4:begin seg = 8'b01100110; end
                        4'h5:begin seg = 8'b01101101; end
                        4'h6:begin seg = 8'b01111101; end
                        4'h7:begin seg = 8'b00000111; end
                        4'h8:begin seg = 8'b01111111; end
                        4'h9:begin seg = 8'b01101111; end
                        default:begin seg = 8'b00000000; end
                        endcase
                    end            
    endmodule
