" test-dog.vim - Creates a unit test execution line
" Author:       Jörgen Scott (jorgen.scott@gmail.com)
" Version:      0.1

if exists("g:loaded_test_dog") || &cp || v:version < 700
    finish
endif
let g:loaded_test_dog = 1

" TODO: Is there a Vim function for this?
function! s:ExtractInner(str, left_delim, right_delim)
    let astr = " " . a:str . " "
    let inner = split(astr, a:left_delim)[1]
    let inner = split(inner, a:right_delim)[0]
    let inner = substitute(inner, '^\s*\(.\{-}\)\s*$', '\1', '')
    return inner
endfunction

function! TestDog(exe_prefix, app_prefix, app_postfix)
    " find the app name...
    " find the CMake build dir, our main CMakeLists.txt should be lurking just above
    let l:found = 0
    let l:app_name = ""
    let l:cmake_build_dir = get(g:, 'cmake_build_dir', 'build')
    let l:build_dir = finddir(l:cmake_build_dir, '.;')
    if filereadable(build_dir . '/../CMakeLists.txt')
        let cm_list = readfile(build_dir . '/../CMakeLists.txt')
        for line in cm_list
            " look for the project name
            if line =~ "project("
                let app_name = ExtractInner(line, "(", ")")
                " check if a cmake variable is used, if so make new loop and
                " find the variable
                if app_name =~ "${"
                    let app_name = ExtractInner(app_name, "{", "}")
                    for app_line in cm_list
                        if app_line =~ app_name
                            let app_name = ExtractInner(app_line, app_name, ")")
                            let found = 1
                            break
                        endif
                    endfor
                 else
                     let found = 1
                     break
                endif
            endif
        endfor
    else
        let l:dog_error = "Woof Woof! no scent of CMakeList.txt"
        echo dog_error
        return dog_error
    endif

    if found == 0
        let l:dog_error = "Woof Woof! no scent of app name"
        echo dog_error
        return dog_error
    endif

    " ..app_name found
    " our line so far
    let dog_line = a:exe_prefix . " " . build_dir . "/" . a:app_prefix . app_name . a:app_postfix . " --run_test="

    "append test suite
    let l:curr_pos = getpos(".")
    exec "silent! :keeppatterns /TEST_SUITE("
    let l:new_pos = getpos(".")
    if curr_pos == new_pos
        let l:dog_error = "Woof Woof! no scent of test suite"
        echo dog_error
        return dog_error
    endif
    exec "normal! %%l"
    let testsuite = expand("<cword>")
    let dog_line = dog_line . testsuite
    :call setpos('.', curr_pos)

    "append test case
    exec "normal! [[k%%l"
    let testcase = expand("<cword>")
    :call setpos('.', curr_pos)
    let dog_line = dog_line . "/" . testcase

    " finally write to clipboard
    call setreg('+', dog_line)
    echo "Woof woof! ". dog_line
endfunction
" vim:set ft=vim sw=4 sts=2 et:
