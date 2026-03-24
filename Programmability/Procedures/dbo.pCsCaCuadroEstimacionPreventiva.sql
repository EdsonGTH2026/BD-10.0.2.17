SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Drop Procedure pCsCaCuadroEstimacionPreventiva 
-- Exec  pCsCaCuadroEstimacionPreventiva  '20110131', 'ZZZ'
CREATE PROCEDURE [dbo].[pCsCaCuadroEstimacionPreventiva] 
@Fecha		SmallDateTime, 
@Ubicacion	Varchar(100)
AS

Declare @CUbicacion		Varchar(500)
Declare @OtroDato		Varchar(1000)
Declare @Cadena			Varchar(8000)


Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out

Set @Ubicacion		= dbo.fduRellena(' ', @Ubicacion, 100, 'I')

Create Table #F
(Fecha SmallDateTime)

Insert Into #F (Fecha) Values(@Fecha)

Set @Cadena = 'SELECT Ubicacion = '''+ @Ubicacion +''', Fecha, TipoCredito, Reestructurado, DiasMora, SUM(Capital) AS Capital, SUM(Interes) AS '
Set @Cadena = @Cadena + 'Interes, SUM(Capital) + SUM(Interes) AS SaldoCartera, PReservaCapital AS PCapital, PReservaInteres AS PInteres, '
Set @Cadena = @Cadena + 'SUM(ReservaCapital) AS RCapital, SUM(ReservaInteres) AS RInteres, SUM(ReservaCapital) + SUM(ReservaInteres) AS '
Set @Cadena = @Cadena + 'EstimacionPreventiva, Identificador, Estado FROM (SELECT Fecha, TipoCredito, Reestructurado, CAST(DiasMinimo AS '
Set @Cadena = @Cadena + 'varchar(10)) + CASE WHEN diasmaximo = 0 THEN '''' WHEN diasmaximo > 1000 THEN '' a más'' ELSE '' - '' + '
Set @Cadena = @Cadena + 'CAST(DiasMaximo AS varchar(10)) END + '' días'' AS DiasMora, SUM(Capital) / 1000 AS Capital, SUM(Interes) / 1000 AS '
Set @Cadena = @Cadena + 'Interes, PReservaCapital, SUM(SReservaCapital) / 1000 AS ReservaCapital, PReservaInteres, SUM(SReservaInteres) / 1000 AS '
Set @Cadena = @Cadena + 'ReservaInteres, DiasMinimo, DiasMaximo, Identificador + dbo.fdurellena(''0'', Orden, 3, ''D'') AS Identificador, Estado '
Set @Cadena = @Cadena + 'FROM (SELECT DISTINCT tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario, '
Set @Cadena = @Cadena + 'tCaProdPerTipoCredito.Descripcion AS TipoCredito, CASE tCsCartera.TipoReprog WHEN ''SINRE'' THEN ''Normal'' WHEN ''REFRE'' THEN ''Normal'' '
Set @Cadena = @Cadena + 'ELSE ''Reestructurado'' END AS Reestructurado, tCsCartera.NroDiasAtraso, tCsCarteraDet.SaldoCapital AS Capital, '
Set @Cadena = @Cadena + 'tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + '
Set @Cadena = @Cadena + 'tCsCarteraDet.MoratorioVencido AS Interes, tCsCarteraDet.PReservaCapital, tCsCarteraDet.SReservaCapital, '
Set @Cadena = @Cadena + 'tCsCarteraDet.PReservaInteres, tCsCarteraDet.SReservaInteres, tCaClProvision.DiasMinimo, tCaClProvision.DiasMaximo, '
Set @Cadena = @Cadena + 'Identificador, Orden, tCsCartera.Estado FROM tCaClProvision INNER JOIN tCsCarteraDet ON tCaClProvision.Identificador = '
Set @Cadena = @Cadena + 'tCsCarteraDet.IReserva LEFT OUTER JOIN tCaProdPerTipoCredito INNER JOIN tCsCartera ON '
Set @Cadena = @Cadena + 'tCaProdPerTipoCredito.CodTipoCredito = tCsCartera.CodTipoCredito ON tCaClProvision.DiasMaximo >= '
Set @Cadena = @Cadena + 'tCsCartera.NroDiasAtraso AND tCaClProvision.DiasMinimo <= tCsCartera.NroDiasAtraso AND tCaClProvision.VigenciaFin >= '
Set @Cadena = @Cadena + 'tCsCartera.Fecha AND tCaClProvision.VigenciaInicio <= tCsCartera.Fecha AND tCaClProvision.Estado = tCsCartera.Estado AND '
Set @Cadena = @Cadena + 'tCaClProvision.CodTipoCredito = tCsCartera.CodTipoCredito AND tCsCarteraDet.Fecha = tCsCartera.Fecha AND '
Set @Cadena = @Cadena + 'tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo '
Set @Cadena = @Cadena + ' AND tCaClProvision.TipoReprog=tCsCartera.TipoReprog '
Set @Cadena = @Cadena + 'WHERE (tCsCarteraDet.Fecha In (Select Fecha from #F)) AND '
Set @Cadena = @Cadena + '(tCsCartera.Cartera IN (''ACTIVA'')) AND (tCsCartera.CodOficina IN ('+ @CUbicacion +'))) Datos GROUP BY Fecha, '
Set @Cadena = @Cadena + 'TipoCredito, NroDiasAtraso, Reestructurado, PReservaCapital, PReservaInteres, DiasMinimo, DiasMaximo, Identificador, '
Set @Cadena = @Cadena + 'Orden, Estado) Datos GROUP BY Fecha, TipoCredito, Reestructurado, DiasMora, PReservaCapital, PReservaInteres, '
Set @Cadena = @Cadena + 'Identificador, Estado ORDER BY Fecha, TipoCredito, Reestructurado, Identificador '

Print @Cadena
Exec (@Cadena)

Drop Table #F
GO