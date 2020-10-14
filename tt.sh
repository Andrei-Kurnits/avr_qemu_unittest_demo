#!/bin/bash

export CDEFS=-DSCENARIO=SUCCESS
make clean 1> /dev/null && make all 1> /dev/null
mv main.elf success.elf

export CDEFS=-DSCENARIO=FAILURE
make clean 1> /dev/null && make all 1> /dev/null
mv main.elf failure.elf

export CDEFS=-DSCENARIO=INFINITE_LOOP
make clean 1> /dev/null && make all 1> /dev/null
mv main.elf loop.elf

make clean


echo "Simulate all test are successful"
./run_under_qemu.sh success.elf
printf "Return code: %d\n\n" $?


echo "Simulate one test failed"
./run_under_qemu.sh failure.elf
printf "Return code: %d\n\n" $?


echo "Simulate unexpected infinite loop on a test"
./run_under_qemu.sh loop.elf
printf "Return code: %d\n" $?

