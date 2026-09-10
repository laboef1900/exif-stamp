-- Launches Exif Stamp from Capture One's Scripts menu.
-- Brings the app to the front; the app reads the current Capture One
-- selection on launch (and via its Refresh toolbar button).
-- Identifies the app by bundle id so a display-name change does not break
-- the launcher.

tell application id "app.captureonedate.CaptureOneDatePlugin" to activate
