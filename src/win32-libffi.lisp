(in-package #:win32)

(defwin32fun ("DragDetect" drag-detect user32) bool
  (hwnd hwnd)
  (point point))

(defwin32fun ("WindowFromPoint" window-from-point user32) hwnd
  (point point))
