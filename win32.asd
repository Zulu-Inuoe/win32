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

(asdf:defsystem #:win32
  :description "A cffi wrapper package for win32, including Kernel32, User32, and GDI32."
  :version "0.0.0.2"
  :author "Wilfredo Velázquez-Rodríguez <zulu.inuoe@gmail.com>"
  :license "zlib/libpng License <http://opensource.org/licenses/zlib-license.php>"
  :components ((:file "package")
               (:file "win32" :depends-on ("package")))
  :depends-on (#:cffi #:trivial-features))
