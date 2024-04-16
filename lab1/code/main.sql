CREATE OR REPLACE PROCEDURE table_columns_info(schema_name TEXT, table_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    column_info RECORD;
    s_name TEXT := schema_name;
    t_name TEXT := table_name;

BEGIN
    RAISE NOTICE ' ';
    RAISE NOTICE 'Таблица: %', t_name;
    RAISE NOTICE ' ';
    RAISE NOTICE 'Схема: %', s_name;
    RAISE NOTICE ' ';
    RAISE NOTICE 'No.  Имя столбца      Атрибуты';
    RAISE NOTICE '---  --------------   -------------------------------------------------';

    FOR column_info IN
        SELECT
            att.attnum,  -- Номер столбца.
            att.attname,  -- Имя столбца.
            format_type(att.atttypid, att.atttypmod) AS typname,  -- Тип данных столбца.
            pg_catalog.col_description(att.attrelid, att.attnum) AS description,  -- Комментарий к столбцу.
            idx.indexrelid::regclass AS idxname  -- Имя индекса, если есть.
        FROM
            pg_attribute AS att
            JOIN pg_class AS tbl ON att.attrelid = tbl.oid
            JOIN pg_namespace AS ns ON tbl.relnamespace = ns.oid
            LEFT JOIN pg_index AS idx ON tbl.oid = idx.indrelid AND att.attnum = ANY(idx.indkey)
        WHERE
            tbl.relname = t_name
            AND att.attnum > 0
            AND ns.nspname = s_name
        ORDER BY
            att.attnum
    LOOP
        RAISE NOTICE '% % Type    :  %', RPAD(column_info.attnum::text, 5, ' '), RPAD(column_info.attname, 16, ' '), column_info.typname;
        RAISE NOTICE '% Commen  :  "%"', RPAD('⠀', 22, ' '), COALESCE(column_info.description, '');
        RAISE NOTICE '% Index   :  "%"', RPAD('⠀', 22, ' '), COALESCE(column_info.idxname::text, '');
        RAISE NOTICE ' ';
    END LOOP;
END;
$$;
