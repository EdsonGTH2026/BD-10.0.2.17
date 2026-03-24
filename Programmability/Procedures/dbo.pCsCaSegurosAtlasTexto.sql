SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[pCsCaSegurosAtlasTexto]
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
--SELECT     @Archivo =    'E' + LTRIM(RTRIM(tClEmpresas.ATLAS)) + @Periodo + '00' + tCsSegurosProd.CodExterno + ''
--FROM       tClEmpresas CROSS JOIN tCsSegurosProd
--WHERE      (tClEmpresas.Activo = 1) AND (tCsSegurosProd.codaseguradora = @CodAseguradora) AND (tCsSegurosProd.codprodseguro = @Producto)

--SELECT Archivo = @Archivo, '3' AS TipoRegistro, Cast(COUNT(*) as Varchar(20)) AS NroPolizas, Round(SUM(MontoCredito),2) as ImportePolizas
--FROM	HHHH          

--SELECT     HHHH.ClaveSucursal, tClOficinas.NomOficina, HHHH.FolioPoliza, HHHH.NoSocio, HHHH.NombreAsegurado, HHHH.PaternoAsegurado, HHHH.MaternoAsegurado, 
--                      HHHH.Genero, HHHH.RFC, HHHH.IngresoSeguro, HHHH.FechaRegistro, HHHH.MontoCredito, HHHH.PlazoCredito/*, HHHH.NombreBeneficiario, 
--                      HHHH.PaternoBeneficiario, HHHH.MaternoBeneficiario, HHHH.Parentesco, ISNULL(tCsClParentesco.descripcion, '') AS NParentesco, HHHH.Porcentaje*/
--FROM         HHHH INNER JOIN
--                      tClOficinas ON HHHH.ClaveSucursal = tClOficinas.CodOficina /*LEFT OUTER JOIN
--                      tCsClParentesco ON HHHH.Parentesco = CAST(tCsClParentesco.Atlas AS Varchar(2))*/

Select * 
From (Select Cadena From HHHH
Union ALL
SELECT Cadena = 
'3' + '|' + Cast(COUNT(*) as Varchar(20)) + '|' + Ltrim(rtrim(Replace(Left(STR(Round(SUM(MontoCredito),2), 20, 2), 20), '.', ''))) + '|'
FROM	HHHH  ) Datos
Order by Cadena
GO