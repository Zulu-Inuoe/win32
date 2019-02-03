(in-package #:win32)

(defwin32fun ("WindowFromPoint" window-from-point user32) hwnd
  (point point))
