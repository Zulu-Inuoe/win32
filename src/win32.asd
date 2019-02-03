(defsystem #:win32
  :description "A cffi wrapper package for win32, including Kernel32, User32, and GDI32."
  :version "0.0.0.3"
  :author "Wilfredo Velázquez-Rodríguez <zulu.inuoe@gmail.com>"
  :license "CC0 <http://creativecommons.org/publicdomain/zero/1.0/>"
  :serial t
  :components
  ((:file "package")
   (:file "win32"))
  :depends-on
  (#:cffi
   #:defpackage-plus
   #:trivial-features))
