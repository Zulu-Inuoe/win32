# win32

## Overview

win32 is a library containing a set of CFFI bindings and constant definitions for interacting with the Win32 API.
This means it's a practically non-existant layer on top of the API, and has little to no utility other than exposing the raw interface.

New functions and libraries will be added as needed, usually a whole set at a time.

## Notes:

### BOOL BOOLEAN
The `BOOL` and `BOOLEAN` types will be coerced to generalized booleans as per [:boolean](https://common-lisp.net/project/cffi/manual/html_node/Other-Types.html).

### Unicode
When encountering "ANSI" functions with "Unicode" counterparts, the latter will always be used. Bindings that accept strings all use the :utf-16 encoding (little-endian typically, but with guards in the case of big-endian).

When encoding to/from a Win32 string, make use of the `win32:+win32-string-encoding+':

``` common-lisp
(defun lisp-to-wstring (string wchar-buf wchar-count)
  (cffi:lisp-string-to-foreign
   string
   wchar-buf
   (* wchar-count (cffi:foreign-type-size 'win32:wchar))
   :encoding win32:+win32-string-encoding+))

(defun wstring-to-lisp (wchar-buf wchar-count)
  (values
   (cffi:foreign-string-to-lisp
    wchar-buf
    :count (* wchar-count (cffi:foreign-type-size 'win32:wchar))
    :encoding win32:+win32-string-encoding+)))
```

### C Types
Most of WinAPI is defined in terms of Windows' own types, with well-defined size across ABI's, such as `win32:long`, `win32:char`, etc.
Occasionally, a type will be a bare C type instead. In this case, the corresponding CFFI type will be used, such as `:int` or `:char`

## Probable Goals:
Separate into multiple source files and possibly separate packages to
have a 1:1 with the library DLLS (aka win32.user32, win32.gdi32 etc.).
