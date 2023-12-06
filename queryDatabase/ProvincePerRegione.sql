USE ElectricalTheft;

SELECT Regione, COUNT(Provincia) AS Numero_Province
FROM Posizione
GROUP BY Regione;
