
# Ideia inicial 

### capturar os logs gerados pelo PostgreSQL e inseri-los em uma tabela dentro do banco de dados.


## 1. Configurar o PostgreSQL para gerar logs detalhados

Primeiro, ajuste a configuração do PostgreSQL para garantir que ele gere os logs necessários, como queries, operações e transações.

Abra o arquivo postgresql.conf e ajuste os seguintes parâmetros para capturar todos os eventos que você deseja logar:

```bash
log_destination = 'csvlog'         # Use formato CSV para facilitar a leitura dos logs.
logging_collector = on             # Ativa a coleta de logs em arquivos.
log_directory = 'pg_log'           # Diretório onde os logs serão armazenados.
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'  # Nome dos arquivos de log.
log_statement = 'all'              # Loga todas as consultas (DDL, DML).
log_duration = on                  # Loga a duração de cada consulta.
```

Isso fará com que o PostgreSQL gere logs em formato CSV, facilitando o processamento posterior.


## 2. Criar uma tabela para armazenar os logs

Agora, crie uma tabela no banco de dados onde você deseja armazenar os logs:

```sql
CREATE TABLE postgres_logs (
    log_time TIMESTAMPTZ,
    user_name TEXT,
    database_name TEXT,
    process_id INT,
    connection_from TEXT,
    session_id TEXT,
    session_line_num BIGINT,
    command_tag TEXT,
    session_start_time TIMESTAMPTZ,
    virtual_transaction_id TEXT,
    transaction_id BIGINT,
    error_severity TEXT,
    sql_state_code TEXT,
    message TEXT,
    detail TEXT,
    hint TEXT,
    internal_query TEXT,
    internal_query_pos INT,
    context TEXT,
    query TEXT,
    query_pos INT,
    location TEXT,
    application_name TEXT
);
```
Essa estrutura está de acordo com o formato de log CSV que o PostgreSQL gera por padrão.



##  3. Criar um script para importar logs para a tabela
Você pode usar uma linguagem como Python ou um procedimento no próprio PostgreSQL (via função de leitura de arquivo) para ler o arquivo de log e inserir os dados na tabela.

### Exemplo usando Python:

``` usando python
import psycopg2
import csv
import os

# Conexão com o banco de dados PostgreSQL
conn = psycopg2.connect(
    dbname="seu_banco",
    user="seu_usuario",
    password="sua_senha",
    host="localhost"
)
cur = conn.cursor()

# Caminho para o arquivo de log gerado pelo PostgreSQL
log_file = '/caminho/para/os/logs/postgresql.log'

# Lê o arquivo CSV de log
with open(log_file, mode='r') as file:
    reader = csv.reader(file)
    next(reader)  # Pula o cabeçalho do CSV
    for row in reader:
        # Insere os dados lidos no arquivo de log para a tabela 'postgres_logs'
        cur.execute('''
            INSERT INTO postgres_logs (
                log_time, user_name, database_name, process_id, connection_from, 
                session_id, session_line_num, command_tag, session_start_time, 
                virtual_transaction_id, transaction_id, error_severity, sql_state_code, 
                message, detail, hint, internal_query, internal_query_pos, context, query, 
                query_pos, location, application_name
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        ''', row)

# Confirma a transação e fecha a conexão
conn.commit()
cur.close()
conn.close()
```


## 4. Agendar o script para rodar automaticamente

Você pode agendar esse script para ser executado periodicamente (por exemplo, a cada 5 minutos ou uma vez por dia) usando ferramentas de agendamento de tarefas, como:

### Cron no Linux:

```bash 
*/5 * * * * /caminho/para/seu/script/import_logs.py
```