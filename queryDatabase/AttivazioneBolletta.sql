CREATE OR REPLACE PROCEDURE attivazione_bolletta
IS
    CURSOR curs IS SELECT * FROM BOLLETTA WHERE ATTIVA = 0;
    riga curs%ROWTYPE;
BEGIN
    OPEN curs;

    LOOP
        FETCH curs INTO riga;
        EXIT WHEN curs%NOTFOUND;

        UPDATE BOLLETTA
        SET ATTIVA = 1
        WHERE CODUTENTE = riga.CODUTENTE AND MESE = riga.MESE AND ANNO = riga.ANNO;

        DBMS_OUTPUT.PUT_LINE('Aggiornata bolletta: ' || riga.CODUTENTE);
    END LOOP;

    CLOSE curs;
END;