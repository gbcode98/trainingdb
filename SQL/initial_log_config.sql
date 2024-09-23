---- 1. Função para localizar o arquivo


CREATE OR REPLACE FUNCTION get_latest_log_file() 
RETURNS TEXT AS $$
DECLARE
    log_file TEXT;
BEGIN
    -- Itera sobre os arquivos no diretório /data/postgresql/13/dbprocessor/pg_log/
    FOR log_file IN 
        SELECT pg_ls_dir('/data/postgresql/13/dbprocessor/pg_log/')
    LOOP
        -- Verifica se o nome do arquivo começa com 'postgresql-'
        IF log_file LIKE 'postgresql-%' THEN
            RETURN log_file;
        END IF;
    END LOOP;

    -- Se nenhum arquivo for encontrado, lançar um erro
    RAISE EXCEPTION 'Nenhum arquivo de log encontrado com prefixo postgresql-';
END;
$$ LANGUAGE plpgsql;



---- 2. Atualizar a FOREIGN TABLE dinamicamente

DO $$
DECLARE
    log_filename TEXT;
BEGIN
    -- Chama a função para obter o nome do arquivo de log
    log_filename := get_latest_log_file();

    -- Atualiza a FOREIGN TABLE dinamicamente
    EXECUTE format(
        'ALTER FOREIGN TABLE postgres_log_file OPTIONS (SET filename ''/data/postgresql/13/dbprocessor/pg_log/%s'')',
        log_filename
    );
END $$;





