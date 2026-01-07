# Add Windows Firewall rule to allow port 5001
New-NetFirewallRule -DisplayName "Spring Boot Backend (Port 5001)" -Direction Inbound -LocalPort 5001 -Protocol TCP -Action Allow
Write-Host "Firewall rule added for port 5001"
