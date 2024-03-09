" test-dog.vim - Creates a unit test execution line
" Author:       Jörgen Scott (jorgen.scott@gmail.com)

if exists("g:loaded_test_dog") || &cp || v:version < 700
    finish
endif
let g:loaded_test_dog = 1

let g:test_framework = {}
let g:test_framework.boost = 1
let g:test_framework.catch = 2
let g:test_framework.google = 3
let g:preferred_framework = 'boost'

" public interface
function TestFileArg()
    let l:test_arg = <SID>BuildTestRunnerTestFileArg()
    if l:test_arg == ""
        return
    endif

    return " " . l:test_arg
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

" local methods
"
" start of boost unit test frame work methods
function! s:FindBoostFileTests()
    let l:curr_pos = getpos(".")
    exec "normal! gg"
    let l:all_tests = ""
    while search("SUITE\\_s*(", 'W') != 0
        exec "normal! f(w"
    	let all_tests .= expand("<cword>") . ','
    endwhile
    " seems to be no need to remove last ','
    :call setpos('.', curr_pos)
    return all_tests
endfunction

function! s:FindBoostTestSuite()
    let l:curr_pos = getpos(".")
    if search("SUITE\\_s*(", 'b') == 0
        return ""
    endif
    exec "normal! f(w"
    let test_suite = expand("<cword>")
    :call setpos('.', curr_pos)
    return test_suite
endfunction

function! s:FindBoostTestCase()
    let l:curr_pos = getpos(".")
    if search("CASE\\_s*(", 'b') == 0
        return ""
    endif
    exec "normal! f(w"
    let test_case = expand("<cword>")
    :call setpos('.', curr_pos)
    return test_case
endfunction

function! s:BuildBoostFileTestsArg()
    let l:dog_line = "--run_test="

    let l:test_suites = <SID>FindBoostFileTests()
    if test_suites == ""
        echoerr "No scent of test suites"
        return ""
    endif
    return dog_line . test_suites
endfunction

function! s:BuildBoostTestSuiteArg()
    let l:dog_line = "--run_test="

    let l:test_suite = <SID>FindBoostTestSuite()
    if test_suite == ""
        echoerr "No scent of test suite"
        return ""
    endif
    return dog_line . test_suite
endfunction

function! s:BuildBoostTestCaseArg()
    let l:dog_line = "--run_test="

    let l:test_suite = <SID>FindBoostTestSuite()
    if test_suite == ""
        echoerr "No scent of test suite"
        return ""
    endif
    let dog_line = dog_line . test_suite

    let l:test_case = <SID>FindBoostTestCase()
    if test_case == ""
        echoerr "No scent of test case"
        return ""
    endif
    return dog_line . "/" . test_case
endfunction
" end of boost unit test frame work methods

" start of catch unit test frame work methods
function! s:FindCatchFileTests()
    let l:curr_pos = getpos(".")
    exec "normal! gg"
    let l:all_tests = ""
    while search("TEST_CASE\\_s*(", 'W') != 0
        exec "normal! f[w"
        let all_tests .= '['.expand("<cword>").']' . ','
    endwhile
    :call setpos('.', curr_pos)
    return all_tests
endfunction

function! s:FindCatchTestSuite()
    let l:curr_pos = getpos(".")
    if search("TEST_CASE\\_s*(", 'b') == 0
        return ""
    endif
    exec "normal! f[w"
    let l:test_suite = '['.expand("<cword>").']'
    :call setpos('.', curr_pos)
    return l:test_suite
endfunction

" what this does..:
" when the most above catch keyword is 'SECTION', it return the section string
" when the most above catch keyword is 'TEST_CASE', it return the test_case string
function! s:FindCatchTestCase()
    let l:curr_pos = getpos(".")
    let l:line_section = search("SECTION\\_s*(", 'b')
    :call setpos('.', curr_pos)
    let l:line_test_case = search("TEST_CASE\\_s*(", 'b')
    if l:line_section == 0 || l:line_test_case == 0
        return ""
    endif
    :call setpos('.', curr_pos)
    echom l:curr_pos
    " get max of SECTION AND TEST_CASE
    let l:use_line = 0
    if l:line_section > l:line_test_case
        let l:use_line = l:line_section
    else
        let l:use_line = l:line_test_case
    endif
    :call cursor(l:use_line, 0)

    exec 'normal! f"'
    " TODO: how to assign expression to variable without using register?
    exec 'normal! "ayf"'
    let test_case = @a
    :call setpos('.', curr_pos)
    echom test_case
endfunction
" end of catch unit test frame work methods

" start of google unit test frame work methods
function! s:FindGoogleTestSuite()
    let l:curr_pos = getpos(".")
    if search("TEST\\_s*(", 'b') == 0
        return ""
    endif
    exec "normal! f(w"
    let test_suite = expand("<cword>")
    :call setpos('.', curr_pos)
    return test_suite
endfunction

function! s:FindGoogleTestCase()
    let l:curr_pos = getpos(".")
    if search("TEST\\_s*(", 'b') == 0
        return ""
    endif
    exec "normal! f(%b"
    let test_case = expand("<cword>")
    :call setpos('.', curr_pos)
    return test_case
endfunction

function! s:BuildGoogleTestSuiteArg()
    let l:dog_line = "--gtest_filter="

    let l:test_suite = <SID>FindGoogleTestSuite()
    if test_suite == ""
        echoerr "No scent of test suite"
        return ""
    endif
    return dog_line . test_suite
endfunction

function! s:BuildGoogleTestCaseArg()
    let l:dog_line = "--gtest_filter="

    let l:test_suite = <SID>FindGoogleTestSuite()
    if test_suite == ""
        echoerr "No scent of test suite"
        return ""
    endif
    let dog_line = dog_line . test_suite

    let l:test_case = <SID>FindGoogleTestCase()
    if test_case == ""
        echoerr "No scent of test case"
        return ""
    endif
    return dog_line . "." . test_case
endfunction
" end of google unit test frame work methods

" prompts the caller for changing preferred test framework
function! s:FrameworkSelect()
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
        if sel > max
            echoerr "Please select a number within range"
        elseif sel == type(0)
            return ""
        else
            return sort(keys(g:test_framework))[sel - 1]
        endif
    endwhile
endfunction

" test runner router method
function! s:BuildTestRunnerTestFileArg()
    let l:res = ""
    while 1
        if get(g:test_framework, g:preferred_framework) == g:test_framework.boost
            let l:res = <SID>BuildBoostFileTestsArg()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.catch
            let l:res = <SID>FindCatchFileTests()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.google
            let l:res = "TODO: Not implemented"
        endif

        if l:res == ""
            let l:framework = <SID>FrameworkSelect()
            if l:framework == ""
                break
            else
                let g:preferred_framework = l:framework
            endif
        else
            break
        endif
    endwhile

    return l:res
endfunction

" test runner router method
function! s:BuildTestRunnerTestSuiteArg()
    let l:res = ""
    while 1
        if get(g:test_framework, g:preferred_framework) == g:test_framework.boost
            let l:res = <SID>BuildBoostTestSuiteArg()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.catch
            let l:res = <SID>FindCatchTestSuite()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.google
            let l:res = <SID>BuildGoogleTestSuiteArg()
        endif

        if l:res == ""
            let l:framework = <SID>FrameworkSelect()
            if l:framework == ""
                break
            else
                let g:preferred_framework = l:framework
            endif
        else
            break
        endif
    endwhile

    return l:res
endfunction

" test runner router method
function! s:BuildTestRunnerTestCaseArg()
    let l:res = ""
    while 1
        if get(g:test_framework, g:preferred_framework) == g:test_framework.boost
            let l:res = <SID>BuildBoostTestCaseArg()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.catch
            let l:res = <SID>FindCatchTestCase()
        elseif get(g:test_framework, g:preferred_framework) == g:test_framework.google
            let l:res = <SID>BuildGoogleTestCaseArg()
        endif

        if l:res == ""
            let l:framework = <SID>FrameworkSelect()
            if l:framework == ""
                break
            else
                let g:preferred_framework = l:framework
            endif
        else
            break
        endif
    endwhile

    return l:res
endfunction

" vim:set ft=vim sw=4 sts=2 et:
