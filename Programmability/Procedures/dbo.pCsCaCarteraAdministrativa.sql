SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[pCsCaCarteraAdministrativa]  @Fecha		SmallDateTime
AS

--Use		FinamigoConsolidado
Declare @Dato Int, @Generar Int
-------------------------------------------------------------------------------------------------------------------------------------------------
--Parametros					--	Valores										--	Usuario Final												|
-------------------------------------------------------------------------------------------------------------------------------------------------
Set @Dato	= 5				--	1: Es para el "UNISAP".						--	Miriam Chavez. (Actualmente con Hector)						|
--						--	2: Es para "Requisitos Mínimos".				--	Miriam Chavez. (Actualmente con Hector)						|
--						--	3: Es para "Cartera FAP".					--	Miriam Chavez. (Actualmente con Hector)						|
--						--	4: Es para "Bansefi Riesgos".					--	Ana Romero.	(no depende de UNISAP y Actualmente con Kemy).	|
--						--	5: Es para UNISAP Administrativa.																			|
--Set @Fecha	= '20140228'			--	Corte de la Información que se desea sacar Fecha de fin de mes.												|
Set @Generar	= 0  	--	0: No genera datos para la tabla UNISAP.																	|
--						--	1: Si Genera Datos para la tabla UNISAP.																	|
------------------------------------------------------------------------------------------------------------------------------------------------|
--Nota: La información solo aparece si es que hay datos en la tabla tCsUNISAP si no hay datos hay que generarlo. 
--Si por alguna razón se cambio datos de cartera hay que volver a generar el UNISAP.
--No se recomienda volver a generar los UNISAP de Fechas anteriores.
--Si solicitan generar el archivo de MESES ANTERIORES el parametro generar debe ser =0 para evitar que se altere la información generada en ese mes. 


If @Generar = 1 And @Dato <> 4
Begin Exec pCsUNISAP2 'CA', @Fecha End
Declare @ClaseCartera	Varchar(50)

If @Dato in (1, 5)
Begin
	If @Dato = 1 
	Begin
		Set @ClaseCartera	= 'ACTIVA'
	End
	If @Dato = 5
	Begin
		Set @ClaseCartera	= 'ADMINISTRATIVA'
	End
	--SELECT        tCsUnisapCA.Fecha, tCsUnisapCA.Año, tCsUnisapCA.Mes, tCsUnisapCA.NombreCompleto, tCsUnisapCA.CodUsuario, tCsUnisapCA.CodOficina, 
	--						 tCsUnisapCA.NomOficina, tCsUnisapCA.CodProducto, tCsUnisapCA.CodPrestamo, tCsUnisapCA.Tecnologia, tCsUnisapCA.TipoCredito, tCsUnisapCA.Condicion, 
	--						 tCsUnisapCA.FechaDesembolso, tCsUnisapCA.MontoDesembolso, tCsUnisapCA.FechaVencimiento, tCsUnisapCA.TasaIntCorriente, tCsUnisapCA.TasaIntMora, 
	--						 tCsUnisapCA.NroCuotas, tCsUnisapCA.Frecuencia, tCsUnisapCA.NroDiasAtraso, tCsUnisapCA.CapitalVigente, tCsUnisapCA.CapitalVencido, 
	--						 tCsUnisapCA.InteresVigente, tCsUnisapCA.InteresVencido, tCsUnisapCA.CtaOrdInteres, tCsUnisapCA.CtaOrdMoratorio, tCsUnisapCA.SaldoPromedio, 
	--						 tCsUnisapCA.DevengadoPromedio, tCsUnisapCA.DevengadoMes, tCsUnisapCA.CtasOrdenRecuperado, tCsUnisapCA.ReservaPreventiva, 
	--						 tCsUnisapCA.ReservaP100Interes, tCsUnisapCA.FechaUltimaCapital, tCsUnisapCA.FechaUltimoInteres, tCsUnisapCA.MontoUltimoCapital, 
	--						 tCsUnisapCA.MontoUltimoInteres, tCsUnisapCA.Estado, tCsUnisapCA.Reestructurado, tCsUnisapCA.NumReprog, tCsUnisapCA.NroGarantias, tCsUnisapCA.DescGarantia, 
	--						 tCsUnisapCA.GarantiaLiquida,
	--						 tCsUnisapCA.GarantiaPrendaria,
	--						 tCsUnisapCA.GarantiaHipotecaria,
	--						 tCsUnisapCA.GarantiaOtras, 
	--						 tCsUnisapCA.Formalizada, tCsUnisapCA.Redescuento, tCsUnisapCA.NemFondo, tCsUnisapCA.EPreventiva, tCsUnisapCA.CargoMora, tCsUnisapCA.PagoXMora, 
	--						 tCsUnisapCA.Comision, tCsUnisapCA.MoratorioVigente, tCsUnisapCA.MoratorioVencido, tCsUnisapCA.CodAsesor, tCsUnisapCA.Asesor, tCsUnisapCA.CodUbigeo, 
	--						 tCsUnisapCA.FechaNacimiento, tCsUnisapCA.Edad, tCsUnisapCA.usCURP, tCsUnisapCA.UsRFC, tCsUnisapCA.EstadoCivil, tCsUnisapCA.Sexo, 
	--						 tCsUnisapCA.RubroNegocio, tCsUnisapCA.Actividad, tCsUnisapCA.GradoInstruccion, tCsUnisapCA.EstadoDireccion, tCsUnisapCA.Municipio, tCsUnisapCA.Lugar, 
	--						 tCsUnisapCA.Direccion, tCsUnisapCA.FechaCastigo, tCsUnisapCA.DiasUltimaCancelacion
	--FROM            tCsUnisapCA with(nolock) INNER JOIN
	--						 tCsCartera with(nolock) ON tCsUnisapCA.Fecha = tCsCartera.Fecha AND tCsUnisapCA.CodPrestamo = tCsCartera.CodPrestamo
	--WHERE        (tCsUnisapCA.Fecha = @Fecha) AND (tCsCartera.Cartera = @ClaseCartera)
	--ORDER BY tCsCartera.CodPrestamo
	SELECT u.Fecha, u.Año, u.Mes, u.NombreCompleto, u.CodUsuario, u.CodOficina, 
  u.NomOficina, u.CodProducto, u.CodPrestamo, u.Tecnologia, u.TipoCredito, u.Condicion, 
  u.FechaDesembolso, u.MontoDesembolso, u.FechaVencimiento, u.TasaIntCorriente, u.TasaIntMora, 
  u.NroCuotas, u.Frecuencia, u.NroDiasAtraso, u.CapitalVigente, u.CapitalVencido, 
  u.InteresVigente, u.InteresVencido, u.CtaOrdInteres, u.CtaOrdMoratorio, u.SaldoPromedio, 
  u.DevengadoPromedio, u.DevengadoMes, u.CtasOrdenRecuperado, u.ReservaPreventiva, 
  u.ReservaP100Interes, u.FechaUltimaCapital, u.FechaUltimoInteres, u.MontoUltimoCapital, 
  u.MontoUltimoInteres, u.Estado, u.Reestructurado, u.NumReprog, u.NroGarantias, u.DescGarantia, 
  case when p.saldocapital=0 then 0 else ((u.capitalvigente+u.capitalvencido)/p.saldocapital)*u.GarantiaLiquida end GarantiaLiquida,
  u.GarantiaPrendaria,
  u.GarantiaHipotecaria,
  u.GarantiaOtras, 
  u.Formalizada, u.Redescuento, u.NemFondo, u.EPreventiva, u.CargoMora, u.PagoXMora, 
  u.Comision, u.MoratorioVigente, u.MoratorioVencido, u.CodAsesor, u.Asesor, u.CodUbigeo, 
  u.FechaNacimiento, u.Edad, u.usCURP, u.UsRFC, u.EstadoCivil, u.Sexo, 
  u.RubroNegocio, u.Actividad, u.GradoInstruccion, u.EstadoDireccion, u.Municipio, u.Lugar, 
  u.Direccion, u.FechaCastigo, u.DiasUltimaCancelacion
  FROM tCsUnisapCA u with(nolock) 
  INNER JOIN tCsCartera with(nolock) ON u.Fecha = tCsCartera.Fecha AND u.CodPrestamo = tCsCartera.CodPrestamo
  left outer join (select fecha,codprestamo,sum(saldocapital) saldocapital from tCsCarteradet with(nolock)
  where fecha=@fecha
  group by fecha,codprestamo) p on p.codprestamo=u.codprestamo
  WHERE (u.Fecha = @fecha) AND (tCsCartera.Cartera = @ClaseCartera)
  ORDER BY tCsCartera.CodPrestamo
End

If @Dato = 2
Begin
	SELECT        tCsUnisapCA.NombreCompleto, tCsUnisapCA.CodUsuario, tCsUnisapCA.CodPrestamo, tCsUnisapCA.TipoCredito, tCsUnisapCA.Condicion, 
							 tCsUnisapCA.FechaDesembolso, tCsUnisapCA.MontoDesembolso, tCsUnisapCA.FechaVencimiento, tCsUnisapCA.TasaIntCorriente, tCsUnisapCA.TasaIntMora, 
							 tCsUnisapCA.NroCuotas, ISNULL(CAST(tCaClModalidadPlazo.Plazo AS Varchar(5)), 'No especificado') AS Frecuencia, tCsUnisapCA.NroDiasAtraso, 
							 tCsUnisapCA.CapitalVigente, tCsUnisapCA.CapitalVencido, tCsUnisapCA.InteresVigente + tCsUnisapCA.MoratorioVigente AS IneteresVigente, 
							 tCsUnisapCA.InteresVencido + tCsUnisapCA.MoratorioVencido AS Interesvencido, tCsUnisapCA.CtaOrdInteres + tCsUnisapCA.CtaOrdMoratorio AS InteresCTaOrden, 
							 tCsUnisapCA.SaldoPromedio, tCsUnisapCA.DevengadoMes + tCsUnisapCA.CtasOrdenRecuperado AS InteresDelMes, 
							 CASE WHEN tCsUnisapCA.Estado IN ('VENCIDO') THEN tCsCarteraDet.SReservaCapital ELSE 0 END AS ProvisionCapitalCAVE, 
							 CASE WHEN tCsUnisapCA.Estado IN ('VENCIDO') THEN tCsCarteraDet.SReservainteres ELSE 0 END AS ProvisionIntereslCAVE, '' AS tres, '' AS cuatro, '' AS cinco, 
							 'NO' AS Microcredito, '' AS siete, tCPClEstado.Estado, tClUbigeo.DescUbiGeo, '' AS Ocho, '' AS Nueve, '' AS Diez, '' AS [ONCE], '' AS Doce, '' AS Trece, 
							 tCsUnisapCA.Redescuento, tCsUnisapCA.NemFondo, '' AS Catorce, '' AS Quince, '' AS Diesisies, '' AS Diesisiete, '' AS Diesiocho, 
							 ISNULL(dbo.fduFechaATexto(tCsUnisapCA.FechaUltimaCapital, 'DD') + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimaCapital, 'MM') 
							 + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimaCapital, 'AAAA'), '') AS FechaUltimaCapital, ISNULL(dbo.fduFechaATexto(tCsUnisapCA.FechaUltimoInteres, 'DD') 
							 + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimoInteres, 'MM') + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimoInteres, 'AAAA'), '') AS FechaUltimoInteres, 
							 ISNULL(tCsUnisapCA.MontoUltimoCapital, 0) AS MontoUltimoCapital, ISNULL(tCsUnisapCA.MontoUltimoInteres, 0) AS MontoUltimoInteres, 
							 tCsUnisapCA.Estado AS ESta, tCsUnisapCA.Reestructurado
	FROM            tCsCarteraDet with(nolock) INNER JOIN
							 tCsUnisapCA with(nolock) ON tCsCarteraDet.Fecha = tCsUnisapCA.Fecha AND tCsCarteraDet.CodPrestamo = tCsUnisapCA.CodPrestamo AND 
							 tCsCarteraDet.CodUsuario = tCsUnisapCA.CodUsuario INNER JOIN
							 tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN
							 tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo LEFT OUTER JOIN
							 tCPClEstado RIGHT OUTER JOIN
							 tClUbigeo ON tCPClEstado.CodEstado = tClUbigeo.CodEstado ON tCsUnisapCA.CodUbigeo = tClUbigeo.CodUbiGeo
	WHERE        (tCsCartera.Cartera IN ('ACTIVA')) AND (tCsUnisapCA.Fecha = @Fecha)
End

If @Dato = 3
Begin

	CREATE TABLE #XXX (
		[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
		[CodUsuario] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
		[MontoCuota] [money] NOT NULL ,
		[CodConcepto] [varchar] (5) COLLATE Modern_Spanish_CI_AI NOT NULL ,
		[SecCuota] [smallint] NOT NULL ,
		[FechaInicio] [smalldatetime] NOT NULL ,
		[FechaVencimiento] [smalldatetime] NOT NULL 
	) 

	Insert into #XXX
	SELECT     tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.MontoCuota, tCsPadronPlanCuotas.CodConcepto, 
						  tCsPadronPlanCuotas.SecCuota, tCsPadronPlanCuotas.FechaInicio, tCsPadronPlanCuotas.FechaVencimiento
	FROM         tCsPadronPlanCuotas with(nolock) INNER JOIN
						  tCsCartera tCsCartera_1 with(nolock) ON tCsPadronPlanCuotas.CodPrestamo = tCsCartera_1.CodPrestamo
	WHERE     (tCsCartera_1.Fecha = @Fecha) AND (tCsCartera_1.Cartera IN ('ACTIVA'))


	SELECT     tCsUnisapCA.CodUsuario AS NumeroSocio, tCsUnisapCA.NombreCompleto AS NombreAcreditado, tCsUnisapCA.CodPrestamo AS NumeroCredito, 
						  tClOficinas.NomOficina AS Sucursal, CASE rtrim(Ltrim(Isnull(Judicial, ''))) WHEN '' THEN 'ADMINISTRATIVA O PREVENTIVA' ELSE Upper(Judicial) 
						  END AS SituacionJuridica, ISNULL(Relacionado.CreditoRelacionado, 'NO') AS CreditoRelacionado, UPPER(ISNULL(tUsClTipoPersona.Tipo, 'TIPO DESCONOCIDO')) 
						  AS TipoPersona, CASE WHEN IsNUll(tCsPadronCarteraDet.SecuenciaCliente, 0) > 1 THEN 'SI' ELSE 'NO' END AS Buro, 
						  ISNULL(dbo.fduFechaATexto(tCsUnisapCA.FechaDesembolso, 'DD') + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaDesembolso, 'MM') 
						  + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaDesembolso, 'AAAA'), '') AS FechaOtorgamiento, tCsUnisapCA.TipoCredito, 
						  CASE tCsCartera.TipoReprog WHEN 'SINRE' THEN 'ORDINARIO' WHEN 'REEST' THEN 'REESTRUCTURADO' ELSE 'DESCONOCIDO' END AS EstatusCredito, 
						  'NO MARGINADA' AS TipoZona, tCsUnisapCA.TipoCredito AS TipoEstimacion, 'CAPITAL E INTERÉS PERIÓDICO FIJO' AS CondicionesPago, 
						  tCsUnisapCA.MontoDesembolso AS MontoOriginalCredito, tCsUnisapCA.CapitalVigente + tCsUnisapCA.CapitalVencido AS SaldoInsolutoCapital, 
						  tCsUnisapCA.InteresVigente + tCsUnisapCA.InteresVencido + tCsUnisapCA.MoratorioVigente + tCsUnisapCA.MoratorioVencido AS InteresDevengadoNoCobrado, 
						  ISNULL(dbo.fduFechaATexto(tCsUnisapCA.FechaVencimiento, 'DD') + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaVencimiento, 'MM') 
						  + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaVencimiento, 'AAAA'), '') AS FechaVencimientoCredito, DATEDIFF(Month, tCsUnisapCA.FechaDesembolso, 
						  tCsUnisapCA.FechaVencimiento) AS PlazoCredito, tCsUnisapCA.NroCuotas, FC.FrecuenciaDiasCapital, FI.FrecuenciaDiasInteres, 
						  derivedtbl_1.MontoCuota AS ImportePago, tCsUnisapCA.TasaIntCorriente AS TasaInteresAnual, ISNULL(dbo.fduFechaATexto(tCsUnisapCA.FechaUltimaCapital, 'DD') 
						  + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimaCapital, 'MM') + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimaCapital, 'AAAA'), '') 
						  AS FechaUltimoPagoCapital, ISNULL(dbo.fduFechaATexto(tCsUnisapCA.FechaUltimoInteres, 'DD') + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimoInteres, 'MM') 
						  + '/' + dbo.fduFechaATexto(tCsUnisapCA.FechaUltimoInteres, 'AAAA'), '') AS FechaUltimoPagoInteres, Isnull(vCsCaGarantias.MDG, 'NINGUNA') AS TipoGarantia, 
						  ISNULL(vCsCaGarantias.GarantiaLiquida, 0) AS DepositosGarantiaLiquida, ISNULL(vCsCaGarantias.GarantiaPrendaria, 0) AS ValorGarantiaPrendaria, 
						  isnull(vCsCaGarantias.GarantiaHipotecaria, 0) AS ValorGarantiaHipotecaria, tCsUnisapCA.NroDiasAtraso, tCsUnisapCA.EPreventiva AS ReservasTotales
	FROM         tCsUnisapCA with(nolock) INNER JOIN
						  tCsCartera with(nolock) ON tCsUnisapCA.Fecha = tCsCartera.Fecha AND tCsUnisapCA.CodPrestamo = tCsCartera.CodPrestamo INNER JOIN
						  tClOficinas ON tCsUnisapCA.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
						  (Select * from vCsCaGarantias Where Fecha = @Fecha And Cartera = 'ACTIVA') As vCsCaGarantias ON tCsUnisapCA.Fecha = vCsCaGarantias.Fecha AND tCsUnisapCA.CodPrestamo = vCsCaGarantias.CodPrestamo LEFT OUTER JOIN
							  (SELECT     tCsPadronPlanCuotas_2.CodPrestamo, tCsPadronPlanCuotas_2.CodUsuario, tCsPadronPlanCuotas_2.MontoCuota
								FROM          [#XXX] AS tCsPadronPlanCuotas_2 INNER JOIN
													   tCsCartera AS tCsCartera_1 with(nolock) ON tCsPadronPlanCuotas_2.CodPrestamo = tCsCartera_1.CodPrestamo AND 
													   tCsPadronPlanCuotas_2.SecCuota = tCsCartera_1.NroCuotasPagadas + 1
								WHERE      (tCsPadronPlanCuotas_2.CodConcepto = 'CAPI') AND (tCsCartera_1.Fecha = @Fecha) AND (tCsCartera_1.Cartera IN ('ACTIVA'))) AS derivedtbl_1 ON 
						  tCsUnisapCA.CodUsuario = derivedtbl_1.CodUsuario AND tCsUnisapCA.CodPrestamo = derivedtbl_1.CodPrestamo LEFT OUTER JOIN
							  (SELECT     tCsPadronPlanCuotas_1.CodPrestamo, tCsPadronPlanCuotas_1.CodUsuario, AVG(DATEDIFF(day, tCsPadronPlanCuotas_1.FechaInicio, 
													   tCsPadronPlanCuotas_1.FechaVencimiento)) AS FrecuenciaDiasInteres
								FROM          [#XXX] AS tCsPadronPlanCuotas_1 INNER JOIN
													   tCsCartera AS tCsCartera_1 with(nolock) ON tCsPadronPlanCuotas_1.CodPrestamo = tCsCartera_1.CodPrestamo
								WHERE      (tCsPadronPlanCuotas_1.CodConcepto = 'INTE') AND (tCsCartera_1.Fecha = @Fecha) AND (tCsCartera_1.Cartera IN ('ACTIVA'))
								GROUP BY tCsPadronPlanCuotas_1.CodPrestamo, tCsPadronPlanCuotas_1.CodUsuario) AS FI ON tCsUnisapCA.CodPrestamo = FI.CodPrestamo AND 
						  tCsUnisapCA.CodUsuario = FI.CodUsuario LEFT OUTER JOIN
							  (SELECT     tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, AVG(DATEDIFF(day, tCsPadronPlanCuotas.FechaInicio, 
													   tCsPadronPlanCuotas.FechaVencimiento)) AS FrecuenciaDiasCapital
								FROM          [#XXX] AS tCsPadronPlanCuotas INNER JOIN
													   tCsCartera AS tCsCartera_1 with(nolock) ON tCsPadronPlanCuotas.CodPrestamo = tCsCartera_1.CodPrestamo
								WHERE      (tCsPadronPlanCuotas.CodConcepto = 'CAPI') AND (tCsCartera_1.Fecha = @Fecha) AND (tCsCartera_1.Cartera IN ('ACTIVA'))
								GROUP BY tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario) AS FC ON tCsUnisapCA.CodPrestamo = FC.CodPrestamo AND 
						  tCsUnisapCA.CodUsuario = FC.CodUsuario LEFT OUTER JOIN
						  tCsPadronCarteraDet with(nolock) ON tCsUnisapCA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
						  tCsUnisapCA.CodUsuario = tCsPadronCarteraDet.CodUsuario LEFT OUTER JOIN
						  tUsClTipoPersona RIGHT OUTER JOIN
						  tCsPadronClientes with(nolock) ON tUsClTipoPersona.CodTPersona = tCsPadronClientes.CodTPersona ON 
						  tCsUnisapCA.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
							  (SELECT     CURP, RFC, Paterno, Materno, Nombres, Nacimiento, Ingreso, Salida, CodUsuario, CodOficina, Correo, CopiaCorreo, DataNegocio, CodEmpleado, 
													   CodOficinaNom, CodPuesto, Estado, CE, Domicilio, Ubicacion, Tiempo, EstadoCivil, Escolaridad, TipoPropiedad, Celular, 
													   'SI' AS CreditoRelacionado
								FROM          tCsEmpleados with(nolock)
								WHERE      (Ingreso <= @Fecha) AND (ISNULL(Salida, @Fecha + 1) > @Fecha)) AS Relacionado ON tCsUnisapCA.CodUsuario = Relacionado.CodUsuario
	WHERE     (tCsUnisapCA.Fecha = @Fecha) AND (tCsCartera.Cartera IN ('ACTIVA'))

		Drop Table #XXX

	End
	If @Dato = 4
	Begin
		Declare @Periodo Varchar(6)

		Set @Periodo	= dbo.fduFechaATexto(@Fecha, 'AAAAMM')

		Declare @Actual		SmallDateTime
		Declare @Anterior	SmallDateTime

		Set @Actual		= DateAdd(Day, -1, Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, Cast(@Periodo + '01' As SmallDateTime)), 'AAAAMM') + '01' As SmallDateTime))
		Set @Anterior	= DateAdd(Day, -1, Cast(@Periodo + '01' As SmallDateTime))

		Print @Actual
		Print @Anterior

		Exec pCsCalcularDatosCartera 4, @Actual 

		SELECT        tCsCartera.Fecha, tCsCartera.CodPrestamo AS Numero, tCsCartera.FechaDesembolso AS FechaPtmo, tCsCarteraDet.MontoDesembolso AS MontoInicial, 
								 tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido AS SaldoActual,
								  tCaProdPerTipoCredito.Descripcion AS FinLacp, tCaClDestino.DescDestino AS Finalidad, tCsCartera.Estado AS Estatus, ISNULL(Anterior.CarteraVencidaAnterior, 0) 
								 AS CarteraVencidaAnterior, tCsCartera.FechaVencimiento, DATEDIFF(day, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento) AS DiasVencidos, 
								 ISNULL(ROUND(Ahorro.Ahorro, 2), 0) AS Ahorro, tCsCarteraDet.InteresVigente AS CVigIO, tCsCarteraDet.MoratorioVigente AS CVigIM, 
								 tCsCarteraDet.InteresVencido AS CVenIO, tCsCarteraDet.MoratorioVencido AS CVenIM, tClOficinas.NomOficina AS Sucursal, SUBSTRING(vGnlUbigeo.CP2_Municipio, 
								 8, 100) AS Poblacion, Case vGnlUbigeo.ZonaLugar When 'Urbano' Then 'Semiurbano' Else vGnlUbigeo.ZonaLugar End AS ZG, dbo.fduEdad(tCsPadronClientes.FechaNacimiento, tCsCartera.Fecha) AS Edad, tUsClSexo.SHF AS Sexo, 
								 CASE tUsClSexo.SHF WHEN 'H' THEN tUsClEstadoCivil.Masculino WHEN 'M' THEN tUsClEstadoCivil.Femenino ELSE 'Desconocido' END AS EstadoCivil, 
								 tUsClTipoPropiedad.TipoPro AS TipoDeVivienda, ISNULL(tCsPadronClientes.TiempoResidirDirFam, tCsPadronClientes.TiempoResidirDirNeg) 
								 AS TiempoDeResidencia, CAST(tCsCartera.NroCuotas AS Varchar(10)) 
								 + ' ' + CASE WHEN tCsCartera.NroCuotas = 1 THEN tCaClModalidadPlazo.Singular WHEN tCsCartera.NroCuotas > 1 THEN tCaClModalidadPlazo.Plural END AS Plazo,
								  tClActividad.Nombre as Actividad, CASE WHEN DateDiff(Day, tCsCartera.Fecha, FechaVencimiento) < 0 THEN 0 ELSE DateDiff(Day, tCsCartera.Fecha, FechaVencimiento) 
								 END AS DXV, tCaProdPerTipoCredito.Descripcion AS TipoDePrestamo, tCaProducto.NombreProdCorto AS PlanDelCredito, tCsCartera.TasaIntCorriente AS Tasa, 
								 tCsCartera.NroCuotasPagadas AS NumeroDeAmortizaciones, tCsCartera.NrodiasEntreCuotas AS FrecuenciaDePago, DATEDIFF(Day, tCsCartera.FechaDesembolso, 
								 tCsCartera.FechaVencimiento) / 30 AS PlazoEnMeses, 'SI' AS Contrato, ROUND(Cuotas.Amortizacion, 2) AS Amortizacion, 
								 CASE WHEN NroDiasAtraso = 0 THEN 0 WHEN NroDiasAtraso > 0 THEN CuotaActual - NroCuotasPagadas END AS PagosVencidosConsecutivos, 
								 ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroComprometido, ISNULL(ROUND(Ahorro.Ahorro, 2), 0) - ISNULL(ROUND(Ahorro.Garantia, 2), 0) 
								 AS AhorroNoComprometidoConCredito, ISNULL(Garantia.Garantia, 0) AS Garantia, 
								 GarantiaReal = Case	When ISNULL(Garantia.Garantia, 0) = 0 Then 0
														When ISNULL(ROUND(Ahorro.Garantia, 2), 0) > ( 
															tCsCarteraDet.SaldoCapital		+ tCsCarteraDet.InteresVigente		+ 
															tCsCarteraDet.InteresVencido	+ tCsCarteraDet.MoratorioVigente	+ 
															tCsCarteraDet.MoratorioVencido)
														Then ISNULL(ROUND(Ahorro.Garantia, 2), 0)
														When ISNULL(ROUND(Ahorro.Garantia, 2), 0) < ( 
															tCsCarteraDet.SaldoCapital		+ tCsCarteraDet.InteresVigente		+ 
															tCsCarteraDet.InteresVencido	+ tCsCarteraDet.MoratorioVigente	+ tCsCarteraDet.MoratorioVencido) 
															And ISNULL(Garantia.Garantia, 0) > ( 
															tCsCarteraDet.SaldoCapital		+ tCsCarteraDet.InteresVigente		+ 
															tCsCarteraDet.InteresVencido	+ tCsCarteraDet.MoratorioVigente	+ 
															tCsCarteraDet.MoratorioVencido)
														Then ( tCsCarteraDet.SaldoCapital		+ tCsCarteraDet.InteresVigente		+ 
																tCsCarteraDet.InteresVencido	+ tCsCarteraDet.MoratorioVigente	+ 
																tCsCarteraDet.MoratorioVencido) 
														When ISNULL(ROUND(Ahorro.Garantia, 2), 0) < ( 
															tCsCarteraDet.SaldoCapital		+ tCsCarteraDet.InteresVigente		+ 
															tCsCarteraDet.InteresVencido	+ tCsCarteraDet.MoratorioVigente	+ tCsCarteraDet.MoratorioVencido) 
															And ISNULL(Garantia.Garantia, 0) < ( 
															tCsCarteraDet.SaldoCapital		+ tCsCarteraDet.InteresVigente		+ 
															tCsCarteraDet.InteresVencido	+ tCsCarteraDet.MoratorioVigente	+ 
															tCsCarteraDet.MoratorioVencido)
														Then ISNULL(Garantia.Garantia, 0)											
												End,
								 CASE WHEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
								  - Isnull(Garantia.Garantia, 0) 
								 < 0 THEN 0 ELSE tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
								  - Isnull(Garantia.Garantia, 0) END AS MontoExpuesto, tCsCarteraDet.SReservaCapital + tCsCarteraDet.SReservaInteres AS ReservaExpuesta, 
								 tCsCarteraDet.InteresVigente + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVencido AS Interes, 
								 tCsCarteraDet.SReservaInteres AS ReservaInteres, tCsCarteraDet.IDA, tCsCartera.NroDiasAtraso, tCsCarteradet.PReservaCapital    
		FROM            (SELECT        tCsCarteraDet_1.CodPrestamo, tCsCarteraDet_1.CodUsuario, 
												tCsCarteraDet_1.CapitalVencido + tCsCarteraDet_1.InteresVencido + tCsCarteraDet_1.MoratorioVencido AS CarteraVencidaAnterior
								  FROM          tCsCarteraDet AS tCsCarteraDet_1 with(nolock) INNER JOIN
												tCsCartera AS tCsCartera_1 with(nolock) ON tCsCarteraDet_1.Fecha = tCsCartera_1.Fecha AND tCsCarteraDet_1.CodPrestamo = tCsCartera_1.CodPrestamo
								  WHERE        (tCsCarteraDet_1.Fecha = @Anterior)) AS Anterior RIGHT OUTER JOIN
								 tCsCartera with(nolock) INNER JOIN
								 tCsCarteraDet with(nolock) ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
								 tCaProdPerTipoCredito ON tCsCartera.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito INNER JOIN
								 tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
								 tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto ON Anterior.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
								 Anterior.CodUsuario = tCsCarteraDet.CodUsuario LEFT OUTER JOIN
									 (SELECT        Fecha, Codigo, SUM(Garantia) AS Garantia
									   FROM            tCsDiaGarantias AS tCsDiaGarantias_1 with(nolock)
									   WHERE        (Fecha = @Actual)
									   GROUP BY Fecha, Codigo) AS Garantia ON tCsCarteraDet.Fecha = Garantia.Fecha AND tCsCarteraDet.CodPrestamo = Garantia.Codigo LEFT OUTER JOIN
									 (SELECT        CodPrestamo, CodUsuario, AVG(Cuota) AS Amortizacion
									   FROM            (SELECT        CodPrestamo, CodUsuario, SecCuota, SUM(MontoCuota) AS Cuota
																 FROM            tCsPadronPlanCuotas with(nolock)
																 WHERE        (CodConcepto IN ('CAPI', 'INTE', 'IVAIT'))
																 GROUP BY CodPrestamo, CodUsuario, SecCuota) AS Datos_1
									   GROUP BY CodPrestamo, CodUsuario) AS Cuotas ON tCsCarteraDet.CodPrestamo = Cuotas.CodPrestamo AND 
								 tCsCarteraDet.CodUsuario = Cuotas.CodUsuario LEFT OUTER JOIN
								 tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo LEFT OUTER JOIN
								 tUsClSexo RIGHT OUTER JOIN
								 tUsClTipoPropiedad RIGHT OUTER JOIN
								 tClActividad RIGHT OUTER JOIN
								 tUsClEstadoCivil INNER JOIN
								 tCsPadronClientes with(nolock) ON tUsClEstadoCivil.CodEstadoCivil = tCsPadronClientes.CodEstadoCivil ON tClActividad.CodActividad = tCsPadronClientes.LabCodActividad ON 
								 tUsClTipoPropiedad.CodTipoPro = ISNULL(tCsPadronClientes.TipoPropiedadDirFam, tCsPadronClientes.TipoPropiedadDirNeg) ON 
								 tUsClSexo.Sexo = tCsPadronClientes.Sexo ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
								 vGnlUbigeo ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) = vGnlUbigeo.CodUbiGeo LEFT OUTER JOIN
									 (SELECT        Fecha, CodPrestamo, CodUsCuenta, SUM(SaldoCuenta) AS Ahorro, SUM(Garantia) AS Garantia
		FROM            (SELECT DISTINCT 
															tCsClientesAhorrosFecha.Fecha, tCsClientesAhorrosFecha.CodUsCuenta, tCsClientesAhorrosFecha.CodCuenta, tCsClientesAhorrosFecha.FraccionCta, 
															tCsClientesAhorrosFecha.Renovado, tCsAhorros.SaldoCuenta, Garantias.Garantia, Garantias.CodPrestamo
								  FROM            tCsClientesAhorrosFecha with(nolock) INNER JOIN
															tCsAhorros with(nolock) ON tCsClientesAhorrosFecha.Fecha = tCsAhorros.Fecha AND tCsClientesAhorrosFecha.CodCuenta = tCsAhorros.CodCuenta AND 
															tCsClientesAhorrosFecha.FraccionCta = tCsAhorros.FraccionCta AND tCsClientesAhorrosFecha.Renovado = tCsAhorros.Renovado LEFT OUTER JOIN
																(SELECT        Fecha, Codigo AS CodPrestamo, DocPropiedad, SUM(Garantia) AS Garantia
																  FROM            tCsDiaGarantias with(nolock)
																  GROUP BY Fecha, DocPropiedad, Codigo) AS Garantias ON tCsAhorros.Fecha = Garantias.Fecha AND 
															tCsAhorros.CodCuenta = Garantias.DocPropiedad
								  WHERE        (tCsAhorros.Fecha = @Actual)) AS Datos
		GROUP BY Fecha, CodUsCuenta, CodPrestamo) AS Ahorro ON tCsCarteraDet.CodUsuario = Ahorro.CodUsCuenta AND tCsCarteraDet.Fecha = Ahorro.Fecha And tCsCarteraDet.CodPrestamo = Ahorro.CodPrestamo LEFT OUTER JOIN
								 tCaClDestino ON tCsCarteraDet.CodDestino = tCaClDestino.CodDestino
		WHERE        (tCsCartera.Fecha = @Actual) AND (tCsCartera.Cartera = 'ACTIVA')
End
GO