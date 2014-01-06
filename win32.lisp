;;;Copyright (c) 2013 Wilfredo Velázquez-Rodríguez
;;;
;;;This software is provided 'as-is', without any express or implied
;;;warranty. In no event will the authors be held liable for any damages
;;;arising from the use of this software.
;;;
;;;Permission is granted to anyone to use this software for any purpose,
;;;including commercial applications, and to alter it and redistribute
;;;it freely, subject to the following restrictions:
;;;
;;;1. The origin of this software must not be misrepresented; you must not
;;;   claim that you wrote the original software. If you use this software
;;;   in a product, an acknowledgment in the product documentation would
;;;   be appreciated but is not required.
;;;
;;;2. Altered source versions must be plainly marked as such, and must not
;;;   be misrepresented as being the original software.
;;;
;;;3. This notice may not be removed or altered from any source distribution.

(cl:in-package #:win32)

(cffi:define-foreign-library kernel32
  (:win32 "Kernel32"))

(cffi:define-foreign-library user32
  (:win32 "User32"))

(cffi:define-foreign-library gdi32
  (:win32 "Gdi32"))

(cffi:define-foreign-library opengl32
  (:win32 "Opengl32"))

(cffi:use-foreign-library user32)
(cffi:use-foreign-library kernel32)
(cffi:use-foreign-library gdi32)
(cffi:use-foreign-library opengl32)

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
       (error "The value ~A cannot be converted at this time, as negatives are not supported." value)))))

(defconstant +win32-string-encoding+
  #+little-endian :utf-16le
  #+big-endian :utf-16be
  "Not a win32 'constant' per-se, but useful to expose for usage with CFFI:FOREIGN-STRING-TO-LISP and friends.")

;;Pixel types
(defconstant +pfd-type-rgba+        0)
(defconstant +pfd-type-colorindex+  1)

;;Layer types
(defconstant +pfd-main-plane+       0)
(defconstant +pfd-overlay-plane+    1)
(defconstant +pfd-underlay-plane+   -1)

;;Flags
(defconstant +pfd-doublebuffer+            #x00000001)
(defconstant +pfd-stereo+                  #x00000002)
(defconstant +pfd-draw-to-window+          #x00000004)
(defconstant +pfd-draw-to-bitmap+          #x00000008)
(defconstant +pfd-support-gdi+             #x00000010)
(defconstant +pfd-support-opengl+          #x00000020)
(defconstant +pfd-generic-format+          #x00000040)
(defconstant +pfd-need-palette+            #x00000080)
(defconstant +pfd-need-system-palette+     #x00000100)
(defconstant +pfd-swap-exchange+           #x00000200)
(defconstant +pfd-swap-copy+               #x00000400)
(defconstant +pfd-swap-layer-buffers+      #x00000800)
(defconstant +pfd-generic-accelerated+     #x00001000)
(defconstant +pfd-support-directdraw+      #x00002000)
(defconstant +pfd-direct3d-accelerated+    #x00004000)
(defconstant +pfd-support-composition+     #x00008000)
(defconstant +pfd-depth-dontcare+          #x20000000)
(defconstant +pfd-doublebuffer-dontcare+   #x40000000)
(defconstant +pfd-stereo-dontcare+         #x80000000)

;;Window styles
(defconstant +ws-overlapped+     #x00000000)
(defconstant +ws-popup+          #x80000000)
(defconstant +ws-child+          #x40000000)
(defconstant +ws-visible+        #x10000000)
(defconstant +ws-caption+        #x00C00000)
(defconstant +ws-border+         #x00800000)
(defconstant +ws-tabstop+        #x00010000)
(defconstant +ws-maximizebox+    #x00010000)
(defconstant +ws-minimizebox+    #x00020000)
(defconstant +ws-thickframe+     #x00040000)
(defconstant +ws-sysmenu+        #x00080000)

(defconstant +ws-overlappedwindow+ (logior +ws-overlapped+ +ws-caption+ +ws-sysmenu+ +ws-thickframe+ +ws-minimizebox+ +ws-maximizebox+))

;;Window ex styles
(defconstant +ws-ex-windowedge+   #x00000100)
(defconstant +ws-ex-appwindow+    #x00040000)

;;Edit control types
(defconstant +es-left+ #x0000)
(defconstant +es-center+ #x0001)
(defconstant +es-right+ #x0002)

(defconstant +wm-null+                     #x0000)
(defconstant +wm-create+                   #x0001)
(defconstant +wm-destroy+                  #x0002)
(defconstant +wm-move+                     #x0003)
(defconstant +wm-size+                     #x0005)
(defconstant +wm-activate+                 #x0006)
(defconstant +wm-setfocus+                 #x0007)
(defconstant +wm-killfocus+                #x0008)
(defconstant +wm-enable+                   #x000A)
(defconstant +wm-setredraw+                #x000B)
(defconstant +wm-settext+                  #x000C)
(defconstant +wm-gettext+                  #x000D)
(defconstant +wm-gettextlength+            #x000E)
(defconstant +wm-paint+                    #x000F)
(defconstant +wm-close+                    #x0010)
(defconstant +wm-queryendsession+          #x0011)
(defconstant +wm-quit+                     #x0012)
(defconstant +wm-queryopen+                #x0013)
(defconstant +wm-erasebkgnd+               #x0014)
(defconstant +wm-syscolorchange+           #x0015)
(defconstant +wm-endsession+               #x0016)
(defconstant +wm-systemerror+              #x0017)
(defconstant +wm-showwindow+               #x0018)
(defconstant +wm-ctlcolor+                 #x0019)
(defconstant +wm-wininichange+             #x001A)
(defconstant +wm-settingchange+            #x001A)
(defconstant +wm-devmodechange+            #x001B)
(defconstant +wm-activateapp+              #x001C)
(defconstant +wm-fontchange+               #x001D)
(defconstant +wm-timechange+               #x001E)
(defconstant +wm-cancelmode+               #x001F)
(defconstant +wm-setcursor+                #x0020)
(defconstant +wm-mouseactivate+            #x0021)
(defconstant +wm-childactivate+            #x0022)
(defconstant +wm-queuesync+                #x0023)
(defconstant +wm-getminmaxinfo+            #x0024)
(defconstant +wm-painticon+                #x0026)
(defconstant +wm-iconerasebkgnd+           #x0027)
(defconstant +wm-nextdlgctl+               #x0028)
(defconstant +wm-spoolerstatus+            #x002A)
(defconstant +wm-drawitem+                 #x002B)
(defconstant +wm-measureitem+              #x002C)
(defconstant +wm-deleteitem+               #x002D)
(defconstant +wm-vkeytoitem+               #x002E)
(defconstant +wm-chartoitem+               #x002F)
(defconstant +wm-setfont+                  #x0030)
(defconstant +wm-getfont+                  #x0031)
(defconstant +wm-sethotkey+                #x0032)
(defconstant +wm-gethotkey+                #x0033)
(defconstant +wm-querydragicon+            #x0037)
(defconstant +wm-compareitem+              #x0039)
(defconstant +wm-compacting+               #x0041)
(defconstant +wm-windowposchanging+        #x0046)
(defconstant +wm-windowposchanged+         #x0047)
(defconstant +wm-power+                    #x0048)
(defconstant +wm-copydata+                 #x004A)
(defconstant +wm-canceljournal+            #x004B)
(defconstant +wm-notify+                   #x004E)
(defconstant +wm-inputlangchangerequest+   #x0050)
(defconstant +wm-inputlangchange+          #x0051)
(defconstant +wm-tcard+                    #x0052)
(defconstant +wm-help+                     #x0053)
(defconstant +wm-userchanged+              #x0054)
(defconstant +wm-notifyformat+             #x0055)
(defconstant +wm-contextmenu+              #x007B)
(defconstant +wm-stylechanging+            #x007C)
(defconstant +wm-stylechanged+             #x007D)
(defconstant +wm-displaychange+            #x007E)
(defconstant +wm-geticon+                  #x007F)
(defconstant +wm-seticon+                  #x0080)
(defconstant +wm-nccreate+                 #x0081)
(defconstant +wm-ncdestroy+                #x0082)
(defconstant +wm-nccalcsize+               #x0083)
(defconstant +wm-nchittest+                #x0084)
(defconstant +wm-ncpaint+                  #x0085)
(defconstant +wm-ncactivate+               #x0086)
(defconstant +wm-getdlgcode+               #x0087)
(defconstant +wm-syncpaint+                #x0088)
(defconstant +wm-ncmousemove+              #x00A0)
(defconstant +wm-nclbuttondown+            #x00A1)
(defconstant +wm-nclbuttonup+              #x00A2)
(defconstant +wm-nclbuttondblclk+          #x00A3)
(defconstant +wm-ncrbuttondown+            #x00A4)
(defconstant +wm-ncrbuttonup+              #x00A5)
(defconstant +wm-ncrbuttondblclk+          #x00A6)
(defconstant +wm-ncmbuttondown+            #x00A7)
(defconstant +wm-ncmbuttonup+              #x00A8)
(defconstant +wm-ncmbuttondblclk+          #x00A9)
(defconstant +wm-keyfirst+                 #x0100)
(defconstant +wm-keydown+                  #x0100)
(defconstant +wm-keyup+                    #x0101)
(defconstant +wm-char+                     #x0102)
(defconstant +wm-deadchar+                 #x0103)
(defconstant +wm-syskeydown+               #x0104)
(defconstant +wm-syskeyup+                 #x0105)
(defconstant +wm-syschar+                  #x0106)
(defconstant +wm-sysdeadchar+              #x0107)
(defconstant +wm-keylast+                  #x0108)
(defconstant +wm-ime_startcomposition+     #x010D)
(defconstant +wm-ime_endcomposition+       #x010E)
(defconstant +wm-ime_composition+          #x010F)
(defconstant +wm-ime_keylast+              #x010F)
(defconstant +wm-initdialog+               #x0110)
(defconstant +wm-command+                  #x0111)
(defconstant +wm-syscommand+               #x0112)
(defconstant +wm-timer+                    #x0113)
(defconstant +wm-hscroll+                  #x0114)
(defconstant +wm-vscroll+                  #x0115)
(defconstant +wm-initmenu+                 #x0116)
(defconstant +wm-initmenupopup+            #x0117)
(defconstant +wm-menuselect+               #x011F)
(defconstant +wm-menuchar+                 #x0120)
(defconstant +wm-enteridle+                #x0121)
(defconstant +wm-ctlcolormsgbox+           #x0132)
(defconstant +wm-ctlcoloredit+             #x0133)
(defconstant +wm-ctlcolorlistbox+          #x0134)
(defconstant +wm-ctlcolorbtn+              #x0135)
(defconstant +wm-ctlcolordlg+              #x0136)
(defconstant +wm-ctlcolorscrollbar+        #x0137)
(defconstant +wm-ctlcolorstatic+           #x0138)
(defconstant +wm-mousefirst+               #x0200)
(defconstant +wm-mousemove+                #x0200)
(defconstant +wm-lbuttondown+              #x0201)
(defconstant +wm-lbuttonup+                #x0202)
(defconstant +wm-lbuttondblclk+            #x0203)
(defconstant +wm-rbuttondown+              #x0204)
(defconstant +wm-rbuttonup+                #x0205)
(defconstant +wm-rbuttondblclk+            #x0206)
(defconstant +wm-mbuttondown+              #x0207)
(defconstant +wm-mbuttonup+                #x0208)
(defconstant +wm-mbuttondblclk+            #x0209)
(defconstant +wm-mousewheel+               #x020A)
(defconstant +wm-mousehwheel+              #x020E)
(defconstant +wm-parentnotify+             #x0210)
(defconstant +wm-entermenuloop+            #x0211)
(defconstant +wm-exitmenuloop+             #x0212)
(defconstant +wm-nextmenu+                 #x0213)
(defconstant +wm-sizing+                   #x0214)
(defconstant +wm-capturechanged+           #x0215)
(defconstant +wm-moving+                   #x0216)
(defconstant +wm-powerbroadcast+           #x0218)
(defconstant +wm-devicechange+             #x0219)
(defconstant +wm-mdicreate+                #x0220)
(defconstant +wm-mdidestroy+               #x0221)
(defconstant +wm-mdiactivate+              #x0222)
(defconstant +wm-mdirestore+               #x0223)
(defconstant +wm-mdinext+                  #x0224)
(defconstant +wm-mdimaximize+              #x0225)
(defconstant +wm-mditile+                  #x0226)
(defconstant +wm-mdicascade+               #x0227)
(defconstant +wm-mdiiconarrange+           #x0228)
(defconstant +wm-mdigetactive+             #x0229)
(defconstant +wm-mdisetmenu+               #x0230)
(defconstant +wm-entersizemove+            #x0231)
(defconstant +wm-exitsizemove+             #x0232)
(defconstant +wm-dropfiles+                #x0233)
(defconstant +wm-mdirefreshmenu+           #x0234)
(defconstant +wm-ime-setcontext+           #x0281)
(defconstant +wm-ime-notify+               #x0282)
(defconstant +wm-ime-control+              #x0283)
(defconstant +wm-ime-compositionfull+      #x0284)
(defconstant +wm-ime-select+               #x0285)
(defconstant +wm-ime-char+                 #x0286)
(defconstant +wm-ime-keydown+              #x0290)
(defconstant +wm-ime-keyup+                #x0291)
(defconstant +wm-mousehover+               #x02A1)
(defconstant +wm-ncmouseleave+             #x02A2)
(defconstant +wm-mouseleave+               #x02A3)
(defconstant +wm-cut+                      #x0300)
(defconstant +wm-copy+                     #x0301)
(defconstant +wm-paste+                    #x0302)
(defconstant +wm-clear+                    #x0303)
(defconstant +wm-undo+                     #x0304)
(defconstant +wm-renderformat+             #x0305)
(defconstant +wm-renderallformats+         #x0306)
(defconstant +wm-destroyclipboard+         #x0307)
(defconstant +wm-drawclipboard+            #x0308)
(defconstant +wm-paintclipboard+           #x0309)
(defconstant +wm-vscrollclipboard+         #x030A)
(defconstant +wm-sizeclipboard+            #x030B)
(defconstant +wm-askcbformatname+          #x030C)
(defconstant +wm-changecbchain+            #x030D)
(defconstant +wm-hscrollclipboard+         #x030E)
(defconstant +wm-querynewpalette+          #x030F)
(defconstant +wm-paletteischanging+        #x0310)
(defconstant +wm-palettechanged+           #x0311)
(defconstant +wm-hotkey+                   #x0312)
(defconstant +wm-print+                    #x0317)
(defconstant +wm-printclient+              #x0318)
(defconstant +wm-handheldfirst+            #x0358)
(defconstant +wm-handheldlast+             #x035F)
(defconstant +wm-penwinfirst+              #x0380)
(defconstant +wm-penwinlast+               #x038F)
(defconstant +wm-coalesce_first+           #x0390)
(defconstant +wm-coalesce_last+            #x039F)
(defconstant +wm-dde-first+                #x03E0)
(defconstant +wm-dde-initiate+             #x03E0)
(defconstant +wm-dde-terminate+            #x03E1)
(defconstant +wm-dde-advise+               #x03E2)
(defconstant +wm-dde-unadvise+             #x03E3)
(defconstant +wm-dde-ack+                  #x03E4)
(defconstant +wm-dde-data+                 #x03E5)
(defconstant +wm-dde-request+              #x03E6)
(defconstant +wm-dde-poke+                 #x03E7)
(defconstant +wm-dde-execute+              #x03E8)
(defconstant +wm-dde-last+                 #x03E8)
(defconstant +wm-user+                     #x0400)
(defconstant +wm-app+                      #x8000)

(defconstant +time-cancel+    #x80000000)
(defconstant +time-hover+     #x00000001)
(defconstant +time-leave+     #x00000002)
(defconstant +time-nonclient+ #x80000010)
(defconstant +time-query+     #x40000000)

(defconstant +cw-usedefault+ (%to-int32 #x80000000))

(defconstant +cs-vredraw+ #x0001)
(defconstant +cs-hredraw+ #x0002)
(defconstant +cs-owndc+   #x0020)

(defconstant +sw-show+ 5)

(defvar +idi-application+ (cffi:make-pointer 32512))
(defvar +idc-arrow+ (cffi:make-pointer 32512))

(defconstant +white-brush+ 0)
(defconstant +black-brush+ 4)
(defconstant +dc-brush+ 18)

(defconstant +gcl-hbrbackground+ -10)
(defconstant +gcl-wndproc+ -24)

(defconstant +gcw-atom+ -32)

(defconstant +gwl-wndproc+  -4)
(defconstant +gwl-id+       -12)
(defconstant +gwl-style+    -16)
(defconstant +gwl-userdata+ -21)

(defconstant +swp-nosize+         #x0001)
(defconstant +swp-nomove+         #x0002)
(defconstant +swp-nozorder+       #x0004)
(defconstant +swp-noactivate+     #x0010)
(defconstant +swp-showwindow+     #x0040)
(defconstant +swp-hidewindow+     #x0080)
(defconstant +swp-noownerzorder+  #x0200)
(defconstant +swp-noreposition+   #x0200)

(defconstant +infinite+       #xFFFFFFFF)

(defconstant +wait-object-0+  #x00000000)
(defconstant +wait-abandoned+ #x00000080)
(defconstant +wait-timeout+   #x00000102)
(defconstant +wait-failed+    #xFFFFFFFF)

(defconstant +hwnd-top+       #x00000000)
(defconstant +hwnd-bottom+    #x00000001)
(defconstant +hwnd-message+   #xFFFFFFFD)
(defconstant +hwnd-notopmost+ #xFFFFFFFE)
(defconstant +hwnd-topmost+   #xFFFFFFFF)

(defconstant +winevent-outofcontext+    #x0000)
(defconstant +winevent-skipownthread+   #x0001)
(defconstant +winevent-skipownprocess+  #x0002)
(defconstant +winevent-incontext+       #x0004)

(defconstant +wh-mouse+        7)
(defconstant +wh-mouse-ll+    14)

(defconstant +delete+         #x00010000)
(defconstant +read-control+   #x00020000)
(defconstant +write-dac+      #x00040000)
(defconstant +write-owner+    #x00080000)
(defconstant +synchronize+    #x00100000)

(defconstant +standard-rights-required+ #x00F0000)

(defconstant +standard-rights-read+     +read-control+)
(defconstant +standard-rights-write+    +read-control+)
(defconstant +standard-rights-execute+  +read-control+)

(defconstant +standard-rights-all+      #x001F0000)
(defconstant +specific-rights-all+      #x0000FFFF)

(defconstant +desktop-createmenu+      #x0004
  "Required to create a menu on the desktop.")
(defconstant +desktop-createwindow+    #x0002
  "Required to create a window on the desktop.")
(defconstant +desktop-enumerate+       #x0040
  "Required for the desktop to be enumerated.")
(defconstant +desktop-hookcontrol+     #x0008
  "Required to establish any of the window hooks.")
(defconstant +desktop-journalplayback+ #x0020
  "Required to perform journal playback on a desktop.")
(defconstant +desktop-journalrecord+   #x0010
  "Required to perform journal recording on a desktop.")
(defconstant +desktop-readobjects+     #x0001
  "Required to read objects on the desktop.")
(defconstant +desktop-switchdesktop+   #x0100
  "Required to activate the desktop using the SwitchDesktop function.")
(defconstant +desktop-writeobjects+    #x0080
  "Required to write objects on the desktop.")

(defconstant +generic-read+ (logior +desktop-enumerate+
                                    +desktop-readobjects+
                                    +standard-rights-read+))

(defconstant +generic-write+ (logior +desktop-createmenu+
                                     +desktop-createwindow+
                                     +desktop-hookcontrol+
                                     +desktop-journalplayback+
                                     +desktop-journalrecord+
                                     +desktop-writeobjects+
                                     +standard-rights-write+))

(defconstant +generic-execute+ (logior +desktop-switchdesktop+
                                       +standard-rights-execute+))

(defconstant +generic-all+ (logior +desktop-createmenu+
                                   +desktop-createwindow+
                                   +desktop-enumerate+
                                   +desktop-hookcontrol+
                                   +desktop-journalplayback+
                                   +desktop-journalrecord+
                                   +desktop-readobjects+
                                   +desktop-switchdesktop+
                                   +desktop-writeobjects+
                                   +standard-rights-required+))

(cffi:defcstruct rect
  (left :int32)
  (top :int32)
  (right :int32)
  (bottom :int32))

(cffi:defcstruct paletteentry
  (red :uint8)
  (green :uint8)
  (blue :uint8)
  (flags :uint8))

(cffi:defcstruct paintstruct
  (dc :pointer)
  (erase :boolean)
  (paint (:struct rect))
  (restore :boolean)
  (incupdate :boolean)
  (rgbreserved :uint8 :count 32))

(cffi:defcstruct logpalette
  (version :uint16)
  (num-entries :uint16)
  (palette-entries (:struct paletteentry) :count 1))

(cffi:defcstruct pixelformatdescriptor
  (size :uint16)
  (version :uint16)
  (flags :uint32)
  (pixel-type :uint8)
  (color-bits :uint8)
  (red-bits :uint8)
  (red-shift :uint8)
  (green-bits :uint8)
  (green-shift :uint8)
  (blue-bits :uint8)
  (blue-shift :uint8)
  (alpha-bits :uint8)
  (alpha-shift :uint8)
  (accum-bits :uint8)
  (accum-red-bits :uint8)
  (accum-green-bits :uint8)
  (accum-blue-bits :uint8)
  (accum-alpha-bits :uint8)
  (depth-bits :uint8)
  (stencil-bits :uint8)
  (aux-buffers :uint8)
  (layer-type :uint8)
  (reserved :uint8)
  (layer-mask :uint32)
  (visible-mask :uint32)
  (damage-mask :uint32))

(cffi:defcstruct point
  (x :int32)
  (y :int32))

(cffi:defcstruct trackmouseevent
  (cbsize :uint32)
  (flags :uint32)
  (hwnd :pointer)
  (hover-time :uint32))

(cffi:defcstruct wndclass
  (style :uint32)
  (wndproc :pointer)
  (clsextra :int32)
  (wndextra :int32)
  (instance :pointer)
  (icon :pointer)
  (cursor :pointer)
  (background :pointer)
  (menu-name (:string :encoding #.+win32-string-encoding+))
  (wndclass-name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcstruct wndclassex
  (cbsize :uint32)
  (style :uint32)
  (wndproc :pointer)
  (clsextra :int32)
  (wndextra :int32)
  (instance :pointer)
  (icon :pointer)
  (cursor :pointer)
  (background :pointer)
  (menu-name (:string :encoding #.+win32-string-encoding+))
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (iconsm :pointer))

(cffi:defcstruct msg
  (hwnd :pointer)
  (message :uint32)
  (wparam :pointer)
  (lparam :pointer)
  (time :uint32)
  (point (:struct point)))

(cffi:defcstruct createstruct
  (create-params :pointer)
  (instance :pointer)
  (menu :pointer)
  (parent :pointer)
  (cy :int)
  (cx :int)
  (y :int)
  (x :int)
  (style :long)
  (name (:string :encoding #.+win32-string-encoding+))
  (class (:string :encoding #.+win32-string-encoding+))
  (exstyle :uint32))

(cffi:defcfun ("Beep" beep) :boolean
  (frequency :uint32)
  (duration :uint32))

(cffi:defcfun ("BeginPaint" begin-paint) :pointer
  (hwnd :pointer)
  (paint :pointer))

(cffi:defcfun ("ChoosePixelFormat" choose-pixel-format) :int
  (dc :pointer)
  (pixel-format :pointer))

(cffi:defcfun ("ClientToScreen" client-to-screen) :boolean
  (hwnd :pointer)
  (point :pointer))

(cffi:defcfun ("ClipCursor" clip-cursor) :boolean
  (rect :pointer))

(cffi:defcfun ("CreatePalette" create-palette) :pointer
  (log-palette :pointer))

(cffi:defcfun ("DescribePixelFormat" describe-pixel-format) :int
  (dc :pointer)
  (format-index :int)
  (bytes :uint32)
  (pixel-format :pointer))

(cffi:defcfun ("DestroyCursor" destroy-cursor) :boolean
  (cursor :pointer))

(cffi:defcfun ("EndPaint" end-paint) :boolean
  (hwnd :pointer)
  (paint :pointer))

(cffi:defcfun ("FindWindowW" find-window) :pointer
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (window-name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("GetClassLongW" get-class-long) :long
  (hwnd :pointer)
  (index :int))

#+x86
(cffi:defcfun ("GetClassLongW" get-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int))

#+x86-64
(cffi:defcfun ("GetClassLongPtrW" get-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int))

(cffi:defcfun ("GetClassWord" get-class-word) :uint16
  (hwnd :pointer)
  (index :int))

(cffi:defcfun ("GetClientRect" get-client-rect) :boolean
  (hwnd :pointer)
  (rect :pointer))

(cffi:defcfun ("GetCommandLineW" get-command-line) (:string :encoding #.+win32-string-encoding+))

(cffi:defcfun ("GetCurrentProcess" get-current-process) :pointer)

(cffi:defcfun ("GetCurrentProcessId" get-current-process-id) :uint32)

(cffi:defcfun ("GetCurrentProcessorNumber" get-current-processor-number) :uint32)

(cffi:defcfun ("GetDC" get-dc) :pointer
  (hwnd :pointer))

(cffi:defcfun ("GetDesktopWindow" get-desktop-window) :pointer)

(cffi:defcfun ("GetShellWindow" get-shell-window) :pointer)

(cffi:defcfun ("GetParent" get-parent) :pointer
  (hwnd :pointer))

(cffi:defcfun ("GetPixelFormat" get-pixel-format) :int
  (dc :pointer))

(cffi:defcfun ("GetTopWindow" get-top-window) :pointer
  (hwnd :pointer))

(cffi:defcfun ("GetWindowTextW" get-window-text) :int
  (hwnd :pointer)
  (string (:string :encoding #.+win32-string-encoding+))
  (size :int))

(cffi:defcfun ("IsGUIThread" is-gui-thread) :boolean
  (convert :boolean))

(cffi:defcfun ("InvalidateRect" invalidate-rect) :boolean
  (hwnd :pointer)
  (rect :pointer)
  (erase :boolean))

(cffi:defcfun ("IsWindow" is-window) :boolean
  (hwnd :pointer))

(cffi:defcfun ("RealizePalette" realize-palette) :uint32
  (dc :pointer))

(cffi:defcfun ("RegisterClassW" register-class) :uint16
  (wndclass :pointer))

(cffi:defcfun ("RegisterClassExW" register-class-ex) :uint16
  (wndclassex :pointer))

(cffi:defcfun ("ReleaseDC" release-dc) :boolean
  (hwnd :pointer)
  (dc :pointer))

(cffi:defcfun ("ResizePalette" resize-palette) :boolean
  (palette :pointer)
  (entries :int))

(cffi:defcfun ("SelectPalette" select-palette) :pointer
  (dc :pointer)
  (palette :pointer)
  (force-background :boolean))


(cffi:defcfun ("SetClassLongW" set-class-long) :uint32
  (hwnd :pointer)
  (index :int)
  (value :long))

#+x86
(cffi:defcfun ("SetClassLongW" set-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int)
  (value :pointer))

#+x86-64
(cffi:defcfun ("SetClassLongPtrW" set-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int)
  (value :pointer))

(cffi:defcfun ("SetClassWord" set-class-word) :pointer
  (hwnd :pointer)
  (index :int)
  (value :uint16))

(cffi:defcfun ("SetCursor" set-cursor) :pointer
  (cursor :pointer))

(cffi:defcfun ("SetCursorPos" set-cursor-pos) :boolean
  (x :int)
  (y :int))

(cffi:defcfun ("SetForegroundWindow" set-foreground-window) :boolean
  (hwnd :pointer))

(cffi:defcfun ("SetParent" set-parent) :boolean
  (hwnd :pointer)
  (new-parent :pointer))

(cffi:defcfun ("SetPixelFormat" set-pixel-format) :boolean
  (dc :pointer)
  (format-index :int)
  (pixel-format :pointer))

(cffi:defcfun ("SetWindowTextW" set-window-text) :boolean
  (hwnd :pointer)
  (text (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("SwapBuffers" swap-buffers) :boolean
  (dc :pointer))

(cffi:defcfun ("TrackMouseEvent" track-mouse-event) :boolean
  (trackmousevent :pointer))

(cffi:defcfun ("UnregisterClassW" unregister-class) :boolean
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (instance :pointer))

(cffi:defcfun ("ValidateRect" validate-rect) :boolean
  (hwnd :pointer)
  (rect :pointer))

(cffi:defcfun ("DefWindowProcW" def-window-proc) :uint32
  (hwnd :pointer)
  (msg :uint32)
  (wparam :pointer)
  (lparam :pointer))

(cffi:defcfun ("GetModuleHandleW" get-module-handle) :pointer
  (module (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("LoadIconW" load-icon) :pointer
  (instance :pointer)
  (name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("LoadCursorW" load-cursor) :pointer
  (instance :pointer)
  (name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("LoadCursorFromFileW" load-cursor-from-file) :pointer
  (file-name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("GetStockObject" get-stock-object) :pointer
  (object :uint32))

(cffi:defcfun ("CreateWindowExW" create-window-ex) :pointer
  (ex-style :uint32)
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (window-name (:string :encoding #.+win32-string-encoding+))
  (style :uint32)
  (x :int32)
  (y :int32)
  (width :int32)
  (height :int32)
  (parent :pointer)
  (menu :pointer)
  (module-instance :pointer)
  (param :pointer))

(cffi:defcfun ("ShowCursor" show-cursor) :int
  (show :boolean))

(cffi:defcfun ("ShowWindow" show-window) :int
  (hwnd :pointer)
  (cmd :int32))

(cffi:defcfun ("EnumWindows" enum-windows) :boolean
  (callback :pointer)
  (lparam :pointer))

(cffi:defcfun ("UpdateWindow" update-window) :int
  (hwnd :pointer))

(cffi:defcfun ("GetMessageW" get-message) :boolean
  (msg :pointer)
  (hwnd :pointer)
  (msg-min :uint32)
  (msg-max :uint32))

(cffi:defcfun ("PeekMessageW" peek-message) :int
  (msg :pointer)
  (hwnd :pointer)
  (msg-min :uint32)
  (msg-max :uint32)
  (remove :uint32))

(cffi:defcfun ("PostQuitMessage" post-quit-message) :void
  (exit-code :int32))

(cffi:defcfun ("PostThreadMessageW" post-thread-message) :boolean
  (thread-id :uint32)
  (msg :uint32)
  (wparam :pointer)
  (lparam :pointer))

(cffi:defcfun ("TranslateMessage" translate-message) :int
  (msg :pointer))

(cffi:defcfun ("DispatchMessageW" dispatch-message) :int32
  (msg :pointer))

(cffi:defcfun ("CloseWindow" close-window) :boolean
  (hwnd :pointer))

(cffi:defcfun ("DestroyWindow" destroy-window) :boolean
  (hwnd :pointer))

(cffi:defcfun ("GetLastError" get-last-error) :uint32)

(cffi:defcfun ("SetWindowLongW" set-window-long) :int32
  (hwnd :pointer)
  (index :int32)
  (newval :int32))

(cffi:defcfun ("GetWindowLongW" get-window-long) :int32
  (hwnd :pointer)
  (index :int32))

(cffi:defcfun ("SetWindowPos" set-window-pos) :boolean
  (hwnd :pointer)
  (insert-after :pointer)
  (x :int32)
  (y :int32)
  (cx :int32)
  (cy :int32)
  (flags :uint32))

(cffi:defcfun ("GetWindowRect" get-window-rect) :boolean
  (hwnd :pointer)
  (rect :pointer))

(cffi:defcfun ("DeleteObject" delete-object) :int
  (object :pointer))

(cffi:defcfun ("PostMessageW" post-message) :boolean
  (hwnd :pointer)
  (msg :uint32)
  (wparam :pointer)
  (lparam :pointer))

(cffi:defcfun ("GetCurrentThreadId" get-current-thread-id) :uint32)

(cffi:defcfun ("SetWindowsHookExW" set-windows-hook-ex) :pointer
  (id-hook :int32)
  (hook :pointer)
  (module :pointer)
  (thread-id :uint32))

(cffi:defcfun ("SetLayeredWindowAttributes" set-layered-window-attributes) :boolean
  (hwnd :pointer)
  (color :uint32)
  (alpha :uint8)
  (flags :uint32))

(defun rgb (r g b)
  (logior (ash b 16)
          (ash g 8)
          (ash r 0)))

(cffi:defcfun ("CallNextHookEx" call-next-hook) :uint32
  (current-hook :pointer)
  (code :int32)
  (wparam :uint32)
  (lparam :uint32))

(cffi:defcfun ("SetWinEventHook" set-win-event-hook) :pointer
  (event-min :uint32)
  (event-max :uint32)
  (proc-module :pointer)
  (id-process :uint32)
  (id-thread :uint32)
  (flags :uint32))

(cffi:defcfun ("GetWindowThreadProcessId" get-window-thread-process-id) :uint32
  (hwnd :pointer)
  (process-id :pointer))

;;;TODO This function actually takes in a struct point, but we need cffi-libffi for that
(cffi:defcfun ("WindowFromPoint" window-from-point) :pointer
  (x :int32)
  (y :int32))

(cffi:defcfun ("CreateEventW" create-event) :pointer
  (security-attributes :pointer)
  (manual-reset :boolean)
  (initial-state :boolean)
  (name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("CreateSemaphoreW" create-semaphore) :pointer
  (security-attributes :pointer)
  (initial-count :int32)
  (maximum-count :int32)
  (name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("OpenEventW" open-event) :pointer
  (access :uint32)
  (inherit-handle :boolean)
  (name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("WaitForSingleObject" wait-for-single-object) :uint32
  (handle :pointer)
  (milliseconds :uint32))

(cffi:defcfun ("wglCreateContext" wgl-create-context) :pointer
  (dc :pointer))

(cffi:defcfun ("wglDeleteContext" wgl-delete-context) :boolean
  (context :pointer))

(cffi:defcfun ("wglMakeCurrent" wgl-make-current) :boolean
  (dc :pointer)
  (gl-rc :pointer))

(cffi:defcfun ("SetEvent" set-event) :boolean
  (event :pointer))

(cffi:defcfun ("ResetEvent" reset-event) :boolean
  (event :pointer))

(cffi:defcfun ("CloseHandle" close-handle) :boolean
  (handle :pointer))

(cffi:defcfun ("CreateMutexW" create-mutex) :pointer
  (security-attributes :pointer)
  (initial-owner :boolean)
  (name (:string :encoding #.+win32-string-encoding+)))

(cffi:defcfun ("CreateDesktopW" create-desktop) :pointer
  (desktop (:string :encoding #.+win32-string-encoding+))
  (device :pointer)
  (devmode :pointer)
  (flags :uint32)
  (desired-access :uint32)
  (security-attributes :pointer))

(cffi:defcfun ("OpenInputDesktop" open-input-desktop) :pointer
  (flags :uint32)
  (inherit :boolean)
  (desired-access :uint32))

(cffi:defcfun ("SwitchDesktop" switch-desktop) :boolean
  (desktop :pointer))

(cffi:defcfun ("memset" memset) :pointer
  (ptr :pointer)
  (val :int)
  (num :int))
