
# Ideia inicial 

## capturar os logs gerados pelo PostgreSQL e inseri-los em uma tabela dentro do banco de dados,PostgreSQL por si só não tem uma função de leitura de arquivo embutida, e você precisaria usar extensões como file_fdw para criar uma tabela externa que aponta para o arquivo de log.


### 1. Instalar a extensão:

```
CREATE EXTENSION file_fdw;
```


### 2. Criar um wrapper para ler o CSV:

```
CREATE FOREIGN TABLE postgres_log_file (
    log_time TEXT,
    user_name TEXT,
    database_name TEXT,
    process_id INT,
    connection_from TEXT,
    session_id TEXT,
    session_line_num BIGINT,
    command_tag TEXT,
    session_start_time TEXT,
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
)
SERVER file_server
OPTIONS (filename '/caminho/para/os/logs/postgresql.log', format 'csv');
```


### 3. Mover dados para a tabela de logs:

```
INSERT INTO postgres_logs
SELECT * FROM postgres_log_file;
```


### Essa abordagem permite automatizar a inserção dos logs diretamente a partir dos arquivos de log gerados pelo PostgreSQL.