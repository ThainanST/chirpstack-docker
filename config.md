# ChirpStack Docker - WSL2 & AU915 Guide

Este repositório contém a infraestrutura para rodar o ChirpStack no WSL2 com suporte ao Gateway Heltec HT-M7603, incluindo automação de rede para contornar as limitações de UDP do Windows.

## 1. Configuração da Rede Windows-WSL2
* **Info**: Não há comunicação UDP nativa entre a interface física do Windows e o WSL2. O script abaixo automatiza a ponte (relay), regras de firewall e libera o acesso web para dispositivos externos.

| Item | Ação | Code |
| :--- | :--- | :--- |
| 1 | Clonar o repositório | `git clone https://github.com/ThainanST/chirpstack-docker.git` |
| 2 | Dar permissão aos scripts | `chmod +x network-gateway-config.sh config-cleanup.sh` |
| 3 | Rodar configurador/relay | `./network-gateway-config.sh` |
| 4 | Limpar após o uso | `./config-cleanup.sh` |

## 2. Configuração do Gateway (HT-M7603)
* **Info**: O Gateway atua como um Packet Forwarder transparente. Ele deve apontar para o IP do Windows que o script anterior forneceu.

| Item | Ação | Obs |
| :--- | :--- | :--- |
| 1 | Acesse o WiFi do Gateway | SSID: `HT_M7603_xxxx`, Senha: `heltec.org` |
| 2 | Acesse o Painel Web | Endereço `192.168.8.1`, Senha: `heltec.org` |
| 3 | Configurar Servidor | No campo `Server Address`, coloque o IP fornecido no Passo 1 |
| 4 | Porta do Servidor | Certifique-se que a porta é `1700` |
| 5 | Obter Identificação | Copie o `Gateway ID` (ex: 40d63c...) para o ChirpStack |

## 3. Configuração do ChirpStack (AU915 Brasil)
* **Info**: Ajustes necessários para o servidor reconhecer os pacotes vindos do Gateway Bridge.

| Item | Ação | Local/Comando |
| :--- | :--- | :--- |
| 1 | Ajustar Tópicos MQTT | No `docker-compose.yml`, mude o prefixo dos tópicos para `au915_0` |
| 2 | Subir os Containers | `docker compose up -d` |
| 3 | Acessar Painel | Login: `admin` / Senha: `admin` |
| 4 | Cadastrar Gateway | Em `Gateways`, adicione o ID e selecione a região `au915_0` |

## 4. Como Acessar
* **Info**: Os links de acesso dinâmicos são exibidos no terminal ao rodar o script de configuração de rede.

**Exemplo de saída do script:**
```text
DADOS PARA CONFIGURAÇÃO:
-----------------------------------------------------
1. NO GATEWAY HELTEC (Server IP): 192.168.0.104
2. PORTA DO GATEWAY:              1700
-----------------------------------------------------
3. ACESSO PAINEL (CELULAR/PC):    [http://192.168.0.104:8080](http://192.168.0.104:8080)
4. ACESSO LOCAL (WSL):            http://localhost:8080
-----------------------------------------------------