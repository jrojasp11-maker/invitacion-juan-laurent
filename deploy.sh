#!/bin/bash
# ========================================
# SCRIPT DE DEPLOY AUTOMATIZADO (Linux/macOS)
# invitacion-juan-laurent
# ========================================

set -e  # Exit on error

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════╗"
echo "║  DEPLOY: Invitación Juan → Laurent           ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar herramientas
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} $1 no está instalado."
        echo "  Instala: $2"
        return 1
    fi
    echo -e "${GREEN}[OK]${NC} $1 encontrado"
    return 0
}

echo "[1/5] Verificando herramientas..."
check_tool git "https://git-scm.com/"
HAS_GH=$(check_tool gh "https://cli.github.com/" && echo 1 || echo 0)
HAS_VERCEL=$(check_tool vercel "npm i -g vercel" && echo 1 || echo 0)

# Verificar archivos
echo -e "\n[2/5] Verificando assets requeridos..."
if [ ! -f "lirios.png" ]; then
    echo -e "${YELLOW}[WARNING]${NC} lirios.png NO encontrado en la raíz."
    echo "  Coloca tu imagen de lirios antes de continuar."
fi

if [ ! -f "audio/music.mp3" ]; then
    echo -e "${YELLOW}[WARNING]${NC} audio/music.mp3 NO encontrado."
    echo "  Coloca tu archivo de audio en la carpeta audio/."
fi

# Inicializar Git
echo -e "\n[3/5] Inicializando repositorio Git..."
if [ ! -d ".git" ]; then
    git init
    # Asegurar .gitignore tiene lo básico
    grep -q "node_modules" .gitignore 2>/dev/null || echo "node_modules/" >> .gitignore
    grep -q ".env" .gitignore 2>/dev/null || echo ".env" >> .gitignore
fi

# Commit
echo -e "\n[4/5] Preparando commit..."
git add .
git status --short

read -p "Mensaje de commit (Enter para default): " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"feat: invitación interactiva completa"}

git commit -m "$COMMIT_MSG" || echo -e "${YELLOW}[INFO]${NC} No hay cambios para commitear."

# Deploy options
echo -e "\n[5/5] Opciones de deploy:"
echo "  1) Solo GitHub (push a origin main)"
echo "  2) GitHub + Vercel CLI (deploy directo)"
echo "  3) Crear repo GitHub con gh (auto push)"
echo "  4) Solo prepara local (sin push)"
echo ""
read -p "Elige [1-4]: " OPTION

case $OPTION in
    1)
        # Push a GitHub
        if ! git remote get-url origin &>/dev/null; then
            read -p "URL del repo GitHub (ej: https://github.com/user/repo.git): " REPO_URL
            git remote add origin "$REPO_URL"
        fi
        git branch -M main
        git push -u origin main
        echo -e "\n${GREEN}✅ Push completado.${NC} Configura deploy en Vercel Dashboard."
        ;;
    2)
        # Push + Vercel
        if ! git remote get-url origin &>/dev/null; then
            read -p "URL del repo GitHub: " REPO_URL
            git remote add origin "$REPO_URL"
        fi
        git branch -M main
        git push -u origin main
        echo -e "\n${BLUE}Desplegando en Vercel...${NC}"
        vercel --prod
        ;;
    3)
        # gh repo create
        if [ $HAS_GH -eq 0 ]; then
            echo -e "${RED}[ERROR]${NC} GitHub CLI (gh) requerido para esta opción."
            exit 1
        fi
        gh repo create invitacion-juan-laurent --public --source=. --push
        echo -e "\n${GREEN}✅ Repo creado y push hecho.${NC} Ve a Vercel para importar."
        ;;
    4)
        echo -e "\n${YELLOW}Operación cancelada.${NC} Repo listo localmente."
        ;;
    *)
        echo -e "${RED}Opción inválida.${NC}"
        exit 1
        ;;
esac

# Próximos pasos
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}PRÓXIMOS PASOS MANUALES (si aplica):${NC}"
echo -e "${BLUE}========================================${NC}"
echo "1. Ve a https://vercel.com/dashboard"
echo "2. Importa el repo de GitHub"
echo "3. Configura Environment Variables:"
echo "   - SUPABASE_URL"
echo "   - SUPABASE_ANON_KEY"
echo "   - WHATSAPP_PHONE"
echo "4. Deploy!"
echo ""
echo "Para desarrollo local: npx serve ."
echo ""