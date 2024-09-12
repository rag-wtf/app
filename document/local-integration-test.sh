#!/bin/bash

if [ -z "$1" ]; then
    sudo docker run --rm --pull always -p 8000:8000 --name surrealdb surrealdb/surrealdb:latest start memory -A --auth --user root --pass root &
    flutter drive --driver=test_driver/integration_test.dart --target integration_test/all_tests.dart -d chrome --debug
    sudo docker container stop surrealdb
else
    echo "Argument \$1: $1"
    flutter drive --driver=test_driver/integration_test.dart --target integration_test/all_tests.dart -d chrome --debug --dart-define=$1
fi

