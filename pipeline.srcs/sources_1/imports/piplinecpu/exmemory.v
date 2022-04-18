`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/08 00:56:12
// Design Name: 
// Module Name: Memory
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


//external memory accessed by MIPS
module exmemory # (parameter WIDTH =32) (clk, a, Load, Reset, Add, Multiply, Divide, LPa, RPa, Equal,Zero,Overflow,Warning,dis_sel, dis_dig,memread, memwrite, adr, writedata,memdata);
	input clk ;
	 //外设直接与内存中相应地址单元相连
	input [7:0] a;  //8个拨码开关，操作数
	input Load; //置数
	input Reset; //重启
	input Add,Multiply,Divide,LPa,RPa,Equal; //+*/()= 
	output reg Zero,Overflow,Warning;
	//Memory在CPU中的输入端口
	input memread,memwrite; //控制读写内存信号
	input [WIDTH-1:0] adr, writedata; //内存空间地址和数据
	//输出到外设的内容，直接与数码管相连
	output reg [7:0] dis_sel;  //位选
	output reg [7:0] dis_dig; //段选
	//Memory在CPU中的输出端口
	output reg [WIDTH-1:0] memdata;
	
	//BISO存放外设数据，ROM存放指令内容，RAM存放数据内容
	reg  [31:0] BSIO [3:0]; // 16B(4个字),映射的地址范围为0x00004ff0-0x00004fff
	reg  [31:0] RAM [1023:0]; //4KB,映射的地址范围为0x00001000-0x00001fff
    reg  [31:0] ROM [1023:0]; //4KB,映射的地址范围为0x00000000-0x00000fff
    wire [31:0] word; //中间变量，存放数据
	reg [31:0] adr1; //中间变量，存放地址
	wire[31:0] word_1;//中间变量

	initial 
		begin
		     //BSIO[0][31:0]=32'd0;
		     BSIO[1][31:0]=32'd0;
		     BSIO[2][31:0]=32'd0;
		     BSIO[3][31:0]=32'd0;
			$readmemh ("C:/Users/Zy531/Desktop/new3.dat" ,ROM) ; //读指令，将汇编的指令机器码烧到ROM中；开始时PC为0即ROM第一条指令
		end

	// read and write bytes from 32-bit word
	always @ (posedge clk)
       if(memwrite)   //有写信号，则写内存
            begin
                $display("write: addr: %h    writedata: %h", adr, writedata); //输出显示写入的地址和数据，用于仿真
                case (adr[15:12])
                    4'd0: ROM[adr>>2][31:0] <= writedata; //写到ROM中
                    4'd1: 
                        begin
                            adr1=adr-32'h00001000;
                            RAM[adr1>>2][31:0] <= writedata;//写到RAM里面
                        end
                    4'd4:
                        case(adr)
                            32'h00004ff8:BSIO[2][31:0] <= writedata;//写到基本IO中数码管数据里面
                            32'h00004ff0:BSIO[0][31:0] <= writedata;//写到三个error里
                        endcase
                endcase
            end
    assign word = BSIO[2];
    assign word_1=BSIO[0];
	always @(*)  //始终读出
	   begin
	       BSIO[3][31:0] <= a[7]?{24'hffffff,a}:{24'd0,a}; //8个操作数,对应8个拨码开关
           BSIO[1][31:0] <= {24'b0,Reset,Equal,Load,Add,Multiply,Divide,LPa,RPa};//8个按键信息,对应6个按键和两个拨码开关
           dis_sel <= word[15:8]; //位选开关
           dis_dig <= word[7:0];//断选开关
           Zero<=word_1[0];
           Overflow<=word_1[1];
           Warning<=word_1[2];
           case (adr[15:12])
                        4'd0: memdata <= ROM[adr>>2][31:0]; //读ROM中数据
                        4'd1: 
                            begin
                                adr1=adr-32'h00001000;
                                memdata <= RAM[adr1>>2][31:0];//读RAM中数据
                            end
                        4'd4:
                            begin
                                adr1=adr-32'h00004ff0;
                                memdata <= BSIO[adr1>>2][31:0];//读基本IO中数据
                            end
            endcase
	   end	
endmodule

