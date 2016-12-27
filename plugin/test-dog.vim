" test-dog.vim - Creates a unit test execution line
" Author:       Jörgen Scott (jorgen.scott@gmail.com)
" Version:      0.1

if exists("g:loaded_test_dog") || &cp || v:version < 700
    finish
endif
let g:loaded_test_dog = 1

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

" test runner router method
function! s:BuildTestRunnerTestSuiteArg()
    "TODO: support more test frameworks through the use of global variable
    "append test suite
    return <SID>BuildBoostTestSuiteArg()
endfunction

" test runner router method
function! s:BuildTestRunnerTestCaseArg()
    "TODO: support more test frameworks through the use of global variable
    "append test suite
    return <SID>BuildBoostTestCaseArg()
endfunction

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
" vim:set ft=vim sw=4 sts=2 et:
