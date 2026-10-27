@echo off
powershell -NoProfile -Command "$f='%~1'; $name=Split-Path $f -Leaf; $enc=[Convert]::ToBase64String([IO.File]::ReadAllBytes($f)); Set-Clipboard -Value ('ClIpBoArDfIlE ' + $name + ' eLiFdRaObPiLc' + [Environment]::NewLine + $enc)"
