vim-testdog
=============
### Sniffs out test runner arguments ###

vim-testdog helps to create unit test arguments for unit test runners.

It provides two methods: `TestSuiteArg()` and `TestCaseArg()`.

Simply position your cursor somewhere inside a unit test and call
`:echo TestCaseArg()`. TestDog will (hopefully) track down the parts needed and
return the test runner argument.

Currently there's support for the Boost and Google unit test frame works.

Example:
```
..
BOOST_FIXTURE_TEST_SUITE(MyTestSuite, MyFixture)

..
BOOST_AUTO_TEST_CASE(MyTestCase)
{
	MyClass unitUnderTest;
	BOOST_CHECK(unitUnderTest.SomeMethod() == true);
}
..
```
With the cursor inside MyTestCase:
```VimL
:echo TestCaseArg()
```
should generate:

"--run_test=MyTestSuite/MyTestCase"

## Installation
Pathogen, Vundle, etc..

## Usage
Example:
```VImL
" copy test argument to clipboard
nnoremap <leader>tr :call setreg('+', TestCaseArg())<cr>
```
I typically combine TestDog with [vim-target](https://github.com/raspine/vim-target) 

These are example mappings to invoke vim-target and vim-testdog:
```VimL
" run test suite directly in vim
nnoremap <leader>tt :exec "!". FindExeTarget() . TestSuiteArg()<cr>

" Spawn a gdb session in a separate terminal. The ending  '&' unlocks
" Vim while debugging.
nnoremap <leader>tg :exec "!urxvt -e gdb --args " FindExeTarget() . TestCaseArg()<cr>

" run the test suite under valgrind
nnoremap <leader>tv :exec "!valgrind " . FindExeTarget() . TestSuiteArg()<cr>

" copy the full execution line to clipboard
nnoremap <leader>tr :call setreg('+', FindExeTarget() . TestCaseArg())<cr>
```

I further combine vim-testdog with [vim-breakgutter](http://github.com/raspine/vim-breakgutter) providing
the following magical line whenever I need to debug a test case:
```VimL
" Spawn requires Tim Pope's vim-dispatch plugin
nnoremap <leader>dg :exec "Spawn urxvt -e gdb " . GetGdbBreakpointArgs() . " --args " . FindExeTarget() . TestCaseArg()<cr>

```

## Variables
There's only one variable you might want to set in your .vimrc:
```VimL
let g:preferred_framework = 'boost' "default
_OR_
let g:preferred_framework = 'google'
```
If testdog fails to sniff out the test runner arguments, it will prompt the
caller to change preferred framework. The new preferred is non-persistent (so
that's why you might want to set it).

## Contributing
As it's kind of hard to make this type of plugin work for every test framework,
contributions are welcomed.

## License
Distributed under the same terms as Vim itself.  See the vim license.

