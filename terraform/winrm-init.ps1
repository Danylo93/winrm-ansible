<powershell>
winrm quickconfig -q
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value true
Enable-PSRemoting -Force
</powershell>