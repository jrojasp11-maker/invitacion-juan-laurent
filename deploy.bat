@echo off
REM ========================================
REM SCRIPT DE DEPLOY AUTOMATIZADO (Windows)
REM invitacion-juan-laurent
REM ========================================

echo.
echo  ╔═══════════════════════════════════════════════╗
echo  ║  DEPLOY: Invitación Juan → Laurent           ║
echo  ╚═══════════════════════════════════════════════╝
echo.

REM Verificar herramientas
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git no está instalado.
    echo Instala desde: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] GitHub CLI (gh) no está instalado.
    echo Instala desde: https://cli.github.com/
    echo Se intentará continuar con git push manual.
    echo.
)

where vercel >nul 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Vercel CLI no está instalado.
    echo Instala con: npm i -g vercel
    echo Se intentará deploy via GitHub integration.
    echo.
)

echo [1/5] Verificando archivos requeridos...
if not exist "lirios.png" (
    echo [WARNING] lirios.png NO encontrado en la raíz.
    echo Coloca tu imagen de lirios antes de continuar.
    echo.
)
if not exist "audio\music.mp3" (
    echo [WARNING] audio\music.mp3 NO encontrado.
    echo Coloca tu archivo de audio en la carpeta audio/.
    echo.
)

echo [2/5] Inicializando repositorio Git...
if not exist ".git" (
    git init
    echo "node_modules/" >> .gitignore
    echo ".env" >> .gitignore
    echo "*.log" >> .gitignore
)

echo [3/5] Agregando archivos...
git add .
git status

echo.
set /p COMMIT_MSG="Mensaje de commit (Enter para default): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=feat: invitación interactiva completa

echo [4/5] Commit...
git commit -m "%COMMIT_MSG%"

echo.
echo [5/5] ¿Subir a GitHub y desplegar?
echo.
echo Opciones:
echo   1) Solo GitHub (push a origin main)
echo   2) GitHub + Vercel CLI (deploy directo)
echo   3) Solo crear repo GitHub (sin push)
echo   4) Salir sin hacer push
echo.
set /p OPTION="Elige [1-4]: "

if "%OPTION%"=="1" (
    echo Verificando remote...
    git remote get-url origin >nul 2>nul
    if %errorlevel% neq 0 (
        set /p REPO_URL="URL del repo GitHub (ej: https://github.com/user/repo.git): "
        git remote add origin %REPO_URL%
    )
    git branch -M main
    git push -u origin main
    echo.
    echo ✅ Push completado. Configura deploy en Vercel Dashboard.
) else if "%OPTION%"=="2" (
    echo Verificando remote...
    git remote get-url origin >nul 2>nul
    if %errorlevel% neq 0 (
        set /p REPO_URL="URL del repo GitHub: "
        git remote add origin %REPO_URL%
    )
    git branch -M main
    git push -u origin main
    echo.
    echo Desplegando en Vercel...
    vercel --prod
) else if "%OPTION%"=="3" (
    gh repo create invitacion-juan-laurent --public --source=. --push
    echo.
    echo ✅ Repo creado y push hecho. Ve a Vercel para importar.
) else (
    echo.
    echo Operación cancelada. Repo listo localmente.
)

echo.
echo ========================================
echo PRÓXIMOS PASOS MANUALES (si aplica):
echo ========================================
echo 1. Ve a https://vercel.com/dashboard
echo 2. Importa el repo de GitHub
echo 3. Configura Environment Variables:
echo    - SUPABASE_URL
echo    - SUPABASE_ANON_KEY
echo    - WHATSAPP_PHONE
echo 4. Deploy!
echo.
echo Para desarrollo local: npx serve .
echo.
pause