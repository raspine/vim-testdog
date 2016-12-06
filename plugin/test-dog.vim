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

" A cmake parser with the single purpose of finding the executable name
" for the % file. The function only returns a single executable name and 
" do not handle executable names built with multiple concatenated cmake variables.
function! s:FindCMakeExeName()
    let l:found_var = 0
    let l:var_name = ""
    let l:app_name = ""
    let l:cmake_build_dir = get(g:, 'cmake_build_dir', 'build')
    let l:build_dir = finddir(l:cmake_build_dir, '.;')
    if build_dir == ""
        return ""
    endif
        
    " look for CMakeLists.txt in current dir
    let l:curr_cmake = expand("%:h") . '/CMakeLists.txt'
    if filereadable(curr_cmake)
        let cm_list = readfile(curr_cmake)
        for line in cm_list
            " look for the project name
            if line =~ "add_executable\\_s*("
                let var_name = <SID>ExtractInner(line, "(", " ")
                if var_name =~ "${\\_s*project_name\\_s*}"
                    for proj_line in cm_list
                        if proj_line =~ "project\\_s*("
                            let var_name = <SID>ExtractInner(proj_line, "(", ")")
                            if var_name =~ "${"
                                let app_name = var_name
                                let var_name = <SID>ExtractInner(var_name, "{", "}")
                                let found_var = 1
                            else
                                return build_dir . "/" . var_name
                            endif
                            break
                        endif
                    endfor
                elseif var_name =~ "${"
                    let app_name = var_name
                    let var_name = <SID>ExtractInner(var_name, "{", "}")
                    let found_var = 1
                else
                    return build_dir . "/" . var_name
                endif
            endif
        endfor
        if found_var == 0
            return ""
        endif
    endif
    
    " couldn't conclude the app name in a local CMakeLists.txt
    " let's look in the root CMakeLists.txt, lurking above our build dir
    let main_app_name = ""
    let main_app_found = 0
    if filereadable(build_dir . '/../CMakeLists.txt')
        let cm_list = readfile(build_dir . '/../CMakeLists.txt')
        for line in cm_list
            if found_var == 0
                " look for the project name in case there was no local CMakeLists.txt
                if line =~ "project\\_s*("
                    let main_app_name = <SID>ExtractInner(line, "(", ")")
                    " check if a cmake variable is used, if so make new loop and
                    " find the variable
                    if main_app_name =~ "${"
                        let main_app_name = <SID>ExtractInner(main_app_name, "{", "}")
                        for app_line in cm_list
                            if app_line =~ main_app_name
                                let main_app_name = <SID>ExtractInner(app_line, main_app_name, ")")
                                return build_dir . "/" . main_app_name
                            endif
                        endfor
                    else
                        return build_dir . "/" . main_app_name
                    endif
                endif
            else
                " in case we do have a var_name, we look for a set function
                if line =~ "set\\_s*(\\_s*" . var_name
                    let main_app_name = <SID>ExtractInner(line, var_name, ")")
                    let main_app_found = 1
                endif
            endif
        endfor

        if main_app_found == 0
            return ""
        endif

        " If here, we have a e.g. main_app_name="my_app", e.g. var_name="APP_NAME"
        " and e.g. app_name="${APP_NAME}_test".
        " So we make a substitution of what we got, e.g. to my_app_test.
        " echo main_app_name . " " . var_name . " " . app_name
        let app_name = substitute(app_name, "${\\_s*" . var_name . "\\_s*}", main_app_name, "")
        return build_dir . "/" . app_name
    else
        return ""
    endif
endfunction

function! TestDogExecutable(tool_prefix)
    " find the app name...
    let l:app_name = <SID>FindCMakeExeName()

    if app_name == ""
        echoerr "Woof! No scent of app name"
        return
    endif

    " ..app_name found
    " our line so far
    let dog_line = a:tool_prefix . " " . app_name . " --run_test="

    "append test suite
    let l:curr_pos = getpos(".")
    exec "silent! keeppatterns ?\\cSUITE\\_s*("
    let l:new_pos = getpos(".")
    if curr_pos == new_pos
        echoerr "Woof! No scent of test suite"
        return
    endif
    exec "normal! f(w"
    let testsuite = expand("<cword>")
    let dog_line = dog_line . testsuite
    :call setpos('.', curr_pos)

    "append test case
    exec "silent! keeppatterns ?\\cCASE\\_s*("
    let l:new_pos = getpos(".")
    if curr_pos == new_pos
        echoerr "Woof! No scent of test case"
        return
    endif
    exec "normal! f(w"
    let testcase = expand("<cword>")
    :call setpos('.', curr_pos)
    let dog_line = dog_line . "/" . testcase

    " finally write to clipboard
    call setreg('+', dog_line)
    call setreg('*', dog_line)
    echo "Woof Woof! " . dog_line
endfunction
" vim:set ft=vim sw=4 sts=2 et:
