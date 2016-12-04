vim-testdog
=============
### Creates unit test execution line ###

vim-testdog is a simple plugin to help with running individual unit tests.
Simply make sure your cursor is somewhere inside your unit test method and call
TestDog(..). If successful, TestDog(..) will try to find the parts needed to create
a complete execution line for that unit test and add it to the system clipboard.

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
:call TestDog("gdb --args", "", "_test")
```
will generate:

"gdb --args build/MyAppName_test --run_test=MyTestSuite/MyTestCase"

E.g. I use these leader key mapping:
```
nnoremap <leader>uu :call TestDog("", "", "_test")<cr>
nnoremap <leader>ug :call TestDog("gdb --args", "", "_test")<cr>
nnoremap <leader>uv :call TestDog("valgrind", "", "_test")<cr>
```

## Contributing
vim-testdog is currently implemented for CMake builds and the boost unit test
framework. As it's kind of hard to make this type of plugin work for every
setup, contributions are welcomed.

If you need to tweak it to work with your particular setup, please do it as
follows:
* Create a minimal test project in test/
* Add a test case in test_dog_tests.sh
* Once it pass, make the pull request.
