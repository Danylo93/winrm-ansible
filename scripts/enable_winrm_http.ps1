<#
Run on the Windows target as Administrator to enable WinRM over HTTP (5985)
and allow Basic auth for Ansible in lab/dev. For production, prefer HTTPS (5986).
#>

powershell -NoProfile -ExecutionPolicy Bypass -Command @'
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '==> Ensuring WinRM service'
Enable-PSRemoting -Force
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

Write-Host '==> Configuring WinRM HTTP listener'
try {
  $listener = winrm enumerate winrm/config/listener | Select-String -SimpleMatch 'Transport = HTTP'
  if (-not $listener) {
    winrm create winrm/config/Listener?Address=*+Transport=HTTP
  }
} catch { Write-Warning $_ }

Write-Host '==> Allowing Basic over HTTP (DEV only)'
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

Write-Host '==> Opening Windows Firewall for 5985'
if (-not (Get-NetFirewallRule -DisplayName 'WINRM HTTP In' -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName 'WINRM HTTP In' -Name 'WINRM-HTTP-In' -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Any
}

Write-Host '==> Done. Test from control node: Test-NetConnection -ComputerName <host> -Port 5985'
'@

