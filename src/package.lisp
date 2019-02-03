(in-package #:defpackage+-user-1)

(defpackage+ #:win32
  (:use #:cffi #:cl)
  (:shadow
   #:atom
   #:boolean
   #:byte
   #:char
   #:float)
  (:export
   #:+win32-string-encoding+))
