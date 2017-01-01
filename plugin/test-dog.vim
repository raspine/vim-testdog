" test-dog.vim - Creates a unit test execution line
" Author:       Jörgen Scott (jorgen.scott@gmail.com)
" Version:      0.1

if exists("g:loaded_test_dog") || &cp || v:version < 700
    finish
endif
let g:loaded_test_dog = 1

let g:test_framework = {}
let g:test_framework.boost = 1
let g:test_framework.google = 2
let g:preferred_framework = 'boost'

" public interface
function! TestSuiteArg()
    let l:test_arg = <SID>BuildTestRunnerTestSuiteArg()
    if l:test_arg == ""
        return
    endif

    return " " . l:test_arg
endfunction

function! TestCaseArg()
    let l:test_arg = <SID>BuildTestRunnerTestCaseArg()
    if l:test_arg == ""
        return
    endif

    return " " . l:test_arg
endfunction

" local methods
function! s:FindBoostTestSuite()
    let l:curr_pos = getpos(".")
    exec "silent! keeppatterns ?\\cSUITE\\_s*("
    let l:new_pos = getpos(".")
    if curr_pos == new_pos
        return ""
    endif
    exec "normal! f(w"
    let test_suite = expand("<cword>")
    :call setpos('.', curr_pos)
    return test_suite
endfunction

function! s:FindBoostTestCase()
    let l:curr_pos = getpos(".")
    exec "silent! keeppatterns ?\\cCASE\\_s*("
    let l:new_pos = getpos(".")
    if curr_pos == new_pos
        return ""
    endif
    exec "normal! f(w"
    let test_case = expand("<cword>")
    :call setpos('.', curr_pos)
    return test_case
endfunction

function! s:BuildBoostTestSuiteArg()
    let l:dog_line = "--run_test="

    let l:test_suite = <SID>FindBoostTestSuite()
    if test_suite == ""
        echoerr "Woof! No scent of test suite"
        return ""
    endif
    return dog_line . test_suite
endfunction

function! s:BuildBoostTestCaseArg()
    let l:dog_line = "--run_test="

    let l:test_suite = <SID>FindBoostTestSuite()
    if test_suite == ""
        echoerr "Woof! No scent of test suite"
        return ""
    endif
    let dog_line = dog_line . test_suite

    let l:test_case = <SID>FindBoostTestCase()
    if test_case == ""
        echoerr "Woof! No scent of test case"
        return ""
    endif
    return dog_line . "/" . test_case
endfunction

function! s:BuildGooleTestSuiteArg()
    let l:dog_line = "--filter="

    " let l:test_suite = <SID>FindBoostTestSuite()
    " if test_suite == ""
    "     echoerr "Woof! No scent of test suite"
    "     return ""
    " endif
    " return dog_line . test_suite
    return "gsuite"
endfunction

function! s:BuildGoogleTestCaseArg()
    let l:dog_line = "--filter="

    " let l:test_suite = <SID>FindBoostTestSuite()
    " if test_suite == ""
    "     echoerr "Woof! No scent of test suite"
    "     return ""
    " endif
    " let dog_line = dog_line . test_suite

    " let l:test_case = <SID>FindBoostTestCase()
    " if test_case == ""
    "     echoerr "Woof! No scent of test case"
    "     return ""
    " endif
    " return dog_line . "/" . test_case
    return "gcase"
endfunction

function! FrameworkSelect()
    echo "Try another framework?"
    let l:sel = 0
    while 1
        echo '0) abort'
        for index in sort(keys(g:test_framework))
            echo get(g:test_framework, index). ") ". index 
        endfor
        let l:max = get(g:test_framework, index)
        call inputsave()
        let sel = input('Select index: ')
        call inputrestore()
        if sel == type(0) || sel > max
            echoerr "Please select a number within range"
        else
            break
        endif
    endwhile
    return sort(keys(g:test_framework))[sel - 1]
endfunction

" test runner router method
function! s:BuildTestRunnerTestSuiteArg()
    let l:res = ""
    while 1
        if get(g:test_framework, g:preferred_framework) == g:test_framework.boost
            let l:res = <SID>BuildBoostTestSuiteArg()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.google
            let l:res = <SID>BuildGoogleTestSuiteArg()
        endif

        if l:res == ""
            g:preferred_framework = <SID>FrameworkSelect()
        else
            break
        endif
    endwhile

    return l:res
endfunction

" test runner router method
function! s:BuildTestRunnerTestCaseArg()
    "TODO: support more test frameworks through the use of global variable
    "append test suite
    let l:res = <SID>BuildBoostTestCaseArg()
    return res
endfunction

" vim:set ft=vim sw=4 sts=2 et:
