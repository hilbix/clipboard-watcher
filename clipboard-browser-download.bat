@echo off
powershell -NoProfile -Command "$f='%~1'; $name=Split-Path $f -Leaf; $enc=[Convert]::ToBase64String([IO.File]::ReadAllBytes($f)); $html='<a download='+$name+' href=\"data:application/octet-stream;base64,'+$enc+'\">Download</a>'; Set-Clipboard -Value ('data:text/html,' + [Uri]::EscapeDataString($html))"

