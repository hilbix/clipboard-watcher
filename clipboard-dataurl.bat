@echo off
powershell -NoProfile -Command "$f='%~1'; $enc=[Convert]::ToBase64String([IO.File]::ReadAllBytes($f)); Set-Clipboard -Value ('data:application/octet-stream;base64,' + $enc)"
