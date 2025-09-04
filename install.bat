@echo off
setlocal

:: ===================================================================
::      INSTALADOR VOYRA STUDIO (v7.0)
:: ===================================================================
:: Versao final baseada no script de depuracao funcional para
:: garantir a maxima compatibilidade e robustez.
:: ===================================================================

:: --- CONFIGURACAO ---
set "COMPOSE_FILE_URL=https://raw.githubusercontent.com/VoyraApps/open/refs/heads/main/docker-compose.local.yml"
set "INSTALL_DIR=%USERPROFILE%\VoyraStudioApp"
set "APP_URL=http://localhost:5020"
:: --------------------

title Instalador do Voyra Studio

:: Passo 1: Verificar permissoes de Administrador
cls
echo Passo 1 de 5: Verificando permissoes de Administrador...
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    cls
    echo ERRO: Este instalador precisa ser executado como Administrador.
    echo.
    echo Por favor, clique com o botao direito no arquivo e selecione "Executar como administrador".
    echo.
    pause
    exit /b
)
echo OK! Permissoes concedidas.
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
cls

:: Passo 2: Verificar e preparar o WSL (Virtualizacao)
echo Passo 2 de 5: Verificando ambiente de virtualizacao (WSL)...
wsl --version >nul 2>&1
if %errorLevel% NEQ 0 (
    echo WSL nao detectado. A instalacao dos componentes necessarios sera iniciada.
    pause
    wsl --install
    cls
    echo SUCESSO! O WSL foi instalado/ativado.
    echo.
    echo E OBRIGATORIO REINICIAR O COMPUTADOR para que as mudancas tenham efeito.
    echo.
    echo Apos reiniciar, por favor, execute este script novamente.
    echo.
    pause
    exit /b
)
echo OK! WSL ja esta ativo.
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
cls

:: Passo 3: Verificar se o Docker esta instalado
echo Passo 3 de 5: Verificando instalacao do Docker...
docker --version >nul 2>&1
if %errorLevel% EQU 0 (
    echo OK! Docker Desktop ja esta instalado.
    goto docker_ok
)
echo Docker nao foi detectado. O script tentara instalar.
pause
winget install Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
cls
echo SUCESSO! O Docker foi instalado.
echo.
echo E OBRIGATORIO REINICIAR O COMPUTADOR para que as mudancas tenham efeito.
echo.
echo Apos reiniciar, por favor, execute este script novamente.
echo.
pause
exit /b

:docker_ok
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
cls

:: Passo 4: Criar diretorio e baixar o compose
echo Passo 4 de 5: Configurando os arquivos da aplicacao...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)
cd /d "%INSTALL_DIR%"
echo.
echo Baixando o arquivo de configuracao... Por favor, aguarde.
curl -L "%COMPOSE_FILE_URL%" -o docker-compose.yml
if %errorLevel% NEQ 0 (
    cls
    echo ERRO: Falha ao baixar os arquivos da aplicacao.
    echo Verifique sua conexao com a internet e tente novamente.
    pause
    exit /b
)
echo OK! Arquivos configurados.
echo.
echo Pressione qualquer tecla para iniciar a instalacao...
pause >nul
cls

:: Passo 5: Iniciar os containers
echo Passo 5 de 5: Instalando os componentes do Voyra Studio...
echo.
echo Por favor, aguarde. Este processo pode levar varios minutos na primeira vez.
echo A janela pode parecer travada, mas a instalacao esta ocorrendo.
echo.

docker compose up -d --build

if %errorLevel% NEQ 0 (
    cls
    echo OCORREU UM ERRO DURANTE A INSTALACAO.
    echo.
    echo Por favor, verifique se o Docker Desktop esta aberto e funcionando corretamente.
    echo Tente executar este instalador novamente.
    echo.
    pause
    exit /b
)

:: ========================= SUCESSO =========================
cls
echo            #######################################
echo            #                                     #
echo            #   Voyra Studio instalado com sucesso!   #
echo            #                                     #
echo            #######################################
echo.
echo.
echo A aplicacao esta rodando em segundo plano.
echo.
echo Pressione qualquer tecla para abrir o Voyra Studio no seu navegador...
pause >nul
start %APP_URL%
exit /b