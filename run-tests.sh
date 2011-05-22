#!/bin/sh

# Write local.properties for the local SDK
android update project -p app -n unit-testing
android update test-project -p tests -m ../app

# Compile and install APKs, run tests
cd tests
ant clean run-tests
cd ..
