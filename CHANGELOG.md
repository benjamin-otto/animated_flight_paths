# Changelog

## 0.0.3

**Bug fixes:**

* Cannot get size from a render object that has been marked dirty for layout. Occurred when trying to get the `CustomPaint` size after `didChangeMetrics` called.

## 0.0.2

**Bug fixes:**

* Map occasionally loses focus when using arrow keys if other focusable widgets are rendered (i.e. TextFormFields).
* Labels not showing if used for more than one flight.
* Calling setState after dispose.

## 0.0.1

**Initial release.**
