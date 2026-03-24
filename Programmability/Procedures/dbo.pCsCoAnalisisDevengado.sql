SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROCEDURE pCsCoAnalisisDevengado
CREATE Procedure [dbo].[pCsCoAnalisisDevengado]
@FI 		SmallDateTime,
@FF 		SmallDateTime,
@Ubicacion	Varchar(100),
@ClaseCartera	Varchar(100)
--Declare @FI 		SmallDateTime
--Declare @FF 		SmallDateTime
--Declare @Ubicacion	Varchar(100)
--Declare @ClaseCartera	Varchar(100)

--Set @FI 		= '20091201'
--Set @FF			= '20091231'
--Set @Ubicacion		= 'ZZZ'
--Set @ClaseCartera	= 'ACTIVA'
As
Declare @tmpSDT		SmallDateTime
Declare @CClaseCartera 	Varchar(500)
Declare @CUbicacion 	Varchar(500)
Declare @OtroDato	Varchar(100)

Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out

If @FI > @FF
Begin
	Set @tmpSDT	= @FI
	Set @FI 	= @FF
	Set @FF		= @tmpSDT
End

Declare @Cadena1 Varchar(4000)
Declare @Cadena2 Varchar(4000)
Declare @Cadena3 Varchar(4000)
Declare @Cadena4 Varchar(4000)

Set @Cadena1 = 'SELECT Cartera, Periodo = dbo.fduFechaAtexto(Fecha, ''AAAAMM''), Fecha, codoficina, Oficina, SUM(InteresCtaBalanceVi) AS InteresCtaBalanceVi, SUM(InteresCtaBalanceVe) AS InteresCtaBalanceVe, SUM(InteresCtaOrden) '
Set @Cadena1 = @Cadena1 + 'AS InteresCtaOrden, SUM(InteresOtro) AS InteresOtro, SUM(MoratorioCtaBalanceVi) AS MoratorioCtaBalanceVi, SUM(MoratorioCtaBalanceVe) '
Set @Cadena1 = @Cadena1 + 'AS MoratorioCtaBalanceVe, SUM(MoratorioCtaOrden) AS MoratorioCtaOrden, SUM(MoratorioOtro) AS MoratorioOtro '
Set @Cadena1 = @Cadena1 + 'FROM (SELECT Cartera, Datos.Estado, Datos.Fecha, Datos.codoficina, dbo.fduRellena(''0'', Datos.codoficina, 2, ''D'') + '' '' + tClOficinas.NomOficina AS Oficina, '
Set @Cadena1 = @Cadena1 + 'CASE WHEN EID = ''CB'' AND Estado = ''VIGENTE'' THEN SUM(Datos.InteresDevengado) ELSE 0 END AS InteresCtaBalanceVi, CASE WHEN EID = ''CB'' AND ' 
Set @Cadena1 = @Cadena1 + 'Estado = ''VENCIDO'' THEN SUM(Datos.InteresDevengado) ELSE 0 END AS InteresCtaBalanceVe, ' 
Set @Cadena1 = @Cadena1 + 'CASE WHEN EID = ''CO'' THEN SUM(Datos.InteresDevengado) ELSE 0 END AS InteresCtaOrden, '
Set @Cadena1 = @Cadena1 + 'InteresOtro = CASE WHEN EID = ''ND'' THEN SUM(interesdevengado) ELSE 0 END, CASE WHEN EMD = ''CB'' AND ' 
Set @Cadena1 = @Cadena1 + 'Estado = ''VIGENTE'' THEN SUM(Datos.MoratorioDevengado) ELSE 0 END AS MoratorioCtaBalanceVi, CASE WHEN EMD = ''CB'' AND ' 
Set @Cadena1 = @Cadena1 + 'Estado = ''VENCIDO'' THEN SUM(Datos.MOratorioDevengado) ELSE 0 END AS MoratorioCtaBalanceVe, ' 
Set @Cadena1 = @Cadena1 + 'CASE WHEN EMD = ''CO'' THEN SUM(Datos.MoratorioDevengado) ELSE 0 END AS MoratorioCtaOrden, ' 

Set @Cadena2 = 'MoratorioOtro = CASE WHEN EMD = ''ND'' THEN SUM(moratoriodevengado) ELSE 0 END, Datos.EID, Datos.EMD '
Set @Cadena2 = @Cadena2 + 'FROM (SELECT Cartera, codoficina, Estado, Fecha, CodPrestamo, CodUsuario, InteresDevengado, ' 
Set @Cadena2 = @Cadena2 + 'CASE WHEN InteresDevengado = 0 THEN ''CO'' WHEN Interes - interesA = interesdevengado THEN ''CB'' WHEN InteresctaOrden - interesctaordenA '
Set @Cadena2 = @Cadena2 + '= interesdevengado THEN ''CO'' WHEN InteresCtaOrden - InteresA = 2 * InteresCtaOrdenA THEN ''CO'' WHEN interes = interesdevengado THEN ''CB'' '
Set @Cadena2 = @Cadena2 + 'WHEN interesctaorden = 0 AND Interes > 0 THEN ''CB'' WHEN Interes = 0 AND interesctaorden > 0 THEN ''CO'' WHEN abs(interes - interesa) ' 
Set @Cadena2 = @Cadena2 + '<= 0.01 AND interesctaorden > 0 THEN ''CO'' WHEN interesctaordenA > interesctaorden AND ' 
Set @Cadena2 = @Cadena2 + 'interes > interesa THEN ''CB'' WHEN interesdevengado > (interes - interesA) AND ' 
Set @Cadena2 = @Cadena2 + 'interesctaorden > interesctaordenA THEN ''CO'' WHEN estado = ''VENCIDO'' THEN ''CO'' ELSE ''ND'' END AS EID, MoratorioDevengado, ' 
Set @Cadena2 = @Cadena2 + 'CASE WHEN MoratorioDevengado = 0 THEN ''CB'' WHEN Moratorio - MoratorioA = Moratoriodevengado THEN ''CB'' WHEN abs(abs(MoratorioCTaOrden '
Set @Cadena2 = @Cadena2 + '- moratorioctaordenA) - Moratoriodevengado) <= 0.02 THEN ''CO'' WHEN abs(abs(moratorioCtaOrden - moratorioA) - 2 * moratorioCtaOrdenA) ' 
Set @Cadena2 = @Cadena2 + '<= 0.02 THEN ''CO'' WHEN moratorio = moratoriodevengado THEN ''CB'' WHEN moratorioctaorden = 0 AND ' 
Set @Cadena2 = @Cadena2 + 'Moratorio > 0 THEN ''CB'' WHEN moratorio = 0 AND moratorioctaorden > 0 THEN ''CO'' WHEN abs(moratorio - moratorioa) <= 0.01 AND '
Set @Cadena2 = @Cadena2 + 'moratorioctaorden > 0 THEN ''CO'' WHEN moratorioctaordenA > moratorioctaorden AND ' 

Set @Cadena3 = 'moratorio > moratorioa THEN ''CB'' WHEN moratoriodevengado > (moratorio - moratorioA) AND ' 
Set @Cadena3 = @Cadena3 + 'moratorioctaorden > moratorioctaordenA THEN ''CO'' WHEN estado = ''VENCIDO'' THEN ''CO'' ELSE ''ND'' END AS EMD '
Set @Cadena3 = @Cadena3 + 'FROM (SELECT Detalle.Cartera, Detalle.codoficina, Detalle.Estado, Detalle.Fecha, Detalle.CodPrestamo, Detalle.CodUsuario, Detalle.Interes, '
Set @Cadena3 = @Cadena3 + 'tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido AS InteresA, Detalle.InteresCtaOrden, ' 
Set @Cadena3 = @Cadena3 + 'tCsCarteraDet.InteresCtaOrden AS InteresCtaOrdenA, Detalle.InteresDevengado, Detalle.Moratorio, ' 
Set @Cadena3 = @Cadena3 + 'tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido AS MoratorioA, Detalle.MoratorioCtaOrden, ' 
Set @Cadena3 = @Cadena3 + 'tCsCarteraDet.MoratorioCtaOrden AS MoratorioCtaOrdenA, Detalle.MoratorioDevengado '
Set @Cadena3 = @Cadena3 + 'FROM (SELECT tcscartera.Cartera, tcscartera.codoficina, tcscartera.Estado, tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario, '
Set @Cadena3 = @Cadena3 + 'tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido AS Interes, tCsCarteraDet.InteresCtaOrden, '
Set @Cadena3 = @Cadena3 + 'tCsCarteraDet.InteresDevengado, tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido AS Moratorio, ' 

Set @Cadena4 = 'tCsCarteraDet.MoratorioCtaOrden, tCsCarteraDet.MoratorioDevengado '
Set @Cadena4 = @Cadena4 + 'FROM tCsCarteraDet with(nolock) INNER JOIN '
Set @Cadena4 = @Cadena4 + 'tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND '
Set @Cadena4 = @Cadena4 + 'tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo '
Set @Cadena4 = @Cadena4 + 'WHERE (tCsCartera.Cartera IN ('+ @CClaseCartera +')) AND tcscartera.codoficina IN ('+ @CUbicacion +') AND (tCsCarteraDet.Fecha >= '''+ dbo.fdufechaatexto(@FI, 'AAAAMMDD') +''' AND ' 
Set @Cadena4 = @Cadena4 + 'tCsCarteraDet.Fecha <= '''+ dbo.fdufechaatexto(@FF, 'AAAAMMDD') +''')) Detalle LEFT OUTER JOIN '
Set @Cadena4 = @Cadena4 + 'tCsCarteraDet with(nolock) ON Detalle.Fecha = tCsCarteraDet.Fecha + 1 AND ' 
Set @Cadena4 = @Cadena4 + 'Detalle.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo AND '
Set @Cadena4 = @Cadena4 + 'Detalle.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodUsuario) Datos) Datos INNER JOIN '
Set @Cadena4 = @Cadena4 + 'tClOficinas ON Datos.codoficina COLLATE Modern_Spanish_CI_AI = tClOficinas.CodOficina '
Set @Cadena4 = @Cadena4 + 'GROUP BY Datos.Cartera, Datos.Fecha, Datos.codoficina, Datos.EID, Datos.EMD, tClOficinas.NomOficina, Datos.Estado) Datos '
Set @Cadena4 = @Cadena4 + 'GROUP BY Cartera, Fecha, codoficina, Oficina '

Print @Cadena1
Print @Cadena2
Print @Cadena3
Print @Cadena4

Exec(@Cadena1 + @Cadena2 + @Cadena3 + @Cadena4)
GO