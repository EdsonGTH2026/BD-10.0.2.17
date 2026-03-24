SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[pCsCaSegurosAtlasActiva]
(@Periodo as varchar(6))

--Declare @Periodo Varchar(6)
AS

--Set @Periodo = '201302'

---------------------------------------
Declare @Archivo		Varchar(50)
Declare @Corte			SmallDateTime
Declare @CodAseguradora Varchar(2)
Declare @Producto		Int
Declare @Codigo			Varchar(100)

Set @CodAseguradora		= '02'
Set @Producto			= 1

Set @Corte				= DateAdd(Day, - 1, DateAdd(Month, 1, Cast(@Periodo + '01' As SmallDateTime)))

UPDATE    tCsCartera
SET              MontoDesembolso = Datos.MontoDesembolso
FROM         (SELECT     Fecha, CodPrestamo, SUM(MontoDesembolso) AS MontoDesembolso
                       FROM          tCsCarteraDet
                       WHERE      (Fecha = @Corte)
                       GROUP BY Fecha, CodPrestamo) Datos INNER JOIN
                      tCsCartera ON Datos.Fecha = tCsCartera.Fecha AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo

Delete from tcsseguros
Where CodAseguradora+ CodOficina+ NumPoliza in (
SELECT     tCsSeguros_1.CodAseguradora+ tCsSeguros_1.CodOficina+ tCsSeguros_1.NumPoliza
FROM         tCsSeguros AS tCsSeguros_1 INNER JOIN
                          (SELECT     CodAseguradora, NumPoliza
                            FROM          tCsSeguros
                            WHERE      (CodAseguradora = @CodAseguradora) AND (CodProdSeguro = @Producto)
                            GROUP BY CodAseguradora, NumPoliza
                            HAVING      (COUNT(*) > 1)) AS Filtro ON tCsSeguros_1.NumPoliza = Filtro.NumPoliza AND tCsSeguros_1.CodAseguradora = Filtro.CodAseguradora LEFT OUTER JOIN
                      tCsSegurosBene ON tCsSeguros_1.CodAseguradora = tCsSegurosBene.CodAseguradora AND tCsSeguros_1.CodOficina = tCsSegurosBene.CodOficina AND 
                      tCsSeguros_1.NumPoliza = tCsSegurosBene.NumPoliza
WHERE     (tCsSegurosBene.CodUsuario IS NULL))

DELETE FROM tCsSegurosBene
WHERE     ((CodAseguradora + CodOficina + NumPoliza + CodUsuario) IN
                          (SELECT     tCsSegurosBene.CodAseguradora + tCsSegurosBene.CodOficina + tCsSegurosBene.NumPoliza + tCsSegurosBene.CodUsuario AS Expr1
                            FROM          tCsSegurosBene INNER JOIN
                                                   tCsSeguros ON tCsSegurosBene.CodAseguradora = tCsSeguros.CodAseguradora AND tCsSegurosBene.CodOficina = tCsSeguros.CodOficina AND 
                                                   tCsSegurosBene.NumPoliza = tCsSeguros.NumPoliza
                            WHERE      (tCsSegurosBene.NumPoliza IN
                                                       (SELECT     NumPoliza
                                                         FROM          (SELECT     tCsSegurosBene_1.CodAseguradora, tCsSegurosBene_1.CodOficina, tCsSegurosBene_1.NumPoliza, 
                                                                                                        tCsSegurosBene_1.CodUsuario, tCsSegurosBene_1.codparentesco
                                                                                 FROM          tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                                                                        tCsSegurosBene AS tCsSegurosBene_1 ON tCsSeguros_1.CodAseguradora = tCsSegurosBene_1.CodAseguradora AND 
                                                                                                        tCsSeguros_1.CodOficina = tCsSegurosBene_1.CodOficina AND 
                                                                                                        tCsSeguros_1.NumPoliza = tCsSegurosBene_1.NumPoliza
                                                                                 WHERE      (tCsSeguros_1.CodAseguradora = @CodAseguradora) AND (tCsSeguros_1.CodProdSeguro = @Producto)) AS Datos
                                                         GROUP BY NumPoliza
                                                         HAVING      (COUNT(*) > 1))) AND (tCsSeguros.CodAseguradora = @CodAseguradora) AND (tCsSeguros.fecha <= @Corte) AND (tCsSeguros.CodProdSeguro = @Producto) AND 
                                                   (tCsSegurosBene.codparentesco IS NULL) AND (tCsSegurosBene.porcentaje IS NULL)))    


DELETE FROM tCsSegurosBene
WHERE     ((CodAseguradora + CodOficina + NumPoliza + CodUsuario) IN
                          (SELECT     Datos_2.Codigo
                            FROM          (SELECT     NumPoliza
                                                    FROM          (SELECT     tCsSegurosBene.CodAseguradora + tCsSegurosBene.CodOficina + tCsSegurosBene.NumPoliza + tCsSegurosBene.CodUsuario AS Codigo,
                                                                                                    tCsSegurosBene.CodAseguradora, tCsSegurosBene.CodOficina, tCsSegurosBene.NumPoliza, tCsSegurosBene.CodUsuario, 
                                                                                                   tCsSegurosBene.orden, tCsSegurosBene.porcentaje, tCsSegurosBene.nombrecompleto, tCsSegurosBene.codparentesco, 
                                                                                                   CASE WHEN tCsPadronClientes.NombreCompleto IS NULL THEN 0 ELSE 1 END AS C
                                                                            FROM          tCsSegurosBene INNER JOIN
                                                                                                   tCsSeguros ON tCsSegurosBene.CodAseguradora = tCsSeguros.CodAseguradora AND 
                                                                                                   tCsSegurosBene.CodOficina = tCsSeguros.CodOficina AND tCsSegurosBene.NumPoliza = tCsSeguros.NumPoliza LEFT OUTER JOIN
                                                                                                   tCsPadronClientes ON tCsSegurosBene.CodUsuario = tCsPadronClientes.CodOrigen
                                                                            WHERE      (tCsSegurosBene.NumPoliza IN
                                                                                                       (SELECT     NumPoliza
                                                                                                         FROM          (SELECT     tCsSegurosBene_1.CodAseguradora, tCsSegurosBene_1.CodOficina, tCsSegurosBene_1.NumPoliza, 
                                                                                                                                                        tCsSegurosBene_1.CodUsuario, tCsSegurosBene_1.codparentesco
                                                                                                                                 FROM          tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                                                                                                                        tCsSegurosBene AS tCsSegurosBene_1 ON 
                                                                                                                                                        tCsSeguros_1.CodAseguradora = tCsSegurosBene_1.CodAseguradora AND 
                                                                                                                                                        tCsSeguros_1.CodOficina = tCsSegurosBene_1.CodOficina AND 
                                                                                                                                                        tCsSeguros_1.NumPoliza = tCsSegurosBene_1.NumPoliza
                                                                                                                                 WHERE      (tCsSeguros_1.CodAseguradora = @CodAseguradora) AND (tCsSeguros_1.CodProdSeguro = @Producto)) AS Datos
                                                                                                         GROUP BY NumPoliza
                                                                                                         HAVING      (COUNT(*) > 1))) AND (tCsSeguros.CodAseguradora = @CodAseguradora) AND (tCsSeguros.fecha <= @Corte) AND 
                                                                                                   (tCsSeguros.CodProdSeguro = @Producto)) AS Datos
                                                    GROUP BY NumPoliza
                                                    HAVING      (SUM(C) = 1)) AS Filtro INNER JOIN
                                                       (SELECT     tCsSegurosBene_2.CodAseguradora + tCsSegurosBene_2.CodOficina + tCsSegurosBene_2.NumPoliza + tCsSegurosBene_2.CodUsuario AS
                                                                                 Codigo, tCsSegurosBene_2.CodAseguradora, tCsSegurosBene_2.CodOficina, tCsSegurosBene_2.NumPoliza, 
                                                                                tCsSegurosBene_2.CodUsuario, tCsSegurosBene_2.orden, tCsSegurosBene_2.porcentaje, tCsSegurosBene_2.nombrecompleto, 
                                                                                tCsSegurosBene_2.codparentesco, CASE WHEN tCsPadronClientes_1.NombreCompleto IS NULL THEN 0 ELSE 1 END AS C
                                                         FROM          tCsSegurosBene AS tCsSegurosBene_2 INNER JOIN
                                                                                tCsSeguros AS tCsSeguros_2 ON tCsSegurosBene_2.CodAseguradora = tCsSeguros_2.CodAseguradora AND 
                                                                                tCsSegurosBene_2.CodOficina = tCsSeguros_2.CodOficina AND 
                                                                                tCsSegurosBene_2.NumPoliza = tCsSeguros_2.NumPoliza LEFT OUTER JOIN
                                                                                tCsPadronClientes AS tCsPadronClientes_1 ON tCsSegurosBene_2.CodUsuario = tCsPadronClientes_1.CodOrigen
                                                         WHERE      (tCsSegurosBene_2.NumPoliza IN
                                                                                    (SELECT     NumPoliza
                                                                                      FROM          (SELECT     tCsSegurosBene_1.CodAseguradora, tCsSegurosBene_1.CodOficina, tCsSegurosBene_1.NumPoliza, 
                                                                                                                                     tCsSegurosBene_1.CodUsuario, tCsSegurosBene_1.codparentesco
                                                                                                              FROM          tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                                                                                                     tCsSegurosBene AS tCsSegurosBene_1 ON 
                                                                                                                                     tCsSeguros_1.CodAseguradora = tCsSegurosBene_1.CodAseguradora AND 
                                                                                                                                     tCsSeguros_1.CodOficina = tCsSegurosBene_1.CodOficina AND 
                                                                                                                                     tCsSeguros_1.NumPoliza = tCsSegurosBene_1.NumPoliza
                                                                                                              WHERE      (tCsSeguros_1.CodAseguradora = @CodAseguradora) AND (tCsSeguros_1.CodProdSeguro = @Producto)) AS Datos_1
                                                                                      GROUP BY NumPoliza
                                                                                      HAVING      (COUNT(*) > 1))) AND (tCsSeguros_2.CodAseguradora = @CodAseguradora) AND (tCsSeguros_2.fecha <= @Corte) AND 
                                                                                (tCsSeguros_2.CodProdSeguro = @Producto)) AS Datos_2 ON Filtro.NumPoliza = Datos_2.NumPoliza
                            WHERE      (Datos_2.C = 0)))



DELETE FROM tCsSegurosBene
WHERE     ((CodAseguradora + CodOficina + NumPoliza + CodUsuario) IN (
SELECT     tCsSegurosBene_3.CodAseguradora+ tCsSegurosBene_3.CodOficina+ tCsSegurosBene_3.NumPoliza+ tCsSegurosBene_3.CodUsuario
FROM         (SELECT     CodAseguradora, NumPoliza, MIN(dbo.fduRellena('0', codparentesco, 2, 'D') + CodUsuario) AS C
                       FROM          tCsSegurosBene
                       WHERE      (NumPoliza IN
                                                  (SELECT     Datos_2.NumPoliza
                                                    FROM          (SELECT     NumPoliza, MIN(Importancia) AS I
                                                                            FROM          (SELECT     tCsSegurosBene_4.CodAseguradora + tCsSegurosBene_4.CodOficina + tCsSegurosBene_4.NumPoliza + tCsSegurosBene_4.CodUsuario
                                                                                                                            AS Codigo, tCsSegurosBene_4.CodAseguradora, tCsSegurosBene_4.CodOficina, tCsSegurosBene_4.NumPoliza, 
                                                                                                                           tCsSegurosBene_4.CodUsuario, tCsSegurosBene_4.orden, tCsSegurosBene_4.porcentaje, 
                                                                                                                           tCsSegurosBene_4.nombrecompleto, tCsSegurosBene_4.codparentesco, tCsClParentesco.Importancia
                                                                                                    FROM          tCsSegurosBene AS tCsSegurosBene_4 INNER JOIN
                                                                                                                           tCsSeguros ON tCsSegurosBene_4.CodAseguradora = tCsSeguros.CodAseguradora AND 
                                                                                                                           tCsSegurosBene_4.CodOficina = tCsSeguros.CodOficina AND 
                                                                                                                           tCsSegurosBene_4.NumPoliza = tCsSeguros.NumPoliza INNER JOIN
                                                                                                                           tCsClParentesco ON tCsSegurosBene_4.codparentesco = tCsClParentesco.CodParentesco
                                                                                                    WHERE      (tCsSegurosBene_4.NumPoliza IN
                                                                                                                               (SELECT     NumPoliza
                                                                                                                                 FROM          (SELECT     tCsSegurosBene_1.CodAseguradora, tCsSegurosBene_1.CodOficina, 
                                                                                                                                                                                tCsSegurosBene_1.NumPoliza, tCsSegurosBene_1.CodUsuario, 
                                                                                                                                                                                tCsSegurosBene_1.codparentesco
                                                                                                                                                         FROM          tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                                                                                                                                                tCsSegurosBene AS tCsSegurosBene_1 ON 
                                                                                                                                                                                tCsSeguros_1.CodAseguradora = tCsSegurosBene_1.CodAseguradora AND 
                                                                                                                                                                                tCsSeguros_1.CodOficina = tCsSegurosBene_1.CodOficina AND 
                                                                                                                                                                                tCsSeguros_1.NumPoliza = tCsSegurosBene_1.NumPoliza
                                                                                                                                                         WHERE      (tCsSeguros_1.CodAseguradora = @CodAseguradora) AND (tCsSeguros_1.CodProdSeguro = @Producto)) 
                                                                                                                                                        AS Datos_3
                                                                                                                                 GROUP BY NumPoliza
                                                                                                                                 HAVING      (COUNT(*) > 1))) AND (tCsSeguros.CodAseguradora = @CodAseguradora) AND (tCsSeguros.fecha <= @Corte) AND 
                                                                                                                           (tCsSeguros.CodProdSeguro = @Producto)) AS Datos_4
                                                                            GROUP BY NumPoliza) AS Filtro INNER JOIN
                                                                               (SELECT     tCsSegurosBene_2.CodAseguradora + tCsSegurosBene_2.CodOficina + tCsSegurosBene_2.NumPoliza + tCsSegurosBene_2.CodUsuario
                                                                                                         AS Codigo, tCsSegurosBene_2.CodAseguradora, tCsSegurosBene_2.CodOficina, tCsSegurosBene_2.NumPoliza, 
                                                                                                        tCsSegurosBene_2.CodUsuario, tCsSegurosBene_2.orden, tCsSegurosBene_2.porcentaje, tCsSegurosBene_2.nombrecompleto, 
                                                                                                        tCsSegurosBene_2.codparentesco, tCsClParentesco_1.Importancia
                                                                                 FROM          tCsSegurosBene AS tCsSegurosBene_2 INNER JOIN
                                                                                                        tCsSeguros AS tCsSeguros_2 ON tCsSegurosBene_2.CodAseguradora = tCsSeguros_2.CodAseguradora AND 
                                                                                                        tCsSegurosBene_2.CodOficina = tCsSeguros_2.CodOficina AND 
                                                                                                        tCsSegurosBene_2.NumPoliza = tCsSeguros_2.NumPoliza INNER JOIN
                                                                                                        tCsClParentesco AS tCsClParentesco_1 ON tCsSegurosBene_2.codparentesco = tCsClParentesco_1.CodParentesco
                                                                                 WHERE      (tCsSegurosBene_2.NumPoliza IN
                                                                                                            (SELECT     NumPoliza
                                                                                                              FROM          (SELECT     tCsSegurosBene_1.CodAseguradora, tCsSegurosBene_1.CodOficina, tCsSegurosBene_1.NumPoliza, 
                                                                                                                                                             tCsSegurosBene_1.CodUsuario, tCsSegurosBene_1.codparentesco
                                                                                                                                      FROM          tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                                                                                                                             tCsSegurosBene AS tCsSegurosBene_1 ON 
                                                                                                                                                             tCsSeguros_1.CodAseguradora = tCsSegurosBene_1.CodAseguradora AND 
                                                                                                                                                             tCsSeguros_1.CodOficina = tCsSegurosBene_1.CodOficina AND 
                                                                                                                                                             tCsSeguros_1.NumPoliza = tCsSegurosBene_1.NumPoliza
                                                                                                                                      WHERE      (tCsSeguros_1.CodAseguradora = @CodAseguradora) AND (tCsSeguros_1.CodProdSeguro = @Producto)) AS Datos_1
                                                                                                              GROUP BY NumPoliza
                                                                                                              HAVING      (COUNT(*) > 1))) AND (tCsSeguros_2.CodAseguradora = @CodAseguradora) AND (tCsSeguros_2.fecha <= @Corte) AND 
                                                                                                        (tCsSeguros_2.CodProdSeguro = @Producto)) AS Datos_2 ON Filtro.NumPoliza = Datos_2.NumPoliza AND 
                                                                           Filtro.I = Datos_2.Importancia
                                                    GROUP BY Datos_2.NumPoliza
                                                    HAVING      (COUNT(*) = 1))) AND (CodAseguradora = @CodAseguradora)
                       GROUP BY CodAseguradora, NumPoliza) AS Datos INNER JOIN
                      tCsSegurosBene AS tCsSegurosBene_3 ON Datos.CodAseguradora = tCsSegurosBene_3.CodAseguradora AND substring(Datos.C, 3, 20) = tCsSegurosBene_3.CodUsuario AND 
                      Datos.NumPoliza = tCsSegurosBene_3.NumPoliza         ))                                                       


 DELETE FROM tCsSegurosBene
WHERE     ((CodAseguradora + CodOficina + NumPoliza + CodUsuario) IN (
 SELECT     tCsSegurosBene.CodAseguradora +  tCsSegurosBene.CodOficina + tCsSegurosBene.NumPoliza + tCsSegurosBene.CodUsuario
FROM         (SELECT     CodAseguradora, NumPoliza, MAX(CodUsuario) AS U
                       FROM          (SELECT     tCsSegurosBene_4.CodAseguradora + tCsSegurosBene_4.CodOficina + tCsSegurosBene_4.NumPoliza + tCsSegurosBene_4.CodUsuario AS Codigo,
                                                                       tCsSegurosBene_4.CodAseguradora, tCsSegurosBene_4.CodOficina, tCsSegurosBene_4.NumPoliza, tCsSegurosBene_4.CodUsuario, 
                                                                      tCsSegurosBene_4.orden, tCsSegurosBene_4.porcentaje, tCsSegurosBene_4.nombrecompleto, tCsSegurosBene_4.codparentesco, 
                                                                      tCsClParentesco.Importancia
                                               FROM          tCsSegurosBene AS tCsSegurosBene_4 INNER JOIN
                                                                      tCsSeguros ON tCsSegurosBene_4.CodAseguradora = tCsSeguros.CodAseguradora AND 
                                                                      tCsSegurosBene_4.CodOficina = tCsSeguros.CodOficina AND tCsSegurosBene_4.NumPoliza = tCsSeguros.NumPoliza INNER JOIN
                                                                      tCsClParentesco ON tCsSegurosBene_4.codparentesco = tCsClParentesco.CodParentesco
                                               WHERE      (tCsSegurosBene_4.NumPoliza IN
                                                                          (SELECT     NumPoliza
                                                                            FROM          (SELECT     tCsSegurosBene_1.CodAseguradora, tCsSegurosBene_1.CodOficina, tCsSegurosBene_1.NumPoliza, 
                                                                                                                           tCsSegurosBene_1.CodUsuario, tCsSegurosBene_1.codparentesco
                                                                                                    FROM          tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                                                                                           tCsSegurosBene AS tCsSegurosBene_1 ON tCsSeguros_1.CodAseguradora = tCsSegurosBene_1.CodAseguradora AND 
                                                                                                                           tCsSeguros_1.CodOficina = tCsSegurosBene_1.CodOficina AND 
                                                                                                                           tCsSeguros_1.NumPoliza = tCsSegurosBene_1.NumPoliza
                                                                                                    WHERE      (tCsSeguros_1.CodAseguradora = @CodAseguradora) AND (tCsSeguros_1.CodProdSeguro = @Producto)) AS Datos_3
                                                                            GROUP BY NumPoliza
                                                                            HAVING      (COUNT(*) > 1))) AND (tCsSeguros.CodAseguradora = @CodAseguradora) AND (tCsSeguros.fecha <= @Corte) AND 
                                                                      (tCsSeguros.CodProdSeguro = @Producto)) AS Datos
                       GROUP BY NumPoliza, CodAseguradora) AS Filtro INNER JOIN
                      tCsSegurosBene ON Filtro.CodAseguradora = tCsSegurosBene.CodAseguradora AND Filtro.NumPoliza = tCsSegurosBene.NumPoliza AND 
                      Filtro.U = tCsSegurosBene.CodUsuario   ))                                                    
/*
Declare CurCarta Cursor For 
	SELECT DISTINCT tCsCarteraDet.CodPrestamo + '-' + dbo.fduRellena('0', tCsPadronClientes.CodOrigen, 13, 'D') AS Codigo
	FROM            tCsPadronClientes LEFT OUTER JOIN
								 (SELECT        codaseguradora, codoficina, numpoliza, fecha, hora, codprodseguro, codusuarioase, codusuariopag, montoprima, montoseguro, estado, 
															 nombrecompleto, usuario, nombrecliente, InterruLab, Enfermo, Ocupacion, Direccion, Telefono, incorporado, idace, error, Firma
								   FROM            tCsSeguros AS tCsSeguros_1
								   WHERE        (codaseguradora = @CodAseguradora) AND (codprodseguro = @Producto)) AS tCsSeguros ON dbo.fduRellena('0', tCsPadronClientes.CodOrigen, 13, 'D') 
							 = tCsSeguros.numpoliza RIGHT OUTER JOIN
							 tCsCartera INNER JOIN
							 tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo ON 
							 tCsPadronClientes.CodUsuario = tCsCarteraDet.CodUsuario
	WHERE        (tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA')) AND (tCsCartera.Fecha = @Corte) AND (tCsSeguros.fecha IS NULL)
Open CurCarta
Fetch Next From CurCarta Into @Codigo
While @@Fetch_Status = 0
Begin
	Exec pCsSeguros1 2, 'KVALERA', @Codigo	
Fetch Next From CurCarta Into  @Codigo
End 
Close 		CurCarta
Deallocate 	CurCarta
*/

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HHHH]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin DROP TABLE [dbo].[HHHH] End

CREATE TABLE [dbo].[HHHH](
	[Cadena] [varchar](8000) NULL,
	[TipoRegistro] [varchar](1) NOT NULL,
	[FolioPoliza] [varchar](2004) NULL,
	[NoSocio] [varchar](25) NULL,
	[NombreAsegurado] [varchar](80) NULL,
	[PaternoAsegurado] [varchar](50) NULL,
	[MaternoAsegurado] [varchar](50) NULL,
	[Genero] [varchar](1) NULL,
	[RFC] [varchar](20) NULL,
	[IngresoSeguro] [varchar](50) NULL,
	[FechaRegistro] [varchar](50) NOT NULL,
	[MontoCredito] [decimal](38, 6) NULL,
	[PlazoCredito] [varchar](3) NULL,
	[ClaveSucursal] [varchar](4) NULL,
	[NombreBeneficiario] [varchar](80) NOT NULL,
	[PaternoBeneficiario] [varchar](50) NOT NULL,
	[MaternoBeneficiario] [varchar](50) NOT NULL,
	[Parentesco] [varchar](2) NULL,
	[Porcentaje] [varchar](3) NOT NULL
) ON [PRIMARY]

Insert Into HHHH
SELECT  Distinct TipoRegistro + '|' + FolioPoliza + '|' + NoSocio + '|' + NombreAsegurado + '|' + PaternoAsegurado + '|' + MaternoAsegurado + '|' + Genero + '|' + RFC + '|' + IngresoSeguro
                       + '|' + FechaRegistro + '|' + LTRIM(RTRIM(REPLACE(LEFT(STR(MontoCredito, 20, 2), 20), '.', ''))) 
                      + '|' + PlazoCredito + '|' + ClaveSucursal/* + '|' + NombreBeneficiario + '|' + PaternoBeneficiario + '|' + MaternoBeneficiario + '|' + Parentesco + '|' + Porcentaje + '|'*/ AS Cadena,
                       TipoRegistro, FolioPoliza, NoSocio, NombreAsegurado, PaternoAsegurado, MaternoAsegurado, Genero, RFC, IngresoSeguro, FechaRegistro, MontoCredito, 
                      PlazoCredito, ClaveSucursal, NombreBeneficiario, PaternoBeneficiario, MaternoBeneficiario, Parentesco, Porcentaje
FROM         (SELECT     '1' AS TipoRegistro, @CodAseguradora + '-' + dbo.fduRellena('0', @Producto, 3, 'D') + '-' + dbo.fduRellena('0', LTRIM(RTRIM(tCsPadronClientes.CodOrigen)), 
                                              13, 'D') AS FolioPoliza, LTRIM(RTRIM(tCsCarteraDet.CodUsuario)) AS NoSocio, tCsPadronClientes.Nombres AS NombreAsegurado, 
                                              tCsPadronClientes.Paterno AS PaternoAsegurado, tCsPadronClientes.Materno AS MaternoAsegurado, tUsClSexo.INTF AS Genero, 
                                              ISNULL(dbo.fduFechaATexto(tCsPadronClientes.FechaNacimiento, 'AAAAMMDD'), '') AS RFC, ISNULL(dbo.fduFechaATexto(Registro.Desembolso, 
                                              'AAAAMMDD'), '') AS IngresoSeguro, ISNULL(dbo.fduFechaATexto(@Corte, 'AAAAMMDD'), '') AS FechaRegistro, 
                                              --ROUND(tCsCartera.SaldoCapital,2) AS MontoCredito, CAST(DATEDIFF(Month, MIN(tCsCartera.FechaDesembolso), MAX(tCsCartera.FechaVencimiento)) 
                                              ROUND(SUM((tCsCarteraDet.MontoDesembolso / tCsCartera.MontoDesembolso) 
                                              * (tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + tCsCartera.CargoMora + tCsCartera.OtrosCargos
                                               + tCsCartera.Impuestos)), 2) AS MontoCredito, CAST(DATEDIFF(Month, MIN(tCsCartera.FechaDesembolso), MAX(tCsCartera.FechaVencimiento)) 
                                              --ROUND(tCsCartera.SaldoCapital AS MontoCredito, CAST(DATEDIFF(Month, MIN(tCsCartera.FechaDesembolso), MAX(tCsCartera.FechaVencimiento)) 
                                              AS Varchar(3)) AS PlazoCredito, MIN(tCsCartera.CodOficina) AS ClaveSucursal, ISNULL(ISNULL(tCsPadronClientes_1.Nombres, 
                                              tCsPadronClientes_2.Nombres), '') AS NombreBeneficiario, ISNULL(ISNULL(tCsPadronClientes_1.Paterno, tCsPadronClientes_2.Paterno), '') 
                                              AS PaternoBeneficiario, ISNULL(ISNULL(tCsPadronClientes_1.Materno, tCsPadronClientes_2.Materno), '') AS MaternoBeneficiario, 
                                              CASE WHEN ISNULL(ISNULL(tCsPadronClientes_1.Nombres, tCsPadronClientes_2.Nombres), '') = '' THEN '' WHEN tCsClParentesco.Atlas IS NULL 
                                              THEN '8' ELSE CAST(tCsClParentesco.Atlas AS Varchar(2)) END AS Parentesco, CASE WHEN ISNULL(ISNULL(tCsPadronClientes_1.Nombres, 
                                              tCsPadronClientes_2.Nombres), '') = '' THEN '' ELSE '100' END AS Porcentaje
                       FROM          (SELECT     CodUsuario, MIN(Desembolso) AS Desembolso
                                               FROM          tCsPadronCarteraDet
                                               WHERE      (CarteraOrigen IN ('ACTIVA', 'ADMINISTRATIVA'))--('CASTIGADA'))
                                               GROUP BY CodUsuario) AS Registro RIGHT OUTER JOIN
                                              tCsCartera INNER JOIN
                                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo ON 
                                              Registro.CodUsuario = tCsCarteraDet.CodUsuario LEFT OUTER JOIN
                                              tCsPadronClientes AS tCsPadronClientes_2 RIGHT OUTER JOIN
                                              tUsClSexo INNER JOIN
                                              tCsPadronClientes ON tUsClSexo.Sexo = tCsPadronClientes.Sexo ON tCsPadronClientes_2.CodUsuario = tCsPadronClientes.CodConyuge LEFT OUTER JOIN
                                              tCsSegurosBene LEFT OUTER JOIN
                                              tCsClParentesco ON tCsSegurosBene.codparentesco = tCsClParentesco.codparentesco LEFT OUTER JOIN
                                              tCsPadronClientes AS tCsPadronClientes_1 ON tCsSegurosBene.CodUsuario = tCsPadronClientes_1.CodOrigen RIGHT OUTER JOIN
                                                  (SELECT DISTINCT  CodAseguradora, CodOficina, NumPoliza, codprodseguro, codusuarioase, codusuariopag, montoprima, montoseguro, estado, 
                                                                           nombrecompleto, nombrecliente, InterruLab, Enfermo, Ocupacion, Direccion, Telefono, incorporado, idace, error, Fecha
                                                    FROM          tCsSeguros AS tCsSeguros_1
                                                    WHERE      (CodAseguradora = @CodAseguradora) AND (codprodseguro = @Producto)) AS tCsSeguros ON 
                                              tCsSegurosBene.CodAseguradora = tCsSeguros.CodAseguradora AND tCsSegurosBene.CodOficina = tCsSeguros.CodOficina AND 
                                              tCsSegurosBene.NumPoliza = tCsSeguros.NumPoliza ON dbo.fduRellena('0', LTRIM(RTRIM(tCsPadronClientes.CodOrigen)), 13, 'D') 
                                              = tCsSeguros.NumPoliza ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario
                       WHERE      (tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA')) AND (tCsCartera.Fecha = @Corte)--('CASTIGADA')) AND (tCsCartera.Fecha = @Corte)
                       GROUP BY tCsPadronClientes.FechaNacimiento, tCsPadronClientes.CodOrigen, tCsCarteraDet.CodUsuario, tCsPadronClientes.Nombres, tCsPadronClientes.Paterno, 
                                              tCsPadronClientes.Materno, tUsClSexo.INTF, tCsPadronClientes.UsRFCBD, tCsSeguros.fecha, tCsPadronClientes_1.Nombres, 
                                              tCsPadronClientes_1.Paterno, tCsPadronClientes_1.Materno, tCsClParentesco.Atlas, tCsPadronClientes_2.Nombres, tCsPadronClientes_2.Paterno, 
                                              tCsPadronClientes_2.Materno, Registro.Desembolso) AS Datos
--Where FolioPoliza = '02-001-004SBF2301851'                                              
GO