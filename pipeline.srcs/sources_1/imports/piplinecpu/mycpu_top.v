module mycpu_top(
    input         clk,     /*����ʱ�Ӻ͸�λ�ź�*/
    input         reset,
    // inst sram interface
    //output        inst_sram_en,
    //output [ 3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,/*ָ��洢���������ַ������ָ��*/
    //output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    // data sram interface
    output        data_sram_wen,/*���ݴ洢�������дʹ���źţ���ַ��д���ݣ����������*/
    //output [ 3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata
);
//reg         reset;
//always @(posedge clk) reset <= ~resetn;

wire [31:0] seq_pc;
wire [31:0] nextpc;
// fs_ -- IF  stage
wire        to_fs_valid;
wire        fs_allowin;
wire        fs_ready_go;
wire        fs_to_ds_valid;
reg         fs_valid;
reg  [31:0] fs_pc;
reg [31:0] inst;
// ds_ -- ID  stage
wire        ds_stall;  //  ds_stall �ź�
wire        ds_allowin;
wire        ds_ready_go;
wire        ds_to_es_valid;
reg         ds_valid;
reg  [31:0] ds_pc;
reg  [31:0] ds_inst;
wire [ 5:0] op;
wire [ 4:0] rs;
wire [ 4:0] rt;
wire [ 4:0] rd;
wire [ 4:0] sa;
wire [ 5:0] func;
wire [15:0] imm;
wire [25:0] jidx;
wire [63:0] op_d;
wire [31:0] rs_d;
wire [31:0] rt_d;
wire [31:0] rd_d;
wire [31:0] sa_d;
wire [63:0] func_d;
wire        inst_addu;
wire        inst_subu;
wire        inst_slt;
wire        inst_sltu;
wire        inst_and;
wire        inst_or;
wire        inst_xor;
wire        inst_nor;
wire        inst_sll;
wire        inst_srl;
wire        inst_sra;
wire        inst_addiu;
wire        inst_lui;
wire        inst_lw;
wire        inst_sw;
wire        inst_beq;
wire        inst_bne;
wire        inst_jal;
wire        inst_jr;
wire [11:0] alu_op;
wire        src1_is_sa;  
wire        src1_is_pc;
wire        src2_is_imm; 
wire        src2_is_8;
wire        res_from_mem;
wire        dst_is_r31;  
wire        dst_is_rt;   
wire        gr_we;       
wire        mem_we;      
wire [ 4:0] dest;
wire        is_load_op;   // is_load_op  ȡ������ָ��
wire [ 4:0] rf_raddr1;
wire [31:0] rf_rdata1;
wire [ 4:0] rf_raddr2;
wire [31:0] rf_rdata2;
wire        rs_mch_es_dst; // ǰ������ź�
wire        rt_mch_es_dst; // ǰ������ź�
wire        rs_mch_ms_dst; // ǰ������ź�
wire        rt_mch_ms_dst; // ǰ������ź�
wire        rs_mch_ws_dst; // ǰ������ź�
wire        rt_mch_ws_dst; // ǰ������ź�
wire [31:0] rs_value;
wire [31:0] rt_value;
wire        rs_eq_rt;
wire        br_taken;
wire [31:0] br_target;
// es_ -- EXE stage
wire        es_allowin;
wire        es_ready_go;
wire        es_to_ms_valid;
reg         es_valid;
reg  [31:0] es_pc;
reg  [31:0] es_rs_value;
reg  [31:0] es_rt_value;
reg  [15:0] es_imm;
reg  [11:0] es_alu_op;
reg         es_src1_is_sa;  
reg         es_src1_is_pc;
reg         es_src2_is_imm; 
reg         es_src2_is_8;
reg         es_res_from_mem;
reg         es_gr_we;
reg         es_mem_we;
reg  [ 4:0] es_dest;
reg         es_is_load_op;  //ES �׶�ȡ������
wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire [31:0] alu_result;
// ms_ -- MEM stage
wire        ms_allowin;
wire        ms_ready_go;
wire        ms_to_ws_valid;
reg         ms_valid;
reg  [31:0] ms_pc;
reg  [ 4:0] ms_dest;
reg         ms_res_from_mem;
reg         ms_gr_we;
reg  [31:0] ms_alu_result;
wire [31:0] mem_result;
wire [31:0] final_result;
// ws_ -- WB  stage
wire        ws_allowin;
wire        ws_ready_go;
reg         ws_valid;
reg  [31:0] ws_pc;
reg         ws_gr_we;
reg  [ 4:0] ws_dest;
reg  [31:0] ws_final_result;
wire        rf_we;
wire [ 4:0] rf_waddr;
wire [31:0] rf_wdata;

// pre-IF stage
assign to_fs_valid  = ~reset;   //�ȼ�validin
assign seq_pc = fs_pc + 3'h4;
assign nextpc = br_taken ? br_target : seq_pc; 

// IF stage
assign fs_ready_go    = 1'b1;   //ʼ�վ���
assign fs_allowin     = !fs_valid || fs_ready_go && ds_allowin;//û��ָ���ָ�����ID��
assign fs_to_ds_valid = fs_valid && fs_ready_go;//ָ����Ч�Ҿ�������ɽ���ID��
assign inst_sram_addr  = nextpc;     //�����inst_sram_addr(ָ��洢����ַ)ΪPCֵ
always @(posedge clk) begin
    if (reset) begin
        fs_valid <= 1'b0;    //��λ��������Ч
    end
    else if (fs_allowin) begin
        fs_valid <= to_fs_valid; //����������Ч��ͬto_fs_valid  
    end

    if (reset) begin   //���ø�λ��ָ����ʼ��ַ
        fs_pc <= 32'hfffffffc;  //trick: to make nextpc be 0x00000000 during reset
//      fs_pc <= 32'hbfbffffc;  //trick: to make nextpc be 0xbfc00000 during reset 
    end
    else if (to_fs_valid && fs_allowin) begin
        fs_pc <= nextpc;        //������Ч������������ı�PCֵ
        inst  <= inst_sram_rdata;
    end
end

//assign inst_sram_en    = to_fs_valid && fs_allowin;
//assign inst_sram_wen   = 4'h0;

//assign inst_sram_wdata = 32'b0;

// ID stage
/*����׶�ʵ��������ͨ�������ʹ���ź�ds_stall����ds_allowin��ʹ��IF�ε�ָ���޷�����ID��*/

//  EX��Ϊloadָ���loadָ���Ŀ�ļĴ����뵱ǰ�ķ�0Դ�Ĵ�����ͬ������Ҫ����һ�ģ�
assign ds_stall = dst_is_r31 ? 0 : 
                    dst_is_rt ? (es_is_load_op && es_valid &&  rs==es_dest && rs!=0) 
                    : (es_is_load_op && es_valid)&&((rs==es_dest&&rs!=0)||(rt==es_dest&&rt!=0)) ;           
assign ds_ready_go    = !ds_stall;
assign ds_allowin     = !ds_valid || ds_ready_go && es_allowin;
assign ds_to_es_valid = ds_valid && ds_ready_go;
always @(posedge clk) begin
    if (reset) begin
        ds_valid <= 1'b0;
    end
    else if (ds_allowin) begin
        ds_valid <= fs_to_ds_valid;
    end

    if (fs_to_ds_valid && ds_allowin) begin
        ds_pc   <= fs_pc;
        ds_inst <= inst;       /*ע�⣬����ͬʱ��ȡָ���ַ��ָ��*/
    end
end
/*ָ������*/
//��һ������ȡָ��ĸ�����ֵ
assign op   = ds_inst[31:26];//op(6) rs(5) rt(5) rd(5) func(6) Ϊ�ͼĴ�����ָ��
assign rs   = ds_inst[25:21];
assign rt   = ds_inst[20:16];
assign rd   = ds_inst[15:11];
assign sa   = ds_inst[10: 6];
assign func = ds_inst[ 5: 0];
assign imm  = ds_inst[15: 0];//op(6) rs(5) rt(5) imm(16)Ϊ��������ָ��
assign jidx = ds_inst[25: 0];//op(6) jidx(26)Ϊ��ת��ָ��
//�ڶ�������λ��Ϊ5��6�Ĳ���������3-8���빤��
decoder_6_64 u_dec0(.in(op  ), .out(op_d  ));
decoder_6_64 u_dec1(.in(func), .out(func_d));
decoder_5_32 u_dec2(.in(rs  ), .out(rs_d  ));
decoder_5_32 u_dec3(.in(rt  ), .out(rt_d  ));
decoder_5_32 u_dec4(.in(rd  ), .out(rd_d  ));
decoder_5_32 u_dec5(.in(sa  ), .out(sa_d  ));
//������������ָ�����ͣ�����ppt33ҳ���ݣ��ǵĻ���Ϊ1
assign inst_addu   = op_d[6'h00] & func_d[6'h21] & sa_d[5'h00];
assign inst_subu   = op_d[6'h00] & func_d[6'h23] & sa_d[5'h00];
assign inst_slt    = op_d[6'h00] & func_d[6'h2a] & sa_d[5'h00];
assign inst_sltu   = op_d[6'h00] & func_d[6'h2b] & sa_d[5'h00];
assign inst_and    = op_d[6'h00] & func_d[6'h24] & sa_d[5'h00];
assign inst_or     = op_d[6'h00] & func_d[6'h25] & sa_d[5'h00];
assign inst_xor    = op_d[6'h00] & func_d[6'h26] & sa_d[5'h00];
assign inst_nor    = op_d[6'h00] & func_d[6'h27] & sa_d[5'h00];
assign inst_sll    = op_d[6'h00] & func_d[6'h00] & rs_d[5'h00];
assign inst_srl    = op_d[6'h00] & func_d[6'h02] & rs_d[5'h00];
assign inst_sra    = op_d[6'h00] & func_d[6'h03] & rs_d[5'h00];
assign inst_addiu  = op_d[6'h09];
assign inst_lui    = op_d[6'h0f] & rs_d[5'h00];
assign inst_lw     = op_d[6'h23];
assign inst_sw     = op_d[6'h2b];
assign inst_beq    = op_d[6'h04];
assign inst_bne    = op_d[6'h05];
assign inst_jal    = op_d[6'h03];
assign inst_jr     = op_d[6'h00] & func_d[6'h08] & rt_d[5'h00] & rd_d[5'h00] & sa_d[5'h00];
//���Ĳ���ALU�����������
assign alu_op[ 0] = inst_addu | inst_addiu | inst_lw | inst_sw | inst_jal;
assign alu_op[ 1] = inst_subu;
assign alu_op[ 2] = inst_slt;
assign alu_op[ 3] = inst_sltu;
assign alu_op[ 4] = inst_and;
assign alu_op[ 5] = inst_nor;
assign alu_op[ 6] = inst_or;
assign alu_op[ 7] = inst_xor;
assign alu_op[ 8] = inst_sll;
assign alu_op[ 9] = inst_srl;
assign alu_op[10] = inst_sra;
assign alu_op[11] = inst_lui;
//���岽�����ÿ����ź���
assign src1_is_sa   = inst_sll   | inst_srl | inst_sra;
assign src1_is_pc   = inst_jal;
assign src2_is_imm  = inst_addiu | inst_lui | inst_lw | inst_sw;
assign src2_is_8    = inst_jal;//jalָ�����һ��Ϊpc+8
assign res_from_mem = inst_lw;//��ȡ�洢����ֵ
assign dst_is_r31   = inst_jal;//31�żĴ���
assign dst_is_rt    = inst_addiu | inst_lui | inst_lw;
assign gr_we        = ~inst_sw & ~inst_beq & ~inst_bne & ~inst_jr;//�Ĵ�����д��Ч
assign mem_we       = inst_sw;//���ݴ洢��дʹ��
//Ŀ�ļĴ���Ϊ31�Ż�rt��rd
assign dest         = dst_is_r31 ? 5'd31 :
                      dst_is_rt  ? rt    : 
                                   rd;
assign is_load_op   = inst_lw;       //��ȡ�洢������

assign rf_raddr1 = rs;
assign rf_raddr2 = rt;
//�Ĵ���
regfile u_regfile(
    .clk    (clk      ),
    .raddr1 (rf_raddr1),
    .rdata1 (rf_rdata1),
    .raddr2 (rf_raddr2),
    .rdata2 (rf_rdata2),
    .we     (rf_we    ),  //�Ĵ���дʹ���ź�
    .waddr  (rf_waddr ),
    .wdata  (rf_wdata )
    );

assign rs_mch_es_dst = es_valid && es_gr_we && !es_is_load_op && (es_dest!=5'b0) && (es_dest==rs);           //ǰ������ź�:EX��Ҫд�ļĴ���Ϊrs
assign rt_mch_es_dst = es_valid && es_gr_we && !es_is_load_op && (es_dest!=5'b0) && (es_dest==rt) && !dst_is_rt; //ǰ������ź�:EX��Ҫд�ļĴ���Ϊrt�ҵ�ǰָ��rt����Ŀ�ļĴ���
assign rs_mch_ms_dst = ms_valid && ms_gr_we && (ms_dest!=5'b0) && (ms_dest==rs); //ǰ������ź�
assign rt_mch_ms_dst = ms_valid && ms_gr_we && (ms_dest!=5'b0) && (ms_dest==rt) && !dst_is_rt; //ǰ������ź�
assign rs_mch_ws_dst = ws_valid && ws_gr_we && (ws_dest!=5'b0) && (ws_dest==rs); //ǰ������ź�
assign rt_mch_ws_dst = ws_valid && ws_gr_we && (ws_dest!=5'b0) && (ws_dest==rt) && !dst_is_rt; //ǰ������ź�
assign rs_value = rs_mch_es_dst ? alu_result      :  //ǰ��������ΪEX�μ�������ֱ�ӽ�alu�����ֵ
                  rs_mch_ms_dst ? final_result    :  	//ǰ������,MEM�ε�������  
                  rs_mch_ws_dst ? rf_wdata :  		//ǰ������WB��д�ص�����
                                  rf_rdata1;         
assign rt_value = rt_mch_es_dst ? alu_result      :   //ǰ������
                  rt_mch_ms_dst ? final_result    :   //ǰ������MEM�ε�������
                  rt_mch_ws_dst ? rf_wdata :   //ǰ������WB��д�ص�����    
                                  rf_rdata2;          

assign rs_eq_rt = (rs_value == rt_value);
assign br_taken = (   inst_beq  &&  rs_eq_rt
                   || inst_bne  && !rs_eq_rt
                   || inst_jal
                   || inst_jr
                  ) && ds_valid; //Ϊת��ָ���ID����Ч
assign br_target = (inst_beq || inst_bne) ? (fs_pc + {{14{imm[15]}}, imm[15:0], 2'b0}) :  //��Ϊ�Ƚ�ת��ָ���pcֵΪIF�ε�PCֵ+imm������չ��������λ
                   (inst_jr)              ? rs_value :      //��Ϊjrָ���PCֵ����rs�Ĵ�����ֵ
                  /*inst_jal*/              {fs_pc[31:28], jidx[25:0], 2'b0};   //����Ϊjalָ�PCֵ�ĵ�28λΪjidx������λ

// EXE stage
assign es_ready_go    = 1'b1;
assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid = es_valid && es_ready_go;
always @(posedge clk) begin
    if (reset) begin
        es_valid <= 1'b0;
    end
    else if (es_allowin) begin
        es_valid <= ds_to_es_valid;
    end

    if (ds_to_es_valid && es_allowin) begin
        es_pc           <= ds_pc;
        es_rs_value     <= rs_value;
        es_rt_value     <= rt_value;
        es_imm          <= imm;
        es_alu_op       <= alu_op;
        es_src1_is_sa   <= src1_is_sa;
        es_src1_is_pc   <= src1_is_pc;
        es_src2_is_imm  <= src2_is_imm;
        es_src2_is_8    <= src2_is_8;
        es_res_from_mem <= res_from_mem;
        es_gr_we        <= gr_we;
        es_mem_we       <= mem_we;
        es_dest         <= dest;
        es_is_load_op   <= is_load_op;           //es�׶�ȡ������
    end
end

assign alu_src1 = es_src1_is_sa  ? {27'b0, es_imm[10:6]} : 
                  es_src1_is_pc  ? es_pc[31:0] :
                                   es_rs_value;
assign alu_src2 = es_src2_is_imm ? {{16{es_imm[15]}}, es_imm[15:0]} : 
                  es_src2_is_8   ? 32'd8 :
                                   es_rt_value;

alu u_alu(
    .alu_op     (es_alu_op ),
    .alu_src1   (alu_src1  ),
    .alu_src2   (alu_src2  ),
    .alu_result (alu_result)
    );

//assign data_sram_en    = 1'b1;
assign data_sram_wen   = es_mem_we&&es_valid ? 4'hf : 4'h0;
assign data_sram_addr  = alu_result;
assign data_sram_wdata = es_rt_value;

// MEM stage
assign ms_ready_go    = 1'b1;
assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;
always @(posedge clk) begin
    if (reset) begin
        ms_valid <= 1'b0;
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;
    end

    if (es_to_ms_valid && ms_allowin) begin
        ms_pc           <= es_pc;
        ms_dest         <= es_dest;
        ms_res_from_mem <= es_res_from_mem;
        ms_gr_we        <= es_gr_we;
        ms_alu_result   <= alu_result;
    end
end

assign mem_result = data_sram_rdata; //�����ݴ洢����ȡ�Ľ��(input�ź�)

assign final_result = ms_res_from_mem ? mem_result : ms_alu_result;//��Ϊ��ȡ�洢��������Ϊ�ϣ�����ΪALU����Ľ���������ݴ�������

// WB stage
assign ws_ready_go = 1'b1;
assign ws_allowin  = !ws_valid || ws_ready_go; //ʼ��Ϊ1
always @(posedge clk) begin
    if (reset) begin
        ws_valid <= 1'b0;
    end
    else if (ws_allowin) begin
        ws_valid <= ms_to_ws_valid;
    end

    if (ms_to_ws_valid && ws_allowin) begin
        ws_pc           <= ms_pc;
        ws_gr_we        <= ms_gr_we;
        ws_dest         <= ms_dest;
        ws_final_result <= final_result;
    end
end

assign rf_we    = ws_gr_we&&ws_valid;
assign rf_waddr = ws_dest;
assign rf_wdata = ws_final_result;


endmodule

