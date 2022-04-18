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
	 //����ֱ�����ڴ�����Ӧ��ַ��Ԫ����
	input [7:0] a;  //8�����뿪�أ�������
	input Load; //����
	input Reset; //����
	input Add,Multiply,Divide,LPa,RPa,Equal; //+*/()= 
	output reg Zero,Overflow,Warning;
	//Memory��CPU�е�����˿�
	input memread,memwrite; //���ƶ�д�ڴ��ź�
	input [WIDTH-1:0] adr, writedata; //�ڴ�ռ��ַ������
	//�������������ݣ�ֱ�������������
	output reg [7:0] dis_sel;  //λѡ
	output reg [7:0] dis_dig; //��ѡ
	//Memory��CPU�е�����˿�
	output reg [WIDTH-1:0] memdata;
	
	//BISO����������ݣ�ROM���ָ�����ݣ�RAM�����������
	reg  [31:0] BSIO [3:0]; // 16B(4����),ӳ��ĵ�ַ��ΧΪ0x00004ff0-0x00004fff
	reg  [31:0] RAM [1023:0]; //4KB,ӳ��ĵ�ַ��ΧΪ0x00001000-0x00001fff
    reg  [31:0] ROM [1023:0]; //4KB,ӳ��ĵ�ַ��ΧΪ0x00000000-0x00000fff
    wire [31:0] word; //�м�������������
	reg [31:0] adr1; //�м��������ŵ�ַ
	wire[31:0] word_1;//�м����

	initial 
		begin
		     //BSIO[0][31:0]=32'd0;
		     BSIO[1][31:0]=32'd0;
		     BSIO[2][31:0]=32'd0;
		     BSIO[3][31:0]=32'd0;
			$readmemh ("C:/Users/Zy531/Desktop/new3.dat" ,ROM) ; //��ָ�������ָ��������յ�ROM�У���ʼʱPCΪ0��ROM��һ��ָ��
		end

	// read and write bytes from 32-bit word
	always @ (posedge clk)
       if(memwrite)   //��д�źţ���д�ڴ�
            begin
                $display("write: addr: %h    writedata: %h", adr, writedata); //�����ʾд��ĵ�ַ�����ݣ����ڷ���
                case (adr[15:12])
                    4'd0: ROM[adr>>2][31:0] <= writedata; //д��ROM��
                    4'd1: 
                        begin
                            adr1=adr-32'h00001000;
                            RAM[adr1>>2][31:0] <= writedata;//д��RAM����
                        end
                    4'd4:
                        case(adr)
                            32'h00004ff8:BSIO[2][31:0] <= writedata;//д������IO���������������
                            32'h00004ff0:BSIO[0][31:0] <= writedata;//д������error��
                        endcase
                endcase
            end
    assign word = BSIO[2];
    assign word_1=BSIO[0];
	always @(*)  //ʼ�ն���
	   begin
	       BSIO[3][31:0] <= a[7]?{24'hffffff,a}:{24'd0,a}; //8��������,��Ӧ8�����뿪��
           BSIO[1][31:0] <= {24'b0,Reset,Equal,Load,Add,Multiply,Divide,LPa,RPa};//8��������Ϣ,��Ӧ6���������������뿪��
           dis_sel <= word[15:8]; //λѡ����
           dis_dig <= word[7:0];//��ѡ����
           Zero<=word_1[0];
           Overflow<=word_1[1];
           Warning<=word_1[2];
           case (adr[15:12])
                        4'd0: memdata <= ROM[adr>>2][31:0]; //��ROM������
                        4'd1: 
                            begin
                                adr1=adr-32'h00001000;
                                memdata <= RAM[adr1>>2][31:0];//��RAM������
                            end
                        4'd4:
                            begin
                                adr1=adr-32'h00004ff0;
                                memdata <= BSIO[adr1>>2][31:0];//������IO������
                            end
            endcase
	   end	
endmodule

