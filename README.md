# avr_qemu_unittest_demo

Demonstrate using QEMU to perform unit testing under QEMU emulator. Helpful for CI/CD setup.

## Prerequisites
1. Ubuntu Linux 16.04 and higher
2. QEMU emulator version 5.1.0 installed with AVR support **qemu-system-avr** must be in $PATH.
- how to configure, build and install: https://en.wikibooks.org/wiki/QEMU/Installing_QEMU
- to bild target desired AVR target QEMU should be conigured including the following: *../configure --target-list=avr-softmmu*
3. Target MCU: ATmega328p (Arduino UNO)
4. Optional: GCC toolchain: avr8-gnu-toolchain-3.6.2.1778-linux.any.x86_64.tar.gz

## Details
**run_under_qemu.sh** script is ready to embed to your CI/CE environment.
Usage: **run_under_qemu.sh firmware.elf**
Does the following:
- runs firmware.elf on emulated AVR core
- transmits output form AVR's UART port to console
- looks for "[  PASSED  ]" or "[  FAILED  ]" patterns to distinguish the test was successful or not
- deals with unexpected infinite loop during test procedure
- returns non-zero exit code if the test was failed or freezed for some reason

## What also is included

### Pre-built images
There are 3 pre-built images for AVR: **success.elf**, **failure.elf** and **loop.elf**.
They simulate corresponding successful, unsuccessful test execution and test execution with infinite loop.
Each test execution produces output to USART. The output is like *CMocka*, *GTest* frameworks output logs:
~~~~
[==========] Running 10 test(s).
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[  FAILED  ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[ RUN      ] test_bla_bla
[       OK ] test_bla_bla
[==========] 10 test(s) run.
[  PASSED  ] 9 test(s).
[  FAILED  ] 1 test(s).
~~~~

### main.c
It's source code for mentioned pre-built images. External preprocessor definition *SCENARIO* is used to change kind of simulated test.

### tt.sh
Script **tt.sh** intends to demonstrate using of **run_under_qemu.sh**.
It runs **run_under_qemu.sh** 3 times for mentioned images and shows simulated test logs and exit code.
