Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class ClipListener : NativeWindow
{
    private Action _onUpdate;
    public ClipListener(Action onUpdate) { _onUpdate = onUpdate; }

    protected override void WndProc(ref Message m)
    {
        if (m.Msg == 0x031D && _onUpdate != null) _onUpdate();
        base.WndProc(ref m);
    }

    [DllImport("user32.dll")] private static extern bool AddClipboardFormatListener(IntPtr hwnd);
    [DllImport("user32.dll")] private static extern bool RemoveClipboardFormatListener(IntPtr hwnd);

    public void Register()
    {
        CreateHandle(new CreateParams { Parent = new IntPtr(-3) });
        AddClipboardFormatListener(Handle);
    }

    public void Unregister()
    {
        RemoveClipboardFormatListener(Handle);
        DestroyHandle();
    }
}
"@ -ReferencedAssemblies @("System.Windows.Forms", "System.Drawing")

# --- UI ---
$form = [Windows.Forms.Form]::new()
$form.Text = "Clipboard Watcher"
$form.Size = [System.Drawing.Size]::new(420, 300)
$form.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen

$btn = [Windows.Forms.Button]::new()
#$btn.Text = "Stop"
$btn.Location = [System.Drawing.Point]::new(10, 10)
$btn.Size = [System.Drawing.Size]::new(80, 28)

$log = [Windows.Forms.TextBox]::new()
$log.Location = [System.Drawing.Point]::new(10, 45)
$log.Size = [System.Drawing.Size]::new(390, 230)
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = [Windows.Forms.ScrollBars]::Vertical
$log.Font = [System.Drawing.Font]::new("Consolas", 9)

$form.Controls.Add($btn)
$form.Controls.Add($log)

# --- State ---
$script:listener = $null
$script:suppress = $false

function Add-Log {
    param([string]$msg)
    $log.AppendText("[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')] $msg`r`n")
    $log.SelectionStart = $log.TextLength
    $log.ScrollToCaret()
}

function Convert-Clipboard {
    if ($script:suppress) { return }
    try { $text = Get-Clipboard -Raw } catch { $text = "" }
    if (-not $text) { return }
    $lines = $text -split "`r`n"
    if ($lines.Count -eq 2 -and $lines[0] -match '^ClIpBoArDfIlE [^/\\]+ eLiFdRaObPiLc$' -and $lines[1] -match '^[A-Za-z0-9+/=]+$') {
        $name  = $lines[0] -split " "
        $name  = $name[1..($name.Length -2)] -join " "
        $bytes = [Convert]::FromBase64String($lines[1])
        $tmp   = [IO.Path]::Combine([IO.Path]::GetTempPath(), $name)
        [IO.File]::WriteAllBytes($tmp, $bytes)
        $script:suppress = $true
        [System.Windows.Forms.Clipboard]::SetFileDropList(@($tmp))
        $script:suppress = $false
        Add-Log "$name ($([math]::Round($bytes.Length/1KB,1)) KB)"
    }
}

function Lis-Start {
    if ($null -eq $script:listener) {
        $script:suppress = $false

        $btn.Text = "Stop"
        $script:listener = [ClipListener]::new({
            $form.BeginInvoke([Action]{ Convert-Clipboard })
        })
        $script:listener.Register()
        Add-Log "Gestartet"
        Convert-Clipboard
	$true
    }
}

function Lis-Stop {
    $btn.Text = "Start"
    if ($script:listener) {
        $script:listener.Unregister()
    }
    $script:listener = $null
    Add-Log "Gestoppt"
}

$btn.Add_Click({
  $r = Lis-Start
  if (-not $r) {
    Lis-Stop
  }
})

$form.Add_FormClosed({
    Stop
    $form.Dispose()
})

Lis-Start

[System.Windows.Forms.Application]::Run($form)
