#!/usr/bin/env bash

# Interrompe a execução imediatamente se qualquer comando falhar,
# se houver variável não definida ou falha em pipelines.
set -euo pipefail

# ==============================================================================
# Configurações e Variáveis de Ambiente
# ==============================================================================
# Marca o tempo inicial da execução em segundos para cálculo de duração
INICIO_EXECUCAO=$(date +%s)

# Identifica o usuário real de forma segura via getent passwd (sem usar eval)
USUARIO_REAL="${SUDO_USER:-$USER}"
HOME_REAL=$(getent passwd "$USUARIO_REAL" | cut -d: -f6)

BASE_DIR="$HOME_REAL/agroalerta-infra"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/provision.log"

# Pacotes essenciais de infraestrutura para o projeto
PACOTES=(
    curl
    wget
    git
    ufw
    htop
    net-tools
    unzip
)

# ==============================================================================
# Funções Auxiliares
# ==============================================================================
# Função para registrar mensagens com data/hora na tela e no arquivo de log
log_msg() {
    local nivel="$1"
    local mensagem="$2"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$nivel] $mensagem" | tee -a "$LOG_FILE"
}

# Trap para capturar e registrar qualquer erro inesperado antes de encerrar
tratamento_erro() {
    local linha="$1"
    local comando="$2"
    log_msg "ERRO" "Falha crítica na linha $linha ao executar: '$comando'. Execução interrompida."
    exit 1
}

trap 'tratamento_erro $LINENO "$BASH_COMMAND"' ERR

# ==============================================================================
# Início da Execução
# ==============================================================================

# 1. Verificar permissões administrativas (root/sudo) antes de tudo
if [[ "$EUID" -ne 0 ]]; then
    echo "[ERRO] Este script precisa ser executado com permissões administrativas (use: sudo ./provision.sh)."
    exit 1
fi

# 2. Criar os diretórios necessários do projeto (idempotente com -p)
mkdir -p "$LOG_DIR"
mkdir -p "$BASE_DIR/scripts"
mkdir -p "$BASE_DIR/config"
mkdir -p "$BASE_DIR/monitoring"

# Garante que o arquivo de log exista e pertença ao usuário comum (não ao root)
touch "$LOG_FILE"
chown -R "$USUARIO_REAL:$USUARIO_REAL" "$BASE_DIR"

# 3. Identificar o início da execução e registrar data/hora no log
log_msg "INFO" "=========================================================="
log_msg "INFO" "INÍCIO DO PROVISIONAMENTO - Projeto Agro-Alerta Infra"
log_msg "INFO" "Executado por: $USUARIO_REAL (via sudo)"
log_msg "INFO" "=========================================================="

# 4. Atualizar a lista de pacotes do Ubuntu (sem parâmetro -y desnecessário)
log_msg "INFO" "Atualizando a lista de pacotes do sistema (apt-get update)..."
DEBIAN_FRONTEND=noninteractive apt-get update >> "$LOG_FILE" 2>&1
log_msg "SUCESSO" "Lista de pacotes atualizada com sucesso."

# 5. Instalar as ferramentas necessárias para a infraestrutura
log_msg "INFO" "Verificando e instalando pacotes: ${PACOTES[*]}..."
DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACOTES[@]}" >> "$LOG_FILE" 2>&1
log_msg "SUCESSO" "Todas as ferramentas de infraestrutura estão instaladas."

# Ajusta novamente as permissões da pasta do projeto por segurança
chown -R "$USUARIO_REAL:$USUARIO_REAL" "$BASE_DIR"

# 6. Finalização e cálculo de duração
FIM_EXECUCAO=$(date +%s)
DURACAO=$((FIM_EXECUCAO - INICIO_EXECUCAO))

log_msg "SUCESSO" "Provisionamento concluído sem erros!"
log_msg "INFO" "TÉRMINO DO PROVISIONAMENTO - Duração total: ${DURACAO}s"
log_msg "INFO" "=========================================================="
