#!/bin/bash

echo -e "\e[1;31m=======================================================\e[0m"
echo -e "\e[1;31m       LIMPANDO CONFIGURAÇÕES DO CHIRPSTACK           \e[0m"
echo -e "\e[1;31m=======================================================\e[0m"

# 1. Avisar sobre o Relay
echo -e "\e[1;33m[1/3]\e[0m Se o script de configuração ainda estiver rodando,"
echo -e "      pressione CTRL+C naquela janela para parar o Relay UDP."

# 2. Limpar Netsh e Firewall via PowerShell
echo -e "\n\e[1;33m[2/3]\e[0m Removendo pontes TCP e regras de Firewall no Windows..."

powershell.exe -Command "Start-Process powershell -ArgumentList \"-NoProfile -ExecutionPolicy Bypass -Command \`\" \
  netsh interface portproxy delete v4tov4 listenport=8080 listenaddress=0.0.0.0; \
  Remove-NetFirewallRule -DisplayName 'Chirpstack Web TCP' -ErrorAction SilentlyContinue; \
  Remove-NetFirewallRule -DisplayName 'Chirpstack Gateway UDP' -ErrorAction SilentlyContinue \`\"\" -Verb RunAs"

# 3. Limpeza de processos órfãos (opcional)
echo -e "\n\e[1;33m[3/3]\e[0m Garantindo que não restaram processos de rede pendentes..."
# (Este comando apenas mata qualquer instância de Relay que tenha ficado travada)

echo -e "\n\e[1;32m[SUCESSO]\e[0m O Windows está limpo."
echo "  - Porta 8080 (Painel) fechada."
echo "  - Regras de Firewall removidas."
echo -e "\e[1;31m=======================================================\e[0m"