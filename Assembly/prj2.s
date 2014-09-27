!=================================================================
! General conventions:
!   1) Stack grows from high addresses to low addresses, and the
!      top of the stack points to valid data
!
!   2) Register usage is as implied by assembler names and manual
!
!   3) Function Calling Convention:
!
!       Setup)
!       * Immediately upon entering a function, push the RA on the stack.
!       * Next, push all the registers used by the function on the stack.
!
!       Teardown)
!       * Load the return value in $v0.
!       * Pop any saved registers from the stack back into the registers.
!       * Pop the RA back into $ra.
!       * Return by executing jalr, $ra, $zero.
!=================================================================

!vector table
vector0:    .fill 0x00000000 !0
            .fill 0x00000000 !1
            .fill 0x00000000 !2
            .fill 0x00000000
            .fill 0x00000000 !4
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000 !8
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000
            .fill 0x00000000 !15
!end vector table

main:           la $sp, stack		! Initialize stack pointer
                lw $sp, 0($sp)          
                
                ! Install timer interrupt handler into vector table
                la $s0, ti_inthandler   ! Load address of int handler to s0
				sw $s0, 0x1($zero)		! Save handler location at 0x1
                ei                      ! Don't forget to enable interrupts...

		la $at, factorial	! load address of factorial label into $at
		addi $a0, $zero, 5 	! $a0 = 5, the number to factorialize
		jalr $at, $ra		! jump to factorial, set $ra to return addr
		halt		        ! when we return, just halt

factorial:	addi    $sp, $sp, -1    ! push RA
                sw      $ra, 0($sp)
                addi    $sp, $sp, -1    ! push a0
                sw      $a0, 0($sp)
                addi    $sp, $sp, -1    ! push s0
                sw      $s0, 0($sp)
                addi    $sp, $sp, -1    ! push s1
                sw      $s1, 0($sp)

                beq     $a0, $zero, base_zero
                addi    $s1, $zero, 1
                beq     $a0, $s1, base_one
                beq     $zero, $zero, recurse
                
    base_zero:  addi    $v0, $zero, 1   ! fact(0) = 1
                beq     $zero, $zero, done

    base_one:   addi    $v0, $zero, 1   ! fact(1) = 1
                beq     $zero, $zero, done

    recurse:    add     $s1, $a0, $zero     ! save n in s1
                addi    $a0, $a0, -1        ! fact(n) = n * fact(n-1)
                la      $at, factorial
                jalr    $at, $ra

                add     $s0, $v0, $zero     ! use s0 to store fact(n-1)
                add     $v0, $zero, $zero   ! use v0 as sum register
        mul:    beq     $s1, $zero, done    ! use s1 as counter (from n to 0)
                add     $v0, $v0, $s0
                addi    $s1, $s1, -1
                beq     $zero, $zero, mul

    done:       lw      $s0, 0($sp)     ! pop s0
                addi    $sp, $sp, 1
                lw      $s1, 0($sp)     ! pop s1
                addi    $sp, $sp, 1
                lw      $a0, 0($sp)     ! pop a0
                addi    $sp, $sp, 1
                lw      $ra, 0($sp)     ! pop RA
                addi    $sp, $sp, 1
                jalr    $ra, $zero

ti_inthandler:
    ! 1. Save state
	! (Insert save state code here)
	! 2. Enable interrupts
	ei
	! 3. Handler program logic
	! To save time, only load memlocation of minutes/hours if needed
	la $s0, seconds				! Load memlocation of seconds variable
	lw $a0, 0x00($s0)			! Load value of seconds variable into $a0
	addi $s1, $s1, 1			! seconds = seconds + 1
	addi $a1, $zero, -60		! a1 = -60		
	add $a1, $s1, $a1			! a1 = seconds - 60
	beq $zero, $a1, inc_mins	! If a1 = 0, need to increment minutes
	sw $s1, 0x00($a0)			! Otherwise, push seconds back to memory
	reti						! We are done (case 1)
inc_mins: sw $zero, 0x00($a0)	! First, push seconds=0 into memory
	la $s0, minutes				! Load memlocation of minutes variable
	lw $a0, 0x00($s0)			! Load value of minutes variable into $a0
	addi $s1, $s1, 1			! minutes = minutes + 1
	addi $a1, $zero, -60		! a1 = -60		
	add $a1, $s1, $a1			! a1 = minutes - 60
	beq $zero, $a1, inc_hours	! If a1 = 0, need to increment hours
	sw $s1, 0x00($a0)			! Otherwise, push minutes back to memory
	reti						! We are done (case 2)










stack:	.fill 0xA0000000

! Below for interrupt handler
seconds: .fill 0xFFFFFFFC
minutes: .fill 0xFFFFFFFD
hours: .fill 0xFFFFFFFE