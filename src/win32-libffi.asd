(defsystem #:win32-libffi
  :description "A cffi wrapper package for win32, including Kernel32, User32, and GDI32.
This is the libffi component to win32, which includes pass-by-value functions that need libffi support."
  :version "0.0.0.3"
  :author "Wilfredo Velázquez-Rodríguez <zulu.inuoe@gmail.com>"
  :license "CC0 <http://creativecommons.org/publicdomain/zero/1.0/>"
  :serial t
  :components
  ((:file "win32-libffi"))
  :depends-on
  (#:cffi-libffi
   #:win32))
