

# identifiers
-----------

#### ALLCAPS
These are things that are traditionally capitalized, such as `CFLAGS`,
`DEBUG`, etc.  They all still work as intended.

#### MFCAPS & MF_ALLCAPS
These are things that the user of make-forge might wish to modify,
either by inclusion on the 'make' command-line, or from within a
superior makefile.  Examples:

* `MFOUT`: the directory that make-forge sends build output to
* `MF_OPSYS`: (readonly!) resolves to a brief string that identifies
  the build's target OS.
* `MF_PROJECT_DIR`: the top directory of the project that is using
  make-forge
* `MD_HELPDOC`: a heredoc to be displayed whenever the 'help' target
  is invoked by the end user
* `MF_QUIET_BUILDS`: when defined, this squelches output that would
  normally echo to the terminal during a build.  (Mostly used by
  test-forge, but can be used by anyone that prefers quiet builds)


#### mf_function
These functions are part of the public interface exposed by make-forge


#### var, mfvar & mf_variable
These track internal state of make-forge, and should not normally be
referenced or modified by users of make-forge.


#### __mf_function
These are private implementation details of make-forge, and should not
be invoked directly by users of make-forge

#### _var
These are local variables within functions, and typically get
undef'd by the end of the function they get defined in.

