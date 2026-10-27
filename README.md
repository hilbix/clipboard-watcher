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

--------------

# Usage

On the remote:

- Download this as a .ZIP
- Unpack it into some directory
- Click `SendTo - Verknüpfung.lnk` to open Send-To folder
- Copy `clipboard-base64.bat` there

On your local computer:

- Start `clipboard-watcher.ps1` in Powershell
  - it opens a window with a button and a log called `Clipboard Watcher`
  - There is another shell window open.  Either one closes the watcher.

Now on the Remote:

- Right click on a file
- Chose `Send to` (it is often hidden, so you must expand the menu)
- Send it to `clipboard-base64.bat`

On your local computer in `Clipboard Watcher` you will see the transferred filename and the size.
It has been converted such, that you can paste it normally anywhere.

In explorer, in browsers, in WinSCP.  It just works.


# Warnings

- This is rough code.
- It was written in a hurry.
- It was vibe coded.
- It is not polished.

You can certainly find many improvements. 

## But

The first attempt used polling.  I hate polling.  Hence I let the AI improve it such, that it receives events.  Hence the window with the button.

Feel free to improve:

- Get rid of the black window
- Put it into the tray
- Add verification/signatures/whatever

As it is AI coded with only minimal adaptations on my side, feel free to do with it whatever you want.
(But: Pull requests are welcome.  However I probably have no time to help or do things.  Also, keep it small and tidy and free!)
