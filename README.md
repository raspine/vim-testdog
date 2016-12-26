vim-testdog
=============
### Creates unit test execution lines ###

vim-testdog helps to create execution lines for unit test runners.

Simply position your cursor somewhere inside your unit test method and call
TestDogExecutable. TestDog will (hopefully) track down the parts needed and
return a complete execution line.

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
:echo TestDogExecutable()
```
should generate:

"build/MyAppName_test --run_test=MyTestSuite/MyTestCase"

These are example mappings to invoke TestDog:
```
" run test case directly in vim
nnoremap <leader>tt :exec "!" . TestDogExecutable()<cr>

" spawn a gdb session in a separate terminal (requires Tim Pope's vim-dispatch plugin)
nnoremap <leader>tg :exec "Spawn urxvt -e gdb --args " . TestDogExecutable()<cr>

" run the test case under valgrind
nnoremap <leader>tv :exec "!valgrind " . TestDogExecutable()<cr>
```

There's also the TestDogArg command that only creates the test runner argument,
i.e. the "--run_test=MyTestSuite/MyTestCase" from the example above.

## Contributing
vim-testdog is currently implemented for CMake builds and the boost unit test
framework. As it's kind of hard to make this type of plugin work for every
setup, contributions are welcomed.

