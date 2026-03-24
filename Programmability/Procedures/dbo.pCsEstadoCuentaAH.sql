SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [FinamigoConsolidado]
--GO
--/****** Object:  StoredProcedure [dbo].[pCsEstadoCuenta]    Script Date: 20/09/2016 06:11:29 pm ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
/*
	Exec pCsEstadoCuenta 3, '', '5370330032000004'
	Select dbo.fduCATPrestamo(3, 32000, 7.85, 6, 0)
	Select dbo.fduCATPrestamo(3, 18132, 7.85, 4, 0)
*/
--ALTER Procedure [dbo].[pCsEstadoCuenta]
--	@Dato			Int			,
--	@Usuario		Varchar(50)	, 
--	@Cuenta			Varchar(25)
--As
--	@Dato
--	1	:	Estado de Cuentas de Créditos.
--	2	:	Estado de Cuentas de Ahorros.
--	3	:	Estado de Cuentas de Tarjetas.

CREATE Procedure [dbo].[pCsEstadoCuentaAH] @Usuario		Varchar(50),@Cuenta			Varchar(25), @PrimerCorte	SmallDateTime, @UltimoCorte	SmallDateTime
as

--declare	@Usuario		Varchar(50)
--declare	@Cuenta			Varchar(25)
--set @Usuario='curbiza'
--set @Cuenta='010-203-06-2-3-00702-0-0'
----Declare @UltimoCorte	SmallDateTime
----Declare @PrimerCorte	SmallDateTime

--POR EL MOMENTO NO SE UTILIZA LA VARIABLE @DATO
Declare @Firma			Varchar(100)
Declare @Parametro		Varchar(50)
Declare @AnteriorCorte	SmallDateTime
Declare @LimitePago		Varchar(20)
Declare @Devengado		Decimal(20,4)
Declare @SaldoAnterior	Decimal(20,4)
Declare @CAT			Decimal(10,4)

--set @PrimerCorte='20160801'
--set @UltimoCorte='20160831'

If Ltrim(Rtrim(@Usuario)) = ''
Begin 
	Select TOP 1 @Usuario = Usuario from tSgUsuarios
	Where Activo = 1 And ltrim(rtrim(Usuario)) <> ''
	Order by NewId()
End
If Ltrim(Rtrim(@Cuenta)) = ''
Begin 
	Select Top 1 @Cuenta = CodPrestamo from (
	Select Distinct CodPrestamo From tCsPadronCarteraDet
	Where EstadoCalculado Not In ('CANCELADO')) Datos
	Order by Newid()
End

--If @Dato = 2
--Begin
--	--Select @PrimerCorte = PrimerCorte, @UltimoCorte = UltimoCorte from (
--	--SELECT     CodPrestamo, EstadoCuenta, PrimerCorte = CAST(dbo.fduFechaATexto(DATEADD(day, 1, DATEADD(Month, - 1, Case When dbo.fduCalculoFinMes(UltimoCorte) = 1 Then Dateadd(day, 1, UltimoCorte) Else UltimoCorte End )), 'AAAAMM') + EstadoCuenta AS SmallDateTime) ,   UltimoCorte, Consolidacion
--	--FROM         (SELECT     CodPrestamo, EstadoCuenta, CASE WHEN UltimoCorte > Consolidacion THEN DateAdd(Month, - 1, UltimoCorte) ELSE UltimoCorte END AS UltimoCorte, 
--	--											  Consolidacion
--	--					   FROM          (SELECT DISTINCT CodCuenta + '-' + CAST(Renovado AS varchar(5)) + '-' + FraccionCta As CodPrestamo, EstadoCuenta = dbo.fduRellena('0', EstadoCuenta, 2, 'D'), DATEADD(day, -1, CAST(dbo.fduFechaATexto
--	--																		  ((SELECT     FechaConsolidacion
--	--																			  FROM         vCsFechaConsolidacion), 'AAAAMM') + dbo.fduRellena('0', EstadoCuenta, 2, 'D') AS SmallDateTime)) AS UltimoCorte,
--	--																		  (SELECT     FechaConsolidacion
--	--																			FROM          vCsFechaConsolidacion) AS Consolidacion
--	--											   FROM          tCsPadronAhorros
--	--											   WHERE      (CodCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) IN
--	--																		  (@Cuenta))) AS Datos) AS Datos) Datos
--	set @PrimerCorte='20160801'
--	set @UltimoCorte='20160831'
--End	

Set		@AnteriorCorte	= DateAdd(day,-1,@PrimerCorte)
/*pendiente*/
Exec	pCsEstadoCuentaCronograma		2,	@Cuenta, @UltimoCorte
Exec	pCsEstadoCuentaCronograma		2,	@Cuenta, @AnteriorCorte
Exec	pCsEstadoCuentaCAMovimientos	2,	@Cuenta, @PrimerCorte,		@UltimoCorte

--Print	@AnteriorCorte
--Print	@UltimoCorte

--If @Dato = 2
--Begin
	SELECT    @CAT = dbo.fduCATPrestamo(4, SaldoCuenta, DATEDIFF(Day, @PrimerCorte, @UltimoCorte), TasaInteres, 0) 
	FROM         tCsAhorros
	WHERE     (CodCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta) AND (Fecha = @UltimoCorte)
--End

CREATE TABLE #Saldos(
	[CodPrestamo]		[varchar](25) NOT NULL,
	[Concepto]			[varchar](100) NULL,
	[SaldoCapital]		[money] NULL,
	[InteresOrdinario]	[money] NULL,
	[InteresMoratorio]	[money] NULL,
	[OtrosCargos]		[money] NULL,
	[ComisionIVA]		[money] NULL
) ON [PRIMARY]

Insert Into #Saldos
Exec pCsEstadoCuentaCASaldos 1, @Cuenta, @UltimoCorte,		'Vigente Actual'
Insert Into #Saldos
Exec pCsEstadoCuentaCASaldos 2, @Cuenta, @UltimoCorte,		'Atraso Actual'

Set @Parametro	= Replace(@Cuenta, '-', '')
Exec pCsFirmaElectronica @Usuario, 'EC', @Parametro, @Firma Out, 'ESTADO DE CUENTA MENSUAL PRUEBA'

Set @Parametro	= Upper(dbo.fduNombreMes(Month(@UltimoCorte)) + ' ' + Cast(Year(@UltimoCorte) as Varchar(4)))

Select @SaldoAnterior = Sum(Devengado-Pago) from tCsEstadoCuentaCronograma
Where Corte = @AnteriorCorte and CodPrestamo = @Cuenta

Print @SaldoAnterior

--If @Dato = 2
--Begin
	Set @LimitePago = 'INMEDIATO'
--End

--If @Dato = 2
--Begin
	SELECT	@PrimerCorte AS Inicio, @UltimoCorte AS Corte, DATEDIFF(Day, @PrimerCorte, @UltimoCorte) AS Dias, @Parametro AS Periodo
			, @Firma AS Firma, 
			CodPrestamo = @Cuenta
			, tCsClientesAhorrosFecha_2.CodUsCuenta as CodUsuario, NombreProdCorto = tAhProductos.Abreviatura, NombreProd = tAhProductos.Nombre
			,tCsPadronClientes.UsRFCBD
			, tCsPadronAhorros.CodOficina, tClOficinas.Tipo, ProximoVencimiento = @UltimoCorte
			,tAhClFormaManejo.Nombre AS Veridico 
			, LEFT(General.ClienteGrupo, 35) AS ClienteGrupo
			,General.DescMoneda
			, tCsAhorros.FechaApertura AS FechaDesembolso
			, FechaVencimiento = Case When tCsAhorros.FechaVencimiento Is Null Then 'INDEFINIDO' 
			Else dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'DD') +  '-' + lower(Left(dbo.fduNombreMes(Month(tCsAhorros.FechaVencimiento)), 3)) + '-' + dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'AAAA') End
			,tCsAhorros.TasaInteres AS TasaIntCorriente
			, @CAT AS CAT, tCsAhorros.SaldoCuenta AS SaldoCapital
			, 0 AS CargoMora, 0 AS OtrosCargos, 0 AS Impuestos
			,CASE WHEN (ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) + ISNULL(Atrasado.InteresMoratorio, 0) + ISNULL(Atrasado.OtrosCargos, 0) 
            + ISNULL(Atrasado.ComisionIVA, 0)) > 0 THEN 'INMEDIATO' ELSE '' END AS LimitePago
			, isnull(@SaldoAnterior,0) AS SaldoAnterior
			, Isnull(Cargos.CK, 0) as CK
			, ISNULL(Abonos.AK, 0) AS AK
			, tCsPadronClientes.NombreCompleto
			, tAhProductos.AlternativaUso
			, cast(Replace(isnull(case when tAhProductos.SaldoMinimo='NO APLICA' then '0' else tAhProductos.SaldoMinimo end,'0'), '$', '') as decimal(8,2)) SaldoMinimo
          ,  SaldoPromedio	= (Select AVG(SaldoCuenta) from tcsahorros Where CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) )
       ,    MontoBloqueado	= tCsAhorros.MontoBloqueado
			,SaldoDisponible = tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado - 
			(case when tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado<(case when tAhProductos.SaldoMinimo='NO APLICA' then 0 else Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4)) end)
				  then 0 else (case when tAhProductos.SaldoMinimo='NO APLICA' then 0 else Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4)) end) end)
	FROM (SELECT     *
		  FROM          [#Saldos] AS [#Saldos_1]
		  WHERE      (Concepto = 'Atraso Actual')
		  ) AS Atrasado 
	RIGHT OUTER JOIN (SELECT     CodCuenta, FraccionCta, Renovado, SUM(AK) AS AK, SUM(AI) AS AI, SUM(AM) AS AM, SUM(AC) AS AC, SUM(AIVA) AS AIVA
					  FROM (SELECT     CodCuenta, FraccionCta, Renovado, CASE CodConcepto WHEN 'CAPI' THEN Pago ELSE 0 END AS AK, 
							CASE CodConcepto WHEN 'INTE' THEN Pago ELSE 0 END AS AI, CASE CodConcepto WHEN 'INPE' THEN Pago ELSE 0 END AS AM, 
							CASE CodConcepto WHEN 'MORA' THEN Pago ELSE 0 END AS AC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
							THEN Pago ELSE 0 END AS AIVA
							FROM (SELECT     tCsTransaccionDiaria.CodigoCuenta AS CodCuenta, tCsTransaccionDiaria.FraccionCta, 
								  tCsTransaccionDiaria.Renovado, 'CAPI' AS CodConcepto, SUM(tCsTransaccionDiaria.MontoTotalTran) AS Pago
									FROM tCsTransaccionDiaria LEFT OUTER JOIN tClOficinas AS tClOficinas_1 ON tCsTransaccionDiaria.CodOficina = tClOficinas_1.CodOficina 
									LEFT OUTER JOIN tAhClTipoTrans ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
									WHERE (tCsTransaccionDiaria.TipoTransacNivel1 = 'E') AND (tCsTransaccionDiaria.Fecha >= @PrimerCorte) AND 
											(tCsTransaccionDiaria.Fecha <= @UltimoCorte) AND (tCsTransaccionDiaria.CodSistema = 'AH') AND 
											(tCsTransaccionDiaria.CodigoCuenta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) + '-' + tCsTransaccionDiaria.FraccionCta = @Cuenta)
									GROUP BY tCsTransaccionDiaria.CodigoCuenta, tCsTransaccionDiaria.FraccionCta, tCsTransaccionDiaria.Renovado
									) AS Datos_3) 
							AS Datos_4
							GROUP BY CodCuenta, FraccionCta, Renovado
					) AS Abonos 
	RIGHT OUTER JOIN (SELECT     CodPrestamo, SUM(CK) AS CK, SUM(CI) AS CI, SUM(CM) AS CM, SUM(CC) AS CC, SUM(CIVA) AS CIVA
					  FROM          (SELECT     Cuenta AS CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN CargoD ELSE 0 END AS CK, CASE WHEN CodConcepto IN ('INTE') 
																			   THEN CargoD ELSE 0 END AS CI, CASE WHEN CodConcepto IN ('INPE') THEN CargoD ELSE 0 END AS CM, 
																			   CASE WHEN CodConcepto IN ('MORA') THEN CargoD ELSE 0 END AS CC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
																			   THEN CargoD ELSE 0 END AS CIVA
														FROM          tCsEstadoCuentaMO
														WHERE      (Cuenta = @Cuenta) AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Sistema = 'AH')) AS Datos
								GROUP BY CodPrestamo) AS Cargos RIGHT OUTER JOIN
						  tCsAhorros INNER JOIN
						  tClOficinas INNER JOIN
						  tCsPadronAhorros ON tClOficinas.CodOficina = tCsPadronAhorros.CodOficina INNER JOIN
						  tAhProductos ON tCsPadronAhorros.CodProducto = tAhProductos.idProducto ON tCsAhorros.CodCuenta = tCsPadronAhorros.CodCuenta AND 
						  tCsAhorros.FraccionCta = tCsPadronAhorros.FraccionCta AND tCsAhorros.Renovado = tCsPadronAhorros.Renovado 
	INNER JOIN
		(SELECT tCsAhorros_1.CodCuenta, tCsAhorros_1.FraccionCta, tCsAhorros_1.Renovado, tCsClientesAhorrosFecha_1.CodUsCuenta AS CodUsuario, 
		 tCsAhorros_1.SaldoCuenta AS MontoDesembolso, tCsClientesAhorrosFecha_1.Capital AS Monto, 
		 tCsClientesAhorrosFecha_1.Capital / tCsAhorros_1.SaldoCuenta * 100.000 AS Concentracion, tCsPadronCarteraDet.Integrantes, 
		 tCsPadronCarteraDet.ClienteGrupo, tClMonedas.DescMoneda
	FROM (SELECT     CodCuenta, FraccionCta, Renovado, COUNT(*) AS Integrantes, MAX(ClienteGrupo) AS ClienteGrupo
			   FROM (SELECT     tCsAhorros_2.CodCuenta, tCsAhorros_2.FraccionCta, tCsAhorros_2.Renovado, 
					 tCsClientesAhorrosFecha.CodUsCuenta AS CodUsuario, ISNULL(tCsPadronClientes_1.NombreCompleto, '') AS ClienteGrupo
					 FROM tCsClientesAhorrosFecha INNER JOIN
					tCsAhorros AS tCsAhorros_2 ON tCsClientesAhorrosFecha.Fecha = tCsAhorros_2.Fecha AND 
					tCsClientesAhorrosFecha.CodCuenta = tCsAhorros_2.CodCuenta AND 
					tCsClientesAhorrosFecha.FraccionCta = tCsAhorros_2.FraccionCta AND 
					tCsClientesAhorrosFecha.Renovado = tCsAhorros_2.Renovado LEFT OUTER JOIN
					tCsPadronClientes AS tCsPadronClientes_1 ON tCsAhorros_2.CodUsuario = tCsPadronClientes_1.CodUsuario
					WHERE (tCsAhorros_2.Fecha = @UltimoCorte) AND (tCsAhorros_2.CodCuenta + '-' + CAST(tCsAhorros_2.Renovado AS varchar(5)) 
						+ '-' + tCsAhorros_2.FraccionCta = @Cuenta)) AS Datos_2
				GROUP BY CodCuenta, FraccionCta, Renovado
			) AS tCsPadronCarteraDet 
	INNER JOIN tCsAhorros AS tCsAhorros_1 ON tCsPadronCarteraDet.CodCuenta = tCsAhorros_1.CodCuenta AND tCsPadronCarteraDet.FraccionCta = tCsAhorros_1.FraccionCta AND tCsPadronCarteraDet.Renovado = tCsAhorros_1.Renovado
	INNER JOIN tClMonedas ON tClMonedas.CodMoneda = tCsAhorros_1.CodMoneda 
	INNER JOIN tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_1 
				ON tCsClientesAhorrosFecha_1.CodCuenta = tCsAhorros_1.CodCuenta AND 
				tCsClientesAhorrosFecha_1.FraccionCta = tCsAhorros_1.FraccionCta AND tCsClientesAhorrosFecha_1.Renovado = tCsAhorros_1.Renovado AND 
				tCsClientesAhorrosFecha_1.Fecha = tCsAhorros_1.Fecha 
	
								WHERE      (tCsAhorros_1.CodCuenta + '-' + tCsAhorros_1.FraccionCta + '-' + CAST(tCsAhorros_1.Renovado AS varchar(5)) = @Cuenta) AND 
													   (tCsAhorros_1.Fecha = @UltimoCorte)
	) AS General INNER JOIN
						  tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_2 ON General.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta AND 
						  General.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta AND General.FraccionCta = tCsClientesAhorrosFecha_2.Renovado AND 
						  General.CodUsuario = tCsClientesAhorrosFecha_2.CodUsCuenta INNER JOIN
						  tCsPadronClientes ON tCsClientesAhorrosFecha_2.CodUsCuenta = tCsPadronClientes.CodUsuario INNER JOIN
						  tAhClFormaManejo ON tCsClientesAhorrosFecha_2.FormaManejo = tAhClFormaManejo.FormaManejo ON tCsAhorros.Fecha = tCsClientesAhorrosFecha_2.Fecha AND 
						  tCsAhorros.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta AND tCsAhorros.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta AND 
						  tCsAhorros.Renovado = tCsClientesAhorrosFecha_2.Renovado ON 
						  Cargos.CodPrestamo = tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) ON 
						  Abonos.CodCuenta = tCsPadronAhorros.CodCuenta AND Abonos.FraccionCta = tCsPadronAhorros.FraccionCta AND Abonos.Renovado = tCsPadronAhorros.Renovado 
						  --ON tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Vigente.CodPrestamo
						  ON tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Atrasado.CodPrestamo
	WHERE    (tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = @Cuenta) AND 
			 (tCsClientesAhorrosFecha_2.Fecha = @UltimoCorte)
--End

Drop Table #Saldos
GO