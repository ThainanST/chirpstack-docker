#!/bin/bash

# 1. Identificar IP Interno do WSL
WSL_IP=$(hostname -I | awk '{print $1}')

# 2. Buscar IP real do Windows (Ajustado)
WIN_IP=$(powershell.exe -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { \$_.IPAddress -like '192.168.*' } | Select-Object -ExpandProperty IPAddress | Select-Object -First 1" | tr -d '\r\n')

# Fallback caso a rede mude
if [ -z "$WIN_IP" ]; then
    WIN_IP=$(powershell.exe -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { \$_.InterfaceAlias -match 'Wi-Fi|Ethernet' }).IPAddress" | head -n 1 | tr -d '\r\n')
fi

echo -e "\e[1;34m=======================================================\e[0m"
echo -e "\e[1;34m       CONFIGURADOR DE REDE CHIRPSTACK (WSL2)         \e[0m"
echo -e "\e[1;34m=======================================================\e[0m"

# 3. Configurar Windows (Portas e Firewall)
powershell.exe -Command "Start-Process powershell -ArgumentList \"-NoProfile -ExecutionPolicy Bypass -Command \`\" \
  netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=8080 connectaddress=$WSL_IP; \
  New-NetFirewallRule -DisplayName 'Chirpstack Web TCP' -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -Profile Any -ErrorAction SilentlyContinue; \
  New-NetFirewallRule -DisplayName 'Chirpstack Gateway UDP' -Direction Inbound -Protocol UDP -LocalPort 1700 -Action Allow -Profile Any -ErrorAction SilentlyContinue \`\"\" -Verb RunAs"

echo -e "\n\e[1;37m  DADOS PARA CONFIGURAÇÃO:\e[0m"
echo -e "  -----------------------------------------------------"
echo -e "  1. NO GATEWAY HELTEC (Server IP): \e[1;31m$WIN_IP\e[0m"
echo -e "  2. PORTA DO GATEWAY:              \e[1;31m1700\e[0m"
echo -e "  -----------------------------------------------------"
echo -e "  3. ACESSO PAINEL (CELULAR/PC):    \e[1;32mhttp://$WIN_IP:8080\e[0m"
echo -e "  4. ACESSO LOCAL (WSL):            \e[1;32mhttp://localhost:8080\e[0m"
echo -e "  -----------------------------------------------------"

echo -e "\n\e[1;35m[STATUS]\e[0m Relay UDP Ativo. Escutando $WIN_IP:1700..."
echo -e "Pressione \e[1;33mCTRL+C\e[0m para encerrar.\n"

# 4. Relay UDP (Mão Dupla)
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    \$WslIp = '$WSL_IP';
    \$udpClient = New-Object System.Net.Sockets.UdpClient(1700);
    \$wslEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse(\$WslIp), 1700);
    \$gatewayEndPoint = \$null;

    try {
        while (\$true) {
            \$remoteEP = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0);
            \$data = \$udpClient.Receive([ref]\$remoteEP);

            if (\$remoteEP.Address.ToString() -eq \$WslIp) {
                if (\$null -ne \$gatewayEndPoint) {
                    \$null = \$udpClient.Send(\$data, \$data.Length, \$gatewayEndPoint);
                }
            } else {
                \$gatewayEndPoint = \$remoteEP;
                \$null = \$udpClient.Send(\$data, \$data.Length, \$wslEndPoint);
                Write-Host '↑' -NoNewline -ForegroundColor Green;
            }
        }
    } finally { \$udpClient.Close() }
"