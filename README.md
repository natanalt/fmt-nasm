# Formatted print macros
This repository contains a macro file for NASM for formatted printing. Format
strings are analysed during assembly and have according assembly code generated
for them which writes matching output at runtime.

Currently only 16 bit code generation is supported, but 32-bit support shouldn't
be too hard to add.

## Usage
One macro is provided, called `print`:
```x86asm
print "This is a format string {bx} {es} wooo"
```

The macro also allows to print values of entire expressions evaluable by NASM:
```x86asm
; w: means that the following expression is a word value
; x: means print as hex
print "{w:x:some_label + 123}"

some_label:
```

See the [Format syntax](#Format_syntax) section for detailed description of the
formatting.

### Runtime requirements
For portability reasons, this macro doesn't provide implementations of any
print functions, so you have to write them yourself:
 * log_print_string - prints a null-terminated string, pointed to by ds:si
 * log_print_byte_* - prints value stored in al. Following variants exist:
   * log_print_byte_dec - decimal (base 10) value
   * log_print_byte_bin - binary value
   * log_print_byte_hex - hex value
   * log_print_byte_chr - single character value
 * log_print_word_* - prints value stored in ax. See above for variants
 * log_print_finish - called when a print is done. Can be used to for example
   print a newline for better logs

Number printing functions shouldn't append any prefixes or suffixes like 0x.

Format functions must preserve all registers, aside from flags.

The `log_` prefix can be customized by defining the FMT_FN_PREFIX macro before
inclusion of the macro, like:
```x86asm

%define FMT_FN_PREFIX fmt_
%include "fmt.mac"

fmt_print_string:
    ; ...
    ret
```

Example implementation for DOS is provided in file [dosexamp.asm](dosexamp.asm).

### Format syntax
 * {reg} - prints the value of a any register `reg` as a hex value, examples:
   * {ax}
   * {es}
   * {fl} prints value of the flags register, as provided by the pushf opcode
 * {reg:T} - prins value of any register `reg`, where T can be:
   * u - base 10 unsigned
   * b - base 2
   * x - base 16
   * c - single character
 * {w:T:expr} - prints value of the expression as word using specified format T
   * {w:h:0x100 * 2 + 0x10} will effectively print hex 0x210
 * {b:T:expr} - same as above, but for byte values
 * {W:expr} - works the same as {w\:x:expr}
 * {B:expr} - works the same as {b\:x:expr}

### Configuration
It is possible to configure behavior of the macro by defining a few values
before the inclusion:
 * FMT_STRING_SEG (default: .rodata) - target section for generated strings
 * FMT_FN_PREFIX (default: log_) - prefix for required print function names
 * FMT_UPDATE_DS - if defined, ds will be updated to point to the string
   segment, like `mov ds, seg FMT_STRING_SEG`

## TODO
 * Support for 32 and 64 bit output
 * Perhaps a way of analyzing all previously generated strings to avoid
   duplication of literals?

## License
tl;dr the Zero Clause BSD license (aka. do what you want and don't sue me)

This applies for all source files in this repository. See text of the license
[here](LICENSE).
