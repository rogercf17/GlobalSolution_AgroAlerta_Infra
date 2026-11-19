# AgroAlerta + AgroVigia — Infraestrutura Linux

## 1. Sobre o projeto

O **AgroAlerta + AgroVigia** é uma solução de monitoramento inteligente do campo, desenvolvida como parte do projeto Global Solution 2026 da FIAP.

O projeto tem como objetivo demonstrar como a tecnologia pode auxiliar no acompanhamento de condições ambientais e na identificação preventiva de situações de risco na agricultura.

Este repositório contém a implementação da infraestrutura Linux responsável por hospedar e executar a aplicação AgroAlerta, além de realizar o provisionamento do ambiente e o monitoramento automatizado dos recursos do servidor.

## 2. Objetivos da infraestrutura

- Preparar automaticamente um ambiente Linux para execução da aplicação.
- Hospedar a API AgroAlerta em um servidor Ubuntu.
- Gerenciar a inicialização e a execução dos serviços com Systemd.
- Monitorar o consumo de CPU, memória RAM e disco.
- Registrar logs de provisionamento e monitoramento.
- Identificar situações de uso elevado dos recursos do servidor.
- Garantir a inicialização automática dos serviços após reinicializações.

## 3. Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| Ubuntu Server 24.04.5 LTS | Sistema operacional |
| Bash | Automação e scripts |
| Systemd | Gerenciamento de serviços |
| .NET 10 | Execução da API |
| SQLite | Persistência de dados da aplicação |
| Git e GitHub | Versionamento |
| VirtualBox | Ambiente virtualizado |

## 4. Arquitetura da infraestrutura

A infraestrutura foi implementada em uma máquina virtual Ubuntu Server, responsável por hospedar a API e executar o monitoramento automatizado.

A aplicação é executada como um serviço Systemd, enquanto outro serviço realiza verificações periódicas dos recursos computacionais.

### Componentes principais

- **AgroAlerta API:** aplicação ASP.NET Core responsável pelo processamento das requisições e gerenciamento dos dados.
- **Provisionamento:** script Bash responsável pela preparação do ambiente.
- **Monitoramento:** script Bash que verifica CPU, memória RAM e utilização do disco.
- **Systemd:** responsável por controlar os serviços e agendar as verificações periódicas.
- **Logs:** registros das atividades de provisionamento e monitoramento.

## 5. Estrutura do repositório

```text
GlobalSolution_AgroAlerta_Infra/
│
├── config/
│   └── systemd/
│       ├── agroalerta-api.service
│       ├── agroalerta-monitor.service
│       └── agroalerta-monitor.timer
│
├── evidence/
│   └── infra-audit.txt
│
├── logs/
│   ├── monitor.log
│   └── provision.log
│
├── monitoring/
│   └── monitor.sh
│
├── scripts/
│   └── provision.sh
│
├── .gitignore
└── README.md
```

Os arquivos publicados neste repositório representam os scripts, configurações e evidências da infraestrutura. Os arquivos compilados da aplicação e o banco de dados local são mantidos fora do versionamento.

## 6. Provisionamento do ambiente

O provisionamento é realizado por meio do script `provision.sh`, desenvolvido em Bash.

O script automatiza a preparação do ambiente Linux, incluindo a instalação de ferramentas necessárias, criação da estrutura de diretórios e geração de registros de execução.

### Execução

```bash
sudo bash scripts/provision.sh
```

O resultado da execução é registrado em:

```text
logs/provision.log
```

## 7. Hospedagem da aplicação

A API AgroAlerta foi publicada em ambiente Linux utilizando .NET 10.

A aplicação é executada por meio de um serviço Systemd, permitindo inicialização automática e reinicialização em caso de falha.

### Configuração do serviço

Arquivo: `agroalerta-api.service`

Principais configurações:

- Usuário de execução: `roger`.
- Diretório de trabalho: `/home/roger/agroalerta-infra/app`.
- Porta de execução: `5000`.
- Reinicialização automática em caso de falha.
- Inicialização automática com o sistema.

### Comandos de gerenciamento

Verificar status:

```bash
sudo systemctl status agroalerta-api
```

Iniciar:

```bash
sudo systemctl start agroalerta-api
```

Reiniciar:

```bash
sudo systemctl restart agroalerta-api
```

Consultar logs:

```bash
sudo journalctl -u agroalerta-api
```

## 8. Monitoramento dos recursos

O monitoramento é realizado pelo script `monitor.sh`, que verifica periodicamente os seguintes recursos:

- **CPU:** percentual de utilização do processador.
- **Memória RAM:** percentual de memória utilizada.
- **Disco:** percentual de utilização do armazenamento.

### Limites de alerta

| Recurso | Limite configurado |
|---|---:|
| CPU | 80% |
| Memória RAM | 85% |
| Disco | 80% |

Quando um limite é ultrapassado, o script registra um alerta no arquivo de log.

Os registros são armazenados em:

```text
logs/monitor.log
```

### Execução manual

```bash
bash monitoring/monitor.sh
```

## 9. Automação com Systemd Timer

O monitoramento foi integrado ao Systemd por meio de dois componentes:

- `agroalerta-monitor.service`: executa o script de monitoramento.
- `agroalerta-monitor.timer`: agenda a execução periódica do serviço.

O timer está configurado para realizar a primeira execução um minuto após a inicialização e repetir a verificação a cada minuto.

### Verificar o timer

```bash
sudo systemctl status agroalerta-monitor.timer
```

Consultar agendamentos:

```bash
systemctl list-timers
```

Consultar logs do serviço:

```bash
sudo journalctl -u agroalerta-monitor.service
```

## 10. Rede e acesso à aplicação

A máquina virtual utiliza uma interface de rede configurada com DHCP.

A aplicação é disponibilizada na porta TCP `5000`, com encaminhamento de porta configurado no VirtualBox para permitir o acesso a partir da máquina hospedeira.

### Endpoints de verificação

```text
http://localhost:5000/api/farms
http://localhost:5000/swagger/index.html
http://localhost:5000/openapi/v1.json
```

O acesso externo depende da configuração de encaminhamento de portas do ambiente virtualizado.

## 11. Testes e validações realizados

Durante a implementação, foram realizados testes para verificar o funcionamento da infraestrutura:

- Execução do script de provisionamento.
- Verificação dos registros de provisionamento.
- Execução manual do script de monitoramento.
- Verificação dos logs de CPU, memória e disco.
- Simulação controlada de ultrapassagem do limite de CPU.
- Verificação do registro de alertas no log.
- Inicialização e gerenciamento dos serviços Systemd.
- Verificação do agendamento automático pelo Systemd Timer.
- Teste de acesso à API e à documentação Swagger.
- Reinicialização da máquina virtual para validar a inicialização automática dos serviços.

## 12. Considerações finais

A infraestrutura Linux foi desenvolvida para demonstrar o provisionamento automatizado, a hospedagem de uma aplicação web, o gerenciamento de serviços e o monitoramento dos recursos computacionais.

A solução integra automação com Shell Script, gerenciamento de serviços com Systemd e monitoramento periódico, oferecendo uma base funcional para a execução do AgroAlerta em ambiente Linux.

---

## 13. Informações acadêmicas

**Instituição:** FIAP  
**Projeto:** Global Solution 2026  
**Solução:** AgroAlerta + AgroVigia — Monitoramento Inteligente do Campo  
**Repositório:** GlobalSolution_AgroAlerta_Infra  
**Autor:** Roger Cardoso Ferreira
