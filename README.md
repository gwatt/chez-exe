## chez-exe: ChezScheme Self-Hosting Executable

The goal of this project is to produce standalone executables that are
a complete ChezScheme system and contain a scheme program.
This works by embedding the ChezScheme bootfiles and a scheme program
into the executable.

Chez-exe embeds the ChezScheme boot files and a compiled scheme program as binary data in a C source file.
The scheme program is compiled with [`compile-whole-program`](http://cisco.github.io/ChezScheme/csug9.5/system.html#./system:s77).
As such, the scheme program must be valid [R6RS top-level program](http://www.r6rs.org/final/html/r6rs/r6rs-Z-H-4.html#node_sec_1.13)
and any imported lbiraries should be available in source form or have already been compiled
with the same version of ChezScheme and have wpo files generated for the libraries.
Any scheme files accessed with `(load)` and libraries which are not available in source form or do not have wpo files
will not be embedded and will need to be distributed with the generated program for it to work properly.

#### SUPPORTED SYSTEMS:
* Linux
* Mac OS X
* Windows

#### REQUIREMENTS

* Unix
    * gcc, clang, or compatible
    * GNU make
* Windows
    * cl.exe
    * nmake

#### BUILDING

Building this project requires a working copy of ChezScheme. Chez need not be
installed anywhere specific, even building inside the repository should work.
Once ChezScheme is ready, you can build chez-exe like so:

    scheme --script gen-config.ss [--prefix prefix] [--bindir bindir] \
        [--libdir libdir] [--bootpath bootpath] [--scheme scheme] \
        [...]
    make

*NOTE*: make is automatically invoked by the `gen-config.ss` script to automate
building of the program.

Running gen-config.ss will create two files:
config.ss and make.in on unix, or config.ss and tools.ini on Windows.
These files ease the building process when compiling and installing chez-exe.
The options for gen-config are as follows:
* `--prefix` - base directory for installing the libraries and binaries
* `--bindir` - directory for installing binaries
* `--libdir` - directory for installing libraries
* `--bootpath` - directory that contains .boot files and scheme.h
* `--scheme` - name or command line of scheme executable

On all systems, `--scheme` defaults to `scheme` and `--bootpath` has no default.
`--prefix`, `--bindir`, and `--libdir` have different defaults on Unix systems and Windows:

* Unix
    * `--prefix` - `/usr/local`
    * `--bindir` - `$prefix/bin`
    * `--libdir` - `$prefix/lib`
* Windows
    * `--prefix` - `%LOCALAPPDATA%\chez-exe`
    * `--bindir` - `$prefix`
    * `--libdir` - `$prefix`

Any extra arguments to `gen-config.ss` are stored and always passed to the C compiler when running `compile-chez-program`.

NOTE: When building on Windows, make sure to use the matching bitsize of the
MSVC compiler and Chez Scheme. If you see errors similar to:

    unresolved external symbol _Sscheme_init
    unresolved external symbol _Sregister_boot_file
    unresolved external symbol _Sbuild_heap
    unresolved external symbol _Sscheme_program

double check that you're running "make" from the correct "Native Tools Command Prompt".

##### Artifacts

There are three important files built under Unix systems: `compile-chez-program`, `full-chez.a`, and `petite-chez.a`.
`compile-chez-program` is the main executable, `full-chez.a` is a static library containing the full ChezScheme system,
and `petite-chez.a` is a static library containing only the Petite ChezScheme system (no compiler/ffi).

#### RUNNING:

    compile-chez-program [--libdirs ...] [--libexts ...] [--srcdirs ...]
        [--chez-lib-dir /path/to/chezlib] [--optimize-level 0|1|2|3]
        [--full-chez]
        program-file.ss [...]

compile-chez-program understands `CHEZSCHEMELIBDIRS` and `CHEZSCHEMELIBEXTS` in
the same way that the ChezScheme executables understand them.
compile-chez-program also recognizes the following command line arguments:

* `--libdirs`
* `--libexts`
* `--srcdirs`
* `--optimize-level`
* `--chez-lib-dir`
* `--full-chez`

`--libdirs`, `--libexts`, and `--optimize-level` all behave exactly as for ChezScheme.
`--srcdirs` alters the [`source-directories`](http://cisco.github.io/ChezScheme/csug9.5/system.html#./system:s102)
parameter in exactly the same way that `--libdirs` and `--libexts` alter their respective parameters.

`--chez-lib-dir` controls where `compile-chez-program` looks for the static libraries to link against when building a program.
The default location is whatever was given as the `--libdir` argument for `gen-config.ss`

`--full-chez` will cause `compile-chez-program` to generate a program that links against `full-chez.a`.
This means the generated program will have access to the compiler and FFI and be able to compile new code.
The default is to link against `petite-chez.a` which will not include the compiler or ffi.
NOTE: Your code will still be compiled and the FFI will be available when building your program aginst `petite-chez.a`.

`compile-chez-program` assumes that the first unknown argument is the filename to compile.
Any further arguments are passed to the C compiler.

For example:

    compile-chez-program foo.ss -lGL -lGLU -lGLEW

will also link against the OpenGL libraries, allowing the scheme source to
access the shared libraries by calling `(load-shared-object #f)` instead of
loading each object file individually.
