.data

slist: .word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu:
	.ascii "\nColecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
return: .asciiz "\n"
catName: .asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria: "
idObj: .asciiz "\nIngrese el ID del objeto a eliminar: "
objName: .asciiz "\nIngrese el nombre de un objeto: "
success: .asciiz "La operación se realizo con exito\n\n"
error: .asciiz "Error: "
errorInvalidOption: .asciiz "(101) Opcion invalida."
errorEmptyCategories: .asciiz "(201) No hay categorias creadas."
errorSingleCategory: .asciiz "(202) Hay una sola categoría."
errorEmptyListCategories: .asciiz "(302) No hay categorias para mostrar."
errorEmptyDeleteCategory: .asciiz "(401) No hay categorias para eliminar."
errorAddObjectEmptyCategory: .asciiz "(501) No hay categorias disponibles para anexar un objeto."
errorListObjectEmptyCategory: .asciiz "(601) No hay categorias disponibles para eliminar un objeto."
errorListObjectEmptyObject: .asciiz "(602) La categoria no tiene objetos para eliminar."
errorCantDeleteCategory: .asciiz "La categoria tiene objetos anexados, debes eliminarlos primero."
notFound: .asciiz "No se ha encontrado el objeto."
errorDeleteObjectEmptyCategory: .asciiz "(701) No existen categorias para eliminar un objeto."
selectedCategorySymbol: .asciiz "> "
dot: .asciiz "."
.text

main:
	la $t0, schedv # initialization scheduler vector
	la $t1, newcategory
	sw $t1, 0($t0)
	la $t1, nextcategory
	sw $t1, 4($t0)
	la $t1, prevcategory
	sw $t1, 8($t0)
	la $t1, listcategory
	sw $t1, 12($t0)
	la $t1, delcategory
	sw $t1, 16($t0)
	la $t1, newobject
	sw $t1, 20($t0)
	la $t1, listobject
	sw $t1, 24($t0)
	la $t1, delobject
	sw $t1, 28($t0)

# menu

menu_loop:
	li $v0, 4
	la $a0, menu
	syscall
    
	li $v0, 5
	syscall

	beqz $v0, exit_program
	blt $v0, 0, invalid_option
	bgt $v0, 8, invalid_option
    
	addi $v0, $v0, -1
	sll $v0, $v0, 2
	la $t0, schedv
	add $t0, $t0, $v0
	lw $t1, ($t0)
	la $ra, menu_return
    	jr $t1

menu_return:
	j menu_loop	

invalid_option:
    li $v0, 4
    la $a0, error
    syscall

    la $a0, errorInvalidOption
    syscall
    j menu_loop

exit_program:
    li $v0, 10
    syscall

# categorias

newcategory:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	
	la $a0, catName	# input category name
	jal getblock
	move $a2, $v0		# $a2 = *char to category name
	
	la $a0, cclist		# $a0 = list
	li $a1, 0		# $a1 = NULL
	jal addnode
	
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist		# update working list if was NULL

newcategory_end:
	li $v0, 0		# return success
	
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	
	jr $ra

nextcategory:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	
	la $a0, wclist
	lw $t0, ($a0)
	beqz, $t0, nextcategory_none
	
	la $t1, 0($t0)
	lw $t1, 12($t1)
	sw $t1, wclist
	beq $t1, $t0, nextcategory_single
	
	li $v0, 4
	la $a0, selCat
	syscall

	li $v0, 4
	lw $a0, 8($t1)
	syscall
	
	j nextcategory_end

nextcategory_none:
	li $v0, 4
	la $a0, error
	syscall
	la $a0, errorEmptyCategories
	syscall
	
	j nextcategory_end

nextcategory_single:
	li $v0, 4
	la $a0, errorSingleCategory
	syscall
	
	j nextcategory_end

nextcategory_end:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	jr $ra

prevcategory:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	
	la $a0, wclist
	lw $t0, ($a0)
	beqz $t0, nextcategory_none
	
	la $t1, 0($t0)
	lw $t1, 0($t1)
	sw $t1, wclist
	beq $t1, $t0, nextcategory_single
	
	li $v0, 4
	la $a0, selCat
	syscall

	li $v0, 4
	lw $a0, 8($t1)
	syscall

prevcategory_end:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	jr $ra

listcategory:
	la $a0, wclist
	lw $t0, ($a0)
	beqz $t0, listcategory_empty
	la $t1, 0($t0)
	
	la $a0, selectedCategorySymbol
	li $v0, 4
	syscall

listcategory_show:
	lw $a0, 8($t1)
	
	li $v0, 4
	syscall
	
	lw $t1, 12($t1)
	beq $t1, $t0, menu_loop
	bne $t1, $t0, listcategory_show
	
	jr $ra

listcategory_empty:
	li $v0, 4
	la $a0, errorEmptyListCategories
	syscall
	
	jr $ra

delcategory:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	
	la $a1, cclist
	lw $t0, ($a1)
	beqz $t0, delcategory_empty
	
	lw $a0, wclist
	lw $t0, 4($a0)
	bnez $t0, delcategory_not_empty
	
	lw $t7, ($a0)
	sw $t7, wclist
	bne $a0, $t7, delnode
	
	sw $0, wclist
	jal delnode
	
	li $v0, 4
	la $a0, success
	syscall
	
	j delcategory_end

delcategory_empty:
	li $v0, 4
	la $a0, errorEmptyDeleteCategory
	syscall
	
	j delcategory_end

delcategory_not_empty:
	li $v0, 4
	la $a0, errorCantDeleteCategory
	syscall
	
	j delcategory_end

delcategory_end:
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra

# objetos

newobject:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	
	la $a0, cclist
	lw $t0, ($a0)
	beqz $t0, newobject_emptycategory
	
	la $a0, objName
	jal getblock
	
	move $a2, $v0
	lw $t6, wclist
	la $a0, 4($t6)
	jal addnode
	
	la $a1, ($v0)
	sw $a1, 4($t6)
	
	bnez $t0, newobject_end
	
	li $v0, 4
	la $a0, success
	syscall
	
newobject_emptycategory:
	li $v0, 4
	la $a0, errorAddObjectEmptyCategory
	syscall

newobject_end:
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra

listobject:
	la $a0, cclist
	lw $t0, ($a0)
	beqz $t0, listobject_emptyobject
	lw $a0, wclist
	lw $t0, 4($a0)
	beqz $t0, listobject_emptycategory
	move $t1, $t0
	li $t5, 0

listobject_show:
	addi $t5, $t5, 1
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	li $v0, 4
	la $a0, dot
	syscall
		
	lw $a0, 8($t1)
	li $v0, 4
	syscall

	lw $t1, 12($t1)
	beq $t1, $t0, menu_loop
	bne $t1, $t0, listobject_show
	jr $ra

listobject_emptyobject:
	li $v0, 4
	la $a0, errorListObjectEmptyObject
	syscall
	
	jr $ra
	
listobject_emptycategory:
	li $v0, 4
	la $a0, errorListObjectEmptyCategory
	syscall
	
	jr $ra

delobject:
	la $a0, cclist
	lw $t0, ($a0)
	beqz $t0, delobject_emptycategory

	lw $t7, wclist
	lw $t0, 4($t7)
	beqz $t0, delobject_noobjects

	li $v0, 4
	la $a0, idObj
	syscall

	li $v0, 5
	syscall

	move $t3, $v0
	move $a0, $t0

	li $t5, 1
	beq $t5, $t3, delobject_updatehead

	lw $a0, 12($a0)
	addi $t5, $t5, 1
	j delobject_loop

delobject_emptycategory:
	li $v0, 4
	la $a0, errorDeleteObjectEmptyCategory
	syscall
	jr $ra

delobject_noobjects:
	li $v0, 4
	la $a0, errorListObjectEmptyObject
	syscall
	jr $ra

delobject_notexists:
	li $v0, 4
	la $a0, notFound
	syscall
	jr $ra

delobject_updatehead:
	lw $t2, 12($a0)
	sw $t2, 4($t7)
	bne $t2, $a0, delnode
	li $t0, 0
	sw $t0, 4($t7)
	j delnode

delobject_loop:
	beq $t5, $t3, delnode
	lw $a0, 12($a0)
	addi $t5, $t5, 1
	beq $a0, $t0, delobject_notexists
	j delobject_loop

# utils

smalloc:
	lw $t0, slist
	beqz $t0, sbrk
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
sbrk:
	li $a0, 16 # node size fixed 4 words
	li $v0, 9
	syscall # return node address in v0
	jr $ra
sfree:
	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address in unused list
	jr $ra

# a0: msg to ask
# v0: block address allocated with string
getblock:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	li $v0, 4
	syscall
	jal smalloc
	move $a0, $v0
	li $a1, 16
	li $v0, 8
	syscall
	move $v0, $a0
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

addnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc
	sw $a1, 4($v0) # set node content
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) # first node address
	beqz $t0, addnode_empty_list

addnode_to_end:
	lw $t1, ($t0) # last node address
	# update prev and next pointers of new node
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	# update prev and first node to new node
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit

addnode_empty_list:
	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)

addnode_exit:
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

# a0: node address to delete
# a1: list address where node is deleted
delnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0) # get block address
	jal sfree # free block
	lw $a0, 4($sp) # restore argument a0
	lw $t0, 12($a0) # get address to next node of a0

node:
	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0) # get address to prev node
	sw $t1, 0($t0)
	sw $t0, 12($t1)
	lw $t1, 0($a1) # get address to first node

again:
	bne $a0, $t1, delnode_exit
	sw $t0, ($a1) # list point to next node
	j delnode_exit

delnode_point_self:
	sw $zero, ($a1) # only one node

delnode_exit:
	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra
