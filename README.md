vim-testdog
=============
### Creates unit test execution line ###

vim-testdog helps to create execution lines for running unit tests.

Simply position your cursor somewhere inside your unit test method and call
TestDogExecutable(..). TestDog will (hopefully) track down the parts needed to
create a complete execution line for that unit test and add it to the system
clipboard.

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
:call TestDogExecutable()
```
should generate:

"build/MyAppName_test --run_test=MyTestSuite/MyTestCase"

A tool prefix argument may also be added.
E.g. I use these leader key mapping:
```
nnoremap <leader>uu :call TestDogExecutable("")<cr>
nnoremap <leader>ug :call TestDogExecutable("gdb --args")<cr>
nnoremap <leader>uv :call TestDogExecutable("valgrind")<cr>
```

## Contributing
vim-testdog is currently implemented for CMake builds and the boost unit test
framework. As it's kind of hard to make this type of plugin work for every
setup, contributions are welcomed.

