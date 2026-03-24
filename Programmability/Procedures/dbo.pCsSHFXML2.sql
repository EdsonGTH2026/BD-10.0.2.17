SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[pCsSHFXML2] 
@Periodo 	Varchar(6), 	@CodProducto	Varchar(3),  
@PlazoI		Int, 		@PlazoF	 	Int, 
@PorcIngresos	Decimal(10,2), 	@PorcAceptacion	Decimal(10,2),
@Proceso 	Varchar(1), 	@Prestamo 	Varchar(50)
As

declare @T1 datetime
declare @T2 datetime

set nocount on

Declare @FI			SmallDateTime
Declare @FF			SmallDateTime
Declare @FA			SmallDateTime
Declare @FC			SmallDateTime
Declare @TipoEnvio		Varchar(1)
Declare @TipoTransaccion 	Int
Declare @movTipo		Int
Declare @movClave		Int
Declare @movAplica		Int

Declare @CodPrestamo 		Varchar(25)
Declare @CodUsuario		Varchar(15)
Declare @Contador		Int

Declare @CorteAnterior 		SmallDateTime

set @T1 = getdate()

Set @CorteAnterior 	= Dateadd(day, -1, Cast(@Periodo + '01' as SmallDateTime)) 

Print 'PROCESO: ' +  Cast(Getdate() as Varchar(100))

--VALORES FIJO
Set @TipoEnvio		= 'S'
Set @TipoTransaccion 	= 2

Set @FI = Cast(@Periodo + '01' as SmallDateTime)
Set @FF = Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, @FI), 'AAAAMM') + '01' as SmallDateTime) - 1

SELECT  @FA =   FechaConsolidacion
FROM         vCsFechaConsolidacion

If @FA <= @FF
Begin
	Set @FF = @FA
End

Delete From tSHFPeriodo
Where Periodo = dbo.fduFechaAtexto(DateAdd(Month, 1, @FI), 'AAAAMM') 

Update tSHFPeriodo
Set Activo = 0

Insert Into tSHFPeriodo (Periodo, ReporteInicio, ReporteFin, Registro, Activo) 
Values			(dbo.fduFechaAtexto(DateAdd(Month, 1, @FI), 'AAAAMM') , @FI, @FF, GetDate(), 1)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[01tSHFOtorgamiento]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[01tSHFOtorgamiento] End

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[02tSHFComportamiento]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[02tSHFComportamiento] End

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[03tSHFComportamientoDetalle]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[03tSHFComportamientoDetalle] End

set @T2 = getdate()
print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. antes If @proceso'
set @T1 = getdate()

If @Proceso = 'P'
Begin	
	Delete From tSHFOtorgamiento
	Where ReporteInicio = @FI AND (SUBSTRING(CodPrestamo, 4, 3) = @CodProducto)
	
	Delete From tSHFComportamiento 
	Where ReporteInicio = @FI AND (SUBSTRING(CodPrestamo, 4, 3) = @CodProducto)
	
	Delete From tSHFComportamientoDetalle 
	Where ReporteInicio = @FI AND (SUBSTRING(CodPrestamo, 4, 3) = @CodProducto)

set @T2 = getdate()
print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso del'
set @T1 = getdate()

-- 26seg
create table #tCsPadronPlanCuotas (
  codprestamo varchar(25),
  codusuario varchar(15),
  seccuota smallint,
  NumeroPlan tinyint,
  montocuota money
)
insert into #tCsPadronPlanCuotas 
SELECT     CodPrestamo, CodUsuario, SecCuota, NumeroPlan,montocuota
FROM          tCsPadronPlanCuotas with(nolock)
WHERE      (CodConcepto IN ('CAPI', 'INTE', 'IVAIT')) AND (SUBSTRING(CodPrestamo, 5, 3) = '123')

set @T2 = getdate()
print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso tmps #tCsPadronPlanCuotas'
set @T1 = getdate()

---0
create table #tCsCarteraDet(
  codusuario varchar(15),
  DeudaTotal money
)
insert into #tCsCarteraDet
SELECT     CodUsuario, SUM(SaldoCapital + SaldoInteres + SaldoMoratorio + OtrosCargos + Impuestos + CargoMora) AS DeudaTotal
FROM          tCsCarteraDet with(nolock)
WHERE      (Fecha = @FF)
GROUP BY CodUsuario

set @T2 = getdate()
print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso tmps #tCsCarteraDet'
set @T1 = getdate()

	Insert Into tSHFOtorgamiento 
		(ReporteInicio, 	ReporteFin, 	Emisor, 	LineaNegocio, 	TipoTransaccion, 	TipoEnvio, 	idLineaCredito, 	
		 Originador,		CodPrestamo, 	CodUsuario, 	CodOficina, 	Monto, 			Divisa,		Frecuencia, 	
		 MontoPago, 		Desembolso, 	Mininistracion, Vencimiento, 	Destino, 		Plazo, 		cveIC, 		
		 valIC, 		cveIM, 		valIM, 		cveCA, 		valCA, 			cveCM, 		valCM, 
		 Nombres, 		Paterno,	Materno, 	Genero, 	Nacimiento, 		EstadoCivil, 	Estudios, 
		 Dependientes, 		TipoPropeidad, 	Antiguedad, 	Municipio, 	TipoEmpleo, 		Ingresos, 	DeudaTotal, 
		 IngresosConyuge,	DeudaConyuge)
	SELECT  ReporteInicio	= @FI,
		ReporteFin   	= @FF,
		Emisor		= tClEmpresas.SHF,
		LineaNegocio	= tSHFEmpresaLineaNegocio.LineaNegocio,
		TipoTransaccion = @TipoTransaccion,
		TipoEnvio	= @TipoEnvio,
		idLineaCredito	= tCaProducto.idLineaCredito,
		Originador	= tClEmpresas.SHF,
		CodPrestamo	= Replace(tCsPadronCarteraDet.CodPrestamo, '-', ''),
		CodUsuario	= tCsPadronCarteraDet.CodUsuario,
		CodOficina	= tCsPadronCarteraDet.CodOficina,
		Monto		= tCsCarteraDet.MontoDesembolso,
		Divisa		= tClMonedas.SHF,
		Frecuencia	= tCaClModalidadPlazo.SHF,
		MontoPago	= Cuota.Cuota,
		Desembolso	= tCsCartera.FechaDesembolso,
		Mininistracion	= tCsCartera.FechaDesembolso,
		Vencimiento	= tCsCartera.FechaVencimiento,
		Destino		= tCaClDestino.SHF,
		Plazo		= Cast(DateDiff(Day, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento)/30.4375 AS Int),
		cveIC		= 1,
		valIC		= tCsCartera.TasaIntCorriente/12 , 
		cveIM		= 2,
		valIM		= tCsCartera.TasaINPE/12,	
	 	cveCA		= 1,
		valCA		= Comision.ComisionApertura,
		cveCM		= 3,
		valCM		= 400,
		Nombres		= Replace(tCsPadronClientes.Nombres, 'Ñ', 'N'),
		Paterno		= Replace(tCsPadronClientes.Paterno, 'Ñ', 'N'), 
		Materno		= Replace(tCsPadronClientes.Materno, 'Ñ', 'N'),
		Genero		= tUsClSexo.SHF,
		Nacimiento	= tCsPadronClientes.FechaNacimiento, 
		EstadoCivil	= tUsClEstadoCivil.SHF,
		Estudios	= tUsClGradoInstruccion.SHF,
		Dependientes	= IsNull(tCsPadronClientes.UsNDependientes, 0), 
		TipoPropiedad	= tUsClTipoPropiedad.SHF,
		Antiguedad	= Cast((Case When DateDiff(Year, tCsPadronClientes.FechaNacimiento, @FF) * 12 < DateDiff(Month, tCsPadronClientes.FechaIngreso, @FF)+ IsNull(tCsPadronClientes.TiempoResidirDirFam, tCsPadronClientes.TiempoResidirDirNeg)  
					Then DateDiff(Year, tCsPadronClientes.FechaNacimiento, @FF) * 12 Else DateDiff(Month, tCsPadronClientes.FechaIngreso, @FF)+ IsNull(tCsPadronClientes.TiempoResidirDirFam, tCsPadronClientes.TiempoResidirDirNeg)
					End)/ 12 as Int), -- con el Factor 12 se vuelve a meses
		Municipio	= tClUbigeo.CodEstado + tClUbigeo.CodMunicipio,
		TipoEmpleo	= 2,
		Ingresos	= Case 	When IsNull(tCsPadronClientes.IngresoMensual, 0) + IsNull(tCsPadronClientes.OtrosIngresos, 0) < CEILING(Cuota.Cuota * 100/@PorcIngresos/100) * 100 Then CEILING(Cuota.Cuota * 100/@PorcIngresos/100) * 100 
					Else 	Case 	When 	(Cuota.Cuota/(IsNull(tCsPadronClientes.IngresoMensual, 0) + IsNull(tCsPadronClientes.OtrosIngresos, 0))) * 100 >= @PorcIngresos - @PorcAceptacion And
								(Cuota.Cuota/(IsNull(tCsPadronClientes.IngresoMensual, 0) + IsNull(tCsPadronClientes.OtrosIngresos, 0))) * 100 <= @PorcIngresos Then
								IsNull(tCsPadronClientes.IngresoMensual, 0) + IsNull(tCsPadronClientes.OtrosIngresos, 0)
							Else CEILING(Cuota.Cuota * 100/@PorcIngresos/100) * 100  
						End 	
				End, 
		DeudaTotal	= DT.DeudaTotal,
		IngresosConyuge	= IsNull(tCsPadronClientes_1.IngresoMensual, 0) + IsNull(tCsPadronClientes_1.OtrosIngresos, 0),
		DeudaConyuge	= IsNull(DTC.DeudaTotal, 0)
	FROM         tUsClSexo RIGHT OUTER JOIN
	                          --(SELECT     CodUsuario, SUM(SaldoCapital + SaldoInteres + SaldoMoratorio + OtrosCargos + Impuestos + CargoMora) AS DeudaTotal
	                          --  FROM          tCsCarteraDet
	                          --  WHERE      (Fecha = @FF)
	                          --  GROUP BY CodUsuario) 
	                          #tCsCarteraDet as  DTC RIGHT OUTER JOIN
	                      tCsPadronClientes tCsPadronClientes_1 with(nolock) ON DTC.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes_1.CodUsuario RIGHT OUTER JOIN
	                      tCsPadronClientes with(nolock) ON tCsPadronClientes_1.CodUsuario = tCsPadronClientes.CodConyuge LEFT OUTER JOIN
	                      tClUbigeo ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) = tClUbigeo.CodUbiGeo LEFT OUTER JOIN
	                      tUsClTipoPropiedad ON ISNULL(tCsPadronClientes.TipoPropiedadDirFam, tCsPadronClientes.TipoPropiedadDirNeg) 
	                      = tUsClTipoPropiedad.CodTipoPro LEFT OUTER JOIN
	                      tUsClGradoInstruccion ON ISNULL(tCsPadronClientes.GradoInstruccion, 'Nulo') = tUsClGradoInstruccion.GradoInstruccion LEFT OUTER JOIN
	                      tUsClEstadoCivil ON tCsPadronClientes.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil ON 
	                      tUsClSexo.Sexo = tCsPadronClientes.Sexo RIGHT OUTER JOIN
	                      tCaProducto INNER JOIN
	                      tCsPadronCarteraDet with(nolock) ON tCaProducto.CodProducto = tCsPadronCarteraDet.CodProducto ON 
	                      tCsPadronClientes.CodUsuario = tCsPadronCarteraDet.CodUsuario RIGHT OUTER JOIN
	                          (SELECT     CodPrestamo, SUM(TotalPagado) AS ComisionApertura
	                            FROM          tCsConceptosPrestamo with(nolock)
	                            WHERE      (TipoCobro IN ('A')) AND (CodConcepto IN ('COM', 'CLC'))
	                            GROUP BY CodPrestamo) Comision RIGHT OUTER JOIN
	                      tCsCartera with(nolock) INNER JOIN
	                      tCsCarteraDet with(nolock) ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN
	                          --(SELECT     CodUsuario, SUM(SaldoCapital + SaldoInteres + SaldoMoratorio + OtrosCargos + Impuestos + CargoMora) AS DeudaTotal
	                          --  FROM          tCsCarteraDet
	                          --  WHERE      (Fecha = @FF)
	                          --  GROUP BY CodUsuario) 
	                            #tCsCarteraDet as DT ON tCsCarteraDet.CodUsuario = DT.CodUsuario COLLATE Modern_Spanish_CI_AI ON 
	                      Comision.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo ON 
	                      tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND 
	                      tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha LEFT OUTER JOIN
	                          (SELECT     CodPrestamo, CodUsuario, AVG(Cuota) AS Cuota
	                            FROM          
	                            --ojo aqui
	                            --(SELECT     CodPrestamo, CodUsuario, SecCuota, NumeroPlan, SUM(MontoCuota) AS Cuota
	                            -- FROM          tCsPadronPlanCuotas
	                            -- WHERE      (CodConcepto IN ('CAPI', 'INTE', 'IVAIT')) AND (SUBSTRING(CodPrestamo, 5, 3) = @CodProducto)
	                            -- GROUP BY CodPrestamo, CodUsuario, SecCuota, NumeroPlan) Datos
	                            --ojo aqui
	                            (select CodPrestamo, CodUsuario, SecCuota, NumeroPlan, SUM(MontoCuota) AS Cuota
                                from #tCsPadronPlanCuotas 
                                GROUP BY CodPrestamo, CodUsuario, SecCuota, NumeroPlan) datos
                                GROUP BY CodPrestamo, CodUsuario
                                ) Cuota 
                                ON tCsCarteraDet.CodPrestamo = Cuota.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
	                      tCsCarteraDet.CodUsuario = Cuota.CodUsuario COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
	                      tClMonedas ON tCsCartera.CodMoneda = tClMonedas.CodMoneda LEFT OUTER JOIN
	                      tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo LEFT OUTER JOIN
	                      tCaClDestino ON tCsCartera.CodDestino = tCaClDestino.CodDestino CROSS JOIN
	                      tClEmpresas INNER JOIN
	                      tSHFEmpresaLineaNegocio ON tClEmpresas.SHF = tSHFEmpresaLineaNegocio.Empresa
	WHERE     (tClEmpresas.CodEmpresa = 1) AND (tCaProducto.CodProducto = @CodProducto) AND (tCsCartera.FechaDesembolso >= @FI) AND 
	                      (tCsCartera.FechaDesembolso <= @FF) And Cast(DateDiff(Day, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento)/30.4375 AS Int) >= @PlazoI And
		Cast(DateDiff(Day, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento)/30.4375 AS Int) <= @PlazoF
	
	drop table #tCsPadronPlanCuotas
	drop table #tCsCarteraDet
	
	set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso insert'
  set @T1 = getdate()
	
	UPDATE    tSHFOtorgamiento
	SET              SolucionVivienda = dbo.fduFechaATexto(tCsPadronCarteraDet.Desembolso, 'AA') 
	                      + tClUbigeo.CodEstado + tClUbigeo.CodMunicipio + tCsPadronCarteraDet.CodProducto + RIGHT(tCsPadronCarteraDet.CodPrestamo, 3)
	FROM         tSHFOtorgamiento INNER JOIN
	                      tCsPadronCarteraDet with(nolock) ON tSHFOtorgamiento.CodPrestamo = REPLACE(tCsPadronCarteraDet.CodPrestamo, '-', '') INNER JOIN
	                      tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha INNER JOIN
	                      tCsPadronClientes with(nolock) ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
	                      tClUbigeo ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) = tClUbigeo.CodUbiGeo
	WHERE     (LTRIM(RTRIM(ISNULL(tSHFOtorgamiento.SolucionVivienda, ''))) = '') And  tSHFOtorgamiento.ReporteInicio = @FI And  tSHFOtorgamiento.ReporteFin = @FF

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update'
  set @T1 = getdate()

	Select * 
	Into [01tSHFOtorgamiento]
	From tSHFOtorgamiento with(nolock)
	Where CodPrestamo = Replace(@Prestamo, '-', '')  And ReporteInicio = @FI

	Print 'Insertando Desembolsos'
	Set @TipoTransaccion 	= 4
	Set @movTipo		= 6
	Set @movClave		= 101
	Set @movAplica		= 	Case @movTipo 
						When 1 Then 0 
						When 6 Then 0 
						When 7 Then 0
						When 2 Then 14
						When 3 Then 14
						When 5 Then 1234						
					End		
	INSERT INTO tSHFComportamiento (ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, CodUsuario, CodOficina, SIInicio, 
                      Disposiciones, PagosProgramado, MovFecha, MovTipo, MovClave, MovAplica, MovMonto, MovDenominacion, NroDiasAtraso, NroCuotasPagadas, 
                      UltimoPago)
	SELECT DISTINCT 
	                      tSHFOtorgamiento.ReporteInicio, tSHFOtorgamiento.ReporteFin, tSHFOtorgamiento.Emisor, tSHFOtorgamiento.LineaNegocio,  TipoTransaccion = @TipoTransaccion, 
	                      tSHFOtorgamiento.TipoEnvio, tSHFOtorgamiento.idLineaCredito, tSHFOtorgamiento.Originador, tSHFOtorgamiento.CodPrestamo, 
	                      tSHFOtorgamiento.CodUsuario, tSHFOtorgamiento.CodOficina, 0 AS SIInicio, tCsCartera.MontoDesembolso AS Disposiciones, 0 AS PagosProgramados, 
	                      tCsCarteraDet.UltimoMovimiento, @movTipo AS MovTipo, @movClave AS MovClave, @movAplica AS MovAplica, tCsCarteraDet.MontoDesembolso AS MovMonto, tClMonedas.SHF AS MovDenominacion, 
	                      tCsCartera.NroDiasAtraso, tCsCartera.NroCuotasPagadas, NULL AS UltimoPago
	FROM         tSHFOtorgamiento INNER JOIN
	                      tCsCarteraDet ON tSHFOtorgamiento.CodPrestamo = Replace(tCsCarteraDet.CodPrestamo, '-', '') AND tSHFOtorgamiento.CodUsuario = tCsCarteraDet.CodUsuario AND 
	                      tSHFOtorgamiento.ReporteInicio <= tCsCarteraDet.UltimoMovimiento AND 
	                      tSHFOtorgamiento.ReporteFin >= tCsCarteraDet.UltimoMovimiento INNER JOIN
	                      tCsCartera ON tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsCarteraDet.UltimoMovimiento = tCsCartera.Fecha AND 
	                      tCsCarteraDet.UltimoMovimiento = tCsCartera.FechaDesembolso INNER JOIN
	                      tClMonedas ON tCsCartera.CodMoneda = tClMonedas.CodMoneda
	WHERE     (tSHFOtorgamiento.ReporteFin = @FF) AND (tSHFOtorgamiento.ReporteInicio = @FI) AND tCsCartera.CodProducto = @CodProducto

  set @T2 = getdate()
    print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso insert desem'
    set @T1 = getdate()

	Select Tipo = 1, * 
	Into [02tSHFComportamiento]
	From tSHFComportamiento
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso 02tSHFComportamiento'
  set @T1 = getdate()

	Print 'Insertando Transacciones'
	Set @TipoTransaccion 	= 4
	Set @movTipo		= 5
	Set @movClave		= 700
	Set @movAplica		= 	Case @movTipo 
						When 1 Then 0 
						When 6 Then 0 
						When 7 Then 0
						When 2 Then 14
						When 3 Then 14
						When 5 Then 1234						
					End		
	
	create table #tCsCarteraDetUM(
	  codprestamo varchar(25),
	  codusuario varchar(15),
	  UltimoMovimiento smalldatetime,
	  codprestamoRE  varchar(25)
	)
	insert into #tCsCarteraDetUM
	select codprestamo,codusuario,ultimomovimiento,REPLACE(tCsCarteraDet.CodPrestamo, '-', '') codprestamoRE from tCsCarteraDet with(nolock)
	--where (tCsCarteraDet.UltimoMovimiento <= '20120131') AND (tCsCarteraDet.UltimoMovimiento >= '20120101')
	where (tCsCarteraDet.UltimoMovimiento <= @FF) AND (tCsCarteraDet.UltimoMovimiento >= @FI) 
	
	INSERT INTO tSHFComportamiento (ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, CodUsuario, CodOficina, SIInicio, 
                      Disposiciones, PagosProgramado, MovFecha, MovTipo, MovClave, MovAplica, MovMonto, MovDenominacion, NroDiasAtraso, NroCuotasPagadas, 
                      UltimoPago)
	SELECT DISTINCT 
	                      ReporteInicio = @FI, ReporteFin = @FF, tSHFOtorgamiento.Emisor, tSHFOtorgamiento.LineaNegocio, TipoTransaccion = @TipoTransaccion, 
	                      tSHFOtorgamiento.TipoEnvio, tSHFOtorgamiento.idLineaCredito, tSHFOtorgamiento.Originador, tSHFOtorgamiento.CodPrestamo, 
	                      tSHFOtorgamiento.CodUsuario, tSHFOtorgamiento.CodOficina, 0 AS SIInicio, 0 AS Disposiciones, 0 AS PagosProgramados, 
	                      tCsCarteraDet.UltimoMovimiento AS UltimoMovimiento, 
				@movTipo AS MovTipo, @movClave AS MovClave, @movAplica AS MovAplica, Null AS MovMonto, tClMonedas.SHF AS MovDenominacion, 
	                      tCsCartera.NroDiasAtraso, tCsCartera.NroCuotasPagadas, NULL AS UltimoPago
	FROM         tSHFOtorgamiento INNER JOIN
                      #tCsCarteraDetUM tCsCarteraDet ON tSHFOtorgamiento.CodPrestamo = tCsCarteraDet.CodPrestamoRE and--REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AND 
                      tSHFOtorgamiento.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN
                      tCsCartera with(nolock) ON tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsCarteraDet.UltimoMovimiento = tCsCartera.Fecha AND 
                      tCsCarteraDet.UltimoMovimiento <> tCsCartera.FechaDesembolso INNER JOIN
                      tClMonedas ON tCsCartera.CodMoneda = tClMonedas.CodMoneda 
	--WHERE     (tCsCarteraDet.UltimoMovimiento <= @FF) AND (tCsCarteraDet.UltimoMovimiento >= @FI) and tCsCartera.CodProducto = @CodProducto 
	WHERE     tCsCartera.CodProducto = @CodProducto 

  drop table #tCsCarteraDetUM

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso insert transac'
  set @T1 = getdate()
	
	Insert Into [02tSHFComportamiento]
	Select Tipo = 2, * 	
	From tSHFComportamiento
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso 02tSHFComportamiento'
  set @T1 = getdate()
	-- Insertando cancelaciones de prestamos

	INSERT INTO tSHFComportamiento (ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, CodUsuario, CodOficina, SIInicio, 
                      Disposiciones, PagosProgramado, MovFecha, MovTipo, MovClave, MovAplica, MovMonto, MovDenominacion, NroDiasAtraso, NroCuotasPagadas, 
                      UltimoPago)
	SELECT DISTINCT 
	                      ReporteInicio = @FI, ReporteFin = @FF, tSHFOtorgamiento.Emisor, tSHFOtorgamiento.LineaNegocio, @TipoTransaccion AS TipoTransaccion, tSHFOtorgamiento.TipoEnvio, 
	                      tSHFOtorgamiento.idLineaCredito, tSHFOtorgamiento.Originador, tSHFOtorgamiento.CodPrestamo, tSHFOtorgamiento.CodUsuario, tSHFOtorgamiento.CodOficina, 
	                      0 AS SIInicio, 0 AS Disposiciones, 0 AS PagosProgramados, tCsPadronCarteraDet.Cancelacion AS UltimoMovimiento, @movTipo AS MovTipo, @movClave AS MovClave, @movAplica AS MovAplica, 
				NULL AS MovMonto, tClMonedas.SHF AS MovDenominacion, 0 AS NroDiasAtraso, tCsCartera.NroCuotas AS NroCuotasPagadas, NULL 
	                      AS UltimoPago
	FROM         tCsPadronCarteraDet with(nolock) INNER JOIN
	                      tSHFOtorgamiento ON REPLACE(tCsPadronCarteraDet.CodPrestamo, '-', '') = tSHFOtorgamiento.CodPrestamo AND 
	                      tCsPadronCarteraDet.CodUsuario = tSHFOtorgamiento.CodUsuario LEFT OUTER JOIN
	                      tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha LEFT OUTER JOIN
	                      tClMonedas ON tCsCartera.CodMoneda = tClMonedas.CodMoneda
	WHERE     (tCsPadronCarteraDet.Cancelacion >= @FI) AND (tCsPadronCarteraDet.Cancelacion <= @FF) And tCsCartera.CodProducto = @CodProducto 

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso cancelaciones'
  set @T1 = getdate()

	Insert Into [02tSHFComportamiento]
	Select Tipo = 3, * 	
	From tSHFComportamiento
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso tipo 3'
  set @T1 = getdate()

	Print 'Insertando Cierres'
	Set @TipoTransaccion 	= 4
	Set @movTipo		= 1
	Set @movClave		= 209
	Set @movAplica		= 	Case @movTipo 
						When 1 Then 0 
						When 6 Then 0 
						When 7 Then 0
						When 2 Then 14
						When 3 Then 14
						When 5 Then 1234						
					End	
	INSERT INTO tSHFComportamiento (ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, CodUsuario, CodOficina, SIInicio, 
                      Disposiciones, PagosProgramado, MovFecha, MovTipo, MovClave, MovAplica, MovMonto, MovDenominacion, NroDiasAtraso, NroCuotasPagadas, 
                      UltimoPago)
	SELECT DISTINCT 
	              ReporteInicio = @FI, ReporteFin = @FF, tSHFOtorgamiento.Emisor, tSHFOtorgamiento.LineaNegocio, TipoTransaccion = @TipoTransaccion, 
	              tSHFOtorgamiento.TipoEnvio, tSHFOtorgamiento.idLineaCredito, tSHFOtorgamiento.Originador, tSHFOtorgamiento.CodPrestamo, 
	              tSHFOtorgamiento.CodUsuario, tSHFOtorgamiento.CodOficina, 0 AS SIInicio, 0 AS Disposiciones, 0 AS PagosProgramados, Fecha = @FF, 
	              @movTipo AS MovTipo, @movClave AS MovClave, @movAplica AS MovAplica, 0 AS MovMonto, tClMonedas.SHF AS MovDenominacion, tCsCartera.NroDiasAtraso, 
	              tCsCartera.NroCuotasPagadas, NULL AS UltimoPago
	FROM         tSHFOtorgamiento INNER JOIN
	                      tCsCarteraDet with(nolock) ON tSHFOtorgamiento.CodPrestamo = Replace(tCsCarteraDet.CodPrestamo, '-', '') AND tSHFOtorgamiento.CodUsuario = tCsCarteraDet.CodUsuario AND 
	                      tSHFOtorgamiento.ReporteFin = tCsCarteraDet.Fecha INNER JOIN
	                      tCsCartera ON tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsCarteraDet.Fecha = tCsCartera.Fecha INNER JOIN
	                      tClMonedas ON tCsCartera.CodMoneda = tClMonedas.CodMoneda
	WHERE     (tSHFOtorgamiento.ReporteFin <= @FF) and tCsCartera.CodProducto = @CodProducto

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso cierres'
  set @T1 = getdate()

	Insert Into [02tSHFComportamiento]
	Select Tipo = 4, * 	
	From tSHFComportamiento
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso tipo 4'
  set @T1 = getdate()

	DELETE FROM tSHFOtorgamiento
	WHERE     (ReporteInicio >= '20090401') AND (CodPrestamo IN (SELECT CodPrestamo FROM tSHFEliminadas))


	DELETE FROM tSHFComportamiento
	WHERE     (ReporteInicio >= '20090401') AND (CodPrestamo IN (SELECT CodPrestamo FROM tSHFEliminadas))

	Insert Into [02tSHFComportamiento]
	Select Tipo = 5, * 	
	From tSHFComportamiento with(nolock)
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso cierres'
  set @T1 = getdate()

	DELETE FROM tSHFComportamiento
	WHERE     ((CAST(ReporteInicio AS varchar(100)) + CAST(ReporteFin AS varchar(100)) + CodPrestamo + CodUsuario + CAST(MovFecha AS varchar(100)) 
	                      + CAST(MovTipo AS varchar(100))) IN
	                          (SELECT     CAST(tSHFComportamiento.ReporteInicio AS varchar(100)) + CAST(tSHFComportamiento.ReporteFin AS varchar(100)) 
	                                                   + tSHFComportamiento.CodPrestamo + tSHFComportamiento.CodUsuario + CAST(tSHFComportamiento.MovFecha AS varchar(100)) 
	                                                   + CAST(tSHFComportamiento.MovTipo AS varchar(100)) AS Expr1
	                            FROM          tSHFComportamiento INNER JOIN
	                                                   tCsPadronCarteraDet with(nolock) ON tSHFComportamiento.CodPrestamo = REPLACE(tCsPadronCarteraDet.CodPrestamo, '-', '') AND 
	                                                   tSHFComportamiento.CodUsuario = tCsPadronCarteraDet.CodUsuario AND tSHFComportamiento.MovFecha > tCsPadronCarteraDet.Cancelacion
	                            WHERE      (tCsPadronCarteraDet.Cancelacion >= @FI) AND (tCsPadronCarteraDet.Cancelacion <= @FF) AND 
	                                                   (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.ReporteFIN = @FF)))
  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso delete'
  set @T1 = getdate()

	Insert Into [02tSHFComportamiento]
	Select Tipo = 6, * 	
	From tSHFComportamiento with(nolock)
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso tipo 6'
  set @T1 = getdate()

	Delete From tSHFComportamiento where Codprestamo in (
	SELECT     tSHFComportamiento.CodPrestamo
	FROM         tSHFComportamiento INNER JOIN
	                      tCsPadronCarteraDet with(nolock) ON tSHFComportamiento.CodPrestamo = REPLACE(tCsPadronCarteraDet.CodPrestamo, '-', '') AND 
	                      tSHFComportamiento.CodUsuario = tCsPadronCarteraDet.CodUsuario
	WHERE     (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.ReporteFin = @FF) AND (tCsPadronCarteraDet.Cancelacion < @FI)) And 
	(tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.ReporteFin = @FF) 

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso delete'
  set @T1 = getdate()

	Insert Into [02tSHFComportamiento]
	Select Tipo = 7, * 	
	From tSHFComportamiento with(nolock)
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso tipo 7'
  set @T1 = getdate()

	Declare @movFecha 		SmallDateTime
	Declare @movContador		Int
	Declare @movSaldo		Decimal(18,4)
	Declare @movDisposiciones	Decimal(18,4)
	Declare @movProgramados	Int
	Declare @movMonto		Decimal(18,4)
	Declare @movAtraso		Int
	Declare @movPagos		int
	Declare @movUltimo		SmallDateTime	
	Declare @movAFecha 		SmallDateTime
	Declare @movATipo		Int
	Declare @C			Int
	
	Set @C = 0

	Set @movUltimo = Null
	
	UPDATE    tSHFComportamiento
	SET       movtipo = 2, Movaplica = 1
	FROM      tSHFComportamiento INNER JOIN
	                      tCsPagoDet with(nolock) ON tSHFComportamiento.MovFecha = tCsPagoDet.Fecha AND tSHFComportamiento.CodPrestamo = REPLACE(tCsPagoDet.CodPrestamo, '-', '')
	WHERE     (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.ReporteFin = @FF) AND (tSHFComportamiento.MovTipo NOT IN (1, 2, 6)) AND 
	                      (tCsPagoDet.Extornado = 0)

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update antes cursor'
  set @T1 = getdate()

  --ojo

	Declare curFragmento Cursor For 
		SELECT DISTINCT tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario
		FROM         tSHFComportamiento INNER JOIN
		                      tCsPadronCarteraDet with(nolock) ON tSHFComportamiento.CodPrestamo = REPLACE(tCsPadronCarteraDet.CodPrestamo, '-', '') AND 
		                      tSHFComportamiento.CodUsuario = tCsPadronCarteraDet.CodUsuario
		WHERE     (ReporteFin = @FF) AND (ReporteInicio = @FI) AND  (tCsPadronCarteraDet.CodProducto = @CodProducto)		
	Open curFragmento
	Fetch Next From curFragmento Into @CodPrestamo, @CodUsuario
	While @@Fetch_Status = 0
	Begin 	
		Print @CodPrestamo
		Set @movContador = 0
		
		set @T1 = getdate() --inicia el primer ptmo cursor
		
		Declare curFragmento2 Cursor For 
			Select movFecha, movTipo 
			From tSHFComportamiento
			Where CodPrestamo = @CodPrestamo And CodUsuario = @CodUsuario
			Order by movFecha, movTipo Desc
		Open curFragmento2
		Fetch Next From curFragmento2 Into @movFecha, @movATipo
		While @@Fetch_Status = 0
		Begin 
			Set @movContador = @movContador + 1
			Print 'Prestamo 	: '  + @CodPrestamo
			Print 'Codusuario	: '  + @CodUsuario
			Print 'Transaccion ' +  dbo.fdufechaatexto(@movFecha, 'DD') + '/' + dbo.fdufechaatexto(@movFecha, 'MM') + '/' + dbo.fdufechaatexto(@movFecha, 'AAAA')
			Print 'Nro: '  + Cast(@movContador as Varchar(50))
			Print 'Tipo Movimiento : ' + Cast(@movATipo as Varchar(10))					

			UPDATE tSHFComportamiento
			Set NroTrans = 	@movContador
			WHERE 	(CodPrestamo 	= @CodPrestamo) AND 	
				(movFecha 	= @movFecha) 	AND 
				(CodUsuario 	= @CodUsuario)	AND
				(MovTipo 	= @movATipo)	

			If @movContador = 1 And @movATipo = 6
			Begin
				Print 'Consistenciando Desembolso'
				Set @movSaldo = 0
				SELECT   @movDisposiciones =  MontoDesembolso
				FROM         tCsCarteraDet with(nolock)
				WHERE   (Replace(CodPrestamo, '-', '') = @CodPrestamo) 	AND 	(Fecha = @movFecha) AND 
					(CodUsuario = @CodUsuario)
				Set @movMonto 	= @movDisposiciones
				Set @movTipo	= 6 	
				Set @movAplica 	= 0
				Set @movAtraso 	= 0
				Set @movPagos 	= 0
				Set @movUltimo	= Null
			End
			Else
			Begin
				Print 'Consistenciando Transacciones'
				
				If @movFecha <> @movAFecha
				Begin
					SELECT    @movSaldo = SIInicio + CASE movtipo WHEN 1 THEN movmonto WHEN 2 THEN - 1 * movmonto WHEN 6 THEN movmonto END 
					FROM         tSHFComportamiento
					WHERE   (CodPrestamo = @CodPrestamo) 	AND 	(movFecha 	= @movAFecha) AND 
						(CodUsuario = @CodUsuario)	--and	(movTipo	<> @movATipo) 	
					Order by CodPrestamo, movFecha, movTipo Desc
				end
				Else
				Begin
					
					SELECT    @movSaldo = SIInicio + CASE movtipo WHEN 1 THEN movmonto WHEN 2 THEN - 1 * movmonto WHEN 6 THEN movmonto END 
						FROM         tSHFComportamiento
						WHERE   (CodPrestamo = @CodPrestamo) 	AND 	(movFecha 	= @movAFecha) AND 
							(CodUsuario = @CodUsuario)	And	(movTipo	<> @movATipo) 	
						Order by CodPrestamo, movFecha, movTipo Desc

					If @movSaldo is null
					Begin
						Print 'SALDO NULO'
						SELECT    @movSaldo = SIInicio + CASE movtipo WHEN 1 THEN movmonto WHEN 2 THEN - 1 * movmonto WHEN 6 THEN movmonto END 
						FROM         tSHFComportamiento
						WHERE   (CodPrestamo = @CodPrestamo) 	AND 	(movFecha 	= @movAFecha) AND 
							(CodUsuario = @CodUsuario)	And	(movTipo	= @movATipo) 	
						Order by CodPrestamo, movFecha, movTipo Desc
					End
				End
				Print 'Mov A Fecha ' + CAST(@movAFecha AS vARCHAR(100))
				Print 'Saldo:' + Isnull(Cast(@movSaldo as Varchar(100)), '0')
				Print 'movTipo : '  + Cast(@movTipo as Varchar(1))
				Set @movDisposiciones = 0	
				
				SELECT @C = Count(*)
				FROM         tCsCarteraDet  with(nolock) INNER JOIN
				                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
				WHERE 	(Replace(tCsCarteraDet.CodPrestamo, '-', '') = @CodPrestamo) AND (tCsCarteraDet.Fecha = @movFecha) AND (tCsCarteraDet.CodUsuario = @CodUsuario) 
				
				If @C Is Null Begin Set @C = 0  End
				
				If @C > 0 
				begin				
					SELECT 	@movMonto = 	tCsCarteraDet.SaldoCapital 	+ 
								tCsCarteraDet.SaldoInteres 	+ 
								tCsCarteraDet.SaldoMoratorio 	+ 
								tCsCarteraDet.OtrosCargos 	+ 
								tCsCarteraDet.CargoMora - @movSaldo,
						@movAtraso =    tCsCartera.NroDiasAtraso, 
						@movPagos  =	tCsCartera.NroCuotasPagadas
					FROM         tCsCarteraDet with(nolock) INNER JOIN
					                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
					WHERE 	(Replace(tCsCarteraDet.CodPrestamo, '-', '') = @CodPrestamo) AND (tCsCarteraDet.Fecha = @movFecha) AND (tCsCarteraDet.CodUsuario = @CodUsuario) 
				End				
				Else
				Begin
					Set @movMonto 	= @movSaldo * -1
					Set @movAtraso 	= 0
					SELECT   @movPagos =  tCsCartera.NroCuotas
					FROM         tCsPadronCarteraDet with(nolock) INNER JOIN
					                      tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha
					WHERE     (Replace(tCsPadronCarteraDet.CodPrestamo, '-', '') = @CodPrestamo) AND (tCsPadronCarteraDet.CodUsuario = @CodUsuario) 
				End
		
				Print 'Monto Original: '  + Cast(@MovMonto as Varchar(50))

				If @movMonto < 0
				Begin
					Set @movTipo 	= 2
					Set @movAplica 	= 1
					Set @movUltimo 	= @movFecha
				End
				Else
				Begin
					Set @movTipo 	= 1
					Set @movAplica 	= 0
				End
				Set @movMonto = ABS(@movMonto)
				Print 'Monto Final: '  + Cast(@MovMonto as Varchar(50))
			End
			
			SELECT    @movProgramados = COUNT(*) 
			FROM         (SELECT DISTINCT SecCuota
			                       FROM       tCsPadronPlanCuotas with(nolock)
			                       WHERE      (Replace(CodPrestamo, '-', '') = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (FechaVencimiento >= @FI) AND 
			                                  (FechaVencimiento <= @FF) AND ((FechaPagoConcepto >= @FI) OR (FechaPagoConcepto IS NULL))) DERIVEDTBL
			
			Print @FI
			Print @FF
			Print @CodPrestamo
			Print @CodUsuario
			Print @movFecha
			Print @movATipo
			Print @movTipo
			
			Set @Contador = 0
      			Select @Contador = Count(*) From tSHFComportamiento
			Where 	(ReporteFin 		= @FF) 		AND 
			      	(ReporteInicio 		= @FI)		AND
			      	(CodPrestamo		= @CodPrestamo)	AND
				(CodUsuario		= @CodUsuario)	AND
				(movFecha		= @movFecha)	AND
				(movTipo		= @movTipo)

			If @Contador Is null Begin Set @Contador = 0 End
			
			Print 'Actualiza con contador ' + cast(@Contador as Varchar(10))

			If @Contador = 0 
			Begin 				
				Update tSHFComportamiento
				Set  	SIInicio 		= @movSaldo,
					Disposiciones		= @movDisposiciones,
					PagosProgramado		= @movProgramados,
					movTipo			= @movTipo,
					movAplica		= @movAplica,
					movMonto		= @movMonto,
					NroDiasAtraso		= @movAtraso,
					NroCuotasPagadas	= @movPagos,
					UltimoPago		= @movUltimo			
				Where 	(ReporteFin 		= @FF) 		AND 
				      	(ReporteInicio 		= @FI)		AND
				      	(CodPrestamo		= @CodPrestamo)	AND
					(CodUsuario		= @CodUsuario)	AND
					(movFecha		= @movFecha)	AND
					(movTipo		= @movATipo)
				Print '0: ' + Cast(@@RowCount as Varchar) + ' Filas Afectadas'
	 		End 
			Else
			Begin
				UPDATE tSHFComportamiento				
				Set  	SIInicio 		= @movSaldo, --datos.SIInicio 	+ @movSaldo		,
					Disposiciones		= @movDisposiciones, --datos.Disposiciones 	+ @movDisposiciones	,
					movMonto		= @movMonto, --datos.MovMonto	+ @movMonto		,
					NroDiasAtraso		= @movAtraso					,
					NroCuotasPagadas	= @movPagos					,
					UltimoPago		= @movUltimo		
				FROM         (SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, SUM(SIInicio) AS SIInicio, SUM(Disposiciones) AS Disposiciones, 
		                                              SUM(MovMonto) AS MovMonto, SUM(NroDiasAtraso) AS NroDiasAtraso, MAX(NroCuotasPagadas) AS NroCuotasPagadas, MAX(UltimoPago) 
		                                              AS UltimoPago
		                       FROM          tSHFComportamiento
		                      	Where 	
					(ReporteFin 		= @FF) 		AND 
				      	(ReporteInicio 		= @FI)		AND
				      	(CodPrestamo		= @CodPrestamo)	AND
					(CodUsuario		= @CodUsuario)	AND
					(movFecha		= @movFecha)	AND
					(movTipo		= @movTipo)
		                       GROUP BY ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, NroCuotasPagadas, UltimoPago) datos INNER JOIN
		                      tSHFComportamiento ON datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
		                      datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                      datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND datos.MovFecha = tSHFComportamiento.MovFecha AND 
		                      datos.MovTipo = tSHFComportamiento.MovTipo

				Print '1: ' + Cast(@@RowCount as Varchar) + ' Filas Afectadas'				
			End

			Insert Into [02tSHFComportamiento]
			Select Tipo = @movContador, * --DatePart(Second,GetDate()), * 	
			From tSHFComportamiento
			Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI And MovFecha = @MovFecha

			Set @movAFecha 		= @movFecha
			If @movTipo = 2 Begin 	Set @movUltimo = @movFecha End
			
			set @T2 = getdate()
      print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. termin ptmo'
      set @T1 = getdate()
			
		Fetch Next From curFragmento2 Into @movFecha, @movATipo
		End 
		Close 		curFragmento2
		Deallocate 	curFragmento2
	
	set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso cursor 2 fin'
  set @T1 = getdate()
	
	  --declare @tblCDet table (
	  --  fecha smalldatetime,
	  --  CodPrestamo varchar(25),
	  --  Total decimal(16,2)
	  --)
	
	  declare @chcodptmotmp varchar(25)
	  --declare @CodPrestamo varchar(25)
	  --set @CodPrestamo = '002123060000086'
	  set @chcodptmotmp = substring(@CodPrestamo,1,3)+'-'+substring(@CodPrestamo,4,3)+'-'+substring(@CodPrestamo,7,2)
	  +'-'+substring(@CodPrestamo,9,2)+'-'+substring(@CodPrestamo,11,5)

	 -- SELECT tCsCarteraDet.Fecha, REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AS CodPrestamo, 
  --  CASE WHEN fechadesembolso = tcscarteradet.fecha THEN SUM(tcscarteradet.montodesembolso) 
  --  ELSE SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio + tCsCarteraDet.OtrosCargos + tCsCarteraDet.CargoMora) END AS Total
  --  FROM tCsCarteraDet INNER JOIN
  --  tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
  --  --Where Replace(tCsCarteraDet.Codprestamo, '-', '') = @CodPrestamo AND Replace(tCsCartera.Codprestamo, '-', '') = @CodPrestamo
  --  where tCsCartera.Codprestamo=@codptmo
  --  --Where Replace(tCsCarteraDet.Codprestamo, '-', '') = '002123060000086' AND Replace(tCsCartera.Codprestamo, '-', '') = '002123060000086'
		--GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCartera.FechaDesembolso
	
		Update tSHFComportamiento
		Set SIInicio = Total
		FROM         (SELECT     Datos.CodPrestamo, Datos.MovFecha, Datos.SIInicio, Datos.MovMonto, Datos.SIInicio + Datos.MovMonto AS SHFInicio, tCsCarteraDet.Total, 
		                                              Datos.NroTrans + 1 AS NroTrans
                  FROM  (SELECT Filtro.*, tSHFComportamiento.SIInicio, 
                        CASE WHEN movtipo = 2 THEN tSHFComportamiento.MovMonto * - 1 ELSE tSHFComportamiento.MovMonto END AS MovMonto
                        FROM (SELECT     Filtro.CodPrestamo, tSHFComportamiento.MovFecha, MAX(tSHFComportamiento.NroTrans) AS NroTrans
                         FROM  (SELECT DISTINCT CodPrestamo
                         FROM          tSHFComportamiento
                         WHERE      (ReporteInicio = @FI) AND (ReporteFin = @FF) AND codprestamo = @CodPrestamo) Filtro INNER JOIN
                         tSHFComportamiento ON Filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo
                         GROUP BY Filtro.CodPrestamo, tSHFComportamiento.MovFecha) Filtro INNER JOIN
                         tSHFComportamiento ON Filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                         Filtro.MovFecha = tSHFComportamiento.MovFecha AND Filtro.NroTrans = tSHFComportamiento.NroTrans) Datos INNER JOIN
                         --aqui variable temporal
                         (SELECT     tCsCarteraDet.Fecha, REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AS CodPrestamo, 
                         CASE WHEN fechadesembolso = tcscarteradet.fecha THEN SUM(tcscarteradet.montodesembolso) 
                         ELSE SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio + tCsCarteraDet.OtrosCargos + tCsCarteraDet.CargoMora)
                         END AS Total
                         FROM tCsCarteraDet with(nolock) INNER JOIN
                         tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                         --Where Replace(tCsCarteraDet.Codprestamo, '-', '') = @CodPrestamo AND Replace(tCsCartera.Codprestamo, '-', '') = @CodPrestamo 
                         Where tCsCartera.Codprestamo=@chcodptmotmp-- <-- aqui se coloco
									       GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCartera.FechaDesembolso) 									
									  tCsCarteraDet ON 
		                Datos.MovFecha = tCsCarteraDet.Fecha AND Datos.CodPrestamo = tCsCarteraDet.CodPrestamo) Datos INNER JOIN
		                tSHFComportamiento ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                Datos.NroTrans = tSHFComportamiento.NroTrans
		Where tSHFComportamiento.SIInicio <> Total
		
		set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update'
  set @T1 = getdate()
		
		Print 'Actualiza Saldo Inicio : ' + Cast(@@RowCount As Varchar(10))	+ ' Filas Afectadas'	

		If (SELECT     COUNT(*) AS Expr1
		FROM         (SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
		                                              tSHFComportamiento.MovFecha, CASE WHEN diferencia < 0 THEN 2 ELSE 1 END AS Movtipo, Datos.NroTrans
		                       FROM          (SELECT     tSHFComportamiento.CodPrestamo, tSHFComportamiento.NroTrans - 1 AS NroTrans, tSHFComportamiento.SIInicio, 
		                                                                      CASE WHEN tSHFComportamiento_1.movmonto IS NULL 
		                                                                      THEN 0 WHEN tSHFComportamiento_1.movtipo = 2 THEN tSHFComportamiento_1.MovMonto * - 1 ELSE tSHFComportamiento_1.MovMonto END AS
		                                                                       MovMonto, tSHFComportamiento.SIInicio - tSHFComportamiento_1.SIInicio AS Diferencia
		                                               FROM          tSHFComportamiento INNER JOIN
		                                                                      tSHFComportamiento tSHFComportamiento_1 ON tSHFComportamiento.CodPrestamo = tSHFComportamiento_1.CodPrestamo AND 
		                                                                      tSHFComportamiento.CodUsuario = tSHFComportamiento_1.CodUsuario AND 
		                                                                      tSHFComportamiento.NroTrans - 1 = tSHFComportamiento_1.NroTrans
		                                               WHERE      (tSHFComportamiento.CodPrestamo = @CodPrestamo)) Datos INNER JOIN
		                                              tSHFComportamiento ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                                              Datos.NroTrans = tSHFComportamiento.NroTrans
		                       WHERE      (Datos.MovMonto <> Datos.Diferencia)) Datos INNER JOIN
		                      tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
		                      Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                      Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND Datos.MovFecha = tSHFComportamiento.MovFecha AND 
		                      Datos.Movtipo = tSHFComportamiento.MovTipo AND Datos.NroTrans <> tSHFComportamiento.NroTrans) >= 1 
		Begin
			DELETE FROM tSHFComportamiento
			WHERE     ((CAST(ReporteInicio AS varchar(100)) + CAST(ReporteFin AS Varchar(100)) + CodPrestamo + CodUsuario + CAST(MovFecha AS varchar(100)) 
			                      + CAST(MovTipo AS varchar(10)) + CAST(NroTrans AS Varchar(10))) IN
			                          (SELECT     CAST(tSHFComportamiento.ReporteInicio AS varchar(100)) + CAST(tSHFComportamiento.ReporteFin AS Varchar(100)) 
			                                                   + tSHFComportamiento.CodPrestamo + tSHFComportamiento.CodUsuario + CAST(tSHFComportamiento.MovFecha AS varchar(100)) 
			                                                   + CAST(tSHFComportamiento.MovTipo AS varchar(10)) + CAST(tSHFComportamiento.NroTrans AS Varchar(10)) AS Expr1
			                            FROM          (SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
			                                                                           tSHFComportamiento.MovFecha, CASE WHEN diferencia < 0 THEN 2 ELSE 1 END AS Movtipo, Datos.NroTrans
			                                                    FROM          (SELECT     tSHFComportamiento.CodPrestamo, tSHFComportamiento.NroTrans - 1 AS NroTrans, tSHFComportamiento.SIInicio, 
			                                                                                                   CASE WHEN tSHFComportamiento_1.movmonto IS NULL 
			                                                                                                   THEN 0 WHEN tSHFComportamiento_1.movtipo = 2 THEN tSHFComportamiento_1.MovMonto * - 1 ELSE tSHFComportamiento_1.MovMonto
			                                                                                                    END AS MovMonto, tSHFComportamiento.SIInicio - tSHFComportamiento_1.SIInicio AS Diferencia
			                                                                            FROM          tSHFComportamiento INNER JOIN
			                                                                                                   tSHFComportamiento tSHFComportamiento_1 ON tSHFComportamiento.CodPrestamo = tSHFComportamiento_1.CodPrestamo AND 
			                                                                                                   tSHFComportamiento.CodUsuario = tSHFComportamiento_1.CodUsuario AND 
			                                                                                                   tSHFComportamiento.NroTrans - 1 = tSHFComportamiento_1.NroTrans
			                                                                            WHERE      (tSHFComportamiento.CodPrestamo = @CodPrestamo)) Datos INNER JOIN
			                                                                           tSHFComportamiento ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
			                                                                           Datos.NroTrans = tSHFComportamiento.NroTrans
			                                                    WHERE      (Datos.MovMonto <> Datos.Diferencia)) Datos INNER JOIN
			                                                   tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
			                                                   Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
			                                                   Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND Datos.MovFecha = tSHFComportamiento.MovFecha AND 
			                                                   Datos.Movtipo = tSHFComportamiento.MovTipo AND Datos.NroTrans <> tSHFComportamiento.NroTrans))
			Print 'Borra Registros : ' + Cast(@@RowCount As Varchar(10))	+ ' Filas Afectadas'
		End

set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update 2'
  set @T1 = getdate()

		UPDATE tSHFComportamiento	
		SET	MovMonto 	= ABS(Datos.Diferencia) , 
			MovTipo 	= CASE WHEN diferencia < 0 THEN 2 ELSE 1 END ,
		       	MovAplica 	= CASE WHEN diferencia < 0 THEN 1 ELSE 0 END 
		FROM         (SELECT     tSHFComportamiento.CodPrestamo, tSHFComportamiento.NroTrans - 1 AS NroTrans, tSHFComportamiento.SIInicio, 
		                                              CASE WHEN tSHFComportamiento_1.movmonto IS NULL 
		                                              THEN 0 WHEN tSHFComportamiento_1.movtipo = 2 THEN tSHFComportamiento_1.MovMonto * - 1 ELSE tSHFComportamiento_1.MovMonto END AS MovMonto,
		                                               tSHFComportamiento.SIInicio - tSHFComportamiento_1.SIInicio AS Diferencia
		                       FROM          tSHFComportamiento INNER JOIN
		                                              tSHFComportamiento tSHFComportamiento_1 ON tSHFComportamiento.CodPrestamo = tSHFComportamiento_1.CodPrestamo AND 
		                                              tSHFComportamiento.CodUsuario = tSHFComportamiento_1.CodUsuario AND tSHFComportamiento.NroTrans - 1 = tSHFComportamiento_1.NroTrans
		                       WHERE      (tSHFComportamiento.CodPrestamo = @CodPrestamo)) Datos INNER JOIN
		                      tSHFComportamiento ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                      Datos.NroTrans = tSHFComportamiento.NroTrans
		WHERE     (Datos.MovMonto <> Datos.Diferencia)

set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update 3'
  set @T1 = getdate()

		Print 'Actualiza MovMonto 1 : ' + Cast(@@RowCount As Varchar(10))	+ ' Filas Afectadas'

		UPDATE    tSHFComportamiento
		SET              MovMonto = ABS(Datos.SIInicio + Datos.MovMonto - Datos.MontoFinal), MovTipo = CASE WHEN (Datos.SIInicio + Datos.MovMonto - Datos.MontoFinal) 
		                      > 0 THEN 2 ELSE 1 END, MovAplica = CASE WHEN (Datos.SIInicio + Datos.MovMonto - Datos.MontoFinal) > 0 THEN 1 ELSE 0 END
		FROM         (SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.CodPrestamo, Datos.Nrotrans, tSHFComportamiento.SIInicio, 
		                                              CASE WHEN tSHFComportamiento.movmonto IS NULL 
		                                              THEN 0 WHEN tSHFComportamiento.movtipo = 2 THEN tSHFComportamiento.MovMonto * - 1 ELSE tSHFComportamiento.MovMonto END AS MovMonto, 
		                                              tCsCarteraDet.SaldoCapital + tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio + tCsCarteraDet.OtrosCargos + tCsCarteraDet.CargoMora AS MontoFinal
		                       FROM          (SELECT     ReporteInicio, ReporteFin, CodPrestamo, MAX(NroTrans) AS Nrotrans
		                                               FROM          tSHFComportamiento
		                                               WHERE      (CodPrestamo = @CodPrestamo) AND (ReporteInicio = @FI) AND (ReporteFin = @FF)
		                                               GROUP BY ReporteInicio, ReporteFin, CodPrestamo) Datos INNER JOIN
		                                              tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
		                                              Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                                              Datos.Nrotrans = tSHFComportamiento.NroTrans INNER JOIN
		                                              tCsCarteraDet ON tSHFComportamiento.CodPrestamo = REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AND 
		                                              tSHFComportamiento.MovFecha = tCsCarteraDet.Fecha) Datos INNER JOIN
		                      tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
		                      Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND Datos.Nrotrans = tSHFComportamiento.NroTrans
		WHERE     (ABS(Datos.SIInicio + Datos.MovMonto - Datos.MontoFinal) > 0)
		
		set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update 4'
  set @T1 = getdate()
		
		Print 'Actualiza MovMonto 2 : ' + Cast(@@RowCount As Varchar(10))	+ ' Filas Afectadas'

		UPDATE    tSHFComportamiento
		SET              PagosProgramado = 1
		WHERE     (CodPrestamo = @CodPrestamo) AND (PagosProgramado = 0)

		UPDATE    tSHFComportamiento
		SET              Ultimopago = datos.ultimopago
		FROM         (SELECT     CodPrestamo, MAX(MovFecha) AS UltimoPago
		                       FROM          tSHFComportamiento
		                       WHERE      (CodPrestamo = @CodPrestamo) AND (MovTipo = 2)
		                       GROUP BY CodPrestamo) Datos INNER JOIN
		                      tSHFComportamiento ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
		                      Datos.UltimoPago <= tSHFComportamiento.MovFecha
		WHERE     (tSHFComportamiento.UltimoPago IS NULL)

  set @T2 = getdate()
    print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso update 5 2'
    set @T1 = getdate()

	Fetch Next From curFragmento Into @CodPrestamo, @CodUsuario
	End 
	Close 		curFragmento
	Deallocate 	curFragmento
End

--ojo

set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso cursor mayor fin --'
  set @T1 = getdate()

If @Proceso = 'P'
Begin
	Insert Into tSHFComportamientoDetalle
	SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, MovClave, MovAplica, MovMonto, MovDenominacion, SecCuota, C, 
	                      Sum(ISNULL(montopagado, MovMonto)) AS Monto
	FROM         (SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, CodConcepto, CAPI, INTE, INPE, MORA, MovClave, MovAplica, 
	                                              MovMonto, MovDenominacion, CASE WHEN movtipo = 6 THEN Capi WHEN movtipo = 1 THEN Isnull(INTE, '') + Isnull(INPE, '') 
	                                              + Isnull(MORA, '') WHEN movtipo = 2 THEN Isnull(codconcepto, '') END AS C, montopagado, Isnull(Seccuota, 0) AS SecCuota
	                       FROM          (SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, 
	                                                                      tSHFComportamiento.CodUsuario, tSHFComportamiento.MovFecha, tSHFComportamiento.MovTipo, tCsCartera.SaldoCapital, 
	                                                                      tCsCartera.SaldoInteresCorriente, tCsCartera.SaldoINPE, tCsCartera.CargoMora, tSHFComportamiento.SIInicio, 
	                                                                      tCsPagoDet.CodConcepto, ISNULL(tCsPagoDet.CodConcepto, CASE WHEN saldocapital > 0 THEN 'CAPI' END) AS CAPI, 
	                                                                      ISNULL(tCsPagoDet.CodConcepto, CASE WHEN Saldointerescorriente > 0 THEN 'INTE' END) AS INTE, 
	                                                                      ISNULL(tCsPagoDet.CodConcepto, CASE WHEN Saldoinpe > 0 THEN 'INPE' END) AS INPE, ISNULL(tCsPagoDet.CodConcepto, 
	                                                                      CASE WHEN CargoMora > 0 THEN 'MORA' END) AS MORA, tSHFComportamiento.MovMonto, tCsPagoDet.MontoPagado, 
	                                                                      MovClave, MovAplica, MovDenominacion, tCsPagoDet.seccuota
	                                               FROM          tCsCartera with(nolock) INNER JOIN
	                                                                      tSHFComportamiento ON tCsCartera.Fecha = tSHFComportamiento.MovFecha AND REPLACE(tCsCartera.CodPrestamo, '-', '') 
	                                                                      = tSHFComportamiento.CodPrestamo LEFT OUTER JOIN
	                                                                      tCsPagoDet with(nolock) ON tSHFComportamiento.MovFecha = tCsPagoDet.Fecha AND 
	                                                                      tSHFComportamiento.CodPrestamo = REPLACE(tCsPagoDet.CodPrestamo, '-', '')
	                                               WHERE      reporteinicio = @FI AND reportefin = @FF AND tCsCartera.CodProducto = @CodProducto) Datos) Datos
	Group by  ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, MovClave, MovAplica, MovMonto, MovDenominacion, SecCuota, C

	Select Tipo = datepart(second,GetDate()), * 	
	Into [03tSHFComportamientoDetalle]	
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI

	Insert Into tSHFComportamientoDetalle
	SELECT     tSHFComportamientoDetalle.ReporteInicio, tSHFComportamientoDetalle.ReporteFin, tSHFComportamientoDetalle.CodPrestamo, 
	                      tSHFComportamientoDetalle.CodUsuario, tSHFComportamientoDetalle.MovFecha, tSHFComportamientoDetalle.MovTipo, 
	                      tSHFComportamientoDetalle.MovClave, tSHFComportamientoDetalle.MovAplica, tSHFComportamientoDetalle.MovMonto, 
	                      tSHFComportamientoDetalle.MovDenominacion, tSHFComportamientoDetalle.SecCuota, 'MORA' AS CodConcepto, tCsCartera.CargoMora
	FROM         tSHFComportamientoDetalle INNER JOIN
	                      tCsCartera ON tSHFComportamientoDetalle.CodPrestamo = REPLACE(tCsCartera.CodPrestamo, '-', '') AND 
	                      tSHFComportamientoDetalle.MovFecha = tCsCartera.Fecha
	WHERE     (tSHFComportamientoDetalle.CodConcepto = 'INTEMORA')  AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	

	UPDATE tSHFComportamientoDetalle
	Set CodConcepto = 'INTE', Monto = tCsCartera.SaldoInteresCorriente
	FROM         tSHFComportamientoDetalle INNER JOIN
	                      tCsCartera with(nolock) ON tSHFComportamientoDetalle.CodPrestamo = REPLACE(tCsCartera.CodPrestamo, '-', '') AND 
	                      tSHFComportamientoDetalle.MovFecha = tCsCartera.Fecha
	WHERE     (tSHFComportamientoDetalle.CodConcepto = 'INTEMORA')  AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'INTE'
	WHERE     (CodConcepto like '%INTE%') AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'CAPI'
	WHERE     (CodConcepto = 'CAPICAPICAPI') AND reporteinicio = @FI AND reportefin = @FF
	
	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'INTE'
	WHERE     (CodConcepto = 'INTEINTEINTE') AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'IVAIT'
	WHERE     (CodConcepto = 'IVAITIVAITIVAIT') AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'IVAMO'
	WHERE     (CodConcepto = 'IVAMOIVAMOIVAMO') AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI		

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'INPE'
	WHERE     (CodConcepto = 'INPEINPEINPE') AND reporteinicio = @FI AND reportefin = @FF

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'IVACM'
	WHERE     (CodConcepto = 'IVACMIVACMIVACM') AND reporteinicio = @FI AND reportefin = @FF

	UPDATE    tSHFComportamientoDetalle
	SET              CodConcepto = 'MORA'
	WHERE     (CodConcepto = 'MORAMORAMORA') AND reporteinicio = @FI AND reportefin = @FF

	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI		

	Delete from tSHFComportamientoDetalle
	Where reporteinicio = @FI AND reportefin = @FF And MovMonto = 0
	
	Insert Into [03tSHFComportamientoDetalle]	
	Select Tipo = datepart(second,GetDate()), * 		
	From tSHFComportamientoDetalle
	Where CodPrestamo = Replace(@Prestamo, '-', '') And ReporteInicio = @FI	
End

set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso 2 antes inicio cursor 3'
  set @T1 = getdate()

Declare @CodConcepto 	Varchar(10)
Declare @Orden		Int
Declare @MontoA		Decimal(18,4)
Declare @Monto		Decimal(18,4)

Declare curFragmento3 Cursor For 
	SELECT    tSHFComportamientoDetalle.CodPrestamo, 
	                      tSHFComportamientoDetalle.CodUsuario, tSHFComportamientoDetalle.MovFecha, tSHFComportamientoDetalle.MovTipo, 
	                      tSHFComportamientoDetalle.CodConcepto, tSHFComportamientoDetalle.MovMonto, tCaClConcepto.Orden, Monto
	FROM         (SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo
	                       FROM          tSHFComportamientoDetalle
	                       WHERE      (reporteinicio = @FI AND reportefin = @FF)
	                       GROUP BY ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo
	                       HAVING      (COUNT(*) > 1)) Corte INNER JOIN
	                      tSHFComportamientoDetalle ON Corte.ReporteInicio = tSHFComportamientoDetalle.ReporteInicio AND 
	                      Corte.ReporteFin = tSHFComportamientoDetalle.ReporteFin AND 
	                      Corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodPrestamo AND 
	                      Corte.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodUsuario AND 
	                      Corte.MovFecha = tSHFComportamientoDetalle.MovFecha AND Corte.MovTipo = tSHFComportamientoDetalle.MovTipo LEFT OUTER JOIN
	                      tCaClConcepto ON tSHFComportamientoDetalle.CodConcepto = tCaClConcepto.CodConcepto
	ORDER BY tCaClConcepto.Orden
Open curFragmento3
Fetch Next From curFragmento3 Into @CodPrestamo, @CodUsuario, @MovFecha, @MovTipo, @CodConcepto, @MovMonto, @Orden, @Monto
While @@Fetch_Status = 0
Begin 

	SELECT  @MontoA = SUM(tSHFComportamientoDetalle.Monto) 
	FROM         (SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo
	                       FROM          tSHFComportamientoDetalle
	                       WHERE      (reporteinicio = @FI AND reportefin = @FF)
	                       GROUP BY ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo
	                       HAVING      (COUNT(*) > 1)) Corte INNER JOIN
	                      tSHFComportamientoDetalle ON Corte.ReporteInicio = tSHFComportamientoDetalle.ReporteInicio AND 
	                      Corte.ReporteFin = tSHFComportamientoDetalle.ReporteFin AND 
	                      Corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodPrestamo AND 
	                      Corte.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodUsuario AND 
	                      Corte.MovFecha = tSHFComportamientoDetalle.MovFecha AND Corte.MovTipo = tSHFComportamientoDetalle.MovTipo LEFT OUTER JOIN
	                      tCaClConcepto ON tSHFComportamientoDetalle.CodConcepto = tCaClConcepto.CodConcepto
	WHERE     (tCaClConcepto.Orden <= @Orden) And tSHFComportamientoDetalle.CodPrestamo = @CodPrestamo And
	                      tSHFComportamientoDetalle.CodUsuario = @CodUsuario And tSHFComportamientoDetalle.MovFecha = @MovFecha And tSHFComportamientoDetalle.MovTipo = @MovTipo  
	GROUP BY tSHFComportamientoDetalle.ReporteInicio, tSHFComportamientoDetalle.ReporteFin, tSHFComportamientoDetalle.CodPrestamo, 
	                      tSHFComportamientoDetalle.CodUsuario, tSHFComportamientoDetalle.MovFecha, tSHFComportamientoDetalle.MovTipo, 
	                      tSHFComportamientoDetalle.MovMonto	

	Print @MontoA
	Print @MovMonto
	Print @Monto
	Print 'KEMY'	

	If @MovMonto < @MontoA
	Begin
		Print 'KEMY'
		Print @Monto
		Set @Monto = @Monto - (@MontoA - @MovMonto)
		Print @Monto
		Update tSHFComportamientoDetalle
		Set Monto = @Monto
		Where tSHFComportamientoDetalle.CodPrestamo = @CodPrestamo And
	                      tSHFComportamientoDetalle.CodUsuario = @CodUsuario And tSHFComportamientoDetalle.MovFecha = @MovFecha And tSHFComportamientoDetalle.MovTipo = @MovTipo  And
	                      tSHFComportamientoDetalle.CodConcepto = @CodConcepto And reporteinicio = @FI AND reportefin = @FF

		Print @@RowCount
	End

Fetch Next From curFragmento3 Into @CodPrestamo, @CodUsuario, @MovFecha, @MovTipo, @CodConcepto, @MovMonto, @Orden, @Monto
End 
Close 		curFragmento3
Deallocate 	curFragmento3

set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. If @proceso 2 antes fin cursor 3'
  set @T1 = getdate()

--ojo cursor 3

UPDATE    tSHFComportamientoDetalle
SET              Seccuota = CuotaActual
FROM         tSHFComportamientoDetalle INNER JOIN
                      tCsCartera with(nolock) ON tSHFComportamientoDetalle.CodPrestamo = REPLACE(tCsCartera.CodPrestamo, '-', '') AND 
                      tSHFComportamientoDetalle.MovFecha = tCsCartera.Fecha
WHERE     (tSHFComportamientoDetalle.SecCuota = 0) AND (ReporteFin 	= @FF) 		AND 	(ReporteInicio 		= @FI) 

UPDATE   tSHFComportamiento
SET      PagosProgramado = 1
WHERE   (PagosProgramado 	= 0) 		AND 
	(ReporteFin 		= @FF) 		AND 
	(ReporteInicio 		= @FI) 

UPDATE    tSHFComportamientoDetalle
SET              MovClave = '102'
FROM         (SELECT     tSHFComportamientoDetalle.ReporteInicio, tSHFComportamientoDetalle.ReporteFin, tSHFComportamientoDetalle.CodPrestamo, 
                                              tSHFComportamientoDetalle.CodUsuario, tSHFComportamientoDetalle.MovFecha, tSHFComportamientoDetalle.MovTipo, 
                                              MIN(tSHFComportamientoDetalle.SecCuota) AS Seccuota, tSHFComportamientoDetalle.CodConcepto
                       FROM          (SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, CodConcepto
                                               FROM          tSHFComportamientoDetalle
                                               WHERE      (CodConcepto = 'CAPI') AND (ReporteFin = @FF) AND (ReporteInicio = @FI) 
                                               GROUP BY ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MovFecha, MovTipo, CodConcepto
                                               HAVING      (COUNT(*) > 1)) Corte INNER JOIN
                                              tSHFComportamientoDetalle ON Corte.ReporteInicio = tSHFComportamientoDetalle.ReporteInicio AND 
                                              Corte.ReporteFin = tSHFComportamientoDetalle.ReporteFin AND 
                                              Corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodPrestamo AND 
                                              Corte.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodUsuario AND 
                                              Corte.MovFecha = tSHFComportamientoDetalle.MovFecha AND Corte.MovTipo = tSHFComportamientoDetalle.MovTipo AND 
                                              Corte.CodConcepto COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodConcepto
                       GROUP BY tSHFComportamientoDetalle.ReporteInicio, tSHFComportamientoDetalle.ReporteFin, tSHFComportamientoDetalle.CodPrestamo, 
                                              tSHFComportamientoDetalle.CodUsuario, tSHFComportamientoDetalle.MovFecha, tSHFComportamientoDetalle.MovTipo, 
                                              tSHFComportamientoDetalle.CodConcepto) Datos INNER JOIN
                      tSHFComportamientoDetalle ON Datos.ReporteInicio = tSHFComportamientoDetalle.ReporteInicio AND 
                      Datos.ReporteFin = tSHFComportamientoDetalle.ReporteFin AND 
                      Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodPrestamo AND 
                      Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodUsuario AND 
                      Datos.MovFecha = tSHFComportamientoDetalle.MovFecha AND Datos.MovTipo = tSHFComportamientoDetalle.MovTipo AND 
                      Datos.CodConcepto COLLATE Modern_Spanish_CI_AI = tSHFComportamientoDetalle.CodConcepto AND 
                      Datos.Seccuota <> tSHFComportamientoDetalle.SecCuota

Delete from tSHFComportamientoDetalle
Where reporteinicio = @FI AND reportefin = @FF And Monto = 0

UPDATE    tSHFComportamiento
SET              siinicio = Datos.siInicio, MovMonto = Datos.siInicio
FROM         (SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.CodPrestamo, Datos.CodUsuario, Datos.NroTrans, tSHFComportamiento.SIInicio
                       FROM          (SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
                                                                      MIN(tSHFComportamiento.NroTrans) AS NroTrans
                                               FROM          (SELECT     CodPrestamo, ReporteInicio, ReporteFin, Codusuario
                                                                       FROM          tSHFComportamiento
                                                                       WHERE      (ReporteInicio = @FI) AND (CodPrestamo IN
                                                                                                  (SELECT     REPLACE(CodPrestamo, '-', '')
                                                                                                    FROM          tCsPadronCarteraDet with(nolock)
                                                                                                    WHERE      (CodProducto IN (@CodProducto)) AND Cancelacion >= @FI AND Cancelacion <= @FF)) AND 
                                                                                              (ReporteFin = @FF)
                                                                       GROUP BY CodPrestamo, ReporteInicio, ReporteFin, Codusuario
                                                                       HAVING      (COUNT(*) > 1)) Corte INNER JOIN
                                                                      tSHFComportamiento ON Corte.ReporteInicio = tSHFComportamiento.ReporteInicio AND Corte.ReporteFin = tSHFComportamiento.ReporteFin AND
                                                                       Corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                                                                      Corte.Codusuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario
                                               GROUP BY tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario) 
                                              Datos INNER JOIN
                                              tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
                                              Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                                              Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND Datos.NroTrans = tSHFComportamiento.NroTrans) 
                      Datos INNER JOIN
                      tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
                      Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                      Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario

DELETE FROM tSHFComportamiento
WHERE     ((CAST(ReporteInicio AS Varchar(50)) + CAST(ReporteFin AS varchar(50)) + CodPrestamo + CodUsuario + CAST(MovFecha AS varchar(50)) 
                      + CAST(MovTipo AS varchar(50))) IN
                          (SELECT     CAST(tSHFComportamiento.ReporteInicio AS Varchar(50)) + CAST(tSHFComportamiento.ReporteFin AS varchar(50)) 
                                                   + tSHFComportamiento.CodPrestamo + tSHFComportamiento.CodUsuario + CAST(tSHFComportamiento.MovFecha AS varchar(50)) 
                                                   + CAST(tSHFComportamiento.MovTipo AS varchar(50)) AS Expr1
                            FROM          (SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
                                                                           MIN(tSHFComportamiento.NroTrans) AS NroTrans
                                                    FROM          (SELECT     CodPrestamo, ReporteInicio, ReporteFin, Codusuario
                                                                            FROM          tSHFComportamiento
                                                                            WHERE      (ReporteInicio = @FI) AND (CodPrestamo IN
                                                                                                       (SELECT     REPLACE(CodPrestamo, '-', '')
                                                                                                         FROM          tCsPadronCarteraDet with(nolock)
                                                                                                         WHERE      (CodProducto IN (@CodProducto)) AND  Cancelacion >= @FI AND Cancelacion <= @FF)) AND 
                                                                                                   (ReporteFin = @FF)
                                                                            GROUP BY CodPrestamo, ReporteInicio, ReporteFin, Codusuario
                                                                            HAVING      (COUNT(*) > 1)) Corte INNER JOIN
                                                                           tSHFComportamiento ON Corte.ReporteInicio = tSHFComportamiento.ReporteInicio AND 
                                                                           Corte.ReporteFin = tSHFComportamiento.ReporteFin AND 
                                                                           Corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                                                                           Corte.Codusuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario
                                                    GROUP BY tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario) 
                                                   Datos INNER JOIN
                                                   tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
                                                   Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                                                   Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND Datos.NroTrans = tSHFComportamiento.NroTrans))

DELETE FROM tSHFComportamientoDetalle
WHERE     (ReporteInicio = @FI) AND (CodPrestamo IN
                          (SELECT     REPLACE(CodPrestamo, '-', '')
                            FROM          tCsPadronCarteraDet
                            WHERE      (CodProducto IN (@CodProducto)) AND Cancelacion >= @FI AND Cancelacion <= @FF)) AND (ReporteFin = @FF)

Insert Into tSHFComportamientoDetalle
SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
                      tSHFComportamiento.MovFecha, tSHFComportamiento.MovTipo, CASE WHEN cartera.Nrocuotas > Cartera.cuotaActual THEN 102 ELSE tCaClConcepto.SHF END AS MovClave, 
                      tSHFComportamiento.MovAplica, tSHFComportamiento.MovMonto, tSHFComportamiento.MovDenominacion, Cartera.NroCuotas, tCaClConcepto.CodConcepto, 
                      Cartera.SaldoCapital
FROM         tSHFComportamiento INNER JOIN
                          (SELECT     REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AS Codprestamo, tCsCarteraDet.CodPrestamo AS [Real], tCsCarteraDet.SaldoCapital, 
                                                   tCsCarteraDet.SaldoInteres, tCsCarteraDet.SaldoMoratorio, tCsCarteraDet.OtrosCargos, tCsCarteraDet.CargoMora, tCsCartera.NroCuotas, 
                                                   Cuotaactual
                            FROM          tCsCarteraDet with(nolock) INNER JOIN
                                                   tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                            WHERE      (tCsCarteraDet.Fecha = @CorteAnterior)) Cartera ON tSHFComportamiento.CodPrestamo = Cartera.Codprestamo COLLATE Modern_Spanish_CI_AI CROSS JOIN
                      tCaClConcepto
WHERE     (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.CodPrestamo IN
                          (SELECT     REPLACE(CodPrestamo, '-', '')
                            FROM          tCsPadronCarteraDet with(nolock)
                            WHERE      (CodProducto IN (@CodProducto)) AND Cancelacion >= @FI AND Cancelacion <= @FF)) AND (tSHFComportamiento.ReporteFin = @FF) AND 
                      (Cartera.SaldoCapital > 0) AND (tCaClConcepto.CodConcepto = 'CAPI')


Insert Into tSHFComportamientoDetalle
SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
                      tSHFComportamiento.MovFecha, tSHFComportamiento.MovTipo, tCaClConcepto.SHF AS MovClave, tSHFComportamiento.MovAplica, tSHFComportamiento.MovMonto, 
                      tSHFComportamiento.MovDenominacion, Cartera.NroCuotas, tCaClConcepto.CodConcepto, Cartera.SaldoInteres
FROM         tSHFComportamiento INNER JOIN
                          (SELECT     REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AS Codprestamo, tCsCarteraDet.CodPrestamo AS [Real], tCsCarteraDet.SaldoCapital, 
                                                   tCsCarteraDet.SaldoInteres, tCsCarteraDet.SaldoMoratorio, tCsCarteraDet.OtrosCargos, tCsCarteraDet.CargoMora, tCsCartera.NroCuotas
                            FROM          tCsCarteraDet with(nolock) INNER JOIN
                                                   tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                            WHERE      (tCsCarteraDet.Fecha = @CorteAnterior)) Cartera ON tSHFComportamiento.CodPrestamo = Cartera.Codprestamo COLLATE Modern_Spanish_CI_AI CROSS JOIN
                      tCaClConcepto
WHERE     (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.CodPrestamo IN
                          (SELECT     REPLACE(CodPrestamo, '-', '')
                            FROM          tCsPadronCarteraDet with(nolock)
                            WHERE      (CodProducto IN (@CodProducto)) AND Cancelacion >= @FI AND Cancelacion <= @FF)) AND (tSHFComportamiento.ReporteFin = @FF) AND 
                      (Cartera.SaldoInteres > 0) AND (tCaClConcepto.CodConcepto = 'INTE')

Insert Into tSHFComportamientoDetalle
SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
                      tSHFComportamiento.MovFecha, tSHFComportamiento.MovTipo, tCaClConcepto.SHF AS MovClave, tSHFComportamiento.MovAplica, tSHFComportamiento.MovMonto, 
                      tSHFComportamiento.MovDenominacion, Cartera.NroCuotas, tCaClConcepto.CodConcepto, Cartera.SaldoMoratorio
FROM         tSHFComportamiento INNER JOIN
                          (SELECT     REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AS Codprestamo, tCsCarteraDet.CodPrestamo AS [Real], tCsCarteraDet.SaldoCapital, 
                                                   tCsCarteraDet.SaldoInteres, tCsCarteraDet.SaldoMoratorio, tCsCarteraDet.OtrosCargos, tCsCarteraDet.CargoMora, tCsCartera.NroCuotas
                            FROM          tCsCarteraDet with(nolock) INNER JOIN
                                                   tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                            WHERE      (tCsCarteraDet.Fecha = @CorteAnterior)) Cartera ON tSHFComportamiento.CodPrestamo = Cartera.Codprestamo COLLATE Modern_Spanish_CI_AI CROSS JOIN
                      tCaClConcepto
WHERE     (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.CodPrestamo IN
                          (SELECT     REPLACE(CodPrestamo, '-', '')
                            FROM          tCsPadronCarteraDet with(nolock)
                            WHERE      (CodProducto IN (@CodProducto)) AND Cancelacion >= @FI AND Cancelacion <= @FF)) AND (tSHFComportamiento.ReporteFin = @FF) AND 
                      (Cartera.SaldoMoratorio > 0) AND (tCaClConcepto.CodConcepto = 'INPE')

Insert Into tSHFComportamientoDetalle
SELECT     tSHFComportamiento.ReporteInicio, tSHFComportamiento.ReporteFin, tSHFComportamiento.CodPrestamo, tSHFComportamiento.CodUsuario, 
                      tSHFComportamiento.MovFecha, tSHFComportamiento.MovTipo, tCaClConcepto.SHF AS MovClave, tSHFComportamiento.MovAplica, tSHFComportamiento.MovMonto, 
                      tSHFComportamiento.MovDenominacion, Cartera.NroCuotas, tCaClConcepto.CodConcepto, Saldo = Cartera.OtrosCargos + Cartera.CargoMora
FROM         tSHFComportamiento INNER JOIN
                          (SELECT     REPLACE(tCsCarteraDet.CodPrestamo, '-', '') AS Codprestamo, tCsCarteraDet.CodPrestamo AS [Real], tCsCarteraDet.SaldoCapital, 
                                                   tCsCarteraDet.SaldoInteres, tCsCarteraDet.SaldoMoratorio, tCsCarteraDet.OtrosCargos, tCsCarteraDet.CargoMora, tCsCartera.NroCuotas
                            FROM          tCsCarteraDet with(nolock) INNER JOIN
                                                   tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                            WHERE      (tCsCarteraDet.Fecha = @CorteAnterior)) Cartera ON tSHFComportamiento.CodPrestamo = Cartera.Codprestamo COLLATE Modern_Spanish_CI_AI CROSS JOIN
                      tCaClConcepto
WHERE     (tSHFComportamiento.ReporteInicio = @FI) AND (tSHFComportamiento.CodPrestamo IN
                          (SELECT     REPLACE(CodPrestamo, '-', '')
                            FROM          tCsPadronCarteraDet with(nolock)
                            WHERE      (CodProducto IN (@CodProducto)) AND Cancelacion >= @FI AND Cancelacion <= @FF)) AND (tSHFComportamiento.ReporteFin = @FF) AND 
                      ( Cartera.OtrosCargos + Cartera.CargoMora > 0) AND (tCaClConcepto.CodConcepto = 'MORA')


set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. termino'
  set @T1 = getdate()

/*
SELECT     *
FROM         tSHFComportamiento
WHERE     (ReporteInicio = '20100101') AND (CodPrestamo IN
                          (SELECT     REPLACE(CodPrestamo, '-', '')
                            FROM          tCsPadronCarteraDet
                            WHERE      (CodProducto IN ('123', '401')) AND (dbo.fduFechaATexto(Cancelacion, 'AAAAMM') = '201001'))) AND (ReporteFin = '20100131')

SELECT     *
FROM         tSHFComportamientoDetalle
WHERE     (ReporteInicio = @FI) AND (Monto <> 0) AND (CodConcepto NOT IN ('CAPI', 'INPE', 'INTE'))
UNION
SELECT     *
FROM         tSHFComportamientoDetalle
WHERE     (ReporteInicio = @FI) AND (Monto < 0)
*/
If ltrim(rtrim(@Prestamo)) = ''
Begin
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[01tSHFOtorgamiento]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin drop table [dbo].[01tSHFOtorgamiento] End
	
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[02tSHFComportamiento]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin drop table [dbo].[02tSHFComportamiento] End
	
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[03tSHFComportamientoDetalle]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin drop table [dbo].[03tSHFComportamientoDetalle] End
End

/*
SELECT     tSHFComportamientoDetalle.ReporteInicio, tSHFComportamientoDetalle.ReporteFin, tSHFComportamientoDetalle.MovFecha, 
                      tSHFComportamientoDetalle.MovTipo, tSHFComportamientoDetalle.MovClave, tSHFComportamientoDetalle.MovMonto, 
                      tSHFComportamientoDetalle.SecCuota, tSHFComportamientoDetalle.CodConcepto, 
                      CASE WHEN movtipo = 2 THEN - 1 * tSHFComportamientoDetalle.Monto ELSE tSHFComportamientoDetalle.Monto END AS Monto, 
                      tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINPE + tCsCartera.CargoMora + tCsCartera.OtrosCargos AS Cartera, 
                      tCsCartera.NroDiasAtraso
FROM         tSHFComportamientoDetalle LEFT OUTER JOIN
                      tCsCartera ON tSHFComportamientoDetalle.CodPrestamo = REPLACE(tCsCartera.CodPrestamo, '-', '') AND 
                      tSHFComportamientoDetalle.MovFecha = tCsCartera.Fecha
WHERE     (tSHFComportamientoDetalle.CodPrestamo = '004401060600008') AND (tSHFComportamientoDetalle.Monto <> 0)
ORDER BY tSHFComportamientoDetalle.MovFecha
*/
GO