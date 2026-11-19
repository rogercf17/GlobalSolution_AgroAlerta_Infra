
#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# AGROALERTA - MONITORAMENTO DE INFRAESTRUTURA
# ==========================================

BASE_DIR="/home/roger/agroalerta-infra"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/monitor.log"

# Limites de alerta (%)
CPU_LIMITE=80
RAM_LIMITE=85
DISCO_LIMITE=80

mkdir -p "$LOG_DIR"

# Registra mensagens no arquivo de log
registrar_log() {
    local nivel="$1"
    local mensagem="$2"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$nivel] $mensagem" \
        | tee -a "$LOG_FILE"
}

# Calcula o uso da CPU usando /proc/stat
CPU_ANTES=$(awk '/^cpu / {
    idle=$5+$6
    total=0
    for (i=2; i<=NF; i++) total+=$i
    print total, idle
}' /proc/stat)

sleep 1

CPU_DEPOIS=$(awk '/^cpu / {
    idle=$5+$6
    total=0
    for (i=2; i<=NF; i++) total+=$i
    print total, idle
}' /proc/stat)

CPU_USO=$(awk -v antes="$CPU_ANTES" -v depois="$CPU_DEPOIS" 'BEGIN {
    split(antes, a, " ")
    split(depois, b, " ")

    total=b[1]-a[1]
    idle=b[2]-a[2]

    if (total > 0)
        printf "%.0f", ((total-idle)/total)*100
    else
        print 0
}')

# Calcula o uso da memória RAM
RAM_USO=$(free -b | awk '/Mem:/ {
    printf "%.0f", (($2-$7)/$2)*100
}')

# Calcula o uso do disco da partição raiz
DISCO_USO=$(df -P / | awk 'NR==2 {
    gsub("%", "", $5)
    print $5
}')

# Registra os indicadores
registrar_log "INFO" "Monitoramento iniciado."
registrar_log "INFO" "Uso da CPU: ${CPU_USO}%"
registrar_log "INFO" "Uso da RAM: ${RAM_USO}%"
registrar_log "INFO" "Uso do disco: ${DISCO_USO}%"

# Verifica limites e registra alertas
if (( CPU_USO >= CPU_LIMITE )); then
    registrar_log "ALERTA" "Uso da CPU acima do limite: ${CPU_USO}%"
fi

if (( RAM_USO >= RAM_LIMITE )); then
    registrar_log "ALERTA" "Uso da RAM acima do limite: ${RAM_USO}%"
fi

if (( DISCO_USO >= DISCO_LIMITE )); then
    registrar_log "ALERTA" "Uso do disco acima do limite: ${DISCO_USO}%"
fi

registrar_log "INFO" "Monitoramento finalizado."
registrar_log "INFO" "------------------------------------------"
