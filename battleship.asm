	.data 
plr1Bd: .space  400	
plr2Bd:	.space 	400
userMv:	.space	16
userIn:	.space	32
warning:.asciiz "\n######################## Your Turn Below ########################\n\n"
wlcm:	.asciiz "\n~~~ Welcome to Battleship! ~~~\n"
players:.asciiz "How many players? (1 or 2)\n"
inst1:	.asciiz "Player 1, place your ships.\n"
inst12:	.asciiz "Player 2, place your ships.\n"
inst2:	.asciiz "Direction? (up = 1,down = 2,left = 3,right = 4)\n"
inst31:	.asciiz "\nPlayer 1, please enter a move. (Ex: b2)\n"
inst32:	.asciiz "\nPlayer 2, please enter a move. (Ex: b2)\n"
error1:	.asciiz "Sorry, that direction would go out of bounds! Try again.\n"
error2:	.asciiz "Sorry, that is not a valid input. Pease try again.\n"
error3:	.asciiz "Sorry, that is not a valid number of players. Please try again.\n"
error4: .asciiz "You already guessed that space! Try again. (Ex: b2)\n"
space:	.asciiz " "
newLine:.asciiz "\n"
alpha:	.asciiz	"+ a b c d e f g h i j\n"
board1:	.asciiz "\nYour Board:\n"
board2: .asciiz "Opponent's Board:\n"
place1:	.asciiz "Please place your Aircraft Carrier. (Length = 5) (Ex: b2)\n"
place2:	.asciiz "Please place your Battleship. (Length = 4) (Ex: b2)\n"
place3:	.asciiz "Please place your Submarine. (Length = 3) (Ex: b2)\n"
place4:	.asciiz "Please place your Cruiser. (Length = 3) (Ex: b2)\n"
place5:	.asciiz "Please place your Destroyer. (Length = 2) (Ex: b2)\n"
Win1:	.asciiz "Player 1 Wins!!!"
Win2:	.asciiz "Player 2 Wins!!!"
bdWater:.asciiz " "
bdMiss:	.asciiz "."
bdBlank:.asciiz "."
bdHit:	.asciiz "X"
bdA:	.asciiz "A"
bdB:	.asciiz "B"
bdS:	.asciiz "S"
bdC:	.asciiz "C"
bdD:	.asciiz "D"

	.text 
main:
	li	$v0, 4		# load printString to $v0
	la	$a0, wlcm	# prints the welcome message
	syscall

	jal setup		# calls setup function
	
	la      $a1, plr1Bd	# load player 1's board into $a1
	la	$s1, plr1Bd	# load player 1's board into $s1
	la      $a2, plr2Bd	# load player 2's board into #a2
	la	$s2, plr1Bd	# load player 1's board into $s1
	
	
	li 	$t0, 0		# loads 0 into $t0
 	move 	$t1, $a1	# move $a1 to $t1
  	addi 	$t2, $a1, 400	# $t2 = $a1 + 400
	jal	fillBoard	
	
	li 	$t0, 0		# loads 0 inot #t0
 	move 	$t1, $a2	# move $a1 to $t1
  	addi 	$t2, $a2, 400	# $t2 = $a2 + 400
	jal	fillBoard
	
	li	$v0,4		# load printString to $v0
	la	$a0,inst1	# prints instruction 1
	syscall
	
	li	$s3, 1		# sets the turn to player 1.
	la      $a1, plr1Bd	# load player 1's board into $a1
	jal	placeShips
	
	li	$v0,4		# load printString to $v0
	la	$a0,warning	# prints the warning message.
	syscall	
	
	li	$v0,4		# load printString to $v0
	la	$a0,inst12	# prints instruction 1 for player 2
	syscall
	
	li	$s3, 0		# sets the turn to player 2.
	
	la      $a1, plr2Bd	# load player 2's board into $a1
	
	bne	$s7,1,CPUPlaceShipsSkip	# skips CPU placing ships if 2 players are playing
	
	jal	CPUPlaceShips
	j	continueWithGame
		
CPUPlaceShipsSkip:
	jal	placeShips
	
continueWithGame:
	li	$s3, 0		# $s3 acts as the turn counter.
	li	$s0, 0		# loads 0 into $s0
	
playGame:
	jal	takeTurn
	
	jal	checkForWin
	bne	$s0,$zero,endGame	# ends game if checkForWin function determines a winner.
	
	j 	playGame	# continues with game if no winner was found

endGame:
	beq	$s3,0,playerTwoWins

	li	$v0,4		# load printString to $v0
	la	$a0,Win1	# prints winnging message for player 1.
	syscall	
	
	j	end

playerTwoWins:
	li	$v0,4		# load printString to $v0
	la	$a0,Win2	# prints winning message for player 2.
	syscall	
	
end:
	li	$v0, 10		# exit cleanly
	syscall 

getInput:
	li	$v0,8		# load readString to $v0
	la	$a0,userIn	# sets the target to userIn
	syscall	
	
	la	$a0,userIn	# puts address of userIn into $a0
	lb 	$t1, 0($a0)	# loads the 0th byte of $a0 into $t1
	sll 	$t1, $t1, 24	# shift $t1 left 24 bits
	srl	$t1, $t1, 24	# shift $t1 right 24 bits

	subi	$t1,$t1,96	# $t1 = $t1 - 96
	
	#la	$a0,userIn	
	
	lw	$t3, ($a0)	# loads $a0 into $t3
	sll 	$t3, $t3, 20	# shift $t1 left 20 bits
	srl	$t3, $t3, 28	# shift $t1 right 28 bits
	
	li	$t2,10		# loads 10 into $t2
	mult	$t3,$t2		# $t3 * $t2
	mflo 	$t3
	
	add	$t1,$t1,$t3	# $t1 = $t1 + $t3
	subi	$s4,$t1,10	# $s4 = $t1 - 10
	
	ble	$s4,0,addOneHundred	# $s4 <= 0, branches to addOneHundred
	
	#bge	$s4,100,invalidLocationError
	#ble	$s4,-1,invalidLocationError

	jr 	$ra	
	
addOneHundred:
	addi	$s4,$s4,100	# $s4 = $s4 + 100
	jr	$ra
	
invalidLocationError:
	li	$v0,4		# load printString to $v0
	la	$a0,error2	# prints error message 2.
	syscall	
	
	j	getInput

#$s3 = 1 if player 1's turn finished. 0 if player 2's turn finished.
#$s0 = 1 means win, $v0 = 0 means no win found.
checkForWin:
	beq	$s3,$zero, checkBoard2	#branches to checkBoard 2 if player 2 is selected
	la	$t1, plr2Bd		#loads address of player two's board into $t1
	addi 	$t2, $t1, 400		#$t2 = $t1 + 400
	j	continueWinCheck

checkBoard2:
	la	$t1, plr1Bd		#loads address of player one's board into $t1
	addi 	$t2, $t1, 400		#$t2 = $t1 + 400

continueWinCheck:
	lw	$t3,($t1)		# loads $t1 into $t3
	bne	$t3,$zero,checkIfOne	# if $t3 isn't 0, branches to checkIfOne
	
   	addi 	$t1, $t1, 4		# $t1 = $t1 + 4
   	bne 	$t1, $t2, continueWinCheck	#branches to continueWinCheck if $t1 != $t2
   	
   	li	$s0,1			# sets result to 1 if there is a winner.

	jr	$ra

checkIfOne:
	li	$t4,1			# $t4 = 1
	beq	$t3,$t4, addFourAndContinueCheck
	li	$t4,7			# $t4 = 7
	beq	$t3,$t4, addFourAndContinueCheck

	li	$s0,0			#Zero means not a win.

	jr	$ra
	
addFourAndContinueCheck:
	addi 	$t1, $t1, 4		# $t1 = $t1 + 4
	j	continueWinCheck

takeTurn:
	li	$v0,4		# load printString to $v0
	la	$a0,warning	# prints warning.
	syscall
	
	bne	$s3, $zero,playerTwoSetup	#branches to playerTwoSetup if it's player 2's turn
	
playerOneSetup:
	li $s3, 1		# $s3 = 1
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,board2	# prints "opponents board"
	syscall
	
	#Print board stack start
	subi	$sp,$sp,4	# dedicates stack space
	sw	$ra,0($sp)	# stores $ra in stack

	la      $a1, plr2Bd	# load player 2's board into $a1
	jal	printBoardSetup	
	
	#Print board stack end
	lw	$ra, 0($sp)	# takes $ra from stack
   	addi	$sp,$sp,4	# returns stack space.
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,board1	# prints "your board"
	syscall
	
	subi	$sp,$sp,4	# dedicates stack space
	sw	$ra,0($sp)	# stores $ra in stack

	la      $a1, plr1Bd	# load player 1's board into $a1
	jal	printBoardSetup	

	lw	$ra, 0($sp)	# takes $ra from stack
   	addi	$sp,$sp,4	# returns stack space.

	li	$v0,4		# load printString to $v0
	la	$a0,inst31	# prints move instruction for player 1.
	syscall
	
	la      $a1, plr2Bd	# load player 2's board into $a1
	j	continueTurn
	
playerTwoSetup:
	li 	$s3,0		# $s3 = 0
	
	beq	$s7,1,CPUMove	# branches to CPUMove if there is only one player.
	
	li	$v0,4		# load printString to $v0
	la	$a0,board2	# prints "opponents board"
	syscall
	
	subi	$sp,$sp,4	# dedicates stack space
	sw	$ra,0($sp)	# stores $ra in stack

	la      $a1, plr1Bd	# load player 1's board into $a1
	jal	printBoardSetup	
	
	lw	$ra, 0($sp)	# restores $ra from stack
   	addi	$sp,$sp,4	# restores stack space
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,board1	# prints "your board"
	syscall
	

	subi	$sp,$sp,4	# dedicates stack space
	sw	$ra,0($sp)	# stores $ra in stack

	la      $a1, plr2Bd	# load player 2's board into $a1
	jal	printBoardSetup	
	
	lw	$ra, 0($sp)	# restores $ra from stack
   	addi	$sp,$sp,4	# returns stack space
	

	li	$v0,4		# load printString to $v0
	la	$a0,inst32	# prints move instruction for player 2.
	syscall
	
	la      $a1, plr1Bd	# load player 1's board into $a1
	j	continueTurn
	
CPUMove:
	li	$v0,42		# $v0 = 42
	li	$a0,0		# $a0 = 0
	li	$a1,100		# $a1 = 100
	syscall			# gets a random number between 0 and 100.
	move	$t6,$a0		# $t6 = $a0
	
	la      $a1, plr1Bd	# load player 1's board into $a1
	
	j	CPUContinueTurn
	
continueTurn:
	subi	$sp,$sp,4	# dedicates stack space.
	sw	$ra,0($sp)	# stores $ra in stack.
	jal	getInput
	lw	$ra, 0($sp)	# restores $ra from stack.
   	addi	$sp,$sp,4	# returns stack space.
	move 	$t6,$s4		# $t6 = $s4
	
CPUContinueTurn:
	subi	$t6,$t6,1	# $t6 = $t6 - 1
	li	$t5,4		# $t5 = 4
	mult	$t6,$t5		# $t6 * $t5
	
	mflo	$t6
	
	la	$t1, ($a1)	# $t1 = address of $a1
	add	$t1,$t1,$t6	# $t1 = $t1 + $t6
	
	li	$t0, 1		# $t0 = 1
	
	lw	$t2, ($t1)	# $t2 loads $t1
	
	beq	$t2, 7, alreadyGuessed	# branches to alreadyGuessed if the tile is blank
	beq	$t2, 1, alreadyGuessed	# branches to alreadyGuessed if the tile is a hit
	
	bne	$zero, $t2, setTile	# branches to setTile if $t2 != 0

	li	$t0, 7		# $t0 = 7
	
setTile:
	sw 	$t0, ($t1)	# stores the contents of $t0 into $t1 address
	jr 	$ra
	
alreadyGuessed:
	li	$v0,4		# load printString to $v0
	la	$a0,error4	# prints error message 4.
	syscall	
	
	j	continueTurn
	
#METHOD
#$t0 = length
#$t1 = direction
#$t2 = type
#$t3 = place
placeShip:
	subi	$t6,$t3,1	# $t6 = #t3 - 1
	li	$t5,4		# $t5 = 4
	mult	$t6,$t5		# $t6 * $t5
	mflo	$t6		

	la	$t4, ($a1)	# sets $t4 to the contents of $a1
	add	$t4,$t4,$t6	# $t4 = $t4 + $t6
	sw 	$t2, ($t4)	# sets $t2 to the contents of $t4
	
	beq	$t1,1,moveUp	# branches of moveUp if $t1 = 1
	beq	$t1,2,moveDown	# branches of moveDown if $t1 = 2
	beq	$t1,3,moveLeft	# branches of moveLeft if $t1 = 3
	beq	$t1,4,moveRight	# branches of moveRight if $t1 = 4
	
moveUp:
	li	$t7,10		# $t7 = 10
	mult	$t7,$t0		# $t7 * $t0
	mflo	$t7
	sub	$t7,$t3,$t7	# $t7 = $t3 - $t7
	
	#ble	$t7,-10,invalidPlacement	# branches if $t7 <= -10
	
	subi	$t3, $t3, 10	#$t3 = $t3 - 10
	j	nextShipSegment
	
moveDown:
	li	$t7,10		#$t7 = 10
	mult	$t7,$t0		#$t7 * $t0
	mflo	$t7
	add	$t7,$t3,$t7	# $t7 = $t3 + $t7
	
	#bge	$t7,111,invalidPlacement	#branches if $t7 >= 111

	addi	$t3, $t3, 10	# $t3 = $t3 + 10
	j	nextShipSegment
	
moveLeft:
	#subi	$t3,$t3,1
	#sub	$t6,$t3,$t0
	#div	$t6,$t6,10
	#div	$t7,$t3,10
	#bne	$t6,$t7,invalidPlacement

	subi	$t3, $t3, 1	#$t3 = $t3 - 1
	j	nextShipSegment
	
moveRight:
	#li	$t7,10
	#add	$t6,$t3,$t0
	#subi	$t6,$t6,2
	#div	$t6,$t6,10
	#mflo	$t6
	
	#div	$t7,$t3,10
	#mflo	$t7
	
	#bne	$t6,$t7,invalidPlacement

	addi	$t3, $t3, 1	# $t3 = #t3 + 1
	j	nextShipSegment
	
nextShipSegment:
	subi	$t0,$t0,1	# $t0 = $t0 + 1
	bne 	$t0,$zero, placeShip	# branches if $t0 != 0
	
	jr 	$ra
	
invalidPlacement:
	li	$t7, 0		# $t7 = 0
	sw 	$t7, ($t4)	# stores contents of $t7 into address $t4

	beq	$s7,1,CPUinvalidPlacement	# branches if $s7 = 1

	li	$v0,4		# load printString to $v0
	la	$a0,error1	# prints invalid placement error.
	syscall
	
	beq	$t2,2,placeAircraft	# branches if $t2 = 2
	beq	$t2,3,placeBattleship	# branches if $t2 = 3
	beq	$t2,4,placeSubmarine	# branches if $t2 = 4
	beq	$t2,5,placeCruiser	# branches if $t2 = 5
	beq	$t2,6,placeDestroyer	# branches if $t2 = 6
	
CPUinvalidPlacement:
	beq	$t2,2,CPUplaceAircraft		# branches if $t2 = 2
	beq	$t2,3,CPUplaceBattleship	# branches if $t2 = 3
	beq	$t2,4,CPUplaceSubmarine		# branches if $t2 = 4
	beq	$t2,5,CPUplaceCruiser		# branches if $t2 = 5
	beq	$t2,6,CPUplaceDestroyer		# branches if $t2 = 6
	
CPUPlaceShips:
	
CPUplaceAircraft:
	
	move	$t4,$a0		# $t4 = $a0
	move	$t5,$a1		# $t5 = $a1
	
	li	$v0,42		# $v0 = 42
	li	$a0,0		# $a0 = 0
	li	$a1,49		# $a1 = 49
	syscall
	move	$t3,$a0		# $t3 = $a0
	
	li	$t1,2		# $t1 = 2
	
	move	$a0,$t4		# $a0 = $t4
	move	$a1,$t5		# $a1 = $t5
	
	li	$t0, 5		# $t0 = 5 (Length of Aircraft)
	li	$t2, 2		# $t2 = 2 (Board type of Aircraft)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
CPUplaceBattleship:
	move	$t4,$a0
	move	$t5,$a1
	
	li	$v0,42
	li	$a0,0
	li	$a1,59
	syscall
	move	$t3,$a0
	
	li	$t1,2
	
	move	$a0,$t4
	move	$a1,$t5
	
	li	$t0, 4		# $t0 = 4 (Length of Battleship)
	li	$t2, 3		# $t2 = 3 (Board type of Battleship)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
CPUplaceSubmarine:
	move	$t4,$a0
	move	$t5,$a1
	
	li	$v0,42
	li	$a0,0
	li	$a1,59
	syscall
	move	$t3,$a0
	
	li	$t1,2
	
	move	$a0,$t4
	move	$a1,$t5
	
	li	$t0, 3		# $t0 = 3 (Length of Submarine)
	li	$t2, 4		# $t2 = 4 (Board type of Submarine)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
CPUplaceCruiser:
	move	$t4,$a0
	move	$t5,$a1
	
	li	$v0,42
	li	$a0,0
	li	$a1,69
	syscall
	move	$t3,$a0
	
	li	$t1,2
	
	move	$a0,$t4
	move	$a1,$t5
	
	li	$t0, 3		# $t0 = 3 (Length of Cruiser)
	li	$t2, 5		# $t2 = 5 (Board type of Cruiser)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
CPUplaceDestroyer:
	move	$t4,$a0
	move	$t5,$a1
	
	li	$v0,42
	li	$a0,0
	li	$a1,79
	syscall
	move	$t3,$a0
	
	li	$t1,2
	
	move	$a0,$t4
	move	$a1,$t5
	
	li	$t0, 2		# $t0 = 2 (Length of Destroyer)
	li	$t2, 6		# $t2 = 6 (Board type of Destroyer)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
   	jr	$ra
	
#METHOD:
placeShips:
	li	$v0,4		# load printString to $v0
	la	$a0,newLine	# prints a new line
	syscall
	
placeAircraft:
	subi	$sp,$sp,8
	sw	$ra,0($sp)
	jal	printBoardSetup	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,8
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,place1	# prints aircraft instruction.
	syscall
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)	
	jal	getInput
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	move 	$t3,$s4
	
	li	$v0,4		# load printString to $v0
	la	$a0,inst2	# prints direction instruction.
	syscall
	
	li	$v0,5
	syscall
	move 	$t1,$v0		# stores return value (direction) in $t1
	
	li	$t0, 5		# $t0 = 5 (Length of Aircraft)
	li	$t2, 2		# $t2 = 2 (Board type of Aircraft)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4

placeBattleship:
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	printBoardSetup	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,place2	# prints battleship instruction.
	syscall
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)	
	jal	getInput
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	move 	$t3,$s4
		
	li	$v0,4		# load printString to $v0
	la	$a0,inst2	# prints direction instruction.
	syscall
	
	li	$v0,5
	syscall
	move 	$t1,$v0		# stores return value in $t1
	
	li	$t0, 4		# $t0 = 4 (Length of Battleship)
	li	$t2, 3		# $t2 = 3 (Board type of Battleship)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4

placeSubmarine:
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	printBoardSetup	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,place3	# prints submarine instruction.
	syscall

	subi	$sp,$sp,4
	sw	$ra,0($sp)	
	jal	getInput
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	move 	$t3,$s4
		
	li	$v0,4		# load printString to $v0
	la	$a0,inst2	# prints direction instruction.
	syscall
	
	li	$v0,5
	syscall
	move 	$t1,$v0		# stores return value in $t1
	
	li	$t0, 3		# $t0 = 3 (Length of Submarine)
	li	$t2, 4		# $t2 = 4 (Board type of Submarine)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	
placeCruiser:
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	printBoardSetup	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,place4	# prints battleship instruction.
	syscall
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)	
	jal	getInput
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	move 	$t3,$s4
		
	li	$v0,4		# load printString to $v0
	la	$a0,inst2	# prints direction instruction.
	syscall
	
	li	$v0,5
	syscall
	move 	$t1,$v0		# stores return value in $t1
	
	li	$t0, 3		# $t0 = 3 (Length of Cruiser)
	li	$t2, 5		# $t2 = 5 (Board type of Cruiser)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4

placeDestroyer:
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	printBoardSetup	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
   	
   	li	$v0,4		# load printString to $v0
	la	$a0,place5	# prints destroyer instruction.
	syscall
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)	
	jal	getInput
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	move 	$t3,$s4	
	
	li	$v0,4		# load printString to $v0
	la	$a0,inst2	# prints direction instruction.
	syscall
	
	li	$v0,5
	syscall
	move 	$t1,$v0		# stores return value in $t1
	
	li	$t0, 2		# $t0 = 2 (Length of Destroyer)
	li	$t2, 6		# $t2 = 2 (Board type of Destroyer)
	
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	placeShip	
	lw	$ra, 0($sp)
   	addi	$sp,$sp,4
	
	jr	$ra
	
fillBoard:
    	sw 	$t0, ($t1)		# stores contents of $t0 into address $t1
   	addi 	$t1, $t1, 4		# $t1 = $t1 + 4
   	bne 	$t1, $t2, fillBoard	#branches if $1 != $t2
	
	jr $ra
	
printBoardSetup:
	move	$t6, $a1		# $t6 = $a1
	la	$t7, plr1Bd		# loads address of plr1Bd into $t7
	
	beq	$t6,$t7,setT6toPlayer1	# branches if $t6 = $t7
	
	li	$t6,0			# $t6 = 0
	j 	continuePrintSetup

setT6toPlayer1:
	li	$t6,1		# $t6 = 1

continuePrintSetup:
	move 	$t1, $a1	# $t1 = $a1
  	addi 	$t2, $a1, 400	# $t2 = $a1 + 400
	
	li	$t3,0		# $t3 =0
	li	$t5,1		# sets $t5 to 2. $t5 acts as the row counter.
	
	li	$v0,4		# load printString to $v0
	la	$a0,alpha	# prints the alphabet
	syscall
	
printBoard:
	li	$t4,10		# $t3 = 10
	
	bne	$t3,$zero,skipRowNumber	# branches if $t3 != 0
	
	li	$v0,1		# load printInt to $v0
	move	$a0, $t5	# moves $t5 to $a0
	syscall
	
	addi	$t5,$t5,1	# $t5 = $t5 + 1
	
	bne	$t4,$t5,skipSetTenToZero	# branches if $t4 != $t5
	
	li	$t5,0		# $t5 = 0
	
skipSetTenToZero:
	li	$v0,4		# load printString to $v0
	la	$a0,space	# prints a space
	syscall

skipRowNumber:
	lw 	$t0, ($t1)	# sets contents of $t0 to address $t1
	
	beq	$t0,0,printBlank	# branches if $t0 = 0
	beq	$t0,1,printHit		# branches if $t0 = 1
	beq	$t0,7,printWater	# branches if $t0 = 7
	
	bne	$t6,$s3,printMiss	# branches if $t6 != $s3 (If the board printed is not the active player)

	beq	$t0,2,printAircraft	# branches if $t0 = 2
	beq	$t0,3,printBattleship	# branches if $t0 = 3
	beq	$t0,4,printSub		# branches if $t0 = 4
	beq	$t0,5,printCruiser	# branches if $t0 = 5
	beq	$t0,6,printDestroyer	# branches if $t0 = 6

printUnknown:
	j	printBlank
	
printBlank:
	li	$v0,4		# load printString to $v0
	la	$a0, bdBlank	# prints bdBlank
	syscall
	
	j	continuePrint
	
printWater:
	li	$v0,4		# load printString to $v0
	la	$a0, bdWater	# prints bdWater
	syscall
	
	j	continuePrint
	
printMiss:
	li	$v0,4		# load printString to $v0
	la	$a0, bdMiss	# prints bdMiss
	syscall
	
	j	continuePrint
	
printHit:
	li	$v0,4		# load printString to $v0
	la	$a0, bdHit	# prints bdHit
	syscall
	
	j	continuePrint
	
printAircraft:
	li	$v0,4		# load printString to $v0
	la	$a0, bdA	# prints bdA
	syscall
	
	j	continuePrint
	
printBattleship:
	li	$v0,4		# load printString to $v0
	la	$a0, bdB	# prints bdB
	syscall
	
	j	continuePrint
	
printSub:
	li	$v0,4		# load printString to $v0
	la	$a0, bdS	# prints bdS
	syscall
	
	j	continuePrint
	
printCruiser:
	li	$v0,4		# load printString to $v0
	la	$a0, bdC	# prints bdC
	syscall
	
	j	continuePrint
	
printDestroyer:
	li	$v0,4		# load printString to $v0
	la	$a0, bdD	# prints bdD
	syscall
	
	j	continuePrint
	
continuePrint:
    	li	$v0,4		# load printString to $v0
	la	$a0, space	# prints a space
	syscall
	
	addi	$t3,$t3,1	# $t3 = $t3 + 1
	bne	$t3,$t4,skipNewLine	# branches if $t3 != $t4
	
	li	$t3,0		# $t3 = 0
	li	$v0,4		# load printString to $v0
	la	$a0, newLine	# prints a new line
	syscall
	
	
skipNewLine:
    	addi 	$t1, $t1, 4	# $t1 = $t1 + 4
    	bne 	$t1, $t2, printBoard	# branches if $t1 != $t2
   	
   	jr 	$ra
	
setup:
	li	$v0,4		# load printString to $v0
	la	$a0, players	# prints the players prompt
	syscall
	
	li 	$v0,5		# load readInt to v0
	syscall
	
	ble	$v0,0,invalidNumberOfPlayers	# branches if less than 1 player is entered
	bge	$v0,3,invalidNumberOfPlayers	# branches if more than 2 players is entered
	
	move	$s7,$v0		# $s7 = $v0

	jr	$ra
	
invalidNumberOfPlayers:
	li	$v0,4		# load printString to $v0
	la	$a0,error3	# prints error message 3
	syscall
	
	j	setup
	