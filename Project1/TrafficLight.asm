.data
address: .word 0xFFFF0000  # $t0 = 0xFFFF0000
SIZE_STATE: .word 3

START_SIM:  	  .word 1
EDIT_SIM:   		  .word 2
EXIT_SIM:   		  .word 3
PROMPT:     		  .asciiz "\nOptions:\n1. Start Simulation\n2. Edit Parameters\n3. Exit\nENTER: "
INVALID_INPUT:  .asciiz "\nInput is invalid, please try again.\n"
SIM_DONE: 		  .asciiz "\nSimulation Finished\n"

#Parameters
RED_P: .asciiz "\nEnter Delay For Red Light(s): "
RED_DELAY: .word 1

SPEED_P: .asciiz "Enter Speed Limit(km/s): "
YELLOW_P: .asciiz "Yellow Delay Based On Speed: "

GREEN_P: .asciiz "\nEnter Delay For Green Light(s): "
GREEN_DELAY: .word 10

NS_R: .asciiz "NS-RED\n"
NS_Y: .asciiz "NS-YELLOW\n"
NS_G: .asciiz "NS-GREEN\n"
EW_R: .asciiz "EW-RED\n\n"
EW_Y: .asciiz "EW-YELLOW\n\n"
EW_G: .asciiz "EW-GREEN\n\n"

.text
j main

#a0-2 - red light, yellow light, green light.
start_sim:
    li $s5, 'q'   # q key
    li $s6, 'e'   # e key
    
    move $s0, $a0 #Green Delay
    move $s1, $a1 #Yellow Delay
    move $s2, $a2 #Red Delay
    li $t0, 1000
    mul $s0, $s0, $t0 #Milliseconds
    mul $s1, $s1, $t0 #Milliseconds
    mul $s2, $s2, $t0 #Milliseconds
	
	# Next Time
	add $s4, $zero, 0
	add $s7, $zero, 0
    # Counter
    waitloop:
    	# Check Time
    	li $v0, 30
   		syscall
   		move $t4, $a0
   		
   		sltu $t1, $s4, $t4
   		beqz $t1, CONT
    	
   		li  $t1, 0      # Load immediate 0 into $t1
 	  	beq  $s7, $t1, case_0  # Branch to case_0 if x == 0
  	  	li  $t1, 1      # Load immediate 1 into $t1
		beq  $s7, $t1, case_1  # Branch to case_1 if x == 1
 	   	li  $t1, 2      # Load immediate 2 into $t1
 	   	beq  $s7, $t1, case_2  # Branch to case_2 if x == 2
  	  	li  $t1, 3      # Load immediate 3 into $t1
   	 	beq  $s7, $t1, case_3  # Branch to case_3 if x == 3
  	  	li  $t1, 4      # Load immediate 4 into $t1
  	  	beq  $s7, $t1, case_4  # Branch to case_4 if x == 4
  	  	li  $t1, 5      # Load immediate 5 into $t1
  	  	beq $s7, $t1, case_5  # Branch to case_5 if x == 5
    
	case_0:
    la $a0, NS_R
    	li $v0, 4
    	syscall
    la $a0, EW_R
    	li $v0, 4
    	syscall
    	addi $s7, $s7, 1
    	add $s4, $t4, $s2
    j   end_switch
    
	case_1:
    la $a0, NS_G
    	li $v0, 4
    	syscall
    la $a0, EW_R
    	li $v0, 4
    	syscall
    	addi $s7, $s7, 1
    	add $s4, $t4, $s0
    j   end_switch
    
	case_2:
    la $a0, NS_Y
    	li $v0, 4
    	syscall
    la $a0, EW_R
    	li $v0, 4
    	syscall
    	addi $s7, $s7, 1
    	add $s4, $t4, $s1
    j   end_switch
    
	case_3:
    la $a0, NS_R
    	li $v0, 4
    	syscall
    la $a0, EW_R
    	li $v0, 4
    	syscall
    	addi $s7, $s7, 1
    	add $s4, $t4, $s2
    j   end_switch
    
	case_4:
    la $a0, NS_R
    	li $v0, 4
    	syscall
    la $a0, EW_G
    	li $v0, 4
    	syscall
    	addi $s7, $s7, 1
    	add $s4, $t4, $s0
    j   end_switch
    
	case_5:
    la $a0, NS_R
    	li $v0, 4
    	syscall
    la $a0, EW_Y
    	li $v0, 4
    	syscall
    	addi $s7, $zero, 0
    	add $s4, $t4, $s1
    j   end_switch
    
	end_switch:
    
    	CONT:
    	lw $t0,  address
    	lw $t1, 0($t0)   # load control byte  
    	andi $t1, $t1, 0x0001 # check to see if new data is there  
    	beq $t1, $zero, waitloop  # loop if not   
    	lw $a0, 4($t0)  # load data byte   
   
     
    	beq $a0, $s5, done # exit if 'q' is typed  	
    	beq $a0, $s6, EDIT_RUN # exit if 'q' is typed
    	j waitloop
    	
    	EDIT_RUN:
    	addi $sp, $sp, -4
		sw $ra, 0($sp)
			jal edit_params
    		move $s0, $a0 #Green Delay
    		move $s1, $a1 #Yellow Delay
    		move $s2, $a2 #Red Delay
    		li $t0, 1000
    		mul $s0, $s0, $t0 #Milliseconds
    		mul $s1, $s1, $t0
    		mul $s2, $s2, $t0
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	j waitloop
    	done:
	jr $ra

#a0-2 - red light, yellow light, green light.
edit_params:
	la $a0, RED_P
    li $v0, 4
    syscall
    
    # Read Red Delay
    li $v0, 5
    syscall
    move $s0, $v0
    
    la $a0, SPEED_P
    li $v0, 4
    syscall
    
    # Read max Speed
    li $v0, 5
    syscall
    move $t1, $v0
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
     
    la $a0, YELLOW_P
    li $v0, 4
    syscall
     
    move $a0, $t1
    jal calc_yellow_delay
    move $s1, $v0
    move $a0, $v0
    li $v0, 1
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    la $a0, GREEN_P
    li $v0, 4
    syscall
    
    # Read Green Delay
    li $v0, 5
    syscall
    move $s2, $v0
    
    move $a0, $s2
    move $a1, $s1
    move $a2, $s0
	jr $ra

#$a0 - max speed
#$v0 - yellow light delay
#t = 2 + V^2/1600 - V/50
calc_yellow_delay: 
    # Square the value of V
    mul $t1, $a0, $a0
    
    li $t2, 1600  
    div $t1, $t2       
    mflo $t3
    
    li $2, 50  
    div $a0, $t2       
    mflo $t5            
    
    li $t4, 2       
    add $v0, $t3, $t4
    sub $v0, $v0, $t5
    
    jr $ra 

main:
	INPUT:
    # Load prompt address into $a0
    la $a0, PROMPT
    # Print prompt
    li $v0, 4
    syscall
    
    # Read user input
    li $v0, 5
    syscall
    move $t0, $v0
    
    # Check over input
    lw $t1, START_SIM
    beq $t0, $t1, START
    
    lw $t1, EDIT_SIM
    beq $t0, $t1, EDIT
    
    lw $t1, EXIT_SIM
    beq $t0, $t1, EXIT
    
    #Default
    la $a0, INVALID_INPUT
    li $v0, 4
    syscall
    j INPUT
    
    START:
    li $a0, 6
    li $a1, 3
    li $a2, 2
    jal start_sim
    j EXIT
    
    EDIT:
    jal edit_params
    jal start_sim
    
    EXIT:
    la $a0, SIM_DONE
    # Print prompt
    li $v0, 4
    syscall
    li $v0, 10    # Exit system call
    syscall
    
    
