#Data segment

.data

# Cac dinh nghia bien

	soA: .float 0
	soB: .float 0
	buffer:     	.space 8
 # filename
        filename: 	.asciiz "FLOAT23.BIN"
 # Các câu nh?c d? li?u
str_dl1: .asciiz "Nhap so A : " 
str_dl2: .asciiz "Nhap so B : " 

	
# Cac cau nhac nhap du lieu

	
	kq: 
		.asciiz "A / B = "
	nan: 
		.asciiz "NaN"
	I: 
		.asciiz "Infinity"
	
# Code segment
.text
.globl main

main:
# M? file
	addi	$v0, $zero,13  	# system call for open file
	la   	$a0, filename     
  	addi   	$a1, $zero, 0  	# Mo de doc (flags are 0: read, 1: write)
  	addi   	$a2, $zero, 0        
  	syscall            	    # Mo file (file descriptor returned in $v0)
	    # thông báo l?i n?u m? file không ???c
  	move 	$s0, $v0      	# save the file descriptor in s0
# ??c file
	addi 	$v0, $zero, 14
	move 	$a0, $s0
	la 	$a1, buffer
	addi 	$a2, $zero, 8 	#number of charater
	syscall
# Nhap (syscall)

  # Chuy?n 2 s? th?c ??c ???c vào trong 2 bi?n A, B
	la 	$a3, buffer 
	lw 	$t1, 0($a3)   	#t1 = float 1
	lw 	$t2, 4($a3)	#t2 = float 2
	sw 	$t1, soA
	sw 	$t2, soB
# In giá tr? s? th?c A
 
 la $a0,str_dl1
 addi $v0,$zero,4
 syscall
li $v0, 2         # L?nh syscall 2: in s? th?c ??n ch?m ??ng
lwc1 $f12, soA      # ??a giá tr? s? th?c trong bi?n A vào thanh ghi $f12
syscall           # Th?c hi?n syscall ?? in giá tr? s? th?c A
# xuong dong
 addi $a0,$zero,'\n'
 addi $v0,$zero,11
 syscall 
# In giá tr? s? th?c B
la $a0,str_dl2
 addi $v0,$zero,4
 syscall
li $v0, 2         # L?nh syscall 2: in s? th?c ??n ch?m ??ng
lwc1 $f12, soB      # ??a giá tr? s? th?c trong bi?n B vào thanh ghi $f12
syscall           # Th?c hi?n syscall ?? in giá tr? s? th?c B
# xuong dong
 addi $a0,$zero,'\n'
 addi $v0,$zero,11
 syscall 
	
# Xu ly
  # Chuyen du lieu sang ma nhi phan
	lw    $a1, soA	# Load du lieu soA vao thanh ghi $a1
	lw    $a2, soB	# Load du lieu soB vao thanh ghi $a2

	jal   Calculator	
	mov.s $f12, $f0	# Lay gia tri tra ve tu ham Calculator -> in ra man hinh
	
# Xuat ket qua
   	la  $a0, kq
   	li  $v0, 4
   	syscall
   
   	li  $v0, 2
   	syscall
   	
# Ket thuc chuong trinh (syscall)
exit:
	li  $v0, 10
	syscall
	
#--------------------Calculator function:-------------------------------
Calculator:		
			
  # Kiem tra truong hop dac biet
   	beqz $a2,b0	# so sanh: $a2 = 0 thi nhay den b0 (B = 0)
   	beqz $a1,a0	# so sanh: $a1 = 0 thi nhay den a0 (A = 0)
   	j not0		# Nhay den not0. Tuc A va B deu khac 0
   	
   b0:			# Truong hop B = 0		
   	beqz $a1, ab0	# Kiem tra xem A co bang 0 hay khong? Neu co nhay den ab0
   	la   $a0, kq	# Nguoc lai, tuc la A khac 0, in ra man hinh "A / B = "
   	li   $v0, 4	
   	syscall
   	
   	la   $a0, I	
   	li   $v0, 4	
   	syscall		# Xuat ket qua: A / B = Infinity
   	j    exit		# Nhay den exit de thoat chuong trinh
   	
   a0:			# Truong hop B khac 0 nhung A = 0
   	la   $a0, kq	# In ra man hinh "A / B = "
   	li   $v0, 4
   	syscall
   	
   	li   $a0, 0	# Xuat ket qua A / B = 0, Vi luc nay B khac 0 va A = 0
   	li   $v0, 1
   	syscall
   	j    exit	# Nhay den exit de thoat chuong trinh
   	
   ab0:			# Truong hop ca A = 0 va B = 0
   	la  $a0, kq	# In ra man hinh "A / B = "
   	li  $v0, 4
   	syscall
   	
   	la  $a0, nan	# In "A / B = NaN" vi luc nay A / B = 0 / 0
   	li  $v0, 4
   	syscall
   	j exit		# Nhay den exit de thoat chuong trinh
   	
   not0:		# A va B deu khac 0
  # Tach cac truong cua ma nhi phan 32 bit
  
  # Truong sign: tim bang cach dich phai so A va B moi so 31 bit. 
    	srl  $t1, $a1, 31		# Truong sign cua so A = $t1
    	srl  $t2, $a2, 31		# Truong sign cua so B = $t2
    	
    # Truong Exponent: Ta dich trai so A va B moi so 1 bit sau do dich phai 24 bit 
    #		      de thu duoc 8 bit cua Exponent
      
    # Truong Exponent cua so A
     	sll  $t3, $a1, 1 		
	srl  $t3, $t3, 24
	subi $t3, $t3, 127	#Exponent A = $t3
	
    # Truong Exponent cua so B
	sll  $t4, $a2, 1 			
	srl  $t4, $t4, 24
	subi $t4, $t4, 127	# Exponent B = $t4
	
    # Truong Fraction: # Ta dich trai so A va B moi so 9 bit sau do dich phai 9 bit 
    		       # -> De thu duoc 23 bit cua Fraction
    		       # Sau do ta cong 0x00800000 de bit thu 24 cua A va B la 1
     
    # Truong Fraction cua so A	
	sll $t5, $a1 ,9		
	srl $t5, $t5, 9
	ori $t5, $t5, 0x00800000		# $t5 = 1bit + fraction A
	
    # Truong fraction cua so B
	sll $t6,$a2,9		
	srl $t6,$t6,9
	ori $t6, $t6, 0x00800000	# $t6 = 1bit + fraction B
	
    # Tinh toan
   	xor $t1,$t1,$t2		# Truong sign cua kq = $t1
   	
   	sub  $t2,$t3,$t4	# Exponent cua kq = $t2
   	addu $t2,$t2,127
   	
   	slt  $s0,$t5,$t6	# Kiem tra xem (1 + Fraction a)/(1 + Fraction b) < 1 hay khong
   	li   $t9, 0x00800000	# Gan bit thu 8 cua $t9 la 1 các bit còn lai la 0 de tinh toan
   	li   $t8, 24		# $t8 = 24 -> lap lai 24 lan tren cac bit cua Fraction
   	li   $t3, 0		# $t3 = 0 de luu ket qua cua fraction
   	
   loop:
   	div  $t5, $t6		#Fraction cua kq = $t3 = (1 + Fraction a)/(1 + Fraction b) - 1
   	mflo $t7		#Ket qua phep chia
   	mfhi $t5		#Phan du phep chia
   	
   	mulu $t7, $t7, $t9	# Lay phan nguyen nhan voi $t9
   	addu $t3, $t3, $t7	# Cong cac ket qua sau khi da nhan voi $t9
   	srl  $t9, $t9, 1	# Dich phai $t9 sau moi lan chia
   	sll  $t5, $t5, 1	# Dich trai phan du sau moi lam chia
   	subu $t8, $t8, 1	# Dien dem giam 1 don vi sau moi lam lap
   	
   	beqz $t5, endloop	# $t5 = 0 tuc khong con du
   	beqz $t8, endloop	# $t8 = 0 tuc da lay du 24 bit
   	j loop
   	
   endloop:
   	beqz $s0, khongcantru	# $s0 = 0 tuc fraction cua A lon hon fraction cua B
   	sll  $t3, $t3, 1	# Dich ket qua sang trai 1 bit
   	subi $t2, $t2, 1	# Tru Exponent di 1 bit
   	
   khongcantru:     
   	andi $t3,$t3,0x007FFFFF	# Thuc hien and de khu di bit 1 o bit thu 23
   	
   # Hop cac truong lai voi nhau va luu vao $t4
   	sll $t4,$t1,31		# Hop truong sign
   	
   	sll $t2,$t2,23		# Hop Exponent
   	or  $t4,$t4,$t2
   	
   	or  $t4,$t4,$t3		# Hop Fraction
   	
   # Kiem tra xem ket qua cua chia fraction co con du hay khong?
   
   	sll  $t5, $t5, 1
   	slt  $t5, $t6, $t5
   	beqz $t5, khongcodu
   	addi $t4, $t4, 1	#Neu con du thi cong them 1 bit de lam tron
   	
   	khongcodu:
   	
   # Chuyen du lieu qua $f0 de tra ve
   	mtc1 $t4, $f0	
   	
   	jr $ra
   # ?óng file
    	li $v0, 16            	# syscall 16: ?óng t?p tin
    	move $a0, $s0         	# L?y handle c?a t?p tin t? $s0 và ??a vào $a0
    	syscall               	# Th?c hi?n syscall ?? ?óng t?p tin