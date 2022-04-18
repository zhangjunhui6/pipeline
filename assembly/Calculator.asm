addi $t0,$zero,0	#标记后缀运算数栈的栈顶指针
addi $t1,$zero,0	#标记后缀运算符栈的栈顶指针
addi $s1,$zero,64             #将等号压入运算符栈中
addi $t1,$t1,4
addi $t2,$zero,0
addi $v0,$zero,0
sw $s1,0x1400($t1)    #地址为0x1400
WAIT:	lw $s0,0x4ff4($zero)   #读取按键信息到s0寄存器中，8个按键(从左到右依次为):重启，等于，置数，上中下(+*/),左右括号
	beq $s0, $zero,SHOW    #判断是否有按键按下,若无则继续查询等待
	xor $s1,$s0,$t2        #判断是否与上一个按键相同
	beq $s1,$zero,SHOW     #相同则继续等待
   	j DELAY_20MS         #若有按键则延迟20ms,在判断
PRSD:	lw $s1,0x4ff4($zero)
	xor $s1,$s1,$s0         
	bne $s1,$zero,WAIT       #判断按键是否按下了超过20ms,否则为抖动
	addi $t2,$s0,0           #存储上一个按键
	xori $s1, $s0, 128      #判断是否是重启键按下
	beq $s1, $zero,CLEAR     #    若是则跳转到重启按键处理程序
	xori $s1, $s0, 64      #判断是否是等于键按下
	beq $s1, $zero,EQUAL     #    若是则跳转到等于按键处理程序
	xori $s1,$s0,32          #判断是否是置数键按下
	beq $s1,$zero,LOAD      #    若是则跳转到等于按键处理程序
	xori $s1, $s0, 16      #判断是否是上键按下(+)
	beq $s1, $zero, UP     #    若是则跳转到加法按键处理程序
	xori $s1, $s0, 8      #判断是否是中键按下(*)
	beq $s1, $zero, CNTR     #    若是则跳转到乘法按键处理程序
	xori $s1, $s0, 4      #判断是否是下键按下(/)
	beq $s1, $zero, DOWN     #    若是则跳转到除法按键处理程序
	xori $s1, $s0, 2      #判断是否是左键按下(
	beq $s1, $zero, LEFT     #    若是则跳转到左括号按键处理程序
	xori $s1, $s0, 1      #判断是否是右键按下)
	beq $s1, $zero, RIGHT     #    若是则跳转到右括号按键处理程序
	j WAIT                   #否则是多个按键同时按下
CLEAR:  addi $t0,$zero,0       #重启则清空二个栈指针   #重启按键处理程序 
	addi $t1,$zero,0
	addi $t2,$zero,0
	addi $v0,$zero,0
	addi $s1,$zero,64             #将等号压入运算符栈中
	addi $t1,$t1,4
	sw $s1,0x1400($t1)
	sw $t0,0x4ff0($zero)   
	j WAIT
EQUAL:  lw $s3, 0x1400($t1)    #读取运算符栈的栈顶元素  #等于按键处理程序         
	andi $s1, $s3, 64      #判断是否为等于	
	bne $s1,$zero,SHOW                 #运算结束，进行结果显示   #若不是等号，则需要将中间运算符全部运算
	addi $ra,$zero,0x00bc    #先将jr跳转回来的指令地址写进ra寄存器
	j CAL
	sll $zero,$zero,0   #ra存放本条指令的地址
	lw $s5,0x1000($t0)     
	addi $v0,$s5,0 
	j EQUAL              
LOAD:   lw $s2, 0x4ffc($zero)  #读取开关信息到s2寄存器(八位二进制补码) #置数按键处理程序
	addi $t0,$t0,4         #运算数入栈
	sw $s2,0x1000($t0)
	addi $v0,$s2,0
	j SHOW
UP:     lw $s3, 0x1400($t1)    #读取运算符栈的栈顶元素  #加法按键处理程序
	andi $s1, $s3, 64      #判断是否为等于
	bne $s1, $zero,PUSH     #    若是则入栈
	andi $s1, $s3, 2      #判断是否为左括号(
	bne $s1, $zero, PUSH     #    若是则入栈   #若为加乘除，则需要将中间运算符全部运算
	addi $ra,$zero,0x00fc
	j CAL
	sll $zero, $zero,0      #ra存放本条指令的地址
	j UP	
CNTR:   lw $s3, 0x1400($t1)    #读取运算符栈的栈顶元素  #乘法按键处理程序
	andi $s1, $s3, 64      #判断是否为等于
	bne $s1, $zero,PUSH     #    若是则入栈
	andi $s1, $s3, 2      #判断是否为左括号(
	bne $s1, $zero, PUSH     #    若是则入栈
	andi $s1, $s3, 16      #判断是否为加法(+)
	bne $s1, $zero, PUSH     #    若是则入栈   #若为乘除，则需要将中间运算符全部运算
	addi $ra,$zero,0x0128	
	j CAL
	sll $zero, $zero,0 #ra存放本条指令的地址     
	j CNTR              	
DOWN:   lw $s3, 0x1400($t1)    #读取运算符栈的栈顶元素   #除法按键处理程序
	andi $s1, $s3, 64      #判断是否为等于
	bne $s1, $zero,PUSH     #    若是则入栈
	andi $s1, $s3, 16      #判断是否为加法(+)
	bne $s1, $zero, PUSH     #    若是则入栈  
	andi $s1, $s3, 2      #判断是否为左括号(
	bne $s1, $zero, PUSH     #    若是则入栈   #若为乘除，则需要将中间运算符全部运算
	addi $ra,$zero,0x0154
	j CAL
	sll $zero, $zero,0      #ra存放本条指令的地址
	j DOWN               	
LEFT:   lw $s3, 0x1400($t1)    #读取运算符栈的栈顶元素   #左括号按键处理程序
	andi $s1, $s3, 64      #判断是否为等于
	bne $s1, $zero,PUSH     #    若是则入栈
	andi $s1, $s3, 16      #判断是否为加法(+)
	bne $s1, $zero, PUSH     #    若是则入栈              
	andi $s1, $s3, 8      #判断是否为乘法(*)
	bne $s1, $zero, PUSH     #    若是则入栈              
	andi $s1, $s3, 4      #判断是否为除法(/)
	bne $s1, $zero, PUSH     #    若是则入栈              
	andi $s1, $s3, 2      #判断是否为左括号(
	bne $s1, $zero, PUSH     #    若是则入栈
RIGHT:  lw $s3, 0x1400($t1)    #读取运算符栈的栈顶元素  #右括号按键处理程序
	xori $s1,$s3,64       #判断是否为等号
	bne $s1,$zero,RIGHT_1 #若不为等号则跳转
		addi $s1,$zero,4   #否则为错误的情况
		sw $s1,0x4ff0($zero)
		addi $t0,$zero,0       
		addi $t1,$zero,0		
		addi $v0,$zero,0
		j WAIT
	RIGHT_1:andi $s1, $s3, 2      #判断是否为左括号(
	bne $s1, $zero, POP     #    若是则出栈   #否则需要将中间运算符全部运算
	addi $ra,$zero,0x01bc
	j CAL
	sll $zero, $zero,0      #ra存放本条指令的地址
	j RIGHT	
PUSH:   addi $t1,$t1,4    #将运算符入栈后跳转到WAIT
	sw $s0,0x1400($t1)
	j WAIT
POP:	addi $t1,$t1,-4   #将运算符出栈后跳转到WAIT
	j WAIT
CAL:	addi $s1,$zero,4
	sub $s1,$s1,$t0
	bltz $s1,CAL_1 #若数栈里面数超过一个，则跳转;否则错误
	addi $s1,$zero,4
	sw $s1,0x4ff0($zero)
	addi $t0,$zero,0       
	addi $t1,$zero,0		
	addi $v0,$zero,0
	j WAIT   
	CAL_1:lw $s5,0x1000($t0)   #进行运算
	addi $t0,$t0,-4	#取出第二个操作数
	lw $s6,0x1000($t0)
	addi $t0,$t0,-4	#取出第一个操作数
	lw $s7,0x1400($t1)
	addi $t1,$t1,-4	#取出栈顶操作符号
	andi $s1, $s7, 16      #判断是否为加法(+)
	bne $s1, $zero,ADD     #    若是则进行加法运算
	andi $s1, $s7, 8      #判断是否为乘法(*)
	bne $s1, $zero,MUL     #    若是则进行乘法运算
	andi $s1, $s7, 4      #判断是否为除法(/)
	bne $s1, $zero,DIV     #    若是则进行除法运算
	addi $s1,$zero,4       #前面三种都不是，则是错误的左括号，直接错误处理
	sw $s1,0x4ff0($zero)
	addi $t0,$zero,0       
	addi $t1,$zero,0		
	addi $v0,$zero,0
	j WAIT	
	ADD:	add $s7,$s6,$s5
		addi $t0,$t0,4
		sw $s7,0x1000($t0)
		jr $ra
	MUL:	srl $s1,$s5,31   #将s5中的数逻辑右移31位，后判断结果是否为0   #先判断乘数(s5)的符号，若为负数并进行转正，结果在取反
		bne $s1,$zero,IND   #结果不为0则是负数	#结果为0的乘法计算过程
		add $s1,$zero,$s5
		addi $s7,$zero,0
		mul_next1:	add $s7,$s7,$s6
				addi $s1,$s1,-1
				bne $s1,$zero,mul_next1
				j CON
		IND:	sub $s5,$zero,$s5  #s5取反
			addi $s1,$s5,0
			addi $s7,$zero,0
			mul_next2:	add $s7,$s7,$s6
					addi $s1,$s1,-1
					bne $s1,$zero,mul_next2
			sub $s7,$zero,$s7    #结果取反
		CON:	addi $t0,$t0,4
			sw $s7,0x1000($t0)
			jr $ra
	DIV:	bne $s5,$zero,DIV_1  #判断除数是否为0，若为0则直接跳出
		addi $s1,$zero,1
		sw $s1,0x4ff0($zero)
		addi $t0,$zero,0       
		addi $t1,$zero,0		
		addi $v0,$zero,0
		j WAIT
	DIV_1:	xor $s1,$s6,$s5    #首先判断除数和被除数同号还是异号，决定最后得到的结果是否要取反
		srl $s1,$s1,31     #将s1逻辑右移31位，为0则同号，为1则异号
		srl $s7,$s6,31	   #除数和被除数取正
		beq $s7,$zero,div_next1 #结果为0则不需要取反
		sub $s6,$zero,$s6
		div_next1:	srl $s7,$s5,31
				beq $s7,$zero,div_next2 #结果为0则不需要取反
				sub $s5,$zero,$s5
		div_next2: 	addi $s7,$zero,0
				div_next3:	sub $s4,$s6,$s5   #判断被除数减去除数是否大于0   #后面进行除法运算
						bgtz $s4,div_next4
						beq $s4,$zero,div_next4
						j div_next5
				div_next4:	addi $s7,$s7,1
						sub $s6,$s6,$s5
						j div_next3
		div_next5:	beq $s1,$zero,div_next6  #运算结束，判断是否需取反
				sub $s7,$zero,$s7
		div_next6:	addi $t0,$t0,4
				sw $s7,0x1000($t0)
				jr $ra
SHOW:	add $s2,$v0,$zero
	srl $s1,$v0,31
	beq $s1,$zero,SHOW_1
	sub $s2,$zero,$v0   #s2取v0的绝对值
	SHOW_1:addi $k0,$zero,1664 	#k1=1000万
	addi $k1,$zero,2441	
	sll $k1, $k1,12 		
	add $k1,$k0,$k1
	sub $s1,$s2,$k1  #小于0则没有溢出
	bltz $s1,SHOW_2
	addi $s1,$zero,2  #溢出处理程序
	sw $s1,0x4ff0($zero)	
	addi $t0,$zero,0       
	addi $t1,$zero,0		
	addi $v0,$zero,0
	j WAIT  
	SHOW_2: addi $t3,$v0,0
	srl $s1,$t3,31  #显示最后的运算结果  #首先判断整个数的符号，并在第一个数码管中显示出来。
	bne $s1,$zero,show_next1  #结果不为0则跳转，第一个数码显示负号
	addi $t7,$zero,1
	sll $s2,$t7,15	#二进制1000_0000_0000_0000
	sw $s2,0x4ff8($zero)   #将符号" "写进数码管中
	j show_next2
	show_next1:	sub $t3,$zero,$t3  #数取反
			addi $t7,$zero,513
			sll $s2,$t7,6   
			sw $s2,0x4ff8($zero)  #将符号"-"写进数码管中，二进制1000_0000_0100_0000
	show_next2:	addi $gp,$zero,0x0380  #延时
			j DELAY_5MS
			sll $zero,$zero,0 	
	addi $t7,$zero,1664 	#0110, 1000, 0000 表示10000000低12位    //初始化位s3为千万位和片选信号s7为1000_0000_0000_0000
	addi $t8,$zero,2441	#1001, 1000, 1001 表示10000000高12位
	sll $t8, $t8,12 		#10000000高12位左移12位      
	add $s3,$t7,$t8  #s3为十进制10000000   
	addi $t7,$zero,1
	sll $s7,$t7,15  #s7为二进制1000_0000_0000_0000               #片选信号,s7s4分别为片选和段选信号，进行按位或得到最后的要存储的数据
	show_next3:	addi $s6,$zero,0   #s6存放这一位的数值大小
			srl $s7,$s7,1	#s7右移一位,s7为片选信号
	addi $k0,$zero,1664 	#首先判断当前处理的是哪一位
	addi $k1,$zero,2441	
	sll $k1, $k1,12 		
	add $k1,$k0,$k1  
	beq $s3,$k1,BAIWAN     #百万位
	addi $k1,$zero,976  
	addi $k0,$zero,576  
	sll $k1,$k1,10 
	add $k1,$k0,$k1  
	beq $s3,$k1,SHIWAN    #十万位
	addi $k1,$zero,390
	sll $k1,$k1,8
	addi $k0,$zero,160
	add $k1,$k1,$k0    
	beq $s3,$k1,YIWAN     #一万位
	addi $k1,$zero,10000
	beq $s3,$k1,QIAN      #千位
	addi $k1,$zero,1000
	beq $s3,$k1,BAI       #百位
	addi $k1,$zero,100
	beq $s3,$k1,SHI       #十位
	addi $k1,$zero,10
	beq $s3,$k1,YI        #个位
	BAIWAN: addi $t7,$zero,976  #一百万的高10位
		addi $t8,$zero,576  #低10位
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
	show_next4:	sub $s5,$t3,$s3      #判断该位的数值	
			bgtz $s5,show_next5            #大于等于0则跳转
			beq $s5,$zero,show_next5
			j show_next6
	show_next5:	addi $s6,$s6,1  
			sub $t3,$t3,$s3
			j show_next4
	show_next6: 	addi $at,$zero,0	#运算结束，进行数据存储		#首先根据数值确定段选信号
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
	show_next7:  or $s2,$s7,$s4 #将数码管信息存到地址单元0x0000fff8中
		     sw $s2,0x4ff8($zero)
	addi $gp,$zero,0x0520
	j DELAY_5MS
	sll $zero,$zero,0	    
	addi $s2,$zero,256
	bne $s2,$s7,show_next3  #跳出数值显示循环的条件,当片选信号为最后一位则结束
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
