# ===================================================================
#      SCRIPT DE INSTALAÇÃO AUTOMÁTICA - VOYRA STUDIO (v2)
# ===================================================================
#
# O que este script faz:
# 1. Pede permissão de Administrador.
# 2. Verifica se o Docker Desktop está instalado.
# 3. Se não estiver, tenta instalar automaticamente.
# 4. SE A INSTALAÇÃO AUTOMÁTICA FALHAR, abre o site oficial para download.
# 5. Cria a pasta da aplicação, baixa o docker-compose.yml e inicia tudo.
#
# ===================================================================

# --- CONFIGURAÇÃO ---
$composeFileUrl = "https://raw.githubusercontent.com/VoyraApps/open/refs/heads/main/docker-compose.local.yml" 
$installDir = "$env:USERPROFILE\VoyraStudioApp"
$dockerInstallUrl = "https://docs.docker.com/desktop/install/windows-install/"
# --------------------


# Função para exibir mensagens coloridas
function Write-Host-Color {
    param(
        [string]$Message,
        [string]$Color
    )
    Write-Host $Message -ForegroundColor $Color
}

# 1. Verificar se está sendo executado como Administrador
Write-Host-Color "Passo 1: Verificando permissões de Administrador..." -ForegroundColor Yellow
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host-Color "ERRO: Este script precisa ser executado como Administrador." -ForegroundColor Red
    Write-Host-Color "Por favor, clique com o botão direito no arquivo e selecione 'Executar como Administrador'." -ForegroundColor Red
    Read-Host "Pressione Enter para sair..."
    exit
}
Write-Host-Color "OK! Permissões de administrador concedidas." -ForegroundColor Green

# 2. Verificar se o Docker Desktop está instalado
Write-Host-Color "`nPasso 2: Verificando a instalação do Docker Desktop..." -ForegroundColor Yellow
$dockerPath = Get-Command docker -ErrorAction SilentlyContinue
if ($null -eq $dockerPath) {
    Write-Host-Color "Docker Desktop não encontrado. Tentando instalar automaticamente (pode demorar)..." -ForegroundColor Yellow
    try {
        # Tenta a instalação silenciosa via Winget
        winget install Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
        Write-Host-Color "IMPORTANTE: Docker Desktop foi instalado. É necessário REINICIAR o computador." -ForegroundColor Cyan
        Write-Host-Color "Após reiniciar, execute este script novamente para finalizar a configuração da aplicação." -ForegroundColor Cyan
        Read-Host "Pressione Enter para sair..."
        exit
    } catch {
        # Bloco de falha - Executa a sua sugestão!
        Write-Host-Color "----------------------------------------------------------------" -ForegroundColor Red
        Write-Host-Color "ERRO: A instalação automática do Docker falhou." -ForegroundColor Red
        Write-Host-Color "Você precisa instalá-lo manualmente para continuar." -ForegroundColor Yellow
        Read-Host "Pressione ENTER para abrir a página oficial de download do Docker..."
        
        # Abre o navegador no site do Docker
        Start-Process $dockerInstallUrl
        
        Write-Host-Color "`nApós instalar o Docker e REINICIAR o seu computador, por favor, execute este script novamente." -ForegroundColor Cyan
        Read-Host "Pressione Enter para fechar esta janela."
        exit
    }
} else {
    Write-Host-Color "OK! Docker Desktop já está instalado." -ForegroundColor Green
}

# 3. Criar diretório da aplicação e baixar o compose
Write-Host-Color "`nPasso 3: Configurando o ambiente da aplicação..." -ForegroundColor Yellow
if (-not (Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory | Out-Null
}
cd $installDir
Write-Host "Baixando o arquivo de configuração (docker-compose.yml) do seu GitHub..."
try {
    Invoke-WebRequest -Uri $composeFileUrl -OutFile "docker-compose.yml"
    Write-Host-Color "OK! Arquivo baixado." -ForegroundColor Green
} catch {
    Write-Host-Color "ERRO: Não foi possível baixar o arquivo docker-compose.yml." -ForegroundColor Red
    Read-Host "Pressione Enter para sair..."
    exit
}

# 4. Iniciar os contêineres com Docker Compose
Write-Host-Color "`nPasso 4: Iniciando a aplicação... Isso pode levar alguns minutos." -ForegroundColor Yellow
try {
    docker compose up -d --build
    Write-Host-Color "`n-----------------------------------------------------" -ForegroundColor Cyan
    Write-Host-Color "SUCESSO! Sua aplicação foi iniciada!" -ForegroundColor Green
    Write-Host-Color "  - Acesse sua aplicação em: http://localhost:5020" -ForegroundColor White
    Write-Host-Color "  - Gerencie o RabbitMQ em: http://localhost:15672 (user: admin, pass: admin)" -ForegroundColor White
    Write-Host-Color "`nPara parar a aplicação, abra o PowerShell, navegue até a pasta '$installDir' e execute: docker compose down" -ForegroundColor Yellow
    Write-Host-Color "-----------------------------------------------------" -ForegroundColor Cyan
} catch {
    Write-Host-Color "ERRO: Falha ao iniciar os contêineres." -ForegroundColor Red
    Write-Host-Color "Verifique se o Docker Desktop está em execução (ícone da baleia perto do relógio) e tente novamente." -ForegroundColor Red
}

Read-Host "Pressione Enter para fechar esta janela..."
