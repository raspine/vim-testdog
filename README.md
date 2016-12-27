vim-testdog
=============
### Sniffs out test runner arguments ###

vim-testdog helps to create unit test arguments for unit test runners.

It provides two methods: `TestSuiteArg()` and `TestCaseArg()`.

Simply position your cursor somewhere inside a unit test and call
`:echo TestCaseArg()`. TestDog will (hopefully) track down the parts needed and
return the test runner argument.

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
```
:echo TestCaseArg()
```
should generate:

"--run_test=MyTestSuite/MyTestCase"

## Usage
I typically combine TestDog with [vim-target](https://github.com/raspine/vim-target) 

These are example mappings to invoke vim-target and vim-testdog:
```
" run test suite directly in vim
nnoremap <leader>tt :exec "!". FindCMakeTarget() . TestSuiteArg()<cr>

" spawn a gdb session in a separate terminal using Tim Pope's vim-dispatch plugin
nnoremap <leader>tg :exec "Spawn urxvt -e gdb --args" FindCMakeTarget() . TestCaseArg()<cr>

" run the test suite under valgrind
nnoremap <leader>tv :exec "!valgrind" . FindCMakeTarget() . TestSuiteArg()<cr>

" copy the execution line to clipboard
nnoremap <leader>tr :call setreg('+', FindCMakeTarget() . TestCaseArg())<cr>
```

I further combine vim-testdog with [vim-breakgutter](http://github.com/raspine/vim-breakgutter) providing
the following magical line (that actually goes into my .vimrc) whenever I need to debug a test case:
```
" Spawn requires Tim Pope's vim-dispatch plugin
nnoremap <leader>dg :exec "Spawn urxvt -e gdb" . GetGdbBreakpointArgs() . " --args " . FindCMakeTarget() . TestCaseArg()<cr>

```

## Contributing
vim-testdog is currently implemented for the boost unit test framework. As it's
kind of hard to make this type of plugin work for every test framework,
contributions are welcomed.

## License

Distributed under the same terms as Vim itself.  See the vim license.

