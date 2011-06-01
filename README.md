## Introduction

Running large numbers of Android unit tests together seems to cause problems.  
Large being at least 300 to 500 tests for a single project.

While running tests on an Android emulator, at some point the test runner will stop executing and possibly crash.  
This has not been observed on an actual Android device so far.

See: http://stackoverflow.com/questions/3576887/large-amount-of-unit-tests-cause-freezes-with-failed-binder-transaction

This repository is an attempt to reproduce this as simply as possible,
with the desire to be able to file meaningful bugs or come up with a solution.

It contains a minimal Android project plus test project.  
The test project makes some very basic Android JUnit assertions,
and repeats them 1000 times, using 1000 separate test methods.

## Reproducing the issue

Running from the command line seems to work:

1. git clone git://github.com/orrc/android-large-test-failures.git
2. cd android-large-test-failures
3. ./run-tests.sh
4. Observe that tests pass

Running from Eclipse does not seem to work:

1. git clone git://github.com/orrc/android-large-test-failures.git
2. Import these "unit-testing" and "unit-testing-tests" Eclipse projects
3. Run unit tests from Eclipse
4. Observe that tests do not run, logcat output shows "!!! FAILED BINDER TRANSACTION !!!"

## Differences

The difference between the two is that Eclipse runs the entire test suite in two passes:

* First pass: to gather all the test classes and names, but without actually executing the code
    * This is used to display a hierarchical list of test suites and methods in the Eclipse JUnit view
* Second pass: to actually execute the code

Using the command line test runner only does the second pass --- it doesn't list the test names up-front.

## Existing workaround

For this first pass, apparently there is a known issue in the Eclipse JUnit test runner, which was worked-around here:  
http://android.git.kernel.org/?p=platform/sdk.git;a=commitdiff;h=c7e4658b149c04820bd8ea8da7bc2515df6a94a3

When gathering test information, since Android SDK Tools r8, a 15ms delay between each test has been introduced.  
You can reproduce this first pass with the following command line:  
adb shell am instrument -e log true -e delay_msec 15 -w org.example.testing.unit.test/android.test.InstrumentationTestRunner

The "log" and "delay_msec" flags mimic the way that Eclipse runs the tests, i.e. with a 15ms delay between tests,
with only the test information being output --- the tests themselves are not actually executed.

## Continuing problems

Adding the 15ms delay alone doesn't appear to be the solution, as this "binder" issue can still occur in Eclipse.

However, I have noted that the first pass can run fine on the command line, even with a delay_msec value of 3ms.  
But as soon as it's run from Eclipse, with its 15ms delay, it fails.  
(Eclipse 3.5.2, ADT 10.0.1, Mac OS X 10.5.8, MacBook 2GHz Core 2 Duo)
