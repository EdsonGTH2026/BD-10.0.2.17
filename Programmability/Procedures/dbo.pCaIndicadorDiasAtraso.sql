SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCaIndicadorDiasAtraso] (@Fecha SmallDatetime) AS

Delete From tCsDiasAtraso
Where Fecha = @Fecha

INSERT INTO tCsDiasAtraso
                      (Fecha, CodUsuario, Saldo, DiasAtraso, CodAnterior)
SELECT     Fecha, CodUsuario, SUM(Saldo) AS Saldo, NroDiasAtraso, CodUsuario AS CodAnterior
FROM         (SELECT     tCsCartera.Fecha, tCsCartera.CodUsuario, SUM(tCsCartera.Saldo) AS Saldo, tCsCartera.NroDiasAtraso
                       FROM          (SELECT     tCsCarteraDet.Fecha, tCsCarteraDet.CodUsuario, 
                                                                      tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                                                       AS Saldo, tCsCartera.NroDiasAtraso
                                               FROM          tCsCarteraDet INNER JOIN
                                                                      tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                                               WHERE      (tCsCarteraDet.Fecha = @Fecha)) tCsCartera
                       WHERE      Fecha = @Fecha and Saldo > 0
                       GROUP BY tCsCartera.Fecha, tCsCartera.CodUsuario, tCsCartera.NroDiasAtraso) Grupo
GROUP BY Fecha, CodUsuario, NroDiasAtraso

UPDATE    tcsdiasatraso
SET              porcentaje = round(tcsdiasatraso.saldo / saldototal.Saldo, 4) * 100
FROM         (SELECT     Fecha, CodUsuario, SUM(Saldo) AS Saldo
                       FROM          tCsDiasAtraso
                       WHERE      (Fecha = @Fecha)
                       GROUP BY Fecha, CodUsuario) SaldoTotal INNER JOIN
                      tCsDiasAtraso ON SaldoTotal.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsDiasAtraso.CodUsuario AND SaldoTotal.Fecha = tCsDiasAtraso.Fecha

UPDATE    tCsDiasAtraso
SET       Acumulado = dbo.fduAPIDA(@Fecha, CodUsuario, DiasAtraso)
WHERE Fecha = @Fecha 

UPDATE    tcsdiasatraso
SET              aceptado = 1
FROM         (SELECT     Fecha, CodUsuario, MIN(Acumulado) AS Acumulado
                       FROM          tCsDiasAtraso
                       WHERE      (Acumulado >= 10)
                       GROUP BY Fecha, CodUsuario) Diez INNER JOIN
                      tCsDiasAtraso ON Diez.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsDiasAtraso.CodUsuario AND 
                      Diez.Acumulado = tCsDiasAtraso.Acumulado AND Diez.Fecha = tCsDiasAtraso.Fecha
Where tcsdiasatraso.Fecha = @Fecha

UPDATE    tCsDiasAtraso
SET              Aceptado = 0
WHERE     (Aceptado IS NULL) AND tcsdiasatraso.Fecha = @Fecha


UPDATE    tcsdiasatraso
SET              iatrasodia = listo.iatrasodia
FROM         (SELECT     Diez.*, tCsDiasAtraso.DiasAtraso, (CASE WHEN tCsDiasAtraso.DiasAtraso = 0 THEN 'A' WHEN tCsDiasAtraso.DiasAtraso > 0 AND 
                                              tCsDiasAtraso.DiasAtraso <= 8 THEN 'B' WHEN tCsDiasAtraso.DiasAtraso   > 8 AND 
                                              tCsDiasAtraso.DiasAtraso <= 15 THEN 'C' WHEN tCsDiasAtraso.DiasAtraso > 15 AND 
                                              tCsDiasAtraso.DiasAtraso <= 30 THEN 'D' WHEN tCsDiasAtraso.DiasAtraso > 30 AND 
                                              tCsDiasAtraso.DiasAtraso <= 60 THEN 'E' WHEN tCsDiasAtraso.DiasAtraso > 60 AND 
                                              tCsDiasAtraso.DiasAtraso <= 90 THEN 'F' WHEN tCsDiasAtraso.DiasAtraso > 90 THEN 'G' END) AS IAtrasoDia
                       FROM          (SELECT     Fecha, CodUsuario, MIN(Acumulado) AS Acumulado
                                               FROM          tCsDiasAtraso
                                               WHERE      (Acumulado >= 10)
                                               GROUP BY Fecha, CodUsuario) Diez INNER JOIN
                                              tCsDiasAtraso ON Diez.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsDiasAtraso.CodUsuario AND 
                                              Diez.Fecha = tCsDiasAtraso.Fecha AND Diez.Acumulado = tCsDiasAtraso.Acumulado) Listo INNER JOIN
                      tCsDiasAtraso ON Listo.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsDiasAtraso.CodUsuario AND Listo.Fecha = tCsDiasAtraso.Fecha
WHERE     tcsdiasatraso.fecha = @Fecha


Declare @CU Varchar(15)

Declare CurUser Cursor For

Select Distinct Codusuario
From tCsDiasAtraso
where Fecha = @Fecha

Open CurUser
Fetch Next From CurUser Into @CU

While @@Fetch_Status = 0 
Begin
	
	Update 	tCsDiasAtraso
	Set 	IAtrasoMes = dbo.fduCIDAM(@Fecha, @CU)
	Where   (tCsDiasAtraso.Fecha = @Fecha) and tCsDiasAtraso.CodUSuario = @CU
	
	Update 	tCsDiasAtraso
	Set 	IAtrasoAño = dbo.fduCIDAA(@Fecha, @CU)
	Where   (tCsDiasAtraso.Fecha = @Fecha) and tCsDiasAtraso.CodUSuario = @CU

Fetch Next From CurUser Into @CU
End
Close CurUser
Deallocate CurUSer

UPDATE    tcsdiasatraso
SET              codoficina = tcspadronclientes.codoficina
FROM         tCsDiasAtraso INNER JOIN
                      tCsPadronClientes ON tCsDiasAtraso.CodUsuario = tCsPadronClientes.CodUsuario
Where tcsdiasatraso.CodOficina Is null
GO