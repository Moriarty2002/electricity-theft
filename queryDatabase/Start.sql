CREATE DATABASE ElectricalTheft;

USE ElectricalTheft;

CREATE TABLE Fornitore( 
    p_iva int, 
    Nome VARCHAR(50), 
    CONSTRAINT pk_fornitore PRIMARY KEY(p_iva) 
);

CREATE TABLE Posizione( 
    Provincia   VARCHAR(2), 
    Regione     VARCHAR(30), 
    CONSTRAINT pk_posizione PRIMARY KEY(Provincia) 
);

CREATE TABLE Persona( 
    IdPersona   INT, 
    NickName    VARCHAR(30),
    Nome        VARCHAR(30), 
    Cognome     VARCHAR(30), 
    TipologiaUtente BOOLEAN, 
    Password    VARCHAR(224), 
    CONSTRAINT pk_persona PRIMARY KEY(IdPersona) 
);

CREATE TABLE Bolletta( 
    CodUtente   INT, 
    Prezzo  DECIMAL, 
    Consumo DECIMAL, 
    Mese    INT, 
    Anno    INT, 
    Attiva  BOOLEAN, 
    Fornitore   INT, 
    Persona     INT, 
    Posizione   VARCHAR(2), 
    CONSTRAINT pk_bolletta PRIMARY KEY(CodUtente), 
    CONSTRAINT fk_fornitore FOREIGN KEY(Fornitore) REFERENCES Fornitore(p_iva), 
    CONSTRAINT fk_persona FOREIGN KEY(Persona) REFERENCES Persona(IdPersona), 
    CONSTRAINT fk_posizione FOREIGN KEY(Posizione) REFERENCES Posizione(Provincia)     
);