Running large numbers of Android unit tests together seems to cause problems.  
Large being at least 300 to 500 tests for a single project.

See: http://stackoverflow.com/questions/3576887/large-amount-of-unit-tests-cause-freezes-with-failed-binder-transaction

This repository is an attempt to reproduce this as simply as possible, with the desire to be able to file meaningful bugs or come up with a solution.

Seems to work:

1. git clone git://github.com/orrc/android-large-test-failures.git
2. cd android-large-test-failures
3. ./run-tests.sh
4. Observe that tests pass

Does not seem to work:

1. git clone git://github.com/orrc/android-large-test-failures.git
2. Import these "unit-testing" and "unit-testing-tests" Eclipse projects
3. Run unit tests from Eclipse
4. Observe that tests do not run, logcat output shows "!!! FAILED BINDER TRANSACTION !!!"

The difference between the two is that Eclipse runs the entire test suite in two passes:

* First pass: to gather all the test classes and names, but without actually executing the code
* Second pass: to actually execute the code

In this first case, there is some code in the Eclipse JUnit test runner that mentions binder transactions:  
http://android.git.kernel.org/?p=platform/sdk.git;a=commitdiff;h=c7e4658b149c04820bd8ea8da7bc2515df6a94a3

However, I believe I have also seen this without running from Eclipse...

You can reproduce the first pass with the following command line:  
adb shell am instrument -e log true -e delay_msec 15 -w org.example.testing.unit.test/android.test.InstrumentationTestRunner

The "log" and "delay_msec" flags mimic the way that Eclipse runs the tests, i.e. with a 15ms delay between tests.

However, I have noted that this runs fine on the command line, even with a delay_msec value of 3ms.
But as soon as it's run from Eclipse, with its 15ms delay, it fails.