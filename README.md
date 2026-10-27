English below.  BTW this was vibe coded with the help of <https://ask.brave.com>

# Clipboard Watcher

Das Ding hier besteht aus einem [Sender](clipboard-base64.bat) und einem [Empfänger](clipboard-watcher.ps1).  Beides ist in Powershell realisiert.

Der Sender läuft auf dem Windows basierten Remote-Jumpserver.

- muss in "Send To" (`Senden an..`) von Windows kopiert werden.
- empfängt so die gesendete Datei, konvertiert sie in ein Textformat
- und legt sie in das Clipboard

Das Clipboard wird dann hoffentlich über die Remote-Konsole oder Citrix oder Zscaler oder was auch immer auf die eigene Windows-Kiste gespiegelt.

Dort läuft dann der Empfänger, ein Powershell-Script mit einem minimalen Fenster:

- Es bekommt die Änderung im Clipboard mit
- Guckt in das Clipboard
- Speichert kurz die Datei zwischen (laut KI geht das nicht anders)
- um sie dann sofort ins Clipboard zurückzulegen

Damit funktioniert lokal alles wie gehabt, und auf der Remote muss man halt nur statt Strg+C die Datei in den Sender droppen.


## Linux

Rein technisch ist es sehr einfach, einen entsprechenden Linux-Empfänger zu basteln.  Oder genauer, noch viel einfacher als unter Windows.
Das Transferformat ist ja auch wirklich zu einfach.  Text.  2 Zeilen.  Erste der Dateiname in kkeinem Framing, und danach einfach Base64.
Das ist im Prinzip nur 1 Zeile `bash` (ungetestet, sorry, ich weiß gerade nicht wie man Dateien unter Linux richtig transferiert, ich nix KDE):

```bash
receive() { { read -r magic name && rest="${name% *}" && base64 -d > "$1$name.tmp"; } < <(xclip -selection clipboard -o); }
printf -v prefix '/tmp/%(%Y%m%d-%H%M%S)T-'
receive "$prefix"
xclip -selection clipboard -i <<<"file:/tmp/$prefix$name.tmp"
```

