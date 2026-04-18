@echo off
title Renove GLP-1 - Servidor Local
color 0A
echo.
echo  ██████╗ ███████╗███╗   ██╗ ██████╗ ██╗   ██╗███████╗
echo  ██╔══██╗██╔════╝████╗  ██║██╔═══██╗██║   ██║██╔════╝
echo  ██████╔╝█████╗  ██╔██╗ ██║██║   ██║██║   ██║█████╗
echo  ██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══╝
echo  ██║  ██║███████╗██║ ╚████║╚██████╔╝ ╚████╔╝ ███████╗
echo  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚══════╝
echo.
echo  GLP-1 App - Iniciando servidor local...
echo  ─────────────────────────────────────────────────────
echo.

:: Mudar para o diretorio do script
cd /d "%~dp0"

:: Verificar se Node.js esta instalado
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Node.js nao encontrado!
    echo.
    echo  Por favor, instale o Node.js em:
    echo  https://nodejs.org/pt
    echo.
    echo  Depois de instalar, feche e abra este arquivo novamente.
    echo.
    pause
    exit /b 1
)

echo  [OK] Node.js encontrado:
node --version
echo.
echo  Iniciando servidor em http://localhost:3000
echo.
echo  >> Abrindo Chrome automaticamente em 3 segundos...
echo.

:: Abrir Chrome apos 3 segundos (em background)
start "" timeout /t 3 /nobreak >nul && start "" "http://localhost:3000"

:: Iniciar servidor com npx serve
npx --yes serve . --listen 3000

echo.
echo  Servidor encerrado.
pause
