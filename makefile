################################################################################
#
# Where you want the release Android apk to be copied
#
RELEASE_TARGET=../net/netmash.net/NetMash.apk
#
################################################################################

noargs: androidemu runstaticserver logboth

twoservers: androidemu runtwo logthree

mesh: androidemu logcat

fjord: kill runcur whappen

demo: editstaticdb androidemu runquickserver logboth editdynamicfile

quickdyn: editquickdb androidemu runquickserver logboth editdynamicfile

local: androidemu runlocalserver logboth editlocaldbanddynamicfile

# -------------------------------------------------------------------

editstaticdb:
	vi -o -N src/server/vm1/static.db

editquickdb:
	vi -o -N src/server/vm1/quick.db

editlocaldb:
	vi -o -N src/server/vm1/local.db

editdynamicfile:
	vi -o -N src/server/vm1/functional-hyper.json src/server/vm1/functional-hyperule.json

editlocaldbanddynamicfile:
	vi -o -N src/server/vm1/local.db src/server/vm1/guitest.json

# -------------------------------------------------------------------

androidemu: clean init setappemuconfig setdebugmapkey
	ant debug
	adb uninstall android.gui
	adb install bin/NetMash-debug.apk

androidemurel: clean init setappemuconfig setreleasemapkey
	ant release
	adb uninstall android.gui
	adb install bin/NetMash-release.apk

androidremoterel: clean init setappremoteconfig setreleasemapkey
	ant release
	cp bin/NetMash-release.apk $(RELEASE_TARGET)

reinstall:
	adb uninstall android.gui
	adb install bin/NetMash-release.apk

# -------------------------------------------------------------------

runstaticserver: kill clean setvmemuconfig usestaticdb run1

runquickserver: kill clean setvmemuconfig usequickdb run1

runlocalserver: kill clean setvmemuconfig uselocaldb run1

runremoteserver: kill clean setvmremoteconfig usestaticdb run1 logout1

runone: kill clean curconfig setvmtestconfig usetestdb run1 logout1

runtwo: kill clean curconfig setvmemuconfig usetestdb run1n2

runcur: kill clean curconfig setvmtestconfig usetestdb run1n2

runall: kill clean allconfig setvmtestconfig usetestdb run1n2

runon1:
	( cd src/server/vm1 ; java -classpath .:../../../build/netmash.jar netmash.NetMash > netmash.log 2>&1 & )

runon2:
	( cd src/server/vm2 ; java -classpath .:../../../build/netmash.jar netmash.NetMash > netmash.log 2>&1 & )

runtests: runjson runuid

runjson: jar
	java -ea -classpath ./build/netmash.jar netmash.lib.TestJSON

runuid: jar
	java -ea -classpath ./build/netmash.jar netmash.forest.UID

run1: jar
	(cd src/server/vm1; ./run.sh)

run2: jar
	(cd src/server/vm2; ./run.sh)

run1n2: run1 run2

# -------------------------------------------------------------------

usestaticdb:
	cp src/server/vm1/static.db src/server/vm1/netmash.db

usequickdb:
	cp src/server/vm1/quick.db src/server/vm1/netmash.db

uselocaldb:
	cp src/server/vm1/local.db src/server/vm1/netmash.db

usetestdb:
	cp src/server/vm1/test.db src/server/vm1/netmash.db
	cp src/server/vm2/test.db src/server/vm2/netmash.db

setreleasemapkey:
	sed -i"" -e "s:03Hoq1TEN3zbZ9y69dEoFX0Tc20g14mWm-hImbQ:03Hoq1TEN3zbEGUSHYbrBqYgXhph-qRQ7g8s3UA:" src/android/gui/NetMash.java

setdebugmapkey:
	sed -i"" -e "s:03Hoq1TEN3zbEGUSHYbrBqYgXhph-qRQ7g8s3UA:03Hoq1TEN3zbZ9y69dEoFX0Tc20g14mWm-hImbQ:" src/android/gui/NetMash.java

setappemuconfig:
	sed -i"" -e "s:netmash.net:10.0.2.2:" res/raw/netmashconfig.json
	sed -i"" -e "s:netmash.net:10.0.2.2:" res/raw/topdb.json

setappremoteconfig:
	sed -i"" -e "s:10.0.2.2:netmash.net:" res/raw/netmashconfig.json
	sed -i"" -e "s:10.0.2.2:netmash.net:" res/raw/topdb.json

setvmemuconfig:
	sed -i"" -e "s:localhost:10.0.2.2:" src/server/vm1/netmashconfig.json
	sed -i"" -e "s:localhost:10.0.2.2:" src/server/vm2/netmashconfig.json

setvmtestconfig:
	sed -i"" -e "s:10.0.2.2:localhost:" src/server/vm1/netmashconfig.json
	sed -i"" -e "s:10.0.2.2:localhost:" src/server/vm2/netmashconfig.json

setvmremoteconfig:
	sed -i"" -e "s:10.0.2.2:netmash.net:" src/server/vm1/netmashconfig.json
	sed -i"" -e "s:10.0.2.2:netmash.net:" src/server/vm2/netmashconfig.json

curconfig:
	cp src/server/vm2/curconfig.json src/server/vm2/netmashconfig.json

allconfig:
	cp src/server/vm2/allconfig.json src/server/vm2/netmashconfig.json

setup:
	vim -o -N res/raw/netmashconfig.json res/raw/topdb.json src/server/vm1/netmashconfig.json src/server/vm1/test.db src/server/vm2/curconfig.json src/server/vm2/allconfig.json src/server/vm2/test.db

whappen:
	vim -o -N src/server/vm2/netmash.log src/server/vm1/netmash.log src/server/vm1/netmash.db src/server/vm2/netmash.db

logboth:
	xterm -geometry 97x50+0+80 -e make logcat &
	xterm -geometry 97x20+0+80 -e make logout1 &

logthree:
	xterm -geometry 97x50+0+80 -e make logcat &
	xterm -geometry 97x20+0+80 -e make logout1 &
	xterm -geometry 97x20+0+80 -e make logout2 &

logcat:
	adb logcat | tee ,logcat | egrep -vi "locapi|\<rpc\>"

logout1:
	tail -9999f src/server/vm1/netmash.log

logout2:
	tail -9999f src/server/vm2/netmash.log

# -------------------------------------------------------------------

classes: \
./build/classes/netmash/NetMash.class \
./build/classes/netmash/lib/JSON.class \
./build/classes/netmash/lib/TestJSON.class \
./build/classes/netmash/forest/WebObject.class \
./build/classes/netmash/forest/FunctionalObserver.class \
./build/classes/netmash/forest/Fjord.class \
./build/classes/netmash/forest/Persistence.class \
./build/classes/server/types/UserHome.class \
./build/classes/server/types/Event.class \
./build/classes/server/types/Twitter.class \
./build/classes/server/types/DynamicFile.class \
./build/classes/server/types/Editable.class \


LIBOPTIONS= -Xlint:unchecked -classpath ./src -d ./build/classes

./build/classes/%.class: ./src/%.java
	javac $(LIBOPTIONS) $<

./build/classes:
	mkdir -p ./build/classes

jar: ./build/classes classes
	( cd ./build/classes; jar cfm ../netmash.jar ../META-INF/MANIFEST.MF . )

# -------------------------------------------------------------------

init:   proguard.cfg local.properties

proguard.cfg:
	android update project -p .

local.properties:
	android update project -p .

kill:
	@-pkill -f 'java -classpath'

clean:
	rm -rf ./build/classes/netmash
	rm -rf ./build/classes/server
	rm -f  ./src/server/vm?/*.class
	rm -rf bin/classes bin/classes.dex
	rm -f  bin/NetMash.ap_ bin/NetMash*un*ed.apk
	rm -f  gen/android/gui/R.java
	rm -f  ,*

veryclean: clean setappemuconfig setvmemuconfig setdebugmapkey
	rm -f  src/server/vm[12]/netmash.log
	rm -f  src/server/vm[12]/netmash.db
	rm -f  src/server/vm2/netmashconfig.json
	rm -rf bin gen

# -------------------------------------------------------------------


