SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Exec pCsRssSeguimientoPLD 'ZZZ', '20100101', '20101231', 50000, '''AH'',''CA'''
--Drop Procedure pCsRssSeguimientoPLD 
CREATE Procedure [dbo].[pCsRssSeguimientoPLD] 

@Ubicacion	Varchar(500),
@FI			SmallDateTime,
@FF			SmallDateTime,
@Monto		Decimal(18,3),
@Sistema	Varchar(100)

As
/*
Set @Ubicacion	= 'ZZZ'
Set @FI			= '20100101'
Set @FF			= '20100131'
Set @Monto		= 50000
Set @Sistema	= '''AH'', ''CA'''
*/

Declare @Cadena0	Varchar(8000)
Declare @Cadena1	Varchar(8000)
Declare @Cadena2	Varchar(8000)
Declare @Cadena3	Varchar(8000)
Declare @Ahorro		Varchar(2)
Declare @Credito	Varchar(2)

Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera	Varchar(500)
Declare @OtroDato		Varchar(1000)
Declare @Cadena			Varchar(8000)

Set @Ahorro	 = 'No'
Set @Credito = 'No'

If CharIndex('AH', @Sistema) > 0 Begin Set @Ahorro	= 'Si' End
If CharIndex('CA', @Sistema) > 0 Begin Set @Credito = 'Si' End

Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out

Set @Ubicacion		= dbo.fduRellena(' ', @Ubicacion, 100, 'I')

Set @Cadena1 = 'SELECT Sistema = ''CA'', tCsPadronCarteraDet.Desembolso AS Fecha, tCsPadronCarteraDet.Monto, ''Desembolso'' AS '
Set @Cadena1 = @Cadena1 + 'Concepto, tCsPadronCarteraDet.CodOficina, tClOficinas.NomOficina, tCsPadronCarteraDet.CodPrestamo AS Cuenta, '
Set @Cadena1 = @Cadena1 + 'tCsPadronClientes.NombreCompleto AS Cliente, ltrim(rtrim(tCsPadronClientes_1.Nombre1)) + '' '' + '
Set @Cadena1 = @Cadena1 + 'ltrim(rtrim(tCsPadronClientes_1.Paterno)) AS AsesorAsignado FROM tCsPadronCarteraDet INNER JOIN tCsCartera ON '
Set @Cadena1 = @Cadena1 + 'tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha LEFT '
Set @Cadena1 = @Cadena1 + 'OUTER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsCartera.CodAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER '
Set @Cadena1 = @Cadena1 + 'JOIN tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN tClOficinas ON '
Set @Cadena1 = @Cadena1 + 'tCsPadronCarteraDet.CodOficina = tClOficinas.CodOficina WHERE (tCsPadronCarteraDet.Desembolso >= '
Set @Cadena1 = @Cadena1 + ''''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND (tCsPadronCarteraDet.Desembolso <= '
Set @Cadena1 = @Cadena1 + ''''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND (tCsPadronCarteraDet.Monto >= '+ Ltrim(rtrim(STR(@Monto, 30,4))) +') '
Set @Cadena1 = @Cadena1 + 'AND tCsPadronCarteraDet.CodOficina IN ('+ @CUbicacion +') '
		
Set @Cadena2 = 'SELECT Sistema = ''CA'', tCsPagoDet.Fecha, SUM(tCsPagoDet.MontoPagado) AS Monto, ''Recuperación'' AS Concepto, '
Set @Cadena2 = @Cadena2 + 'tCsPagoDet.OficinaTransaccion AS CodOficina, tClOficinas.NomOficina, tCsPagoDet.CodPrestamo AS Cuenta, '
Set @Cadena2 = @Cadena2 + 'tCsPadronClientes.NombreCompleto AS Cliente, ltrim(rtrim(tCsPadronClientes_1.Nombre1)) + '' '' + '
Set @Cadena2 = @Cadena2 + 'ltrim(rtrim(tCsPadronClientes_1.Paterno)) AS AsesorAsignado FROM tCsPagoDet INNER JOIN (SELECT DISTINCT CodPrestamo, '
Set @Cadena2 = @Cadena2 + 'FechaCorte FROM tcsPadronCarteraDet) tCsPadronCarteraDet ON tCsPagoDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo '
Set @Cadena2 = @Cadena2 + 'INNER JOIN tCsCartera ON tCsPadronCarteraDet.CodPrestamo COLLATE Modern_Spanish_CI_AI '
Set @Cadena2 = @Cadena2 + '= tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha LEFT OUTER JOIN tCsPadronClientes '
Set @Cadena2 = @Cadena2 + 'tCsPadronClientes_1 ON tCsCartera.CodAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN tCsPadronClientes ON '
Set @Cadena2 = @Cadena2 + 'tCsPagoDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN tClOficinas ON tCsPagoDet.CodOficina = '
Set @Cadena2 = @Cadena2 + 'tClOficinas.CodOficina WHERE (tCsPagoDet.Extornado = 0) AND (tCsPagoDet.Fecha >= '
Set @Cadena2 = @Cadena2 + ''''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND (tCsPagoDet.Fecha <= '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') '
Set @Cadena2 = @Cadena2 + 'AND tCsPagoDet.OficinaTransaccion In ('+ @CUbicacion +') GROUP BY tCsPagoDet.Fecha, tCsPagoDet.CodPrestamo, '
Set @Cadena2 = @Cadena2 + 'tCsPagoDet.CodUsuario, tCsPagoDet.OficinaTransaccion, tClOficinas.NomOficina, tCsPadronClientes_1.Nombre1, tCsPadronClientes_1.Paterno, '
Set @Cadena2 = @Cadena2 + 'tCsPadronClientes.NombreCompleto HAVING (SUM(tCsPagoDet.MontoPagado) >= '+ Ltrim(rtrim(STR(@Monto, 30,4))) +') ' 

Set @Cadena3 = 'SELECT tCsTransaccionDiaria.CodSistema AS Sistema, tCsTransaccionDiaria.Fecha, SUM(tCsTransaccionDiaria.MontoTotalTran) AS Monto, '
Set @Cadena3 = @Cadena3 + 'tAhClTipoTrans.Descripcion AS Concepto, tCsTransaccionDiaria.CodOficina, tClOficinas.NomOficina, '
Set @Cadena3 = @Cadena3 + 'tCsTransaccionDiaria.CodigoCuenta, tCsPadronClientes.NombreCompleto AS Cliente, '
Set @Cadena3 = @Cadena3 + 'ltrim(rtrim(tCsPadronClientes_1.Nombre1)) + '' '' + ltrim(rtrim(tCsPadronClientes_1.Paterno)) AS '
Set @Cadena3 = @Cadena3 + 'AsesorAsignado FROM tCsPadronClientes tCsPadronClientes_1 RIGHT OUTER JOIN tCsAhorros ON tCsPadronClientes_1.CodUsuario '
Set @Cadena3 = @Cadena3 + '= tCsAhorros.CodAsesor RIGHT OUTER JOIN tCsTransaccionDiaria INNER JOIN tCsPadronAhorros ON '
Set @Cadena3 = @Cadena3 + 'tCsTransaccionDiaria.CodigoCuenta = tCsPadronAhorros.CodCuenta AND tCsTransaccionDiaria.FraccionCta = '
Set @Cadena3 = @Cadena3 + 'tCsPadronAhorros.FraccionCta AND tCsTransaccionDiaria.Renovado = tCsPadronAhorros.Renovado LEFT OUTER JOIN '
Set @Cadena3 = @Cadena3 + 'tCsPadronClientes ON tCsTransaccionDiaria.CodUsuario = tCsPadronClientes.CodUsuario ON tCsAhorros.Fecha = '
Set @Cadena3 = @Cadena3 + 'tCsPadronAhorros.FechaCorte AND tCsAhorros.CodCuenta = tCsPadronAhorros.CodCuenta AND tCsAhorros.FraccionCta = '
Set @Cadena3 = @Cadena3 + 'tCsPadronAhorros.FraccionCta AND tCsAhorros.Renovado = tCsPadronAhorros.Renovado LEFT OUTER JOIN tClOficinas ON '
Set @Cadena3 = @Cadena3 + 'tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN tAhClTipoTrans ON '
Set @Cadena3 = @Cadena3 + 'tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans WHERE (tCsTransaccionDiaria.Fecha >= '
Set @Cadena3 = @Cadena3 + ''''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND (tCsTransaccionDiaria.Fecha <= '
Set @Cadena3 = @Cadena3 + ''''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND (tCsTransaccionDiaria.CodSistema = ''AH'') AND '
Set @Cadena3 = @Cadena3 + '(tCsTransaccionDiaria.CodOficina IN ('+ @CUbicacion +')) GROUP BY tCsTransaccionDiaria.CodSistema, '
Set @Cadena3 = @Cadena3 + 'tCsTransaccionDiaria.Fecha, tAhClTipoTrans.Descripcion, tCsTransaccionDiaria.CodOficina, tClOficinas.NomOficina, '
Set @Cadena3 = @Cadena3 + 'tCsTransaccionDiaria.CodigoCuenta, tCsPadronClientes.NombreCompleto, tCsPadronClientes_1.Nombre1, tCsPadronClientes_1.Paterno HAVING '
Set @Cadena3 = @Cadena3 + '(SUM(tCsTransaccionDiaria.MontoTotalTran) >= '+ Ltrim(rtrim(STR(@Monto, 30,4))) +') '

Set @Cadena0 = 'Select MN = dbo.fduDSM(Fecha, ''MN''), dbo.fduDSM(Fecha, ''ML'') As Mes, '
Set @Cadena0 = @Cadena0 + 'SN = dbo.fduDSM(Fecha, ''SN''), dbo.fduDSM(Fecha, ''SL'') As Semana, '
Set @Cadena0 = @Cadena0 + 'Ubicacion = '''+ @Ubicacion +''', Ahorros = '''+ @Ahorro +''', Creditos = '''+ @Credito +''', * From('+ @Cadena1 + ' '
Set @Cadena0 = @Cadena0 + 'UNION '+ @Cadena2 +' UNION ' + @Cadena3 + ')Datos Where Sistema In('+ @Sistema +')'

Print @Cadena1
Print @Cadena2
Print @Cadena3

Exec(@Cadena0)

GO