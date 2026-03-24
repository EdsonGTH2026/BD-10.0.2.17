SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Exec pCsCaDetalleCarteraTramo '5', 'ACTIVA', 30, 1
-- Drop Procedure pCsRssCancelacionesAnticipadas 

CREATE Procedure [dbo].[pCsRssCancelacionesAnticipadas] 
@Ubicacion		Varchar(500),
@ClaseCartera	Varchar(100),	
@FI				SmallDateTime,
@FF				SmallDateTime
As
--Set @Ubicacion		= 'ZZZ'
--Set @ClaseCartera		= 'ACTIVA'
--Set @FI				= '20100101'
--Set @FF				= '20101231'

Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera	Varchar(500)
Declare @OtroDato		Varchar(1000)
Declare @Cadena			Varchar(8000)

Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera	Out, 	@ClaseCartera 	Out,  @OtroDato Out

Set @Ubicacion		= dbo.fduRellena(' ', @Ubicacion, 100, 'I')
Set @ClaseCartera	= dbo.fduRellena(' ', @ClaseCartera, 100, 'I')

Create Table #Cuotas
(
CodPrestamo			Varchar(25),
SecCuota			Int,
FechaVencimiento	SmallDateTime
)

Set @Cadena = 'Insert Into #Cuotas '
Set @Cadena = @Cadena + 'SELECT CodPrestamo, SecCuota, FechaVencimiento FROM tCsPadronPlanCuotas WHERE CodPrestamo IN (SELECT DISTINCT tCsPadronCarteraDet.CodPrestamo '
Set @Cadena = @Cadena + 'FROM tCsPadronCarteraDet INNER JOIN tCsCartera ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND '
Set @Cadena = @Cadena + 'tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.Cancelacion < tCsCartera.FechaVencimiento '
Set @Cadena = @Cadena + 'WHERE (Cancelacion >= '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND '
Set @Cadena = @Cadena + '(Cancelacion <= '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND (tCsPadronCarteraDet.CodOficina IN ('+ @CUbicacion +')) AND CarteraActual IN ('+ @CClaseCartera +')) GROUP BY '
Set @Cadena = @Cadena + 'CodPrestamo, SecCuota, FechaVencimiento'

Print @Cadena
Exec (@Cadena) 

Set @Cadena = 'SELECT UBicacion = '''+ @Ubicacion +''', '''+ @ClaseCartera +''' as ClaseCartera, Año = Year(tCsPadronCarteraDet.Cancelacion), '
Set @Cadena	= @Cadena	+ 'MN = dbo.fduDSM(tCsPadronCarteraDet.Cancelacion, ''MN''), dbo.fduDSM(tCsPadronCarteraDet.Cancelacion, ''ML'') As Mes, '
Set @Cadena	= @Cadena	+ 'SN = dbo.fduDSM(tCsPadronCarteraDet.Cancelacion, ''SN''), dbo.fduDSM(tCsPadronCarteraDet.Cancelacion, ''SL'') As Semana, '
Set @Cadena	= @Cadena	+ 'tCsPadronCarteraDet.CodPrestamo, ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto) AS ClienteGrupo, '
Set @Cadena	= @Cadena	+ 'COUNT(*) AS NroParticipantes, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso, tCsPadronCarteraDet.SecuenciaGrupo '
Set @Cadena	= @Cadena	+ 'AS SecuenciaPrestamo, CASE tCsCartera.NroCuotas WHEN 1 THEN ''Un '' + tCaClModalidadPlazo.Singular ELSE '
Set @Cadena	= @Cadena	+ 'CAST(tCsCartera.NroCuotas AS Varchar(10)) + '' '' + tCaClModalidadPlazo.Plural END AS Plazo, '
Set @Cadena	= @Cadena	+ 'dbo.fduNumeroTexto(tCsCartera.TasaIntCorriente / 12, 2) + ''%'' AS TIM, tCsCartera.NroDiasAtraso, CASE WHEN '
Set @Cadena	= @Cadena	+ 'Cuotas.Fechavencimiento = tcsPadronCarteradet.cancelacion THEN tCsCartera.NroCuotas - tCsCartera.CuotaActual ELSE '
Set @Cadena	= @Cadena	+ 'tCsCartera.NroCuotas - tCsCartera.CuotaActual + 1 END AS CuotasAnticipadas, tCsPadronCarteraDet.Cancelacion, '
Set @Cadena	= @Cadena	+ 'Pagos.CapitalAnticipado, Pagos.InteresAnticipado, Pagos.Liquidacion, tCsPadronCarteraDet.CodOficina, '
Set @Cadena	= @Cadena	+ 'tClOficinas.NomOficina, tCsCartera.Cartera, tCsCartera.FechaVencimiento FROM tCsPadronCarteraDet INNER JOIN (SELECT Fecha, CodPrestamo, CuotaActual, '
Set @Cadena	= @Cadena	+ 'FechaVencimiento, ModalidadPlazo, CodUsuario, CodGrupo, FechaDesembolso, CodOficina, MontoDesembolso, NroCuotas, Cartera, '
Set @Cadena	= @Cadena	+ 'TasaIntCorriente, NroDiasAtraso FROM tCsCartera AS '
Set @Cadena	= @Cadena	+ 'tCsCartera_1 WHERE (CodOficina IN ('+ @CUbicacion +')) And Cartera in '
Set @Cadena	= @Cadena	+ '('+ @CClaseCartera +')) AS tCsCartera ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND '
Set @Cadena	= @Cadena	+ 'tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.Cancelacion < '
Set @Cadena	= @Cadena	+ 'tCsCartera.FechaVencimiento INNER JOIN (Select * from #Cuotas) AS Cuotas ON tCsCartera.CodPrestamo '
Set @Cadena	= @Cadena	+ '= Cuotas.CodPrestamo AND tCsCartera.CuotaActual = Cuotas.SecCuota INNER JOIN tClOficinas ON '
Set @Cadena	= @Cadena	+ 'tCsPadronCarteraDet.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN (SELECT CodPrestamo, Fecha, SUM(Capital) AS '
Set @Cadena	= @Cadena	+ 'CapitalAnticipado, SUM(Interes) AS InteresAnticipado, SUM(Liquidacion) AS Liquidacion FROM (SELECT CodPrestamo, Fecha, '
Set @Cadena	= @Cadena	+ 'CASE WHEN CodConcepto = ''CAPI'' THEN Montopagado ELSE 0 END AS Capital, CASE WHEN CodConcepto = ''INTE'' THEN '
Set @Cadena	= @Cadena	+ 'Montopagado ELSE 0 END AS Interes, MontoPagado AS Liquidacion FROM tCsPagoDet WHERE (Extornado = 0)) AS Pagos GROUP BY '
Set @Cadena	= @Cadena	+ 'CodPrestamo, Fecha) AS Pagos ON tCsPadronCarteraDet.CodPrestamo = Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI AND '
Set @Cadena	= @Cadena	+ 'tCsPadronCarteraDet.Cancelacion = Pagos.Fecha LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = '
Set @Cadena	= @Cadena	+ 'tCaClModalidadPlazo.ModalidadPlazo LEFT OUTER JOIN tCsPadronClientes ON tCsCartera.CodUsuario = '
Set @Cadena	= @Cadena	+ 'tCsPadronClientes.CodUsuario LEFT OUTER JOIN tCsCarteraGrupos ON tCsCartera.CodOficina = tCsCarteraGrupos.CodOficina '
Set @Cadena	= @Cadena	+ 'AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo WHERE (tCsPadronCarteraDet.Cancelacion '
Set @Cadena	= @Cadena	+ '>= '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND '
Set @Cadena	= @Cadena	+ '(tCsPadronCarteraDet.Cancelacion <= '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND '
Set @Cadena	= @Cadena	+ '(tCsPadronCarteraDet.CodOficina IN ('+ @CUbicacion +')) AND (tCsCartera.Cartera in ('+ @CClaseCartera +')) GROUP BY '
Set @Cadena	= @Cadena	+ 'tCsPadronCarteraDet.CodPrestamo, ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto), '
Set @Cadena	= @Cadena	+ 'tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso, tCsPadronCarteraDet.SecuenciaGrupo, tCsCartera.NroCuotas, '
Set @Cadena	= @Cadena	+ 'tCaClModalidadPlazo.Singular, tCaClModalidadPlazo.Plural, tCsCartera.TasaIntCorriente, tCsCartera.NroDiasAtraso, '
Set @Cadena	= @Cadena	+ 'tCsCartera.CuotaActual, tCsPadronCarteraDet.Cancelacion, Cuotas.FechaVencimiento, Pagos.CapitalAnticipado, '
Set @Cadena	= @Cadena	+ 'Pagos.InteresAnticipado, Pagos.Liquidacion, tCsPadronCarteraDet.CodOficina, tClOficinas.NomOficina, tCsCartera.Cartera, tCsCartera.FechaVencimiento '

Print @Cadena
Exec (@Cadena) 

Drop Table #Cuotas
GO