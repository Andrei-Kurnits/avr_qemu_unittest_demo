#!/bin/bash


# Check argument - a firmware file
args=("$@")
if test "$#" -ne 1
then
	echo "Usage: <sript.sh> <firmwarefile.elf>"
	exit -1
fi
FIRMWARE=${args[0]}
if ! test -f "$FIRMWARE";
then
	echo "Firmware file '$FIRMWARE' doesn't exists."
	exit -1
fi


# Pipes
PIPE_BEFORE_TEE="/tmp/avr_unit_test_simulation_pipe1"
PIPE_AFTER_TEE="/tmp/avr_unit_test_simulation_pipe2"


# Create a pipe QEMU which will be connected to emulated MCU serial port
mkfifo $PIPE_BEFORE_TEE &> /dev/null
mkfifo $PIPE_AFTER_TEE &> /dev/null


# Run QEMU itself and store its PID
# Redirect of unit testing framework output to the pipe
qemu-system-avr -machine uno -bios $FIRMWARE -serial pipe:$PIPE_BEFORE_TEE -nographic 1> /dev/null &
QEMU=$!


# Show unit tests framework output and copy it to 2nd pipe
cat $PIPE_BEFORE_TEE | tee $PIPE_AFTER_TEE &


# Run timeout process which kills QEMU if it run into infinite loop and isn't sending any messages
{
	sleep 5s #timeout
	kill $QEMU &> /dev/null
	wait $QEMU &> /dev/null
	kill $$ &> /dev/null
	wait $S &> /dev/null
	rm -f /$PIPE_BEFORE_TEE &> /dev/null
	rm -f /$PIPE_AFTER_TEE &> /dev/null
} &
TIMEOUT=$!


# Grep for 1sh "[  PASSED  ]" match. It should be present at the end of any test run.
# Grab all lines before the match.
WHOLE_LOG=$(grep -B 1000000 -m 1 "\[  PASSED  \]" $PIPE_AFTER_TEE)


# Look for "[  FAILED  ]" pattern in logs
if [[ $WHOLE_LOG == *"[  FAILED  ]"* ]]
then
# One or more test failed
	RESULT=13
else
# All tests were successful
	RESULT=0
fi


# Kill QEMU and Timeout child processes
kill $TIMEOUT &> /dev/null
wait $TIMEOUT &> /dev/null
kill $QEMU &> /dev/null
wait $QEMU &> /dev/null


# Destroy the pipes
rm -f $PIPE_BEFORE_TEE &> /dev/null
rm -f $PIPE_AFTER_TEE &> /dev/null


exit $RESULT
