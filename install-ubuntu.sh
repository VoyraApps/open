#!/bin/bash

# ===================================================================
#      SCRIPT DE INSTALAÇÃO AUTOMÁTICA - VOYRA STUDIO (Ubuntu)
# ===================================================================
# O que este script faz:
# 1. Atualiza o sistema e instala as dependências.
# 2. Instala o Docker Engine e o Docker Compose Plugin (oficial).
# 3. Cria um diretório para a aplicação.
# 4. Baixa o arquivo docker-compose.yml do seu repositório.
# 5. Inicia a aplicação em modo detached (segundo plano).
# ===================================================================

# --- CONFIGURAÇÃO ---
# URL direta para o seu arquivo docker-compose.yml
COMPOSE_FILE_URL="https://raw.githubusercontent.com/VoyraApps/open/main/docker-compose.local.yml"
# Diretório onde a aplicação será instalada
APP_DIR="$HOME/voyra-studio-app"
# --------------------

# Cores para as mensagens
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem Cor

# Função para verificar se o comando anterior foi bem-sucedido
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}ERRO: O passo anterior falhou. Abortando a instalação.${NC}"
        exit 1
    fi
}

# Passo 0: Verificar se o script está sendo executado como root/sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}Este script precisa ser executado com privilégios de superusuário (sudo).${NC}"
  echo -e "${YELLOW}Tentando executar novamente com sudo...${NC}"
  sudo bash "$0" "$@"
  exit $?
fi

echo -e "${GREEN}Passo 1 de 5: Atualizando o sistema e instalando dependências...${NC}"
apt-get update
apt-get install -y ca-certificates curl
check_status

echo -e "${GREEN}Passo 2 de 5: Instalando o Docker Engine...${NC}"
# Adicionar a chave GPG oficial do Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Adicionar o repositório do Docker às fontes do Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Instalar o Docker Engine, CLI, Containerd e o plugin do Compose
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_status

echo -e "${GREEN}Docker instalado com sucesso!${NC}"

echo -e "${GREEN}Passo 3 de 5: Configurando o ambiente da aplicação...${NC}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
check_status

echo -e "${GREEN}Passo 4 de 5: Baixando o arquivo de configuração (docker-compose.yml)...${NC}"
curl -L -o docker-compose.yml "$COMPOSE_FILE_URL"
check_status

echo -e "${GREEN}Passo 5 de 5: Iniciando a aplicação...${NC}"
echo "Isso pode levar alguns minutos, pois irá baixar as imagens."
docker compose up --build -d
check_status

# ========================= SUCESSO =========================
echo -e "\n${GREEN}#######################################"
echo -e "#                                     #"
echo -e "#   Voyra Studio instalado com sucesso!   #"
echo -e "#                                     #"
echo -e "#######################################${NC}\n"
echo -e "Sua aplicação está rodando em segundo plano."
echo -e "Para acessá-la, use o seguinte endereço no seu navegador:"
echo -e "${YELLOW}http://$(curl -s ifconfig.me):5020${NC}\n"
echo -e "Para gerenciar a aplicação, navegue até o diretório ${YELLOW}$APP_DIR${NC} e use os comandos:"
echo -e "  - ${YELLOW}docker compose logs -f${NC} (para ver os logs em tempo real)"
echo -e "  - ${YELLOW}docker compose down${NC} (para parar a aplicação)"
echo -e "  - ${YELLOW}docker compose up -d${NC} (para iniciar novamente)\n"
