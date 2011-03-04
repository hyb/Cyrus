#!/bin/bash

cp test-forest.db forest.db

javac -Xlint:unchecked -classpath ../../../build/jungle.jar *.java || exit

java -classpath .:../../../build/jungle.jar jungle.Jungle > jungle.log 2>&1 &

