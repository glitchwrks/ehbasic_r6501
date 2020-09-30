EhBASIC for Rockwell R6501/R6511
--------------------------------

This repository contains a version of the EhBASIC interpreter for the Rockwell R6501 and R6511 single-chip microprocessors. These processors are 6502-like, but contain some significant differences:

* Zero page is internal to the processor, and smaller than 256 bytes
* I/O devices in zero page
* Hardware stack in zero page, of limited size

### About EhBASIC

From the original source on which this work is based:

```
Enhanced BASIC is a BASIC interpreter for the 6502 family microprocessors. It
is constructed to be quick and powerful and easily ported between 6502 systems.
It requires few resources to run and includes instructions to facilitate easy
low level handling of hardware devices. It also retains most of the powerful
high level instructions from similar BASICs.
```

### Copyright and Licensing

From the original EhBASIC source on which this work is based:

```
EhBASIC is free but not copyright free. For non commercial use there is only one
restriction, any derivative work should include, in any binary image distributed,
the string "Derived from EhBASIC" and in any distribution that includes human
readable files a file that includes the above string in a human readable form
e.g. not as a comment in an HTML file.

For commercial use please contact me,  Lee Davison, at leeedavison@googlemail.com
for conditions.
```

Since Lee Davidson has since passed away, we believe that we're in the right to distribute our modifications to EhBASIC under the GNU GPL v3. Mr. Davidson's work of course retains its original license. Our first commit is the unmodified v2.22 EhBASIC source code.

Additionally, our `Makefile` comes from Jeff Tranter's port of EhBASIC to the Replica-1 and other platforms, [which can be found here](https://github.com/jefftranter/6502/tree/master/asm/ehbasic). Jeff didn't provide a license with his code, but our modifications to his `Makefile` are released under the GNU GPL v3.
