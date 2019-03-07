SELECT
    errors.error_code AS error_code,
    COUNT(1) AS occurences,
    MIN(errors.error_text) AS example_error
FROM
    (
     SELECT
        error_text,
        SUBSTR(error_text,
               INSTR(error_text, '[ERROR]'),
               INSTR(error_text, '|', INSTR(error_text, '[ERROR]')) - INSTR(error_text, '[ERROR]'))
        AS error_code
     FROM fif_isis_req WHERE error_text IS NOT NULL
    ) errors
GROUP BY error_code
ORDER BY occurences DESC;
