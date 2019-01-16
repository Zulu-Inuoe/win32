;;;win32 - CFFI bindings to Win32 API
;;;Written in 2013 by Wilfredo Velázquez-Rodríguez <zulu.inuoe@gmail.com>
;;;
;;;To the extent possible under law, the author(s) have dedicated all copyright
;;;and related and neighboring rights to this software to the public domain
;;;worldwide. This software is distributed without any warranty.
;;;You should have received a copy of the CC0 Public Domain Dedication along
;;;with this software. If not, see
;;;<http://creativecommons.org/publicdomain/zero/1.0/>.

(in-package #:win32)

(define-foreign-library api-ms-win-core-version-l1-1-0
  (:win32 "Api-ms-win-core-version-l1-1-0.dll"))

(define-foreign-library api-ms-win-core-localization-l1-2-1
  (:win32 "Api-ms-win-core-localization-l1-2-1.dll"))

(define-foreign-library kernel32
  (:win32 "Kernel32.dll"))

(define-foreign-library user32
  (:win32 "User32.dll"))

(define-foreign-library gdi32
  (:win32 "Gdi32.dll"))

(define-foreign-library opengl32
  (:win32 "Opengl32.dll"))

(define-foreign-library advapi32
  (:win32 "Advapi32.dll"))

(define-foreign-library setupapi
  (:win32 "setupapi.dll"))

(use-foreign-library api-ms-win-core-version-l1-1-0)
(use-foreign-library api-ms-win-core-localization-l1-2-1)
(use-foreign-library user32)
(use-foreign-library kernel32)
(use-foreign-library gdi32)
(use-foreign-library opengl32)
(use-foreign-library advapi32)
(use-foreign-library setupapi)

(defconstant +win32-string-encoding+
  #+little-endian :utf-16le
  #+big-endian :utf-16be
  "Not a win32 'constant' per-se, but useful to expose for usage with FOREIGN-STRING-TO-LISP and friends.")

(defconstant +pointer-bit-size+ (* (cffi:foreign-type-size :pointer) 8))

(defmacro defwin32constant (name value &optional doc)
  "Wrapper around `defconstant' which exports the constant."
  `(progn
     (eval-when (:compile-toplevel :load-toplevel :execute)
       (defparameter ,name ,value ,doc))
     (export ',name)
     ',name))

(defmacro defwin32enum (name &body enum-list)
  "Wrapper around `defcenum' which exports the enum type and each enum name within."
  `(progn
     (defcenum ,name
       ,@enum-list)
     ;;Export enum name
     (export ',name)
     ;;Export each enum value
     (export
      ',(mapcar
         (lambda (spec)
           (if (cl:atom spec)
               spec
               (car spec)))
         ;;Skip docstring if present
         (if (typep (car enum-list) 'string)
             (cdr enum-list)
             enum-list)))
     ;;Return name of enum
     ',name))

(defmacro defwin32type (name base-type &optional documentation)
  `(progn
     (defctype ,name ,base-type ,documentation)
     ;;Export name
     (export ',name)
     ;;Return name of type
     ',name))

(defmacro defwin32struct (name &body fields
                          &aux
                            (tag-name (intern (concatenate 'string "TAG-" (symbol-name name)) :win32)))
  "Wrapper around `defcstruct' which also defines a type for the struct, and exports all of its fields."
  `(progn
     (defcstruct ,tag-name
       ,@fields)
     ;;typedef it
     (defctype ,name (:struct ,tag-name))
     ;;Export name
     (export ',name)
     ;;Export each field
     (export ',(mapcar #'car (if (typep (car fields) 'string) (cdr fields) fields)))
     ;;Return the name of struct
     ',name))

(defmacro defwin32union (name &body fields)
  "Wrapper around `defcunion' which exports the union and all of its fields."
  `(progn
     (defcunion ,name
       ,@fields)
     ;;typedef it
     (defctype ,name (:union ,name))
     ;;Export name
     (export ',name)
     ;;Export each member
     (export ',(mapcar #'car (if (typep (car fields) 'string) (cdr fields) fields)))
     ;;Return name of union
     ',name))

(defmacro defwin32fun ((c-name lisp-name library) return-type &body args)
  "Wrapper around `defcfun' that sets the library and convention to the correct values, and performs an EXPORT of the lisp name."
  (assert (typep c-name 'string))
  (assert (and (symbolp lisp-name)
               (not (keywordp lisp-name))))
  `(progn
     (defcfun (,c-name ,lisp-name :library ,library :convention :stdcall) ,return-type
       ,@args)
     ;;Export the lisp name of the function
     (export ',lisp-name)
     ;;Return the lisp-name
     ',lisp-name))

(defmacro defwin32-lispfun (name lambda-list &body body)
  "Wrapper around `defun' which additionally exports the function name.
Meant to be used around win32 C preprocessor macros which have to be implemented as lisp functions."
  (assert (and (symbolp name)
               (not (keywordp name))))
  `(progn
     (defun ,name ,lambda-list
       ,@body)

     ;;Export it
     (export ',name)

     ;;Return the name
     ',name))

(defwin32type char :int8)
(defwin32type uchar :uchar)
(defwin32type wchar :int16)

(defwin32type int :int)
(defwin32type int-ptr #+x86 :int32 #+x86-64 :int64)
(defwin32type int8 :int8)
(defwin32type int16 :int16)
(defwin32type int32 :int32)
(defwin32type int64 :int64)

(defwin32type uint :uint32)
(defwin32type uint-ptr #+x86 :uint32 #+x86-64 :uint64)
(defwin32type uint8 :uint8)
(defwin32type uint16 :uint16)
(defwin32type uint32 :uint32)
(defwin32type uint64 :uint64)

(defwin32type long :long)
(defwin32type longlong :int64)
(defwin32type long-ptr #+x86 :int32 #+x86-64 :int64)
(defwin32type long32 :int32)
(defwin32type long64 :int64)

(defwin32type ulong :uint32)
(defwin32type ulonglong :uint64)
(defwin32type ulong-ptr #+x86 :uint32 #+x86-64 :uint64)
(defwin32type ulong32 :uint32)
(defwin32type ulong64 :uint64)

(defwin32type short :short)
(defwin32type ushort :ushort)

(defwin32type byte :uint8)
(defwin32type word :uint16)
(defwin32type dword :uint32)
(defwin32type dwordlong :uint64)
(defwin32type dword-ptr ulong-ptr)
(defwin32type dword32 :uint32)
(defwin32type dword64 :uint64)
(defwin32type qword :uint64)

(defwin32type bool :int)
(defwin32type boolean byte)

(defwin32type tbyte wchar)
(defwin32type tchar wchar)

(defwin32type float :float)

(defwin32type size-t #+x86 :uint32 #+x86-64 :uint64)
(defwin32type ssize-t #+x86 :int32 #+x86-64 :int64)

(defwin32type lpcstr (:string :encoding :ascii))
(defwin32type lpcwstr (:string :encoding #.+win32-string-encoding+))
(defwin32type lpstr (:string :encoding :ascii))
(defwin32type lpwstr (:string :encoding #.+win32-string-encoding+))
(defwin32type pcstr (:string :encoding :ascii))
(defwin32type pcwstr (:string :encoding #.+win32-string-encoding+))
(defwin32type pstr (:string :encoding :ascii))
(defwin32type pwstr (:string :encoding #.+win32-string-encoding+))

(defwin32type handle :pointer)

(defwin32type atom :uint16)
(defwin32type half-ptr #+x86 :int #+x86-64 :short)
(defwin32type uhalf-ptr #+x86 :uint #+x86-64 :ushort)
(defwin32type colorref :uint32)
(defwin32type haccel handle)
(defwin32type hbitmap handle)
(defwin32type hbrush handle)
(defwin32type hcolorspace handle)
(defwin32type hconv handle)
(defwin32type hconvlist handle)
(defwin32type hcursor handle)
(defwin32type hdc handle)
(defwin32type hddedata handle)
(defwin32type hdesk handle)
(defwin32type hdrop handle)
(defwin32type hdwp handle)
(defwin32type henhmetafile handle)
(defwin32type hfile :int)
(defwin32type hfont handle)
(defwin32type hgdiobj handle)
(defwin32type hglobal handle)
(defwin32type hhook handle)
(defwin32type hicon handle)
(defwin32type hinstance handle)
(defwin32type hkey handle)
(defwin32type hkl handle)
(defwin32type hlocal handle)
(defwin32type hmenu handle)
(defwin32type hmetafile handle)
(defwin32type hmodule hinstance)
(defwin32type hmonitor handle)
(defwin32type hpalette handle)
(defwin32type hpen handle)
(defwin32type hresult long)
(defwin32type hrgn handle)
(defwin32type hrsrc handle)
(defwin32type hsz handle)
(defwin32type hwinsta handle)
(defwin32type hwnd handle)
(defwin32type langid word)
(defwin32type lcid dword)
(defwin32type lgrpid dword)
(defwin32type lparam long-ptr)
(defwin32type lpctstr (:string :encoding #.+win32-string-encoding+))
(defwin32type lptstr (:string :encoding #.+win32-string-encoding+))
(defwin32type lresult long-ptr)
(defwin32type pctstr (:string :encoding #.+win32-string-encoding+))
(defwin32type ptstr (:string :encoding #.+win32-string-encoding+))
(defwin32type sc-handle handle)
(defwin32type sc-lock :pointer)
(defwin32type service-status-handle handle)
(defwin32type usn longlong)
(defwin32type wndproc :pointer)
(defwin32type wparam uint-ptr)

(defwin32type hdevinfo :pointer)
(defwin32type access-mask dword)
(defwin32type regsam ulong)
(defwin32type hwineventhook handle)
(defwin32type hglrc handle)

(defwin32type access-mask dword)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %to-int32 (value)
    "Makes it easier to declare certain high values which in C are int32, in hex.
  For example, the constant +cw-usedefault+ must be used in int32 contexts, but is declared
  to be 0x80000000, which when interpreted by lisp is a high positive number  and does not
  have the same binary memory representation as the C interpreted negative value."
    (cond
      ((> value #xFFFFFFFF)
       (error "The value ~A cannot be represented as an int32 as its value does not fit into 32-bits." value))
      ((> value #x7FFFFFFF)
       (1- (-  value #xFFFFFFFF)))
      ((>= value 0)
       value)
      (t
       (error "The value ~A cannot be converted at this time, as negatives are not supported." value))))

  (defun %as-ptr (value)
    (cffi:make-pointer (ldb (cl:byte #.+pointer-bit-size+ 0) value)))

  (defun %as-dword (value)
    (ldb (cl:byte 32 0) value)))

;; Local Memory Flags
(defwin32constant +lmem-fixed+          #x0000)
(defwin32constant +lmem-moveable+       #x0002)
(defwin32constant +lmem-nocompact+      #x0010)
(defwin32constant +lmem-nodiscard+      #x0020)
(defwin32constant +lmem-zeroinit+       #x0040)
(defwin32constant +lmem-modify+         #x0080)
(defwin32constant +lmem-discardable+    #x0F00)
(defwin32constant +lmem-valid-flags+    #x0F72)
(defwin32constant +lmem-invalid-handle+ #x8000)

(defwin32constant +lhnd+                (logior +lmem-moveable+ +lmem-zeroinit+))
(defwin32constant +lptr+                (logior +lmem-fixed+  +lmem-zeroinit+))

(defwin32constant +nonzerolhnd+         +lmem-moveable+)
(defwin32constant +nonzerolptr+         +lmem-fixed+)

;; Flags returned by LocalFlags (in addition to LMEM_DISCARDABLE)
(defwin32constant +lmem-discarded+      #x4000)
(defwin32constant +lmem-lockcount+      #x00FF)

;;CreateFile Creation Disposition
(defwin32constant +create-new+        1)
(defwin32constant +create-always+     2)
(defwin32constant +open-existing+     3)
(defwin32constant +open-always+       4)
(defwin32constant +truncate-existing+ 5)

;;Pixel types
(defwin32constant +pfd-type-rgba+        0)
(defwin32constant +pfd-type-colorindex+  1)

;;Layer types
(defwin32constant +pfd-main-plane+       0)
(defwin32constant +pfd-overlay-plane+    1)
(defwin32constant +pfd-underlay-plane+   -1)

;;Flags
(defwin32constant +pfd-doublebuffer+            #x00000001)
(defwin32constant +pfd-stereo+                  #x00000002)
(defwin32constant +pfd-draw-to-window+          #x00000004)
(defwin32constant +pfd-draw-to-bitmap+          #x00000008)
(defwin32constant +pfd-support-gdi+             #x00000010)
(defwin32constant +pfd-support-opengl+          #x00000020)
(defwin32constant +pfd-generic-format+          #x00000040)
(defwin32constant +pfd-need-palette+            #x00000080)
(defwin32constant +pfd-need-system-palette+     #x00000100)
(defwin32constant +pfd-swap-exchange+           #x00000200)
(defwin32constant +pfd-swap-copy+               #x00000400)
(defwin32constant +pfd-swap-layer-buffers+      #x00000800)
(defwin32constant +pfd-generic-accelerated+     #x00001000)
(defwin32constant +pfd-support-directdraw+      #x00002000)
(defwin32constant +pfd-direct3d-accelerated+    #x00004000)
(defwin32constant +pfd-support-composition+     #x00008000)
(defwin32constant +pfd-depth-dontcare+          #x20000000)
(defwin32constant +pfd-doublebuffer-dontcare+   #x40000000)
(defwin32constant +pfd-stereo-dontcare+         #x80000000)

;;Window styles
(defwin32constant +ws-overlapped+     #x00000000)
(defwin32constant +ws-popup+          #x80000000)
(defwin32constant +ws-child+          #x40000000)
(defwin32constant +ws-visible+        #x10000000)
(defwin32constant +ws-caption+        #x00C00000)
(defwin32constant +ws-border+         #x00800000)
(defwin32constant +ws-tabstop+        #x00010000)
(defwin32constant +ws-maximizebox+    #x00010000)
(defwin32constant +ws-minimizebox+    #x00020000)
(defwin32constant +ws-thickframe+     #x00040000)
(defwin32constant +ws-sysmenu+        #x00080000)

(defwin32constant +ws-overlappedwindow+ (logior +ws-overlapped+ +ws-caption+ +ws-sysmenu+ +ws-thickframe+ +ws-minimizebox+ +ws-maximizebox+))

;;Window ex styles
(defwin32constant +ws-ex-left+                 #x00000000)
(defwin32constant +ws-ex-ltrreading+           #x00000000)
(defwin32constant +ws-ex-rightscrollbar+       #x00000000)
(defwin32constant +ws-ex-dlgmodalframe+        #x00000001)
(defwin32constant +ws-ex-noparentnotify+       #x00000004)
(defwin32constant +ws-ex-topmost+              #x00000008)
(defwin32constant +ws-ex-acceptfiles+          #x00000010)
(defwin32constant +ws-ex-transparent+          #x00000020)
(defwin32constant +ws-ex-mdichild+             #x00000040)
(defwin32constant +ws-ex-toolwindow+           #x00000080)
(defwin32constant +ws-ex-windowedge+           #x00000100)
(defwin32constant +ws-ex-clientedge+           #x00000200)
(defwin32constant +ws-ex-contexthelp+          #x00000400)
(defwin32constant +ws-ex-right+                #x00001000)
(defwin32constant +ws-ex-rtlreading+           #x00002000)
(defwin32constant +ws-ex-leftscrollbar+        #x00004000)
(defwin32constant +ws-ex-controlparent+        #x00010000)
(defwin32constant +ws-ex-staticedge+           #x00020000)
(defwin32constant +ws-ex-appwindow+            #x00040000)
(defwin32constant +ws-ex-noinheritlayout+      #x00100000)
(defwin32constant +ws-ex-noredirectionbitmap+  #x00200000)
(defwin32constant +ws-ex-layoutrtl+            #x00400000)
(defwin32constant +ws-ex-composited+           #x02000000)
(defwin32constant +ws-ex-noactivate+           #x08000000)

(defwin32constant +ws-ex-overlapped-window+    (logior
                                                +ws-ex-windowedge+
                                                +ws-ex-clientedge+))
(defwin32constant +ws-ex-palettewindow+        (logior
                                                +ws-ex-windowedge+
                                                +ws-ex-toolwindow+
                                                +ws-ex-topmost+))

;;Edit control types
(defwin32constant +es-left+ #x0000)
(defwin32constant +es-center+ #x0001)
(defwin32constant +es-right+ #x0002)

(defwin32constant +wm-null+                     #x0000)
(defwin32constant +wm-create+                   #x0001)
(defwin32constant +wm-destroy+                  #x0002)
(defwin32constant +wm-move+                     #x0003)
(defwin32constant +wm-size+                     #x0005)
(defwin32constant +wm-activate+                 #x0006)
(defwin32constant +wm-setfocus+                 #x0007)
(defwin32constant +wm-killfocus+                #x0008)
(defwin32constant +wm-enable+                   #x000A)
(defwin32constant +wm-setredraw+                #x000B)
(defwin32constant +wm-settext+                  #x000C)
(defwin32constant +wm-gettext+                  #x000D)
(defwin32constant +wm-gettextlength+            #x000E)
(defwin32constant +wm-paint+                    #x000F)
(defwin32constant +wm-close+                    #x0010)
(defwin32constant +wm-queryendsession+          #x0011)
(defwin32constant +wm-quit+                     #x0012)
(defwin32constant +wm-queryopen+                #x0013)
(defwin32constant +wm-erasebkgnd+               #x0014)
(defwin32constant +wm-syscolorchange+           #x0015)
(defwin32constant +wm-endsession+               #x0016)
(defwin32constant +wm-systemerror+              #x0017)
(defwin32constant +wm-showwindow+               #x0018)
(defwin32constant +wm-ctlcolor+                 #x0019)
(defwin32constant +wm-wininichange+             #x001A)
(defwin32constant +wm-settingchange+            #x001A)
(defwin32constant +wm-devmodechange+            #x001B)
(defwin32constant +wm-activateapp+              #x001C)
(defwin32constant +wm-fontchange+               #x001D)
(defwin32constant +wm-timechange+               #x001E)
(defwin32constant +wm-cancelmode+               #x001F)
(defwin32constant +wm-setcursor+                #x0020)
(defwin32constant +wm-mouseactivate+            #x0021)
(defwin32constant +wm-childactivate+            #x0022)
(defwin32constant +wm-queuesync+                #x0023)
(defwin32constant +wm-getminmaxinfo+            #x0024)
(defwin32constant +wm-painticon+                #x0026)
(defwin32constant +wm-iconerasebkgnd+           #x0027)
(defwin32constant +wm-nextdlgctl+               #x0028)
(defwin32constant +wm-spoolerstatus+            #x002A)
(defwin32constant +wm-drawitem+                 #x002B)
(defwin32constant +wm-measureitem+              #x002C)
(defwin32constant +wm-deleteitem+               #x002D)
(defwin32constant +wm-vkeytoitem+               #x002E)
(defwin32constant +wm-chartoitem+               #x002F)
(defwin32constant +wm-setfont+                  #x0030)
(defwin32constant +wm-getfont+                  #x0031)
(defwin32constant +wm-sethotkey+                #x0032)
(defwin32constant +wm-gethotkey+                #x0033)
(defwin32constant +wm-querydragicon+            #x0037)
(defwin32constant +wm-compareitem+              #x0039)
(defwin32constant +wm-compacting+               #x0041)
(defwin32constant +wm-windowposchanging+        #x0046)
(defwin32constant +wm-windowposchanged+         #x0047)
(defwin32constant +wm-power+                    #x0048)
(defwin32constant +wm-copydata+                 #x004A)
(defwin32constant +wm-canceljournal+            #x004B)
(defwin32constant +wm-notify+                   #x004E)
(defwin32constant +wm-inputlangchangerequest+   #x0050)
(defwin32constant +wm-inputlangchange+          #x0051)
(defwin32constant +wm-tcard+                    #x0052)
(defwin32constant +wm-help+                     #x0053)
(defwin32constant +wm-userchanged+              #x0054)
(defwin32constant +wm-notifyformat+             #x0055)
(defwin32constant +wm-contextmenu+              #x007B)
(defwin32constant +wm-stylechanging+            #x007C)
(defwin32constant +wm-stylechanged+             #x007D)
(defwin32constant +wm-displaychange+            #x007E)
(defwin32constant +wm-geticon+                  #x007F)
(defwin32constant +wm-seticon+                  #x0080)
(defwin32constant +wm-nccreate+                 #x0081)
(defwin32constant +wm-ncdestroy+                #x0082)
(defwin32constant +wm-nccalcsize+               #x0083)
(defwin32constant +wm-nchittest+                #x0084)
(defwin32constant +wm-ncpaint+                  #x0085)
(defwin32constant +wm-ncactivate+               #x0086)
(defwin32constant +wm-getdlgcode+               #x0087)
(defwin32constant +wm-syncpaint+                #x0088)
(defwin32constant +wm-ncmousemove+              #x00A0)
(defwin32constant +wm-nclbuttondown+            #x00A1)
(defwin32constant +wm-nclbuttonup+              #x00A2)
(defwin32constant +wm-nclbuttondblclk+          #x00A3)
(defwin32constant +wm-ncrbuttondown+            #x00A4)
(defwin32constant +wm-ncrbuttonup+              #x00A5)
(defwin32constant +wm-ncrbuttondblclk+          #x00A6)
(defwin32constant +wm-ncmbuttondown+            #x00A7)
(defwin32constant +wm-ncmbuttonup+              #x00A8)
(defwin32constant +wm-ncmbuttondblclk+          #x00A9)
(defwin32constant +wm-keyfirst+                 #x0100)
(defwin32constant +wm-keydown+                  #x0100)
(defwin32constant +wm-keyup+                    #x0101)
(defwin32constant +wm-char+                     #x0102)
(defwin32constant +wm-deadchar+                 #x0103)
(defwin32constant +wm-syskeydown+               #x0104)
(defwin32constant +wm-syskeyup+                 #x0105)
(defwin32constant +wm-syschar+                  #x0106)
(defwin32constant +wm-sysdeadchar+              #x0107)
(defwin32constant +wm-keylast+                  #x0108)
(defwin32constant +wm-ime_startcomposition+     #x010D)
(defwin32constant +wm-ime_endcomposition+       #x010E)
(defwin32constant +wm-ime_composition+          #x010F)
(defwin32constant +wm-ime_keylast+              #x010F)
(defwin32constant +wm-initdialog+               #x0110)
(defwin32constant +wm-command+                  #x0111)
(defwin32constant +wm-syscommand+               #x0112)
(defwin32constant +wm-timer+                    #x0113)
(defwin32constant +wm-hscroll+                  #x0114)
(defwin32constant +wm-vscroll+                  #x0115)
(defwin32constant +wm-initmenu+                 #x0116)
(defwin32constant +wm-initmenupopup+            #x0117)
(defwin32constant +wm-menuselect+               #x011F)
(defwin32constant +wm-menuchar+                 #x0120)
(defwin32constant +wm-enteridle+                #x0121)
(defwin32constant +wm-ctlcolormsgbox+           #x0132)
(defwin32constant +wm-ctlcoloredit+             #x0133)
(defwin32constant +wm-ctlcolorlistbox+          #x0134)
(defwin32constant +wm-ctlcolorbtn+              #x0135)
(defwin32constant +wm-ctlcolordlg+              #x0136)
(defwin32constant +wm-ctlcolorscrollbar+        #x0137)
(defwin32constant +wm-ctlcolorstatic+           #x0138)
(defwin32constant +wm-mousefirst+               #x0200)
(defwin32constant +wm-mousemove+                #x0200)
(defwin32constant +wm-lbuttondown+              #x0201)
(defwin32constant +wm-lbuttonup+                #x0202)
(defwin32constant +wm-lbuttondblclk+            #x0203)
(defwin32constant +wm-rbuttondown+              #x0204)
(defwin32constant +wm-rbuttonup+                #x0205)
(defwin32constant +wm-rbuttondblclk+            #x0206)
(defwin32constant +wm-mbuttondown+              #x0207)
(defwin32constant +wm-mbuttonup+                #x0208)
(defwin32constant +wm-mbuttondblclk+            #x0209)
(defwin32constant +wm-mousewheel+               #x020A)
(defwin32constant +wm-mousehwheel+              #x020E)
(defwin32constant +wm-parentnotify+             #x0210)
(defwin32constant +wm-entermenuloop+            #x0211)
(defwin32constant +wm-exitmenuloop+             #x0212)
(defwin32constant +wm-nextmenu+                 #x0213)
(defwin32constant +wm-sizing+                   #x0214)
(defwin32constant +wm-capturechanged+           #x0215)
(defwin32constant +wm-moving+                   #x0216)
(defwin32constant +wm-powerbroadcast+           #x0218)
(defwin32constant +wm-devicechange+             #x0219)
(defwin32constant +wm-mdicreate+                #x0220)
(defwin32constant +wm-mdidestroy+               #x0221)
(defwin32constant +wm-mdiactivate+              #x0222)
(defwin32constant +wm-mdirestore+               #x0223)
(defwin32constant +wm-mdinext+                  #x0224)
(defwin32constant +wm-mdimaximize+              #x0225)
(defwin32constant +wm-mditile+                  #x0226)
(defwin32constant +wm-mdicascade+               #x0227)
(defwin32constant +wm-mdiiconarrange+           #x0228)
(defwin32constant +wm-mdigetactive+             #x0229)
(defwin32constant +wm-mdisetmenu+               #x0230)
(defwin32constant +wm-entersizemove+            #x0231)
(defwin32constant +wm-exitsizemove+             #x0232)
(defwin32constant +wm-dropfiles+                #x0233)
(defwin32constant +wm-mdirefreshmenu+           #x0234)
(defwin32constant +wm-ime-setcontext+           #x0281)
(defwin32constant +wm-ime-notify+               #x0282)
(defwin32constant +wm-ime-control+              #x0283)
(defwin32constant +wm-ime-compositionfull+      #x0284)
(defwin32constant +wm-ime-select+               #x0285)
(defwin32constant +wm-ime-char+                 #x0286)
(defwin32constant +wm-ime-keydown+              #x0290)
(defwin32constant +wm-ime-keyup+                #x0291)
(defwin32constant +wm-mousehover+               #x02A1)
(defwin32constant +wm-ncmouseleave+             #x02A2)
(defwin32constant +wm-mouseleave+               #x02A3)
(defwin32constant +wm-cut+                      #x0300)
(defwin32constant +wm-copy+                     #x0301)
(defwin32constant +wm-paste+                    #x0302)
(defwin32constant +wm-clear+                    #x0303)
(defwin32constant +wm-undo+                     #x0304)
(defwin32constant +wm-renderformat+             #x0305)
(defwin32constant +wm-renderallformats+         #x0306)
(defwin32constant +wm-destroyclipboard+         #x0307)
(defwin32constant +wm-drawclipboard+            #x0308)
(defwin32constant +wm-paintclipboard+           #x0309)
(defwin32constant +wm-vscrollclipboard+         #x030A)
(defwin32constant +wm-sizeclipboard+            #x030B)
(defwin32constant +wm-askcbformatname+          #x030C)
(defwin32constant +wm-changecbchain+            #x030D)
(defwin32constant +wm-hscrollclipboard+         #x030E)
(defwin32constant +wm-querynewpalette+          #x030F)
(defwin32constant +wm-paletteischanging+        #x0310)
(defwin32constant +wm-palettechanged+           #x0311)
(defwin32constant +wm-hotkey+                   #x0312)
(defwin32constant +wm-print+                    #x0317)
(defwin32constant +wm-printclient+              #x0318)
(defwin32constant +wm-handheldfirst+            #x0358)
(defwin32constant +wm-handheldlast+             #x035F)
(defwin32constant +wm-penwinfirst+              #x0380)
(defwin32constant +wm-penwinlast+               #x038F)
(defwin32constant +wm-coalesce_first+           #x0390)
(defwin32constant +wm-coalesce_last+            #x039F)
(defwin32constant +wm-dde-first+                #x03E0)
(defwin32constant +wm-dde-initiate+             #x03E0)
(defwin32constant +wm-dde-terminate+            #x03E1)
(defwin32constant +wm-dde-advise+               #x03E2)
(defwin32constant +wm-dde-unadvise+             #x03E3)
(defwin32constant +wm-dde-ack+                  #x03E4)
(defwin32constant +wm-dde-data+                 #x03E5)
(defwin32constant +wm-dde-request+              #x03E6)
(defwin32constant +wm-dde-poke+                 #x03E7)
(defwin32constant +wm-dde-execute+              #x03E8)
(defwin32constant +wm-dde-last+                 #x03E8)
(defwin32constant +wm-user+                     #x0400)
(defwin32constant +wm-app+                      #x8000)

(defwin32constant +time-cancel+    #x80000000)
(defwin32constant +time-hover+     #x00000001)
(defwin32constant +time-leave+     #x00000002)
(defwin32constant +time-nonclient+ #x80000010)
(defwin32constant +time-query+     #x40000000)

(defwin32constant +cw-usedefault+ (%to-int32 #x80000000))

(defwin32constant +cs-vredraw+ #x0001)
(defwin32constant +cs-hredraw+ #x0002)
(defwin32constant +cs-owndc+   #x0020)

(defwin32constant +sw-show+ 5)

(defvar +idi-application+ (make-pointer 32512))
(defvar +idc-arrow+ (make-pointer 32512))

(defwin32constant +white-brush+ 0)
(defwin32constant +black-brush+ 4)
(defwin32constant +dc-brush+ 18)

(defwin32constant +gcl-hbrbackground+ -10)
(defwin32constant +gcl-wndproc+ -24)

(defwin32constant +gcw-atom+ -32)

(defwin32constant +gwl-wndproc+  -4)
(defwin32constant +gwl-id+       -12)
(defwin32constant +gwl-style+    -16)
(defwin32constant +gwl-userdata+ -21)

(defwin32constant +swp-nosize+         #x0001)
(defwin32constant +swp-nomove+         #x0002)
(defwin32constant +swp-nozorder+       #x0004)
(defwin32constant +swp-noactivate+     #x0010)
(defwin32constant +swp-showwindow+     #x0040)
(defwin32constant +swp-hidewindow+     #x0080)
(defwin32constant +swp-noownerzorder+  #x0200)
(defwin32constant +swp-noreposition+   #x0200)

(defwin32constant +infinite+       #xFFFFFFFF)

(defwin32constant +invalid-handle-value+ (%as-ptr -1))
(defwin32constant +invalid-file-size+ #xFFFFFFFF)
(defwin32constant +invalid-set-file-pointer+ (%as-dword -1))
(defwin32constant +invalid-file-attributes+ (%as-dword -1))

(defwin32constant +wait-object-0+  #x00000000)
(defwin32constant +wait-abandoned+ #x00000080)
(defwin32constant +wait-timeout+   #x00000102)
(defwin32constant +wait-failed+    #xFFFFFFFF)

(defwin32constant +hwnd-top+       #x00000000)
(defwin32constant +hwnd-bottom+    #x00000001)
#+:x86
(progn
  (defwin32constant +hwnd-message+   #xFFFFFFFD)
  (defwin32constant +hwnd-notopmost+ #xFFFFFFFE)
  (defwin32constant +hwnd-topmost+   #xFFFFFFFF))

#+:x86-64
(progn
  (defwin32constant +hwnd-message+   #xFFFFFFFFFFFFFFFD)
  (defwin32constant +hwnd-notopmost+ #xFFFFFFFFFFFFFFFE)
  (defwin32constant +hwnd-topmost+   #xFFFFFFFFFFFFFFFF))

(defwin32constant +winevent-outofcontext+    #x0000)
(defwin32constant +winevent-skipownthread+   #x0001)
(defwin32constant +winevent-skipownprocess+  #x0002)
(defwin32constant +winevent-incontext+       #x0004)

(defwin32constant +wh-mouse+        7)
(defwin32constant +wh-mouse-ll+    14)

(defwin32constant +delete+         #x00010000)
(defwin32constant +read-control+   #x00020000)
(defwin32constant +write-dac+      #x00040000)
(defwin32constant +write-owner+    #x00080000)
(defwin32constant +synchronize+    #x00100000)

(defwin32constant +standard-rights-required+ #x00F0000)

(defwin32constant +standard-rights-read+     +read-control+)
(defwin32constant +standard-rights-write+    +read-control+)
(defwin32constant +standard-rights-execute+  +read-control+)

(defwin32constant +standard-rights-all+      #x001F0000)
(defwin32constant +specific-rights-all+      #x0000FFFF)

(defwin32constant +access-system-security+ #x01000000)

(defwin32constant +maximum-allowed+ #x01000000)

(defwin32constant +desktop-createmenu+      #x0004
  "Required to create a menu on the desktop.")
(defwin32constant +desktop-createwindow+    #x0002
  "Required to create a window on the desktop.")
(defwin32constant +desktop-enumerate+       #x0040
  "Required for the desktop to be enumerated.")
(defwin32constant +desktop-hookcontrol+     #x0008
  "Required to establish any of the window hooks.")
(defwin32constant +desktop-journalplayback+ #x0020
  "Required to perform journal playback on a desktop.")
(defwin32constant +desktop-journalrecord+   #x0010
  "Required to perform journal recording on a desktop.")
(defwin32constant +desktop-readobjects+     #x0001
  "Required to read objects on the desktop.")
(defwin32constant +desktop-switchdesktop+   #x0100
  "Required to activate the desktop using the SwitchDesktop function.")
(defwin32constant +desktop-writeobjects+    #x0080
  "Required to write objects on the desktop.")

(defwin32constant +generic-read+ (logior +desktop-enumerate+
                                         +desktop-readobjects+
                                         +standard-rights-read+))

(defwin32constant +generic-write+ (logior +desktop-createmenu+
                                          +desktop-createwindow+
                                          +desktop-hookcontrol+
                                          +desktop-journalplayback+
                                          +desktop-journalrecord+
                                          +desktop-writeobjects+
                                          +standard-rights-write+))

(defwin32constant +generic-execute+ (logior +desktop-switchdesktop+
                                            +standard-rights-execute+))

(defwin32constant +generic-all+ (logior +desktop-createmenu+
                                        +desktop-createwindow+
                                        +desktop-enumerate+
                                        +desktop-hookcontrol+
                                        +desktop-journalplayback+
                                        +desktop-journalrecord+
                                        +desktop-readobjects+
                                        +desktop-switchdesktop+
                                        +desktop-writeobjects+
                                        +standard-rights-required+))

(defwin32constant +file-read-data+ #x0001)
(defwin32constant +file-list-directory+ #x0001)

(defwin32constant +file-write-data+ #x0002)
(defwin32constant +file-add-file+ #x0002)

(defwin32constant +file-append-data+ #x0004)
(defwin32constant +file-add-subdirectory+ #x0004)
(defwin32constant +file-create-pipe-instance+ #x0004)

(defwin32constant +file-read-ea+ #x0008)

(defwin32constant +file-write-ea+ #x0010)

(defwin32constant +file-execute+ #x0020)
(defwin32constant +file-traverse+ #x0020)

(defwin32constant +file-delete-child+ #x0040)

(defwin32constant +file-read-attributes+ #x0080)

(defwin32constant +file-write-attributes+ #x0100)

(defwin32constant +file-all-access+
    (logior +standard-rights-required+
            +synchronize+
            #x1ff))

(defwin32constant +file-generic-read+
    (logior +standard-rights-read+
            +file-read-data+
            +file-read-attributes+
            +file-read-ea+
            +synchronize+))

(defwin32constant +file-generic-write+
    (logior +standard-rights-write+
            +file-write-data+
            +file-write-attributes+
            +file-write-ea+
            +file-append-data+
            +synchronize+))

(defwin32constant +file-generic-execute+
    (logior +standard-rights-execute+
            +file-read-attributes+
            +file-execute+
            +synchronize+))

(defwin32constant +file-share-delete+ #x00000004)
(defwin32constant +file-share-read+   #x00000001)
(defwin32constant +file-share-write+  #x00000002)

(defwin32constant +file-attribute-archive+ #x20)
(defwin32constant +file-attribute-compressed+ #x800)
(defwin32constant +file-attribute-device+ #x40)
(defwin32constant +file-attribute-directory+ #x10)
(defwin32constant +file-attribute-encrypted+ #x4000)
(defwin32constant +file-attribute-hidden+ #x2)
(defwin32constant +file-attribute-integrity-stream+ #x8000)
(defwin32constant +file-attribute-normal+ #x80)
(defwin32constant +file-attribute-not-content-indexed+ #x2000)
(defwin32constant +file-attribute-no-scrub-data+ #x20000)
(defwin32constant +file-attribute-offline+ #x1000)
(defwin32constant +file-attribute-readonly+ #x1)
(defwin32constant +file-attribute-recall-on-data-access+ #x400000)
(defwin32constant +file-attribute-recall-on-open+ #x40000)
(defwin32constant +file-attribute-reparse-point+ #x400)
(defwin32constant +file-attribute-sparse-file+ #x200)
(defwin32constant +file-attribute-system+ #x4)
(defwin32constant +file-attribute-temporary+ #x100)
(defwin32constant +file-attribute-virtual+ #x10000)

(defwin32constant +file-flag-backup-semantics+    #x02000000)
(defwin32constant +file-flag-delete-on-close+     #x04000000)
(defwin32constant +file-flag-no-buffering+        #x20000000)
(defwin32constant +file-flag-open-no-recall+      #x00100000)
(defwin32constant +file-flag-open-reparse-point+  #x00200000)
(defwin32constant +file-flag-overlapped+          #x40000000)
(defwin32constant +file-flag-posix-semantics+     #x00100000)
(defwin32constant +file-flag-random-access+       #x10000000)
(defwin32constant +file-flag-session-aware+       #x00800000)
(defwin32constant +file-flag-sequential-scan+     #x08000000)
(defwin32constant +file-flag-write-through+       #x80000000)
(defwin32constant +file-flag-first-pipe-instance+ #x00080000)

(defwin32constant +movefile-replace-existing+      #x01)
(defwin32constant +movefile-copy-allowed+          #x02)
(defwin32constant +movefile-delay-until-reboot+    #x04)
(defwin32constant +movefile-write-through+         #x08)
(defwin32constant +movefile-create-hardlink+       #x10)
(defwin32constant +movefile-fail-if-not-trackable+ #x20)

(defwin32constant +copy-file-fail-if-exists+              #x00000001)
(defwin32constant +copy-file-restartable+                 #x00000002)
(defwin32constant +copy-file-open-source-for-write+       #x00000004)
(defwin32constant +copy-file-allow-decrypted-destination+ #x00000008)
(defwin32constant +copy-file-copy-symlink+                #x00000800)
(defwin32constant +copy-file-no-buffering+                #x00001000)

(defwin32constant +hkey-classes-root+        #x80000000)
(defwin32constant +hkey-current-user+        #x80000001)
(defwin32constant +hkey-local-machine+       #x80000002)
(defwin32constant +hkey-users+               #x80000003)
(defwin32constant +hkey-performance-data+    #x80000004)
(defwin32constant +hkey-current-config+      #x80000005)
(defwin32constant +hkey-dyn-data+            #x80000006)
(defwin32constant +hkey-performance-text+    #x80000050)
(defwin32constant +hkey-performance-nlstext+ #x80000060)

(defwin32constant +reg-none+ 0)
(defwin32constant +reg-sz+ 1)
(defwin32constant +reg-expand-sz+ 2)
(defwin32constant +reg-binary+ 3)
(defwin32constant +reg-dword+ 4)
(defwin32constant +reg-dword-little-endian+ 4)
(defwin32constant +reg-dword-big-endian+ 5)
(defwin32constant +reg-link+ 6)
(defwin32constant +reg-multi-sz+ 7)
(defwin32constant +reg-resource-list+ 8)
(defwin32constant +reg-full-resource-descriptor+ 9)
(defwin32constant +reg-resource-requirements-list+ 10)
(defwin32constant +reg-qword+ 11)
(defwin32constant +reg-qword-little-endian+ 11)

(defwin32constant +rrf-rt-any+           #x0000ffff)
(defwin32constant +rrf-rt-dword+         #x00000018)
(defwin32constant +rrf-rt-qword+         #x00000048)
(defwin32constant +rrf-rt-reg-binary+    #x00000008)
(defwin32constant +rrf-rt-reg-dword+     #x00000010)
(defwin32constant +rrf-rt-reg-expand-sz+ #x00000004)
(defwin32constant +rrf-rt-reg-multi-sz+  #x00000020)
(defwin32constant +rrf-rt-reg-none+      #x00000001)
(defwin32constant +rrf-rt-reg-qword+     #x00000040)
(defwin32constant +rrf-rt-reg-sz+        #x00000002)

(defwin32constant +rrf-noexpand+          #x10000000)
(defwin32constant +rrf-zeroonfailure+     #x20000000)
(defwin32constant +rrf-subkey-wow6464key+ #x00010000)
(defwin32constant +rrf-subkey-wow6432key+ #x00020000)

(defwin32constant +reg-option-reserved+       #x00000000)
(defwin32constant +reg-option-backup-restore+ #x00000004)
(defwin32constant +reg-option-create-link+    #x00000002)
(defwin32constant +reg-option-non-volatile+   #x00000000)
(defwin32constant +reg-option-volatile+       #x00000001)
(defwin32constant +reg-option-open-link+      #x00000008)

(defwin32constant +reg-created-new-key+     #x00000001)
(defwin32constant +reg-opened-existing-key+ #x00000002)

(defwin32constant +key-all-access+         #xF003F)
(defwin32constant +key-create-link+        #x00020)
(defwin32constant +key-create-sub-key+     #x00004)
(defwin32constant +key-enumerate-sub-keys+ #x00008)
(defwin32constant +key-execute+            #x20019)
(defwin32constant +key-notify+             #x00010)
(defwin32constant +key-query-value+        #x00001)
(defwin32constant +key-read+               #x20019)
(defwin32constant +key-set-value+          #x00002)
(defwin32constant +key-wow64-32key+        #x00200)
(defwin32constant +key-wow64-64key+        #x00100)
(defwin32constant +key-write+              #x20006)

(defwin32constant +color-3ddkshadow+ 21)
(defwin32constant +color-3dface+ 15)
(defwin32constant +color-3dhighlight+ 20)
(defwin32constant +color-3dhilight+ 20)
(defwin32constant +color-3dlight+ 22)
(defwin32constant +color-3dshadow+ 16)
(defwin32constant +color-activeborder+ 10)
(defwin32constant +color-activecaption+ 2)
(defwin32constant +color-appworkspace+ 12)
(defwin32constant +color-background+ 1)
(defwin32constant +color-btnface+ 15)
(defwin32constant +color-btnhighlight+ 20)
(defwin32constant +color-btnhilight+ 20)
(defwin32constant +color-btnshadow+ 16)
(defwin32constant +color-btntext+ 18)
(defwin32constant +color-captiontext+ 9)
(defwin32constant +color-desktop+ 1)
(defwin32constant +color-gradientactivecaption+ 27)
(defwin32constant +color-gradientinactivecaption+ 28)
(defwin32constant +color-graytext+ 17)
(defwin32constant +color-highlight+ 13)
(defwin32constant +color-highlighttext+ 14)
(defwin32constant +color-hotlight+ 26)
(defwin32constant +color-inactiveborder+ 11)
(defwin32constant +color-inactivecaption+ 3)
(defwin32constant +color-inactivecaptiontext+ 19)
(defwin32constant +color-infobk+ 24)
(defwin32constant +color-infotext+ 23)
(defwin32constant +color-menu+ 4)
(defwin32constant +color-menuhilight+ 29)
(defwin32constant +color-menubar+ 30)
(defwin32constant +color-menutext+ 7)
(defwin32constant +color-scrollbar+ 0)
(defwin32constant +color-window+ 5)
(defwin32constant +color-windowframe+ 6)
(defwin32constant +color-windowtext+ 8)

(defwin32constant +smto-abortifhung+        #x0002)
(defwin32constant +smto-block+              #x0001)
(defwin32constant +smto-normal+             #x0000)
(defwin32constant +smto-notimeoutifnothung+ #x0008)
(defwin32constant +smto-erroronexit+        #x0020)

(defwin32constant +bsf-allowsfw+           #x00000080)
(defwin32constant +bsf-flushdisk+          #x00000004)
(defwin32constant +bsf-forceifhung+        #x00000020)
(defwin32constant +bsf-ignorecurrenttask+  #x00000002)
(defwin32constant +bsf-luid+               #x00000400)
(defwin32constant +bsf-nohang+             #x00000008)
(defwin32constant +bsf-notimeoutifnothung+ #x00000040)
(defwin32constant +bsf-postmessage+        #x00000010)
(defwin32constant +bsf-returnhdesk+        #x00000200)
(defwin32constant +bsf-query+              #x00000001)
(defwin32constant +bsf-sendnotifymessage+  #x00000100)

(defwin32constant +bsm-allcomponents+ #x00000000)
(defwin32constant +bsm-alldesktops+   #x00000010)
(defwin32constant +bsm-applications+  #x00000008)

(defwin32constant +ismex-callback+ #x00000004)
(defwin32constant +ismex-notify+   #x00000002)
(defwin32constant +ismex-replied+  #x00000008)
(defwin32constant +ismex-send+     #x00000001)

(defwin32constant +sm-arrange+ 56)
(defwin32constant +sm-cleanboot+ 67)
(defwin32constant +sm-cmonitors+ 80)
(defwin32constant +sm-cmousebuttons+ 43)
(defwin32constant +sm-convertibleslatemode+ #x2003)
(defwin32constant +sm-cxborder+ 5)
(defwin32constant +sm-cxcursor+ 13)
(defwin32constant +sm-cxdlgframe+ 7)
(defwin32constant +sm-cxdoubleclk+ 36)
(defwin32constant +sm-cxdrag+ 68)
(defwin32constant +sm-cxedge+ 45)
(defwin32constant +sm-cxfixedframe+ 7)
(defwin32constant +sm-cxfocusborder+ 83)
(defwin32constant +sm-cxframe+ 32)
(defwin32constant +sm-cxfullscreen+ 16)
(defwin32constant +sm-cxhscroll+ 21)
(defwin32constant +sm-cxhthumb+ 10)
(defwin32constant +sm-cxicon+ 11)
(defwin32constant +sm-cxiconspacing+ 38)
(defwin32constant +sm-cxmaximized+ 61)
(defwin32constant +sm-cxmaxtrack+ 59)
(defwin32constant +sm-cxmenucheck+ 71)
(defwin32constant +sm-cxmenusize+ 54)
(defwin32constant +sm-cxmin+ 28)
(defwin32constant +sm-cxminimized+ 57)
(defwin32constant +sm-cxminspacing+ 47)
(defwin32constant +sm-cxmintrack+ 34)
(defwin32constant +sm-cxpaddedborder+ 92)
(defwin32constant +sm-cxscreen+ 0)
(defwin32constant +sm-cxsize+ 30)
(defwin32constant +sm-cxsizeframe+ 32)
(defwin32constant +sm-cxsmicon+ 49)
(defwin32constant +sm-cxsmsize+ 52)
(defwin32constant +sm-cxvirtualscreen+ 78)
(defwin32constant +sm-cxvscroll+ 2)
(defwin32constant +sm-cyborder+ 6)
(defwin32constant +sm-cycaption+ 4)
(defwin32constant +sm-cycursor+ 14)
(defwin32constant +sm-cydlgframe+ 8)
(defwin32constant +sm-cydoubleclk+ 37)
(defwin32constant +sm-cydrag+ 69)
(defwin32constant +sm-cyedge+ 46)
(defwin32constant +sm-cyfixedframe+ 8)
(defwin32constant +sm-cyfocusborder+ 84)
(defwin32constant +sm-cyframe+ 33)
(defwin32constant +sm-cyfullscreen+ 17)
(defwin32constant +sm-cyhscroll+ 3)
(defwin32constant +sm-cyicon+ 12)
(defwin32constant +sm-cyiconspacing+ 39)
(defwin32constant +sm-cykanjiwindow+ 18)
(defwin32constant +sm-cymaximized+ 62)
(defwin32constant +sm-cymaxtrack+ 60)
(defwin32constant +sm-cymenu+ 15)
(defwin32constant +sm-cymenucheck+ 72)
(defwin32constant +sm-cymenusize+ 55)
(defwin32constant +sm-cymin+ 29)
(defwin32constant +sm-cyminimized+ 58)
(defwin32constant +sm-cyminspacing+ 48)
(defwin32constant +sm-cymintrack+ 35)
(defwin32constant +sm-cyscreen+ 1)
(defwin32constant +sm-cysize+ 31)
(defwin32constant +sm-cysizeframe+ 33)
(defwin32constant +sm-cysmcaption+ 51)
(defwin32constant +sm-cysmicon+ 50)
(defwin32constant +sm-cysmsize+ 53)
(defwin32constant +sm-cyvirtualscreen+ 79)
(defwin32constant +sm-cyvscroll+ 20)
(defwin32constant +sm-cyvthumb+ 9)
(defwin32constant +sm-dbcsenabled+ 42)
(defwin32constant +sm-debug+ 22)
(defwin32constant +sm-digitizer+ 94)
(defwin32constant +sm-immenabled+ 82)
(defwin32constant +sm-maximumtouches+ 95)
(defwin32constant +sm-mediacenter+ 87)
(defwin32constant +sm-menudropalignment+ 40)
(defwin32constant +sm-mideastenabled+ 74)
(defwin32constant +sm-mousepresent+ 19)
(defwin32constant +sm-mousehorizontalwheelpresent+ 91)
(defwin32constant +sm-mousewheelpresent+ 75)
(defwin32constant +sm-network+ 63)
(defwin32constant +sm-penwindows+ 41)
(defwin32constant +sm-remotecontrol+ #x2001)
(defwin32constant +sm-remotesession+ #x1000)
(defwin32constant +sm-samedisplayformat+ 81)
(defwin32constant +sm-secure+ 44)
(defwin32constant +sm-serverr2+ 89)
(defwin32constant +sm-showsounds+ 70)
(defwin32constant +sm-shuttingdown+ #x2000)
(defwin32constant +sm-slowmachine+ 73)
(defwin32constant +sm-starter+ 88)
(defwin32constant +sm-swapbutton+ 23)
(defwin32constant +sm-systemdocked+ #x2004)
(defwin32constant +sm-tabletpc+ 86)
(defwin32constant +sm-xvirtualscreen+ 76)
(defwin32constant +sm-yvirtualscreen+ 77)

;;;Accessibility parameters
(defwin32constant +spi-getaccesstimeout+ #x003C)
(defwin32constant +spi-getaudiodescription+ #x0074)
(defwin32constant +spi-getclientareaanimation+ #x1042)
(defwin32constant +spi-getdisableoverlappedcontent+ #x1040)
(defwin32constant +spi-getfilterkeys+ #x0032)
(defwin32constant +spi-getfocusborderheight+ #x2010)
(defwin32constant +spi-getfocusborderwidth+ #x200E)
(defwin32constant +spi-gethighcontrast+ #x0042)
(defwin32constant +spi-getlogicaldpioverride+ #x009E)
(defwin32constant +spi-getmessageduration+ #x2016)
(defwin32constant +spi-getmouseclicklock+ #x101E)
(defwin32constant +spi-getmouseclicklocktime+ #x2008)
(defwin32constant +spi-getmousekeys+ #x0036)
(defwin32constant +spi-getmousesonar+ #x101C)
(defwin32constant +spi-getmousevanish+ #x1020)
(defwin32constant +spi-getscreenreader+ #x0046)
(defwin32constant +spi-getserialkeys+ #x003E)
(defwin32constant +spi-getshowsounds+ #x0038)
(defwin32constant +spi-getsoundsentry+ #x0040)
(defwin32constant +spi-getstickykeys+ #x003A)
(defwin32constant +spi-gettogglekeys+ #x0034)
(defwin32constant +spi-setaccesstimeout+ #x003D)
(defwin32constant +spi-setaudiodescription+ #x0075)
(defwin32constant +spi-setclientareaanimation+ #x1043)
(defwin32constant +spi-setdisableoverlappedcontent+ #x1041)
(defwin32constant +spi-setfilterkeys+ #x0033)
(defwin32constant +spi-setfocusborderheight+ #x2011)
(defwin32constant +spi-setfocusborderwidth+ #x200F)
(defwin32constant +spi-sethighcontrast+ #x0043)
(defwin32constant +spi-setlogicaldpioverride+ #x009F)
(defwin32constant +spi-setmessageduration+ #x2017)
(defwin32constant +spi-setmouseclicklock+ #x101F)
(defwin32constant +spi-setmouseclicklocktime+ #x2009)
(defwin32constant +spi-setmousekeys+ #x0037)
(defwin32constant +spi-setmousesonar+ #x101D)
(defwin32constant +spi-setmousevanish+ #x1021)
(defwin32constant +spi-setscreenreader+ #x0047)
(defwin32constant +spi-setserialkeys+ #x003F)
(defwin32constant +spi-setshowsounds+ #x0039)
(defwin32constant +spi-setsoundsentry+ #x0041)
(defwin32constant +spi-setstickykeys+ #x003B)
(defwin32constant +spi-settogglekeys+ #x0035)

;;;Desktop parameters
(defwin32constant +spi-getcleartype+ #x1048)
(defwin32constant +spi-getdeskwallpaper+ #x0073)
(defwin32constant +spi-getdropshadow+ #x1024)
(defwin32constant +spi-getflatmenu+ #x1022)
(defwin32constant +spi-getfontsmoothing+ #x004A)
(defwin32constant +spi-getfontsmoothingcontrast+ #x200C)
(defwin32constant +spi-getfontsmoothingorientation+ #x2012)
(defwin32constant +spi-getfontsmoothingtype+ #x200A)
(defwin32constant +spi-getworkarea+ #x0030)
(defwin32constant +spi-setcleartype+ #x1049)
(defwin32constant +spi-setcursors+ #x0057)
(defwin32constant +spi-setdeskpattern+ #x0015)
(defwin32constant +spi-setdeskwallpaper+ #x0014)
(defwin32constant +spi-setdropshadow+ #x1025)
(defwin32constant +spi-setflatmenu+ #x1023)
(defwin32constant +spi-setfontsmoothing+ #x004B)
(defwin32constant +spi-setfontsmoothingcontrast+ #x200D)
(defwin32constant +spi-setfontsmoothingorientation+ #x2013)
(defwin32constant +spi-setfontsmoothingtype+ #x200B)
(defwin32constant +spi-setworkarea+ #x002F)

;;;Icon parameters
(defwin32constant +spi-geticonmetrics+ #x002D)
(defwin32constant +spi-geticontitlelogfont+ #x001F)
(defwin32constant +spi-geticontitlewrap+ #x0019)
(defwin32constant +spi-iconhorizontalspacing+ #x000D)
(defwin32constant +spi-iconverticalspacing+ #x0018)
(defwin32constant +spi-seticonmetrics+ #x002E)
(defwin32constant +spi-seticons+ #x0058)
(defwin32constant +spi-seticontitlelogfont+ #x0022)
(defwin32constant +spi-seticontitlewrap+ #x001A)

;;Input parameters
(defwin32constant +spi-getbeep+ #x0001)
(defwin32constant +spi-getblocksendinputresets+ #x1026)
(defwin32constant +spi-getcontactvisualization+ #x2018)
(defwin32constant +spi-getdefaultinputlang+ #x0059)
(defwin32constant +spi-getgesturevisualization+ #x201A)
(defwin32constant +spi-getkeyboardcues+ #x100A)
(defwin32constant +spi-getkeyboarddelay+ #x0016)
(defwin32constant +spi-getkeyboardpref+ #x0044)
(defwin32constant +spi-getkeyboardspeed+ #x000A)
(defwin32constant +spi-getmouse+ #x0003)
(defwin32constant +spi-getmousehoverheight+ #x0064)
(defwin32constant +spi-getmousehovertime+ #x0066)
(defwin32constant +spi-getmousehoverwidth+ #x0062)
(defwin32constant +spi-getmousespeed+ #x0070)
(defwin32constant +spi-getmousetrails+ #x005E)
(defwin32constant +spi-getmousewheelrouting+ #x201C)
(defwin32constant +spi-getpenvisualization+ #x201E)
(defwin32constant +spi-getsnaptodefbutton+ #x005F)
(defwin32constant +spi-getsystemlanguagebar+ #x1050)
(defwin32constant +spi-getthreadlocalinputsettings+ #x104E)
(defwin32constant +spi-getwheelscrollchars+ #x006C)
(defwin32constant +spi-getwheelscrolllines+ #x0068)
(defwin32constant +spi-setbeep+ #x0002)
(defwin32constant +spi-setblocksendinputresets+ #x1027)
(defwin32constant +spi-setcontactvisualization+ #x2019)
(defwin32constant +spi-setdefaultinputlang+ #x005A)
(defwin32constant +spi-setdoubleclicktime+ #x0020)
(defwin32constant +spi-setdoubleclkheight+ #x001E)
(defwin32constant +spi-setdoubleclkwidth+ #x001D)
(defwin32constant +spi-setgesturevisualization+ #x201B)
(defwin32constant +spi-setkeyboardcues+ #x100B)
(defwin32constant +spi-setkeyboarddelay+ #x0017)
(defwin32constant +spi-setkeyboardpref+ #x0045)
(defwin32constant +spi-setkeyboardspeed+ #x000B)
(defwin32constant +spi-setlangtoggle+ #x005B)
(defwin32constant +spi-setmouse+ #x0004)
(defwin32constant +spi-setmousebuttonswap+ #x0021)
(defwin32constant +spi-setmousehoverheight+ #x0065)
(defwin32constant +spi-setmousehovertime+ #x0067)
(defwin32constant +spi-setmousehoverwidth+ #x0063)
(defwin32constant +spi-setmousespeed+ #x0071)
(defwin32constant +spi-setmousetrails+ #x005D)
(defwin32constant +spi-setmousewheelrouting+ #x201D)
(defwin32constant +spi-setpenvisualization+ #x201F)
(defwin32constant +spi-setsnaptodefbutton+ #x0060)
(defwin32constant +spi-setsystemlanguagebar+ #x1051)
(defwin32constant +spi-setthreadlocalinputsettings+ #x104F)
(defwin32constant +spi-setwheelscrollchars+ #x006D)
(defwin32constant +spi-setwheelscrolllines+ #x0069)

;;;Menu parameters
(defwin32constant +spi-getmenudropalignment+ #x001B)
(defwin32constant +spi-getmenufade+ #x1012)
(defwin32constant +spi-getmenushowdelay+ #x006A)
(defwin32constant +spi-setmenudropalignment+ #x001C)
(defwin32constant +spi-setmenufade+ #x1013)
(defwin32constant +spi-setmenushowdelay+ #x006B)

;;;Power parameters
(defwin32constant +spi-getlowpoweractive+ #x0053)
(defwin32constant +spi-getlowpowertimeout+ #x004F)
(defwin32constant +spi-getpoweroffactive+ #x0054)
(defwin32constant +spi-getpowerofftimeout+ #x0050)
(defwin32constant +spi-setlowpoweractive+ #x0055)
(defwin32constant +spi-setlowpowertimeout+ #x0051)
(defwin32constant +spi-setpoweroffactive+ #x0056)
(defwin32constant +spi-setpowerofftimeout+ #x0052)

;;;Screen saver parameters
(defwin32constant +spi-getscreensaveactive+ #x0010)
(defwin32constant +spi-getscreensaverrunning+ #x0072)
(defwin32constant +spi-getscreensavesecure+ #x0076)
(defwin32constant +spi-getscreensavetimeout+ #x000E)
(defwin32constant +spi-setscreensaveactive+ #x0011)
(defwin32constant +spi-setscreensavesecure+ #x0077)
(defwin32constant +spi-setscreensavetimeout+ #x000F)

;;;Time-out parameters for applications/services
(defwin32constant +spi-gethungapptimeout+ #x0078)
(defwin32constant +spi-getwaittokilltimeout+ #x007A)
(defwin32constant +spi-getwaittokillservicetimeout+ #x007C)
(defwin32constant +spi-sethungapptimeout+ #x0079)
(defwin32constant +spi-setwaittokilltimeout+ #x007B)
(defwin32constant +spi-setwaittokillservicetimeout+ #x007D)

;;;UI effects parameters
(defwin32constant +spi-getcomboboxanimation+ #x1004)
(defwin32constant +spi-getcursorshadow+ #x101A)
(defwin32constant +spi-getgradientcaptions+ #x1008)
(defwin32constant +spi-gethottracking+ #x100E)
(defwin32constant +spi-getlistboxsmoothscrolling+ #x1006)
(defwin32constant +spi-getmenuanimation+ #x1002)
(defwin32constant +spi-getmenuunderlines+ #x100A)
(defwin32constant +spi-getselectionfade+ #x1014)
(defwin32constant +spi-gettooltipanimation+ #x1016)
(defwin32constant +spi-gettooltipfade+ #x1018)
(defwin32constant +spi-getuieffects+ #x103E)
(defwin32constant +spi-setcomboboxanimation+ #x1005)
(defwin32constant +spi-setcursorshadow+ #x101B)
(defwin32constant +spi-setgradientcaptions+ #x1009)
(defwin32constant +spi-sethottracking+ #x100F)
(defwin32constant +spi-setlistboxsmoothscrolling+ #x1007)
(defwin32constant +spi-setmenuanimation+ #x1003)
(defwin32constant +spi-setmenuunderlines+ #x100B)
(defwin32constant +spi-setselectionfade+ #x1015)
(defwin32constant +spi-settooltipanimation+ #x1017)
(defwin32constant +spi-settooltipfade+ #x1019)
(defwin32constant +spi-setuieffects+ #x103F)

;;;Window parameters
(defwin32constant +spi-getactivewindowtracking+ #x1000)
(defwin32constant +spi-getactivewndtrkzorder+ #x100C)
(defwin32constant +spi-getactivewndtrktimeout+ #x2002)
(defwin32constant +spi-getanimation+ #x0048)
(defwin32constant +spi-getborder+ #x0005)
(defwin32constant +spi-getcaretwidth+ #x2006)
(defwin32constant +spi-getdockmoving+ #x0090)
(defwin32constant +spi-getdragfrommaximize+ #x008C)
(defwin32constant +spi-getdragfullwindows+ #x0026)
(defwin32constant +spi-getforegroundflashcount+ #x2004)
(defwin32constant +spi-getforegroundlocktimeout+ #x2000)
(defwin32constant +spi-getminimizedmetrics+ #x002B)
(defwin32constant +spi-getmousedockthreshold+ #x007E)
(defwin32constant +spi-getmousedragoutthreshold+ #x0084)
(defwin32constant +spi-getmousesidemovethreshold+ #x0088)
(defwin32constant +spi-getnonclientmetrics+ #x0029)
(defwin32constant +spi-getpendockthreshold+ #x0080)
(defwin32constant +spi-getpendragoutthreshold+ #x0086)
(defwin32constant +spi-getpensidemovethreshold+ #x008A)
(defwin32constant +spi-getshowimeui+ #x006E)
(defwin32constant +spi-getsnapsizing+ #x008E)
(defwin32constant +spi-getwinarranging+ #x0082)
(defwin32constant +spi-setactivewindowtracking+ #x1001)
(defwin32constant +spi-setactivewndtrkzorder+ #x100D)
(defwin32constant +spi-setactivewndtrktimeout+ #x2003)
(defwin32constant +spi-setanimation+ #x0049)
(defwin32constant +spi-setborder+ #x0006)
(defwin32constant +spi-setcaretwidth+ #x2007)
(defwin32constant +spi-setdockmoving+ #x0091)
(defwin32constant +spi-setdragfrommaximize+ #x008D)
(defwin32constant +spi-setdragfullwindows+ #x0025)
(defwin32constant +spi-setdragheight+ #x004D)
(defwin32constant +spi-setdragwidth+ #x004C)
(defwin32constant +spi-setforegroundflashcount+ #x2005)
(defwin32constant +spi-setforegroundlocktimeout+ #x2001)
(defwin32constant +spi-setminimizedmetrics+ #x002C)
(defwin32constant +spi-setmousedockthreshold+ #x007F)
(defwin32constant +spi-setmousedragoutthreshold+ #x0085)
(defwin32constant +spi-setmousesidemovethreshold+ #x0089)
(defwin32constant +spi-setnonclientmetrics+ #x002A)
(defwin32constant +spi-setpendockthreshold+ #x0081)
(defwin32constant +spi-setpendragoutthreshold+ #x0087)
(defwin32constant +spi-setpensidemovethreshold+ #x008B)
(defwin32constant +spi-setshowimeui+ #x006F)
(defwin32constant +spi-setsnapsizing+ #x008F)
(defwin32constant +spi-setwinarranging+ #x0083)

(defwin32constant +spif-updateinifile+ #x01)
(defwin32constant +spif-sendchange+ #x02)
(defwin32constant +spif-sendwininichange+ #x02)

(defwin32constant +lf-facesize+ 32)

(defwin32constant +anysize-array+ 1)

(defwin32constant +digcf-default+         #x00000001)
(defwin32constant +digcf-present+         #x00000002)
(defwin32constant +digcf-allclasses+      #x00000004)
(defwin32constant +digcf-profile+         #x00000008)
(defwin32constant +digcf-deviceinterface+ #x00000010)
(defwin32constant +digcf-interfacedevice+ #x00000010)

(defwin32constant +error-success+ 0)
(defwin32constant +no-error+ 0)
(defwin32constant +error-invalid-function+ 1)
(defwin32constant +error-file-not-found+ 2)
(defwin32constant +error-path-not-found+ 3)
(defwin32constant +error-too-many-open-files+ 4)
(defwin32constant +error-access-denied+ 5)
(defwin32constant +error-invalid-handle+ 6)
(defwin32constant +error-arena-trashed+ 7)
(defwin32constant +error-not-enough-memory+ 8)
(defwin32constant +error-invalid-block+ 9)
(defwin32constant +error-bad-environment+ 10)
(defwin32constant +error-bad-format+ 11)
(defwin32constant +error-invalid-access+ 12)
(defwin32constant +error-invalid-data+ 13)
(defwin32constant +error-outofmemory+ 14)
(defwin32constant +error-invalid-drive+ 15)
(defwin32constant +error-current-directory+ 16)
(defwin32constant +error-not-same-device+ 17)
(defwin32constant +error-no-more-files+ 18)
(defwin32constant +error-write-protect+ 19)
(defwin32constant +error-bad-unit+ 20)
(defwin32constant +error-not-ready+ 21)
(defwin32constant +error-bad-command+ 22)
(defwin32constant +error-crc+ 23)
(defwin32constant +error-bad-length+ 24)
(defwin32constant +error-seek+ 25)
(defwin32constant +error-not-dos-disk+ 26)
(defwin32constant +error-sector-not-found+ 27)
(defwin32constant +error-out-of-paper+ 28)
(defwin32constant +error-write-fault+ 29)
(defwin32constant +error-read-fault+ 30)
(defwin32constant +error-gen-failure+ 31)
(defwin32constant +error-sharing-violation+ 32)
(defwin32constant +error-lock-violation+ 33)
(defwin32constant +error-wrong-disk+ 34)
(defwin32constant +error-sharing-buffer-exceeded+ 36)
(defwin32constant +error-handle-eof+ 38)
(defwin32constant +error-handle-disk-full+ 39)
(defwin32constant +error-not-supported+ 50)
(defwin32constant +error-rem-not-list+ 51)
(defwin32constant +error-dup-name+ 52)
(defwin32constant +error-bad-netpath+ 53)
(defwin32constant +error-network-busy+ 54)
(defwin32constant +error-dev-not-exist+ 55)
(defwin32constant +error-too-many-cmds+ 56)
(defwin32constant +error-adap-hdw-err+ 57)
(defwin32constant +error-bad-net-resp+ 58)
(defwin32constant +error-unexp-net-err+ 59)
(defwin32constant +error-bad-rem-adap+ 60)
(defwin32constant +error-printq-full+ 61)
(defwin32constant +error-no-spool-space+ 62)
(defwin32constant +error-print-cancelled+ 63)
(defwin32constant +error-netname-deleted+ 64)
(defwin32constant +error-network-access-denied+ 65)
(defwin32constant +error-bad-dev-type+ 66)
(defwin32constant +error-bad-net-name+ 67)
(defwin32constant +error-too-many-names+ 68)
(defwin32constant +error-too-many-sess+ 69)
(defwin32constant +error-sharing-paused+ 70)
(defwin32constant +error-req-not-accep+ 71)
(defwin32constant +error-redir-paused+ 72)
(defwin32constant +error-file-exists+ 80)
(defwin32constant +error-cannot-make+ 82)
(defwin32constant +error-fail-i24+ 83)
(defwin32constant +error-out-of-structures+ 84)
(defwin32constant +error-already-assigned+ 85)
(defwin32constant +error-invalid-password+ 86)
(defwin32constant +error-invalid-parameter+ 87)
(defwin32constant +error-net-write-fault+ 88)
(defwin32constant +error-no-proc-slots+ 89)
(defwin32constant +error-too-many-semaphores+ 100)
(defwin32constant +error-excl-sem-already-owned+ 101)
(defwin32constant +error-sem-is-set+ 102)
(defwin32constant +error-too-many-sem-requests+ 103)
(defwin32constant +error-invalid-at-interrupt-time+ 104)
(defwin32constant +error-sem-owner-died+ 105)
(defwin32constant +error-sem-user-limit+ 106)
(defwin32constant +error-disk-change+ 107)
(defwin32constant +error-drive-locked+ 108)
(defwin32constant +error-broken-pipe+ 109)
(defwin32constant +error-open-failed+ 110)
(defwin32constant +error-buffer-overflow+ 111)
(defwin32constant +error-disk-full+ 112)
(defwin32constant +error-no-more-search-handles+ 113)
(defwin32constant +error-invalid-target-handle+ 114)
(defwin32constant +error-invalid-category+ 117)
(defwin32constant +error-invalid-verify-switch+ 118)
(defwin32constant +error-bad-driver-level+ 119)
(defwin32constant +error-call-not-implemented+ 120)
(defwin32constant +error-sem-timeout+ 121)
(defwin32constant +error-insufficient-buffer+ 122)
(defwin32constant +error-invalid-name+ 123)
(defwin32constant +error-invalid-level+ 124)
(defwin32constant +error-no-volume-label+ 125)
(defwin32constant +error-mod-not-found+ 126)
(defwin32constant +error-proc-not-found+ 127)
(defwin32constant +error-wait-no-children+ 128)
(defwin32constant +error-child-not-complete+ 129)
(defwin32constant +error-direct-access-handle+ 130)
(defwin32constant +error-negative-seek+ 131)
(defwin32constant +error-seek-on-device+ 132)
(defwin32constant +error-is-join-target+ 133)
(defwin32constant +error-is-joined+ 134)
(defwin32constant +error-is-substed+ 135)
(defwin32constant +error-not-joined+ 136)
(defwin32constant +error-not-substed+ 137)
(defwin32constant +error-join-to-join+ 138)
(defwin32constant +error-subst-to-subst+ 139)
(defwin32constant +error-join-to-subst+ 140)
(defwin32constant +error-subst-to-join+ 141)
(defwin32constant +error-busy-drive+ 142)
(defwin32constant +error-same-drive+ 143)
(defwin32constant +error-dir-not-root+ 144)
(defwin32constant +error-dir-not-empty+ 145)
(defwin32constant +error-is-subst-path+ 146)
(defwin32constant +error-is-join-path+ 147)
(defwin32constant +error-path-busy+ 148)
(defwin32constant +error-is-subst-target+ 149)
(defwin32constant +error-system-trace+ 150)
(defwin32constant +error-invalid-event-count+ 151)
(defwin32constant +error-too-many-muxwaiters+ 152)
(defwin32constant +error-invalid-list-format+ 153)
(defwin32constant +error-label-too-long+ 154)
(defwin32constant +error-too-many-tcbs+ 155)
(defwin32constant +error-signal-refused+ 156)
(defwin32constant +error-discarded+ 157)
(defwin32constant +error-not-locked+ 158)
(defwin32constant +error-bad-threadid-addr+ 159)
(defwin32constant +error-bad-arguments+ 160)
(defwin32constant +error-bad-pathname+ 161)
(defwin32constant +error-signal-pending+ 162)
(defwin32constant +error-max-thrds-reached+ 164)
(defwin32constant +error-lock-failed+ 167)
(defwin32constant +error-busy+ 170)
(defwin32constant +error-cancel-violation+ 173)
(defwin32constant +error-atomic-locks-not-supported+ 174)
(defwin32constant +error-invalid-segment-number+ 180)
(defwin32constant +error-invalid-ordinal+ 182)
(defwin32constant +error-already-exists+ 183)
(defwin32constant +error-invalid-flag-number+ 186)
(defwin32constant +error-sem-not-found+ 187)
(defwin32constant +error-invalid-starting-codeseg+ 188)
(defwin32constant +error-invalid-stackseg+ 189)
(defwin32constant +error-invalid-moduletype+ 190)
(defwin32constant +error-invalid-exe-signature+ 191)
(defwin32constant +error-exe-marked-invalid+ 192)
(defwin32constant +error-bad-exe-format+ 193)
(defwin32constant +error-iterated-data-exceeds-64k+ 194)
(defwin32constant +error-invalid-minallocsize+ 195)
(defwin32constant +error-dynlink-from-invalid-ring+ 196)
(defwin32constant +error-iopl-not-enabled+ 197)
(defwin32constant +error-invalid-segdpl+ 198)
(defwin32constant +error-autodataseg-exceeds-64k+ 199)
(defwin32constant +error-ring2seg-must-be-movable+ 200)
(defwin32constant +error-reloc-chain-xeeds-seglim+ 201)
(defwin32constant +error-infloop-in-reloc-chain+ 202)
(defwin32constant +error-envvar-not-found+ 203)
(defwin32constant +error-no-signal-sent+ 205)
(defwin32constant +error-filename-exced-range+ 206)
(defwin32constant +error-ring2-stack-in-use+ 207)
(defwin32constant +error-meta-expansion-too-long+ 208)
(defwin32constant +error-invalid-signal-number+ 209)
(defwin32constant +error-thread-1-inactive+ 210)
(defwin32constant +error-locked+ 212)
(defwin32constant +error-too-many-modules+ 214)
(defwin32constant +error-nesting-not-allowed+ 215)
(defwin32constant +error-bad-pipe+ 230)
(defwin32constant +error-pipe-busy+ 231)
(defwin32constant +error-no-data+ 232)
(defwin32constant +error-pipe-not-connected+ 233)
(defwin32constant +error-more-data+ 234)
(defwin32constant +error-vc-disconnected+ 240)
(defwin32constant +error-invalid-ea-name+ 254)
(defwin32constant +error-ea-list-inconsistent+ 255)
(defwin32constant +error-no-more-items+ 259)
(defwin32constant +error-cannot-copy+ 266)
(defwin32constant +error-directory+ 267)
(defwin32constant +error-eas-didnt-fit+ 275)
(defwin32constant +error-ea-file-corrupt+ 276)
(defwin32constant +error-ea-table-full+ 277)
(defwin32constant +error-invalid-ea-handle+ 278)
(defwin32constant +error-eas-not-supported+ 282)
(defwin32constant +error-not-owner+ 288)
(defwin32constant +error-too-many-posts+ 298)
(defwin32constant +error-partial-copy+ 299)
(defwin32constant +error-mr-mid-not-found+ 317)
(defwin32constant +error-invalid-address+ 487)
(defwin32constant +error-arithmetic-overflow+ 534)
(defwin32constant +error-pipe-connected+ 535)
(defwin32constant +error-pipe-listening+ 536)
(defwin32constant +error-ea-access-denied+ 994)
(defwin32constant +error-operation-aborted+ 995)
(defwin32constant +error-io-incomplete+ 996)
(defwin32constant +error-io-pending+ 997)
(defwin32constant +error-noaccess+ 998)
(defwin32constant +error-swaperror+ 999)
(defwin32constant +error-stack-overflow+ 1001)
(defwin32constant +error-invalid-message+ 1002)
(defwin32constant +error-can-not-complete+ 1003)
(defwin32constant +error-invalid-flags+ 1004)
(defwin32constant +error-unrecognized-volume+ 1005)
(defwin32constant +error-file-invalid+ 1006)
(defwin32constant +error-fullscreen-mode+ 1007)
(defwin32constant +error-no-token+ 1008)
(defwin32constant +error-baddb+ 1009)
(defwin32constant +error-badkey+ 1010)
(defwin32constant +error-cantopen+ 1011)
(defwin32constant +error-cantread+ 1012)
(defwin32constant +error-cantwrite+ 1013)
(defwin32constant +error-registry-recovered+ 1014)
(defwin32constant +error-registry-corrupt+ 1015)
(defwin32constant +error-registry-io-failed+ 1016)
(defwin32constant +error-not-registry-file+ 1017)
(defwin32constant +error-key-deleted+ 1018)
(defwin32constant +error-no-log-space+ 1019)
(defwin32constant +error-key-has-children+ 1020)
(defwin32constant +error-child-must-be-volatile+ 1021)
(defwin32constant +error-notify-enum-dir+ 1022)
(defwin32constant +error-dependent-services-running+ 1051)
(defwin32constant +error-invalid-service-control+ 1052)
(defwin32constant +error-service-request-timeout+ 1053)
(defwin32constant +error-service-no-thread+ 1054)
(defwin32constant +error-service-database-locked+ 1055)
(defwin32constant +error-service-already-running+ 1056)
(defwin32constant +error-invalid-service-account+ 1057)
(defwin32constant +error-service-disabled+ 1058)
(defwin32constant +error-circular-dependency+ 1059)
(defwin32constant +error-service-does-not-exist+ 1060)
(defwin32constant +error-service-cannot-accept-ctrl+ 1061)
(defwin32constant +error-service-not-active+ 1062)
(defwin32constant +error-failed-service-controller-connect+ 1063)
(defwin32constant +error-exception-in-service+ 1064)
(defwin32constant +error-database-does-not-exist+ 1065)
(defwin32constant +error-service-specific-error+ 1066)
(defwin32constant +error-process-aborted+ 1067)
(defwin32constant +error-service-dependency-fail+ 1068)
(defwin32constant +error-service-logon-failed+ 1069)
(defwin32constant +error-service-start-hang+ 1070)
(defwin32constant +error-invalid-service-lock+ 1071)
(defwin32constant +error-service-marked-for-delete+ 1072)
(defwin32constant +error-service-exists+ 1073)
(defwin32constant +error-already-running-lkg+ 1074)
(defwin32constant +error-service-dependency-deleted+ 1075)
(defwin32constant +error-boot-already-accepted+ 1076)
(defwin32constant +error-service-never-started+ 1077)
(defwin32constant +error-duplicate-service-name+ 1078)
(defwin32constant +error-end-of-media+ 1100)
(defwin32constant +error-filemark-detected+ 1101)
(defwin32constant +error-beginning-of-media+ 1102)
(defwin32constant +error-setmark-detected+ 1103)
(defwin32constant +error-no-data-detected+ 1104)
(defwin32constant +error-partition-failure+ 1105)
(defwin32constant +error-invalid-block-length+ 1106)
(defwin32constant +error-device-not-partitioned+ 1107)
(defwin32constant +error-unable-to-lock-media+ 1108)
(defwin32constant +error-unable-to-unload-media+ 1109)
(defwin32constant +error-media-changed+ 1110)
(defwin32constant +error-bus-reset+ 1111)
(defwin32constant +error-no-media-in-drive+ 1112)
(defwin32constant +error-no-unicode-translation+ 1113)
(defwin32constant +error-dll-init-failed+ 1114)
(defwin32constant +error-shutdown-in-progress+ 1115)
(defwin32constant +error-no-shutdown-in-progress+ 1116)
(defwin32constant +error-io-device+ 1117)
(defwin32constant +error-serial-no-device+ 1118)
(defwin32constant +error-irq-busy+ 1119)
(defwin32constant +error-more-writes+ 1120)
(defwin32constant +error-counter-timeout+ 1121)
(defwin32constant +error-floppy-id-mark-not-found+ 1122)
(defwin32constant +error-floppy-wrong-cylinder+ 1123)
(defwin32constant +error-floppy-unknown-error+ 1124)
(defwin32constant +error-floppy-bad-registers+ 1125)
(defwin32constant +error-disk-recalibrate-failed+ 1126)
(defwin32constant +error-disk-operation-failed+ 1127)
(defwin32constant +error-disk-reset-failed+ 1128)
(defwin32constant +error-eom-overflow+ 1129)
(defwin32constant +error-not-enough-server-memory+ 1130)
(defwin32constant +error-possible-deadlock+ 1131)
(defwin32constant +error-mapped-alignment+ 1132)
(defwin32constant +error-set-power-state-vetoed+ 1140)
(defwin32constant +error-set-power-state-failed+ 1141)
(defwin32constant +error-too-many-links+ 1142)
(defwin32constant +error-old-win-version+ 1150)
(defwin32constant +error-app-wrong-os+ 1151)
(defwin32constant +error-single-instance-app+ 1152)
(defwin32constant +error-rmode-app+ 1153)
(defwin32constant +error-invalid-dll+ 1154)
(defwin32constant +error-no-association+ 1155)
(defwin32constant +error-dde-fail+ 1156)
(defwin32constant +error-dll-not-found+ 1157)
(defwin32constant +error-bad-username+ 2202)
(defwin32constant +error-not-connected+ 2250)
(defwin32constant +error-open-files+ 2401)
(defwin32constant +error-active-connections+ 2402)
(defwin32constant +error-device-in-use+ 2404)
(defwin32constant +error-bad-device+ 1200)
(defwin32constant +error-connection-unavail+ 1201)
(defwin32constant +error-device-already-remembered+ 1202)
(defwin32constant +error-no-net-or-bad-path+ 1203)
(defwin32constant +error-bad-provider+ 1204)
(defwin32constant +error-cannot-open-profile+ 1205)
(defwin32constant +error-bad-profile+ 1206)
(defwin32constant +error-not-container+ 1207)
(defwin32constant +error-extended-error+ 1208)
(defwin32constant +error-invalid-groupname+ 1209)
(defwin32constant +error-invalid-computername+ 1210)
(defwin32constant +error-invalid-eventname+ 1211)
(defwin32constant +error-invalid-domainname+ 1212)
(defwin32constant +error-invalid-servicename+ 1213)
(defwin32constant +error-invalid-netname+ 1214)
(defwin32constant +error-invalid-sharename+ 1215)
(defwin32constant +error-invalid-passwordname+ 1216)
(defwin32constant +error-invalid-messagename+ 1217)
(defwin32constant +error-invalid-messagedest+ 1218)
(defwin32constant +error-session-credential-conflict+ 1219)
(defwin32constant +error-remote-session-limit-exceeded+ 1220)
(defwin32constant +error-dup-domainname+ 1221)
(defwin32constant +error-no-network+ 1222)
(defwin32constant +error-cancelled+ 1223)
(defwin32constant +error-user-mapped-file+ 1224)
(defwin32constant +error-connection-refused+ 1225)
(defwin32constant +error-graceful-disconnect+ 1226)
(defwin32constant +error-address-already-associated+ 1227)
(defwin32constant +error-address-not-associated+ 1228)
(defwin32constant +error-connection-invalid+ 1229)
(defwin32constant +error-connection-active+ 1230)
(defwin32constant +error-network-unreachable+ 1231)
(defwin32constant +error-host-unreachable+ 1232)
(defwin32constant +error-protocol-unreachable+ 1233)
(defwin32constant +error-port-unreachable+ 1234)
(defwin32constant +error-request-aborted+ 1235)
(defwin32constant +error-connection-aborted+ 1236)
(defwin32constant +error-retry+ 1237)
(defwin32constant +error-connection-count-limit+ 1238)
(defwin32constant +error-login-time-restriction+ 1239)
(defwin32constant +error-login-wksta-restriction+ 1240)
(defwin32constant +error-incorrect-address+ 1241)
(defwin32constant +error-already-registered+ 1242)
(defwin32constant +error-service-not-found+ 1243)
(defwin32constant +error-not-authenticated+ 1244)
(defwin32constant +error-not-logged-on+ 1245)
(defwin32constant +error-continue+ 1246)
(defwin32constant +error-already-initialized+ 1247)
(defwin32constant +error-no-more-devices+ 1248)
(defwin32constant +error-not-all-assigned+ 1300)
(defwin32constant +error-some-not-mapped+ 1301)
(defwin32constant +error-no-quotas-for-account+ 1302)
(defwin32constant +error-local-user-session-key+ 1303)
(defwin32constant +error-null-lm-password+ 1304)
(defwin32constant +error-unknown-revision+ 1305)
(defwin32constant +error-revision-mismatch+ 1306)
(defwin32constant +error-invalid-owner+ 1307)
(defwin32constant +error-invalid-primary-group+ 1308)
(defwin32constant +error-no-impersonation-token+ 1309)
(defwin32constant +error-cant-disable-mandatory+ 1310)
(defwin32constant +error-no-logon-servers+ 1311)
(defwin32constant +error-no-such-logon-session+ 1312)
(defwin32constant +error-no-such-privilege+ 1313)
(defwin32constant +error-privilege-not-held+ 1314)
(defwin32constant +error-invalid-account-name+ 1315)
(defwin32constant +error-user-exists+ 1316)
(defwin32constant +error-no-such-user+ 1317)
(defwin32constant +error-group-exists+ 1318)
(defwin32constant +error-no-such-group+ 1319)
(defwin32constant +error-member-in-group+ 1320)
(defwin32constant +error-member-not-in-group+ 1321)
(defwin32constant +error-last-admin+ 1322)
(defwin32constant +error-wrong-password+ 1323)
(defwin32constant +error-ill-formed-password+ 1324)
(defwin32constant +error-password-restriction+ 1325)
(defwin32constant +error-logon-failure+ 1326)
(defwin32constant +error-account-restriction+ 1327)
(defwin32constant +error-invalid-logon-hours+ 1328)
(defwin32constant +error-invalid-workstation+ 1329)
(defwin32constant +error-password-expired+ 1330)
(defwin32constant +error-account-disabled+ 1331)
(defwin32constant +error-none-mapped+ 1332)
(defwin32constant +error-too-many-luids-requested+ 1333)
(defwin32constant +error-luids-exhausted+ 1334)
(defwin32constant +error-invalid-sub-authority+ 1335)
(defwin32constant +error-invalid-acl+ 1336)
(defwin32constant +error-invalid-sid+ 1337)
(defwin32constant +error-invalid-security-descr+ 1338)
(defwin32constant +error-bad-inheritance-acl+ 1340)
(defwin32constant +error-server-disabled+ 1341)
(defwin32constant +error-server-not-disabled+ 1342)
(defwin32constant +error-invalid-id-authority+ 1343)
(defwin32constant +error-allotted-space-exceeded+ 1344)
(defwin32constant +error-invalid-group-attributes+ 1345)
(defwin32constant +error-bad-impersonation-level+ 1346)
(defwin32constant +error-cant-open-anonymous+ 1347)
(defwin32constant +error-bad-validation-class+ 1348)
(defwin32constant +error-bad-token-type+ 1349)
(defwin32constant +error-no-security-on-object+ 1350)
(defwin32constant +error-cant-access-domain-info+ 1351)
(defwin32constant +error-invalid-server-state+ 1352)
(defwin32constant +error-invalid-domain-state+ 1353)
(defwin32constant +error-invalid-domain-role+ 1354)
(defwin32constant +error-no-such-domain+ 1355)
(defwin32constant +error-domain-exists+ 1356)
(defwin32constant +error-domain-limit-exceeded+ 1357)
(defwin32constant +error-internal-db-corruption+ 1358)
(defwin32constant +error-internal-error+ 1359)
(defwin32constant +error-generic-not-mapped+ 1360)
(defwin32constant +error-bad-descriptor-format+ 1361)
(defwin32constant +error-not-logon-process+ 1362)
(defwin32constant +error-logon-session-exists+ 1363)
(defwin32constant +error-no-such-package+ 1364)
(defwin32constant +error-bad-logon-session-state+ 1365)
(defwin32constant +error-logon-session-collision+ 1366)
(defwin32constant +error-invalid-logon-type+ 1367)
(defwin32constant +error-cannot-impersonate+ 1368)
(defwin32constant +error-rxact-invalid-state+ 1369)
(defwin32constant +error-rxact-commit-failure+ 1370)
(defwin32constant +error-special-account+ 1371)
(defwin32constant +error-special-group+ 1372)
(defwin32constant +error-special-user+ 1373)
(defwin32constant +error-members-primary-group+ 1374)
(defwin32constant +error-token-already-in-use+ 1375)
(defwin32constant +error-no-such-alias+ 1376)
(defwin32constant +error-member-not-in-alias+ 1377)
(defwin32constant +error-member-in-alias+ 1378)
(defwin32constant +error-alias-exists+ 1379)
(defwin32constant +error-logon-not-granted+ 1380)
(defwin32constant +error-too-many-secrets+ 1381)
(defwin32constant +error-secret-too-long+ 1382)
(defwin32constant +error-internal-db-error+ 1383)
(defwin32constant +error-too-many-context-ids+ 1384)
(defwin32constant +error-logon-type-not-granted+ 1385)
(defwin32constant +error-nt-cross-encryption-required+ 1386)
(defwin32constant +error-no-such-member+ 1387)
(defwin32constant +error-invalid-member+ 1388)
(defwin32constant +error-too-many-sids+ 1389)
(defwin32constant +error-lm-cross-encryption-required+ 1390)
(defwin32constant +error-no-inheritance+ 1391)
(defwin32constant +error-file-corrupt+ 1392)
(defwin32constant +error-disk-corrupt+ 1393)
(defwin32constant +error-no-user-session-key+ 1394)
(defwin32constant +error-license-quota-exceeded+ 1395)
(defwin32constant +error-invalid-window-handle+ 1400)
(defwin32constant +error-invalid-menu-handle+ 1401)
(defwin32constant +error-invalid-cursor-handle+ 1402)
(defwin32constant +error-invalid-accel-handle+ 1403)
(defwin32constant +error-invalid-hook-handle+ 1404)
(defwin32constant +error-invalid-dwp-handle+ 1405)
(defwin32constant +error-tlw-with-wschild+ 1406)
(defwin32constant +error-cannot-find-wnd-class+ 1407)
(defwin32constant +error-window-of-other-thread+ 1408)
(defwin32constant +error-hotkey-already-registered+ 1409)
(defwin32constant +error-class-already-exists+ 1410)
(defwin32constant +error-class-does-not-exist+ 1411)
(defwin32constant +error-class-has-windows+ 1412)
(defwin32constant +error-invalid-index+ 1413)
(defwin32constant +error-invalid-icon-handle+ 1414)
(defwin32constant +error-private-dialog-index+ 1415)
(defwin32constant +error-listbox-id-not-found+ 1416)
(defwin32constant +error-no-wildcard-characters+ 1417)
(defwin32constant +error-clipboard-not-open+ 1418)
(defwin32constant +error-hotkey-not-registered+ 1419)
(defwin32constant +error-window-not-dialog+ 1420)
(defwin32constant +error-control-id-not-found+ 1421)
(defwin32constant +error-invalid-combobox-message+ 1422)
(defwin32constant +error-window-not-combobox+ 1423)
(defwin32constant +error-invalid-edit-height+ 1424)
(defwin32constant +error-dc-not-found+ 1425)
(defwin32constant +error-invalid-hook-filter+ 1426)
(defwin32constant +error-invalid-filter-proc+ 1427)
(defwin32constant +error-hook-needs-hmod+ 1428)
(defwin32constant +error-global-only-hook+ 1429)
(defwin32constant +error-journal-hook-set+ 1430)
(defwin32constant +error-hook-not-installed+ 1431)
(defwin32constant +error-invalid-lb-message+ 1432)
(defwin32constant +error-setcount-on-bad-lb+ 1433)
(defwin32constant +error-lb-without-tabstops+ 1434)
(defwin32constant +error-destroy-object-of-other-thread+ 1435)
(defwin32constant +error-child-window-menu+ 1436)
(defwin32constant +error-no-system-menu+ 1437)
(defwin32constant +error-invalid-msgbox-style+ 1438)
(defwin32constant +error-invalid-spi-value+ 1439)
(defwin32constant +error-screen-already-locked+ 1440)
(defwin32constant +error-hwnds-have-diff-parent+ 1441)
(defwin32constant +error-not-child-window+ 1442)
(defwin32constant +error-invalid-gw-command+ 1443)
(defwin32constant +error-invalid-thread-id+ 1444)
(defwin32constant +error-non-mdichild-window+ 1445)
(defwin32constant +error-popup-already-active+ 1446)
(defwin32constant +error-no-scrollbars+ 1447)
(defwin32constant +error-invalid-scrollbar-range+ 1448)
(defwin32constant +error-invalid-showwin-command+ 1449)
(defwin32constant +error-no-system-resources+ 1450)
(defwin32constant +error-nonpaged-system-resources+ 1451)
(defwin32constant +error-paged-system-resources+ 1452)
(defwin32constant +error-working-set-quota+ 1453)
(defwin32constant +error-pagefile-quota+ 1454)
(defwin32constant +error-commitment-limit+ 1455)
(defwin32constant +error-menu-item-not-found+ 1456)
(defwin32constant +error-eventlog-file-corrupt+ 1500)
(defwin32constant +error-eventlog-cant-start+ 1501)
(defwin32constant +error-log-file-full+ 1502)
(defwin32constant +error-eventlog-file-changed+ 1503)
(defwin32constant +rpc-s-invalid-string-binding+ 1700)
(defwin32constant +rpc-s-wrong-kind-of-binding+ 1701)
(defwin32constant +rpc-s-invalid-binding+ 1702)
(defwin32constant +rpc-s-protseq-not-supported+ 1703)
(defwin32constant +rpc-s-invalid-rpc-protseq+ 1704)
(defwin32constant +rpc-s-invalid-string-uuid+ 1705)
(defwin32constant +rpc-s-invalid-endpoint-format+ 1706)
(defwin32constant +rpc-s-invalid-net-addr+ 1707)
(defwin32constant +rpc-s-no-endpoint-found+ 1708)
(defwin32constant +rpc-s-invalid-timeout+ 1709)
(defwin32constant +rpc-s-object-not-found+ 1710)
(defwin32constant +rpc-s-already-registered+ 1711)
(defwin32constant +rpc-s-type-already-registered+ 1712)
(defwin32constant +rpc-s-already-listening+ 1713)
(defwin32constant +rpc-s-no-protseqs-registered+ 1714)
(defwin32constant +rpc-s-not-listening+ 1715)
(defwin32constant +rpc-s-unknown-mgr-type+ 1716)
(defwin32constant +rpc-s-unknown-if+ 1717)
(defwin32constant +rpc-s-no-bindings+ 1718)
(defwin32constant +rpc-s-no-protseqs+ 1719)
(defwin32constant +rpc-s-cant-create-endpoint+ 1720)
(defwin32constant +rpc-s-out-of-resources+ 1721)
(defwin32constant +rpc-s-server-unavailable+ 1722)
(defwin32constant +rpc-s-server-too-busy+ 1723)
(defwin32constant +rpc-s-invalid-network-options+ 1724)
(defwin32constant +rpc-s-no-call-active+ 1725)
(defwin32constant +rpc-s-call-failed+ 1726)
(defwin32constant +rpc-s-call-failed-dne+ 1727)
(defwin32constant +rpc-s-protocol-error+ 1728)
(defwin32constant +rpc-s-unsupported-trans-syn+ 1730)
(defwin32constant +rpc-s-unsupported-type+ 1732)
(defwin32constant +rpc-s-invalid-tag+ 1733)
(defwin32constant +rpc-s-invalid-bound+ 1734)
(defwin32constant +rpc-s-no-entry-name+ 1735)
(defwin32constant +rpc-s-invalid-name-syntax+ 1736)
(defwin32constant +rpc-s-unsupported-name-syntax+ 1737)
(defwin32constant +rpc-s-uuid-no-address+ 1739)
(defwin32constant +rpc-s-duplicate-endpoint+ 1740)
(defwin32constant +rpc-s-unknown-authn-type+ 1741)
(defwin32constant +rpc-s-max-calls-too-small+ 1742)
(defwin32constant +rpc-s-string-too-long+ 1743)
(defwin32constant +rpc-s-protseq-not-found+ 1744)
(defwin32constant +rpc-s-procnum-out-of-range+ 1745)
(defwin32constant +rpc-s-binding-has-no-auth+ 1746)
(defwin32constant +rpc-s-unknown-authn-service+ 1747)
(defwin32constant +rpc-s-unknown-authn-level+ 1748)
(defwin32constant +rpc-s-invalid-auth-identity+ 1749)
(defwin32constant +rpc-s-unknown-authz-service+ 1750)
(defwin32constant +ept-s-invalid-entry+ 1751)
(defwin32constant +ept-s-cant-perform-op+ 1752)
(defwin32constant +ept-s-not-registered+ 1753)
(defwin32constant +rpc-s-nothing-to-export+ 1754)
(defwin32constant +rpc-s-incomplete-name+ 1755)
(defwin32constant +rpc-s-invalid-vers-option+ 1756)
(defwin32constant +rpc-s-no-more-members+ 1757)
(defwin32constant +rpc-s-not-all-objs-unexported+ 1758)
(defwin32constant +rpc-s-interface-not-found+ 1759)
(defwin32constant +rpc-s-entry-already-exists+ 1760)
(defwin32constant +rpc-s-entry-not-found+ 1761)
(defwin32constant +rpc-s-name-service-unavailable+ 1762)
(defwin32constant +rpc-s-invalid-naf-id+ 1763)
(defwin32constant +rpc-s-cannot-support+ 1764)
(defwin32constant +rpc-s-no-context-available+ 1765)
(defwin32constant +rpc-s-internal-error+ 1766)
(defwin32constant +rpc-s-zero-divide+ 1767)
(defwin32constant +rpc-s-address-error+ 1768)
(defwin32constant +rpc-s-fp-div-zero+ 1769)
(defwin32constant +rpc-s-fp-underflow+ 1770)
(defwin32constant +rpc-s-fp-overflow+ 1771)
(defwin32constant +rpc-x-no-more-entries+ 1772)
(defwin32constant +rpc-x-ss-char-trans-open-fail+ 1773)
(defwin32constant +rpc-x-ss-char-trans-short-file+ 1774)
(defwin32constant +rpc-x-ss-in-null-context+ 1775)
(defwin32constant +rpc-x-ss-context-damaged+ 1777)
(defwin32constant +rpc-x-ss-handles-mismatch+ 1778)
(defwin32constant +rpc-x-ss-cannot-get-call-handle+ 1779)
(defwin32constant +rpc-x-null-ref-pointer+ 1780)
(defwin32constant +rpc-x-enum-value-out-of-range+ 1781)
(defwin32constant +rpc-x-byte-count-too-small+ 1782)
(defwin32constant +rpc-x-bad-stub-data+ 1783)
(defwin32constant +error-invalid-user-buffer+ 1784)
(defwin32constant +error-unrecognized-media+ 1785)
(defwin32constant +error-no-trust-lsa-secret+ 1786)
(defwin32constant +error-no-trust-sam-account+ 1787)
(defwin32constant +error-trusted-domain-failure+ 1788)
(defwin32constant +error-trusted-relationship-failure+ 1789)
(defwin32constant +error-trust-failure+ 1790)
(defwin32constant +rpc-s-call-in-progress+ 1791)
(defwin32constant +error-netlogon-not-started+ 1792)
(defwin32constant +error-account-expired+ 1793)
(defwin32constant +error-redirector-has-open-handles+ 1794)
(defwin32constant +error-printer-driver-already-installed+ 1795)
(defwin32constant +error-unknown-port+ 1796)
(defwin32constant +error-unknown-printer-driver+ 1797)
(defwin32constant +error-unknown-printprocessor+ 1798)
(defwin32constant +error-invalid-separator-file+ 1799)
(defwin32constant +error-invalid-priority+ 1800)
(defwin32constant +error-invalid-printer-name+ 1801)
(defwin32constant +error-printer-already-exists+ 1802)
(defwin32constant +error-invalid-printer-command+ 1803)
(defwin32constant +error-invalid-datatype+ 1804)
(defwin32constant +error-invalid-environment+ 1805)
(defwin32constant +rpc-s-no-more-bindings+ 1806)
(defwin32constant +error-nologon-interdomain-trust-account+ 1807)
(defwin32constant +error-nologon-workstation-trust-account+ 1808)
(defwin32constant +error-nologon-server-trust-account+ 1809)
(defwin32constant +error-domain-trust-inconsistent+ 1810)
(defwin32constant +error-server-has-open-handles+ 1811)
(defwin32constant +error-resource-data-not-found+ 1812)
(defwin32constant +error-resource-type-not-found+ 1813)
(defwin32constant +error-resource-name-not-found+ 1814)
(defwin32constant +error-resource-lang-not-found+ 1815)
(defwin32constant +error-not-enough-quota+ 1816)
(defwin32constant +rpc-s-no-interfaces+ 1817)
(defwin32constant +rpc-s-call-cancelled+ 1818)
(defwin32constant +rpc-s-binding-incomplete+ 1819)
(defwin32constant +rpc-s-comm-failure+ 1820)
(defwin32constant +rpc-s-unsupported-authn-level+ 1821)
(defwin32constant +rpc-s-no-princ-name+ 1822)
(defwin32constant +rpc-s-not-rpc-error+ 1823)
(defwin32constant +rpc-s-uuid-local-only+ 1824)
(defwin32constant +rpc-s-sec-pkg-error+ 1825)
(defwin32constant +rpc-s-not-cancelled+ 1826)
(defwin32constant +rpc-x-invalid-es-action+ 1827)
(defwin32constant +rpc-x-wrong-es-version+ 1828)
(defwin32constant +rpc-x-wrong-stub-version+ 1829)
(defwin32constant +rpc-s-group-member-not-found+ 1898)
(defwin32constant +ept-s-cant-create+ 1899)
(defwin32constant +rpc-s-invalid-object+ 1900)
(defwin32constant +error-invalid-time+ 1901)
(defwin32constant +error-invalid-form-name+ 1902)
(defwin32constant +error-invalid-form-size+ 1903)
(defwin32constant +error-already-waiting+ 1904)
(defwin32constant +error-printer-deleted+ 1905)
(defwin32constant +error-invalid-printer-state+ 1906)
(defwin32constant +error-password-must-change+ 1907)
(defwin32constant +error-domain-controller-not-found+ 1908)
(defwin32constant +error-account-locked-out+ 1909)
(defwin32constant +error-no-browser-servers-found+ 6118)
(defwin32constant +error-invalid-pixel-format+ 2000)
(defwin32constant +error-bad-driver+ 2001)
(defwin32constant +error-invalid-window-style+ 2002)
(defwin32constant +error-metafile-not-supported+ 2003)
(defwin32constant +error-transform-not-supported+ 2004)
(defwin32constant +error-clipping-not-supported+ 2005)
(defwin32constant +error-unknown-print-monitor+ 3000)
(defwin32constant +error-printer-driver-in-use+ 3001)
(defwin32constant +error-spool-file-not-found+ 3002)
(defwin32constant +error-spl-no-startdoc+ 3003)
(defwin32constant +error-spl-no-addjob+ 3004)
(defwin32constant +error-print-processor-already-installed+ 3005)
(defwin32constant +error-print-monitor-already-installed+ 3006)
(defwin32constant +error-wins-internal+ 4000)
(defwin32constant +error-can-not-del-local-wins+ 4001)
(defwin32constant +error-static-init+ 4002)
(defwin32constant +error-inc-backup+ 4003)
(defwin32constant +error-full-backup+ 4004)
(defwin32constant +error-rec-non-existent+ 4005)
(defwin32constant +error-rpl-not-allowed+ 4006)
(defwin32constant +severity-success+ 0)
(defwin32constant +severity-error+ 1)
(defwin32constant +facility-windows+ 8)
(defwin32constant +facility-storage+ 3)
(defwin32constant +facility-rpc+ 1)
(defwin32constant +facility-win32+ 7)
(defwin32constant +facility-control+ 10)
(defwin32constant +facility-null+ 0)
(defwin32constant +facility-itf+ 4)
(defwin32constant +facility-dispatch+ 2)

(defwin32constant +s-ok+ #x00000000)
(defwin32constant +s-false+ #x00000001)
(defwin32constant +noerror+ +s-ok+)
(defwin32constant +e-unexpected+ #x8000ffff)
(defwin32constant +e-notimpl+ #x80004001)
(defwin32constant +e-outofmemory+ #x8007000e)
(defwin32constant +e-invalidarg+ #x80070057)
(defwin32constant +e-nointerface+ #x80004002)
(defwin32constant +e-pointer+ #x80004003)
(defwin32constant +e-handle+ #x80070006)
(defwin32constant +e-abort+ #x80004004)
(defwin32constant +e-fail+ #x80004005)
(defwin32constant +e-accessdenied+ #x80070005)
(defwin32constant +e-pending+ #x8000000a)
(defwin32constant +co-e-init-tls+ #x80004006)
(defwin32constant +co-e-init-shared-allocator+ #x80004007)
(defwin32constant +co-e-init-memory-allocator+ #x80004008)
(defwin32constant +co-e-init-class-cache+ #x80004009)
(defwin32constant +co-e-init-rpc-channel+ #x8000400a)
(defwin32constant +co-e-init-tls-set-channel-control+ #x8000400b)
(defwin32constant +co-e-init-tls-channel-control+ #x8000400c)
(defwin32constant +co-e-init-unaccepted-user-allocator+ #x8000400d)
(defwin32constant +co-e-init-scm-mutex-exists+ #x8000400e)
(defwin32constant +co-e-init-scm-file-mapping-exists+ #x8000400f)
(defwin32constant +co-e-init-scm-map-view-of-file+ #x80004010)
(defwin32constant +co-e-init-scm-exec-failure+ #x80004011)
(defwin32constant +co-e-init-only-single-threaded+ #x80004012)
(defwin32constant +ole-e-first+ #x80040000)
(defwin32constant +ole-e-last+ #x800400ff)
(defwin32constant +ole-s-first+ #x00040000)
(defwin32constant +ole-s-last+ #x000400ff)
(defwin32constant +ole-e-oleverb+ #x80040000)
(defwin32constant +ole-e-advf+ #x80040001)
(defwin32constant +ole-e-enum-nomore+ #x80040002)
(defwin32constant +ole-e-advisenotsupported+ #x80040003)
(defwin32constant +ole-e-noconnection+ #x80040004)
(defwin32constant +ole-e-notrunning+ #x80040005)
(defwin32constant +ole-e-nocache+ #x80040006)
(defwin32constant +ole-e-blank+ #x80040007)
(defwin32constant +ole-e-classdiff+ #x80040008)
(defwin32constant +ole-e-cant-getmoniker+ #x80040009)
(defwin32constant +ole-e-cant-bindtosource+ #x8004000a)
(defwin32constant +ole-e-static+ #x8004000b)
(defwin32constant +ole-e-promptsavecancelled+ #x8004000c)
(defwin32constant +ole-e-invalidrect+ #x8004000d)
(defwin32constant +ole-e-wrongcompobj+ #x8004000e)
(defwin32constant +ole-e-invalidhwnd+ #x8004000f)
(defwin32constant +ole-e-not-inplaceactive+ #x80040010)
(defwin32constant +ole-e-cantconvert+ #x80040011)
(defwin32constant +ole-e-nostorage+ #x80040012)
(defwin32constant +dv-e-formatetc+ #x80040064)
(defwin32constant +dv-e-dvtargetdevice+ #x80040065)
(defwin32constant +dv-e-stgmedium+ #x80040066)
(defwin32constant +dv-e-statdata+ #x80040067)
(defwin32constant +dv-e-lindex+ #x80040068)
(defwin32constant +dv-e-tymed+ #x80040069)
(defwin32constant +dv-e-clipformat+ #x8004006a)
(defwin32constant +dv-e-dvaspect+ #x8004006b)
(defwin32constant +dv-e-dvtargetdevice-size+ #x8004006c)
(defwin32constant +dv-e-noiviewobject+ #x8004006d)
(defwin32constant +dragdrop-e-first+ #x80040100)
(defwin32constant +dragdrop-e-last+ #x8004010f)
(defwin32constant +dragdrop-s-first+ #x00040100)
(defwin32constant +dragdrop-s-last+ #x0004010f)
(defwin32constant +dragdrop-e-notregistered+ #x80040100)
(defwin32constant +dragdrop-e-alreadyregistered+ #x80040101)
(defwin32constant +dragdrop-e-invalidhwnd+ #x80040102)
(defwin32constant +classfactory-e-first+ #x80040110)
(defwin32constant +classfactory-e-last+ #x8004011f)
(defwin32constant +classfactory-s-first+ #x00040110)
(defwin32constant +classfactory-s-last+ #x0004011f)
(defwin32constant +class-e-noaggregation+ #x80040110)
(defwin32constant +class-e-classnotavailable+ #x80040111)
(defwin32constant +marshal-e-first+ #x80040120)
(defwin32constant +marshal-e-last+ #x8004012f)
(defwin32constant +marshal-s-first+ #x00040120)
(defwin32constant +marshal-s-last+ #x0004012f)
(defwin32constant +data-e-first+ #x80040130)
(defwin32constant +data-e-last+ #x8004013f)
(defwin32constant +data-s-first+ #x00040130)
(defwin32constant +data-s-last+ #x0004013f)
(defwin32constant +view-e-first+ #x80040140)
(defwin32constant +view-e-last+ #x8004014f)
(defwin32constant +view-s-first+ #x00040140)
(defwin32constant +view-s-last+ #x0004014f)
(defwin32constant +view-e-draw+ #x80040140)
(defwin32constant +regdb-e-first+ #x80040150)
(defwin32constant +regdb-e-last+ #x8004015f)
(defwin32constant +regdb-s-first+ #x00040150)
(defwin32constant +regdb-s-last+ #x0004015f)
(defwin32constant +regdb-e-readregdb+ #x80040150)
(defwin32constant +regdb-e-writeregdb+ #x80040151)
(defwin32constant +regdb-e-keymissing+ #x80040152)
(defwin32constant +regdb-e-invalidvalue+ #x80040153)
(defwin32constant +regdb-e-classnotreg+ #x80040154)
(defwin32constant +regdb-e-iidnotreg+ #x80040155)
(defwin32constant +cache-e-first+ #x80040170)
(defwin32constant +cache-e-last+ #x8004017f)
(defwin32constant +cache-s-first+ #x00040170)
(defwin32constant +cache-s-last+ #x0004017f)
(defwin32constant +cache-e-nocache-updated+ #x80040170)
(defwin32constant +oleobj-e-first+ #x80040180)
(defwin32constant +oleobj-e-last+ #x8004018f)
(defwin32constant +oleobj-s-first+ #x00040180)
(defwin32constant +oleobj-s-last+ #x0004018f)
(defwin32constant +oleobj-e-noverbs+ #x80040180)
(defwin32constant +oleobj-e-invalidverb+ #x80040181)
(defwin32constant +clientsite-e-first+ #x80040190)
(defwin32constant +clientsite-e-last+ #x8004019f)
(defwin32constant +clientsite-s-first+ #x00040190)
(defwin32constant +clientsite-s-last+ #x0004019f)
(defwin32constant +inplace-e-notundoable+ #x800401a0)
(defwin32constant +inplace-e-notoolspace+ #x800401a1)
(defwin32constant +inplace-e-first+ #x800401a0)
(defwin32constant +inplace-e-last+ #x800401af)
(defwin32constant +inplace-s-first+ #x000401a0)
(defwin32constant +inplace-s-last+ #x000401af)
(defwin32constant +enum-e-first+ #x800401b0)
(defwin32constant +enum-e-last+ #x800401bf)
(defwin32constant +enum-s-first+ #x000401b0)
(defwin32constant +enum-s-last+ #x000401bf)
(defwin32constant +convert10-e-first+ #x800401c0)
(defwin32constant +convert10-e-last+ #x800401cf)
(defwin32constant +convert10-s-first+ #x000401c0)
(defwin32constant +convert10-s-last+ #x000401cf)
(defwin32constant +convert10-e-olestream-get+ #x800401c0)
(defwin32constant +convert10-e-olestream-put+ #x800401c1)
(defwin32constant +convert10-e-olestream-fmt+ #x800401c2)
(defwin32constant +convert10-e-olestream-bitmap-to-dib+ #x800401c3)
(defwin32constant +convert10-e-stg-fmt+ #x800401c4)
(defwin32constant +convert10-e-stg-no-std-stream+ #x800401c5)
(defwin32constant +convert10-e-stg-dib-to-bitmap+ #x800401c6)
(defwin32constant +clipbrd-e-first+ #x800401d0)
(defwin32constant +clipbrd-e-last+ #x800401df)
(defwin32constant +clipbrd-s-first+ #x000401d0)
(defwin32constant +clipbrd-s-last+ #x000401df)
(defwin32constant +clipbrd-e-cant-open+ #x800401d0)
(defwin32constant +clipbrd-e-cant-empty+ #x800401d1)
(defwin32constant +clipbrd-e-cant-set+ #x800401d2)
(defwin32constant +clipbrd-e-bad-data+ #x800401d3)
(defwin32constant +clipbrd-e-cant-close+ #x800401d4)
(defwin32constant +mk-e-first+ #x800401e0)
(defwin32constant +mk-e-last+ #x800401ef)
(defwin32constant +mk-s-first+ #x000401e0)
(defwin32constant +mk-s-last+ #x000401ef)
(defwin32constant +mk-e-connectmanually+ #x800401e0)
(defwin32constant +mk-e-exceededdeadline+ #x800401e1)
(defwin32constant +mk-e-needgeneric+ #x800401e2)
(defwin32constant +mk-e-unavailable+ #x800401e3)
(defwin32constant +mk-e-syntax+ #x800401e4)
(defwin32constant +mk-e-noobject+ #x800401e5)
(defwin32constant +mk-e-invalidextension+ #x800401e6)
(defwin32constant +mk-e-intermediateinterfacenotsupported+ #x800401e7)
(defwin32constant +mk-e-notbindable+ #x800401e8)
(defwin32constant +mk-e-notbound+ #x800401e9)
(defwin32constant +mk-e-cantopenfile+ #x800401ea)
(defwin32constant +mk-e-mustbotheruser+ #x800401eb)
(defwin32constant +mk-e-noinverse+ #x800401ec)
(defwin32constant +mk-e-nostorage+ #x800401ed)
(defwin32constant +mk-e-noprefix+ #x800401ee)
(defwin32constant +mk-e-enumeration-failed+ #x800401ef)
(defwin32constant +co-e-first+ #x800401f0)
(defwin32constant +co-e-last+ #x800401ff)
(defwin32constant +co-s-first+ #x000401f0)
(defwin32constant +co-s-last+ #x000401ff)
(defwin32constant +co-e-notinitialized+ #x800401f0)
(defwin32constant +co-e-alreadyinitialized+ #x800401f1)
(defwin32constant +co-e-cantdetermineclass+ #x800401f2)
(defwin32constant +co-e-classstring+ #x800401f3)
(defwin32constant +co-e-iidstring+ #x800401f4)
(defwin32constant +co-e-appnotfound+ #x800401f5)
(defwin32constant +co-e-appsingleuse+ #x800401f6)
(defwin32constant +co-e-errorinapp+ #x800401f7)
(defwin32constant +co-e-dllnotfound+ #x800401f8)
(defwin32constant +co-e-errorindll+ #x800401f9)
(defwin32constant +co-e-wrongosforapp+ #x800401fa)
(defwin32constant +co-e-objnotreg+ #x800401fb)
(defwin32constant +co-e-objisreg+ #x800401fc)
(defwin32constant +co-e-objnotconnected+ #x800401fd)
(defwin32constant +co-e-appdidntreg+ #x800401fe)
(defwin32constant +co-e-released+ #x800401ff)
(defwin32constant +ole-s-usereg+ #x00040000)
(defwin32constant +ole-s-static+ #x00040001)
(defwin32constant +ole-s-mac-clipformat+ #x00040002)
(defwin32constant +dragdrop-s-drop+ #x00040100)
(defwin32constant +dragdrop-s-cancel+ #x00040101)
(defwin32constant +dragdrop-s-usedefaultcursors+ #x00040102)
(defwin32constant +data-s-sameformatetc+ #x00040130)
(defwin32constant +view-s-already-frozen+ #x00040140)
(defwin32constant +cache-s-formatetc-notsupported+ #x00040170)
(defwin32constant +cache-s-samecache+ #x00040171)
(defwin32constant +cache-s-somecaches-notupdated+ #x00040172)
(defwin32constant +oleobj-s-invalidverb+ #x00040180)
(defwin32constant +oleobj-s-cannot-doverb-now+ #x00040181)
(defwin32constant +oleobj-s-invalidhwnd+ #x00040182)
(defwin32constant +inplace-s-truncated+ #x000401a0)
(defwin32constant +convert10-s-no-presentation+ #x000401c0)
(defwin32constant +mk-s-reduced-to-self+ #x000401e2)
(defwin32constant +mk-s-me+ #x000401e4)
(defwin32constant +mk-s-him+ #x000401e5)
(defwin32constant +mk-s-us+ #x000401e6)
(defwin32constant +mk-s-monikeralreadyregistered+ #x000401e7)
(defwin32constant +co-e-class-create-failed+ #x80080001)
(defwin32constant +co-e-scm-error+ #x80080002)
(defwin32constant +co-e-scm-rpc-failure+ #x80080003)
(defwin32constant +co-e-bad-path+ #x80080004)
(defwin32constant +co-e-server-exec-failure+ #x80080005)
(defwin32constant +co-e-objsrv-rpc-failure+ #x80080006)
(defwin32constant +mk-e-no-normalized+ #x80080007)
(defwin32constant +co-e-server-stopping+ #x80080008)
(defwin32constant +mem-e-invalid-root+ #x80080009)
(defwin32constant +mem-e-invalid-link+ #x80080010)
(defwin32constant +mem-e-invalid-size+ #x80080011)
(defwin32constant +disp-e-unknowninterface+ #x80020001)
(defwin32constant +disp-e-membernotfound+ #x80020003)
(defwin32constant +disp-e-paramnotfound+ #x80020004)
(defwin32constant +disp-e-typemismatch+ #x80020005)
(defwin32constant +disp-e-unknownname+ #x80020006)
(defwin32constant +disp-e-nonamedargs+ #x80020007)
(defwin32constant +disp-e-badvartype+ #x80020008)
(defwin32constant +disp-e-exception+ #x80020009)
(defwin32constant +disp-e-overflow+ #x8002000a)
(defwin32constant +disp-e-badindex+ #x8002000b)
(defwin32constant +disp-e-unknownlcid+ #x8002000c)
(defwin32constant +disp-e-arrayislocked+ #x8002000d)
(defwin32constant +disp-e-badparamcount+ #x8002000e)
(defwin32constant +disp-e-paramnotoptional+ #x8002000f)
(defwin32constant +disp-e-badcallee+ #x80020010)
(defwin32constant +disp-e-notacollection+ #x80020011)
(defwin32constant +type-e-buffertoosmall+ #x80028016)
(defwin32constant +type-e-invdataread+ #x80028018)
(defwin32constant +type-e-unsupformat+ #x80028019)
(defwin32constant +type-e-registryaccess+ #x8002801c)
(defwin32constant +type-e-libnotregistered+ #x8002801d)
(defwin32constant +type-e-undefinedtype+ #x80028027)
(defwin32constant +type-e-qualifiednamedisallowed+ #x80028028)
(defwin32constant +type-e-invalidstate+ #x80028029)
(defwin32constant +type-e-wrongtypekind+ #x8002802a)
(defwin32constant +type-e-elementnotfound+ #x8002802b)
(defwin32constant +type-e-ambiguousname+ #x8002802c)
(defwin32constant +type-e-nameconflict+ #x8002802d)
(defwin32constant +type-e-unknownlcid+ #x8002802e)
(defwin32constant +type-e-dllfunctionnotfound+ #x8002802f)
(defwin32constant +type-e-badmodulekind+ #x800288bd)
(defwin32constant +type-e-sizetoobig+ #x800288c5)
(defwin32constant +type-e-duplicateid+ #x800288c6)
(defwin32constant +type-e-invalidid+ #x800288cf)
(defwin32constant +type-e-typemismatch+ #x80028ca0)
(defwin32constant +type-e-outofbounds+ #x80028ca1)
(defwin32constant +type-e-ioerror+ #x80028ca2)
(defwin32constant +type-e-cantcreatetmpfile+ #x80028ca3)
(defwin32constant +type-e-cantloadlibrary+ #x80029c4a)
(defwin32constant +type-e-inconsistentpropfuncs+ #x80029c83)
(defwin32constant +type-e-circulartype+ #x80029c84)
(defwin32constant +stg-e-invalidfunction+ #x80030001)
(defwin32constant +stg-e-filenotfound+ #x80030002)
(defwin32constant +stg-e-pathnotfound+ #x80030003)
(defwin32constant +stg-e-toomanyopenfiles+ #x80030004)
(defwin32constant +stg-e-accessdenied+ #x80030005)
(defwin32constant +stg-e-invalidhandle+ #x80030006)
(defwin32constant +stg-e-insufficientmemory+ #x80030008)
(defwin32constant +stg-e-invalidpointer+ #x80030009)
(defwin32constant +stg-e-nomorefiles+ #x80030012)
(defwin32constant +stg-e-diskiswriteprotected+ #x80030013)
(defwin32constant +stg-e-seekerror+ #x80030019)
(defwin32constant +stg-e-writefault+ #x8003001d)
(defwin32constant +stg-e-readfault+ #x8003001e)
(defwin32constant +stg-e-shareviolation+ #x80030020)
(defwin32constant +stg-e-lockviolation+ #x80030021)
(defwin32constant +stg-e-filealreadyexists+ #x80030050)
(defwin32constant +stg-e-invalidparameter+ #x80030057)
(defwin32constant +stg-e-mediumfull+ #x80030070)
(defwin32constant +stg-e-abnormalapiexit+ #x800300fa)
(defwin32constant +stg-e-invalidheader+ #x800300fb)
(defwin32constant +stg-e-invalidname+ #x800300fc)
(defwin32constant +stg-e-unknown+ #x800300fd)
(defwin32constant +stg-e-unimplementedfunction+ #x800300fe)
(defwin32constant +stg-e-invalidflag+ #x800300ff)
(defwin32constant +stg-e-inuse+ #x80030100)
(defwin32constant +stg-e-notcurrent+ #x80030101)
(defwin32constant +stg-e-reverted+ #x80030102)
(defwin32constant +stg-e-cantsave+ #x80030103)
(defwin32constant +stg-e-oldformat+ #x80030104)
(defwin32constant +stg-e-olddll+ #x80030105)
(defwin32constant +stg-e-sharerequired+ #x80030106)
(defwin32constant +stg-e-notfilebasedstorage+ #x80030107)
(defwin32constant +stg-e-extantmarshallings+ #x80030108)
(defwin32constant +stg-s-converted+ #x00030200)
(defwin32constant +rpc-e-call-rejected+ #x80010001)
(defwin32constant +rpc-e-call-canceled+ #x80010002)
(defwin32constant +rpc-e-cantpost-insendcall+ #x80010003)
(defwin32constant +rpc-e-cantcallout-inasynccall+ #x80010004)
(defwin32constant +rpc-e-cantcallout-inexternalcall+ #x80010005)
(defwin32constant +rpc-e-connection-terminated+ #x80010006)
(defwin32constant +rpc-e-server-died+ #x80010007)
(defwin32constant +rpc-e-client-died+ #x80010008)
(defwin32constant +rpc-e-invalid-datapacket+ #x80010009)
(defwin32constant +rpc-e-canttransmit-call+ #x8001000a)
(defwin32constant +rpc-e-client-cantmarshal-data+ #x8001000b)
(defwin32constant +rpc-e-client-cantunmarshal-data+ #x8001000c)
(defwin32constant +rpc-e-server-cantmarshal-data+ #x8001000d)
(defwin32constant +rpc-e-server-cantunmarshal-data+ #x8001000e)
(defwin32constant +rpc-e-invalid-data+ #x8001000f)
(defwin32constant +rpc-e-invalid-parameter+ #x80010010)
(defwin32constant +rpc-e-cantcallout-again+ #x80010011)
(defwin32constant +rpc-e-server-died-dne+ #x80010012)
(defwin32constant +rpc-e-sys-call-failed+ #x80010100)
(defwin32constant +rpc-e-out-of-resources+ #x80010101)
(defwin32constant +rpc-e-attempted-multithread+ #x80010102)
(defwin32constant +rpc-e-not-registered+ #x80010103)
(defwin32constant +rpc-e-fault+ #x80010104)
(defwin32constant +rpc-e-serverfault+ #x80010105)
(defwin32constant +rpc-e-changed-mode+ #x80010106)
(defwin32constant +rpc-e-invalidmethod+ #x80010107)
(defwin32constant +rpc-e-disconnected+ #x80010108)
(defwin32constant +rpc-e-retry+ #x80010109)
(defwin32constant +rpc-e-servercall-retrylater+ #x8001010a)
(defwin32constant +rpc-e-servercall-rejected+ #x8001010b)
(defwin32constant +rpc-e-invalid-calldata+ #x8001010c)
(defwin32constant +rpc-e-cantcallout-ininputsynccall+ #x8001010d)
(defwin32constant +rpc-e-wrong-thread+ #x8001010e)
(defwin32constant +rpc-e-thread-not-init+ #x8001010f)
(defwin32constant +rpc-e-unexpected+ #x8001ffff)

(defwin32constant +nte-bad-uid+ #x80090001)
(defwin32constant +nte-bad-hash+ #x80090002)
(defwin32constant +nte-bad-key+ #x80090003)
(defwin32constant +nte-bad-len+ #x80090004)
(defwin32constant +nte-bad-data+ #x80090005)
(defwin32constant +nte-bad-signature+ #x80090006)
(defwin32constant +nte-bad-ver+ #x80090007)
(defwin32constant +nte-bad-algid+ #x80090008)
(defwin32constant +nte-bad-flags+ #x80090009)
(defwin32constant +nte-bad-type+ #x8009000a)
(defwin32constant +nte-bad-key-state+ #x8009000b)
(defwin32constant +nte-bad-hash-state+ #x8009000c)
(defwin32constant +nte-no-key+ #x8009000d)
(defwin32constant +nte-no-memory+ #x8009000e)
(defwin32constant +nte-exists+ #x8009000f)
(defwin32constant +nte-perm+ #x80090010)
(defwin32constant +nte-not-found+ #x80090011)
(defwin32constant +nte-double-encrypt+ #x80090012)
(defwin32constant +nte-bad-provider+ #x80090013)
(defwin32constant +nte-bad-prov-type+ #x80090014)
(defwin32constant +nte-bad-public-key+ #x80090015)
(defwin32constant +nte-bad-keyset+ #x80090016)
(defwin32constant +nte-prov-type-not-def+ #x80090017)
(defwin32constant +nte-prov-type-entry-bad+ #x80090018)
(defwin32constant +nte-keyset-not-def+ #x80090019)
(defwin32constant +nte-keyset-entry-bad+ #x8009001a)
(defwin32constant +nte-prov-type-no-match+ #x8009001b)
(defwin32constant +nte-signature-file-bad+ #x8009001c)
(defwin32constant +nte-provider-dll-fail+ #x8009001d)
(defwin32constant +nte-prov-dll-not-found+ #x8009001e)
(defwin32constant +nte-bad-keyset-param+ #x8009001f)
(defwin32constant +nte-fail+ #x80090020)
(defwin32constant +nte-sys-err+ #x80090021)

(defwin32constant +pipe-access-duplex+ 3)
(defwin32constant +pipe-access-inbound+ 1)
(defwin32constant +pipe-access-outbound+ 2)

(defwin32constant +pipe-client-end+ 0)
(defwin32constant +pipe-server-end+ 1)

(defwin32constant +pipe-wait+ 0)
(defwin32constant +pipe-nowait+ 1)
(defwin32constant +pipe-readmode-byte+ 0)
(defwin32constant +pipe-readmode-message+ 2)
(defwin32constant +pipe-type-byte+ 0)
(defwin32constant +pipe-type-message+ 4)
(defwin32constant +pipe-accept-remote-clients+ 0)
(defwin32constant +pipe-reject-remote-clients+ 0)

(defwin32constant +pipe-unlimited-instances+ 255)

(defwin32constant +nmpwait-wait-forever+ #xffffffff)
(defwin32constant +nmpwait-nowait+ #x00000001)
(defwin32constant +nmpwait-use-default-wait+ #x00000000)

(defwin32struct unicode-string
  (length ushort)
  (maximum-length ushort)
  (buffer pwstr))

(defwin32struct luid
  (low-part dword)
  (high-part long))

(defwin32struct bsminfo
  (size uint)
  (hdesk hdesk)
  (hwnd hwnd)
  (luid luid))

(defwin32struct rect
  (left long)
  (top long)
  (right long)
  (bottom long))

(defwin32struct paletteentry
  (red byte)
  (green byte)
  (blue byte)
  (flags byte))

(defwin32struct paintstruct
  (dc hdc)
  (erase bool)
  (paint rect)
  (restore bool)
  (incupdate bool)
  (rgbreserved byte :count 32))

(defwin32struct logpalette
  (version word)
  (num-entries word)
  (palette-entries paletteentry :count 1))

(defwin32struct pixelformatdescriptor
  (size word)
  (version word)
  (flags dword)
  (pixel-type byte)
  (color-bits byte)
  (red-bits byte)
  (red-shift byte)
  (green-bits byte)
  (green-shift byte)
  (blue-bits byte)
  (blue-shift byte)
  (alpha-bits byte)
  (alpha-shift byte)
  (accum-bits byte)
  (accum-red-bits byte)
  (accum-green-bits byte)
  (accum-blue-bits byte)
  (accum-alpha-bits byte)
  (depth-bits byte)
  (stencil-bits byte)
  (aux-buffers byte)
  (layer-type byte)
  (reserved byte)
  (layer-mask dword)
  (visible-mask dword)
  (damage-mask dword))

(defwin32struct point
  (x long)
  (y long))

(defwin32struct pointl
  (x long)
  (y long))

(defwin32struct trackmouseevent
  (cbsize dword)
  (flags dword)
  (hwnd hwnd)
  (hover-time dword))

(defwin32struct wndclass
  (style uint)
  (wndproc wndproc)
  (clsextra :int)
  (wndextra :int)
  (instance hinstance)
  (icon hicon)
  (cursor hcursor)
  (background hbrush)
  (menu-name lpctstr)
  (wndclass-name lpctstr))

(defwin32struct wndclassex
  (cbsize uint)
  (style uint)
  (wndproc wndproc)
  (clsextra :int)
  (wndextra :int)
  (instance hinstance)
  (icon hicon)
  (cursor hcursor)
  (background hbrush)
  (menu-name lpctstr)
  (wndclass-name lpctstr)
  (iconsm hicon))

(defwin32struct msg
  (hwnd hwnd)
  (message uint)
  (wparam wparam)
  (lparam lparam)
  (time dword)
  (point point))

(defwin32struct createstruct
  (create-params :pointer)
  (instance hinstance)
  (menu hmenu)
  (parent hwnd)
  (cy :int)
  (cx :int)
  (y :int)
  (x :int)
  (style long)
  (name lpctstr)
  (class lpctstr)
  (exstyle dword))

(defwin32struct overlapped
  (internal ulong-ptr)
  (internal-high ulong-ptr)
  (offset dword)
  (offset-high dword)
  (event handle))

(defwin32struct security-attributes
  (length dword)
  (security-descriptor :pointer)
  (inherit bool))

(defwin32struct animationinfo
  (size uint)
  (min-animate :int))

(defwin32struct audiodescription
  (size uint)
  (enabled bool)
  (locale lcid))

(defwin32struct copyfile2-extended-parameters
  (size dword)
  (copy-flags dword)
  (cancel (:pointer bool))
  (progress-routine :pointer)
  (callback-context :pointer))

(defwin32struct createfile2-extended-parameters
  (size dword)
  (file-attributes dword)
  (file-flags dword)
  (security-qos-flags dword)
  (security-attributes (:pointer security-attributes))
  (template-file handle))

(defwin32struct minimizedmetrics
  (size uint)
  (width :int)
  (horzgap :int)
  (vertgap :int)
  (arrange :int))

(defwin32struct logfont
  (height long)
  (width long)
  (escapement long)
  (orientation long)
  (weight long)
  (italic byte)
  (underline byte)
  (strikeout byte)
  (charset byte)
  (outprecision byte)
  (clipprecision byte)
  (quality byte)
  (pitchandfamily byte)
  (facename tchar :count #.+lf-facesize+))

(defwin32struct nonclientmetrics
  (size uint)
  (borderwidth :int)
  (scrollwidth :int)
  (scrollheight :int)
  (captionwidth :int)
  (captionheight :int)
  (captionfont logfont)
  (smcaptionwidth :int)
  (smcaptionheight :int)
  (smcaptionfont logfont)
  (menuwidth :int)
  (menuheight :int)
  (menufont logfont)
  (statusfont logfont)
  (messagefont logfont)
  ;;#IF WINVER >= 0x0600
  (paddedborderwidth :int)
  ;;#ENDIF
  )

(defwin32struct guid
  (data1 dword)
  (data2 word)
  (data3 word)
  (data4 byte :count 8))

(defwin32struct sp-devinfo-data
  (size dword)
  (class-guid guid)
  (dev-inst dword)
  (reserved ulong-ptr))

(defwin32struct sp-device-interface-data
  (size dword)
  (interface-class-guid guid)
  (flags dword)
  (reserved :pointer))

(defwin32struct sp-device-interface-detail-data
  (size dword)
  (device-path tchar :count #.+anysize-array+))

(defwin32struct devmode_print-struct
  (orientation :short)
  (paper-size :short)
  (paper-length :short)
  (paper-width :short)
  (scale :short)
  (copies :short)
  (default-source :short)
  (print-quality :short))

(defwin32struct devmode_display-struct
  (position pointl)
  (display-orientation dword)
  (display-fixed-output dword))

(defwin32union devmode_display-union
  (print-struct devmode_print-struct)
  (display-struct devmode_display-struct))

(defwin32union devmode_display-flags-union
  (display-flags dword)
  (nup dword))

(defwin32constant +cchdevicename+ 32)
(defwin32constant +cchformname+ 32)

(defwin32constant +file-ver-get-localised+ #x01)
(defwin32constant +file-ver-get-neutral+ #x02)
(defwin32constant +file-ver-get-prefetched+ #x04)

(defwin32constant +vfff-issharedfile+ #x0001)

(defwin32constant +viff-forceinstall+ #x0001)
(defwin32constant +viff-dontdeleteold+ #x0002)

(defwin32constant +vif-accessviolation+ #x00000200)

(defwin32constant +vif-bufftoosmall+      #x00040000)
(defwin32constant +vif-cannotcreate+      #x00000800)
(defwin32constant +vif-cannotdelete+      #x00001000)
(defwin32constant +vif-cannotdeletecur+   #x00004000)
(defwin32constant +vif-cannotloadcabinet+ #x00100000)
(defwin32constant +vif-cannotloadlz32+    #x00080000)
(defwin32constant +vif-cannotreaddst+     #x00020000)
(defwin32constant +vif-cannotreadsrc+     #x00010000)
(defwin32constant +vif-cannotrename+      #x00002000)
(defwin32constant +vif-diffcodepg+        #x00000010)
(defwin32constant +vif-difflang+          #x00000008)
(defwin32constant +vif-difftype+          #x00000020)
(defwin32constant +vif-fileinuse+         #x00000080)
(defwin32constant +vif-mismatch+          #x00000002)
(defwin32constant +vif-outofmemory+       #x00008000)
(defwin32constant +vif-outofspace+        #x00000100)
(defwin32constant +vif-sharingviolation+  #x00000400)
(defwin32constant +vif-srcold+            #x00000004)
(defwin32constant +vif-tempfile+          #x00000001)
(defwin32constant +vif-writeprot+         #x00000040)

(defwin32struct devmode
  (device-name wchar :count #.+cchdevicename+)
  (spec-version word)
  (driver-version word)
  (size word)
  (driver-extra word)
  (fields dword)
  (display-union devmode_display-union)
  (color :short)
  (duplex :short)
  (y-resolution :short)
  (t-option :short)
  (collate :short)
  (form-name wchar :count #.+cchformname+)
  (log-pixels  word)
  (bits-per-pel dword)
  (pels-width dword)
  (pels-height dword)
  (display-flags devmode_display-flags-union)
  (display-frequency dword)
  ;;#if (WINVER >= 0x0400)
  (icm-method dword)
  (icm-intent dword)
  (media-type dword)
  (dither-type dword)
  (reserved-1 dword)
  (reserved-2 dword)
  ;;#if (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
  (panning-width dword)
  (panning-height dword)
  ;;#endif
  ;;#endif
  )

(defwin32struct mouseinput
  (dx long)
  (dy long)
  (mouse-data dword)
  (flags dword)
  (time dword)
  (extra-info ulong-ptr))

(defwin32struct keybdinput
  (vk word)
  (scan word)
  (flags dword)
  (time dword)
  (extra-info ulong-ptr))

(defwin32struct hardwareinput
  (msg dword)
  (paraml word)
  (paramw word))

(defwin32union input_input-union
  (mi mouseinput)
  (ki keybdinput)
  (hi hardwareinput))

(defwin32struct input
  (type dword)
  (input input_input-union))

(defwin32struct filetime
  (low-date-time dword)
  (high-date-time dword))

(defwin32struct systemtime
  (year word)
  (month word)
  (day-of-week word)
  (day word)
  (hour word)
  (minute word)
  (second word)
  (milliseconds word))

(defwin32struct dynamic-time-zone-information
  (bias long)
  (standard-name wchar :count 32)
  (standard-date systemtime)
  (standard-bias long)
  (daylight-name wchar :count 32)
  (daylight-date systemtime)
  (daylight-bias long)
  (time-zone-key-name wchar :count 128)
  (dynamic-daylight-time-disabled boolean))

(defwin32struct time-zone-information
  (bias long)
  (standard-name wchar :count 32)
  (standard-date systemtime)
  (standard-bias long)
  (daylight-name wchar :count 32)
  (daylight-date systemtime)
  (daylight-bias long))

(defwin32fun ("Beep" beep kernel32) bool
  (freq dword)
  (duration dword))

(defwin32fun ("BeginPaint" begin-paint user32) hdc
  (hwnd hwnd)
  (paint (:pointer paintstruct)))

(defwin32fun ("BroadcastSystemMessageW" broadcast-system-message user32) :long
  (flags dword)
  (recipients (:pointer dword))
  (message uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("CallNamedPipeA" call-named-pipe kernel32) bool
  (named-pipe-name lpcstr)
  (in-buffer (:pointer :void))
  (in-buffer-size dword)
  (out-buffer (:pointer :void))
  (out-buffer-size dword)
  (bytes-read (:pointer dword))
  (timeout dword))

(defwin32fun ("CallNextHookEx" call-next-hook user32) lresult
  (hk hhook)
  (code :int)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("CallWindowProcW" call-window-proc user32) lresult
  (prev-wndproc :pointer)
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("CancelIo" cancel-io kernel32) bool
  (handle handle))

(defwin32fun ("ChoosePixelFormat" choose-pixel-format gdi32) :int
  (dc hdc)
  (pixel-format (:pointer pixelformatdescriptor)))

(defwin32fun ("ClientToScreen" client-to-screen user32) bool
  (hwnd hwnd)
  (point (:pointer point)))

(defwin32fun ("ClipCursor" clip-cursor user32) bool
  (rect (:pointer rect)))

(defwin32fun ("CloseHandle" close-handle kernel32) bool
  (handle handle))

(defwin32fun ("CloseWindow" close-window user32) bool
  (hwnd hwnd))

(defwin32fun ("CommandLineToArgvW" command-line-to-argv shell32) (:pointer lpwstr)
  (cmd-line lpcwstr)
  (num-args (:pointer :int)))

(defwin32fun ("CompareFileTime" compare-file-time kernel32) long
  (file-time-1 (:pointer filetime))
  (file-time-2 (:pointer filetime)))

(defwin32fun ("ConnectNamedPipe" connect-named-pipe kernel32) bool
  (hnamed-pipe handle)
  (overlapped (:pointer overlapped)))

(defwin32fun ("ConvertAuxiliaryCounterToPerformanceCounter" convert-auxiliary-counter-to-performance-counter kernel32) hresult
  (auxiliary-counter-value ulonglong)
  (performance-counter-value (:pointer ulonglong))
  (conversion-error (:pointer ulonglong)))

(defwin32fun ("ConvertPerformanceCounterToAuxiliaryCounter" convert-performance-counter-to-auxiliary-counter kernel32) hresult
  (performance-counter-value ulonglong)
  (auxiliary-counter-value (:pointer ulonglong))
  (conversion-error (:pointer ulonglong)))

(defwin32fun ("CopyFileW" copy-file kernel32) bool
  (existing-name lpcwstr)
  (new-name lpcwstr)
  (fail-if-exists bool))

(defwin32fun ("CopyFile2" copy-file-2 kernel32) bool
  (existing-name lpcwstr)
  (new-name lpcwstr)
  (extended-parameters  (:pointer copyfile2-extended-parameters)))

(defwin32fun ("CopyFileExW" copy-file-ex kernel32) bool
  (existing-name lpcwstr)
  (new-name lpcwstr)
  (progress-routine :pointer)
  (data :pointer)
  (cancel (:pointer bool))
  (flags dword))

(defwin32fun ("CopyFileTransactedW" copy-file-transacted kernel32) bool
  (existing-file-name lpctstr)
  (new-file-name lpctstr)
  (progress-routine :pointer)
  (data :pointer)
  (cancel (:pointer bool))
  (copy-flags dword)
  (transaction handle))

(defwin32fun ("CreateDesktopW" create-desktop user32) hdesk
  (desktop lpcwstr)
  (device lpcwstr)
  (devmode (:pointer devmode))
  (flags dword)
  (desired-access access-mask)
  (security-attributes (:pointer security-attributes)))

(defwin32fun ("CreateEventW" create-event kernel32) handle
  (security-attributes (:pointer security-attributes))
  (manual-reset bool)
  (initial-state bool)
  (name lpwstr))

(defwin32fun ("CreateFileW" create-file kernel32) handle
  (file-name lpcwstr)
  (desired-access dword)
  (share-mode dword)
  (security-attributes (:pointer security-attributes))
  (creation-disposition dword)
  (flags-and-attributes dword)
  (template-file handle))

(defwin32fun ("CreateFile2" create-file-2 kernel32) handle
  (file-name lpcwstr)
  (desired-access dword)
  (share-mode dword)
  (creation-disposition dword)
  (create-ex-params (:pointer createfile2-extended-parameters)))

(defwin32fun ("CreateMutexW" create-mutex kernel32) handle
  (mutex-attributes (:pointer security-attributes))
  (initial-owner bool)
  (name lpcwstr))

(defwin32fun ("CreateNamedPipeA" create-named-pipe kernel32) handle
  (name lpcstr)
  (open-mode dword)
  (pipe-mode dword)
  (max-instances dword)
  (out-buffer-size dword)
  (in-buffer-size dword)
  (default-timeout dword)
  (security-attributes (:pointer security-attributes)))

(defwin32fun ("CreatePalette" create-palette gdi32) hpalette
  (log-palette (:pointer logpalette)))

(defwin32fun ("CreateSemaphoreW" create-semaphore kernel32) handle
  (semaphore-attributes (:pointer security-attributes))
  (initial-count long)
  (maximum-count long)
  (name lpcwstr))

(defwin32-lispfun create-window (class-name window-name style x y width height parent menu instance param)
  (create-window-ex 0 class-name window-name style x y width height parent menu instance param))

(defwin32fun ("CreateWindowExW" create-window-ex user32) hwnd
  (ex-style dword)
  (wndclass-name lpcwstr)
  (window-name lpcwstr)
  (style dword)
  (x :int)
  (y :int)
  (width :int)
  (height :int)
  (parent hwnd)
  (menu hmenu)
  (instance hinstance)
  (param :pointer))

(defwin32fun ("DefWindowProcW" def-window-proc user32) lresult
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("DeleteObject" delete-object gdi32) bool
  (object hgdiobj))

(defwin32fun ("DescribePixelFormat" describe-pixel-format user32) :int
  (dc hdc)
  (pixel-format :int)
  (bytes uint)
  (pfd (:pointer pixelformatdescriptor)))

(defwin32fun ("DestroyCursor" destroy-cursor user32) bool
  (cursor hcursor))

(defwin32fun ("DestroyWindow" destroy-window user32) bool
  (hwnd hwnd))

(defwin32fun ("DisconnectNamedPipe" disconnect-named-pipe kernel32) bool
  (hnamed-pipe handle))

(defwin32fun ("DispatchMessageW" dispatch-message user32) lresult
  (msg (:pointer msg)))

(defwin32fun ("DosDateTimeToFileTime" dos-date-time-to-file-time kernel32) bool
  (fat-date word)
  (fat-time word)
  (file-time (:pointer filetime)))

(defwin32fun ("EnableWindow" enable-window user32) bool
  (hwnd hwnd)
  (enable bool))

(defwin32fun ("EndPaint" end-paint user32) bool
  (hwnd hwnd)
  (paint (:pointer paintstruct)))

(defwin32fun ("EnumDynamicTimeZoneInformation" enum-dynamic-time-zone-information kernel32) dword
  (index dword)
  (time-zone-information (:pointer dynamic-time-zone-information)))

(defwin32fun ("EnumWindows" enum-windows user32) bool
  (callback :pointer)
  (lparam lparam))

(defwin32fun ("FileTimeToDosDateTime" file-time-to-dos-date-time kernel32) bool
  (file-time (:pointer filetime))
  (fat-date (:pointer word))
  (fat-time (:pointer word)))

(defwin32fun ("FileTimeToLocalFileTime" file-time-to-local-file-time kernel32) bool
  (file-time (:pointer filetime))
  (local-file-time (:pointer filetime)))

(defwin32fun ("FileTimeToSystemTime" file-time-to-system-time kernel32) bool
  (file-time (:pointer filetime))
  (system-time (:pointer systemtime)))

(defwin32fun ("FindWindowW" find-window user32) hwnd
  (wndclass-name lpcwstr)
  (window-name lpcwstr))

(defwin32fun ("FindWindowExW" find-window-ex user32) hwnd
  (hwnd-parent hwnd)
  (hwnd-child-after hwnd)
  (class lpcwstr)
  (window lpcwstr))

(defwin32fun ("FlushFileBuffers" flush-file-buffers kernel32) bool
  (hfile handle))

(defwin32fun ("GetACP" get-acp kernel32) uint)

(defwin32fun ("GetClassLongW" get-class-long user32) dword
  (hwnd hwnd)
  (index :int))

#+x86
(defwin32fun ("GetClassLongW" get-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int))

#+x86-64
(defwin32fun ("GetClassLongPtrW" get-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int))

(defwin32fun ("GetClassWord" get-class-word user32) word
  (hwnd hwnd)
  (index :int))

(defwin32fun ("GetClientRect" get-client-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32fun ("GetCommandLineW" get-command-line kernel32) lptstr)

(defwin32fun ("GetCurrentProcess" get-current-process kernel32) handle)

(defwin32fun ("GetCurrentProcessId" get-current-process-id kernel32) dword)

(defwin32fun ("GetCurrentProcessorNumber" get-current-processor-number kernel32) dword)

(defwin32fun ("GetCurrentThreadId" get-current-thread-id kernel32) dword)

(defwin32fun ("GetDC" get-dc user32) hdc
  (hwnd hwnd))

(defwin32fun ("GetDesktopWindow" get-desktop-window user32) hwnd)

(defwin32fun ("GetDynamicTimeZoneInformation" get-dynamic-time-zone-information kernel32) dword
  (time-zone-information (:pointer dynamic-time-zone-information)))

(defwin32fun ("GetDynamicTimeZoneInformationEffectiveYears" get-dynamic-time-zone-information-effective-years kernel32) dword
  (time-zone-information (:pointer dynamic-time-zone-information))
  (first-year (:pointer dword))
  (last-year (:pointer dword)))

(defwin32fun ("GetFileTime" get-file-time kernel32) bool
  (file handle)
  (creation-time (:pointer filetime))
  (last-access-time (:pointer filetime))
  (last-write-time (:pointer filetime)))

(defwin32fun ("GetFileVersionInfoW" get-file-version-info api-ms-win-core-version-l1-1-0) bool
  (str-file-name lpctstr)
  (handle dword)
  (len dword)
  (data :pointer))

(defwin32fun ("GetFileVersionInfoExW" get-file-version-info-ex api-ms-win-core-version-l1-1-0) bool
  (flags dword)
  (str-file-name lpctstr)
  (handle dword)
  (len dword)
  (data :pointer))

(defwin32fun ("GetFileVersionInfoSizeW" get-file-version-info-size pi-ms-win-core-version-l1-1-0) dword
  (str-file-name lpctstr)
  (handle (:pointer dword)))

(defwin32fun ("GetFileVersionInfoSizeExW" get-file-version-info-size-ex api-ms-win-core-version-l1-1-0) dword
  (flags dword)
  (str-file-name lpctstr)
  (handle (:pointer dword)))

(defwin32fun ("VerFindFileW" ver-find-file api-ms-win-core-version-l1-1-0) dword
  (flags dword)
  (file-name lpctstr)
  (win-dir lpctstr)
  (app-dir lpctstr)
  (cur-dir lpwstr)
  (cur-dir-len (:pointer uint))
  (dst-dir lptstr)
  (dest-dir-len (:pointer uint)))

(defwin32fun ("VerInstallFileW" ver-install-file api-ms-win-core-version-l1-1-0) dword
  (flags dword)
  (src-file-name lpctstr)
  (dst-file-name lpctstr)
  (src-dir lpctstr)
  (dst-dir lpctstr)
  (cur-dir lpctstr)
  (tmp-file lptstr)
  (tmp-file-len (:pointer uint)))

(defwin32fun ("VerLanguageNameW" ver-language-name api-ms-win-core-localization-l1-2-1) dword
  (wlang dword)
  (szlang lptstr)
  (cchlang dword))

(defwin32fun ("VerQueryValueW" ver-query-value api-ms-win-core-version-l1-1-0) bool
  (block :pointer)
  (sub-block lpctstr)
  (buffer :pointer)
  (len (:pointer uint)))

(defwin32fun ("GetInputState" get-input-state user32) bool)

(defwin32fun ("GetLastError" get-last-error user32) dword)

(defwin32fun ("GetLocalTime" get-local-time kernel32) :void
  (system-time (:pointer systemtime)))

(defwin32fun ("GetMessageW" get-message user32) bool
  (msg (:pointer msg))
  (hwnd hwnd)
  (msg-filter-min uint)
  (msg-filter-max uint))

(defwin32fun ("GetMessageExtraInfo" get-message-extra-info user32) lparam)

(defwin32fun ("GetMessagePos" get-message-pos user32) dword)

(defwin32fun ("GetMessageTime" get-message-time user32) long)

(defwin32fun ("GetModuleHandleW" get-module-handle kernel32) hmodule
  (module lpcwstr))

(defwin32fun ("GetNamedPipeClientComputerNameA" get-named-pipe-client-computer-name kernel32) bool
  (pipe handle)
  (client-computer-name lpstr)
  (client-computer-name-length ulong))

(defwin32fun ("GetNamedPipeClientProcessId" get-named-pipe-client-process-id kernel32) bool
  (pipe handle)
  (client-process-id (:pointer ulong)))

(defwin32fun ("GetNamedPipeClientSessionId" get-named-pipe-client-session-id kernel32) bool
  (pipe handle)
  (client-session-id (:pointer ulong)))

(defwin32fun ("GetNamedPipeHandleStateA" get-named-pipe-handle-state kernel32) bool
  (named-pipe handle)
  (state (:pointer dword))
  (cur-instances (:pointer dword))
  (max-collection-count (:pointer dword))
  (collect-data-timeout (:pointer dword))
  (user-name lpstr)
  (max-user-name-size dword))

(defwin32fun ("GetNamedPipeInfo" get-named-pipe-info kernel32) bool
  (named-pipe handle)
  (flags (:pointer dword))
  (out-buffer-size (:pointer dword))
  (in-buffer-size (:pointer dword))
  (max-instances (:pointer dword)))

(defwin32fun ("GetNamedPipeServerProcessId" get-named-pipe-server-process-id kernel32) bool
  (pipe handle)
  (server-process-id (:pointer ulong)))

(defwin32fun ("GetNamedPipeServerSessionId" get-named-pipe-server-session-id kernel32) bool
  (pipe handle)
  (server-session-id (:pointer ulong)))

(defwin32fun ("GetOverlappedResult" get-overlapped-result kernel32) bool
  (file handle)
  (overlapped (:pointer overlapped))
  (bytes-transfered (:pointer dword))
  (wait bool))

(defwin32fun ("GetParent" get-parent user32) hwnd
  (hwnd :pointer))

(defwin32fun ("GetPixelFormat" get-pixel-format gdi32) :int
  (dc hdc))

(defwin32fun ("GetShellWindow" get-shell-window user32) hwnd)

(defwin32fun ("GetStockObject" get-stock-object gdi32) hgdiobj
  (object :int))

(defwin32fun ("GetQueueStatus" get-queue-status user32) dword
  (flags uint))

(defwin32fun ("GetSysColor" get-sys-color user32) :uint32
  (index :int))

(defwin32fun ("GetSysColorBrush" get-sys-color-brush user32) hbrush
  (index :int))

(defwin32fun ("GetSystemMetrics" get-system-metrics user32) :int
  (index :int))

(defwin32fun ("GetSystemTime" get-system-time kernel32) :void
  (system-time (:pointer systemtime)))

(defwin32fun ("GetSystemTimeAdjustment" get-system-time-adjustment kernel32) bool
  (time-adjust (:pointer dword))
  (time-increment (:pointer dword))
  (time-adjustment-disabled (:pointer bool)))

(defwin32fun ("GetSystemTimeAsFileTime" get-system-time-as-file-time kernel32) :void
  (system-time-as-file-time (:pointer filetime)))

(defwin32fun ("GetSystemTimePreciseAsFileTime" get-system-time-precise-as-file-time kernel32) :void
  (system-time-as-file-time (:pointer filetime)))

(defwin32fun ("GetSystemTimes" get-system-times kernel32) bool
  (idle-time (:pointer filetime))
  (kernel-time (:pointer filetime))
  (user-time (:pointer filetime)))

(defwin32fun ("GetTickCount" get-tick-count kernel32) dword)

(defwin32fun ("GetTickCount64" get-tick-count-64 kernel32) ulonglong)

(defwin32fun ("GetTimeZoneInformation" get-time-zone-information kernel32) dword
  (time-zone-information (:pointer time-zone-information)))

(defwin32fun ("GetTimeZoneInformationForYear" get-time-zone-information-for-year kernel32) bool
  (year ushort)
  (dtzi (:pointer dynamic-time-zone-information))
  (tzi (:pointer time-zone-information)))

(defwin32fun ("GetTopWindow" get-top-window user32) hwnd
  (hwnd hwnd))

(defwin32fun ("GetWindowLongW" get-window-long user32) long
  (hwnd hwnd)
  (index :int))

(defwin32fun ("GetWindowRect" get-window-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32fun ("GetWindowTextW" get-window-text user32) :int
  (hwnd hwnd)
  (string lptstr)
  (max-count :int))

(defwin32fun ("GetWindowThreadProcessId" get-window-thread-process-id user32) dword
  (hwnd hwnd)
  (process-id (:pointer dword)))

(defwin32fun ("ImpersonateNamedPipeClient" impersonate-named-pipe-client advapi32) bool
  (named-pipe handle))

(defwin32fun ("InSendMessage" in-send-message user32) bool)

(defwin32fun ("InSendMessageEx" in-send-message-ex user32) dword
  (reserved :pointer))

(defwin32fun ("InvalidateRect" invalidate-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect))
  (erase bool))

(defwin32fun ("IsGUIThread" is-gui-thread user32) bool
  (convert bool))

(defwin32fun ("IsWindow" is-window user32) bool
  (hwnd hwnd))

(defwin32fun ("LoadCursorW" load-cursor user32) hcursor
  (instance hinstance)
  (name lpctstr))

(defwin32fun ("LoadCursorFromFileW" load-cursor-from-file user32) hcursor
  (file-name lpctstr))

(defwin32fun ("LoadIconW" load-icon user32) hicon
  (instance hinstance)
  (name lpctstr))

(defwin32fun ("LocalAlloc" local-alloc kernel32) hlocal
  (flags uint)
  (bytes size-t))

(defwin32-lispfun local-discard (h)
  (local-re-alloc h 0 +lmem-moveable+))

(defwin32fun ("LocalFileTimeToFileTime" local-file-time-to-file-time kernel32) bool
  (local-file-time (:pointer filetime))
  (file-time (:pointer filetime)))

(defwin32fun ("LocalFree" local-free kernel32) hlocal
  (hmem hlocal))

(defwin32fun ("LocalReAlloc" local-re-alloc kernel32) hlocal
  (hmem hlocal)
  (bytes size-t)
  (flags uint))

(defwin32fun ("MoveFileW" move-file kernel32) bool
  (existing-file-name lpctstr)
  (new-file-name lpctstr))

(defwin32fun ("MoveFileExW" move-file-ex kernel32) bool
  (existing-file-name lpctstr)
  (new-file-name lpctstr)
  (flags dword))

(defwin32fun ("MoveFileTransactedW" move-file-transacted kernel32) bool
  (existing-file-name lpctstr)
  (new-file-name lpctstr)
  (progress-routine :pointer)
  (data :pointer)
  (flags dword)
  (transaction handle))

(defwin32fun ("OpenEventW" open-event kernel32) handle
  (desired-access dword)
  (inherit-handle bool)
  (name lpctstr))

(defwin32fun ("OpenInputDesktop" open-input-desktop user32) hdesk
  (flags dword)
  (inherit bool)
  (desired-access access-mask))

(defwin32fun ("PeekMessageW" peek-message user32) bool
  (msg (:pointer msg))
  (hwnd hwnd)
  (msg-min uint)
  (msg-max uint)
  (remove uint))

(defwin32fun ("PeekNamedPipe" peek-named-pipe kernel32) bool
  (named-pipe handle)
  (buffer (:pointer :void))
  (buffer-size dword)
  (bytes-read (:pointer dword))
  (total-bytes-avail (:pointer dword))
  (bytes-left-this-message (:pointer dword)))

(defwin32fun ("PostMessageW" post-message user32) bool
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("PostQuitMessage" post-quit-message user32) :void
  (exit-code :int))

(defwin32fun ("PostThreadMessageW" post-thread-message user32) bool
  (thread-id dword)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("QueryAuxiliaryCounterFrequency" query-auxiliary-counter-frequency kernel32) hresult
  (auxiliary-counter-frequency (:pointer ulonglong)))

(defwin32fun ("QueryInterruptTime" query-interrupt-time kernel32) :void
  (interrupt-time (:pointer ulonglong)))

(defwin32fun ("QueryInterruptTimePrecise" query-interrupt-time-precise kernel32) :void
  (interrupt-time-precise (:pointer ulonglong)))

(defwin32fun ("QueryUnbiasedInterruptTime" query-unbiased-interrupt-time kernel32) bool
  (unbiased-interrupt-time (:pointer ulonglong)))

(defwin32fun ("QueryUnbiasedInterruptTimePrecise" query-unbiased-interrupt-time-precise kernel32) :void
  (unbiased-interrupt-time-precise (:pointer ulonglong)))

(defwin32fun ("ReadFile" read-file kernel32) bool
  (handle handle)
  (buffer :pointer)
  (bytes-to-read dword)
  (bytes-read (:pointer dword))
  (overlapped (:pointer overlapped)))

(defwin32fun ("ReadFileEx" read-file-ex kernel32) bool
  (handle handle)
  (buffer :pointer)
  (number-of-bytes-to-read dword)
  (overlapped (:pointer overlapped))
  (completion-routine :pointer))

(defwin32fun ("RealizePalette" realize-palette gdi32) uint
  (dc hdc))

(defwin32fun ("RegCloseKey" reg-close-key advapi32) long
  (hkey hkey))

(defwin32fun ("RegCreateKeyW" reg-create-key advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (phkey-result (:pointer hkey)))

(defwin32fun ("RegCreateKeyExW" reg-create-key-ex advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (reserved dword)
  (class lptstr)
  (options dword)
  (sam-desired regsam)
  (security-attributes (:pointer security-attributes))
  (phkey-result (:pointer hkey))
  (disposition (:pointer dword)))

(defwin32fun ("RegDeleteKeyW" reg-delete-key advapi32) long
  (hkey hkey)
  (sub-key lpctstr))

(defwin32fun ("RegDeleteKeyExW" reg-delete-key-ex advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (sam-desired regsam)
  (reserved dword))

(defwin32fun ("RegDeleteTreeW" reg-delete-tree advapi32) long
  (hkey hkey)
  (sub-key lpctstr))

(defwin32fun ("RegGetValueW" reg-get-value advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (value-name lpctstr)
  (flags dword)
  (type (:pointer dword))
  (data :pointer)
  (data-size (:pointer dword)))

(defwin32fun ("RegOpenKeyW" reg-open-key advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (phkey-result (:pointer hkey)))

(defwin32fun ("RegOpenKeyExW" reg-open-key-ex advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (options dword)
  (sam-desired regsam)
  (phkey-result (:pointer hkey)))

(defwin32fun ("RegQueryValueW" reg-query-value advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (value (:pointer lptstr))
  (value-size (:pointer long)))

(defwin32fun ("RegQueryValueExW" reg-query-value-ex advapi32) long
  (hkey hkey)
  (value-name lpctstr)
  (reserved (:pointer dword))
  (type (:pointer dword))
  (data (:pointer byte))
  (data-size (:pointer dword)))

(defwin32fun ("RegSetValueW" reg-set-value advapi32) long
  (hkey hkey)
  (sub-key lpctstr)
  (type dword)
  (data lpctstr)
  (data-size dword))

(defwin32fun ("RegSetValueExW" reg-set-value-ex advapi32) :long
  (hkey hkey)
  (value-name lpctstr)
  (reserved dword)
  (type dword)
  (data (:pointer byte))
  (data-size dword))

(defwin32fun ("RegisterClassW" register-class user32) atom
  (wndclass (:pointer wndclass)))

(defwin32fun ("RegisterClassExW" register-class-ex user32) atom
  (wndclassex (:pointer wndclassex)))

(defwin32fun ("RegisterWindowMessageW" register-window-message user32) uint
  (string lpctstr))

(defwin32fun ("ReleaseDC" release-dc user32) :int
  (hwnd hwnd)
  (dc hdc))

(defwin32fun ("ReplyMessage" reply-message user32) bool
  (result lresult))

(defwin32fun ("ResetEvent" reset-event kernel32) bool
  (event handle))

(defwin32fun ("ResizePalette" resize-palette gdi32) bool
  (palette hpalette)
  (entries uint))

(defwin32-lispfun rgb (r g b)
  (logior
   (ash (logand b #xFF) 16)
   (ash (logand g #xFF) 8)
   (ash (logand r #xFF) 0)))

(defwin32fun ("SelectPalette" select-palette gdi32) hpalette
  (dc hdc)
  (palette hpalette)
  (force-background bool))

(defwin32fun ("SendInput" send-input user32) uint
  (num-inputs uint)
  (inputs (:pointer input))
  (cbsize :int))

(defwin32fun ("SendMessageW" send-message user32) lresult
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("SendMessageCallbackW" send-message-callback user32) bool
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam)
  (callback :pointer)
  (data ulong-ptr))

(defwin32fun ("SendMessageTimeoutW" send-message-timeout user32) lresult
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (flags uint)
  (timeout uint)
  (result (:pointer dword-ptr)))

(defwin32fun ("SendNotifyMessageW" send-notify-message user32) bool
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("SetClassLongW" set-class-long user32) dword
  (hwnd hwnd)
  (index :int)
  (new-long long))

#+x86
(defwin32fun ("SetClassLongW" set-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

#+x86-64
(defwin32fun ("SetClassLongPtrW" set-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

(defwin32fun ("SetClassWord" set-class-word user32) word
  (hwnd hwnd)
  (index :int)
  (new-word word))

(defwin32fun ("SetCursor" set-cursor user32) hcursor
  (cursor hcursor))

(defwin32fun ("SetCursorPos" set-cursor-pos user32) bool
  (x :int)
  (y :int))

(defwin32fun ("SetDynamicTimeZoneInformation" set-dynamic-time-zone-information kernel32) bool
  (time-zone-information (:pointer dynamic-time-zone-information)))

(defwin32fun ("SetEvent" set-event kernel32) bool
  (event handle))

(defwin32fun ("SetFileTime" set-file-time kernel32) bool
  (file handle)
  (creation-time (:pointer filetime))
  (last-access-time (:pointer filetime))
  (last-write-time (:pointer filetime)))

(defwin32fun ("SetLocalTime" set-local-time kernel32) bool
  (system-time (:pointer systemtime)))

(defwin32fun ("SetNamedPipeHandleState" set-named-pipe-handle-state kernel32) bool
  (hnamed-pipe handle)
  (mode (:pointer dword))
  (max-collection-count (:pointer dword))
  (collected-data-timeout (:pointer dword)))

(defwin32fun ("SetSystemTime" set-system-time kernel32) bool
  (system-time (:pointer systemtime)))

(defwin32fun ("SetSystemTimeAdjustment" set-system-time-adjustment kernel32) bool
  (time-adjustment dword)
  (time-adjustment-disabled bool))

(defwin32fun ("SetTimeZoneInformation" set-time-zone-information kernel32) bool
  (time-zone-information (:pointer time-zone-information)))

(defwin32fun ("SetForegroundWindow" set-foreground-window user32) bool
  (hwnd hwnd))

(defwin32fun ("SetLastError" set-last-error kernel32) :void
  (err-code dword))

(defwin32fun ("SetLastErrorEx" set-last-error-ex kernel32) :void
  (err-code dword)
  (type dword))

(defwin32fun ("SetLayeredWindowAttributes" set-layered-window-attributes user32) bool
  (hwnd hwnd)
  (color colorref)
  (alpha byte)
  (flags dword))

(defwin32fun ("SetMessageExtraInfo" set-message-extra-info user32) lparam
  (lparam lparam))

(defwin32fun ("SetParent" set-parent user32) hwnd
  (hwnd hwnd)
  (new-parent hwnd))

(defwin32fun ("SetPixelFormat" set-pixel-format user32) bool
  (dc hdc)
  (pixel-format :int)
  (pfd (:pointer pixelformatdescriptor)))

(defwin32fun ("SetSysColors" set-sys-colors user32) bool
  (numelements :int)
  (elements (:pointer :int))
  (rgbas (:pointer colorref)))

(defwin32fun ("SetWinEventHook" set-win-event-hook user32) hwineventhook
  (event-min uint)
  (event-max uint)
  (hmod-win-event-proc hmodule)
  (win-event-proc :pointer)
  (id-process dword)
  (id-thread dword)
  (flags uint))

(defwin32fun ("SetWindowLongW" set-window-long user32) long
  (hwnd hwnd)
  (index :int)
  (new-long long))

#+x86
(defwin32fun ("SetWindowLongW" set-window-long-ptr user32) long-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

#+x86-64
(defwin32fun ("SetWindowLongPtrW" set-window-long-ptr user32) long-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

(defwin32fun ("SetWindowPos" set-window-pos user32) bool
  (hwnd hwnd)
  (insert-after hwnd)
  (x :int)
  (y :int)
  (cx :int)
  (cy :int)
  (flags uint))

(defwin32fun ("SetWindowTextW" set-window-text user32) bool
  (hwnd hwnd)
  (text lpctstr))

(defwin32fun ("SetWindowsHookExW" set-windows-hook-ex user32) hhook
  (id-hook :int)
  (fn :pointer)
  (mod hinstance)
  (thread-id dword))

(defwin32fun ("SetupDiDestroyDeviceInfoList" setup-di-destroy-device-info-list setupapi) bool
  (device-info hdevinfo))

(defwin32fun ("SetupDiEnumDeviceInterfaces" setup-di-enum-device-interface setupapi) bool
  (device hdevinfo)
  (device-info-data (:pointer sp-devinfo-data))
  (guid (:pointer guid))
  (member-index dword)
  (device-interface-data (:pointer sp-device-interface-data)))

(defwin32fun ("SetupDiGetClassDevsW" setup-di-get-class-devs setupapi) hdevinfo
  (guid (:pointer guid))
  (enum pctstr)
  (hwnd-parent hwnd)
  (flags dword))

(defwin32fun ("SetupDiGetDeviceInterfaceDetailW" setup-di-get-device-interface-detail setupapi) bool
  (device hdevinfo)
  (device-interface-data (:pointer sp-device-interface-data))
  (device-interface-detail-data (:pointer sp-device-interface-detail-data))
  (device-interface-detail-data-size dword)
  (required-size (:pointer dword))
  (device-info-data (:pointer sp-devinfo-data)))

(defwin32fun ("ShowCursor" show-cursor user32) :int
  (show bool))

(defwin32fun ("ShowWindow" show-window user32) bool
  (hwnd hwnd)
  (cmd :int))

(defwin32fun ("SwapBuffers" swap-buffers gdi32) bool
  (dc hdc))

(defwin32fun ("SwitchDesktop" switch-desktop user32) bool
  (desktop hdesk))

(defwin32fun ("SystemParametersInfoW" system-parameters-info user32) bool
  (action uint)
  (uiparam uint)
  (pvparam :pointer)
  (win-ini uint))

(defwin32fun ("SystemTimeToFileTime" system-time-to-file-time kernel32) bool
  (system-time (:pointer systemtime))
  (filetime (:pointer filetime)))

(defwin32fun ("SystemTimeToTzSpecificLocalTime" system-time-to-tz-specific-local-time kernel32) bool
  (time-zone (:pointer time-zone-information))
  (universal-time (:pointer systemtime))
  (local-time (:pointer systemtime)))

(defwin32fun ("SystemTimeToTzSpecificLocalTimeEx" system-time-to-tz-specific-local-time-ex kernel32) bool
  (time-zone-information (:pointer dynamic-time-zone-information))
  (universal-time (:pointer systemtime))
  (local-time (:pointer systemtime)))

(defwin32fun ("TrackMouseEvent" track-mouse-event user32) bool
  (event-track (:pointer trackmouseevent)))

(defwin32fun ("TransactNamedPipe" transact-named-pipe kernel32) bool
  (named-pipe handle)
  (in-buffer (:pointer :void))
  (in-buffer-size (:pointer dword))
  (out-buffer (:pointer :void))
  (out-buffer-size (:pointer dword))
  (bytes-read (:pointer dword))
  (overlapped (:pointer overlapped)))

(defwin32fun ("TranslateMessage" translate-message user32) bool
  (msg (:pointer msg)))

(defwin32fun ("TzSpecificLocalTimeToSystemTime" tz-specific-local-time-to-system-time kernel32) bool
  (time-zone-information (:pointer time-zone-information))
  (local-time (:pointer systemtime))
  (universal-time (:pointer systemtime)))

(defwin32fun ("TzSpecificLocalTimeToSystemTimeEx" tz-specific-local-time-to-system-time-ex kernel32) bool
  (time-zone-information (:pointer dynamic-time-zone-information))
  (local-time (:pointer systemtime))
  (universal-time (:pointer systemtime)))

(defwin32fun ("UnregisterClassW" unregister-class user32) bool
  (wndclass-name lpctstr)
  (instance hinstance))

(defwin32fun ("UpdateWindow" update-window user32) bool
  (hwnd hwnd))

(defwin32fun ("ValidateRect" validate-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32fun ("WaitForSingleObject" wait-for-single-object kernel32) dword
  (handle handle)
  (milliseconds dword))

(defwin32fun ("WaitForMultipleObjects" wait-for-multiple-objects kernel32) dword
  (count dword)
  (handles (:pointer handle))
  (wait-all bool)
  (milliseconds dword))

(defwin32fun ("WaitNamedPipeA" wait-named-pipe kernel32) bool
  (named-pipe-name lpcstr)
  (timeout dword))

(defwin32fun ("wglCreateContext" wgl-create-context opengl32) hglrc
  (dc hdc))

(defwin32fun ("wglDeleteContext" wgl-delete-context opengl32) bool
  (hglrc hglrc))

(defwin32fun ("wglMakeCurrent" wgl-make-current opengl32) bool
  (dc hdc)
  (hglrc hglrc))

(defwin32fun ("WriteFile" write-file kernel32) bool
  (file handle)
  (buffer :pointer)
  (number-of-bytes-to-write dword)
  (number-of-bytes-written (:pointer dword))
  (overlapped (:pointer overlapped)))

(defwin32fun ("WriteFileEx" write-file-ex kernel32) bool
  (file handle)
  (buffer :pointer)
  (number-of-bytes-to-write dword)
  (overlapped (:pointer overlapped))
  (completion-routine :pointer))
