REM   Script: Electrical Theft Definitive
REM   w

REM   start 


REM   Script electrical theft - progetto Basi di Dati (prof. Chianese)


CREATE SEQUENCE seq_persona   
INCREMENT BY 1   
START WITH 1   
NOMAXVALUE   
NOMINVALUE   
NOCYCLE   
NOCACHE;

CREATE SEQUENCE seq_contratti 
INCREMENT BY 1 
START WITH 1 
NOMAXVALUE 
NOMINVALUE 
NOCYCLE 
NOCACHE;

CREATE TABLE Fornitore(    
    p_iva int,    
    Nome VARCHAR(50) NOT NULL,    
    Num_bollette NUMBER DEFAULT 0, 
     
    CONSTRAINT pk_fornitore PRIMARY KEY(p_iva)    
);

CREATE TABLE Posizione(     
    Provincia   VARCHAR(2),     
    Regione     VARCHAR(30) NOT NULL,        
    Num_bollette NUMBER DEFAULT 0, 
     
    CONSTRAINT pk_posizione PRIMARY KEY(Provincia)     
);

CREATE TABLE Persona(    
    IdPersona   INT DEFAULT seq_persona.NEXTVAL,    
    NickName    VARCHAR(30),   
    Nome        VARCHAR(30) NOT NULL,    
    Cognome     VARCHAR(30) NOT NULL,    
    TipologiaUtente CHAR(1) NOT NULL,    
    Password    VARCHAR(64), -- for SHA-256   
     
    CONSTRAINT pk_persona PRIMARY KEY(IdPersona)    
);

CREATE TABLE CONTRATTO( 
    CodContratto    INT DEFAULT seq_contratti.NEXTVAL, 
    Fornitore   INT, 
    Posizione   VARCHAR(2), 
    Persona INT, 
     
    CONSTRAINT pk_contratto PRIMARY KEY(CodContratto), 
    CONSTRAINT fk_contratto_fornitore FOREIGN KEY(Fornitore) REFERENCES FORNITORE(p_iva), 
    CONSTRAINT fk_contratto_posizione FOREIGN KEY(Posizione) REFERENCES POSIZIONE(Provincia), 
    CONSTRAINT fk_contratto_persona FOREIGN KEY(Persona) REFERENCES PERSONA(IdPersona) 
);

CREATE TABLE Bolletta(    
    CodContratto INT,    
    Prezzo  DECIMAL NOT NULL,    
    Consumo DECIMAL NOT NULL,    
    Mese    INT NOT NULL,    
    Anno    INT NOT NULL,    
    Attiva  CHAR(1) DEFAULT 'N',   
    URL	VARCHAR(32),   
     
    CONSTRAINT pk_bolletta PRIMARY KEY(CodContratto, Mese, Anno), 
    CONSTRAINT fk_bolletta_contratto FOREIGN KEY(CodContratto) REFERENCES CONTRATTO(CodContratto), 
    CONSTRAINT k_mese CHECK(Mese < 13 AND Mese > 0),  
    CONSTRAINT k_anno CHECK(Anno > 0) 
);

CREATE MATERIALIZED VIEW COSTI AS    
SELECT C.Posizione, F.Nome, TRUNC(SUM(B.Prezzo)/SUM(B.Consumo), 2) AS CONSUMO_IN_KWH 
FROM Bolletta B 
JOIN CONTRATTO C ON B.CodContratto = C.CodContratto 
JOIN FORNITORE F ON C.Fornitore = F.p_iva 
WHERE B.Attiva = 'Y' 
GROUP BY C.Posizione, F.Nome;

CREATE MATERIALIZED VIEW REGIONI AS   
SELECT REGIONE   
FROM POSIZIONE   
GROUP BY REGIONE   
ORDER BY REGIONE ASC;

CREATE OR REPLACE PROCEDURE attivazione_bolletta  
IS  
	CURSOR curs IS SELECT * FROM BOLLETTA WHERE ATTIVA = 'N';  
	riga curs%ROWTYPE;  
BEGIN  
	OPEN curs;  
  
	LOOP  
		FETCH curs INTO riga;  
		EXIT WHEN curs%NOTFOUND;  
  
		UPDATE BOLLETTA  
		SET ATTIVA = 'Y'  
		WHERE CODCONTRATTO = riga.CODCONTRATTO AND MESE = riga.MESE AND ANNO = riga.ANNO;  
  
		DBMS_OUTPUT.PUT_LINE('Aggiornata bolletta: ' || riga.CODCONTRATTO);  
	END LOOP;  
  
	CLOSE curs;  
END;  
/

CREATE OR REPLACE PROCEDURE elimina_record IS   
	CURSOR curs IS SELECT * FROM BOLLETTA WHERE to_char( sysdate, 'mm' ) > to_char(MESE) AND to_char( sysdate, 'yy' ) > to_char(ANNO);   
	riga curs%ROWTYPE;   
BEGIN   
	OPEN curs;   
   
	LOOP   
    	FETCH curs INTO riga;   
    	EXIT WHEN curs%NOTFOUND;   
   
    	DELETE FROM BOLLETTA WHERE riga.CODCONTRATTO = CODCONTRATTO AND riga.MESE = MESE AND riga.ANNO = ANNO;   
   
	END LOOP;   
END;   
/

CREATE OR REPLACE PROCEDURE prc_update_cost IS 
BEGIN 
    dbms_mview.refresh('COSTI'); 
END; 
/

CREATE OR REPLACE TRIGGER trg_insert_bolletta 
AFTER INSERT ON BOLLETTA 
FOR EACH ROW 
DECLARE  
    cod_fornitore CONTRATTO.FORNITORE%TYPE; 
	cod_posizione CONTRATTO.POSIZIONE%TYPE; 
BEGIN 
    IF (:NEW.ATTIVA = 'Y') THEN
	SELECT c.fornitore, c.posizione INTO cod_fornitore, cod_posizione 
    FROM CONTRATTO c  
    WHERE c.codContratto = :NEW.codContratto; 
     
    UPDATE FORNITORE f 
    SET f.NUM_BOLLETTE = (f.NUM_BOLLETTE + 1)  
    WHERE f.p_iva = cod_fornitore; 
 
	UPDATE POSIZIONE p 
    SET p.NUM_BOLLETTE = (p.NUM_BOLLETTE + 1)  
    WHERE p.PROVINCIA = cod_posizione; 
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_update_bolletta 
AFTER UPDATE OF ATTIVA ON BOLLETTA 
FOR EACH ROW 
DECLARE  
    cod_fornitore CONTRATTO.FORNITORE%TYPE; 
	cod_posizione CONTRATTO.POSIZIONE%TYPE; 
BEGIN 
    SELECT c.fornitore, c.posizione INTO cod_fornitore, cod_posizione 
    FROM CONTRATTO c  
    WHERE c.codContratto = :NEW.codContratto; 

    IF (:NEW.ATTIVA = 'Y') THEN
        UPDATE FORNITORE f 
        SET f.NUM_BOLLETTE = (f.NUM_BOLLETTE + 1)  
        WHERE f.p_iva = cod_fornitore; 
     
    	UPDATE POSIZIONE p 
        SET p.NUM_BOLLETTE = (p.NUM_BOLLETTE + 1)  
        WHERE p.PROVINCIA = cod_posizione; 
    ELSE
        UPDATE FORNITORE f 
    	SET f.NUM_BOLLETTE = (f.NUM_BOLLETTE - 1)  
        WHERE f.p_iva = cod_fornitore; 
     
        UPDATE POSIZIONE p 
        SET p.NUM_BOLLETTE = (p.NUM_BOLLETTE - 1)  
        WHERE p.PROVINCIA = cod_posizione;
	END IF;
END; 


CREATE OR REPLACE TRIGGER trg_delete_bolletta 
AFTER DELETE ON BOLLETTA 
FOR EACH ROW 
DECLARE  
    cod_fornitore CONTRATTO.FORNITORE%TYPE; 
	cod_posizione CONTRATTO.POSIZIONE%TYPE; 
BEGIN 
    IF (:OLD.attiva = 'Y') THEN
	SELECT c.fornitore, c.posizione INTO cod_fornitore, cod_posizione 
        FROM CONTRATTO c  
        WHERE c.codContratto = :OLD.codContratto; 
     
        UPDATE FORNITORE f 
        SET f.NUM_BOLLETTE = (f.NUM_BOLLETTE - 1)  
         WHERE f.p_iva = cod_fornitore; 
 
	UPDATE POSIZIONE p 
        SET p.NUM_BOLLETTE = (p.NUM_BOLLETTE - 1)  
        WHERE p.PROVINCIA = cod_posizione; 
    END IF;
END; 
/

INSERT INTO Posizione(Provincia, Regione) VALUES ('CH', 'Abruzzo');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AQ', 'Abruzzo');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PE', 'Abruzzo');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TE', 'Abruzzo');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AG', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CL', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CT', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('EN', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('ME', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PA', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RG', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SR', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TP', 'Sicilia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PZ', 'Basilicata');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MT', 'Basilicata');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CS', 'Calabria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('KR', 'Calabria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RC', 'Calabria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VV', 'Calabria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CZ', 'Calabria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('NA', 'Campania');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AV', 'Campania');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BN', 'Campania');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SA', 'Campania');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CE', 'Campania');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BO', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('FE', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('FC', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MO', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PR', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PC', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RA', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RE', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RN', 'Emilia-Romagna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('GO', 'Friuli-Venezia-Giulia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PN', 'Friuli-Venezia-Giulia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TS', 'Friuli-Venezia-Giulia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('UD', 'Friuli-Venezia-Giulia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RM', 'Lazio');

INSERT INTO Posizione(Provincia, Regione) VALUES ('FR', 'Lazio');

INSERT INTO Posizione(Provincia, Regione) VALUES ('LT', 'Lazio');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RI', 'Lazio');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VT', 'Lazio');

INSERT INTO Posizione(Provincia, Regione) VALUES ('GE', 'Liguria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('IM', 'Liguria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SP', 'Liguria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SV', 'Liguria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MI', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BG', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BS', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CO', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CR', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('LC', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('LO', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MB', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PV', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SO', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VA', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MR', 'Lombardia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AN', 'Marche');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AP', 'Marche');

INSERT INTO Posizione(Provincia, Regione) VALUES ('FM', 'Marche');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MC', 'Marche');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PU', 'Marche');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CB', 'Molise');

INSERT INTO Posizione(Provincia, Regione) VALUES ('IS', 'Molise');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AL', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AT', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BI', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CN', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('NO', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TO', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VB', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VC', 'Piemonte');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BA', 'Puglia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BT', 'Puglia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BR', 'Puglia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('FG', 'Puglia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('LE', 'Puglia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TA', 'Puglia');

INSERT INTO Posizione(Provincia, Regione) VALUES ('CA', 'Sardegna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('NU', 'Sardegna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('OR', 'Sardegna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SS', 'Sardegna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SU', 'Sardegna');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AR', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('FI', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('GR', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('LI', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('LU', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('MS', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PI', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PT', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PO', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('SI', 'Toscana');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BZ', 'Trentino Alto Adige');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TN', 'Trentino Alto Adige');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PG', 'Umbria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TR', 'Umbria');

INSERT INTO Posizione(Provincia, Regione) VALUES ('AO', 'Valle d*Aosta');

INSERT INTO Posizione(Provincia, Regione) VALUES ('BL', 'Veneto');

INSERT INTO Posizione(Provincia, Regione) VALUES ('PD', 'Veneto');

INSERT INTO Posizione(Provincia, Regione) VALUES ('RO', 'Veneto');

INSERT INTO Posizione(Provincia, Regione) VALUES ('TV', 'Veneto');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VE', 'Veneto');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VR', 'Veneto');

INSERT INTO Posizione(Provincia, Regione) VALUES ('VI', 'Veneto');

INSERT INTO FORNITORE(p_iva, nome) VALUES (1, 'enel');

INSERT INTO FORNITORE(p_iva, nome) VALUES (2, 'Fastweb');

INSERT INTO PERSONA VALUES (seq_persona.NEXTVAL, 'nick2', 'name2', 'surname2', 0, 'SHA-256');

INSERT INTO CONTRATTO(CodContratto, Fornitore, Persona, Posizione) 
VALUES( 
    seq_contratti.NEXTVAL, 
    1,  
    seq_persona.CURRVAL,  
    'NA' 
);

INSERT INTO CONTRATTO (CodContratto, Fornitore, Persona, Posizione) 
VALUES( 
    seq_contratti.NEXTVAL, 
    2,  
    seq_persona.CURRVAL,  
    'MI' 
);

INSERT INTO Bolletta(CodContratto, Prezzo, Consumo, Mese, Anno, URL) 
VALUES ( 
    2, 
    150.00, 
    130.00,  
    1, 
    2023, 
    'http://example.com/bolletta_1' 
);

INSERT INTO Bolletta(CodContratto, Prezzo, Consumo, Mese, Anno, URL) 
VALUES ( 
    1, 
    200.00, 
    100.00,  
    1,  
    2023, 
    'http://example.com/bolletta_1' 
);

INSERT INTO PERSONA VALUES (seq_persona.NEXTVAL, 'nick3', 'name3', 'surname3', 1, 'SHA-256');

SELECT * FROM BOLLETTA;

SELECT * FROM PERSONA;

SELECT * FROM COSTI;

EXEC attivazione_bolletta()


EXEC prc_update_cost()


SELECT * FROM COSTI;

SELECT * FROM FORNITORE;

SELECT * FROM POSIZIONE WHERE NUM_BOLLETTE <> 0;

