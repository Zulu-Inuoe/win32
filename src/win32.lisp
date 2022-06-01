(in-package #:win32)

(define-foreign-library version
  (:win32 "version.dll"))

(define-foreign-library kernel32
  (:win32 "Kernel32.dll"))

(define-foreign-library user32
  (:win32 "User32.dll"))

(define-foreign-library shell32
  (:win32 "Shell32.dll"))

(define-foreign-library gdi32
  (:win32 "Gdi32.dll"))

(define-foreign-library opengl32
  (:win32 "Opengl32.dll"))

(define-foreign-library advapi32
  (:win32 "Advapi32.dll"))

(define-foreign-library setupapi
  (:win32 "setupapi.dll"))

(define-foreign-library psapi
  (:win32 "psapi.dll"))

(define-foreign-library ole32
  (:win32 "ole32.dll"))

(define-foreign-library oleaut32
  (:win32 "oleaut32.dll"))

(define-foreign-library comdlg32
  (:win32 "comdlg32.dll"))

(use-foreign-library version)
(use-foreign-library kernel32)
(use-foreign-library user32)
(use-foreign-library shell32)
(use-foreign-library gdi32)
(use-foreign-library opengl32)
(use-foreign-library advapi32)
(use-foreign-library setupapi)
(use-foreign-library psapi)
(use-foreign-library ole32)
(use-foreign-library oleaut32)
(use-foreign-library comdlg32)

(defconstant +win32-string-encoding+
  #+little-endian :ucs-2le
  #+big-endian :ucs-2be
  "Not a win32 'constant' per-se, but useful to expose for usage with FOREIGN-STRING-TO-LISP and friends.")

(defconstant +pointer-bit-size+ (* (cffi:foreign-type-size :pointer) 8))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (pushnew
   #.(ecase +pointer-bit-size+
       (32 :32-bit)
       (64 :64-bit))
   *features*))

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

(defwin32type pvoid (:pointer :void))

(defwin32type char :int8)
(defwin32type uchar :uchar)
(defwin32type wchar :int16)

(defwin32type int :int32)
(defwin32type int-ptr #+32-bit :int32 #+64-bit :int64)
(defwin32type int8 :int8)
(defwin32type int16 :int16)
(defwin32type int32 :int32)
(defwin32type int64 :int64)

(defwin32type uint :uint32)
(defwin32type uint-ptr #+32-bit :uint32 #+64-bit :uint64)
(defwin32type uint8 :uint8)
(defwin32type uint16 :uint16)
(defwin32type uint32 :uint32)
(defwin32type uint64 :uint64)

(defwin32type long :int32)
(defwin32type longlong :int64)
(defwin32type long-ptr #+32-bit :int32 #+64-bit :int64)
(defwin32type long32 :int32)
(defwin32type long64 :int64)
(defwin32type double :double)
(defwin32type ulong :uint32)
(defwin32type ulonglong :uint64)
(defwin32type ulong-ptr #+32-bit :uint32 #+64-bit :uint64)
(defwin32type ulong32 :uint32)
(defwin32type ulong64 :uint64)

(defwin32type short :short)
(defwin32type ushort :ushort)

(defwin32type byte :uint8)
(defwin32type word :uint16)
(defwin32type float :float)
(defwin32type dword :uint32)
(defwin32type dwordlong :uint64)
(defwin32type dword-ptr ulong-ptr)
(defwin32type dword32 :uint32)
(defwin32type dword64 :uint64)
(defwin32type qword :uint64)

(defwin32type bool (:boolean :int))
(defwin32type boolean (:boolean byte))

(defwin32type tbyte wchar)
(defwin32type tchar wchar)

(defwin32type float :float)

(defwin32type size-t #+32-bit :uint32 #+64-bit :uint64)
(defwin32type ssize-t #+32-bit :int32 #+64-bit :int64)

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
(defwin32type half-ptr #+32-bit :int #+64-bit :short)
(defwin32type uhalf-ptr #+32-bit :uint #+64-bit :ushort)
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

(defwin32type dll-directory-cookie :pointer)
(defwin32type far-proc :pointer)

(defwin32type large-integer :int64)

(defwin32type sid :void)

(defwin32type fxpt16dot16 :long)
(defwin32type fxpt2dot30 :long)

(defwin32struct flagged-word-blob
  (f-flags ulong)
  (cl-size ulong)
  (as-data :ushort :count 1))

(defwin32struct byte-sizedarr
  (cl-size ulong)
  (p-data (:pointer byte)))

(defwin32struct word-sizedarr
  (cl-size ulong)
  (p-data (:pointer :ushort)))

(defwin32struct dword-sizedarr
  (cl-size ulong)
  (p-data (:pointer ulong)))

(defwin32type hyper :int64)

(defwin32struct hyper-sizedarr
  (cl-size ulong)
  (p-data (:pointer hyper)))

(defwin32struct kbd-ll-hook
  (vk-code dword)
  (scan-code dword)
  (flags dword)
  (time dword)
  (extra-info ulong-ptr))

(defwin32type olechar wchar)
(defwin32type wire-bstr (:pointer flagged-word-blob))
(defwin32type bstr (:pointer olechar))
(defwin32type lpbstr (:pointer bstr))
(defwin32type variant-bool :short)
(defwin32type -variant-bool variant-bool)
(defwin32type dispid long)
(defwin32type memberid dispid)
(defwin32type hreftype dword)
(defwin32type lpolestr lpstr)
(defwin32type lpcolestr (:string :encoding #.+win32-string-encoding+))
(defwin32type lpolestrptr (:pointer lpstr))
(defwin32type interface :void)
(defwin32type iunknown interface)
(defwin32type lpunknown (:pointer iunknown))
(defwin32type itypelib interface)
(defwin32type vartype :ushort)
(defwin32type scode long)
(defwin32type pscode (:pointer scode))

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

;;
;; _WIN32_WINNT version constants
;;
(defwin32constant +-win32-winnt-nt4+                    #x0400)
(defwin32constant +-win32-winnt-win2k+                  #x0500)
(defwin32constant +-win32-winnt-winxp+                  #x0501)
(defwin32constant +-win32-winnt-ws03+                   #x0502)
(defwin32constant +-win32-winnt-win6+                   #x0600)
(defwin32constant +-win32-winnt-vista+                  #x0600)
(defwin32constant +-win32-winnt-ws08+                   #x0600)
(defwin32constant +-win32-winnt-longhorn+               #x0600)
(defwin32constant +-win32-winnt-win7+                   #x0601)
(defwin32constant +-win32-winnt-win8+                   #x0602)
(defwin32constant +-win32-winnt-winblue+                #x0603)

;;

;;
;; RtlVerifyVersionInfo() conditions
;;

(defwin32constant +ver-equal+                       1)
(defwin32constant +ver-greater+                     2)
(defwin32constant +ver-greater-equal+               3)
(defwin32constant +ver-less+                        4)
(defwin32constant +ver-less-equal+                  5)
(defwin32constant +ver-and+                         6)
(defwin32constant +ver-or+                          7)

(defwin32constant +ver-condition-mask+              7)
(defwin32constant +ver-num-bits-per-condition-mask+ 3)

;;
;; RtlVerifyVersionInfo() type mask bits
;;

(defwin32constant +ver-minorversion+                #x0000001)
(defwin32constant +ver-majorversion+                #x0000002)
(defwin32constant +ver-buildnumber+                 #x0000004)
(defwin32constant +ver-platformid+                  #x0000008)
(defwin32constant +ver-servicepackminor+            #x0000010)
(defwin32constant +ver-servicepackmajor+            #x0000020)
(defwin32constant +ver-suitename+                   #x0000040)
(defwin32constant +ver-product-type+                #x0000080)

;;
;; RtlVerifyVersionInfo() os product type values
;;

(defwin32constant +ver-nt-workstation+              #x0000001)
(defwin32constant +ver-nt-domain-controller+        #x0000002)
(defwin32constant +ver-nt-server+                   #x0000003)

(defwin32constant +ver-server-nt+                       #x80000000)
(defwin32constant +ver-workstation-nt+                  #x40000000)
(defwin32constant +ver-suite-smallbusiness+             #x00000001)
(defwin32constant +ver-suite-enterprise+                #x00000002)
(defwin32constant +ver-suite-backoffice+                #x00000004)
(defwin32constant +ver-suite-communications+            #x00000008)
(defwin32constant +ver-suite-terminal+                  #x00000010)
(defwin32constant +ver-suite-smallbusiness-restricted+  #x00000020)
(defwin32constant +ver-suite-embeddednt+                #x00000040)
(defwin32constant +ver-suite-datacenter+                #x00000080)
(defwin32constant +ver-suite-singleuserts+              #x00000100)
(defwin32constant +ver-suite-personal+                  #x00000200)
(defwin32constant +ver-suite-blade+                     #x00000400)
(defwin32constant +ver-suite-embedded-restricted+       #x00000800)
(defwin32constant +ver-suite-security-appliance+        #x00001000)
(defwin32constant +ver-suite-storage-server+            #x00002000)
(defwin32constant +ver-suite-compute-server+            #x00004000)
(defwin32constant +ver-suite-wh-server+                 #x00008000)

;;
;; dwPlatformId defines:
;;

(defwin32constant +ver-platform-win32s+             0)
(defwin32constant +ver-platform-win32-windows+      1)
(defwin32constant +ver-platform-win32-nt+           2)

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

;;; Window styles
(defwin32constant +ws-overlapped+       #x00000000)
(defwin32constant +ws-popup+            #x80000000)
(defwin32constant +ws-child+            #x40000000)
(defwin32constant +ws-minimize+         #x20000000)
(defwin32constant +ws-visible+          #x10000000)
(defwin32constant +ws-disabled+         #x08000000)
(defwin32constant +ws-clipsiblings+     #x04000000)
(defwin32constant +ws-clipchildren+     #x02000000)
(defwin32constant +ws-maximize+         #x01000000)
(defwin32constant +ws-caption+          #x00C00000)
(defwin32constant +ws-border+           #x00800000)
(defwin32constant +ws-dlgframe+         #x00400000)
(defwin32constant +ws-vscroll+          #x00200000)
(defwin32constant +ws-hscroll+          #x00100000)
(defwin32constant +ws-sysmenu+          #x00080000)
(defwin32constant +ws-thickframe+       #x00040000)
(defwin32constant +ws-group+            #x00020000)
(defwin32constant +ws-tabstop+          #x00010000)

(defwin32constant +ws-minimizebox+      #x00020000)
(defwin32constant +ws-maximizebox+      #x00010000)


(defwin32constant +ws-tiled+            +ws-overlapped+)
(defwin32constant +ws-iconic+           +ws-minimize+)
(defwin32constant +ws-sizebox+          +ws-thickframe+)
(defwin32constant +ws-overlappedwindow+ (logior
                                         +ws-overlapped+
                                         +ws-caption+
                                         +ws-sysmenu+
                                         +ws-thickframe+
                                         +ws-minimizebox+
                                         +ws-maximizebox+))
(defwin32constant +ws-tiledwindow+      +ws-overlappedwindow+)

;;; Common Window Styles

(defwin32constant +ws-popupwindow+      (logior
                                         +ws-popup+
                                         +ws-border+
                                         +ws-sysmenu+))

(defwin32constant +ws-childwindow+      +ws-child+)

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

;;; Virtual Keys, Standard Set

(defwin32constant +vk-lbutton+        #x01)
(defwin32constant +vk-rbutton+        #x02)
(defwin32constant +vk-cancel+         #x03)
(defwin32constant +vk-mbutton+        #x04)    ; NOT contiguous with L & RBUTTON

(defwin32constant +vk-xbutton1+       #x05)    ; NOT contiguous with L & RBUTTON
(defwin32constant +vk-xbutton2+       #x06)    ; NOT contiguous with L & RBUTTON

;;; #x07 : reserved


(defwin32constant +vk-back+           #x08)
(defwin32constant +vk-tab+            #x09)

;;; #x0A - #x0B : reserved

(defwin32constant +vk-clear+          #x0C)
(defwin32constant +vk-return+         #x0D)

;;; #x0E - #x0F : unassigned

(defwin32constant +vk-shift+          #x10)
(defwin32constant +vk-control+        #x11)
(defwin32constant +vk-menu+           #x12)
(defwin32constant +vk-pause+          #x13)
(defwin32constant +vk-capital+        #x14)

(defwin32constant +vk-kana+           #x15)
(defwin32constant +vk-hangeul+        #x15)  ; old name - should be here for compatibility
(defwin32constant +vk-hangul+         #x15)

;;; #x16 : unassigned

(defwin32constant +vk-junja+          #x17)
(defwin32constant +vk-final+          #x18)
(defwin32constant +vk-hanja+          #x19)
(defwin32constant +vk-kanji+          #x19)


;;; #x1A : unassigned

(defwin32constant +vk-escape+         #x1B)

(defwin32constant +vk-convert+        #x1C)
(defwin32constant +vk-nonconvert+     #x1D)
(defwin32constant +vk-accept+         #x1E)
(defwin32constant +vk-modechange+     #x1F)

(defwin32constant +vk-space+          #x20)
(defwin32constant +vk-prior+          #x21)
(defwin32constant +vk-next+           #x22)
(defwin32constant +vk-end+            #x23)
(defwin32constant +vk-home+           #x24)
(defwin32constant +vk-left+           #x25)
(defwin32constant +vk-up+             #x26)
(defwin32constant +vk-right+          #x27)
(defwin32constant +vk-down+           #x28)
(defwin32constant +vk-select+         #x29)
(defwin32constant +vk-print+          #x2A)
(defwin32constant +vk-execute+        #x2B)
(defwin32constant +vk-snapshot+       #x2C)
(defwin32constant +vk-insert+         #x2D)
(defwin32constant +vk-delete+         #x2E)
(defwin32constant +vk-help+           #x2F)

;;; VK-0 - VK-9 are the same as ASCII '0' - '9' (#x30 - #x39)
;;; #x3A - #x40 : unassigned
;;; VK-A - VK-Z are the same as ASCII 'A' - 'Z' (#x41 - #x5A)

(defwin32constant +vk-lwin+           #x5B)
(defwin32constant +vk-rwin+           #x5C)
(defwin32constant +vk-apps+           #x5D)

;;; #x5E : reserved

(defwin32constant +vk-sleep+          #x5F)

(defwin32constant +vk-numpad0+        #x60)
(defwin32constant +vk-numpad1+        #x61)
(defwin32constant +vk-numpad2+        #x62)
(defwin32constant +vk-numpad3+        #x63)
(defwin32constant +vk-numpad4+        #x64)
(defwin32constant +vk-numpad5+        #x65)
(defwin32constant +vk-numpad6+        #x66)
(defwin32constant +vk-numpad7+        #x67)
(defwin32constant +vk-numpad8+        #x68)
(defwin32constant +vk-numpad9+        #x69)
(defwin32constant +vk-multiply+       #x6A)
(defwin32constant +vk-add+            #x6B)
(defwin32constant +vk-separator+      #x6C)
(defwin32constant +vk-subtract+       #x6D)
(defwin32constant +vk-decimal+        #x6E)
(defwin32constant +vk-divide+         #x6F)
(defwin32constant +vk-f1+             #x70)
(defwin32constant +vk-f2+             #x71)
(defwin32constant +vk-f3+             #x72)
(defwin32constant +vk-f4+             #x73)
(defwin32constant +vk-f5+             #x74)
(defwin32constant +vk-f6+             #x75)
(defwin32constant +vk-f7+             #x76)
(defwin32constant +vk-f8+             #x77)
(defwin32constant +vk-f9+             #x78)
(defwin32constant +vk-f10+            #x79)
(defwin32constant +vk-f11+            #x7A)
(defwin32constant +vk-f12+            #x7B)
(defwin32constant +vk-f13+            #x7C)
(defwin32constant +vk-f14+            #x7D)
(defwin32constant +vk-f15+            #x7E)
(defwin32constant +vk-f16+            #x7F)
(defwin32constant +vk-f17+            #x80)
(defwin32constant +vk-f18+            #x81)
(defwin32constant +vk-f19+            #x82)
(defwin32constant +vk-f20+            #x83)
(defwin32constant +vk-f21+            #x84)
(defwin32constant +vk-f22+            #x85)
(defwin32constant +vk-f23+            #x86)
(defwin32constant +vk-f24+            #x87)

;;; #x88 - #x8F : UI navigation

(defwin32constant +vk-navigation-view+     #x88) ; reserved
(defwin32constant +vk-navigation-menu+     #x89) ; reserved
(defwin32constant +vk-navigation-up+       #x8A) ; reserved
(defwin32constant +vk-navigation-down+     #x8B) ; reserved
(defwin32constant +vk-navigation-left+     #x8C) ; reserved
(defwin32constant +vk-navigation-right+    #x8D) ; reserved
(defwin32constant +vk-navigation-accept+   #x8E) ; reserved
(defwin32constant +vk-navigation-cancel+   #x8F) ; reserved

(defwin32constant +vk-numlock+        #x90)
(defwin32constant +vk-scroll+         #x91)

;;; NEC PC-9800 kbd definitions
(defwin32constant +vk-oem-nec-equal+  #x92)   ; '=' key on numpad

;;; Fujitsu/OASYS kbd definitions

(defwin32constant +vk-oem-fj-jisho+   #x92)   ; 'Dictionary' key
(defwin32constant +vk-oem-fj-masshou+ #x93)   ; 'Unregister word' key
(defwin32constant +vk-oem-fj-touroku+ #x94)   ; 'Register word' key
(defwin32constant +vk-oem-fj-loya+    #x95)   ; 'Left OYAYUBI' key
(defwin32constant +vk-oem-fj-roya+    #x96)   ; 'Right OYAYUBI' key

;;; #x97 - #x9F : unassigned

;;; VK-L* & VK-R* - left and right Alt, Ctrl and Shift virtual keys.
;;; Used only as parameters to GetAsyncKeyState() and GetKeyState().
;;; No other API or message will distinguish left and right keys in this way.

(defwin32constant +vk-lshift+         #xA0)
(defwin32constant +vk-rshift+         #xA1)
(defwin32constant +vk-lcontrol+       #xA2)
(defwin32constant +vk-rcontrol+       #xA3)
(defwin32constant +vk-lmenu+          #xA4)
(defwin32constant +vk-rmenu+          #xA5)

(defwin32constant +vk-browser-back+        #xA6)
(defwin32constant +vk-browser-forward+     #xA7)
(defwin32constant +vk-browser-refresh+     #xA8)
(defwin32constant +vk-browser-stop+        #xA9)
(defwin32constant +vk-browser-search+      #xAA)
(defwin32constant +vk-browser-favorites+   #xAB)
(defwin32constant +vk-browser-home+        #xAC)

(defwin32constant +vk-volume-mute+         #xAD)
(defwin32constant +vk-volume-down+         #xAE)
(defwin32constant +vk-volume-up+           #xAF)
(defwin32constant +vk-media-next-track+    #xB0)
(defwin32constant +vk-media-prev-track+    #xB1)
(defwin32constant +vk-media-stop+          #xB2)
(defwin32constant +vk-media-play-pause+    #xB3)
(defwin32constant +vk-launch-mail+         #xB4)
(defwin32constant +vk-launch-media-select+ #xB5)
(defwin32constant +vk-launch-app1+         #xB6)
(defwin32constant +vk-launch-app2+         #xB7)


;;; #xB8 - #xB9 : reserved

(defwin32constant +vk-oem-1+          #xBA)   ; ';:' for US
(defwin32constant +vk-oem-plus+       #xBB)   ; '+' any country
(defwin32constant +vk-oem-comma+      #xBC)   ; ',' any country
(defwin32constant +vk-oem-minus+      #xBD)   ; '-' any country
(defwin32constant +vk-oem-period+     #xBE)   ; '.' any country
(defwin32constant +vk-oem-2+          #xBF)   ; '/?' for US
(defwin32constant +vk-oem-3+          #xC0)   ; '`~' for US

;;; #xC1 - #xC2 : reserved

;;; #xC3 - #xDA : Gamepad input

(defwin32constant +vk-gamepad-a+                         #xC3) ; reserved
(defwin32constant +vk-gamepad-b+                         #xC4) ; reserved
(defwin32constant +vk-gamepad-x+                         #xC5) ; reserved
(defwin32constant +vk-gamepad-y+                         #xC6) ; reserved
(defwin32constant +vk-gamepad-right-shoulder+            #xC7) ; reserved
(defwin32constant +vk-gamepad-left-shoulder+             #xC8) ; reserved
(defwin32constant +vk-gamepad-left-trigger+              #xC9) ; reserved
(defwin32constant +vk-gamepad-right-trigger+             #xCA) ; reserved
(defwin32constant +vk-gamepad-dpad-up+                   #xCB) ; reserved
(defwin32constant +vk-gamepad-dpad-down+                 #xCC) ; reserved
(defwin32constant +vk-gamepad-dpad-left+                 #xCD) ; reserved
(defwin32constant +vk-gamepad-dpad-right+                #xCE) ; reserved
(defwin32constant +vk-gamepad-menu+                      #xCF) ; reserved
(defwin32constant +vk-gamepad-view+                      #xD0) ; reserved
(defwin32constant +vk-gamepad-left-thumbstick-button+    #xD1) ; reserved
(defwin32constant +vk-gamepad-right-thumbstick-button+   #xD2) ; reserved
(defwin32constant +vk-gamepad-left-thumbstick-up+        #xD3) ; reserved
(defwin32constant +vk-gamepad-left-thumbstick-down+      #xD4) ; reserved
(defwin32constant +vk-gamepad-left-thumbstick-right+     #xD5) ; reserved
(defwin32constant +vk-gamepad-left-thumbstick-left+      #xD6) ; reserved
(defwin32constant +vk-gamepad-right-thumbstick-up+       #xD7) ; reserved
(defwin32constant +vk-gamepad-right-thumbstick-down+     #xD8) ; reserved
(defwin32constant +vk-gamepad-right-thumbstick-right+    #xD9) ; reserved
(defwin32constant +vk-gamepad-right-thumbstick-left+     #xDA) ; reserved

(defwin32constant +vk-oem-4+          #xDB)  ;  '[{' for US
(defwin32constant +vk-oem-5+          #xDC)  ;  '\|' for US
(defwin32constant +vk-oem-6+          #xDD)  ;  ']}' for US
(defwin32constant +vk-oem-7+          #xDE)  ;  ''"' for US
(defwin32constant +vk-oem-8+          #xDF)

;;; #xE0 : reserved

;;; Various extended or enhanced keyboards
(defwin32constant +vk-oem-ax+         #xE1)  ;  'AX' key on Japanese AX kbd
(defwin32constant +vk-oem-102+        #xE2)  ;  "<>" or "\|" on RT 102-key kbd.
(defwin32constant +vk-ico-help+       #xE3)  ;  Help key on ICO
(defwin32constant +vk-ico-00+         #xE4)  ;  00 key on ICO

(defwin32constant +vk-processkey+     #xE5)

(defwin32constant +vk-ico-clear+      #xE6)


(defwin32constant +vk-packet+         #xE7)

;;; #xE8 : unassigned

;;; Nokia/Ericsson definitions
(defwin32constant +vk-oem-reset+      #xE9)
(defwin32constant +vk-oem-jump+       #xEA)
(defwin32constant +vk-oem-pa1+        #xEB)
(defwin32constant +vk-oem-pa2+        #xEC)
(defwin32constant +vk-oem-pa3+        #xED)
(defwin32constant +vk-oem-wsctrl+     #xEE)
(defwin32constant +vk-oem-cusel+      #xEF)
(defwin32constant +vk-oem-attn+       #xF0)
(defwin32constant +vk-oem-finish+     #xF1)
(defwin32constant +vk-oem-copy+       #xF2)
(defwin32constant +vk-oem-auto+       #xF3)
(defwin32constant +vk-oem-enlw+       #xF4)
(defwin32constant +vk-oem-backtab+    #xF5)

(defwin32constant +vk-attn+           #xF6)
(defwin32constant +vk-crsel+          #xF7)
(defwin32constant +vk-exsel+          #xF8)
(defwin32constant +vk-ereof+          #xF9)
(defwin32constant +vk-play+           #xFA)
(defwin32constant +vk-zoom+           #xFB)
(defwin32constant +vk-noname+         #xFC)
(defwin32constant +vk-pa1+            #xFD)
(defwin32constant +vk-oem-clear+      #xFE)

;;; #xFF : reserved


;;
;; SetWindowsHook() codes
;;
(defwin32constant +wh-min+              -1)
(defwin32constant +wh-msgfilter+        -1)
(defwin32constant +wh-journalrecord+    0)
(defwin32constant +wh-journalplayback+  1)
(defwin32constant +wh-keyboard+         2)
(defwin32constant +wh-getmessage+       3)
(defwin32constant +wh-callwndproc+      4)
(defwin32constant +wh-cbt+              5)
(defwin32constant +wh-sysmsgfilter+     6)
(defwin32constant +wh-mouse+            7)
(defwin32constant +wh-hardware+         8)
(defwin32constant +wh-debug+            9)
(defwin32constant +wh-shell+           10)
(defwin32constant +wh-foregroundidle+  11)
(defwin32constant +wh-callwndprocret+  12)
(defwin32constant +wh-keyboard-ll+     13)
(defwin32constant +wh-mouse-ll+        14)
(defwin32constant +wh-max+             14)

(defwin32constant +wh-minhook+         +wh-min+)
(defwin32constant +wh-maxhook+         +wh-max+)

;;
;; Hook Codes
;;
(defwin32constant +hc-action+           0)
(defwin32constant +hc-getnext+          1)
(defwin32constant +hc-skip+             2)
(defwin32constant +hc-noremove+         3)
(defwin32constant +hc-norem+            +hc-noremove+)
(defwin32constant +hc-sysmodalon+       4)
(defwin32constant +hc-sysmodaloff+      5)

;;
;; CBT Hook Codes
;;
(defwin32constant +hcbt-movesize+       0)
(defwin32constant +hcbt-minmax+         1)
(defwin32constant +hcbt-qs+             2)
(defwin32constant +hcbt-createwnd+      3)
(defwin32constant +hcbt-destroywnd+     4)
(defwin32constant +hcbt-activate+       5)
(defwin32constant +hcbt-clickskipped+   6)
(defwin32constant +hcbt-keyskipped+     7)
(defwin32constant +hcbt-syscommand+     8)
(defwin32constant +hcbt-setfocus+       9)

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

(defwin32constant +flashw-stop+         0)
(defwin32constant +flashw-caption+      #x00000001)
(defwin32constant +flashw-tray+         #x00000002)
(defwin32constant +flashw-all+          (logior +flashw-caption+ +flashw-tray+))
(defwin32constant +flashw-timer+        #x00000004)
(defwin32constant +flashw-timernofg+    #x0000000C)

(defwin32constant +cs-vredraw+ #x0001)
(defwin32constant +cs-hredraw+ #x0002)
(defwin32constant +cs-owndc+   #x0020)

(defwin32constant +sw-hide+             0)
(defwin32constant +sw-shownormal+       1)
(defwin32constant +sw-normal+           1)
(defwin32constant +sw-showminimized+    2)
(defwin32constant +sw-showmaximized+    3)
(defwin32constant +sw-maximize+         3)
(defwin32constant +sw-shownoactivate+   4)
(defwin32constant +sw-show+             5)
(defwin32constant +sw-minimize+         6)
(defwin32constant +sw-showminnoactive+  7)
(defwin32constant +sw-showna+           8)
(defwin32constant +sw-restore+          9)
(defwin32constant +sw-showdefault+      10)
(defwin32constant +sw-forceminimize+    11)
(defwin32constant +sw-max+              11)

;; Old ShowWindow() Commands
(defwin32constant +hide-window+         0)
(defwin32constant +show-openwindow+     1)
(defwin32constant +show-iconwindow+     2)
(defwin32constant +show-fullscreen+     3)
(defwin32constant +show-opennoactivate+ 4)

;; Identifiers for the WM_SHOWWINDOW message
(defwin32constant +sw-parentclosing+    1)
(defwin32constant +sw-otherzoom+        2)
(defwin32constant +sw-parentopening+    3)
(defwin32constant +sw-otherunzoom+      4)

(defwin32constant +idi-application+     (make-pointer 32512))
(defwin32constant +idi-hand+            (make-pointer 32513))
(defwin32constant +idi-question+        (make-pointer 32514))
(defwin32constant +idi-exclamation+     (make-pointer 32515))
(defwin32constant +idi-asterisk+        (make-pointer 32516))
(defwin32constant +idi-winlogo+         (make-pointer 32517))
(defwin32constant +idi-shield+          (make-pointer 32518))

(defwin32constant +idi-warning+     +idi-exclamation+)
(defwin32constant +idi-error+       +idi-hand+)
(defwin32constant +idi-information+ +idi-asterisk+)


;;; Dialog Box Command IDs
(defwin32constant +idok+                1)
(defwin32constant +idcancel+            2)
(defwin32constant +idabort+             3)
(defwin32constant +idretry+             4)
(defwin32constant +idignore+            5)
(defwin32constant +idyes+               6)
(defwin32constant +idno+                7)
(defwin32constant +idclose+         8)
(defwin32constant +idhelp+          9)
(defwin32constant +idtryagain+      10)
(defwin32constant +idcontinue+      11)
(defwin32constant +idtimeout+ 32000)

;;; Edit Control Styles
(defwin32constant +es-left+             #x0000)
(defwin32constant +es-center+           #x0001)
(defwin32constant +es-right+            #x0002)
(defwin32constant +es-multiline+        #x0004)
(defwin32constant +es-uppercase+        #x0008)
(defwin32constant +es-lowercase+        #x0010)
(defwin32constant +es-password+         #x0020)
(defwin32constant +es-autovscroll+      #x0040)
(defwin32constant +es-autohscroll+      #x0080)
(defwin32constant +es-nohidesel+        #x0100)
(defwin32constant +es-oemconvert+       #x0400)
(defwin32constant +es-readonly+         #x0800)
(defwin32constant +es-wantreturn+       #x1000)
(defwin32constant +es-number+           #x2000)

;;; Edit Control Notification Codes
(defwin32constant +en-setfocus+         #x0100)
(defwin32constant +en-killfocus+        #x0200)
(defwin32constant +en-change+           #x0300)
(defwin32constant +en-update+           #x0400)
(defwin32constant +en-errspace+         #x0500)
(defwin32constant +en-maxtext+          #x0501)
(defwin32constant +en-hscroll+          #x0601)
(defwin32constant +en-vscroll+          #x0602)
(defwin32constant +en-align-ltr-ec+     #x0700)
(defwin32constant +en-align-rtl-ec+     #x0701)
(defwin32constant +en-before-paste+     #x0800)
(defwin32constant +en-after-paste+      #x0801)

;;; Edit control EM-SETMARGIN parameters
(defwin32constant +ec-leftmargin+       #x0001)
(defwin32constant +ec-rightmargin+      #x0002)
(defwin32constant +ec-usefontinfo+      #xffff)

;;; wParam of EM-GET/SETIMESTATUS
(defwin32constant +emsis-compositionstring+        #x0001)

;;; lParam for EMSIS-COMPOSITIONSTRING
(defwin32constant +eimes-getcompstratonce+         #x0001)
(defwin32constant +eimes-cancelcompstrinfocus+     #x0002)
(defwin32constant +eimes-completecompstrkillfocus+ #x0004)

;;; Edit Control Messages
(defwin32constant +em-getsel+               #x00b0)
(defwin32constant +em-setsel+               #x00b1)
(defwin32constant +em-getrect+              #x00b2)
(defwin32constant +em-setrect+              #x00b3)
(defwin32constant +em-setrectnp+            #x00b4)
(defwin32constant +em-scroll+               #x00b5)
(defwin32constant +em-linescroll+           #x00b6)
(defwin32constant +em-scrollcaret+          #x00b7)
(defwin32constant +em-getmodify+            #x00b8)
(defwin32constant +em-setmodify+            #x00b9)
(defwin32constant +em-getlinecount+         #x00ba)
(defwin32constant +em-lineindex+            #x00bb)
(defwin32constant +em-sethandle+            #x00bc)
(defwin32constant +em-gethandle+            #x00bd)
(defwin32constant +em-getthumb+             #x00be)
(defwin32constant +em-linelength+           #x00c1)
(defwin32constant +em-replacesel+           #x00c2)
(defwin32constant +em-getline+              #x00c4)
(defwin32constant +em-limittext+            #x00c5)
(defwin32constant +em-canundo+              #x00c6)
(defwin32constant +em-undo+                 #x00c7)
(defwin32constant +em-fmtlines+             #x00c8)
(defwin32constant +em-linefromchar+         #x00c9)
(defwin32constant +em-settabstops+          #x00cb)
(defwin32constant +em-setpasswordchar+      #x00cc)
(defwin32constant +em-emptyundobuffer+      #x00cd)
(defwin32constant +em-getfirstvisibleline+  #x00ce)
(defwin32constant +em-setreadonly+          #x00cf)
(defwin32constant +em-setwordbreakproc+     #x00d0)
(defwin32constant +em-getwordbreakproc+     #x00d1)
(defwin32constant +em-getpasswordchar+      #x00d2)
(defwin32constant +em-setmargins+           #x00d3)
(defwin32constant +em-getmargins+           #x00d4)
(defwin32constant +em-setlimittext+         +em-limittext+)
(defwin32constant +em-getlimittext+         #x00d5)
(defwin32constant +em-posfromchar+          #x00d6)
(defwin32constant +em-charfrompos+          #x00d7)
(defwin32constant +em-setimestatus+         #x00d8)
(defwin32constant +em-getimestatus+         #x00d9)
(defwin32constant +em-enablefeature+        #x00da)

;;; Button Control Styles
(defwin32constant +bs-pushbutton+       #x00000000)
(defwin32constant +bs-defpushbutton+    #x00000001)
(defwin32constant +bs-checkbox+         #x00000002)
(defwin32constant +bs-autocheckbox+     #x00000003)
(defwin32constant +bs-radiobutton+      #x00000004)
(defwin32constant +bs-3state+           #x00000005)
(defwin32constant +bs-auto3state+       #x00000006)
(defwin32constant +bs-groupbox+         #x00000007)
(defwin32constant +bs-userbutton+       #x00000008)
(defwin32constant +bs-autoradiobutton+  #x00000009)
(defwin32constant +bs-pushbox+          #x0000000A)
(defwin32constant +bs-ownerdraw+        #x0000000B)
(defwin32constant +bs-typemask+         #x0000000F)
(defwin32constant +bs-lefttext+         #x00000020)
(defwin32constant +bs-text+             #x00000000)
(defwin32constant +bs-icon+             #x00000040)
(defwin32constant +bs-bitmap+           #x00000080)
(defwin32constant +bs-left+             #x00000100)
(defwin32constant +bs-right+            #x00000200)
(defwin32constant +bs-center+           #x00000300)
(defwin32constant +bs-top+              #x00000400)
(defwin32constant +bs-bottom+           #x00000800)
(defwin32constant +bs-vcenter+          #x00000C00)
(defwin32constant +bs-pushlike+         #x00001000)
(defwin32constant +bs-multiline+        #x00002000)
(defwin32constant +bs-notify+           #x00004000)
(defwin32constant +bs-flat+             #x00008000)
(defwin32constant +bs-rightbutton+      +bs-lefttext+)

;;; User Button Notification Codes
(defwin32constant +bn-clicked+          0)
(defwin32constant +bn-paint+            1)
(defwin32constant +bn-hilite+           2)
(defwin32constant +bn-unhilite+         3)
(defwin32constant +bn-disable+          4)
(defwin32constant +bn-doubleclicked+    5)
(defwin32constant +bn-pushed+           +bn-hilite+)
(defwin32constant +bn-unpushed+         +bn-unhilite+)
(defwin32constant +bn-dblclk+           +bn-doubleclicked+)
(defwin32constant +bn-setfocus+         6)
(defwin32constant +bn-killfocus+        7)

;;; Button Control Messages
(defwin32constant +bm-getcheck+        #x00F0)
(defwin32constant +bm-setcheck+        #x00F1)
(defwin32constant +bm-getstate+        #x00F2)
(defwin32constant +bm-setstate+        #x00F3)
(defwin32constant +bm-setstyle+        #x00F4)
(defwin32constant +bm-click+           #x00F5)
(defwin32constant +bm-getimage+        #x00F6)
(defwin32constant +bm-setimage+        #x00F7)
(defwin32constant +bm-setdontclick+    #x00F8)


(defwin32constant +bst-unchecked+      #x0000)
(defwin32constant +bst-checked+        #x0001)
(defwin32constant +bst-indeterminate+  #x0002)
(defwin32constant +bst-pushed+         #x0004)
(defwin32constant +bst-focus+          #x0008)

;; Static Control Constants
(defwin32constant +ss-left+             #x00000000)
(defwin32constant +ss-center+           #x00000001)
(defwin32constant +ss-right+            #x00000002)
(defwin32constant +ss-icon+             #x00000003)
(defwin32constant +ss-blackrect+        #x00000004)
(defwin32constant +ss-grayrect+         #x00000005)
(defwin32constant +ss-whiterect+        #x00000006)
(defwin32constant +ss-blackframe+       #x00000007)
(defwin32constant +ss-grayframe+        #x00000008)
(defwin32constant +ss-whiteframe+       #x00000009)
(defwin32constant +ss-useritem+         #x0000000A)
(defwin32constant +ss-simple+           #x0000000B)
(defwin32constant +ss-leftnowordwrap+   #x0000000C)
(defwin32constant +ss-ownerdraw+        #x0000000D)
(defwin32constant +ss-bitmap+           #x0000000E)
(defwin32constant +ss-enhmetafile+      #x0000000F)
(defwin32constant +ss-etchedhorz+       #x00000010)
(defwin32constant +ss-etchedvert+       #x00000011)
(defwin32constant +ss-etchedframe+      #x00000012)
(defwin32constant +ss-typemask+         #x0000001F)
(defwin32constant +ss-realsizecontrol+  #x00000040)
(defwin32constant +ss-noprefix+         #x00000080)
(defwin32constant +ss-notify+           #x00000100)
(defwin32constant +ss-centerimage+      #x00000200)
(defwin32constant +ss-rightjust+        #x00000400)
(defwin32constant +ss-realsizeimage+    #x00000800)
(defwin32constant +ss-sunken+           #x00001000)
(defwin32constant +ss-editcontrol+      #x00002000)
(defwin32constant +ss-endellipsis+      #x00004000)
(defwin32constant +ss-pathellipsis+     #x00008000)
(defwin32constant +ss-wordellipsis+     #x0000C000)
(defwin32constant +ss-ellipsismask+     #x0000C000)

;;; Static Control Mesages
(defwin32constant +stm-seticon+         #x0170)
(defwin32constant +stm-geticon+         #x0171)
(defwin32constant +stm-setimage+        #x0172)
(defwin32constant +stm-getimage+        #x0173)
(defwin32constant +stn-clicked+         0)
(defwin32constant +stn-dblclk+          1)
(defwin32constant +stn-enable+          2)
(defwin32constant +stn-disable+         3)
(defwin32constant +stm-msgmax+          #x0174)

(defwin32constant +idc-arrow+           (make-pointer 32512))
(defwin32constant +idc-ibeam+           (make-pointer 32513))
(defwin32constant +idc-wait+            (make-pointer 32514))
(defwin32constant +idc-cross+           (make-pointer 32515))
(defwin32constant +idc-uparrow+         (make-pointer 32516))
(defwin32constant +idc-size+            (make-pointer 32640)) ; OBSOLETE: use IDC_SIZEALL
(defwin32constant +idc-icon+            (make-pointer 32641)) ; OBSOLETE: use IDC_ARROW
(defwin32constant +idc-sizenwse+        (make-pointer 32642))
(defwin32constant +idc-sizenesw+        (make-pointer 32643))
(defwin32constant +idc-sizewe+          (make-pointer 32644))
(defwin32constant +idc-sizens+          (make-pointer 32645))
(defwin32constant +idc-sizeall+         (make-pointer 32646))
(defwin32constant +idc-no+              (make-pointer 32648)) ; /*not in win3.1 */
(defwin32constant +idc-hand+            (make-pointer 32649))
(defwin32constant +idc-appstarting+     (make-pointer 32650)) ; /*not in win3.1 */
(defwin32constant +idc-help+            (make-pointer 32651))

(defwin32constant +image-bitmap+        0)
(defwin32constant +image-icon+          1)
(defwin32constant +image-cursor+        2)
(defwin32constant +image-enhmetafile+   3)

(defwin32constant +lr-defaultcolor+     #x00000000)
(defwin32constant +lr-monochrome+       #x00000001)
(defwin32constant +lr-color+            #x00000002)
(defwin32constant +lr-copyreturnorg+    #x00000004)
(defwin32constant +lr-copydeleteorg+    #x00000008)
(defwin32constant +lr-loadfromfile+     #x00000010)
(defwin32constant +lr-loadtransparent+  #x00000020)
(defwin32constant +lr-defaultsize+      #x00000040)
(defwin32constant +lr-vgacolor+         #x00000080)
(defwin32constant +lr-loadmap3dcolors+  #x00001000)
(defwin32constant +lr-createdibsection+ #x00002000)
(defwin32constant +lr-copyfromresource+ #x00004000)
(defwin32constant +lr-shared+           #x00008000)

;;; Binary raster ops
(defwin32constant +r2-black+            1)   ;  0
(defwin32constant +r2-notmergepen+      2)   ; DPon
(defwin32constant +r2-masknotpen+       3)   ; DPna
(defwin32constant +r2-notcopypen+       4)   ; PN
(defwin32constant +r2-maskpennot+       5)   ; PDna
(defwin32constant +r2-not+              6)   ; Dn
(defwin32constant +r2-xorpen+           7)   ; DPx
(defwin32constant +r2-notmaskpen+       8)   ; DPan
(defwin32constant +r2-maskpen+          9)   ; DPa
(defwin32constant +r2-notxorpen+        10)  ; DPxn
(defwin32constant +r2-nop+              11)  ; D
(defwin32constant +r2-mergenotpen+      12)  ; DPno
(defwin32constant +r2-copypen+          13)  ; P
(defwin32constant +r2-mergepennot+      14)  ; PDno
(defwin32constant +r2-mergepen+         15)  ; DPo
(defwin32constant +r2-white+            16)  ;  1
(defwin32constant +r2-last+             16)

;;; Ternary raster operations
(defwin32constant +srccopy+             #x00CC0020) ; dest = source
(defwin32constant +srcpaint+            #x00EE0086) ; dest = source OR dest
(defwin32constant +srcand+              #x008800C6) ; dest = source AND dest
(defwin32constant +srcinvert+           #x00660046) ; dest = source XOR dest
(defwin32constant +srcerase+            #x00440328) ; dest = source AND (NOT dest )
(defwin32constant +notsrccopy+          #x00330008) ; dest = (NOT source)
(defwin32constant +notsrcerase+         #x001100A6) ; dest = (NOT src) AND (NOT dest)
(defwin32constant +mergecopy+           #x00C000CA) ; dest = (source AND pattern)
(defwin32constant +mergepaint+          #x00BB0226) ; dest = (NOT source) OR dest
(defwin32constant +patcopy+             #x00F00021) ; dest = pattern
(defwin32constant +patpaint+            #x00FB0A09) ; dest = DPSnoo
(defwin32constant +patinvert+           #x005A0049) ; dest = pattern XOR dest
(defwin32constant +dstinvert+           #x00550009) ; dest = (NOT dest)
(defwin32constant +blackness+           #x00000042) ; dest = BLACK
(defwin32constant +whiteness+           #x00FF0062) ; dest = WHITE

(defwin32constant +nomirrorbitmap+               #x80000000) ; Do not Mirror the bitmap in this call
(defwin32constant +captureblt+                   #x40000000) ; Include layered windows

(defwin32constant +gdi-error+ #xFFFFFFFF)

(defwin32constant +hgdi-error+ (cffi:make-pointer #xFFFFFFFF))

;;; Region Flags
(defwin32constant +error+               0)
(defwin32constant +nullregion+          1)
(defwin32constant +simpleregion+        2)
(defwin32constant +complexregion+       3)
(defwin32constant +rgn-error+ +error+)

;;; CombineRgn() Styles
(defwin32constant +rgn-and+             1)
(defwin32constant +rgn-or+              2)
(defwin32constant +rgn-xor+             3)
(defwin32constant +rgn-diff+            4)
(defwin32constant +rgn-copy+            5)
(defwin32constant +rgn-min+             +rgn-and+)
(defwin32constant +rgn-max+             +rgn-copy+)

;;; StretchBlt() Modes
(defwin32constant +blackonwhite+                 1)
(defwin32constant +whiteonblack+                 2)
(defwin32constant +coloroncolor+                 3)
(defwin32constant +halftone+                     4)
(defwin32constant +maxstretchbltmode+            4)

;;; New StretchBlt() Modes
(defwin32constant +stretch-andscans+    +blackonwhite+)
(defwin32constant +stretch-orscans+     +whiteonblack+)
(defwin32constant +stretch-deletescans+ +coloroncolor+)
(defwin32constant +stretch-halftone+    +halftone+)

;;; PolyFill() Modes
(defwin32constant +alternate+                    1)
(defwin32constant +winding+                      2)
(defwin32constant +polyfill-last+                2)

;;; Layout Orientation Options
(defwin32constant +layout-rtl+                         #x00000001) ;; Right to left
(defwin32constant +layout-btt+                         #x00000002) ;; Bottom to top
(defwin32constant +layout-vbh+                         #x00000004) ;; Vertical before horizontal
(defwin32constant +layout-orientationmask+             (logior +layout-rtl+ +layout-btt+ +layout-vbh+))
(defwin32constant +layout-bitmaporientationpreserved+  #x00000008)

;;; Text Alignment Options
(defwin32constant +ta-noupdatecp+                0)
(defwin32constant +ta-updatecp+                  1)

(defwin32constant +ta-left+                      0)
(defwin32constant +ta-right+                     2)
(defwin32constant +ta-center+                    6)

(defwin32constant +ta-top+                       0)
(defwin32constant +ta-bottom+                    8)
(defwin32constant +ta-baseline+                  24)

(defwin32constant +ta-rtlreading+                256)
(defwin32constant +ta-mask+       (+ +ta-baseline+ +ta-center+ +ta-updatecp+ +ta-rtlreading+))

(defwin32constant +vta-baseline+ +ta-baseline+)
(defwin32constant +vta-left+     +ta-bottom+)
(defwin32constant +vta-right+    +ta-top+)
(defwin32constant +vta-center+   +ta-center+)
(defwin32constant +vta-bottom+   +ta-right+)
(defwin32constant +vta-top+      +ta-left+)

(defwin32constant +eto-opaque+                   #x0002)
(defwin32constant +eto-clipped+                  #x0004)

(defwin32constant +eto-glyph-index+              #x0010)
(defwin32constant +eto-rtlreading+               #x0080)
(defwin32constant +eto-numericslocal+            #x0400)
(defwin32constant +eto-numericslatin+            #x0800)
(defwin32constant +eto-ignorelanguage+           #x1000)

(defwin32constant +eto-pdy+                      #x2000)

(defwin32constant +eto-reverse-index-map+        #x10000)

(defwin32constant +aspect-filtering+             #x0001)

;;; EnumFonts Masks
(defwin32constant +raster-fonttype+     #x0001)
(defwin32constant +device-fonttype+     #x0002)
(defwin32constant +truetype-fonttype+   #x0004)

;;; palette entry flags

(defwin32constant +pc-reserved+     #x01)    ; palette index used for animation
(defwin32constant +pc-explicit+     #x02)    ; palette index is explicit to device
(defwin32constant +pc-nocollapse+   #x04)    ; do not match color to system palette


;;; Background Modes
(defwin32constant +transparent+         1)
(defwin32constant +opaque+              2)
(defwin32constant +bkmode-last+         2)

;;; Graphics Modes

(defwin32constant +gm-compatible+       1)
(defwin32constant +gm-advanced+         2)
(defwin32constant +gm-last+             2)

;;; PolyDraw and GetPath point types
(defwin32constant +pt-closefigure+      #x01)
(defwin32constant +pt-lineto+           #x02)
(defwin32constant +pt-bezierto+         #x04)
(defwin32constant +pt-moveto+           #x06)

;;; Mapping Modes
(defwin32constant +mm-text+             1)
(defwin32constant +mm-lometric+         2)
(defwin32constant +mm-himetric+         3)
(defwin32constant +mm-loenglish+        4)
(defwin32constant +mm-hienglish+        5)
(defwin32constant +mm-twips+            6)
(defwin32constant +mm-isotropic+        7)
(defwin32constant +mm-anisotropic+      8)

;;; Min and Max Mapping Mode values
(defwin32constant +mm-min+              +mm-text+)
(defwin32constant +mm-max+              +mm-anisotropic+)
(defwin32constant +mm-max-fixedscale+   +mm-twips+)

;;; Coordinate Modes
(defwin32constant +absolute+            1)
(defwin32constant +relative+            2)

;;; Stock Logical Objects
(defwin32constant +white-brush+         0)
(defwin32constant +ltgray-brush+        1)
(defwin32constant +gray-brush+          2)
(defwin32constant +dkgray-brush+        3)
(defwin32constant +black-brush+         4)
(defwin32constant +null-brush+          5)
(defwin32constant +hollow-brush+        +null-brush+)
(defwin32constant +white-pen+           6)
(defwin32constant +black-pen+           7)
(defwin32constant +null-pen+            8)
(defwin32constant +oem-fixed-font+      10)
(defwin32constant +ansi-fixed-font+     11)
(defwin32constant +ansi-var-font+       12)
(defwin32constant +system-font+         13)
(defwin32constant +device-default-font+ 14)
(defwin32constant +default-palette+     15)
(defwin32constant +system-fixed-font+   16)

(defwin32constant +default-gui-font+    17)

(defwin32constant +dc-brush+            18)
(defwin32constant +dc-pen+              19)

(defwin32constant +stock-last+          19)

(defwin32constant +clr-invalid+     #xFFFFFFFF)

;;; Brush Styles
(defwin32constant +bs-solid+            0)
(defwin32constant +bs-null+             1)
(defwin32constant +bs-hollow+           +bs-null+)
(defwin32constant +bs-hatched+          2)
(defwin32constant +bs-pattern+          3)
(defwin32constant +bs-indexed+          4)
(defwin32constant +bs-dibpattern+       5)
(defwin32constant +bs-dibpatternpt+     6)
(defwin32constant +bs-pattern8x8+       7)
(defwin32constant +bs-dibpattern8x8+    8)
(defwin32constant +bs-monopattern+      9)

;;; Hatch Styles
(defwin32constant +hs-horizontal+       0)       ; -----
(defwin32constant +hs-vertical+         1)       ; |||||
(defwin32constant +hs-fdiagonal+        2)       ; \\\\\
(defwin32constant +hs-bdiagonal+        3)       ; /////
(defwin32constant +hs-cross+            4)       ; +++++
(defwin32constant +hs-diagcross+        5)       ; xxxxx
(defwin32constant +hs-api-max+          12)

;;; Pen Styles
(defwin32constant +ps-solid+            0)
(defwin32constant +ps-dash+             1)       ; -------
(defwin32constant +ps-dot+              2)       ; .......
(defwin32constant +ps-dashdot+          3)       ; _._._._
(defwin32constant +ps-dashdotdot+       4)       ; _.._.._
(defwin32constant +ps-null+             5)
(defwin32constant +ps-insideframe+      6)
(defwin32constant +ps-userstyle+        7)
(defwin32constant +ps-alternate+        8)
(defwin32constant +ps-style-mask+       #x0000000F)

(defwin32constant +ps-endcap-round+     #x00000000)
(defwin32constant +ps-endcap-square+    #x00000100)
(defwin32constant +ps-endcap-flat+      #x00000200)
(defwin32constant +ps-endcap-mask+      #x00000F00)

(defwin32constant +ps-join-round+       #x00000000)
(defwin32constant +ps-join-bevel+       #x00001000)
(defwin32constant +ps-join-miter+       #x00002000)
(defwin32constant +ps-join-mask+        #x0000F000)

(defwin32constant +ps-cosmetic+         #x00000000)
(defwin32constant +ps-geometric+        #x00010000)
(defwin32constant +ps-type-mask+        #x000F0000)

(defwin32constant +ad-counterclockwise+ 1)
(defwin32constant +ad-clockwise+        2)

;;; Device Parameters for GetDeviceCaps()
(defwin32constant +driverversion+ 0)     ; Device driver version
(defwin32constant +technology+    2)     ; Device classification
(defwin32constant +horzsize+      4)     ; Horizontal size in millimeters
(defwin32constant +vertsize+      6)     ; Vertical size in millimeters
(defwin32constant +horzres+       8)     ; Horizontal width in pixels
(defwin32constant +vertres+       10)    ; Vertical height in pixels
(defwin32constant +bitspixel+     12)    ; Number of bits per pixel
(defwin32constant +planes+        14)    ; Number of planes
(defwin32constant +numbrushes+    16)    ; Number of brushes the device has
(defwin32constant +numpens+       18)    ; Number of pens the device has
(defwin32constant +nummarkers+    20)    ; Number of markers the device has
(defwin32constant +numfonts+      22)    ; Number of fonts the device has
(defwin32constant +numcolors+     24)    ; Number of colors the device supports
(defwin32constant +pdevicesize+   26)    ; Size required for device descriptor
(defwin32constant +curvecaps+     28)    ; Curve capabilities
(defwin32constant +linecaps+      30)    ; Line capabilities
(defwin32constant +polygonalcaps+ 32)    ; Polygonal capabilities
(defwin32constant +textcaps+      34)    ; Text capabilities
(defwin32constant +clipcaps+      36)    ; Clipping capabilities
(defwin32constant +rastercaps+    38)    ; Bitblt capabilities
(defwin32constant +aspectx+       40)    ; Length of the X leg
(defwin32constant +aspecty+       42)    ; Length of the Y leg
(defwin32constant +aspectxy+      44)    ; Length of the hypotenuse

(defwin32constant +logpixelsx+    88)    ; Logical pixels/inch in X
(defwin32constant +logpixelsy+    90)    ; Logical pixels/inch in Y

(defwin32constant +sizepalette+  104)    ; Number of entries in physical palette
(defwin32constant +numreserved+  106)    ; Number of reserved entries in palette
(defwin32constant +colorres+     108)    ; Actual color resolution

;; Printing related DeviceCaps. These replace the appropriate Escapes

(defwin32constant +physicalwidth+   110) ; Physical Width in device units
(defwin32constant +physicalheight+  111) ; Physical Height in device units
(defwin32constant +physicaloffsetx+ 112) ; Physical Printable Area x margin
(defwin32constant +physicaloffsety+ 113) ; Physical Printable Area y margin
(defwin32constant +scalingfactorx+  114) ; Scaling factor x
(defwin32constant +scalingfactory+  115) ; Scaling factor y

;; Display driver specific

(defwin32constant +vrefresh+        116)  ; Current vertical refresh rate of the
                                          ; display device (for displays only) in Hz
(defwin32constant +desktopvertres+  117)  ; Horizontal width of entire desktop in
                                          ; pixels
(defwin32constant +desktophorzres+  118)  ; Vertical height of entire desktop in
                                          ; pixels
(defwin32constant +bltalignment+    119)  ; Preferred blt alignment

(defwin32constant +shadeblendcaps+  120)  ; Shading and blending caps
(defwin32constant +colormgmtcaps+   121)  ; Color Management caps

;;; Device Capability Masks:

;;; Device Technologies
(defwin32constant +dt-plotter+          0)   ; Vector plotter
(defwin32constant +dt-rasdisplay+       1)   ; Raster display
(defwin32constant +dt-rasprinter+       2)   ; Raster printer
(defwin32constant +dt-rascamera+        3)   ; Raster camera
(defwin32constant +dt-charstream+       4)   ; Character-stream, PLP
(defwin32constant +dt-metafile+         5)   ; Metafile, VDM
(defwin32constant +dt-dispfile+         6)   ; Display-file

;;; Curve Capabilities
(defwin32constant +cc-none+             0)   ; Curves not supported
(defwin32constant +cc-circles+          1)   ; Can do circles
(defwin32constant +cc-pie+              2)   ; Can do pie wedges
(defwin32constant +cc-chord+            4)   ; Can do chord arcs
(defwin32constant +cc-ellipses+         8)   ; Can do ellipese
(defwin32constant +cc-wide+             16)  ; Can do wide lines
(defwin32constant +cc-styled+           32)  ; Can do styled lines
(defwin32constant +cc-widestyled+       64)  ; Can do wide styled lines
(defwin32constant +cc-interiors+        128) ; Can do interiors
(defwin32constant +cc-roundrect+        256) ;

;;; Line Capabilities
(defwin32constant +lc-none+             0)   ; Lines not supported
(defwin32constant +lc-polyline+         2)   ; Can do polylines
(defwin32constant +lc-marker+           4)   ; Can do markers
(defwin32constant +lc-polymarker+       8)   ; Can do polymarkers
(defwin32constant +lc-wide+             16)  ; Can do wide lines
(defwin32constant +lc-styled+           32)  ; Can do styled lines
(defwin32constant +lc-widestyled+       64)  ; Can do wide styled lines
(defwin32constant +lc-interiors+        128) ; Can do interiors

;;; Polygonal Capabilities
(defwin32constant +pc-none+             0)   ; Polygonals not supported
(defwin32constant +pc-polygon+          1)   ; Can do polygons
(defwin32constant +pc-rectangle+        2)   ; Can do rectangles
(defwin32constant +pc-windpolygon+      4)   ; Can do winding polygons
(defwin32constant +pc-trapezoid+        4)   ; Can do trapezoids
(defwin32constant +pc-scanline+         8)   ; Can do scanlines
(defwin32constant +pc-wide+             16)  ; Can do wide borders
(defwin32constant +pc-styled+           32)  ; Can do styled borders
(defwin32constant +pc-widestyled+       64)  ; Can do wide styled borders
(defwin32constant +pc-interiors+        128) ; Can do interiors
(defwin32constant +pc-polypolygon+      256) ; Can do polypolygons
(defwin32constant +pc-paths+            512) ; Can do paths

;;; Clipping Capabilities
(defwin32constant +cp-none+             0)   ; No clipping of output
(defwin32constant +cp-rectangle+        1)   ; Output clipped to rects
(defwin32constant +cp-region+           2)   ; obsolete

;;; Text Capabilities
(defwin32constant +tc-op-character+     #x00000001)  ; Can do OutputPrecision   CHARACTER
(defwin32constant +tc-op-stroke+        #x00000002)  ; Can do OutputPrecision   STROKE
(defwin32constant +tc-cp-stroke+        #x00000004)  ; Can do ClipPrecision     STROKE
(defwin32constant +tc-cr-90+            #x00000008)  ; Can do CharRotAbility    90
(defwin32constant +tc-cr-any+           #x00000010)  ; Can do CharRotAbility    ANY
(defwin32constant +tc-sf-x-yindep+      #x00000020)  ; Can do ScaleFreedom      X_YINDEPENDENT
(defwin32constant +tc-sa-double+        #x00000040)  ; Can do ScaleAbility      DOUBLE
(defwin32constant +tc-sa-integer+       #x00000080)  ; Can do ScaleAbility      INTEGER
(defwin32constant +tc-sa-contin+        #x00000100)  ; Can do ScaleAbility      CONTINUOUS
(defwin32constant +tc-ea-double+        #x00000200)  ; Can do EmboldenAbility   DOUBLE
(defwin32constant +tc-ia-able+          #x00000400)  ; Can do ItalisizeAbility  ABLE
(defwin32constant +tc-ua-able+          #x00000800)  ; Can do UnderlineAbility  ABLE
(defwin32constant +tc-so-able+          #x00001000)  ; Can do StrikeOutAbility  ABLE
(defwin32constant +tc-ra-able+          #x00002000)  ; Can do RasterFontAble    ABLE
(defwin32constant +tc-va-able+          #x00004000)  ; Can do VectorFontAble    ABLE
(defwin32constant +tc-reserved+         #x00008000)
(defwin32constant +tc-scrollblt+        #x00010000)  ; Don't do text scroll with blt

;;; Raster Capabilities
(defwin32constant +rc-none+             0)
(defwin32constant +rc-bitblt+           1)       ; Can do standard BLT.
(defwin32constant +rc-banding+          2)       ; Device requires banding support
(defwin32constant +rc-scaling+          4)       ; Device requires scaling support
(defwin32constant +rc-bitmap64+         8)       ; Device can support >64K bitmap
(defwin32constant +rc-gdi20-output+     #x0010)      ; has 2.0 output calls
(defwin32constant +rc-gdi20-state+      #x0020)
(defwin32constant +rc-savebitmap+       #x0040)
(defwin32constant +rc-di-bitmap+        #x0080)      ; supports DIB to memory
(defwin32constant +rc-palette+          #x0100)      ; supports a palette
(defwin32constant +rc-dibtodev+         #x0200)      ; supports DIBitsToDevice
(defwin32constant +rc-bigfont+          #x0400)      ; supports >64K fonts
(defwin32constant +rc-stretchblt+       #x0800)      ; supports StretchBlt
(defwin32constant +rc-floodfill+        #x1000)      ; supports FloodFill
(defwin32constant +rc-stretchdib+       #x2000)      ; supports StretchDIBits
(defwin32constant +rc-op-dx-output+     #x4000)
(defwin32constant +rc-devbits+          #x8000)

;;; Shading and blending caps
(defwin32constant +sb-none+             #x00000000)
(defwin32constant +sb-const-alpha+      #x00000001)
(defwin32constant +sb-pixel-alpha+      #x00000002)
(defwin32constant +sb-premult-alpha+    #x00000004)

(defwin32constant +sb-grad-rect+        #x00000010)
(defwin32constant +sb-grad-tri+         #x00000020)

;;; Color Management caps
(defwin32constant +cm-none+             #x00000000)
(defwin32constant +cm-device-icm+       #x00000001)
(defwin32constant +cm-gamma-ramp+       #x00000002)
(defwin32constant +cm-cmyk-color+       #x00000004)

;;; DIB color table identifiers

(defwin32constant +dib-rgb-colors+      0) ; color table in RGBs
(defwin32constant +dib-pal-colors+      1) ; color table in palette indices

;;; constants for Get/SetSystemPaletteUse()

(defwin32constant +syspal-error+    0)
(defwin32constant +syspal-static+   1)
(defwin32constant +syspal-nostatic+ 2)
(defwin32constant +syspal-nostatic256+ 3)

;;; constants for CreateDIBitmap
(defwin32constant +cbm-init+        #x04)   ; initialize bitmap


;;; ExtFloodFill style flags
(defwin32constant +floodfillborder+   0)
(defwin32constant +floodfillsurface+  1)

;;; size of a device name string
(defwin32constant +cchdevicename+ 32)

;;; size of a form name string
(defwin32constant +cchformname+ 32)

(defwin32constant +bi-rgb+        0)
(defwin32constant +bi-rle8+       1)
(defwin32constant +bi-rle4+       2)
(defwin32constant +bi-bitfields+  3)
(defwin32constant +bi-jpeg+       4)
(defwin32constant +bi-png+        5)

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

(defwin32constant +hwnd-top+        (%as-ptr 0))
(defwin32constant +hwnd-bottom+     (%as-ptr 1))
(defwin32constant +hwnd-topmost+    (%as-ptr -1))
(defwin32constant +hwnd-notopmost+  (%as-ptr -2))

(defwin32constant +hwnd-broadcast+  (%as-ptr #xffff))
(defwin32constant +hwnd-message+     (%as-ptr -3))

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

(defwin32constant +process-terminate+                  #x0001)
(defwin32constant +process-create-thread+              #x0002)
(defwin32constant +process-set-sessionid+              #x0004)
(defwin32constant +process-vm-operation+               #x0008)
(defwin32constant +process-vm-read+                    #x0010)
(defwin32constant +process-vm-write+                   #x0020)
(defwin32constant +process-dup-handle+                 #x0040)
(defwin32constant +process-create-process+             #x0080)
(defwin32constant +process-set-quota+                  #x0100)
(defwin32constant +process-set-information+            #x0200)
(defwin32constant +process-query-information+          #x0400)
(defwin32constant +process-suspend-resume+             #x0800)
(defwin32constant +process-query-limited-information+  #x1000)
(defwin32constant +process-set-limited-information+    #x2000)
(defwin32constant +process-all-access+        (logior +standard-rights-required+ +synchronize+  #xFFFF))

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

(defwin32constant +hkey-classes-root+                   (cffi:make-pointer #x80000000))
(defwin32constant +hkey-current-user+                   (cffi:make-pointer #x80000001))
(defwin32constant +hkey-local-machine+                  (cffi:make-pointer #x80000002))
(defwin32constant +hkey-users+                          (cffi:make-pointer #x80000003))
(defwin32constant +hkey-performance-data+               (cffi:make-pointer #x80000004))
(defwin32constant +hkey-performance-text+               (cffi:make-pointer #x80000050))
(defwin32constant +hkey-performance-nlstext+            (cffi:make-pointer #x80000060))

(defwin32constant +hkey-current-config+                 (cffi:make-pointer #x80000005))
(defwin32constant +hkey-dyn-data+                       (cffi:make-pointer #x80000006))
(defwin32constant +hkey-current-user-local-settings+    (cffi:make-pointer #x80000007))

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

;;
;; MENUGETOBJECTINFO dwFlags values
;;
(defwin32constant +mngof-topgap+         #x00000001)
(defwin32constant +mngof-bottomgap+      #x00000002)

;;
;; WM_MENUGETOBJECT return values
;;
(defwin32constant +mngo-nointerface+     #x00000000)
(defwin32constant +mngo-noerror+         #x00000001)

(defwin32constant +miim-state+       #x00000001)
(defwin32constant +miim-id+          #x00000002)
(defwin32constant +miim-submenu+     #x00000004)
(defwin32constant +miim-checkmarks+  #x00000008)
(defwin32constant +miim-type+        #x00000010)
(defwin32constant +miim-data+        #x00000020)
(defwin32constant +miim-string+      #x00000040)
(defwin32constant +miim-bitmap+      #x00000080)
(defwin32constant +miim-ftype+       #x00000100)

(defwin32constant +hbmmenu-callback+            (%as-ptr -1))
(defwin32constant +hbmmenu-system+              (%as-ptr  1))
(defwin32constant +hbmmenu-mbar-restore+        (%as-ptr  2))
(defwin32constant +hbmmenu-mbar-minimize+       (%as-ptr  3))
(defwin32constant +hbmmenu-mbar-close+          (%as-ptr  5))
(defwin32constant +hbmmenu-mbar-close-d+        (%as-ptr  6))
(defwin32constant +hbmmenu-mbar-minimize-d+     (%as-ptr  7))
(defwin32constant +hbmmenu-popup-close+         (%as-ptr  8))
(defwin32constant +hbmmenu-popup-restore+       (%as-ptr  9))
(defwin32constant +hbmmenu-popup-maximize+      (%as-ptr 10))
(defwin32constant +hbmmenu-popup-minimize+      (%as-ptr 11))

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

(defwin32constant +lang-neutral+                     #x00)
(defwin32constant +lang-invariant+                   #x7f)

(defwin32constant +lang-afrikaans+                   #x36)
(defwin32constant +lang-albanian+                    #x1c)
(defwin32constant +lang-alsatian+                    #x84)
(defwin32constant +lang-amharic+                     #x5e)
(defwin32constant +lang-arabic+                      #x01)
(defwin32constant +lang-armenian+                    #x2b)
(defwin32constant +lang-assamese+                    #x4d)
(defwin32constant +lang-azeri+                       #x2c)   ; for Azerbaijani, LANG_AZERBAIJANI is preferred
(defwin32constant +lang-azerbaijani+                 #x2c)
(defwin32constant +lang-bangla+                      #x45)
(defwin32constant +lang-bashkir+                     #x6d)
(defwin32constant +lang-basque+                      #x2d)
(defwin32constant +lang-belarusian+                  #x23)
(defwin32constant +lang-bengali+                     #x45)   ; Some prefer to use LANG_BANGLA
(defwin32constant +lang-breton+                      #x7e)
(defwin32constant +lang-bosnian+                     #x1a)   ; Use with SUBLANG_BOSNIAN_* Sublanguage IDs
(defwin32constant +lang-bosnian-neutral+           #x781a)   ; Use with the ConvertDefaultLocale function
(defwin32constant +lang-bulgarian+                   #x02)
(defwin32constant +lang-catalan+                     #x03)
(defwin32constant +lang-central-kurdish+             #x92)
(defwin32constant +lang-cherokee+                    #x5c)
(defwin32constant +lang-chinese+                     #x04)   ; Use with SUBLANG_CHINESE_* Sublanguage IDs
(defwin32constant +lang-chinese-simplified+          #x04)   ; Use with the ConvertDefaultLocale function
(defwin32constant +lang-chinese-traditional+       #x7c04)   ; Use with the ConvertDefaultLocale function
(defwin32constant +lang-corsican+                    #x83)
(defwin32constant +lang-croatian+                    #x1a)
(defwin32constant +lang-czech+                       #x05)
(defwin32constant +lang-danish+                      #x06)
(defwin32constant +lang-dari+                        #x8c)
(defwin32constant +lang-divehi+                      #x65)
(defwin32constant +lang-dutch+                       #x13)
(defwin32constant +lang-english+                     #x09)
(defwin32constant +lang-estonian+                    #x25)
(defwin32constant +lang-faeroese+                    #x38)
(defwin32constant +lang-farsi+                       #x29)   ; Deprecated: use LANG_PERSIAN instead
(defwin32constant +lang-filipino+                    #x64)
(defwin32constant +lang-finnish+                     #x0b)
(defwin32constant +lang-french+                      #x0c)
(defwin32constant +lang-frisian+                     #x62)
(defwin32constant +lang-fulah+                       #x67)
(defwin32constant +lang-galician+                    #x56)
(defwin32constant +lang-georgian+                    #x37)
(defwin32constant +lang-german+                      #x07)
(defwin32constant +lang-greek+                       #x08)
(defwin32constant +lang-greenlandic+                 #x6f)
(defwin32constant +lang-gujarati+                    #x47)
(defwin32constant +lang-hausa+                       #x68)
(defwin32constant +lang-hawaiian+                    #x75)
(defwin32constant +lang-hebrew+                      #x0d)
(defwin32constant +lang-hindi+                       #x39)
(defwin32constant +lang-hungarian+                   #x0e)
(defwin32constant +lang-icelandic+                   #x0f)
(defwin32constant +lang-igbo+                        #x70)
(defwin32constant +lang-indonesian+                  #x21)
(defwin32constant +lang-inuktitut+                   #x5d)
(defwin32constant +lang-irish+                       #x3c)   ; Use with the SUBLANG_IRISH_IRELAND Sublanguage ID
(defwin32constant +lang-italian+                     #x10)
(defwin32constant +lang-japanese+                    #x11)
(defwin32constant +lang-kannada+                     #x4b)
(defwin32constant +lang-kashmiri+                    #x60)
(defwin32constant +lang-kazak+                       #x3f)
(defwin32constant +lang-khmer+                       #x53)
(defwin32constant +lang-kiche+                       #x86)
(defwin32constant +lang-kinyarwanda+                 #x87)
(defwin32constant +lang-konkani+                     #x57)
(defwin32constant +lang-korean+                      #x12)
(defwin32constant +lang-kyrgyz+                      #x40)
(defwin32constant +lang-lao+                         #x54)
(defwin32constant +lang-latvian+                     #x26)
(defwin32constant +lang-lithuanian+                  #x27)
(defwin32constant +lang-lower-sorbian+               #x2e)
(defwin32constant +lang-luxembourgish+               #x6e)
(defwin32constant +lang-macedonian+                  #x2f)   ; the Former Yugoslav Republic of Macedonia
(defwin32constant +lang-malay+                       #x3e)
(defwin32constant +lang-malayalam+                   #x4c)
(defwin32constant +lang-maltese+                     #x3a)
(defwin32constant +lang-manipuri+                    #x58)
(defwin32constant +lang-maori+                       #x81)
(defwin32constant +lang-mapudungun+                  #x7a)
(defwin32constant +lang-marathi+                     #x4e)
(defwin32constant +lang-mohawk+                      #x7c)
(defwin32constant +lang-mongolian+                   #x50)
(defwin32constant +lang-nepali+                      #x61)
(defwin32constant +lang-norwegian+                   #x14)
(defwin32constant +lang-occitan+                     #x82)
(defwin32constant +lang-odia+                        #x48)
(defwin32constant +lang-oriya+                       #x48)   ; Deprecated: use LANG_ODIA, instead.
(defwin32constant +lang-pashto+                      #x63)
(defwin32constant +lang-persian+                     #x29)
(defwin32constant +lang-polish+                      #x15)
(defwin32constant +lang-portuguese+                  #x16)
(defwin32constant +lang-pular+                       #x67)   ; Deprecated: use LANG_FULAH instead
(defwin32constant +lang-punjabi+                     #x46)
(defwin32constant +lang-quechua+                     #x6b)
(defwin32constant +lang-romanian+                    #x18)
(defwin32constant +lang-romansh+                     #x17)
(defwin32constant +lang-russian+                     #x19)
(defwin32constant +lang-sakha+                       #x85)
(defwin32constant +lang-sami+                        #x3b)
(defwin32constant +lang-sanskrit+                    #x4f)
(defwin32constant +lang-scottish-gaelic+             #x91)
(defwin32constant +lang-serbian+                     #x1a)   ; Use with the SUBLANG_SERBIAN_* Sublanguage IDs
(defwin32constant +lang-serbian-neutral+           #x7c1a)   ; Use with the ConvertDefaultLocale function
(defwin32constant +lang-sindhi+                      #x59)
(defwin32constant +lang-sinhalese+                   #x5b)
(defwin32constant +lang-slovak+                      #x1b)
(defwin32constant +lang-slovenian+                   #x24)
(defwin32constant +lang-sotho+                       #x6c)
(defwin32constant +lang-spanish+                     #x0a)
(defwin32constant +lang-swahili+                     #x41)
(defwin32constant +lang-swedish+                     #x1d)
(defwin32constant +lang-syriac+                      #x5a)
(defwin32constant +lang-tajik+                       #x28)
(defwin32constant +lang-tamazight+                   #x5f)
(defwin32constant +lang-tamil+                       #x49)
(defwin32constant +lang-tatar+                       #x44)
(defwin32constant +lang-telugu+                      #x4a)
(defwin32constant +lang-thai+                        #x1e)
(defwin32constant +lang-tibetan+                     #x51)
(defwin32constant +lang-tigrigna+                    #x73)
(defwin32constant +lang-tigrinya+                    #x73)   ; Preferred spelling in locale
(defwin32constant +lang-tswana+                      #x32)
(defwin32constant +lang-turkish+                     #x1f)
(defwin32constant +lang-turkmen+                     #x42)
(defwin32constant +lang-uighur+                      #x80)
(defwin32constant +lang-ukrainian+                   #x22)
(defwin32constant +lang-upper-sorbian+               #x2e)
(defwin32constant +lang-urdu+                        #x20)
(defwin32constant +lang-uzbek+                       #x43)
(defwin32constant +lang-valencian+                   #x03)
(defwin32constant +lang-vietnamese+                  #x2a)
(defwin32constant +lang-welsh+                       #x52)
(defwin32constant +lang-wolof+                       #x88)
(defwin32constant +lang-xhosa+                       #x34)
(defwin32constant +lang-yakut+                       #x85)   ; Deprecated: use LANG_SAKHA,instead
(defwin32constant +lang-yi+                          #x78)
(defwin32constant +lang-yoruba+                      #x6a)
(defwin32constant +lang-zulu+                        #x35)

(defwin32constant +sublang-neutral+                             #x00)    ; language neutral
(defwin32constant +sublang-default+                             #x01)    ; user default
(defwin32constant +sublang-sys-default+                         #x02)    ; system default
(defwin32constant +sublang-custom-default+                      #x03)    ; default custom language/locale
(defwin32constant +sublang-custom-unspecified+                  #x04)    ; custom language/locale
(defwin32constant +sublang-ui-custom-default+                   #x05)    ; Default custom MUI language/locale


(defwin32constant +sublang-afrikaans-south-africa+              #x01)    ; Afrikaans (South Africa) 0x0436 af-ZA
(defwin32constant +sublang-albanian-albania+                    #x01)    ; Albanian (Albania) 0x041c sq-AL
(defwin32constant +sublang-alsatian-france+                     #x01)    ; Alsatian (France) 0x0484
(defwin32constant +sublang-amharic-ethiopia+                    #x01)    ; Amharic (Ethiopia) 0x045e
(defwin32constant +sublang-arabic-saudi-arabia+                 #x01)    ; Arabic (Saudi Arabia)
(defwin32constant +sublang-arabic-iraq+                         #x02)    ; Arabic (Iraq)
(defwin32constant +sublang-arabic-egypt+                        #x03)    ; Arabic (Egypt)
(defwin32constant +sublang-arabic-libya+                        #x04)    ; Arabic (Libya)
(defwin32constant +sublang-arabic-algeria+                      #x05)    ; Arabic (Algeria)
(defwin32constant +sublang-arabic-morocco+                      #x06)    ; Arabic (Morocco)
(defwin32constant +sublang-arabic-tunisia+                      #x07)    ; Arabic (Tunisia)
(defwin32constant +sublang-arabic-oman+                         #x08)    ; Arabic (Oman)
(defwin32constant +sublang-arabic-yemen+                        #x09)    ; Arabic (Yemen)
(defwin32constant +sublang-arabic-syria+                        #x0a)    ; Arabic (Syria)
(defwin32constant +sublang-arabic-jordan+                       #x0b)    ; Arabic (Jordan)
(defwin32constant +sublang-arabic-lebanon+                      #x0c)    ; Arabic (Lebanon)
(defwin32constant +sublang-arabic-kuwait+                       #x0d)    ; Arabic (Kuwait)
(defwin32constant +sublang-arabic-uae+                          #x0e)    ; Arabic (U.A.E)
(defwin32constant +sublang-arabic-bahrain+                      #x0f)    ; Arabic (Bahrain)
(defwin32constant +sublang-arabic-qatar+                        #x10)    ; Arabic (Qatar)
(defwin32constant +sublang-armenian-armenia+                    #x01)    ; Armenian (Armenia) 0x042b hy-AM
(defwin32constant +sublang-assamese-india+                      #x01)    ; Assamese (India) 0x044d
(defwin32constant +sublang-azeri-latin+                         #x01)    ; Azeri (Latin) - for Azerbaijani, SUBLANG_AZERBAIJANI_AZERBAIJAN_LATIN preferred
(defwin32constant +sublang-azeri-cyrillic+                      #x02)    ; Azeri (Cyrillic) - for Azerbaijani, SUBLANG_AZERBAIJANI_AZERBAIJAN_CYRILLIC preferred
(defwin32constant +sublang-azerbaijani-azerbaijan-latin+        #x01)    ; Azerbaijani (Azerbaijan, Latin)
(defwin32constant +sublang-azerbaijani-azerbaijan-cyrillic+     #x02)    ; Azerbaijani (Azerbaijan, Cyrillic)
(defwin32constant +sublang-bangla-india+                        #x01)    ; Bangla (India)
(defwin32constant +sublang-bangla-bangladesh+                   #x02)    ; Bangla (Bangladesh)
(defwin32constant +sublang-bashkir-russia+                      #x01)    ; Bashkir (Russia) 0x046d ba-RU
(defwin32constant +sublang-basque-basque+                       #x01)    ; Basque (Basque) 0x042d eu-ES
(defwin32constant +sublang-belarusian-belarus+                  #x01)    ; Belarusian (Belarus) 0x0423 be-BY
(defwin32constant +sublang-bengali-india+                       #x01)    ; Bengali (India) - Note some prefer SUBLANG_BANGLA_INDIA
(defwin32constant +sublang-bengali-bangladesh+                  #x02)    ; Bengali (Bangladesh) - Note some prefer SUBLANG_BANGLA_BANGLADESH
(defwin32constant +sublang-bosnian-bosnia-herzegovina-latin+    #x05)    ; Bosnian (Bosnia and Herzegovina - Latin) 0x141a bs-BA-Latn
(defwin32constant +sublang-bosnian-bosnia-herzegovina-cyrillic+ #x08)    ; Bosnian (Bosnia and Herzegovina - Cyrillic) 0x201a bs-BA-Cyrl
(defwin32constant +sublang-breton-france+                       #x01)    ; Breton (France) 0x047e
(defwin32constant +sublang-bulgarian-bulgaria+                  #x01)    ; Bulgarian (Bulgaria) 0x0402
(defwin32constant +sublang-catalan-catalan+                     #x01)    ; Catalan (Catalan) 0x0403
(defwin32constant +sublang-central-kurdish-iraq+                #x01)    ; Central Kurdish (Iraq) 0x0492 ku-Arab-IQ
(defwin32constant +sublang-cherokee-cherokee+                   #x01)    ; Cherokee (Cherokee) 0x045c chr-Cher-US
(defwin32constant +sublang-chinese-traditional+                 #x01)    ; Chinese (Taiwan) 0x0404 zh-TW
(defwin32constant +sublang-chinese-simplified+                  #x02)    ; Chinese (PR China) 0x0804 zh-CN
(defwin32constant +sublang-chinese-hongkong+                    #x03)    ; Chinese (Hong Kong S.A.R., P.R.C.) 0x0c04 zh-HK
(defwin32constant +sublang-chinese-singapore+                   #x04)    ; Chinese (Singapore) 0x1004 zh-SG
(defwin32constant +sublang-chinese-macau+                       #x05)    ; Chinese (Macau S.A.R.) 0x1404 zh-MO
(defwin32constant +sublang-corsican-france+                     #x01)    ; Corsican (France) 0x0483
(defwin32constant +sublang-czech-czech-republic+                #x01)    ; Czech (Czech Republic) 0x0405
(defwin32constant +sublang-croatian-croatia+                    #x01)    ; Croatian (Croatia)
(defwin32constant +sublang-croatian-bosnia-herzegovina-latin+   #x04)    ; Croatian (Bosnia and Herzegovina - Latin) 0x101a hr-BA
(defwin32constant +sublang-danish-denmark+                      #x01)    ; Danish (Denmark) 0x0406
(defwin32constant +sublang-dari-afghanistan+                    #x01)    ; Dari (Afghanistan)
(defwin32constant +sublang-divehi-maldives+                     #x01)    ; Divehi (Maldives) 0x0465 div-MV
(defwin32constant +sublang-dutch+                               #x01)    ; Dutch
(defwin32constant +sublang-dutch-belgian+                       #x02)    ; Dutch (Belgian)
(defwin32constant +sublang-english-us+                          #x01)    ; English (USA)
(defwin32constant +sublang-english-uk+                          #x02)    ; English (UK)
(defwin32constant +sublang-english-aus+                         #x03)    ; English (Australian)
(defwin32constant +sublang-english-can+                         #x04)    ; English (Canadian)
(defwin32constant +sublang-english-nz+                          #x05)    ; English (New Zealand)
(defwin32constant +sublang-english-eire+                        #x06)    ; English (Irish)
(defwin32constant +sublang-english-south-africa+                #x07)    ; English (South Africa)
(defwin32constant +sublang-english-jamaica+                     #x08)    ; English (Jamaica)
(defwin32constant +sublang-english-caribbean+                   #x09)    ; English (Caribbean)
(defwin32constant +sublang-english-belize+                      #x0a)    ; English (Belize)
(defwin32constant +sublang-english-trinidad+                    #x0b)    ; English (Trinidad)
(defwin32constant +sublang-english-zimbabwe+                    #x0c)    ; English (Zimbabwe)
(defwin32constant +sublang-english-philippines+                 #x0d)    ; English (Philippines)
(defwin32constant +sublang-english-india+                       #x10)    ; English (India)
(defwin32constant +sublang-english-malaysia+                    #x11)    ; English (Malaysia)
(defwin32constant +sublang-english-singapore+                   #x12)    ; English (Singapore)
(defwin32constant +sublang-estonian-estonia+                    #x01)    ; Estonian (Estonia) 0x0425 et-EE
(defwin32constant +sublang-faeroese-faroe-islands+              #x01)    ; Faroese (Faroe Islands) 0x0438 fo-FO
(defwin32constant +sublang-filipino-philippines+                #x01)    ; Filipino (Philippines) 0x0464 fil-PH
(defwin32constant +sublang-finnish-finland+                     #x01)    ; Finnish (Finland) 0x040b
(defwin32constant +sublang-french+                              #x01)    ; French
(defwin32constant +sublang-french-belgian+                      #x02)    ; French (Belgian)
(defwin32constant +sublang-french-canadian+                     #x03)    ; French (Canadian)
(defwin32constant +sublang-french-swiss+                        #x04)    ; French (Swiss)
(defwin32constant +sublang-french-luxembourg+                   #x05)    ; French (Luxembourg)
(defwin32constant +sublang-french-monaco+                       #x06)    ; French (Monaco)
(defwin32constant +sublang-frisian-netherlands+                 #x01)    ; Frisian (Netherlands) 0x0462 fy-NL
(defwin32constant +sublang-fulah-senegal+                       #x02)    ; Fulah (Senegal) 0x0867 ff-SN
(defwin32constant +sublang-galician-galician+                   #x01)    ; Galician (Galician) 0x0456 gl-ES
(defwin32constant +sublang-georgian-georgia+                    #x01)    ; Georgian (Georgia) 0x0437 ka-GE
(defwin32constant +sublang-german+                              #x01)    ; German
(defwin32constant +sublang-german-swiss+                        #x02)    ; German (Swiss)
(defwin32constant +sublang-german-austrian+                     #x03)    ; German (Austrian)
(defwin32constant +sublang-german-luxembourg+                   #x04)    ; German (Luxembourg)
(defwin32constant +sublang-german-liechtenstein+                #x05)    ; German (Liechtenstein)
(defwin32constant +sublang-greek-greece+                        #x01)    ; Greek (Greece)
(defwin32constant +sublang-greenlandic-greenland+               #x01)    ; Greenlandic (Greenland) 0x046f kl-GL
(defwin32constant +sublang-gujarati-india+                      #x01)    ; Gujarati (India (Gujarati Script)) 0x0447 gu-IN
(defwin32constant +sublang-hausa-nigeria-latin+                 #x01)    ; Hausa (Latin, Nigeria) 0x0468 ha-NG-Latn
(defwin32constant +sublang-hawaiian-us+                         #x01)    ; Hawiian (US) 0x0475 haw-US
(defwin32constant +sublang-hebrew-israel+                       #x01)    ; Hebrew (Israel) 0x040d
(defwin32constant +sublang-hindi-india+                         #x01)    ; Hindi (India) 0x0439 hi-IN
(defwin32constant +sublang-hungarian-hungary+                   #x01)    ; Hungarian (Hungary) 0x040e
(defwin32constant +sublang-icelandic-iceland+                   #x01)    ; Icelandic (Iceland) 0x040f
(defwin32constant +sublang-igbo-nigeria+                        #x01)    ; Igbo (Nigeria) 0x0470 ig-NG
(defwin32constant +sublang-indonesian-indonesia+                #x01)    ; Indonesian (Indonesia) 0x0421 id-ID
(defwin32constant +sublang-inuktitut-canada+                    #x01)    ; Inuktitut (Syllabics) (Canada) 0x045d iu-CA-Cans
(defwin32constant +sublang-inuktitut-canada-latin+              #x02)    ; Inuktitut (Canada - Latin)
(defwin32constant +sublang-irish-ireland+                       #x02)    ; Irish (Ireland)
(defwin32constant +sublang-italian+                             #x01)    ; Italian
(defwin32constant +sublang-italian-swiss+                       #x02)    ; Italian (Swiss)
(defwin32constant +sublang-japanese-japan+                      #x01)    ; Japanese (Japan) 0x0411
(defwin32constant +sublang-kannada-india+                       #x01)    ; Kannada (India (Kannada Script)) 0x044b kn-IN
(defwin32constant +sublang-kashmiri-sasia+                      #x02)    ; Kashmiri (South Asia)
(defwin32constant +sublang-kashmiri-india+                      #x02)    ; For app compatibility only
(defwin32constant +sublang-kazak-kazakhstan+                    #x01)    ; Kazakh (Kazakhstan) 0x043f kk-KZ
(defwin32constant +sublang-khmer-cambodia+                      #x01)    ; Khmer (Cambodia) 0x0453 kh-KH
(defwin32constant +sublang-kiche-guatemala+                     #x01)    ; K'iche (Guatemala)
(defwin32constant +sublang-kinyarwanda-rwanda+                  #x01)    ; Kinyarwanda (Rwanda) 0x0487 rw-RW
(defwin32constant +sublang-konkani-india+                       #x01)    ; Konkani (India) 0x0457 kok-IN
(defwin32constant +sublang-korean+                              #x01)    ; Korean (Extended Wansung)
(defwin32constant +sublang-kyrgyz-kyrgyzstan+                   #x01)    ; Kyrgyz (Kyrgyzstan) 0x0440 ky-KG
(defwin32constant +sublang-lao-lao+                             #x01)    ; Lao (Lao PDR) 0x0454 lo-LA
(defwin32constant +sublang-latvian-latvia+                      #x01)    ; Latvian (Latvia) 0x0426 lv-LV
(defwin32constant +sublang-lithuanian+                          #x01)    ; Lithuanian
(defwin32constant +sublang-lower-sorbian-germany+               #x02)    ; Lower Sorbian (Germany) 0x082e wee-DE
(defwin32constant +sublang-luxembourgish-luxembourg+            #x01)    ; Luxembourgish (Luxembourg) 0x046e lb-LU
(defwin32constant +sublang-macedonian-macedonia+                #x01)    ; Macedonian (Macedonia (FYROM)) 0x042f mk-MK
(defwin32constant +sublang-malay-malaysia+                      #x01)    ; Malay (Malaysia)
(defwin32constant +sublang-malay-brunei-darussalam+             #x02)    ; Malay (Brunei Darussalam)
(defwin32constant +sublang-malayalam-india+                     #x01)    ; Malayalam (India (Malayalam Script) ) 0x044c ml-IN
(defwin32constant +sublang-maltese-malta+                       #x01)    ; Maltese (Malta) 0x043a mt-MT
(defwin32constant +sublang-maori-new-zealand+                   #x01)    ; Maori (New Zealand) 0x0481 mi-NZ
(defwin32constant +sublang-mapudungun-chile+                    #x01)    ; Mapudungun (Chile) 0x047a arn-CL
(defwin32constant +sublang-marathi-india+                       #x01)    ; Marathi (India) 0x044e mr-IN
(defwin32constant +sublang-mohawk-mohawk+                       #x01)    ; Mohawk (Mohawk) 0x047c moh-CA
(defwin32constant +sublang-mongolian-cyrillic-mongolia+         #x01)    ; Mongolian (Cyrillic, Mongolia)
(defwin32constant +sublang-mongolian-prc+                       #x02)    ; Mongolian (PRC)
(defwin32constant +sublang-nepali-india+                        #x02)    ; Nepali (India)
(defwin32constant +sublang-nepali-nepal+                        #x01)    ; Nepali (Nepal) 0x0461 ne-NP
(defwin32constant +sublang-norwegian-bokmal+                    #x01)    ; Norwegian (Bokmal)
(defwin32constant +sublang-norwegian-nynorsk+                   #x02)    ; Norwegian (Nynorsk)
(defwin32constant +sublang-occitan-france+                      #x01)    ; Occitan (France) 0x0482 oc-FR
(defwin32constant +sublang-odia-india+                          #x01)    ; Odia (India (Odia Script)) 0x0448 or-IN
(defwin32constant +sublang-oriya-india+                         #x01)    ; Deprecated: use SUBLANG_ODIA_INDIA instead
(defwin32constant +sublang-pashto-afghanistan+                  #x01)    ; Pashto (Afghanistan)
(defwin32constant +sublang-persian-iran+                        #x01)    ; Persian (Iran) 0x0429 fa-IR
(defwin32constant +sublang-polish-poland+                       #x01)    ; Polish (Poland) 0x0415
(defwin32constant +sublang-portuguese+                          #x02)    ; Portuguese
(defwin32constant +sublang-portuguese-brazilian+                #x01)    ; Portuguese (Brazil)
(defwin32constant +sublang-pular-senegal+                       #x02)    ; Deprecated: Use SUBLANG_FULAH_SENEGAL instead
(defwin32constant +sublang-punjabi-india+                       #x01)    ; Punjabi (India (Gurmukhi Script)) 0x0446 pa-IN
(defwin32constant +sublang-punjabi-pakistan+                    #x02)    ; Punjabi (Pakistan (Arabic Script)) 0x0846 pa-Arab-PK
(defwin32constant +sublang-quechua-bolivia+                     #x01)    ; Quechua (Bolivia)
(defwin32constant +sublang-quechua-ecuador+                     #x02)    ; Quechua (Ecuador)
(defwin32constant +sublang-quechua-peru+                        #x03)    ; Quechua (Peru)
(defwin32constant +sublang-romanian-romania+                    #x01)    ; Romanian (Romania) 0x0418
(defwin32constant +sublang-romansh-switzerland+                 #x01)    ; Romansh (Switzerland) 0x0417 rm-CH
(defwin32constant +sublang-russian-russia+                      #x01)    ; Russian (Russia) 0x0419
(defwin32constant +sublang-sakha-russia+                        #x01)    ; Sakha (Russia) 0x0485 sah-RU
(defwin32constant +sublang-sami-northern-norway+                #x01)    ; Northern Sami (Norway)
(defwin32constant +sublang-sami-northern-sweden+                #x02)    ; Northern Sami (Sweden)
(defwin32constant +sublang-sami-northern-finland+               #x03)    ; Northern Sami (Finland)
(defwin32constant +sublang-sami-lule-norway+                    #x04)    ; Lule Sami (Norway)
(defwin32constant +sublang-sami-lule-sweden+                    #x05)    ; Lule Sami (Sweden)
(defwin32constant +sublang-sami-southern-norway+                #x06)    ; Southern Sami (Norway)
(defwin32constant +sublang-sami-southern-sweden+                #x07)    ; Southern Sami (Sweden)
(defwin32constant +sublang-sami-skolt-finland+                  #x08)    ; Skolt Sami (Finland)
(defwin32constant +sublang-sami-inari-finland+                  #x09)    ; Inari Sami (Finland)
(defwin32constant +sublang-sanskrit-india+                      #x01)    ; Sanskrit (India) 0x044f sa-IN
(defwin32constant +sublang-scottish-gaelic+                     #x01)    ; Scottish Gaelic (United Kingdom) 0x0491 gd-GB
(defwin32constant +sublang-serbian-bosnia-herzegovina-latin+    #x06)    ; Serbian (Bosnia and Herzegovina - Latin)
(defwin32constant +sublang-serbian-bosnia-herzegovina-cyrillic+ #x07)    ; Serbian (Bosnia and Herzegovina - Cyrillic)
(defwin32constant +sublang-serbian-montenegro-latin+            #x0b)    ; Serbian (Montenegro - Latn)
(defwin32constant +sublang-serbian-montenegro-cyrillic+         #x0c)    ; Serbian (Montenegro - Cyrillic)
(defwin32constant +sublang-serbian-serbia-latin+                #x09)    ; Serbian (Serbia - Latin)
(defwin32constant +sublang-serbian-serbia-cyrillic+             #x0a)    ; Serbian (Serbia - Cyrillic)
(defwin32constant +sublang-serbian-croatia+                     #x01)    ; Croatian (Croatia) 0x041a hr-HR
(defwin32constant +sublang-serbian-latin+                       #x02)    ; Serbian (Latin)
(defwin32constant +sublang-serbian-cyrillic+                    #x03)    ; Serbian (Cyrillic)
(defwin32constant +sublang-sindhi-india+                        #x01)    ; Sindhi (India) reserved 0x0459
(defwin32constant +sublang-sindhi-pakistan+                     #x02)    ; Sindhi (Pakistan) 0x0859 sd-Arab-PK
(defwin32constant +sublang-sindhi-afghanistan+                  #x02)    ; For app compatibility only
(defwin32constant +sublang-sinhalese-sri-lanka+                 #x01)    ; Sinhalese (Sri Lanka)
(defwin32constant +sublang-sotho-northern-south-africa+         #x01)    ; Northern Sotho (South Africa)
(defwin32constant +sublang-slovak-slovakia+                     #x01)    ; Slovak (Slovakia) 0x041b sk-SK
(defwin32constant +sublang-slovenian-slovenia+                  #x01)    ; Slovenian (Slovenia) 0x0424 sl-SI
(defwin32constant +sublang-spanish+                             #x01)    ; Spanish (Castilian)
(defwin32constant +sublang-spanish-mexican+                     #x02)    ; Spanish (Mexico)
(defwin32constant +sublang-spanish-modern+                      #x03)    ; Spanish (Modern)
(defwin32constant +sublang-spanish-guatemala+                   #x04)    ; Spanish (Guatemala)
(defwin32constant +sublang-spanish-costa-rica+                  #x05)    ; Spanish (Costa Rica)
(defwin32constant +sublang-spanish-panama+                      #x06)    ; Spanish (Panama)
(defwin32constant +sublang-spanish-dominican-republic+          #x07)    ; Spanish (Dominican Republic)
(defwin32constant +sublang-spanish-venezuela+                   #x08)    ; Spanish (Venezuela)
(defwin32constant +sublang-spanish-colombia+                    #x09)    ; Spanish (Colombia)
(defwin32constant +sublang-spanish-peru+                        #x0a)    ; Spanish (Peru)
(defwin32constant +sublang-spanish-argentina+                   #x0b)    ; Spanish (Argentina)
(defwin32constant +sublang-spanish-ecuador+                     #x0c)    ; Spanish (Ecuador)
(defwin32constant +sublang-spanish-chile+                       #x0d)    ; Spanish (Chile)
(defwin32constant +sublang-spanish-uruguay+                     #x0e)    ; Spanish (Uruguay)
(defwin32constant +sublang-spanish-paraguay+                    #x0f)    ; Spanish (Paraguay)
(defwin32constant +sublang-spanish-bolivia+                     #x10)    ; Spanish (Bolivia)
(defwin32constant +sublang-spanish-el-salvador+                 #x11)    ; Spanish (El Salvador)
(defwin32constant +sublang-spanish-honduras+                    #x12)    ; Spanish (Honduras)
(defwin32constant +sublang-spanish-nicaragua+                   #x13)    ; Spanish (Nicaragua)
(defwin32constant +sublang-spanish-puerto-rico+                 #x14)    ; Spanish (Puerto Rico)
(defwin32constant +sublang-spanish-us+                          #x15)    ; Spanish (United States)
(defwin32constant +sublang-swahili-kenya+                       #x01)    ; Swahili (Kenya) 0x0441 sw-KE
(defwin32constant +sublang-swedish+                             #x01)    ; Swedish
(defwin32constant +sublang-swedish-finland+                     #x02)    ; Swedish (Finland)
(defwin32constant +sublang-syriac-syria+                        #x01)    ; Syriac (Syria) 0x045a syr-SY
(defwin32constant +sublang-tajik-tajikistan+                    #x01)    ; Tajik (Tajikistan) 0x0428 tg-TJ-Cyrl
(defwin32constant +sublang-tamazight-algeria-latin+             #x02)    ; Tamazight (Latin, Algeria) 0x085f tzm-Latn-DZ
(defwin32constant +sublang-tamazight-morocco-tifinagh+          #x04)    ; Tamazight (Tifinagh) 0x105f tzm-Tfng-MA
(defwin32constant +sublang-tamil-india+                         #x01)    ; Tamil (India)
(defwin32constant +sublang-tamil-sri-lanka+                     #x02)    ; Tamil (Sri Lanka) 0x0849 ta-LK
(defwin32constant +sublang-tatar-russia+                        #x01)    ; Tatar (Russia) 0x0444 tt-RU
(defwin32constant +sublang-telugu-india+                        #x01)    ; Telugu (India (Telugu Script)) 0x044a te-IN
(defwin32constant +sublang-thai-thailand+                       #x01)    ; Thai (Thailand) 0x041e th-TH
(defwin32constant +sublang-tibetan-prc+                         #x01)    ; Tibetan (PRC)
(defwin32constant +sublang-tigrigna-eritrea+                    #x02)    ; Tigrigna (Eritrea)
(defwin32constant +sublang-tigrinya-eritrea+                    #x02)    ; Tigrinya (Eritrea) 0x0873 ti-ER (preferred spelling)
(defwin32constant +sublang-tigrinya-ethiopia+                   #x01)    ; Tigrinya (Ethiopia) 0x0473 ti-ET
(defwin32constant +sublang-tswana-botswana+                     #x02)    ; Setswana / Tswana (Botswana) 0x0832 tn-BW
(defwin32constant +sublang-tswana-south-africa+                 #x01)    ; Setswana / Tswana (South Africa) 0x0432 tn-ZA
(defwin32constant +sublang-turkish-turkey+                      #x01)    ; Turkish (Turkey) 0x041f tr-TR
(defwin32constant +sublang-turkmen-turkmenistan+                #x01)    ; Turkmen (Turkmenistan) 0x0442 tk-TM
(defwin32constant +sublang-uighur-prc+                          #x01)    ; Uighur (PRC) 0x0480 ug-CN
(defwin32constant +sublang-ukrainian-ukraine+                   #x01)    ; Ukrainian (Ukraine) 0x0422 uk-UA
(defwin32constant +sublang-upper-sorbian-germany+               #x01)    ; Upper Sorbian (Germany) 0x042e wen-DE
(defwin32constant +sublang-urdu-pakistan+                       #x01)    ; Urdu (Pakistan)
(defwin32constant +sublang-urdu-india+                          #x02)    ; Urdu (India)
(defwin32constant +sublang-uzbek-latin+                         #x01)    ; Uzbek (Latin)
(defwin32constant +sublang-uzbek-cyrillic+                      #x02)    ; Uzbek (Cyrillic)
(defwin32constant +sublang-valencian-valencia+                  #x02)    ; Valencian (Valencia) 0x0803 ca-ES-Valencia
(defwin32constant +sublang-vietnamese-vietnam+                  #x01)    ; Vietnamese (Vietnam) 0x042a vi-VN
(defwin32constant +sublang-welsh-united-kingdom+                #x01)    ; Welsh (United Kingdom) 0x0452 cy-GB
(defwin32constant +sublang-wolof-senegal+                       #x01)    ; Wolof (Senegal)
(defwin32constant +sublang-xhosa-south-africa+                  #x01)    ; isiXhosa / Xhosa (South Africa) 0x0434 xh-ZA
(defwin32constant +sublang-yakut-russia+                        #x01)    ; Deprecated: use SUBLANG_SAKHA_RUSSIA instead
(defwin32constant +sublang-yi-prc+                              #x01)    ; Yi (PRC)) 0x0478
(defwin32constant +sublang-yoruba-nigeria+                      #x01)    ; Yoruba (Nigeria) 046a yo-NG
(defwin32constant +sublang-zulu-south-africa+                   #x01)    ; isiZulu / Zulu (South Africa) 0x0435 zu-ZA

(defwin32constant +format-message-ignore-inserts+  #x00000200)
(defwin32constant +format-message-from-string+     #x00000400)
(defwin32constant +format-message-from-hmodule+    #x00000800)
(defwin32constant +format-message-from-system+     #x00001000)
(defwin32constant +format-message-argument-array+  #x00002000)
(defwin32constant +format-message-max-width-mask+  #x000000FF)
(defwin32constant +format-message-allocate-buffer+ #x00000100)

(defwin32constant +find-startswith+           #x00100000)  ; see if value is at the beginning of source
(defwin32constant +find-endswith+             #x00200000)  ; see if value is at the end of source
(defwin32constant +find-fromstart+            #x00400000)  ; look for value in source, starting at the beginning
(defwin32constant +find-fromend+              #x00800000)  ; look for value in source, starting at the end

(defwin32constant +dont-resolve-dll-references+         #x00000001)
(defwin32constant +load-library-as-datafile+            #x00000002)
;;  reserved for internal LOAD_PACKAGED_LIBRARY: 0x00000004
(defwin32constant +load-with-altered-search-path+       #x00000008)
(defwin32constant +load-ignore-code-authz-level+        #x00000010)
(defwin32constant +load-library-as-image-resource+      #x00000020)
(defwin32constant +load-library-as-datafile-exclusive+  #x00000040)
(defwin32constant +load-library-require-signed-target+  #x00000080)
(defwin32constant +load-library-search-dll-load-dir+    #x00000100)
(defwin32constant +load-library-search-application-dir+ #x00000200)
(defwin32constant +load-library-search-user-dirs+       #x00000400)
(defwin32constant +load-library-search-system32+        #x00000800)
(defwin32constant +load-library-search-default-dirs+    #x00001000)

(defwin32constant +processor-intel-386+     386)
(defwin32constant +processor-intel-486+     486)
(defwin32constant +processor-intel-pentium+ 586)
(defwin32constant +processor-intel-ia64+    2200)
(defwin32constant +processor-amd-x8664+     8664)
(defwin32constant +processor-mips-r4000+    4000)    ; incl R4101 & R3910 for Windows CE
(defwin32constant +processor-alpha-21064+   21064)
(defwin32constant +processor-ppc-601+       601)
(defwin32constant +processor-ppc-603+       603)
(defwin32constant +processor-ppc-604+       604)
(defwin32constant +processor-ppc-620+       620)
(defwin32constant +processor-hitachi-sh3+   10003)   ; Windows CE
(defwin32constant +processor-hitachi-sh3e+  10004)   ; Windows CE
(defwin32constant +processor-hitachi-sh4+   10005)   ; Windows CE
(defwin32constant +processor-motorola-821+  821)     ; Windows CE
(defwin32constant +processor-shx-sh3+       103)     ; Windows CE
(defwin32constant +processor-shx-sh4+       104)     ; Windows CE
(defwin32constant +processor-strongarm+     2577)    ; Windows CE - 0xA11
(defwin32constant +processor-arm720+        1824)    ; Windows CE - 0x720
(defwin32constant +processor-arm820+        2080)    ; Windows CE - 0x820
(defwin32constant +processor-arm920+        2336)    ; Windows CE - 0x920
(defwin32constant +processor-arm-7tdmi+     70001)   ; Windows CE
(defwin32constant +processor-optil+         #x494f)  ; MSIL

(defwin32constant +processor-architecture-intel+            0)
(defwin32constant +processor-architecture-mips+             1)
(defwin32constant +processor-architecture-alpha+            2)
(defwin32constant +processor-architecture-ppc+              3)
(defwin32constant +processor-architecture-shx+              4)
(defwin32constant +processor-architecture-arm+              5)
(defwin32constant +processor-architecture-ia64+             6)
(defwin32constant +processor-architecture-alpha64+          7)
(defwin32constant +processor-architecture-msil+             8)
(defwin32constant +processor-architecture-amd64+            9)
(defwin32constant +processor-architecture-ia32-on-win64+    10)
(defwin32constant +processor-architecture-neutral+          11)

(defwin32constant +processor-architecture-unknown+ #xFFFF)

(defwin32constant +mf-insert+           #x00000000)
(defwin32constant +mf-change+           #x00000080)
(defwin32constant +mf-append+           #x00000100)
(defwin32constant +mf-delete+           #x00000200)
(defwin32constant +mf-remove+           #x00001000)

(defwin32constant +mf-bycommand+        #x00000000)
(defwin32constant +mf-byposition+       #x00000400)

(defwin32constant +mf-separator+        #x00000800)

(defwin32constant +mf-enabled+          #x00000000)
(defwin32constant +mf-grayed+           #x00000001)
(defwin32constant +mf-disabled+         #x00000002)

(defwin32constant +mf-unchecked+        #x00000000)
(defwin32constant +mf-checked+          #x00000008)
(defwin32constant +mf-usecheckbitmaps+  #x00000200)

(defwin32constant +mf-string+           #x00000000)
(defwin32constant +mf-bitmap+           #x00000004)
(defwin32constant +mf-ownerdraw+        #x00000100)

(defwin32constant +mf-popup+            #x00000010)
(defwin32constant +mf-menubarbreak+     #x00000020)
(defwin32constant +mf-menubreak+        #x00000040)

(defwin32constant +mf-unhilite+         #x00000000)
(defwin32constant +mf-hilite+           #x00000080)


(defwin32constant +mf-default+          #x00001000)

(defwin32constant +mf-sysmenu+          #x00002000)
(defwin32constant +mf-help+             #x00004000)

(defwin32constant +mf-rightjustify+     #x00004000)


(defwin32constant +mf-mouseselect+      #x00008000)

(defwin32constant +mf-end+              #x00000080) ; Obsolete -- only used by old RES files

(defwin32constant +mft-string+          +mf-string+)
(defwin32constant +mft-bitmap+          +mf-bitmap+)
(defwin32constant +mft-menubarbreak+    +mf-menubarbreak+)
(defwin32constant +mft-menubreak+       +mf-menubreak+)
(defwin32constant +mft-ownerdraw+       +mf-ownerdraw+)
(defwin32constant +mft-radiocheck+      #x00000200)
(defwin32constant +mft-separator+       +mf-separator+)
(defwin32constant +mft-rightorder+      #x00002000)
(defwin32constant +mft-rightjustify+    +mf-rightjustify+)

;; Menu flags for Add/Check/EnableMenuItem()
(defwin32constant +mfs-grayed+          #x00000003)
(defwin32constant +mfs-disabled+        +mfs-grayed+)
(defwin32constant +mfs-checked+         +mf-checked+)
(defwin32constant +mfs-hilite+          +mf-hilite+)
(defwin32constant +mfs-enabled+         +mf-enabled+)
(defwin32constant +mfs-unchecked+       +mf-unchecked+)
(defwin32constant +mfs-unhilite+        +mf-unhilite+)
(defwin32constant +mfs-default+         +mf-default+)

(defwin32constant +nim-add+         #x00000000)
(defwin32constant +nim-modify+      #x00000001)
(defwin32constant +nim-delete+      #x00000002)
(defwin32constant +nim-setfocus+    #x00000003)
(defwin32constant +nim-setversion+  #x00000004)

(defwin32constant +nif-message+     #x00000001)
(defwin32constant +nif-icon+        #x00000002)
(defwin32constant +nif-tip+         #x00000004)
(defwin32constant +nif-state+       #x00000008)
(defwin32constant +nif-info+        #x00000010)
(defwin32constant +nif-guid+        #x00000020)
(defwin32constant +nif-realtime+    #x00000040)
(defwin32constant +nif-showtip+     #x00000080)

(defwin32constant +mb-ok+                       #x00000000)
(defwin32constant +mb-okcancel+                 #x00000001)
(defwin32constant +mb-abortretryignore+         #x00000002)
(defwin32constant +mb-yesnocancel+              #x00000003)
(defwin32constant +mb-yesno+                    #x00000004)
(defwin32constant +mb-retrycancel+              #x00000005)

(defwin32constant +mb-canceltrycontinue+        #x00000006)

(defwin32constant +mb-iconhand+                 #x00000010)
(defwin32constant +mb-iconquestion+             #x00000020)
(defwin32constant +mb-iconexclamation+          #x00000030)
(defwin32constant +mb-iconasterisk+             #x00000040)

(defwin32constant +mb-usericon+                 #x00000080)
(defwin32constant +mb-iconwarning+              +mb-iconexclamation+)
(defwin32constant +mb-iconerror+                +mb-iconhand+)

(defwin32constant +mb-iconinformation+          +mb-iconasterisk+)
(defwin32constant +mb-iconstop+                 +mb-iconhand+)

(defwin32constant +mb-defbutton1+               #x00000000)
(defwin32constant +mb-defbutton2+               #x00000100)
(defwin32constant +mb-defbutton3+               #x00000200)

(defwin32constant +mb-defbutton4+               #x00000300)

(defwin32constant +mb-applmodal+                #x00000000)
(defwin32constant +mb-systemmodal+              #x00001000)
(defwin32constant +mb-taskmodal+                #x00002000)

(defwin32constant +mb-help+                     #x00004000) ; Help Button

(defwin32constant +mb-nofocus+                  #x00008000)
(defwin32constant +mb-setforeground+            #x00010000)
(defwin32constant +mb-default-desktop-only+     #x00020000)

(defwin32constant +mb-topmost+                  #x00040000)
(defwin32constant +mb-right+                    #x00080000)
(defwin32constant +mb-rtlreading+               #x00100000)


(defwin32constant +mb-service-notification+          #x00200000)
(defwin32constant +mb-service-notification-nt3x+     #x00040000)

(defwin32constant +mb-typemask+                 #x0000000F)
(defwin32constant +mb-iconmask+                 #x000000F0)
(defwin32constant +mb-defmask+                  #x00000F00)
(defwin32constant +mb-modemask+                 #x00003000)
(defwin32constant +mb-miscmask+                 #x0000C000)

(defwin32constant +tpm-leftbutton+  #x0000)
(defwin32constant +tpm-rightbutton+ #x0002)
(defwin32constant +tpm-leftalign+   #x0000)
(defwin32constant +tpm-centeralign+ #x0004)
(defwin32constant +tpm-rightalign+  #x0008)

(defwin32constant +tpm-topalign+        #x0000)
(defwin32constant +tpm-vcenteralign+    #x0010)
(defwin32constant +tpm-bottomalign+     #x0020)

(defwin32constant +tpm-horizontal+      #x0000) ; Horz alignment matters more
(defwin32constant +tpm-vertical+        #x0040) ; Vert alignment matters more
(defwin32constant +tpm-nonotify+        #x0080) ; Don't send any notification msgs
(defwin32constant +tpm-returncmd+       #x0100)

(defwin32constant +tpm-recurse+         #x0001)
(defwin32constant +tpm-horposanimation+ #x0400)
(defwin32constant +tpm-horneganimation+ #x0800)
(defwin32constant +tpm-verposanimation+ #x1000)
(defwin32constant +tpm-verneganimation+ #x2000)

(defwin32constant +tpm-noanimation+     #x4000)

(defwin32constant +tpm-layoutrtl+       #x8000)

(defwin32constant +tpm-workarea+        #x10000)

(defwin32constant +get-module-handle-ex-flag-pin+                 #x00000001)
(defwin32constant +get-module-handle-ex-flag-unchanged-refcount+  #x00000002)
(defwin32constant +get-module-handle-ex-flag-from-address+        #x00000004)

(defwin32constant      +ga-parent+       1)
(defwin32constant      +ga-root+         2)
(defwin32constant      +ga-rootowner+    3)

(defwin32constant +gw-hwndfirst+        0)
(defwin32constant +gw-hwndlast+         1)
(defwin32constant +gw-hwndnext+         2)
(defwin32constant +gw-hwndprev+         3)
(defwin32constant +gw-owner+            4)
(defwin32constant +gw-child+            5)
(defwin32constant +gw-enabledpopup+     6)
(defwin32constant +gw-max+              6)

(defwin32constant +kl-namelength+ 9)

(defwin32constant  +mapvk-vk-to-vsc+     0)
(defwin32constant  +mapvk-vsc-to-vk+     1)
(defwin32constant  +mapvk-vk-to-char+    2)
(defwin32constant  +mapvk-vsc-to-vk-ex+  3)

(defwin32constant +coinitbase-multithreaded+       #x0)      ; OLE calls objects on any thread.

(defwin32constant +coinit-apartmentthreaded+   #x2)      ; Apartment model
(defwin32constant +coinit-multithreaded+       +coinitbase-multithreaded+)
(defwin32constant +coinit-disable-ole1dde+     #x4)      ; Don't use DDE for Ole1 support.
(defwin32constant +coinit-speed-over-memory+   #x8)      ; Trade memory for speed.

(defwin32constant +rotregflags-allowanyclient+ #x1)
(defwin32constant +appidregflags-activate-iuserver-indesktop+ #x1)
(defwin32constant +appidregflags-secure-server-process-sd-and-bind+ #x2)
(defwin32constant +appidregflags-issue-activation-rpc-at-identify+ #x4)
(defwin32constant +appidregflags-iuserver-unmodified-logon-token+ #x8)
(defwin32constant +appidregflags-iuserver-self-sid-in-launch-permission+ #x10)
(defwin32constant +appidregflags-iuserver-activate-in-client-session-only+ #x20)
(defwin32constant +appidregflags-reserved1+ #x40)
(defwin32constant +appidregflags-reserved2+ #x80)

(defwin32constant +dcomscm-activation-use-all-authnservices+ #x1)
(defwin32constant +dcomscm-activation-disallow-unsecure-call+ #x2)
(defwin32constant +dcomscm-resolve-use-all-authnservices+ #x4)
(defwin32constant +dcomscm-resolve-disallow-unsecure-call+ #x8)
(defwin32constant +dcomscm-ping-use-mid-authnservice+ #x10)
(defwin32constant +dcomscm-ping-disallow-unsecure-call+ #x20)

(defwin32constant +clsctx-inproc-server+	 #x1)
(defwin32constant +clsctx-inproc-handler+	 #x2)
(defwin32constant +clsctx-local-server+	 #x4)
(defwin32constant +clsctx-inproc-server16+	 #x8)
(defwin32constant +clsctx-remote-server+	 #x10)
(defwin32constant +clsctx-inproc-handler16+	 #x20)
(defwin32constant +clsctx-reserved1+	 #x40)
(defwin32constant +clsctx-reserved2+	 #x80)
(defwin32constant +clsctx-reserved3+	 #x100)
(defwin32constant +clsctx-reserved4+	 #x200)
(defwin32constant +clsctx-no-code-download+	 #x400)
(defwin32constant +clsctx-reserved5+	 #x800)
(defwin32constant +clsctx-no-custom-marshal+	 #x1000)
(defwin32constant +clsctx-enable-code-download+	 #x2000)
(defwin32constant +clsctx-no-failure-log+	 #x4000)
(defwin32constant +clsctx-disable-aaa+	 #x8000)
(defwin32constant +clsctx-enable-aaa+	 #x10000)
(defwin32constant +clsctx-from-default-context+	 #x20000)
(defwin32constant +clsctx-activate-32-bit-server+	 #x40000)
(defwin32constant +clsctx-activate-64-bit-server+	 #x80000)
(defwin32constant +clsctx-enable-cloaking+	 #x100000)
(defwin32constant +clsctx-appcontainer+	 #x400000)
(defwin32constant +clsctx-activate-aaa-as-iu+	 #x800000)
(defwin32constant +clsctx-ps-dll+	 #x80000000)

(defwin32constant +file-type-unknown+   #x0000)
(defwin32constant +file-type-disk+      #x0001)
(defwin32constant +file-type-char+      #x0002)
(defwin32constant +file-type-pipe+      #x0003)
(defwin32constant +file-type-remote+    #x8000)

(defwin32constant +std-input-handle+    (%as-dword -10))
(defwin32constant +std-output-handle+   (%as-dword -11))
(defwin32constant +std-error-handle+    (%as-dword -12))

(defwin32constant +noparity+            0)
(defwin32constant +oddparity+           1)
(defwin32constant +evenparity+          2)
(defwin32constant +markparity+          3)
(defwin32constant +spaceparity+         4)

(defwin32constant +onestopbit+          0)
(defwin32constant +one5stopbits+        1)
(defwin32constant +twostopbits+         2)

(defwin32constant +ignore+              0)       ;; Ignore signal
(defwin32constant +infinite+            #xFFFFFFFF)  ;; Infinite timeout

(defwin32constant +cbr-110+             110)
(defwin32constant +cbr-300+             300)
(defwin32constant +cbr-600+             600)
(defwin32constant +cbr-1200+            1200)
(defwin32constant +cbr-2400+            2400)
(defwin32constant +cbr-4800+            4800)
(defwin32constant +cbr-9600+            9600)
(defwin32constant +cbr-14400+           14400)
(defwin32constant +cbr-19200+           19200)
(defwin32constant +cbr-38400+           38400)
(defwin32constant +cbr-56000+           56000)
(defwin32constant +cbr-57600+           57600)
(defwin32constant +cbr-115200+          115200)
(defwin32constant +cbr-128000+          128000)
(defwin32constant +cbr-256000+          256000)

(defwin32constant +ce-rxover+           #x0001)  ; Receive Queue overflow
(defwin32constant +ce-overrun+          #x0002)  ; Receive Overrun Error
(defwin32constant +ce-rxparity+         #x0004)  ; Receive Parity Error
(defwin32constant +ce-frame+            #x0008)  ; Receive Framing error
(defwin32constant +ce-break+            #x0010)  ; Break Detected
(defwin32constant +ce-txfull+           #x0100)  ; TX Queue is full
(defwin32constant +ce-pto+              #x0200)  ; LPTx Timeout
(defwin32constant +ce-ioe+              #x0400)  ; LPTx I/O Error
(defwin32constant +ce-dns+              #x0800)  ; LPTx Device not selected
(defwin32constant +ce-oop+              #x1000)  ; LPTx Out-Of-Paper
(defwin32constant +ce-mode+             #x8000)  ; Requested mode unsupported

(defwin32constant +ie-badid+            -1)    ; Invalid or unsupported id
(defwin32constant +ie-open+             -2)    ; Device Already Open
(defwin32constant +ie-nopen+            -3)    ; Device Not Open
(defwin32constant +ie-memory+           -4)    ; Unable to allocate queues
(defwin32constant +ie-default+          -5)    ; Error in default parameters
(defwin32constant +ie-hardware+         -10)   ; Hardware Not Present
(defwin32constant +ie-bytesize+         -11)   ; Illegal Byte Size
(defwin32constant +ie-baudrate+         -12)   ; Unsupported BaudRate

(defwin32constant +ev-rxchar+           #x0001)  ; Any Character received
(defwin32constant +ev-rxflag+           #x0002)  ; Received certain character
(defwin32constant +ev-txempty+          #x0004)  ; Transmitt Queue Empty
(defwin32constant +ev-cts+              #x0008)  ; CTS changed state
(defwin32constant +ev-dsr+              #x0010)  ; DSR changed state
(defwin32constant +ev-rlsd+             #x0020)  ; RLSD changed state
(defwin32constant +ev-break+            #x0040)  ; BREAK received
(defwin32constant +ev-err+              #x0080)  ; Line status error occurred
(defwin32constant +ev-ring+             #x0100)  ; Ring signal detected
(defwin32constant +ev-perr+             #x0200)  ; Printer error occured
(defwin32constant +ev-rx80full+         #x0400)  ; Receive buffer is 80 percent full
(defwin32constant +ev-event1+           #x0800)  ; Provider specific event 1
(defwin32constant +ev-event2+           #x1000)  ; Provider specific event 2

(defwin32constant +setxoff+             1)       ; Simulate XOFF received
(defwin32constant +setxon+              2)       ; Simulate XON received
(defwin32constant +setrts+              3)       ; Set RTS high
(defwin32constant +clrrts+              4)       ; Set RTS low
(defwin32constant +setdtr+              5)       ; Set DTR high
(defwin32constant +clrdtr+              6)       ; Set DTR low
(defwin32constant +resetdev+            7)       ; Reset device if possible
(defwin32constant +setbreak+            8)       ; Set the device break line.
(defwin32constant +clrbreak+            9)       ; Clear the device break line.

(defwin32constant +purge-txabort+       #x0001)  ; Kill the pending/current writes to the comm port.
(defwin32constant +purge-rxabort+       #x0002)  ; Kill the pending/current reads to the comm port.
(defwin32constant +purge-txclear+       #x0004)  ; Kill the transmit queue if there.
(defwin32constant +purge-rxclear+       #x0008)  ; Kill the typeahead buffer if there.

(defwin32constant +lptx+                #x80)    ; Set if ID is for LPT device

(defwin32struct memory-status
  (length dword)
  (memory-load dword)
  (total-phys size-t)
  (avail-phys size-t)
  (total-page-file size-t)
  (avail-page-file size-t)
  (total-virtual size-t)
  (avail-virtual size-t))

(defwin32struct memory-status-ex
  (length dword)
  (memory-load dword)
  (total-phys dwordlong)
  (avail-phys dwordlong)
  (total-page-file dwordlong)
  (avail-page-file dwordlong)
  (total-virtual dwordlong)
  (avail-virtual dwordlong)
  (avail-extended-virtual dwordlong))

(defwin32struct openfilename
  (size               dword)
  (owner              hwnd)
  (instance           hinstance)
  (filter             lpcwstr)
  (custom-filter      lpwstr)
  (max-custom-filter  dword)
  (filter-index       dword)
  (file               lpwstr)
  (max-file           dword)
  (file-title         lpwstr)
  (max-file-title     dword)
  (initial-dir        lpcwstr)
  (title              lpcwstr)
  (flags              dword)
  (file-offset        word)
  (file-textension    word)
  (def-ext            lpcwstr)
  (cust-data          lparam)
  (fn-hook            :pointer)
  (template-name      lpcwstr)
  (pv-reserved        (:pointer :void))
  (dw-reserved        dword)
  (Flags-ex           dword));

(defwin32type date :double)
(defwin32union cy
  (int64 longlong))

(defwin32struct decimal
  (w-reserved ushort)
  (scale byte)
  (sign byte)
  (hi-32 ulong)
  (lo-32 ulong)
  (mid-32 ulong))

(defwin32struct os-version-info-ex
  (os-version-info-size dword)
  (major-version dword)
  (minor-version dword)
  (build-number dword)
  (platform-id dword)
  (csd-version wchar :count 128)
  (service-pack-major word)
  (service-pack-minor word)
  (suite-mask word)
  (product-type byte)
  (reserved byte))

(defwin32struct system-info
  (processor-architecture word)
  (reserved word)
  (page-size dword)
  (minimum-application-address :pointer)
  (maximum-application-address :pointer)
  (active-processor-mask dword-ptr)
  (number-of-processors dword)
  (processor-type dword)
  (allocation-granularity dword)
  (processor-level word)
  (processor-revision word))

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

(defwin32struct iconinfo
  (icon bool)
  (x-hotspot dword)
  (y-hotspot dword)
  (bm-mask hbitmap)
  (bm-color hbitmap))

(defwin32struct point
  (x long)
  (y long))

(defwin32struct pointl
  (x long)
  (y long))

(defwin32struct trackmouseevent
  (size dword)
  (flags dword)
  (hwnd hwnd)
  (hover-time dword))

(defwin32struct wndclass
  (style uint)
  (wndproc wndproc)
  (cls-extra :int)
  (wnd-extra :int)
  (instance hinstance)
  (icon hicon)
  (cursor hcursor)
  (background hbrush)
  (menu-name lpctstr)
  (wndclass-name lpctstr))

(defwin32struct wndclassex
  (size uint)
  (style uint)
  (wndproc wndproc)
  (cls-extra :int)
  (wnd-extra :int)
  (instance hinstance)
  (icon hicon)
  (cursor hcursor)
  (background hbrush)
  (menu-name lpctstr)
  (wndclass-name lpctstr)
  (icon-sm hicon))

(defwin32struct flashwindowinfo
  (size uint)
  (hwnd hwnd)
  (flags dword)
  (count uint)
  (timeout dword))

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

(defwin32struct xform
  (em11 float)
  (em12 float)
  (em21 float)
  (em22 float)
  (edx float)
  (edy float))

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

(defwin32struct logbrush
  (style uint)
  (color colorref)
  (hatch ulong-ptr))

(defwin32struct logbrush32
  (style uint)
  (color colorref)
  (hatch ulong))

(defwin32struct logpen
  (style uint)
  (width point)
  (color colorref))

(defwin32struct polytext
  (x :int)
  (y :int)
  (n uint)
  (text lpcwstr)
  (flags uint)
  (rect rect)
  (pdx (:pointer :int)))

(defwin32struct bitmap
  (type long)
  (width long)
  (height long)
  (width-bytes long)
  (planes word)
  (bits-pixel word)
  (bits (:pointer :void)))

(defwin32struct rgbtriple
  (blue byte)
  (green byte)
  (red byte))

(defwin32struct rgbquad
  (blue byte)
  (green byte)
  (red byte)
  (reserved byte))

(defwin32struct bitmapinfoheader
  (size dword)
  (width long)
  (height long)
  (planes word)
  (bit-count word)
  (compression dword)
  (size-image dword)
  (x-pels-per-meter long)
  (y-pels-per-meter long)
  (clr-used dword)
  (clr-important dword))

(defwin32struct ciexyz
  (x fxpt2dot30)
  (y fxpt2dot30)
  (z fxpt2dot30))

(defwin32struct ciexyztriple
  (red ciexyz)
  (green ciexyz)
  (blue ciexyz))

(defwin32struct bitmapinfoheaderv4
  (size dword)
  (width long)
  (height long)
  (planes word)
  (bit-count word)
  (compression dword)
  (size-image dword)
  (x-pels-per-meter long)
  (y-pels-per-meter long)
  (clr-used dword)
  (clr-important dword)
  (red-mask dword)
  (green-mask dword)
  (blue-mask dword)
  (alpha-mask dword)
  (cs-type dword)
  (end-points ciexyztriple)
  (gamma-red dword)
  (gamma-green dword)
  (gamma-blue dword))

(defwin32struct bitmapinfoheaderv5
  (size dword)
  (width long)
  (height long)
  (planes word)
  (bit-count word)
  (compression dword)
  (size-image dword)
  (x-pels-per-meter long)
  (y-pels-per-meter long)
  (clr-used dword)
  (clr-important dword)
  (red-mask dword)
  (green-mask dword)
  (blue-mask dword)
  (alpha-mask dword)
  (cs-type dword)
  (end-points ciexyztriple)
  (gamma-red dword)
  (gamma-green dword)
  (gamma-blue dword)
  (intent dword)
  (profile-data dword)
  (profile-size dword)
  (reserved dword))

(defwin32struct bitmapinfo
  (header bitmapinfoheader)
  (colors rgbquad :count 1))

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

(defwin32type refguid (:pointer guid))
(defwin32type clsid guid)
(defwin32type iid guid)
(defwin32type refclsid (:pointer clsid))
(defwin32type refiid (:pointer iid))

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

(defwin32struct notify-icon-data
  (size dword)
  (hwnd hwnd)
  (id uint)
  (flags uint)
  (callback-message uint)
  (icon hicon)
  (tip wchar :count 128)
  (state dword)
  (state-mask dword)
  (info wchar :count 256)
  (version uint)
  (info-title wchar :count 64)
  (info-flags dword)
  (item guid)
  (balloon-icon hicon))

(defwin32struct notify-icon-identifier
  (size dword)
  (hwnd hwnd)
  (id uint)
  (guid-item guid))

(defwin32struct dcb
  (dcb-length dword)
  (baud-rate dword)
  (settings :uint32)
  (reserved word)
  (on-lim word)
  (off-lim word)
  (byte-size byte)
  (parity byte)
  (stop-bits byte)
  (on-char :char)
  (off-char :char)
  (error-char :char)
  (eof-char :char)
  (evt-char :char)
  (reserved-1 word))

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

(defwin32constant  +hkl-prev+            0)
(defwin32constant  +hkl-next+            1)

(defwin32constant  +klf-activate+        #x00000001)
(defwin32constant  +klf-substitute-ok+   #x00000002)
(defwin32constant  +klf-reorder+         #x00000008)
(defwin32constant  +klf-replacelang+     #x00000010)
(defwin32constant  +klf-notellshell+     #x00000080)
(defwin32constant  +klf-setforprocess+   #x00000100)
(defwin32constant  +klf-shiftlock+       #x00010000)
(defwin32constant  +klf-reset+           #x40000000)

;;; Predefined Clipboard Formats
(defwin32constant  +cf-text+             1)
(defwin32constant  +cf-bitmap+           2)
(defwin32constant  +cf-metafilepict+     3)
(defwin32constant  +cf-sylk+             4)
(defwin32constant  +cf-dif+              5)
(defwin32constant  +cf-tiff+             6)
(defwin32constant  +cf-oemtext+          7)
(defwin32constant  +cf-dib+              8)
(defwin32constant  +cf-palette+          9)
(defwin32constant  +cf-pendata+          10)
(defwin32constant  +cf-riff+             11)
(defwin32constant  +cf-wave+             12)
(defwin32constant  +cf-unicodetext+      13)
(defwin32constant  +cf-enhmetafile+      14)
;; #if(WINVER >= #x0400)
(defwin32constant  +cf-hdrop+            15)
(defwin32constant  +cf-locale+           16)
;; #endif /* WINVER >= #x0400 */
;; #if(WINVER >= #x0500)
(defwin32constant  +cf-dibv5+            17)
;; #endif /* WINVER >= #x0500 */

;; #if(WINVER >= #x0500)
(defwin32constant  +cf-max+              18)
;; #elif(WINVER >= #x0400)
;; CF_MAX              17
;; #else
;; CF_MAX              15
;; #endif

(defwin32constant  +cf-ownerdisplay+     #x0080)
(defwin32constant  +cf-dsptext+          #x0081)
(defwin32constant  +cf-dspbitmap+        #x0082)
(defwin32constant  +cf-dspmetafilepict+  #x0083)
(defwin32constant  +cf-dspenhmetafile+   #x008E)

;;; "Private" formats don't get GlobalFree()'d
(defwin32constant  +cf-privatefirst+     #x0200)
(defwin32constant  +cf-privatelast+      #x02FF)

;;; "GDIOBJ" formats do get DeleteObject()'d
(defwin32constant  +cf-gdiobjfirst+      #x0300)
(defwin32constant  +cf-gdiobjlast+       #x03FF)

(defwin32constant  +mod-alt+                         #x0001)
(defwin32constant  +mod-control+                     #x0002)
(defwin32constant  +mod-shift+                       #x0004)

(defwin32constant  +mod-left+                        #x8000)
(defwin32constant  +mod-right+                       #x4000)

(defwin32constant  +mod-on-keyup+                    #x0800)
(defwin32constant  +mod-ignore-all-modifier+         #x0400)

(defwin32constant +startf-useshowwindow+       #x00000001)
(defwin32constant +startf-usesize+             #x00000002)
(defwin32constant +startf-useposition+         #x00000004)
(defwin32constant +startf-usecountchars+       #x00000008)
(defwin32constant +startf-usefillattribute+    #x00000010)
(defwin32constant +startf-runfullscreen+       #x00000020)  ;; ignored for non-x86 platforms
(defwin32constant +startf-forceonfeedback+     #x00000040)
(defwin32constant +startf-forceofffeedback+    #x00000080)
(defwin32constant +startf-usestdhandles+       #x00000100)

(defwin32constant +startf-usehotkey+           #x00000200)
(defwin32constant +startf-titleislinkname+     #x00000800)
(defwin32constant +startf-titleisappid+        #x00001000)
(defwin32constant +startf-preventpinning+      #x00002000)

(defwin32constant +logon32-logon-interactive+       2)
(defwin32constant +logon32-logon-network+           3)
(defwin32constant +logon32-logon-batch+             4)
(defwin32constant +logon32-logon-service+           5)
(defwin32constant +logon32-logon-unlock+            7)
;; #if(_WIN32_WINNT >= 0x0500)
(defwin32constant +logon32-logon-network-cleartext+ 8)
(defwin32constant +logon32-logon-new-credentials+   9)
;; #endif // (_WIN32_WINNT >= 0x0500)

(defwin32constant +logon32-provider-default+    0)
(defwin32constant +logon32-provider-winnt35+    1)
;; #if(_WIN32_WINNT >= 0x0400)
(defwin32constant +logon32-provider-winnt40+    2)
;; #endif /* _WIN32_WINNT >= 0x0400 */
;; #if(_WIN32_WINNT >= 0x0500)
(defwin32constant +logon32-provider-winnt50+    3)
;; #endif // (_WIN32_WINNT >= 0x0500)
;; #if(_WIN32_WINNT >= 0x0600)
(defwin32constant +logon32-provider-virtual+    4)
;; #endif // (_WIN32_WINNT >= 0x0600)

;;
;; Process dwCreationFlag values
;;

(defwin32constant +debug-process+                     #x00000001)
(defwin32constant +debug-only-this-process+           #x00000002)
(defwin32constant +create-suspended+                  #x00000004)
(defwin32constant +detached-process+                  #x00000008)

(defwin32constant +create-new-console+                #x00000010)
(defwin32constant +normal-priority-class+             #x00000020)
(defwin32constant +idle-priority-class+               #x00000040)
(defwin32constant +high-priority-class+               #x00000080)

(defwin32constant +realtime-priority-class+           #x00000100)
(defwin32constant +create-new-process-group+          #x00000200)
(defwin32constant +create-unicode-environment+        #x00000400)
(defwin32constant +create-separate-wow-vdm+           #x00000800)

(defwin32constant +create-shared-wow-vdm+             #x00001000)
(defwin32constant +create-forcedos+                   #x00002000)
(defwin32constant +below-normal-priority-class+       #x00004000)
(defwin32constant +above-normal-priority-class+       #x00008000)

(defwin32constant +inherit-parent-affinity+           #x00010000)
(defwin32constant +inherit-caller-priority+           #x00020000)    ;; Deprecated
(defwin32constant +create-protected-process+          #x00040000)
(defwin32constant +extended-startupinfo-present+      #x00080000)

(defwin32constant +process-mode-background-begin+     #x00100000)
(defwin32constant +process-mode-background-end+       #x00200000)

(defwin32constant +create-breakaway-from-job+         #x01000000)
(defwin32constant +create-preserve-code-authz-level+  #x02000000)
(defwin32constant +create-default-error-mode+         #x04000000)
(defwin32constant +create-no-window+                  #x08000000)

(defwin32constant +profile-user+                      #x10000000)
(defwin32constant +profile-kernel+                    #x20000000)
(defwin32constant +profile-server+                    #x40000000)
(defwin32constant +create-ignore-system-default+      #x80000000)

;;
;; Thread dwCreationFlag values
;;

;;#define CREATE_SUSPENDED                  #x00000004

(defwin32constant +stack-size-param-is-a-reservation+   #x00010000)    ;; Threads only

(defwin32constant  +section-query+                #x0001)
(defwin32constant  +section-map-write+            #x0002)
(defwin32constant  +section-map-read+             #x0004)
(defwin32constant  +section-map-execute+          #x0008)
(defwin32constant  +section-extend-size+          #x0010)
(defwin32constant  +section-map-execute-explicit+ #x0020) ;; not included in SECTION_ALL_ACCESS

(defwin32constant  +section-all-access+ (logior +standard-rights-required+
                                                +section-query+
                                                +section-map-write+
                                                +section-map-read+
                                                +section-map-execute+
                                                +section-extend-size+))

(defwin32constant  +session-query-access+  #x0001)
(defwin32constant  +session-modify-access+ #x0002)

(defwin32constant  +session-all-access+ (logior +standard-rights-required+
                                                +session-query-access+
                                                +session-modify-access+))

(defwin32constant  +page-noaccess+          #x01)
(defwin32constant  +page-readonly+          #x02)
(defwin32constant  +page-readwrite+         #x04)
(defwin32constant  +page-writecopy+         #x08)
;; #if WINAPI-FAMILY-PARTITION(WINAPI-PARTITION-DESKTOP)
(defwin32constant  +page-execute+           #x10)
(defwin32constant  +page-execute-read+      #x20)
(defwin32constant  +page-execute-readwrite+ #x40)
(defwin32constant  +page-execute-writecopy+ #x80)
;; #endif  WINAPI-FAMILY-PARTITION(WINAPI-PARTITION-DESKTOP)
(defwin32constant  +page-guard+            #x100)
(defwin32constant  +page-nocache+          #x200)
(defwin32constant  +page-writecombine+     #x400)
(defwin32constant  +page-revert-to-file-map+     #x80000000)
(defwin32constant  +mem-commit+                  #x1000)
(defwin32constant  +mem-reserve+                 #x2000)
(defwin32constant  +mem-decommit+                #x4000)
(defwin32constant  +mem-release+                 #x8000)
(defwin32constant  +mem-free+                    #x10000)
(defwin32constant  +mem-private+                 #x20000)
(defwin32constant  +mem-mapped+                  #x40000)
(defwin32constant  +mem-reset+                   #x80000)
(defwin32constant  +mem-top-down+                #x100000)
(defwin32constant  +mem-write-watch+             #x200000)
(defwin32constant  +mem-physical+                #x400000)
(defwin32constant  +mem-rotate+                  #x800000)
(defwin32constant  +mem-different-image-base-ok+ #x800000)
(defwin32constant  +mem-reset-undo+              #x1000000)
(defwin32constant  +mem-large-pages+             #x20000000)
(defwin32constant  +mem-4mb-pages+               #x80000000)
(defwin32constant  +sec-file+           #x800000)
(defwin32constant  +sec-image+         #x1000000)
(defwin32constant  +sec-protected-image+  #x2000000)
(defwin32constant  +sec-reserve+       #x4000000)
(defwin32constant  +sec-commit+        #x8000000)
(defwin32constant  +sec-nocache+      #x10000000)
(defwin32constant  +sec-writecombine+ #x40000000)
(defwin32constant  +sec-large-pages+  #x80000000)
(defwin32constant  +sec-image-no-execute+ (logior +sec-image+ +sec-nocache+))
(defwin32constant  +mem-image+         +sec-image+)
(defwin32constant  +write-watch-flag-reset+  #x01)
(defwin32constant  +mem-unmap-with-transient-boost+  #x01)

(defwin32constant +numa-no-preferred-node+ #xffffffff)

(defwin32constant +gmem-fixed+          #x0000)
(defwin32constant +gmem-moveable+       #x0002)
(defwin32constant +gmem-nocompact+      #x0010)
(defwin32constant +gmem-nodiscard+      #x0020)
(defwin32constant +gmem-zeroinit+       #x0040)
(defwin32constant +gmem-modify+         #x0080)
(defwin32constant +gmem-discardable+    #x0100)
(defwin32constant +gmem-not-banked+     #x1000)
(defwin32constant +gmem-share+          #x2000)
(defwin32constant +gmem-ddeshare+       #x2000)
(defwin32constant +gmem-notify+         #x4000)
(defwin32constant +gmem-lower+          +gmem-not-banked+)
(defwin32constant +gmem-valid-flags+    #x7F72)
(defwin32constant +gmem-invalid-handle+ #x8000)

(defwin32constant +ghnd+                (logior +gmem-moveable+ +gmem-zeroinit+))
(defwin32constant +gptr+                (logior +gmem-fixed+  +gmem-zeroinit+))

;/* Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE) */
(defwin32constant  +gmem-discarded+      #x4000)
(defwin32constant  +gmem-lockcount+      #x00FF)

(defwin32constant +fr-private+     #x10)
(defwin32constant +fr-not-enum+    #x20)

(defwin32constant +activeobject-strong+ #x0)
(defwin32constant +activeobject-weak+ #x1)

 ;;/*
 ;; * VARENUM usage key,
 ;; *
 ;; * * [V] - may appear in a VARIANT
 ;; * * [T] - may appear in a TYPEDESC
 ;; * * [P] - may appear in an OLE property set
 ;; * * [S] - may appear in a Safe Array
 ;; *
 ;; *
 ;; *  VT_EMPTY            [V]   [P]     nothing
 ;; *  VT_NULL             [V]   [P]     SQL style Null
 ;; *  VT_I2               [V][T][P][S]  2 byte signed int
 ;; *  VT_I4               [V][T][P][S]  4 byte signed int
 ;; *  VT_R4               [V][T][P][S]  4 byte real
 ;; *  VT_R8               [V][T][P][S]  8 byte real
 ;; *  VT_CY               [V][T][P][S]  currency
 ;; *  VT_DATE             [V][T][P][S]  date
 ;; *  VT_BSTR             [V][T][P][S]  OLE Automation string
 ;; *  VT_DISPATCH         [V][T]   [S]  IDispatch *
 ;; *  VT_ERROR            [V][T][P][S]  SCODE
 ;; *  VT_BOOL             [V][T][P][S]  True=-1, False=0
 ;; *  VT_VARIANT          [V][T][P][S]  VARIANT *
 ;; *  VT_UNKNOWN          [V][T]   [S]  IUnknown *
 ;; *  VT_DECIMAL          [V][T]   [S]  16 byte fixed point
 ;; *  VT_RECORD           [V]   [P][S]  user defined type
 ;; *  VT_I1               [V][T][P][s]  signed char
 ;; *  VT_UI1              [V][T][P][S]  unsigned char
 ;; *  VT_UI2              [V][T][P][S]  unsigned short
 ;; *  VT_UI4              [V][T][P][S]  ULONG
 ;; *  VT_I8                  [T][P]     signed 64-bit int
 ;; *  VT_UI8                 [T][P]     unsigned 64-bit int
 ;; *  VT_INT              [V][T][P][S]  signed machine int
 ;; *  VT_UINT             [V][T]   [S]  unsigned machine int
 ;; *  VT_INT_PTR             [T]        signed machine register size width
 ;; *  VT_UINT_PTR            [T]        unsigned machine register size width
 ;; *  VT_VOID                [T]        C style void
 ;; *  VT_HRESULT             [T]        Standard return type
 ;; *  VT_PTR                 [T]        pointer type
 ;; *  VT_SAFEARRAY           [T]        (use VT_ARRAY in VARIANT)
 ;; *  VT_CARRAY              [T]        C style array
 ;; *  VT_USERDEFINED         [T]        user defined type
 ;; *  VT_LPSTR               [T][P]     null terminated string
 ;; *  VT_LPWSTR              [T][P]     wide null terminated string
 ;; *  VT_FILETIME               [P]     FILETIME
 ;; *  VT_BLOB                   [P]     Length prefixed bytes
 ;; *  VT_STREAM                 [P]     Name of the stream follows
 ;; *  VT_STORAGE                [P]     Name of the storage follows
 ;; *  VT_STREAMED_OBJECT        [P]     Stream contains an object
 ;; *  VT_STORED_OBJECT          [P]     Storage contains an object
 ;; *  VT_VERSIONED_STREAM       [P]     Stream with a GUID version
 ;; *  VT_BLOB_OBJECT            [P]     Blob contains an object 
 ;; *  VT_CF                     [P]     Clipboard format
 ;; *  VT_CLSID                  [P]     A Class ID
 ;; *  VT_VECTOR                 [P]     simple counted array
 ;; *  VT_ARRAY            [V]           SAFEARRAY*
 ;; *  VT_BYREF            [V]           void* for local use
 ;; *  VT_BSTR_BLOB                      Reserved for system use
 ;; */
(defwin32constant        +vt-empty+	 0)
(defwin32constant        +vt-null+	 1)
(defwin32constant        +vt-i2+	 2)
(defwin32constant        +vt-i4+	 3)
(defwin32constant        +vt-r4+	 4)
(defwin32constant        +vt-r8+	 5)
(defwin32constant        +vt-cy+	 6)
(defwin32constant        +vt-date+	 7)
(defwin32constant        +vt-bstr+	 8)
(defwin32constant        +vt-dispatch+	 9)
(defwin32constant        +vt-error+	 10)
(defwin32constant        +vt-bool+	 11)
(defwin32constant        +vt-variant+	 12)
(defwin32constant        +vt-unknown+	 13)
(defwin32constant        +vt-decimal+	 14)
(defwin32constant        +vt-i1+	 16)
(defwin32constant        +vt-ui1+	 17)
(defwin32constant        +vt-ui2+	 18)
(defwin32constant        +vt-ui4+	 19)
(defwin32constant        +vt-i8+	 20)
(defwin32constant        +vt-ui8+	 21)
(defwin32constant        +vt-int+	 22)
(defwin32constant        +vt-uint+	 23)
(defwin32constant        +vt-void+	 24)
(defwin32constant        +vt-hresult+	 25)
(defwin32constant        +vt-ptr+	 26)
(defwin32constant        +vt-safearray+	 27)
(defwin32constant        +vt-carray+	 28)
(defwin32constant        +vt-userdefined+	 29)
(defwin32constant        +vt-lpstr+	 30)
(defwin32constant        +vt-lpwstr+	 31)
(defwin32constant        +vt-record+	 36)
(defwin32constant        +vt-int-ptr+	 37)
(defwin32constant        +vt-uint-ptr+	 38)
(defwin32constant        +vt-filetime+	 64)
(defwin32constant        +vt-blob+	 65)
(defwin32constant        +vt-stream+	 66)
(defwin32constant        +vt-storage+	 67)
(defwin32constant        +vt-streamed-object+	 68)
(defwin32constant        +vt-stored-object+	 69)
(defwin32constant        +vt-blob-object+	 70)
(defwin32constant        +vt-cf+	 71)
(defwin32constant        +vt-clsid+	 72)
(defwin32constant        +vt-versioned-stream+	 73)
(defwin32constant        +vt-bstr-blob+	 #xfff)
(defwin32constant        +vt-vector+	 #x1000)
(defwin32constant        +vt-array+	 #x2000)
(defwin32constant        +vt-byref+	 #x4000)
(defwin32constant        +vt-reserved+	 #x8000)
(defwin32constant        +vt-illegal+	 #xffff)
(defwin32constant        +vt-illegalmasked+	 #xfff)
(defwin32constant        +vt-typemask+	 #xfff)

(defwin32constant +th32cs-snapheaplist+ #x00000001)
(defwin32constant +th32cs-snapprocess+  #x00000002)
(defwin32constant +th32cs-snapthread+   #x00000004)
(defwin32constant +th32cs-snapmodule+   #x00000008)
(defwin32constant +th32cs-snapmodule32+ #x00000010)
(defwin32constant +th32cs-snapall+      (logior +th32cs-snapheaplist+ +th32cs-snapprocess+ +th32cs-snapthread+ +th32cs-snapmodule+))
(defwin32constant +th32cs-inherit+      #x80000000)

(defwin32constant +keyeventf-extendedkey+ #x0001)
(defwin32constant +keyeventf-keyup+       #x0002)
(defwin32constant +keyeventf-unicode+     #x0004)
(defwin32constant +keyeventf-scancode+    #x0008)

(defwin32constant +mouseeventf-move+                #x0001) ; mouse move
(defwin32constant +mouseeventf-leftdown+            #x0002) ; left button down
(defwin32constant +mouseeventf-leftup+              #x0004) ; left button up
(defwin32constant +mouseeventf-rightdown+           #x0008) ; right button down
(defwin32constant +mouseeventf-rightup+             #x0010) ; right button up
(defwin32constant +mouseeventf-middledown+          #x0020) ; middle button down
(defwin32constant +mouseeventf-middleup+            #x0040) ; middle button up
(defwin32constant +mouseeventf-xdown+               #x0080) ; x button down
(defwin32constant +mouseeventf-xup+                 #x0100) ; x button down
(defwin32constant +mouseeventf-wheel+               #x0800) ; wheel button rolled
(defwin32constant +mouseeventf-hwheel+              #x01000) ; hwheel button rolled
(defwin32constant +mouseeventf-move-nocoalesce+     #x2000) ; do not coalesce mouse moves
(defwin32constant +mouseeventf-virtualdesk+         #x4000) ; map to entire virtual desktop
(defwin32constant +mouseeventf-absolute+            #x8000) ; absolute move

(defwin32constant +input-mouse+ 0)
(defwin32constant +input-keyboard+ 1)
(defwin32constant +input-hardware+ 2)


(defwin32struct startupinfo
  (size dword)
  (reserved lpwstr)
  (desktop lpwstr)
  (title lpwstr)
  (x dword)
  (y dword)
  (width dword)
  (height dword)
  (char-width dword)
  (char-height dword)
  (fill-attributes dword)
  (flags dword)
  (show-window word)
  (reserved-2-size word)
  (reserved-2-buf (:pointer byte))
  (std-input handle)
  (std-output handle)
  (std-error handle))

(defwin32struct process-information
  (process handle)
  (thread handle)
  (process-id dword)
  (thread-id dword))

(defwin32struct quota-limits
  (paged-pool-limit size-t)
  (non-paged-pool-limit size-t)
  (minimum-working-set-size size-t)
  (maximum-working-set-size size-t)
  (page-file-limit size-t)
  (time-limit large-integer))

(defwin32struct processor-number
  (group word)
  (number byte)
  (reserved byte))

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

(defwin32struct last-input-info
  (size uint)
  (time dword))

(defwin32struct mouse-move-point
  (x :int)
  (y :int)
  (time dword)
  (extra-info ulong-ptr))

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

(defwin32struct copydatastruct
  (dw-data ulong-ptr)
  (cb-data dword)
  (lp-data (:pointer :void)))

(defwin32struct menuiteminfo
  (size uint)
  (mask uint)
  (type uint)
  (state uint)
  (id uint)
  (sub-menu hmenu)
  (bmp-checked hbitmap)
  (bmp-unchecked hbitmap)
  (item-data ulong-ptr)
  (type-data lpwstr)
  (cch uint)
  (bmp-item hbitmap))

(defwin32struct processentry32
  (size dword)
  (usage dword)
  (process-id dword)
  (default-heap-id ulong-ptr)
  (module-id dword)
  (count-threads dword)
  (parent-process-id dword)
  (pri-class-base long)
  (flags dword)
  (exe-file wchar :count 260))

(defwin32struct moduleentry32
  (size dword)
  (module-id dword)
  (process-id dword)
  (glb-count-usage dword)
  (proc-count-usage dword)
  (mod-base-addr (:pointer byte))
  (mod-base-size dword)
  (hmodule hmodule)
  (module wchar :count 256)
  (exe-file wchar :count 260))

(defwin32struct reason-context_detailed-struct
  (localized-reason-module hmodule)
  (localized-reason-id ulong)
  (reason-string-count ulong)
  (reason-string lpwstr))

(defwin32union reason-context_reason-union
  (detailed reason-context_detailed-struct)
  (simple-reason-string lpwstr))

(defwin32struct reason-context
  (version ulong)
  (flags dword)
  (reason reason-context_reason-union))

(defwin32struct threadentry32
  (size dword)
  (count-usage dword)
  (thread-id dword)
  (owner-process-id dword)
  (base-pri long)
  (delta-pri long)
  (flags dword))

(defwin32fun ("AbortPath" abort-path gdi32) bool
  (hdc hdc))

(defwin32fun ("ActivateKeyboardLayout" activate-keyboard-layout user32) hkl
  (hkl hkl)
  (flags uint))

(defwin32fun ("AddClipboardFormatListener" add-clipboard-format-listener user32) bool
  (hwnd hwnd))

(defwin32fun ("AddDllDirectory" add-dll-directory kernel32) dll-directory-cookie
  (new-directory pcwstr))

(defwin32fun ("AddFontMemResourceEx" add-font-mem-resource-ex gdi32) handle
  (file-view (:pointer :void))
  (size dword)
  (reserved (:pointer :void))
  (num-fonts (:pointer dword)))

(defwin32fun ("AddFontResourceW" add-font-resource gdi32) :int
  (resource-name lpwstr))

(defwin32fun ("AddFontResourceExW" add-font-resource-ex gdi32) :int
  (resource-name lpwstr)
  (fl dword)
  (res (:pointer :void)))

(defwin32fun ("AppendMenuW" append-menu user32) bool
  (hmenu hmenu)
  (flags uint)
  (id-new-item uint-ptr)
  (new-item lpcwstr))

(defwin32fun ("Arc" arc gdi32) bool
  (hdc hdc)
  (x1 :int)
  (y1 :int)
  (x2 :int)
  (y2 :int)
  (x3 :int)
  (y3 :int)
  (x4 :int)
  (y4 :int))

(defwin32fun ("ArcTo" arc-to gdi32) bool
  (hdc hdc)
  (left :int)
  (top :int)
  (right :int)
  (bottom :int)
  (xr1 :int)
  (yr1 :int)
  (xr2 :int)
  (yr2 :int))

(defwin32fun ("Beep" beep kernel32) bool
  (freq dword)
  (duration dword))

(defwin32fun ("BeginPaint" begin-paint user32) hdc
  (hwnd hwnd)
  (paint (:pointer paintstruct)))

(defwin32fun ("BeginPath" begin-path gdi32) bool
  (hdc hdc))

(defwin32fun ("BitBlt" bit-blt gdi32) bool
  (hdc hdc)
  (x :int)
  (y :int)
  (cx :int)
  (cy :int)
  (hdc-src hdc)
  (x1 :int)
  (y1 :int)
  (rop dword))

(defwin32fun ("BlockInput" block-input user32) bool
  (block-it bool))

(defwin32fun ("BroadcastSystemMessageW" broadcast-system-message user32) :long
  (flags dword)
  (recipients (:pointer dword))
  (message uint)
  (wparam wparam)
  (lparam lparam))

(defwin32fun ("CallNamedPipeW" call-named-pipe kernel32) bool
  (named-pipe-name lpcwstr)
  (in-buffer (:pointer :void))
  (in-buffer-size dword)
  (out-buffer (:pointer :void))
  (out-buffer-size dword)
  (bytes-read (:pointer dword))
  (timeout dword))

(defwin32fun ("CallNextHookEx" call-next-hook-ex user32) lresult
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

(defwin32fun ("CancelDC" cancel-dc gdi32) bool
  (hdc hdc))

(defwin32fun ("CancelIo" cancel-io kernel32) bool
  (handle handle))

(defwin32fun ("CancelWaitableTimer" cancel-waitable-timer kernel32) bool
  (handle handle))

(defwin32fun ("ChangeClipboardChain" change-clipboard-chain user32) bool
  (hwnd-remove hwnd)
  (hwnd-new-next hwnd))

(defwin32fun ("CheckMenuItem" check-menu-item user32) dword
  (hmenu hmenu)
  (id-check-item uint)
  (check uint))

(defwin32fun ("ChoosePixelFormat" choose-pixel-format gdi32) :int
  (dc hdc)
  (pixel-format (:pointer pixelformatdescriptor)))

(defwin32fun ("Chord" chord gdi32) bool
  (hdc hdc)
  (x1 :int)
  (y1 :int)
  (x2 :int)
  (y2 :int)
  (x3 :int)
  (y3 :int)
  (x4 :int)
  (y4 :int))

(defwin32fun ("CLSIDFromProgID" clsid-from-prog-id ole32) hresult
  (prog-id lpcolestr)
  (clsid (:pointer clsid)))

(defwin32fun ("CLSIDFromProgIDEx" clsid-from-prog-id-ex ole32) hresult
  (prog-id lpcolestr)
  (clsid (:pointer clsid)))

(defwin32fun ("CLSIDFromString" clsid-from-string ole32) hresult
  (lpsz lpcolestr)
  (clsid (:pointer clsid)))

(defwin32fun ("ClientToScreen" client-to-screen user32) bool
  (hwnd hwnd)
  (point (:pointer point)))

(defwin32fun ("ClipCursor" clip-cursor user32) bool
  (rect (:pointer rect)))

(defwin32fun ("CloseClipboard" close-clipboard user32) bool)

(defwin32fun ("CloseEnhMetaFile" close-enh-meta-file gdi32) henhmetafile
  (hdc hdc))

(defwin32fun ("CloseFigure" close-figure gdi32) bool
  (hdc hdc))

(defwin32fun ("CloseHandle" close-handle kernel32) bool
  (handle handle))

(defwin32fun ("CloseMetaFile" close-meta-file gdi32) hmetafile
  (hdc hdc))

(defwin32fun ("CoAddRefServerProcess" co-add-ref-server-process ole32) ulong)

(defwin32fun ("CoCreateGuid" co-create-guid ole32) hresult
  (pguid (:pointer guid)))

(defwin32fun ("CoCreateInstance" co-create-instance ole32) hresult
  (clsid refclsid)
  (unk-outer lpunknown)
  (cls-context dword)
  (riid refiid)
  (ppv (:pointer :void)))

(defwin32fun ("CoEnableCallCancellation" co-enable-call-cancellation ole32) hresult
  (reserved (:pointer :void)))

(defwin32fun ("CoFileTimeNow" co-file-time-now ole32) hresult
  (lp-file-time (:pointer filetime)))

(defwin32fun ("CoFreeUnusedLibraries" co-free-unused-libraries ole32) :void)

(defwin32fun ("CoFreeUnusedLibrariesEx" co-free-unused-libraries-ex ole32) :void
  (unload-delay dword)
  (reserved dword))

(defwin32fun ("CoGetCallContext" co-get-call-context ole32) hresult
  (riid refiid)
  (pp-interface (:pointer (:pointer :void))))

(defwin32fun ("CoGetCallerTID" co-get-caller-tid ole32) hresult
  (lptid (:pointer dword)))

(defwin32fun ("CoGetClassObject" co-get-class-object ole32) hresult
  (clsid refclsid)
  (context dword)
  (reserved (:pointer :void))
  (riid refiid)
  (ppv (:pointer :void)))

(defwin32fun ("CoGetContextToken" co-get-context-token ole32) hresult
  (token (:pointer ulong-ptr)))

(defwin32fun ("CoGetCurrentLogicalThreadId" co-get-current-logical-thread-id ole32) hresult
  (pguid (:pointer guid)))

(defwin32fun ("CoGetCurrentProcess" co-get-current-process ole32) dword)

(defwin32fun ("CoInitialize" co-initialize ole32) hresult
  (reserved (:pointer :void)))

(defwin32fun ("CoInitializeEx" co-initialize-ex ole32) hresult
  (reserved (:pointer :void))
  (co-init dword))

(defwin32fun ("CoSetCancelObject" co-set-cancel-object ole32) hresult
  (punk (:pointer iunknown)))

(defwin32fun ("CoSuspendClassObjects" co-suspend-class-objects ole32) hresult)

(defwin32fun ("CoSwitchCallContext" co-switch-call-context ole32) hresult
  (new-object (:pointer iunknown))
  (old-object (:pointer (:pointer iunknown))))

(defwin32fun ("CoTaskMemAlloc" co-task-mem-alloc ole32) (:pointer :void)
  (cb size-t))

(defwin32fun ("CoTaskMemFree" co-task-mem-free ole32) :void
  (pv (:pointer :void)))

(defwin32fun ("CoTaskMemRealloc" co-task-mem-realloc ole32) (:pointer :void)
  (pv (:pointer :void))
  (cb size-t))

(defwin32fun ("CoTestCancel" co-test-cancel ole32) hresult)

(defwin32fun ("CoUninitialize" co-uninitialize ole32) :void)

(defwin32fun ("CombineRgn" combine-rgn gdi32) :int
  (dst hrgn)
  (src1 hrgn)
  (src2 hrgn)
  (mode :int))

(defwin32fun ("CombineTransform" combine-transform gdi32) bool
  (xf-out (:pointer xform))
  (xf1 (:pointer xform))
  (xf2 (:pointer xform)))

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

(defwin32fun ("CopyEnhMetaFileW" copy-enh-meta-file gdi32) henhmetafile
  (henh henhmetafile)
  (file-name lpcwstr))

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

(defwin32fun ("CopyMetaFileW" copy-meta-file gdi32) hmetafile
  (hmeta hmetafile)
  (file-name lpcwstr))

(defwin32fun ("CountClipboardFormats" count-clipboard-formats user32) :int)

(defwin32fun ("CreateBitmap" create-bitmap gdi32) hbitmap
  (width :int)
  (height :int)
  (planes uint)
  (bit-count uint)
  (bits (:pointer :void)))

(defwin32fun ("CreateBitmapIndirect" create-bitmap-indirect gdi32) hbitmap
  (pbm (:pointer bitmap)))

(defwin32fun ("CreateBrushIndirect" create-brush-indirect gdi32) hbrush
  (logbrush (:pointer logbrush)))

(defwin32fun ("CreateCompatibleBitmap" create-compatible-bitmap gdi32) hbitmap
  (hdc hdc)
  (cx :int)
  (cy :int))

(defwin32fun ("CreateCompatibleDC" create-compatible-dc gdi32) hdc
  (hdc hdc))

(defwin32fun ("CreateDCW" create-dc gdi32) hdc
  (driver lpcwstr)
  (device lpcwstr)
  (port lpcwstr)
  (pdm (:pointer devmode)))

(defwin32fun ("CreateDesktopW" create-desktop user32) hdesk
  (desktop lpcwstr)
  (device lpcwstr)
  (devmode (:pointer devmode))
  (flags dword)
  (desired-access access-mask)
  (security-attributes (:pointer security-attributes)))

(defwin32fun ("CreateDIBitmap" create-di-bitmap gdi32) hbitmap
  (hdc hdc)
  (header (:pointer bitmapinfoheader))
  (fl-init dword)
  (pj-bits (:pointer :void))
  (pbmi (:pointer bitmapinfo))
  (usage uint))

(defwin32fun ("CreateDIBPatternBrush" create-dib-pattern-brush gdi32) hbrush
  (h hglobal)
  (usage uint))

(defwin32fun ("CreateDIBPatternBrushPt" create-dib-pattern-brush-pt gdi32) hbrush
  (packed-dib (:pointer :void))
  (usage uint))

(defwin32fun ("CreateDIBSection" create-dib-section gdi32) hbitmap
  (hdc hdc)
  (pbmi (:pointer bitmapinfo))
  (usage uint)
  (bits (:pointer (:pointer :void)))
  (section handle)
  (offset dword))

(defwin32fun ("CreateDiscardableBitmap" create-discardable-bitmap gdi32) hbitmap
  (hdc hdc)
  (cx :int)
  (cy :int))

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

(defwin32fun ("CreateFileMappingW" create-file-mapping kernel32) handle
  (file handle)
  (security-attributes (:pointer security-attributes))
  (protect dword)
  (max-size-high dword)
  (max-size-low dword)
  (name lpcwstr))

(defwin32fun ("CreateFileMappingNumaW" create-file-mapping-numa kernel32) handle
  (file handle)
  (security-attributes (:pointer security-attributes))
  (protect dword)
  (max-size-high dword)
  (max-size-low dword)
  (name lpcwstr)
  (nd-preferred dword))

(defwin32fun ("CreateFontW" create-font gdi32) hfont
  (height :int)
  (width :int)
  (escapement :int)
  (orientation :int)
  (weight :int)
  (italic dword)
  (underline dword)
  (strike-out dword)
  (charset dword)
  (out-precision dword)
  (clip-precision dword)
  (quality dword)
  (pitch-and-family dword)
  (face-name lpcwstr))

(defwin32fun ("CreateFontIndirectW" create-font-indirect gdi32) hfont
  (plf (:pointer logfont)))

(defwin32fun ("CreateFontIndirectExW" create-font-indirect-ex gdi32) hfont
  (plf (:pointer logfont)))

(defwin32fun ("CreateHalftonePalette" create-halftone-palette gdi32) hpalette
  (hdc hdc))

(defwin32fun ("CreateHatchBrush" create-hatch-brush gdi32) hbrush
  (hatch :int)
  (color colorref))

(defwin32fun ("CreateIconFromResource" create-icon-from-resource user32) hicon
  (presbits (:pointer byte))
  (dw-res-size dword)
  (ficon bool)
  (dw-ver dword))

(defwin32fun ("CreateIconFromResourceEx" create-icon-from-resource-ex user32) hicon
  (presbits (:pointer byte))
  (dw-res-size dword)
  (ficon bool)
  (dw-ver dword)
  (cx-desired :int)
  (cy-desired :int)
  (flags uint))

(defwin32fun ("CreateIconIndirect" create-icon-indirect user32) hicon
  (piconinfo (:pointer iconinfo)))

(defwin32fun ("CreateMenu" create-menu user32) hmenu)

(defwin32fun ("CreateMutexW" create-mutex kernel32) handle
  (security-attributes (:pointer security-attributes))
  (initial-owner bool)
  (name lpcwstr))

(defwin32fun ("CreateMutexExW" create-mutex-ex kernel32) handle
  (security-attributes (:pointer security-attributes))
  (name lpcwstr)
  (flags dword)
  (desired-access dword))

(defwin32fun ("CreateSystemMenu" create-system-menu user32) hmenu
  (hwnd hwnd)
  (revert bool))

(defwin32fun ("CreateNamedPipeW" create-named-pipe kernel32) handle
  (name lpcwstr)
  (open-mode dword)
  (pipe-mode dword)
  (max-instances dword)
  (out-buffer-size dword)
  (in-buffer-size dword)
  (default-timeout dword)
  (security-attributes (:pointer security-attributes)))

(defwin32fun ("CreatePalette" create-palette gdi32) hpalette
  (log-palette (:pointer logpalette)))

(defwin32fun ("CreatePatternBrush" create-pattern-brush gdi32) hbrush
  (hbm hbitmap))

(defwin32fun ("CreatePen" create-pen gdi32) hpen
  (style :int)
  (width :int)
  (color colorref))

(defwin32fun ("CreatePenIndirect" create-pen-indirect gdi32) hpen
  (pen (:pointer logpen)))

(defwin32fun ("CreatePopupMenu" create-popup-menu user32) hmenu)

(defwin32fun ("CreateProcessW" create-process kernel32) bool
  (application-name lpcwstr)
  (command-line lpwstr)
  (process-attributes (:pointer security-attributes))
  (thread-attributes (:pointer security-attributes))
  (inherit-handles bool)
  (creation-flags dword)
  (environment (:pointer :void))
  (current-directory lpcwstr)
  (startupinfo (:pointer startupinfo))
  (process-information (:pointer process-information)))

(defwin32fun ("CreateProcessAsUserW" create-process-as-user advapi32) bool
  (token handle)
  (application-name lpcwstr)
  (command-line lpwstr)
  (process-attributes (:pointer security-attributes))
  (thread-attributes (:pointer security-attributes))
  (inherit-handles bool)
  (creation-flags dword)
  (environment (:pointer :void))
  (current-directory lpcwstr)
  (startupinfo (:pointer startupinfo))
  (process-information (:pointer process-information)))

(defwin32fun ("CreateProcessWithLogonW" create-process-with-logon advapi32) bool
  (user-name lpcwstr)
  (domain lpcwstr)
  (password lpcwstr)
  (logon-flags dword)
  (application-name lpcwstr)
  (command-line lpwstr)
  (creation-flags dword)
  (environment (:pointer :void))
  (current-directory lpcwstr)
  (startupinfo (:pointer startupinfo))
  (process-information (:pointer process-information)))

(defwin32fun ("CreateProcessWithTokenW" create-process-with-token advapi32) bool
  (token handle)
  (logon-flags dword)
  (application-name lpcwstr)
  (command-line lpwstr)
  (creation-flags dword)
  (environment (:pointer :void))
  (current-directory lpcwstr)
  (startupinfo (:pointer startupinfo))
  (process-information (:pointer process-information)))

(defwin32fun ("CreateRemoteThread" create-remote-thread kernel32) handle
  (process handle)
  (thread-attributes (:pointer security-attributes))
  (stack-size size-t)
  (start-address :pointer)
  (parameter (:pointer :void))
  (creation-flags dword)
  (thread-id (:pointer dword)))

(defwin32fun ("CreateSemaphoreW" create-semaphore kernel32) handle
  (semaphore-attributes (:pointer security-attributes))
  (initial-count long)
  (maximum-count long)
  (name lpcwstr))

(defwin32fun ("CreateScalableFontResourceW" create-scalable-font-resource gdi32) bool
  (hidden dword)
  (font lpcwstr)
  (file lpcwstr)
  (path lpcwstr))

(defwin32fun ("CreateSolidBrush" create-solid-brush gdi32) hbrush
  (color colorref))

(defwin32fun ("CreateThread" create-thread kernel32) handle
  (security-attributes (:pointer security-attributes))
  (stack-size size-t)
  (start-address :pointer)
  (parameter (:pointer :void))
  (creation-flags dword)
  (thread-id (:pointer dword)))

(defwin32fun ("CreateToolhelp32Snapshot" create-tool-help-32-snapshot kernel32) handle
  (flags dword)
  (process-id dword))

(defwin32fun ("CreateWaitableTimerW" create-waitable-timer kernel32) handle
  (security-attributes (:pointer security-attributes))
  (manual-reset bool)
  (timer-name lpcwstr))

(defwin32fun ("CreateWaitableTimerExW" create-waitable-timer-ex kernel32) handle
  (security-attributes (:pointer security-attributes))
  (timer-name lpcwstr)
  (flags dword)
  (desired-access dword))

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

(defwin32fun ("DeleteDC" delete-dc gdi32) bool
  (hdc hdc))

(defwin32fun ("DeleteMenu" delete-menu user32) bool
  (hmenu hmenu)
  (position uint)
  (flags uint))

(defwin32fun ("DeleteObject" delete-object gdi32) bool
  (object hgdiobj))

(defwin32fun ("DescribePixelFormat" describe-pixel-format user32) :int
  (dc hdc)
  (pixel-format :int)
  (bytes uint)
  (pfd (:pointer pixelformatdescriptor)))

(defwin32fun ("DestroyCursor" destroy-cursor user32) bool
  (cursor hcursor))

(defwin32fun ("DestroyIcon" destroy-icon user32) bool
  (icon hicon))

(defwin32fun ("DestroyMenu" destroy-menu user32) bool
  (menu hmenu))

(defwin32fun ("DestroyWindow" destroy-window user32) bool
  (hwnd hwnd))

(defwin32fun ("DisableThreadLibraryCalls" disable-thread-library-calls kernel32) bool
  (lib-module hmodule))

(defwin32fun ("DisconnectNamedPipe" disconnect-named-pipe kernel32) bool
  (hnamed-pipe handle))

(defwin32fun ("DispatchMessageW" dispatch-message user32) lresult
  (msg (:pointer msg)))

(defwin32fun ("DosDateTimeToFileTime" dos-date-time-to-file-time kernel32) bool
  (fat-date word)
  (fat-time word)
  (file-time (:pointer filetime)))

(defwin32fun ("DrawEscape" draw-escape gdi32) :int
  (hdc hdc)
  (escape :int)
  (cjin :int)
  (lpin lpcstr))

(defwin32fun ("Ellipse" ellipse gdi32) bool
  (hdc hdc)
  (left :int)
  (top :int)
  (right :int)
  (bottom :int))

(defwin32fun ("EmptyClipboard" empty-clipboard user32) bool)

(defwin32fun ("EnableMenuItem" enable-menu-item user32) bool
  (hmenu hmenu)
  (id-enable-item uint)
  (enable uint))

(defwin32fun ("EnableWindow" enable-window user32) bool
  (hwnd hwnd)
  (enable bool))

(defwin32fun ("EndPaint" end-paint user32) bool
  (hwnd hwnd)
  (paint (:pointer paintstruct)))

(defwin32fun ("EndPath" end-path gdi32) bool
  (hdc hdc))

(defwin32fun ("EnumChildWindows" enum-child-windows user32) bool
  (parent hwnd)
  (enum-func :pointer)
  (lparam lparam))

(defwin32fun ("EnumClipboardFormats" enum-clipboard-formats user32) uint
  (format uint))

(defwin32fun ("EnumDynamicTimeZoneInformation" enum-dynamic-time-zone-information kernel32) dword
  (index dword)
  (time-zone-information (:pointer dynamic-time-zone-information)))

(defwin32fun ("EnumEnhMetaFile" enum-enh-meta-file gdi32) bool
  (hdc hdc)
  (hmf henhmetafile)
  (proc :pointer)
  (param (:pointer :void))
  (rect (:pointer rect)))

(defwin32fun ("EnumFontFamiliesW" enum-font-families gdi32) :int
  (hdc hdc)
  (logfont (:pointer logfont))
  (proc :pointer)
  (lparam lparam))

(defwin32fun ("EnumFontFamiliesExW" enum-font-families-ex gdi32) :int
  (hdc hdc)
  (logfont (:pointer logfont))
  (proc :pointer)
  (lparam lparam)
  (flags dword))

(defwin32fun ("EnumFontsW" enum-fonts gdi32) :int
  (hdc hdc)
  (face-name lpwstr)
  (proc :pointer)
  (lparam lparam))

(defwin32fun ("EnumProcesses" enum-processes psapi) bool
  (lpid-process (:pointer dword))
  (cb dword)
  (cb-needed (:pointer dwordlong)))

(defwin32fun ("EnumWindows" enum-windows user32) bool
  (callback :pointer)
  (lparam lparam))

(defwin32fun ("ExtCreatePen" ext-create-pen gdi32) hpen
  (pen-style dword)
  (width dword)
  (brush (:pointer logbrush)))

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

(defwin32fun ("FindStringOrdinal" find-string-ordinal kernel32) :int
  (find-string-ordinal-flags dword)
  (string-source lpcwstr)
  (ch-source :int)
  (string-value lpcwstr)
  (ch-value :int)
  (ignore-case bool))

(defwin32fun ("FindWindowW" find-window user32) hwnd
  (wndclass-name lpcwstr)
  (window-name lpcwstr))

(defwin32fun ("FindWindowExW" find-window-ex user32) hwnd
  (hwnd-parent hwnd)
  (hwnd-child-after hwnd)
  (class lpcwstr)
  (window lpcwstr))

(defwin32fun ("FlashWindow" flash-window user32) bool
  (hwnd hwnd)
  (invert bool))

(defwin32fun ("FlashWindowEx" flash-window-ex user32) bool
  (pfwi (:pointer flashwindowinfo)))

(defwin32fun ("FlushFileBuffers" flush-file-buffers kernel32) bool
  (hfile handle))

(defwin32fun ("FlushInstructionCache" flush-instruction-cache kernel32) bool
  (process handle)
  (base-address (:pointer :void))
  (size size-t))

(defwin32fun ("FlushViewOfFile" flush-view-of-file kernel32) bool
  (base-address (:pointer :void))
  (number-of-bytes-to-flush size-t))

(defwin32fun ("FormatMessageW" format-message kernel32) dword
  (flags dword)
  (source (:pointer :void))
  (message-id dword)
  (language-id dword)
  (buffer lpwstr)
  (size dword)
  (arguments :pointer))

(defwin32fun ("FreeLibrary" free-library kernel32) bool
  (lib-module hmodule))

(defwin32fun ("FreeLibraryAndExitThread" free-library-and-exit-thread kernel32) :void
  (lib-module hmodule)
  (exit-code dword))

(defwin32fun ("GetACP" get-acp kernel32) uint)

(defwin32fun ("GetActiveWindow" get-active-window user32) hwnd)

(defwin32fun ("GetAncestor" get-ancestor user32) hwnd
  (hwnd hwnd)
  (ga-flags uint))

(defwin32fun ("GetAsyncKeyState" get-async-key-state user32) short
  (virt-key :int))

(defwin32fun ("GetBkColor" get-bk-color gdi32) colorref
  (hdc hdc))

(defwin32fun ("GetBkMode" get-bk-mode gdi32) :int
  (hdc hdc))

(defwin32fun ("GetCapture" get-capture user32) hwnd)

(defwin32fun ("GetCaretBlinkTime" get-caret-blink-time user32) uint)

(defwin32fun ("GetCaretPos" get-caret-pos user32) bool
  (point (:pointer point)))

(defwin32fun ("GetClassLongW" get-class-long user32) dword
  (hwnd hwnd)
  (index :int))

#+32-bit
(defwin32fun ("GetClassLongW" get-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int))

#+64-bit
(defwin32fun ("GetClassLongPtrW" get-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int))

(defwin32fun ("GetClassWord" get-class-word user32) word
  (hwnd hwnd)
  (index :int))

(defwin32fun ("GetClientRect" get-client-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32fun ("GetClipboardData" get-clipboard-data user32) handle
  (format uint))

(defwin32fun ("GetClipboardFormatNameW" get-clipboard-format-name user32) :int
  (format uint)
  (format-name lpwstr)
  (ch-max-count :int))

(defwin32fun ("GetClipboardOwner" get-clipboard-owner user32) hwnd)

(defwin32fun ("GetClipboardSequenceNumber" get-clipboard-sequence-number user32) dword)

(defwin32fun ("GetClipboardViewer" get-clipboard-viewer user32) hwnd)

(defwin32fun ("GetCommState" get-comm-state kernel32) bool
  (hfile handle)
  (lpdcb (:pointer dcb)))

(defwin32fun ("GetCommandLineW" get-command-line kernel32) lptstr)

(defwin32fun ("GetCompressedFileSizeW" get-compressed-file-size kernel32) dword
  (file-name lpcwstr)
  (file-size-high (:pointer dword)))

(defwin32fun ("GetComputerNameW" get-computer-name kernel32) bool
  (lp-buffer lpwstr)
  (n-size (:pointer dword)))

(defwin32fun ("GetCurrentDirectoryW" get-current-directory kernel32) dword
  (n-buffer-length dword)
  (lp-buffer lpwstr))

(defwin32fun ("GetCurrentProcess" get-current-process kernel32) handle)

(defwin32fun ("GetCurrentProcessId" get-current-process-id kernel32) dword)

(defwin32fun ("GetCurrentProcessorNumber" get-current-processor-number kernel32) dword)

(defwin32fun ("GetCurrentProcessorNumberEx" get-current-processor-number-ex kernel32) :void
  (processor-number (:pointer processor-number)))

(defwin32fun ("GetCurrentThreadId" get-current-thread-id kernel32) dword)

(defwin32fun ("GetCursorPos" get-cursor-pos user32) bool
  (point (:pointer point)))

(defwin32fun ("GetDC" get-dc user32) hdc
  (hwnd hwnd))

(defwin32fun ("GetDCEx" get-dc-ex user32) hdc
  (hwnd hwnd)
  (clip hrgn)
  (flags dword))

(defwin32fun ("GetDesktopWindow" get-desktop-window user32) hwnd)

(defwin32fun ("GetDeviceCaps" get-device-caps gdi32) :int
  (hdc hdc)
  (index :int))

(defwin32fun ("GetDIBits" get-di-bits gdi32) :int
  (hdc hdc)
  (hbm hbitmap)
  (start uint)
  (clines uint)
  (lpv-bits (:pointer :void))
  (lpbmi (:pointer bitmapinfo))
  (usage uint))

(defwin32fun ("GetDoubleClickTime" get-double-click-time user32) uint)

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

(defwin32fun ("GetFileSize" get-file-size kernel32) dword
  (file handle)
  (file-size-high (:pointer dword)))

(defwin32fun ("GetFileSizeEx" get-file-size-ex kernel32) bool
  (file handle)
  (file-size-high (:pointer large-integer)))

(defwin32fun ("GetFileVersionInfoW" get-file-version-info version) bool
  (str-file-name lpctstr)
  (handle dword)
  (len dword)
  (data :pointer))

(defwin32fun ("GetFileVersionInfoExW" get-file-version-info-ex version) bool
  (flags dword)
  (str-file-name lpctstr)
  (handle dword)
  (len dword)
  (data :pointer))

(defwin32fun ("GetFileVersionInfoSizeW" get-file-version-info-size version) dword
  (str-file-name lpctstr)
  (handle (:pointer dword)))

(defwin32fun ("GetFileVersionInfoSizeExW" get-file-version-info-size-ex version) dword
  (flags dword)
  (str-file-name lpctstr)
  (handle (:pointer dword)))

(defwin32fun ("GetFocus" get-focus user32) hwnd)

(defwin32fun ("GetInputState" get-input-state user32) bool)

(defwin32fun ("GetKBCodePage" get-kb-code-page user32) uint)

(defwin32fun ("GetKeyboardLayoutNameW" get-keyboard-layout-name user32) bool
  (buffer lpwstr))

(defwin32fun ("GetKeyboardState" get-keyboard-state user32) bool
  (key-state (:pointer byte)))

(defwin32fun ("GetKeyboardType" get-keyboard-type user32) :int
  (type-flag :int))

(defwin32fun ("GetKeyNameTextW" get-key-name-text user32) :int
  (lparam long)
  (buffer lpwstr)
  (buffer-size :int))

(defwin32fun ("GetKeyState" get-key-state user32) short
  (virt-key :int))

(defwin32fun ("GetLastActivePopup" get-last-active-popup user32) hwnd
  (hwnd hwnd))

(defwin32fun ("GetLastError" get-last-error user32) dword)

(defwin32fun ("GetLastInputInfo" get-last-input-info user32) bool
  (last-input (:pointer last-input-info)))

(defwin32fun ("GetLocalTime" get-local-time kernel32) :void
  (system-time (:pointer systemtime)))

(defwin32fun ("GetLogicalDriveStringsW" get-logical-drive-strings kernel32) dword
  (n-buffer-length dword)
  (lp-buffer lpwstr))

(defwin32fun ("GetMappedFiledNameW" get-mapped-file-name psapi) dword
  (process handle)
  (lpv (:pointer :void))
  (file-name lpwstr)
  (size dword))

(defwin32fun ("GetMenuItemCount" get-menu-item-count user32) :int
  (hmenu hmenu))

(defwin32fun ("GetMenuItemID" get-menu-item-id user32) uint
  (hmenu hmenu)
  (pos :int))

(defwin32fun ("GetMenuItemInfoW" get-menu-item-info user32) bool
  (hmenu hmenu)
  (item uint)
  (by-position bool)
  (lpmii (:pointer menuiteminfo)))

(defwin32fun ("GetMenuState" get-menu-state user32) uint
  (hmenu hmenu)
  (uid uint)
  (uflags uint))

(defwin32fun ("GetMenuStringW" get-menu-string user32) :int
  (hmenu hmenu)
  (uid-item uint)
  (lp-string lpwstr)
  (c-ch-max :int)
  (flags uint))

(defwin32fun ("GetMessageW" get-message user32) :int
  (msg (:pointer msg))
  (hwnd hwnd)
  (msg-filter-min uint)
  (msg-filter-max uint))

(defwin32fun ("GetMessageExtraInfo" get-message-extra-info user32) lparam)

(defwin32fun ("GetMessagePos" get-message-pos user32) dword)

(defwin32fun ("GetMessageTime" get-message-time user32) long)

(defwin32fun ("GetModuleFileNameW" get-module-file-name kernel32) dword
  (module hmodule)
  (buffer lptstr)
  (size dword))

(defwin32fun ("GetModuleFileNameExW" get-module-file-name-ex kernel32) dword
  (process handle)
  (module hmodule)
  (buffer lptstr)
  (size dword))

(defwin32fun ("GetModuleHandleW" get-module-handle kernel32) hmodule
  (module lpcwstr))

(defwin32fun ("GetModuleHandleExW" get-module-handle-ex kernel32) bool
  (flags dword)
  (module-name lpctstr)
  (module (:pointer hmodule)))

(defwin32fun ("GetMouseMovePointsEx" get-mouse-move-points-ex user32) :int
  (size uint)
  (ppt (:pointer mouse-move-point))
  (buffer (:pointer mouse-move-point))
  (buf-points :int)
  (resolution dword))

(defwin32fun ("GetNamedPipeClientComputerNameW" get-named-pipe-client-computer-name kernel32) bool
  (pipe handle)
  (client-computer-name lpwstr)
  (client-computer-name-length ulong))

(defwin32fun ("GetNamedPipeClientProcessId" get-named-pipe-client-process-id kernel32) bool
  (pipe handle)
  (client-process-id (:pointer ulong)))

(defwin32fun ("GetNamedPipeClientSessionId" get-named-pipe-client-session-id kernel32) bool
  (pipe handle)
  (client-session-id (:pointer ulong)))

(defwin32fun ("GetNamedPipeHandleStateW" get-named-pipe-handle-state kernel32) bool
  (named-pipe handle)
  (state (:pointer dword))
  (cur-instances (:pointer dword))
  (max-collection-count (:pointer dword))
  (collect-data-timeout (:pointer dword))
  (user-name lpwstr)
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

(defwin32fun ("GetNativeSystemInfo" get-native-system-info kernel32) :void
  (system-info (:pointer system-info)))

(defwin32fun ("GetObjectW" get-object gdi32) :int
  (h handle)
  (c :int)
  (pv (:pointer :void)))

(defwin32fun ("GetOpenClipboardWindow" get-open-clipboard-window user32) hwnd)

(defwin32fun ("GetOpenFileNameW" get-open-file-name comdlg32) bool
  (arg (:pointer openfilename)))

(defwin32fun ("GetOverlappedResult" get-overlapped-result kernel32) bool
  (file handle)
  (overlapped (:pointer overlapped))
  (bytes-transfered (:pointer dword))
  (wait bool))

(defwin32fun ("GetParent" get-parent user32) hwnd
  (hwnd :pointer))

(defwin32fun ("GetPhysicalCursorPos" get-physical-cursor-pos user32) bool
  (point (:pointer point)))

(defwin32fun ("GetPixelFormat" get-pixel-format gdi32) :int
  (dc hdc))

(defwin32fun ("GetPriorityClass" get-priority-class kernel32) dword
  (process handle))

(defwin32fun ("GetPriorityClipboardFormat" get-priority-clipboard-format user32) :int
  (format-priority-list (:pointer uint))
  (formats :int))

(defwin32fun ("GetProcAddress" get-proc-address kernel32) far-proc
  (module hmodule)
  (proc-name lpcstr))

(defwin32fun ("GetProcessImageFileNameW" get-process-image-file-name psapi) dword
  (hprocess handle)
  (lpimage-file-name lpwstr)
  (nsize dword))

(defwin32-lispfun get-proc-address* (module ordinal)
  (declare (type (unsigned-byte 16) ordinal))
  (get-proc-address module (cffi:make-pointer ordinal)))

(defwin32-lispfun get-b-value (rgb)
  (ldb (cl:byte 8 16) rgb))

(defwin32-lispfun get-g-value (rgb)
  (ldb (cl:byte 8 8) rgb))

(defwin32-lispfun get-r-value (rgb)
  (ldb (cl:byte 8 0) rgb))

(defwin32fun ("GetSaveFileNameW" get-save-file-name comdlg32) bool
  (arg (:pointer openfilename)))

(defwin32fun ("GetShellWindow" get-shell-window user32) hwnd)

(defwin32fun ("GetStartupInfoW" get-startup-info kernel32) :void
  (startupinfo (:pointer startupinfo)))

(defwin32fun ("GetStockObject" get-stock-object gdi32) hgdiobj
  (object :int))

(defwin32fun ("GetSubMenu" get-sub-menu user32) hmenu
  (hmenu hmenu)
  (pos :int))

(defwin32fun ("GetQueueStatus" get-queue-status user32) dword
  (flags uint))

(defwin32fun ("GetSysColor" get-sys-color user32) :uint32
  (index :int))

(defwin32fun ("GetSysColorBrush" get-sys-color-brush user32) hbrush
  (index :int))

(defwin32fun ("GetSystemInfo" get-system-info kernel32) :void
  (system-info (:pointer system-info)))

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

(defwin32fun ("GetSystemWow64DirectoryW" get-system-wow-64-directory kernel32) uint
  (buffer lpwstr)
  (size uint))

(defwin32fun ("GetThreadId" get-thread-id kernel32) dword
  (thread handle))

(defwin32fun ("GetThreadLocale" get-thread-locale kernel32) lcid)

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

(defwin32fun ("GetUpdatedClipboardFormats" get-updated-clipboard-formats user32) bool
  (formats (:pointer uint))
  (count-formats uint)
  (count-formats-out (:pointer uint)))

(defwin32fun ("GetUserNameW" get-user-name advapi32) bool
  (lp-buffer lpwstr)
  (pcb-buffer (:pointer dword)))

(defwin32fun ("GetForegroundWindow" get-foreground-window user32) hwnd
  (hwnd hwnd)
  (cmd uint))

(defwin32fun ("SetForegroundWindow" set-foreground-window user32) bool
  (hwnd hwnd))

(defwin32fun ("GetWindow" get-window user32) hwnd
  (hwnd hwnd)
  (cmd uint))

(defwin32fun ("GetWindowDC" get-window-dc user32) hdc
  (hwnd hwnd))

(defwin32fun ("GetWindowLongW" get-window-long user32) long
  (hwnd hwnd)
  (index :int))

#+32-bit
(defwin32fun ("GetWindowLongPtrW" get-window-long-ptr user32) long-ptr
  (hwnd hwnd)
  (index :int))

#+64-bit
(defwin32fun ("GetWindowLongW" get-window-long-ptr user32) long-ptr
  (hwnd hwnd)
  (index :int))

(defwin32fun ("GetWindowRect" get-window-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32fun ("GetWindowTextW" get-window-text user32) :int
  (hwnd hwnd)
  (string lptstr)
  (max-count :int))

(defwin32fun ("GetWindowTextLengthW" get-window-text-length user32) :int
  (hwnd hwnd))

(defwin32fun ("GetWindowThreadProcessId" get-window-thread-process-id user32) dword
  (hwnd hwnd)
  (process-id (:pointer dword)))

(defwin32fun ("GlobalAlloc" global-alloc kernel32) hglobal
  (flags uint)
  (size size-t))

(defwin32-lispfun global-discard (h)
  (global-re-alloc h 0 +gmem-moveable+))

(defwin32fun ("GlobalFlags" global-flags kernel32) uint
  (mem hglobal))

(defwin32fun ("GlobalFree" global-free kernel32) hglobal
  (mem hglobal))

(defwin32fun ("GlobalHandle" global-handle kernel32) hglobal
  (mem (:pointer :void)))

(defwin32fun ("GlobalLock" global-lock kernel32) (:pointer :void)
  (mem hglobal))

(defwin32fun ("GlobalMemoryStatus" global-memory-status kernel32) :void
  (lp-buffer (:pointer memory-status)))

(defwin32fun ("GlobalMemoryStatusEx" global-memory-status-ex kernel32) bool
  (lp-buffer (:pointer memory-status-ex)))

(defwin32fun ("GlobalReAlloc" global-re-alloc kernel32) hglobal
  (mem hglobal)
  (size size-t)
  (flags uint))

(defwin32fun ("GlobalSize" global-size kernel32) size-t
  (mem hglobal))

(defwin32fun ("GlobalUnlock" global-unlock kernel32) bool
  (mem hglobal))

(defwin32-lispfun hiword (dword)
  (ldb (cl:byte 16 16) dword))

(defwin32fun ("IIDFromString" iid-from-string ole32) hresult
  (lpsz lpcolestr)
  (lpiid (:pointer iid)))

(defwin32fun ("ImpersonateNamedPipeClient" impersonate-named-pipe-client advapi32) bool
  (named-pipe handle))

(defwin32fun ("InSendMessage" in-send-message user32) bool)

(defwin32fun ("InSendMessageEx" in-send-message-ex user32) dword
  (reserved :pointer))

(defwin32fun ("InsertMenuW" insert-menu user32) bool
  (hmenu hmenu)
  (position uint)
  (flags uint)
  (id-new-item uint-ptr)
  (new-item lpcwstr))

(defwin32fun ("InvalidateRect" invalidate-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect))
  (erase bool))

(defwin32fun ("IsClipboardFormatAvailable" is-clipboard-format-available user32) bool
  (format uint))

(defwin32fun ("IsDialogMessageW" is-dialog-message user32) bool
  (hdlg hwnd)
  (lpmsg (:pointer msg)))

(defwin32fun ("IsEqualGUID" is-equal-guid ole32) bool
  (rguid1 refguid)
  (rguid2 refguid))

(defwin32-lispfun is-equal-clsid (rclsid1 rclsid2)
  (is-equal-guid rclsid1 rclsid2))

(defwin32-lispfun is-equal-iid (riid1 riid2)
  (is-equal-guid riid1 riid2))

(defwin32-lispfun is-intresource (r)
  (zerop (ash r -16)))

(defwin32fun ("IsGUIThread" is-gui-thread user32) bool
  (convert bool))

(defwin32fun ("IsIconic" is-iconic user32) bool
  (hwnd hwnd))

(defwin32fun ("IsWindow" is-window user32) bool
  (hwnd hwnd))

(defwin32fun ("IsWindowEnabled" is-window-enabled user32) bool
  (hwnd hwnd))

(defwin32fun ("IsWindowVisible" is-window-visible user32) bool
  (hwnd hwnd))

(defwin32-lispfun is-windows-version-or-greater (major minor service-pack)
  (declare (type (unsigned-byte 16) major minor service-pack))
  (cffi:with-foreign-object (osvi 'os-version-info-ex)
    (cffi:with-foreign-slots ((os-version-info-size
                               major-version minor-version service-pack-major)
                              osvi
                              os-version-info-ex)
      (setf os-version-info-size (cffi:foreign-type-size 'os-version-info-ex)
            major-version major
            minor-version minor
            service-pack-major service-pack))

    (verify-version-info osvi
                         (logior +ver-majorversion+ +ver-minorversion+ +ver-servicepackmajor+)
                         (ver-set-condition-mask
                          (ver-set-condition-mask
                           (ver-set-condition-mask 0 +ver-majorversion+ +ver-greater-equal+)
                           +ver-minorversion+ +ver-greater-equal+)
                          +ver-servicepackmajor+ +ver-greater-equal+))))

(defwin32-lispfun is-windows-xp-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-winxp+) (ldb (cl:byte 8 0) +-win32-winnt-winxp+) 0))

(defwin32-lispfun is-windows-xp-sp1-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-winxp+) (ldb (cl:byte 8 0) +-win32-winnt-winxp+) 1))

(defwin32-lispfun is-windows-xp-sp2-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-winxp+) (ldb (cl:byte 8 0) +-win32-winnt-winxp+) 2))

(defwin32-lispfun is-windows-xp-sp3-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-winxp+) (ldb (cl:byte 8 0) +-win32-winnt-winxp+) 3))

(defwin32-lispfun is-windows-vista-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-vista+) (ldb (cl:byte 8 0) +-win32-winnt-vista+) 0))

(defwin32-lispfun is-windows-vista-sp1-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-vista+) (ldb (cl:byte 8 0) +-win32-winnt-vista+) 1))

(defwin32-lispfun is-windows-vista-sp2-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-vista+) (ldb (cl:byte 8 0) +-win32-winnt-vista+) 2))

(defwin32-lispfun is-windows-7-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-win7+) (ldb (cl:byte 8 0) +-win32-winnt-win7+) 0))

(defwin32-lispfun is-windows-7-sp1-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-win7+) (ldb (cl:byte 8 0) +-win32-winnt-win7+) 1))

(defwin32-lispfun is-windows-8-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-win8+) (ldb (cl:byte 8 0) +-win32-winnt-win8+) 0))

(defwin32-lispfun is-windows-8-point1-or-greater ()
  (is-windows-version-or-greater
   (ldb (cl:byte 8 8) +-win32-winnt-winblue+) (ldb (cl:byte 8 0) +-win32-winnt-winblue+) 0))

(defwin32-lispfun is-windows-server ()
  (cffi:with-foreign-object (osvi 'os-version-info-ex)
    (cffi:with-foreign-slots ((os-version-info-size
                               product-type)
                              osvi
                              os-version-info-ex)
      (setf os-version-info-size (cffi:foreign-type-size 'os-version-info-ex)
            product-type +ver-nt-workstation+))
    (verify-version-info osvi
                         +ver-product-type+
                         +ver-equal+)))

(defwin32fun ("IsWow64Process" is-wow-64-process kernel32) bool
  (process handle)
  (wow-64-process (:pointer bool)))

(defwin32fun ("KillTimer" kill-timer user32) bool
  (hwnd hwnd)
  (u-id-event uint-ptr))

(defwin32fun ("LineTo" line-to gdi32) bool
  (hdc hdc)
  (x :int)
  (y :int))

(defwin32fun ("LoadCursorW" load-cursor user32) hcursor
  (instance hinstance)
  (name lpctstr))

(defwin32fun ("LoadCursorFromFileW" load-cursor-from-file user32) hcursor
  (file-name lpctstr))

(defwin32fun ("LoadImageW" load-image user32) handle
  (hinst hinstance)
  (name lpwstr)
  (type uint)
  (cx :int)
  (cy :int)
  (fu-load uint))

(defwin32fun ("LoadIconW" load-icon user32) hicon
  (instance hinstance)
  (name lpctstr))

(defwin32fun ("LoadKeyboardLayoutW" load-keyboard-layout user32) hkl
  (id lpcstr)
  (flags uint))

(defwin32fun ("LoadRegTypeLib" load-reg-type-lib oleaut32) hresult
  (guid refguid)
  (ver-major word)
  (ver-minor word)
  (lcid lcid)
  (lib (:pointer (:pointer itypelib))))

(defwin32fun ("LoadTypeLib" load-type-lib oleaut32) hresult
  (file lpcolestr)
  (lib (:pointer (:pointer itypelib))))

(defwin32fun ("LoadTypeLibEx" load-type-lib-ex oleaut32) hresult
  (file lpcolestr)
  (regkind :int)
  (lib (:pointer (:pointer itypelib))))

(defwin32fun ("LocalAlloc" local-alloc kernel32) hlocal
  (flags uint)
  (bytes size-t))

(defwin32-lispfun local-discard (h)
  (local-re-alloc h 0 +lmem-moveable+))

(defwin32fun ("LocalFileTimeToFileTime" local-file-time-to-file-time kernel32) bool
  (local-file-time (:pointer filetime))
  (file-time (:pointer filetime)))

(defwin32fun ("LocalFlags" local-flags kernel32) uint
  (mem hlocal))

(defwin32fun ("LocalFree" local-free kernel32) hlocal
  (hmem hlocal))

(defwin32fun ("LocalHandle" local-handle kernel32) hlocal
  (mem (:pointer :void)))

(defwin32fun ("LocalLock" local-lock kernel32) (:pointer :void)
  (mem hlocal))

(defwin32fun ("LocalReAlloc" local-re-alloc kernel32) hlocal
  (hmem hlocal)
  (bytes size-t)
  (flags uint))

(defwin32fun ("LocalSize" local-size kernel32) size-t
  (mem hlocal))

(defwin32fun ("LocalUnlock" local-unlock kernel32) bool
  (mem hlocal))

(defwin32fun ("LockWorkStation" lock-work-station user32) bool)

(defwin32fun ("LogonUserW" logon-user advapi32) bool
  (user-name lpcwstr)
  (domain lpcwstr)
  (password lpcwstr)
  (logon-type dword)
  (logon-provider dword)
  (token (:pointer handle)))

(defwin32fun ("LogonUserExW" logon-user-ex advapi32) bool
  (user-name lpcwstr)
  (domain lpcwstr)
  (password lpcwstr)
  (logon-type dword)
  (logon-provider dword)
  (token (:pointer handle))
  (sid (:pointer sid))
  (profile-buffer (:pointer :void))
  (profile-length (:pointer dword))
  (quota-limits (:pointer quota-limits)))

(defwin32-lispfun loword (dword)
  (ldb (cl:byte 16 0) dword))

(defwin32-lispfun makeintresource (i)
  (cffi:make-pointer (ldb (cl:byte 16 0) i)))

(defwin32-lispfun make-lang-id (p s)
  (declare (type (unsigned-byte 16) p s))
  (logior (ash s 10) p))

(defwin32-lispfun makerop4 (fore back)
  (logior (logand (ash back 8) #xFF000000) fore))

(defwin32fun ("MapViewOfFile" map-view-of-file kernel32) (:pointer :void)
  (file-mapping-object handle)
  (desired-access dword)
  (file-offset-high dword)
  (file-offset-low dword)
  (number-of-bytes-to-map size-t))

(defwin32fun ("MapViewOfFile2" map-view-of-file-2 kernel32) (:pointer :void)
  (file-mapping-object handle)
  (process-handle handle)
  (offset ulong64)
  (base-address (:pointer :void))
  (view-size size-t)
  (allocation-type ulong)
  (page-protection ulong))

(defwin32fun ("MapViewOfFile3" map-view-of-file-3 kernel32) (:pointer :void)
  (file-mapping-object handle)
  (process-handle handle)
  (offset ulong64)
  (base-address (:pointer :void))
  (view-size size-t)
  (allocation-type ulong)
  (page-protection ulong))

(defwin32fun ("MapViewOfFileEx" map-view-of-file-ex kernel32) (:pointer :void)
  (file-mapping-object handle)
  (desired-access dword)
  (file-offset-high dword)
  (file-offset-low dword)
  (number-of-bytes-to-map size-t)
  (base-address (:pointer :void)))

(defwin32fun ("MapViewOfFileExNuma" map-view-of-file-ex-numa kernel32) (:pointer :void)
  (file-mapping-object handle)
  (desired-access dword)
  (file-offset-high dword)
  (file-offset-low dword)
  (number-of-bytes-to-map size-t)
  (base-address (:pointer :void))
  (nd-preferred dword))

(defwin32fun ("MapViewOfFileNuma2" map-view-of-file-numa-2 kernel32) (:pointer :void)
  (file-mapping-object handle)
  (process-handle handle)
  (offset ulong64)
  (base-address (:pointer :void))
  (view-size size-t)
  (allocation-type ulong)
  (page-protection ulong)
  (preferred-node ulong))

(defwin32fun ("MapVirtualKeyW" map-virtual-key user32) uint
  (code uint)
  (map-type uint))

(defwin32fun ("MapVirtualKeyExW" map-virtual-key-ex user32) uint
  (code uint)
  (map-type uint)
  (layout hkl))

(defwin32fun ("MessageBeep" message-beep user32) bool
  (u-type uint))

(defwin32fun ("MaskBlt" mask-blt gdi32) bool
  (hdc-dest hdc)
  (x-dest :int)
  (y-dest :int)
  (width :int)
  (height :int)
  (hdc-src hdc)
  (x-src :int)
  (y-src :int)
  (mask hbitmap)
  (x-mask :int)
  (y-mask :int)
  (rop dword))

(defwin32fun ("MessageBoxW" message-box user32) :int
  (hwnd hwnd)
  (text lpcwstr)
  (caption lpcwstr)
  (type uint))

(defwin32fun ("MessageBoxExW" message-box-ex user32) :int
  (hwnd hwnd)
  (text lpcwstr)
  (caption lpcwstr)
  (type uint)
  (language-id word))

(defwin32fun ("ModifyMenuW" modify-menu user32) bool
  (hmenu hmenu)
  (position uint)
  (flags uint)
  (id-new-item uint-ptr)
  (new-item lpcwstr))

(defwin32fun ("Module32FirstW" module-32-first kernel32) bool
  (snapshot handle)
  (lpme (:pointer moduleentry32)))

(defwin32fun ("Module32NextW" module-32-next kernel32) bool
  (snapshot handle)
  (lpme (:pointer moduleentry32)))

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

(defwin32fun ("MoveToEx" move-to-ex gdi32) bool
  (hdc hdc)
  (x :int)
  (y :int)
  (prev-point (:pointer point)))

(defwin32fun ("OaBuildVersion" oa-build-version oleaut32) hresult)

(defwin32fun ("OaEnablePerUserTLibRegistration" oa-enable-per-user-tlib-registration oleaut32) :void)

(defwin32fun ("OpenClipboard" open-clipboard user32) bool
  (new-owner hwnd))

(defwin32fun ("OpenEventW" open-event kernel32) handle
  (desired-access dword)
  (inherit-handle bool)
  (name lpctstr))

(defwin32fun ("OpenFileMappingW" open-file-mapping kernel32) handle
  (desired-access dword)
  (inherit-handle bool)
  (name lpcwstr))

(defwin32fun ("OpenInputDesktop" open-input-desktop user32) hdesk
  (flags dword)
  (inherit bool)
  (desired-access access-mask))

(defwin32fun ("OpenProcess" open-process kernel32) handle
  (desired-access dword)
  (inherit-handle bool)
  (process-id dword))

(defwin32fun ("OpenProcessToken" open-process-token advapi32) bool
  (process-handle handle)
  (desired-access dword)
  (handle (:pointer handle)))

(defwin32fun ("OpenThread" open-thread kernel32) handle
  (desired-access dword)
  (inherit-handle bool)
  (thread-id dword))

(defwin32fun ("OpenThreadToken" open-thread-token advapi32) bool
  (thread-handle handle)
  (desired-access dword)
  (open-as-self bool)
  (token-handle (:pointer handle)))

(defwin32-lispfun palettergb (r g b)
  (logior #x02000000 (rgb r g b)))

(defwin32-lispfun paletteindex (i)
  (logior #x01000000 (ldb (cl:byte 16 0) i)))

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

(defwin32fun ("PolyBezier" poly-bezier gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (cpt dword))

(defwin32fun ("PolyBezierTo" poly-bezier-to gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (cpt dword))

(defwin32fun ("Polygon" polygon gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (cpt :int))

(defwin32fun ("Polyline" polyline gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (cpt :int))

(defwin32fun ("PolylineTo" polyline-to gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (cpt dword))

(defwin32fun ("PolyPolygon" poly-polygon gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (asz (:pointer int))
  (csz :int))

(defwin32fun ("PolyPolyline" poly-polyline gdi32) bool
  (hdc hdc)
  (apt (:pointer point))
  (asz (:pointer dword))
  (csz dword))

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

(defwin32-lispfun primary-lang-id (lgid)
  (ldb (cl:byte 10 0) lgid))

(defwin32fun ("Process32FirstW" process-32-first kernel32) bool
  (snapshot handle)
  (lppe (:pointer processentry32)))

(defwin32fun ("Process32NextW" process-32-next kernel32) bool
  (snapshot handle)
  (lppe (:pointer processentry32)))

(defwin32fun ("ProgIDFromCLSID" prog-id-from-clsid ole32) hresult
  (clsid refclsid)
  (lplpsz-prog-id (:pointer lpolestr)))

(defwin32-lispfun sub-lang-id (lgid)
  (ldb (cl:byte 6 10) lgid))

(defwin32fun ("QueryAuxiliaryCounterFrequency" query-auxiliary-counter-frequency kernel32) hresult
  (auxiliary-counter-frequency (:pointer ulonglong)))

(defwin32fun ("QueryInterruptTime" query-interrupt-time kernel32) :void
  (interrupt-time (:pointer ulonglong)))

(defwin32fun ("QueryInterruptTimePrecise" query-interrupt-time-precise kernel32) :void
  (interrupt-time-precise (:pointer ulonglong)))

(defwin32fun ("QueryPathOfRegTypeLib" query-path-of-reg-type-lib oleaut32) hresult
  (guid refguid)
  (ver-major ushort)
  (ver-minor ushort)
  (lcid lcid)
  (path-name lpbstr))

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

(defwin32fun ("ReadProcessMemory" read-process-memory kernel32) bool
  (hprocess handle)
  (base-address (:pointer :void))
  (buffer (:pointer :void))
  (size size-t)
  (number-of-bytes-read (:pointer size-t)))

(defwin32fun ("RealizePalette" realize-palette gdi32) uint
  (dc hdc))

(defwin32fun ("Rectangle" rectangle gdi32) bool
  (hdc hdc)
  (left :int)
  (top :int)
  (right :int)
  (bottom :int))

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

(defwin32fun ("RegisterActiveObject" register-active-object oleaut32) hresult
  (punk (:pointer iunknown))
  (clsid refclsid)
  (flags dword)
  (register (:pointer dword)))

(defwin32fun ("RegisterClassW" register-class user32) atom
  (wndclass (:pointer wndclass)))

(defwin32fun ("RegisterClassExW" register-class-ex user32) atom
  (wndclassex (:pointer wndclassex)))

(defwin32fun ("RegisterClipboardFormatW" register-clipboard-format user32) uint
  (format lpcwstr))

(defwin32fun ("RegisterHotKey" register-hot-key user32) bool
  (hwnd hwnd)
  (id :int)
  (modifiers uint)
  (vk uint))

(defwin32fun ("RegisterTypeLib" register-type-lib oleaut32) hresult
  (lib (:pointer itypelib))
  (full-path lpcolestr)
  (help-dir lpcolestr))

(defwin32fun ("RegisterTypeLibForUser" register-type-lib-for-user oleaut32) hresult
  (lib (:pointer itypelib))
  (full-path lpcolestr)
  (help-dir lpcolestr))

(defwin32fun ("RegisterWindowMessageW" register-window-message user32) uint
  (string lpctstr))

(defwin32fun ("ReleaseCapture" release-capture user32) bool)

(defwin32fun ("ReleaseDC" release-dc user32) :int
  (hwnd hwnd)
  (dc hdc))

(defwin32fun ("RemoveClipboardFormatListener" remove-clipboard-format-listener user32) bool
  (hwnd hwnd))

(defwin32fun ("RemoveDllDirectory" remove-dll-directory kernel32) bool
  (cookie dll-directory-cookie))

(defwin32fun ("RemoveFontMemResourceW" remove-font-mem-resource gdi32) bool
  (h handle))

(defwin32fun ("RemoveFontResourceW" remove-font-resource gdi32) bool
  (file-name lpwstr))

(defwin32fun ("RemoveFontResourceExW" remove-font-resource-ex gdi32) bool
  (name lpwstr)
  (fl dword)
  (pdv (:pointer :void)))

(defwin32fun ("RemoveMenu" remove-menu user32) bool
  (hmenu hmenu)
  (position uint)
  (flags uint))

(defwin32fun ("ReplyMessage" reply-message user32) bool
  (result lresult))

(defwin32fun ("ResetEvent" reset-event kernel32) bool
  (event handle))

(defwin32fun ("ResizePalette" resize-palette gdi32) bool
  (palette hpalette)
  (entries uint))

(defwin32fun ("RevokeActiveObject" revoke-active-object oleaut32) hresult
  (register dword)
  (reserved (:pointer :void)))

(defwin32-lispfun rgb (r g b)
  (logior
   (ash (logand b #xFF) 16)
   (ash (logand g #xFF) 8)
   (ash (logand r #xFF) 0)))

(defwin32fun ("RoundRect" round-rect gdi32) bool
  (hdc hdc)
  (left :int)
  (top :int)
  (right :int)
  (bottom :int)
  (width :int)
  (height :int))

(defwin32fun ("ScreenToClient" screen-to-client user32) bool
  (hwnd hwnd)
  (lp-point (:pointer point)))

(defwin32fun ("SelectObject" select-object gdi32) hgdiobj
  (hdc hdc)
  (obj hgdiobj))

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

(defwin32fun ("SetActiveWindow" set-active-window user32) hwnd
  (hwnd hwnd))

(defwin32fun ("SetBkColor" set-bk-color gdi32) colorref
  (hdc hdc)
  (color colorref))

(defwin32fun ("SetBkMode" set-bk-mode gdi32) :int
  (hdc hdc)
  (mode :int))

(defwin32fun ("SetCapture" set-capture user32) hwnd
  (hwnd hwnd))

(defwin32fun ("SetCaretBlinkTime" set-caret-blink-time user32) bool
  (umseconds uint))

(defwin32fun ("SetCaretPos" set-caret-pos user32) bool
  (x :int)
  (y :int))

(defwin32fun ("SetClassLongW" set-class-long user32) dword
  (hwnd hwnd)
  (index :int)
  (new-long long))

#+32-bit
(defwin32fun ("SetClassLongW" set-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

#+64-bit
(defwin32fun ("SetClassLongPtrW" set-class-long-ptr user32) ulong-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

(defwin32fun ("SetClassWord" set-class-word user32) word
  (hwnd hwnd)
  (index :int)
  (new-word word))

(defwin32fun ("SetClipboardData" set-clipboard-data user32) handle
  (format uint)
  (hmem handle))

(defwin32fun ("SetClipboardViewer" set-clipboard-viewer user32) hwnd
  (new-viewer hwnd))

(defwin32fun ("SetCommMask" set-comm-mask kernel32) bool
  (hfile handle)
  (evt-mask dword))

(defwin32fun ("SetCommState" set-comm-state kernel32) bool
  (hfile handle)
  (lpdcb (:pointer dcb)))

(defwin32fun ("SetCurrentDirectoryW" set-current-directory kernel32) bool
  (lp-path-name lpcwstr))

(defwin32fun ("SetCursor" set-cursor user32) hcursor
  (cursor hcursor))

(defwin32fun ("SetCursorPos" set-cursor-pos user32) bool
  (x :int)
  (y :int))

(defwin32fun ("SetDefaultDllDirectories" set-default-dll-directories kernel32) bool
  (directory-flags dword))

(defwin32fun ("SetDIBits" set-di-bits gdi32) :int
  (hdc hdc)
  (hbm hbitmap)
  (start uint)
  (clines uint)
  (lp-bits (:pointer :void))
  (lp-bmi (:pointer bitmapinfo))
  (color-use uint))

(defwin32fun ("SetDoubleClickTime" set-double-click-time user32) bool
  (arg uint))

(defwin32fun ("SetDynamicTimeZoneInformation" set-dynamic-time-zone-information kernel32) bool
  (time-zone-information (:pointer dynamic-time-zone-information)))

(defwin32fun ("SetEvent" set-event kernel32) bool
  (event handle))

(defwin32fun ("SetFileTime" set-file-time kernel32) bool
  (file handle)
  (creation-time (:pointer filetime))
  (last-access-time (:pointer filetime))
  (last-write-time (:pointer filetime)))

(defwin32fun ("SetFocus" set-focus user32) hwnd
  (hwnd hwnd))

(defwin32fun ("SetLocalTime" set-local-time kernel32) bool
  (system-time (:pointer systemtime)))

(defwin32fun ("SetNamedPipeHandleState" set-named-pipe-handle-state kernel32) bool
  (hnamed-pipe handle)
  (mode (:pointer dword))
  (max-collection-count (:pointer dword))
  (collected-data-timeout (:pointer dword)))

(defwin32fun ("SetPhysicalCursorPos" set-physical-cursor-pos user32) bool
  (x :int)
  (y :int))

(defwin32fun ("SetSystemTime" set-system-time kernel32) bool
  (system-time (:pointer systemtime)))

(defwin32fun ("SetSystemTimeAdjustment" set-system-time-adjustment kernel32) bool
  (time-adjustment dword)
  (time-adjustment-disabled bool))

(defwin32fun ("SetThreadLocale" set-thread-locale kernel32) bool
  (locale lcid))

(defwin32fun ("SetTimer" set-timer user32) uint-ptr
  (hwnd hwnd)
  (n-id-event uint-ptr)
  (u-elapse uint)
  (lp-timer-func (:pointer :void)))

(defwin32fun ("SetTimeZoneInformation" set-time-zone-information kernel32) bool
  (time-zone-information (:pointer time-zone-information)))

(defwin32fun ("SetForegroundWindow" set-foreground-window user32) bool
  (hwnd hwnd))

(defwin32fun ("SetKeyboardState" set-keyboard-state user32) bool
  (key-state (:pointer byte)))

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

(defwin32fun ("SetMenu" set-menu user32) bool
  (hwnd hwnd)
  (hmenu hmenu))

(defwin32fun ("SetMessageExtraInfo" set-message-extra-info user32) lparam
  (lparam lparam))

(defwin32fun ("SetParent" set-parent user32) hwnd
  (hwnd hwnd)
  (new-parent hwnd))

(defwin32fun ("SetPixel" set-pixel gdi32) colorref
  (hdc hdc)
  (x :int)
  (y :int)
  (color colorref))

(defwin32fun ("SetPixelV" set-pixel-v gdi32) bool
  (hdc hdc)
  (x :int)
  (y :int)
  (color colorref))

(defwin32fun ("SetPixelFormat" set-pixel-format user32) bool
  (dc hdc)
  (pixel-format :int)
  (pfd (:pointer pixelformatdescriptor)))

(defwin32fun ("SetSysColors" set-sys-colors user32) bool
  (numelements :int)
  (elements (:pointer :int))
  (rgbas (:pointer colorref)))

(defwin32fun ("SetWaitableTimer" set-waitable-timer kernel32) bool
  (handle handle)
  (due-time (:pointer large-integer))
  (period long)
  (completion-routine :pointer)
  (arg-to-completion-routine :pointer)
  (resume bool))

(defwin32fun ("SetWaitableTimerEx" set-waitable-timer-ex kernel32) bool
  (handle handle)
  (due-time (:pointer large-integer))
  (period long)
  (completion-routine :pointer)
  (arg-to-completion-routine :pointer)
  (wake-context (:pointer reason-context))
  (tolerable-delay ulong))

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

#+32-bit
(defwin32fun ("SetWindowLongPtrW" set-window-long-ptr user32) long-ptr
  (hwnd hwnd)
  (index :int)
  (new-long long-ptr))

#+64-bit
(defwin32fun ("SetWindowLongW" set-window-long-ptr user32) long-ptr
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

(defwin32fun ("Shell_NotifyIconW" shell-notify-icon shell32) bool
  (message dword)
  (data (:pointer notify-icon-data)))

(defwin32fun ("ShowCursor" show-cursor user32) :int
  (show bool))

(defwin32fun ("ShowWindow" show-window user32) bool
  (hwnd hwnd)
  (cmd :int))

(defwin32fun ("Sleep" sleep kernel32) :void
  (dw-milliseconds dword))

(defwin32fun ("SleepEx" sleep-ex kernel32) dword
  (dw-milliseconds dword)
  (alertable bool))

(defwin32fun ("StretchBlt" stretch-blt gdi32) bool
  (hdc-dest hdc)
  (x-dest :int)
  (y-dest :int)
  (w-dest :int)
  (h-dest :int)
  (hdc-src hdc)
  (x-src :int)
  (y-src :int)
  (w-src :int)
  (h-src :int)
  (rop dword))

(defwin32fun ("StringFromCLSID" string-from-clsid ole32) hresult
  (rclsid refclsid)
  (lplpsz (:pointer lpolestr)))

(defwin32fun ("StringFromGUID2" string-from-guid-2 ole32) :int
  (rguid refguid)
  (lpsz lpolestr)
  (chh-max :int))

(defwin32fun ("StringFromIID" string-from-iid ole32) hresult
  (rclsid refiid)
  (lplpsz (:pointer lpolestr)))

(defwin32fun ("SwapBuffers" swap-buffers gdi32) bool
  (dc hdc))

(defwin32fun ("SwapMouseButton" swap-mouse-button user32) bool
  (sweap bool))

(defwin32fun ("SwitchDesktop" switch-desktop user32) bool
  (desktop hdesk))

(defwin32fun ("SysAddRefString" sys-add-ref-string oleaut32) hresult
  (bstr bstr))

(defwin32fun ("SysAllocString" sys-alloc-string oleaut32) bstr
  (psz (:pointer olechar)))

(defwin32fun ("SysAllocStringByteLen" sys-alloc-string-byte-len oleaut32) bstr
  (psz lpcstr)
  (len uint))

(defwin32fun ("SysAllocStringLen" sys-alloc-string-len oleaut32) bstr
  (str (:pointer olechar))
  (char-len uint))

(defwin32fun ("SysFreeString" sys-free-string oleaut32) :void
  (bstr bstr))

(defwin32fun ("SysReAllocString" sys-re-alloc-string oleaut32) int
  (bstr (:pointer bstr))
  (psz (:pointer olechar)))

(defwin32fun ("SysReAllocStringLen" sys-re-alloc-string-len oleaut32) int
  (bstr (:pointer bstr))
  (psz (:pointer olechar))
  (len :uint))

(defwin32fun ("SysReleaseString" sys-release-string oleaut32) :void
  (bstr bstr))

(defwin32fun ("SysStringByteLen" sys-string-byte-len oleaut32) uint
  (bstr bstr))

(defwin32fun ("SysStringLen" sys-string-len oleaut32) uint
  (bstr bstr))

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

(defwin32fun ("TextOutW" text-out gdi32) bool
  (hdc hdc)
  (x :int)
  (y :int)
  (string lpcwstr)
  (c :int))

(defwin32fun ("Thread32First" thread-32-first kernel32) bool
  (snapshot handle)
  (lpte (:pointer threadentry32)))

(defwin32fun ("Thread32Next" thread-32-next kernel32) bool
  (snapshot handle)
  (lpte (:pointer threadentry32)))

(defwin32fun ("ToAscii" to-ascii user32) :int
  (virt-key uint)
  (scan-code uint)
  (key-state (:pointer byte))
  (char (:pointer word))
  (flags uint))

(defwin32fun ("ToAsciiEx" to-ascii-ex user32) :int
  (virt-key uint)
  (scan-code uint)
  (key-state (:pointer byte))
  (char (:pointer word))
  (flags uint)
  (hkl hkl))

(defwin32fun ("ToUnicode" to-unicode user32) :int
  (virt-key uint)
  (scan-code uint)
  (key-state (:pointer byte))
  (buf lpwstr)
  (buf-size :int)
  (flags uint))

(defwin32fun ("ToUnicodeEx" to-unicode-ex user32) :int
  (virt-key uint)
  (scan-code uint)
  (key-state (:pointer byte))
  (buf lpwstr)
  (buf-size :int)
  (flags uint)
  (hkl hkl))

(defwin32fun ("TrackMouseEvent" track-mouse-event user32) bool
  (event-track (:pointer trackmouseevent)))

(defwin32fun ("TrackPopupMenu" track-popup-menu user32) :int
  (hmenu hmenu)
  (flags uint)
  (x :int)
  (y :int)
  (reserved :int)
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32-lispfun track-popup-menu* (hmenu flags x y reserved hwnd rect)
  (not (zerop (track-popup-menu hmenu flags x y reserved hwnd rect))))

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

(defwin32fun ("UnhookWindowsHookEx" unhook-windows-hook-ex user32) bool
  (hhook hhook))

(defwin32fun ("UnloadKeyboardLayout" unload-keyboard-layout user32) bool
  (hkl hkl))

(defwin32fun ("UnmapViewOfFile" unmap-view-of-file kernel32) bool
  (base-address (:pointer :void)))

(defwin32fun ("UnmapViewOfFile2" unmap-view-of-file-2 kernel32) bool
  (process-handle handle)
  (base-address (:pointer :void))
  (unmap-flags ulong))

(defwin32fun ("UnmapViewOfFileEx" unmap-view-of-file-ex kernel32) bool
  (base-address (:pointer :void))
  (unmap-flags ulong))

(defwin32fun ("UnregisterClassW" unregister-class user32) bool
  (wndclass-name lpctstr)
  (instance hinstance))

(defwin32fun ("UnregisterHotKey" unregister-hot-key user32) bool
  (hwnd hwnd)
  (id :int))

(defwin32fun ("UpdateWindow" update-window user32) bool
  (hwnd hwnd))

(defwin32fun ("ValidateRect" validate-rect user32) bool
  (hwnd hwnd)
  (rect (:pointer rect)))

(defwin32fun ("VerFindFileW" ver-find-file version) dword
  (flags dword)
  (file-name lpctstr)
  (win-dir lpctstr)
  (app-dir lpctstr)
  (cur-dir lpwstr)
  (cur-dir-len (:pointer uint))
  (dst-dir lptstr)
  (dest-dir-len (:pointer uint)))

(defwin32fun ("VerInstallFileW" ver-install-file version) dword
  (flags dword)
  (src-file-name lpctstr)
  (dst-file-name lpctstr)
  (src-dir lpctstr)
  (dst-dir lpctstr)
  (cur-dir lpctstr)
  (tmp-file lptstr)
  (tmp-file-len (:pointer uint)))

(defwin32fun ("VerLanguageNameW" ver-language-name version) dword
  (wlang dword)
  (szlang lptstr)
  (cchlang dword))

(defwin32fun ("VerQueryValueW" ver-query-value version) bool
  (block :pointer)
  (sub-block lpctstr)
  (buffer :pointer)
  (len (:pointer uint)))

(defwin32-lispfun ver-set-condition (mask type-mask condition)
  (ver-set-condition-mask mask type-mask condition))

(defwin32fun ("VerSetConditionMask" ver-set-condition-mask kernel32) ulonglong
  (condition-mask ulonglong)
  (type-mask dword)
  (condition byte))

(defwin32fun ("VerifyVersionInfoW" verify-version-info kernel32) bool
  (version-information (:pointer os-version-info-ex))
  (type-mask dword)
  (condition-mask dwordlong))

(defwin32fun ("VkKeyScanW" vk-key-scan user32) short
  (ch wchar))

(defwin32fun ("VkKeyScanExW" vk-key-scan-ex user32) short
  (ch wchar)
  (hkl hkl))

(defwin32fun ("WaitCommEvent" wait-comm-event kernel32) bool
  (hfile handle)
  (lp-evt-mask (:pointer dword))
  (lp-overlapped (:pointer overlapped)))

(defwin32fun ("WaitForMultipleObjects" wait-for-multiple-objects kernel32) dword
  (count dword)
  (handles (:pointer handle))
  (wait-all bool)
  (milliseconds dword))

(defwin32fun ("WaitForMultipleObjectsEx" wait-for-multiple-objects-ex kernel32) dword
  (count dword)
  (handles (:pointer handle))
  (wait-all bool)
  (milliseconds dword)
  (alertable bool))

(defwin32fun ("WaitForSingleObject" wait-for-single-object kernel32) dword
  (handle handle)
  (milliseconds dword))

(defwin32fun ("WaitForSingleObjectEx" wait-for-single-object-ex kernel32) dword
  (handle handle)
  (milliseconds dword)
  (alertable bool))

(defwin32fun ("WaitNamedPipeW" wait-named-pipe kernel32) bool
  (named-pipe-name lpcwstr)
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

(defwin32fun ("WriteProcessMemory" write-process-memory kernel32) bool
  (hprocess handle)
  (base-address (:pointer :void))
  (buffer (:pointer :void))
  (size size-t)
  (number-of-bytes-written (:pointer size-t)))

(defwin32-lispfun zero-memory (destination length)
  (dotimes (i length)
    (setf (cffi:mem-aref destination :uint8 i) 0)))
