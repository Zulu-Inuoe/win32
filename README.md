# win32

## Overview

win32 is a library containing a set of CFFI bindings and constant definitions for interacting with the Win32 API.
This means it's a practically non-existant layer on top of the API, and has little to no utility other than exposing the raw interface.

New functions and libraries will be added as needed, usually a whole set at a time.

## Notes:
### Unicode
When encountering "ANSI" functions with "Unicode" counterparts, the latter will always be used. Bindings that accept strings all use the :utf-16 encoding (little-endian typically, but with guards in the case of big-endian).

### C Types
When a WinAPI function definition utilizes bare C types, the corresponding CFFI type will be used. When using the typedef'd or #define'd types, their definition will be inspected [in this list]("http://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx"). If a suitable fixed-bit definition matches, then the appropriate cffi type will be used (:uint8, :uint16, etc).


## Probable Goals:
Separate into multiple source files and possibly separate packages to
have a 1:1 with the library DLLS (aka win32.user32, win32.gdi32 etc.).
