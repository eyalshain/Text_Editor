section .data
    
    ; start menu
    start_menu db  '---------------------------------------------------------------------------',0ah,0dh
               db  '*                                                                         *',0ah,0dh
               db  '*                        WELCOME TO MY TEXT EDITOR!!!                     *',0ah,0dh                                                                  
               db  '*                                                                         *',0ah,0dh
               db  '---------------------------------------------------------------------------',0ah,0ah, 0ah
    menu_len equ $ - start_menu

     ; options for the user
    options db 'options: ', 0ah, 0dh                             
                db '1. Create a new file', 0ah, 0dh
                db '2. Open existing file', 0ah, 0dh
                db '3. Exit', 0ah, 0dh
                db 'Please enter the num of the option: ', 0ah, 0dh

    options_len equ $ - options

    ; 'creating a file' menu
    print_create_file db   0ah, '**********************************', 0ah, 0dh   
                      db   '*                                *', 0ah, 0dh
                      db   '*        Creating a file!        *', 0ah, 0dh     
                      db   '*                                *', 0ah, 0dh
                      db   '**********************************', 0ah, 0ah

    print_create_file_len equ $ - print_create_file


    print_open_file db 0ah, '*******************************************', 0ah, 0dh
                    db '*                                         *', 0ah, 0dh
                    db '*              Opening a file!            *', 0ah, 0dh 
                    db '*                                         *', 0ah, 0dh 
                    db '*******************************************', 0ah, 0dh  

    print_open_file_len equ $ - print_open_file
    ; message for reading a file name from the user
    file_name_prompt db 'Please enter a file name (add .txt): ', 0
    file_name_prompt_len equ $ - file_name_prompt

    ; message for reading a file name / full path
    file_opening_prompt db 'Please enter a file name that you want to open.', 0ah, 0dh
                        db 'if the file is on a different directory, move the file to the current directory. ', 0ah, 0dh
                        db 'file name: ', 0
    file_opening_prompt_len equ $ - file_opening_prompt

    open_file_error db "Error. failed to open a file. ", 0ah, 0dh
    open_file_error_len equ $ - open_file_error
    
    ; clearing the screen using ANSI escape code.
    clear_screen_msg db 0x1B, '[2J', 0x1B, '[H' 
    clear_len equ $ - clear_screen_msg

    ; message for the writing file page
    print_exit_esc db 0ah, 'Start writing!', 0ah, 0dh
                   db      'To exit, press: esc', 0ah, 0ah

    print_exit_esc_len equ $ - print_exit_esc

    ; message for successfully written a file
    file_w db 0ah, 'The file has been created and written successfully! ', 0ah, 0dh
    file_w_len equ $ - file_w

    ; error msg
    error_msg db 0ah, 0ah, 'Invalid option, try again. ', 0ah, 0ah
    error_msg_len equ $ - error_msg

    new_line db 0ah
    new_line_len equ $ - new_line

    line db '----------------------------------------------------------------------------', 0ah, 0dh
    line_len equ $ - line

    open_file_msg db 0ah, 0ah, 'File has been opened successfully! ', 0ah, 0dh
    open_file_msg_len equ $ - open_file_msg

section .bss
    ; input_option needs 1 byte, but because there is a new line char, I will set it to 2 bytes.
    input_option resb 2
    file_name resb 100
    file_content resb 1024


section .text
    global _start

_start:

print_menu:

    call clear_screen

    ;printing the start menu
    mov rax, 1
    mov rdi, 1
    mov rsi, start_menu
    mov rdx, menu_len
    syscall

    jmp print_option


clear_screen:    
    ; clearing the screen
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen_msg
    mov rdx, clear_len
    syscall
    ret
    
print_option:
    ;printing the options
    mov rax, 1
    mov rdi, 1
    mov rsi, options
    mov rdx, options_len
    syscall

    ;read user option
    mov rax, 0
    mov rdi, 0
    mov rsi, input_option
    mov rdx, 2
    syscall

    ; Remove newline from input_option if present
    mov byte [input_option + 1], 0
    

    ; comparing the input from the user, to see if he wants to create a file, open a file, or exit.
    mov rax, [input_option]
    cmp rax, '1'
    je create_file

    mov rax, [input_option]
    cmp rax, '2'
    je open_file
    
    mov rax, [input_option]
    cmp rax, '3'
    je exit_editor

    jmp print_error




create_file:
    
    ; printing the 'creating a file' menu
    mov rax, 1
    mov rdi, 1
    mov rsi, print_create_file
    mov rdx, print_create_file_len
    syscall

    ; printing 'Enter a file name'
    mov rax, 1
    mov rdi, 1
    mov rsi, file_name_prompt
    mov rdx, file_name_prompt_len
    syscall

    ; reading a file name
    mov rax, 0
    mov rdi, 0
    mov rsi, file_name
    mov rdx, 100
    syscall
    
    ; because the user also enter the null terminator '\n', we want to delete it.
    mov rdi, file_name
    call find_end  
   
    ; opening a file for writing - (O_CREAT | O_WRONLY)
    ; 0001, 0100: OR = 0101h
    mov rax, 2
    mov rdi, file_name
    mov rsi, 101o
    mov rdx, 600o
    syscall 
    mov rbx, rax ; save the file descriptor

    call clear_screen
    
    ; printing 'esc for exiting'
    
    mov rax, 1
    mov rdi, 1
    mov rsi, print_exit_esc
    mov rdx, print_exit_esc_len
    syscall
    

waiting_for_input:

    ; reading the file content from the user
    mov rax, 0
    mov rdi, 0
    mov rsi, file_content
    mov rdx, 1024
    syscall
    mov rcx, rax ; save the number bytes read


    ; esc in ascii = 27
    mov al, [file_content]
    cmp al, 27
    je close_file

    ; write to a file
    mov rax, 1
    mov rdi, rbx
    mov rsi, file_content
    mov rdx, rcx
    syscall

   ; continue reading input
    jmp waiting_for_input


close_file:
    mov rax, 3
    mov rdi, rbx
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, file_w
    mov rdx, file_w_len
    syscall

    jmp exit_program

open_file:

    ; clearing the screen.
    call clear_screen

    ; print a start message for opening a file name
    mov rax, 1
    mov rdi, 1
    mov rsi, print_open_file
    mov rdx, print_open_file_len
    syscall

    ; print message for reading a file name
    mov rax, 1
    mov rdi, 1
    mov rsi, file_opening_prompt
    mov rdx, file_opening_prompt_len
    syscall

    ; reading a file name
    mov rax, 0
    mov rdi, 0
    mov rsi, file_name
    mov rdx, 100
    syscall

    ; remove newline character at the end of the filename/path
    mov rdi, file_name
    call find_end

    ; opening the file for read / write option.
    mov rax, 2
    mov rdi, file_name
    mov rsi, 02o | 0100o  ; O_RDWR | O_CREAT (read/write and create if doesn't exist)
    mov rdx, 0600o        ; mode (permissions) - read and write for the owner
    syscall       

    ; check if the file has been successfully opened
    cmp rax, -1
    je print_file_open_error       

    mov rbx, rax    ; save the file descriptor

    ; prints a new line seperator before writing the file content :)
    mov rax, 1
    mov rdi, 1
    mov rsi, line
    mov rdx, line_len
    syscall

read_file:

    ; reading the file content, so we can write it out to the console.
    mov rax, 0
    mov rdi, rbx
    mov rsi, file_content
    mov rdx, 1024
    syscall

    ; check if the end of the file
    test rax, rax      ; if rax == 0, we reached the end
    jz end_of_file
    js print_file_open_error      ; if rax < 0, something wrong happened...

    ; writing the file content to the console
    mov rax, 1
    mov rdi, 1
    mov rsi, file_content
    mov rdx, 1024
    syscall

    jmp read_file


end_of_file:  

    ; closing the file
    mov rax, 3
    mov rdi, rbx    ; file descriptor 
    syscall

    ; printing '---------' to make things more clear
    mov rax, 1
    mov rdi, 1
    mov rsi, line
    mov rdx, line_len
    syscall

    ; printing success on opening the file
    mov rax, 1
    mov rdi, 1
    mov rsi, open_file_msg
    mov rdx, open_file_msg_len
    syscall

    ; exiting the editor.
    jmp exit_editor


exit_editor:
    jmp exit_program


exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall


; finding the end of the string, and then using the remove_null to remove the last char.
find_end:
    mov al, [rdi]
    cmp al, 0
    je remove_null
    inc rdi
    jmp find_end

; removing the last char.
remove_null:
    sub rdi, 1
    mov byte [rdi], 0
    ret

; printing error, and then moving back the start so the user can enter a new option value.
print_error:

    ; clearing the screen first.
    call clear_screen

    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall

    ; letting the user enter an option again.
    jmp print_option


print_file_open_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, open_file_error
    mov rdx, open_file_error_len
    syscall
    jmp exit_editor