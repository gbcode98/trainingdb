
# Ideia inicial 

## capturar os logs gerados pelo PostgreSQL e inseri-los em uma tabela dentro do banco de dados,PostgreSQL por si só não tem uma função de leitura de arquivo embutida, e você precisaria usar extensões como file_fdw para criar uma tabela externa que aponta para o arquivo de log.


### 1. Instalar a extensão:

```
log_line_prefix = '%t [%p] user=%u, db=%d, client=%h, sess_id=%c, line=%l, cmd_tag=%i, sess_start=%s, vxid=%v, txid=%x, app=%a, location=%r, severity=%p'


# Habilitar logs de consultas lentas e erros detalhados
log_statement = 'all'               # Registrar todas as consultas
log_duration = on                   # Registrar a duração de cada consulta
log_error_verbosity = 'verbose'     # Incluir detalhes adicionais no log de erros
log_min_error_statement = 'error'   # Registrar a consulta SQL em caso de erro
log_min_messages = 'info'           # Registrar todas as mensagens de INFO para cima (INFO, WARNING, ERROR)

# Adiciona detalhes específicos às mensagens de erro
log_executor_stats = on             # Incluir estatísticas do executor nas mensagens de erro


CREATE EXTENSION file_fdw;

```


### 2. Criar um wrapper para ler o CSV:

```
CREATE SERVER pglog FOREIGN DATA WRAPPER file_fdw;

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
SERVER pglog
OPTIONS (filename '/caminho/para/os/logs/postgresql.log', format 'csv');
```


### 3. Mover dados para a tabela de logs:

```
INSERT INTO postgres_logs
SELECT * FROM postgres_log_file;
```


### Essa abordagem permite automatizar a inserção dos logs diretamente a partir dos arquivos de log gerados pelo PostgreSQL.


https://www.postgresql.org/docs/current/file-fdw.html




drop FOREIGN TABLE if exists psql_log_monday;
CREATE FOREIGN TABLE psql_log_monday (
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
    application_name TEXT,
    colum1 text
)
SERVER pglog
options (filename '/var/lib/postgresql/13/main/pg_log/postgresql-Mon.csv', format 'csv', delimiter ',');

alter foreign table psql_log_monday owner to radarsaude_write;
grant select on table psql_log_monday to radarsaude_read;

