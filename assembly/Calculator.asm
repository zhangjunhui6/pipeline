addi $t0,$zero,0	#��Ǻ�׺������ջ��ջ��ָ��
addi $t1,$zero,0	#��Ǻ�׺�����ջ��ջ��ָ��
addi $s1,$zero,64             #���Ⱥ�ѹ�������ջ��
addi $t1,$t1,4
addi $t2,$zero,0
addi $v0,$zero,0
sw $s1,0x1400($t1)    #��ַΪ0x1400
WAIT:	lw $s0,0x4ff4($zero)   #��ȡ������Ϣ��s0�Ĵ����У�8������(����������Ϊ):���������ڣ�������������(+*/),��������
	beq $s0, $zero,SHOW    #�ж��Ƿ��а�������,�����������ѯ�ȴ�
	xor $s1,$s0,$t2        #�ж��Ƿ�����һ��������ͬ
	beq $s1,$zero,SHOW     #��ͬ������ȴ�
   	j DELAY_20MS         #���а������ӳ�20ms,���ж�
PRSD:	lw $s1,0x4ff4($zero)
	xor $s1,$s1,$s0         
	bne $s1,$zero,WAIT       #�жϰ����Ƿ����˳���20ms,����Ϊ����
	addi $t2,$s0,0           #�洢��һ������
	xori $s1, $s0, 128      #�ж��Ƿ�������������
	beq $s1, $zero,CLEAR     #    ��������ת�����������������
	xori $s1, $s0, 64      #�ж��Ƿ��ǵ��ڼ�����
	beq $s1, $zero,EQUAL     #    ��������ת�����ڰ����������
	xori $s1,$s0,32          #�ж��Ƿ�������������
	beq $s1,$zero,LOAD      #    ��������ת�����ڰ����������
	xori $s1, $s0, 16      #�ж��Ƿ����ϼ�����(+)
	beq $s1, $zero, UP     #    ��������ת���ӷ������������
	xori $s1, $s0, 8      #�ж��Ƿ����м�����(*)
	beq $s1, $zero, CNTR     #    ��������ת���˷������������
	xori $s1, $s0, 4      #�ж��Ƿ����¼�����(/)
	beq $s1, $zero, DOWN     #    ��������ת�����������������
	xori $s1, $s0, 2      #�ж��Ƿ����������(
	beq $s1, $zero, LEFT     #    ��������ת�������Ű����������
	xori $s1, $s0, 1      #�ж��Ƿ����Ҽ�����)
	beq $s1, $zero, RIGHT     #    ��������ת�������Ű����������
	j WAIT                   #�����Ƕ������ͬʱ����
CLEAR:  addi $t0,$zero,0       #��������ն���ջָ��   #��������������� 
	addi $t1,$zero,0
	addi $t2,$zero,0
	addi $v0,$zero,0
	addi $s1,$zero,64             #���Ⱥ�ѹ�������ջ��
	addi $t1,$t1,4
	sw $s1,0x1400($t1)
	sw $t0,0x4ff0($zero)   
	j WAIT
EQUAL:  lw $s3, 0x1400($t1)    #��ȡ�����ջ��ջ��Ԫ��  #���ڰ����������         
	andi $s1, $s3, 64      #�ж��Ƿ�Ϊ����	
	bne $s1,$zero,SHOW                 #������������н����ʾ   #�����ǵȺţ�����Ҫ���м������ȫ������
	addi $ra,$zero,0x00bc    #�Ƚ�jr��ת������ָ���ַд��ra�Ĵ���
	j CAL
	sll $zero,$zero,0   #ra��ű���ָ��ĵ�ַ
	lw $s5,0x1000($t0)     
	addi $v0,$s5,0 
	j EQUAL              
LOAD:   lw $s2, 0x4ffc($zero)  #��ȡ������Ϣ��s2�Ĵ���(��λ�����Ʋ���) #���������������
	addi $t0,$t0,4         #��������ջ
	sw $s2,0x1000($t0)
	addi $v0,$s2,0
	j SHOW
UP:     lw $s3, 0x1400($t1)    #��ȡ�����ջ��ջ��Ԫ��  #�ӷ������������
	andi $s1, $s3, 64      #�ж��Ƿ�Ϊ����
	bne $s1, $zero,PUSH     #    ��������ջ
	andi $s1, $s3, 2      #�ж��Ƿ�Ϊ������(
	bne $s1, $zero, PUSH     #    ��������ջ   #��Ϊ�ӳ˳�������Ҫ���м������ȫ������
	addi $ra,$zero,0x00fc
	j CAL
	sll $zero, $zero,0      #ra��ű���ָ��ĵ�ַ
	j UP	
CNTR:   lw $s3, 0x1400($t1)    #��ȡ�����ջ��ջ��Ԫ��  #�˷������������
	andi $s1, $s3, 64      #�ж��Ƿ�Ϊ����
	bne $s1, $zero,PUSH     #    ��������ջ
	andi $s1, $s3, 2      #�ж��Ƿ�Ϊ������(
	bne $s1, $zero, PUSH     #    ��������ջ
	andi $s1, $s3, 16      #�ж��Ƿ�Ϊ�ӷ�(+)
	bne $s1, $zero, PUSH     #    ��������ջ   #��Ϊ�˳�������Ҫ���м������ȫ������
	addi $ra,$zero,0x0128	
	j CAL
	sll $zero, $zero,0 #ra��ű���ָ��ĵ�ַ     
	j CNTR              	
DOWN:   lw $s3, 0x1400($t1)    #��ȡ�����ջ��ջ��Ԫ��   #���������������
	andi $s1, $s3, 64      #�ж��Ƿ�Ϊ����
	bne $s1, $zero,PUSH     #    ��������ջ
	andi $s1, $s3, 16      #�ж��Ƿ�Ϊ�ӷ�(+)
	bne $s1, $zero, PUSH     #    ��������ջ  
	andi $s1, $s3, 2      #�ж��Ƿ�Ϊ������(
	bne $s1, $zero, PUSH     #    ��������ջ   #��Ϊ�˳�������Ҫ���м������ȫ������
	addi $ra,$zero,0x0154
	j CAL
	sll $zero, $zero,0      #ra��ű���ָ��ĵ�ַ
	j DOWN               	
LEFT:   lw $s3, 0x1400($t1)    #��ȡ�����ջ��ջ��Ԫ��   #�����Ű����������
	andi $s1, $s3, 64      #�ж��Ƿ�Ϊ����
	bne $s1, $zero,PUSH     #    ��������ջ
	andi $s1, $s3, 16      #�ж��Ƿ�Ϊ�ӷ�(+)
	bne $s1, $zero, PUSH     #    ��������ջ              
	andi $s1, $s3, 8      #�ж��Ƿ�Ϊ�˷�(*)
	bne $s1, $zero, PUSH     #    ��������ջ              
	andi $s1, $s3, 4      #�ж��Ƿ�Ϊ����(/)
	bne $s1, $zero, PUSH     #    ��������ջ              
	andi $s1, $s3, 2      #�ж��Ƿ�Ϊ������(
	bne $s1, $zero, PUSH     #    ��������ջ
RIGHT:  lw $s3, 0x1400($t1)    #��ȡ�����ջ��ջ��Ԫ��  #�����Ű����������
	xori $s1,$s3,64       #�ж��Ƿ�Ϊ�Ⱥ�
	bne $s1,$zero,RIGHT_1 #����Ϊ�Ⱥ�����ת
		addi $s1,$zero,4   #����Ϊ��������
		sw $s1,0x4ff0($zero)
		addi $t0,$zero,0       
		addi $t1,$zero,0		
		addi $v0,$zero,0
		j WAIT
	RIGHT_1:andi $s1, $s3, 2      #�ж��Ƿ�Ϊ������(
	bne $s1, $zero, POP     #    �������ջ   #������Ҫ���м������ȫ������
	addi $ra,$zero,0x01bc
	j CAL
	sll $zero, $zero,0      #ra��ű���ָ��ĵ�ַ
	j RIGHT	
PUSH:   addi $t1,$t1,4    #���������ջ����ת��WAIT
	sw $s0,0x1400($t1)
	j WAIT
POP:	addi $t1,$t1,-4   #���������ջ����ת��WAIT
	j WAIT
CAL:	addi $s1,$zero,4
	sub $s1,$s1,$t0
	bltz $s1,CAL_1 #����ջ����������һ��������ת;�������
	addi $s1,$zero,4
	sw $s1,0x4ff0($zero)
	addi $t0,$zero,0       
	addi $t1,$zero,0		
	addi $v0,$zero,0
	j WAIT   
	CAL_1:lw $s5,0x1000($t0)   #��������
	addi $t0,$t0,-4	#ȡ���ڶ���������
	lw $s6,0x1000($t0)
	addi $t0,$t0,-4	#ȡ����һ��������
	lw $s7,0x1400($t1)
	addi $t1,$t1,-4	#ȡ��ջ����������
	andi $s1, $s7, 16      #�ж��Ƿ�Ϊ�ӷ�(+)
	bne $s1, $zero,ADD     #    ��������мӷ�����
	andi $s1, $s7, 8      #�ж��Ƿ�Ϊ�˷�(*)
	bne $s1, $zero,MUL     #    ��������г˷�����
	andi $s1, $s7, 4      #�ж��Ƿ�Ϊ����(/)
	bne $s1, $zero,DIV     #    ��������г�������
	addi $s1,$zero,4       #ǰ�����ֶ����ǣ����Ǵ���������ţ�ֱ�Ӵ�����
	sw $s1,0x4ff0($zero)
	addi $t0,$zero,0       
	addi $t1,$zero,0		
	addi $v0,$zero,0
	j WAIT	
	ADD:	add $s7,$s6,$s5
		addi $t0,$t0,4
		sw $s7,0x1000($t0)
		jr $ra
	MUL:	srl $s1,$s5,31   #��s5�е����߼�����31λ�����жϽ���Ƿ�Ϊ0   #���жϳ���(s5)�ķ��ţ���Ϊ����������ת���������ȡ��
		bne $s1,$zero,IND   #�����Ϊ0���Ǹ���	#���Ϊ0�ĳ˷��������
		add $s1,$zero,$s5
		addi $s7,$zero,0
		mul_next1:	add $s7,$s7,$s6
				addi $s1,$s1,-1
				bne $s1,$zero,mul_next1
				j CON
		IND:	sub $s5,$zero,$s5  #s5ȡ��
			addi $s1,$s5,0
			addi $s7,$zero,0
			mul_next2:	add $s7,$s7,$s6
					addi $s1,$s1,-1
					bne $s1,$zero,mul_next2
			sub $s7,$zero,$s7    #���ȡ��
		CON:	addi $t0,$t0,4
			sw $s7,0x1000($t0)
			jr $ra
	DIV:	bne $s5,$zero,DIV_1  #�жϳ����Ƿ�Ϊ0����Ϊ0��ֱ������
		addi $s1,$zero,1
		sw $s1,0x4ff0($zero)
		addi $t0,$zero,0       
		addi $t1,$zero,0		
		addi $v0,$zero,0
		j WAIT
	DIV_1:	xor $s1,$s6,$s5    #�����жϳ����ͱ�����ͬ�Ż�����ţ��������õ��Ľ���Ƿ�Ҫȡ��
		srl $s1,$s1,31     #��s1�߼�����31λ��Ϊ0��ͬ�ţ�Ϊ1�����
		srl $s7,$s6,31	   #�����ͱ�����ȡ��
		beq $s7,$zero,div_next1 #���Ϊ0����Ҫȡ��
		sub $s6,$zero,$s6
		div_next1:	srl $s7,$s5,31
				beq $s7,$zero,div_next2 #���Ϊ0����Ҫȡ��
				sub $s5,$zero,$s5
		div_next2: 	addi $s7,$zero,0
				div_next3:	sub $s4,$s6,$s5   #�жϱ�������ȥ�����Ƿ����0   #������г�������
						bgtz $s4,div_next4
						beq $s4,$zero,div_next4
						j div_next5
				div_next4:	addi $s7,$s7,1
						sub $s6,$s6,$s5
						j div_next3
		div_next5:	beq $s1,$zero,div_next6  #����������ж��Ƿ���ȡ��
				sub $s7,$zero,$s7
		div_next6:	addi $t0,$t0,4
				sw $s7,0x1000($t0)
				jr $ra
SHOW:	add $s2,$v0,$zero
	srl $s1,$v0,31
	beq $s1,$zero,SHOW_1
	sub $s2,$zero,$v0   #s2ȡv0�ľ���ֵ
	SHOW_1:addi $k0,$zero,1664 	#k1=1000��
	addi $k1,$zero,2441	
	sll $k1, $k1,12 		
	add $k1,$k0,$k1
	sub $s1,$s2,$k1  #С��0��û�����
	bltz $s1,SHOW_2
	addi $s1,$zero,2  #����������
	sw $s1,0x4ff0($zero)	
	addi $t0,$zero,0       
	addi $t1,$zero,0		
	addi $v0,$zero,0
	j WAIT  
	SHOW_2: addi $t3,$v0,0
	srl $s1,$t3,31  #��ʾ����������  #�����ж��������ķ��ţ����ڵ�һ�����������ʾ������
	bne $s1,$zero,show_next1  #�����Ϊ0����ת����һ��������ʾ����
	addi $t7,$zero,1
	sll $s2,$t7,15	#������1000_0000_0000_0000
	sw $s2,0x4ff8($zero)   #������" "д���������
	j show_next2
	show_next1:	sub $t3,$zero,$t3  #��ȡ��
			addi $t7,$zero,513
			sll $s2,$t7,6   
			sw $s2,0x4ff8($zero)  #������"-"д��������У�������1000_0000_0100_0000
	show_next2:	addi $gp,$zero,0x0380  #��ʱ
			j DELAY_5MS
			sll $zero,$zero,0 	
	addi $t7,$zero,1664 	#0110, 1000, 0000 ��ʾ10000000��12λ    //��ʼ��λs3Ϊǧ��λ��Ƭѡ�ź�s7Ϊ1000_0000_0000_0000
	addi $t8,$zero,2441	#1001, 1000, 1001 ��ʾ10000000��12λ
	sll $t8, $t8,12 		#10000000��12λ����12λ      
	add $s3,$t7,$t8  #s3Ϊʮ����10000000   
	addi $t7,$zero,1
	sll $s7,$t7,15  #s7Ϊ������1000_0000_0000_0000               #Ƭѡ�ź�,s7s4�ֱ�ΪƬѡ�Ͷ�ѡ�źţ����а�λ��õ�����Ҫ�洢������
	show_next3:	addi $s6,$zero,0   #s6�����һλ����ֵ��С
			srl $s7,$s7,1	#s7����һλ,s7ΪƬѡ�ź�
	addi $k0,$zero,1664 	#�����жϵ�ǰ���������һλ
	addi $k1,$zero,2441	
	sll $k1, $k1,12 		
	add $k1,$k0,$k1  
	beq $s3,$k1,BAIWAN     #����λ
	addi $k1,$zero,976  
	addi $k0,$zero,576  
	sll $k1,$k1,10 
	add $k1,$k0,$k1  
	beq $s3,$k1,SHIWAN    #ʮ��λ
	addi $k1,$zero,390
	sll $k1,$k1,8
	addi $k0,$zero,160
	add $k1,$k1,$k0    
	beq $s3,$k1,YIWAN     #һ��λ
	addi $k1,$zero,10000
	beq $s3,$k1,QIAN      #ǧλ
	addi $k1,$zero,1000
	beq $s3,$k1,BAI       #��λ
	addi $k1,$zero,100
	beq $s3,$k1,SHI       #ʮλ
	addi $k1,$zero,10
	beq $s3,$k1,YI        #��λ
	BAIWAN: addi $t7,$zero,976  #һ����ĸ�10λ
		addi $t8,$zero,576  #��10λ
		sll $t7,$t7,10 
		add $s3,$t7,$t8
		j show_next4
	SHIWAN: addi $t7,$zero,390
		sll $t7,$t7,8
		addi $t8,$zero,160
		add $s3,$t7,$t8
		j show_next4
	YIWAN:  addi $t7,$zero,78
		addi $t8,$zero,16
		sll $t7,$t7,7
		add $s3,$t7,$t8
		j show_next4
	QIAN:	addi $s3,$zero,1000
		j show_next4
	BAI:	addi $s3,$zero,100
		j show_next4
	SHI:	addi $s3,$zero,10
		j show_next4
	YI:	addi $s3,$zero,1
	show_next4:	sub $s5,$t3,$s3      #�жϸ�λ����ֵ	
			bgtz $s5,show_next5            #���ڵ���0����ת
			beq $s5,$zero,show_next5
			j show_next6
	show_next5:	addi $s6,$s6,1  
			sub $t3,$t3,$s3
			j show_next4
	show_next6: 	addi $at,$zero,0	#����������������ݴ洢		#���ȸ�����ֵȷ����ѡ�ź�
			beq $s6,$at,ZERO
			addi $at,$zero,1
			beq $s6,$at,ONE
			addi $at,$zero,2
			beq $s6,$at,TWO
			addi $at,$zero,3
			beq $s6,$at,THREE
			addi $at,$zero,4
			beq $s6,$at,FOUR
			addi $at,$zero,5
			beq $s6,$at,FIVE
			addi $at,$zero,6
			beq $s6,$at,SIX
			addi $at,$zero,7
			beq $s6,$at,SEVEN
			addi $at,$zero,8
			beq $s6,$at,EIGHT
			addi $at,$zero,9
			beq $s6,$at,NINE
	ZERO: addi $s4,$zero,63
		j show_next7
	ONE: addi $s4,$zero,6
		j show_next7
	TWO: addi $s4,$zero,91
		j show_next7
	THREE: addi $s4,$zero,79
		j show_next7
	FOUR: addi $s4,$zero,102
		j show_next7
	FIVE: addi $s4,$zero,109
		j show_next7
	SIX: addi $s4,$zero,125
		j show_next7
	SEVEN: addi $s4,$zero,7
		j show_next7
	EIGHT: addi $s4,$zero,127
		j show_next7
	NINE: addi $s4,$zero,111
	show_next7:  or $s2,$s7,$s4 #���������Ϣ�浽��ַ��Ԫ0x0000fff8��
		     sw $s2,0x4ff8($zero)
	addi $gp,$zero,0x0520
	j DELAY_5MS
	sll $zero,$zero,0	    
	addi $s2,$zero,256
	bne $s2,$s7,show_next3  #������ֵ��ʾѭ��������,��Ƭѡ�ź�Ϊ���һλ�����
	j WAIT
DELAY_20MS:	addi $s1,$zero,0x15f9           #5f9
		sll $s1,$s1,5
		next:	sll  $zero,$zero,0   #
			addi $s1,$s1,-1
			bne $s1,$zero,next
		j PRSD
DELAY_5MS:	addi $s1,$zero,1
		sll $s1,$s1,12
		next_1:	sll  $zero,$zero,0   #
			addi $s1,$s1,-1
			bne $s1,$zero,next_1
		jr $gp
		sll $zero,$zero,0
		sll $zero,$zero,0
