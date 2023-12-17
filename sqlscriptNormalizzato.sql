REM   Script: Electricity Theft (w slash)
REM   start

REM   Script: Electricity Theft pre procedure 


REM   Chianese 


-- Create sequence persona
CREATE SEQUENCE seq_persona  
INCREMENT BY 1  
START WITH 1  
NOMAXVALUE  
NOMINVALUE  
NOCYCLE  
NOCACHE;


CREATE TABLE Fornitore(   
    p_iva int,   
    Nome VARCHAR(50) NOT NULL,   
    CONSTRAINT pk_fornitore PRIMARY KEY(p_iva)   
);

CREATE TABLE Posizione(    
    Provincia   VARCHAR(2),    
    Regione     VARCHAR(30) NOT NULL,    
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

CREATE TABLE Bolletta(   
    CodContratto INT,   
    Prezzo  DECIMAL NOT NULL,   
    Consumo DECIMAL NOT NULL,   
    Mese    INT NOT NULL,   
    Anno    INT NOT NULL,   
    Attiva  CHAR(1) DEFAULT 'N',  
    URL	VARCHAR(32),  
    CONSTRAINT pk_bolletta PRIMARY KEY(CodContratto, Mese, Anno),
    CONSTRAINT k_mese CHECK(Mese < 13 AND Mese > 0), 
    CONSTRAINT k_anno CHECK(Anno > 0) 
);

CREATE TABLE Erogazione(
    codContratto	INT NOT NULL,
    codFornitore	INT NOT NULL,
	CONSTRAINT pk_fornitura PRIMARY KEY(codContratto),
    CONSTRAINT fk_fornitura FOREIGN KEY(codContratto) REFERENCES Bolletta(CodContratto),
    CONSTRAINT fk_fornitore_fornitura FOREIGN KEY(codFornitore) REFERENCES Fornitore
);

CREATE TABLE Localizzazione(
    codContratto	INT NOT NULL,
    codPosizione	CHAR(2) NOT NULL,
    CONSTRAINT pk_localizzazione PRIMARY KEY(codContratto),
    CONSTRAINT fk_localizzazioe_contratto FOREIGN KEY(codContratto) REFERENCES Bolletta(CodContratto),
    CONSTRAINT fk_localizzazione_posizione FOREIGN KEY(codPosizione) REFERENCES Posizione(Provincia)
);

CREATE TABLE Inserimento(
    codContratto	INT NOT NULL,
    codPersona	INT NOT NULL,
    CONSTRAINT pk_Inserimento PRIMARY KEY(codContratto),
    CONSTRAINT fk_inserimento_contratto FOREIGN KEY(codContratto) REFERENCES Bolletta(CodContratto),
    CONSTRAINT fk_inserimento_persona FOREIGN KEY(codPersona) REFERENCES Persona(IdPersona)
);

-- CREATE COSTI MATERIALIZED VIEW
CREATE MATERIALIZED VIEW COSTI AS   
SELECT L.codProvincia, F.Nome, AVG(B.Prezzo)/AVG(B.Consumo)
FROM Bolletta B
JOIN Erogazione E on E.codContratto = B.CodContratto
JOIN Localizzazione L on L.codContratto = B.CodContratto
GROUP BY L.codProvincia

-- CREATE REGIONI MATERIALIZED VIEW
CREATE MATERIALIZED VIEW REGIONI AS  
SELECT REGIONE  
FROM POSIZIONE  
GROUP BY REGIONE  
ORDER BY REGIONE ASC;

-- CREATE attivazione bolletta PROCEDURE
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

-- CREATE elimina record PROCEDURE
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

-- CREATE update cost view TRIGGER
CREATE OR REPLACE TRIGGER trg_update_cost 
AFTER UPDATE ON BOLLETTA 
DECLARE 
    PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN 
	EXEC dbms_mview.refresh('COSTI');
	COMMIT; 
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

INSERT INTO FORNITORE VALUES (1, 'enel');

INSERT INTO FORNITORE VALUES (2, 'Fastweb');

INSERT INTO PERSONA VALUES (seq_persona.NEXTVAL, 'nick', 'name', 'surname', 0, 'SHA-256');

INSERT INTO Bolletta(CodContratto, Prezzo, Consumo, Mese, Anno, Fornitore, Persona, Posizione, URL)
VALUES (
    1,
    100.00, 
    150.00,
    1, 
    2023, 
    1, 
    seq_persona.CURRVAL, 
    'NA',
    'http://example.com/bolletta_1'
);


INSERT INTO Bolletta(CodContratto, Prezzo, Consumo, Mese, Anno, Fornitore, Persona, Posizione, URL)
VALUES (
    1,
    120.00,
    180.00, 
    2, 
    2023, 
    1, 
    seq_persona.CURRVAL, 
    'NA',
    'http://example.com/bolletta_1'
);


INSERT INTO PERSONA VALUES (seq_persona.NEXTVAL, 'nick2', 'name2', 'surname2', 0, 'SHA-256');


INSERT INTO Bolletta(CodContratto, Prezzo, Consumo, Mese, Anno, Fornitore, Persona, Posizione, URL)
VALUES (
    2,
    150.00,
    130.00, 
    1, 
    2023, 
    1, 
    seq_persona.CURRVAL, 
    'NA',
    'http://example.com/bolletta_1'
);


INSERT INTO Bolletta(CodContratto, Prezzo, Consumo, Mese, Anno, Fornitore, Persona, Posizione, URL)
VALUES (
    3,
    200.00,
    100.00, 
    1, 
    2023, 
    2, 
    seq_persona.CURRVAL, 
    'MI',
    'http://example.com/bolletta_1'
);


INSERT INTO PERSONA VALUES (seq_persona.NEXTVAL, 'nick3', 'name3', 'surname3', 1, 'SHA-256');


