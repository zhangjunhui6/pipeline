`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/08 11:17:33
// Design Name: 
// Module Name: top
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


module Ego1_Top #(parameter WIDTH=32, REGBITS=5) (
	input clk, //100MHz
	input [7:0] a, //补码表示的有符号数通过8位拨码开关输入
	input Load, //拨码开关置数
	input Reset, //拨码开关复位
	input Add,Multiply,Divide,LPa,RPa,Equal, //加、乘、除、左、右括号和等于按键
	//input reset, //节拍重置
	output Zero, //除以0指示灯，
	output Overflow,//溢出指示灯
	output Warning,//表达式错误指示灯
	output [7:0] led_dis, //显示八个开关
	output [7:0] dis_sel, //八个数码管位选,LPa,RPa,
	output [7:0] dis_dig, //八个数码管段选
	output [7:0] dis_dig1
    );
	wire [31: 0] inst_addr;
    	wire [31: 0] inst_data;

    	wire         data_wen;
    	wire [31: 0] data_addr;
    	wire [31: 0] data_dout;
    	wire [31: 0] data_din;

    	mycpu_top cpu
    	(
        		.clk        ( clk           ),
       		.reset        ( Reset         ),
        		.inst_sram_addr  ( inst_addr     ),
        		.inst_sram_rdata  ( inst_data     ),
        		.data_sram_wen   ( data_wen      ),
        		.data_sram_addr  ( data_addr     ),
        		.data_sram_wdata  ( data_dout     ),
        		.data_sram_rdata   ( data_din      )
    	);
    
    	wire reset;
    	assign reset=0;
	//Memory模块的端口
	wire memread, memwrite; //存储器读/存储器写信号
	wire [WIDTH-1:0] adr, writedata;  //存储器写地址/写数据
	wire [WIDTH-1:0] memdata; //存储器输出端口

	//external memory for code and data
	exmemory #(WIDTH) exmem(clk,a,Load,~Reset,Add,Multiply,Divide,LPa,RPa,Equal,Zero,Overflow,Warning,dis_sel,dis_dig,memread,memwrite,adr,writedata,memdata);
    assign dis_dig1=dis_dig;
    assign led_dis=a;
endmodule