SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--- Nombre de Procedimientos a Crear deben empezar con: pCsSHFXXXXXXXX (Base de Datos Consolidado)
----Este procedimiento genera el periodo a crear de SHF
 
CREATE procedure [dbo].[pCsSHFCrearPeriodoXML]
as
Declare @Periodo			Varchar(6)
Declare @FI					SmallDateTime
Declare @FF					SmallDateTime
Declare @FA					SmallDateTime 
Declare @Contador			Int
Declare @TipoEnvio			Varchar(1)
Declare @TipoTransaccion 	Int
Declare @PlazoI				Int
Declare	@PlazoF	 			Int
Declare @PorcIngresos		Decimal(10,2)
Declare @PorcAceptacion		Decimal(10,2)
Declare @Monto				Decimal(20,4)

--VALORES FIJO
Set @TipoEnvio			= 'S'
Set @TipoTransaccion 	= 2
Set @PlazoI				= 0
Set @PlazoF				= 100
Set @PorcIngresos		= 30	
Set @PorcAceptacion		= 10
set @Periodo			='201112'	--para q tome el periodo

SELECT  @Periodo =   dbo.fduFechaaTexto(DateAdd(month, -1, FechaConsolidacion), 'AAAAMM')
FROM    vCsFechaConsolidacion

Set @FI = Cast(@Periodo + '01' as SmallDateTime)
Set @FF = Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, @FI), 'AAAAMM') + '01' as SmallDateTime) - 1


SELECT  @FA =   FechaConsolidacion
FROM    vCsFechaConsolidacion 

If @FA <= @FF
Begin
      Set @FF = @FA
End

Delete From tSHFPeriodo
Where Periodo = dbo.fduFechaAtexto(DateAdd(Month, 1, @FI), 'AAAAMM') 

Update tSHFPeriodo
Set Activo = 0

Insert Into tSHFPeriodo (Periodo, ReporteInicio, ReporteFin, Registro, Activo) 
Values                  (dbo.fduFechaAtexto(DateAdd(Month, 1, @FI), 'AAAAMM') , @FI, @FF, GetDate(), 1)

Select @Contador = Count(*) From tSHFOtorgamiento
Where ReporteInicio = @FI And ReporteFin = @FF

If @Contador is null Begin Set @Contador = 0 End

If @Contador = 0
Begin
	Delete From tSHFOtorgamiento
	Where ReporteInicio = @FI AND (SUBSTRING(CodPrestamo, 4, 3) IN ('401', '123'))
	
	Delete From tSHFComportamiento 
	Where ReporteInicio = @FI AND (SUBSTRING(CodPrestamo, 4, 3) IN ('401', '123'))
	
	Delete From tSHFComportamientoDetalle 
	Where ReporteInicio = @FI AND (SUBSTRING(CodPrestamo, 4, 3) IN ('401', '123'))

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
	                          (SELECT     CodUsuario, SUM(SaldoCapital + SaldoInteres + SaldoMoratorio + OtrosCargos + Impuestos + CargoMora) AS DeudaTotal
	                            FROM          tCsCarteraDet
	                            WHERE      (Fecha = @FF)
	                            GROUP BY CodUsuario) DTC RIGHT OUTER JOIN
	                      tCsPadronClientes tCsPadronClientes_1 ON DTC.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes_1.CodUsuario RIGHT OUTER JOIN
	                      tCsPadronClientes ON tCsPadronClientes_1.CodUsuario = tCsPadronClientes.CodConyuge LEFT OUTER JOIN
	                      tClUbigeo ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) = tClUbigeo.CodUbiGeo LEFT OUTER JOIN
	                      tUsClTipoPropiedad ON ISNULL(tCsPadronClientes.TipoPropiedadDirFam, tCsPadronClientes.TipoPropiedadDirNeg) 
	                      = tUsClTipoPropiedad.CodTipoPro LEFT OUTER JOIN
	                      tUsClGradoInstruccion ON ISNULL(tCsPadronClientes.GradoInstruccion, 'Nulo') = tUsClGradoInstruccion.GradoInstruccion LEFT OUTER JOIN
	                      tUsClEstadoCivil ON tCsPadronClientes.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil ON 
	                      tUsClSexo.Sexo = tCsPadronClientes.Sexo RIGHT OUTER JOIN
	                      tCaProducto INNER JOIN
	                      tCsPadronCarteraDet ON tCaProducto.CodProducto = tCsPadronCarteraDet.CodProducto ON 
	                      tCsPadronClientes.CodUsuario = tCsPadronCarteraDet.CodUsuario RIGHT OUTER JOIN
	                          (SELECT     CodPrestamo, SUM(TotalPagado) AS ComisionApertura
	                            FROM          tCsConceptosPrestamo
	                            WHERE      (TipoCobro IN ('A')) AND (CodConcepto IN ('COM', 'CLC'))
	                            GROUP BY CodPrestamo) Comision RIGHT OUTER JOIN
	                      tCsCartera INNER JOIN
	                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN
	                          (SELECT     CodUsuario, SUM(SaldoCapital + SaldoInteres + SaldoMoratorio + OtrosCargos + Impuestos + CargoMora) AS DeudaTotal
	                            FROM          tCsCarteraDet
	                            WHERE      (Fecha = @FF)
	                            GROUP BY CodUsuario) DT ON tCsCarteraDet.CodUsuario = DT.CodUsuario COLLATE Modern_Spanish_CI_AI ON 
	                      Comision.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo ON 
	                      tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND 
	                      tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha LEFT OUTER JOIN
	                          (SELECT     CodPrestamo, CodUsuario, AVG(Cuota) AS Cuota
	                            FROM          (SELECT     CodPrestamo, CodUsuario, SecCuota, NumeroPlan, SUM(MontoCuota) AS Cuota
	                                                    FROM          tCsPadronPlanCuotas
	                                                    WHERE      (CodConcepto IN ('CAPI', 'INTE', 'IVAIT')) AND (SUBSTRING(CodPrestamo, 5, 3) IN ('123', '401'))
	                                                    GROUP BY CodPrestamo, CodUsuario, SecCuota, NumeroPlan) Datos
	                            GROUP BY CodPrestamo, CodUsuario) Cuota ON tCsCarteraDet.CodPrestamo = Cuota.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
	                      tCsCarteraDet.CodUsuario = Cuota.CodUsuario COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
	                      tClMonedas ON tCsCartera.CodMoneda = tClMonedas.CodMoneda LEFT OUTER JOIN
	                      tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo LEFT OUTER JOIN
	                      tCaClDestino ON tCsCartera.CodDestino = tCaClDestino.CodDestino CROSS JOIN
	                      tClEmpresas INNER JOIN
	                      tSHFEmpresaLineaNegocio ON tClEmpresas.SHF = tSHFEmpresaLineaNegocio.Empresa
	WHERE     (tClEmpresas.CodEmpresa = 1) AND (tCaProducto.CodProducto IN ('401', '123')) AND (tCsCartera.FechaDesembolso >= @FI) AND 
	                      (tCsCartera.FechaDesembolso <= @FF) And Cast(DateDiff(Day, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento)/30.4375 AS Int) >= @PlazoI And
		Cast(DateDiff(Day, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento)/30.4375 AS Int) <= @PlazoF And tCsCarteraDet.MontoDesembolso <= @Monto
	
	UPDATE    tSHFOtorgamiento
	SET              SolucionVivienda = dbo.fduFechaATexto(tCsPadronCarteraDet.Desembolso, 'AA') 
	                      + tClUbigeo.CodEstado + tClUbigeo.CodMunicipio + tCsPadronCarteraDet.CodProducto + RIGHT(tCsPadronCarteraDet.CodPrestamo, 3)
	FROM         tSHFOtorgamiento INNER JOIN
	                      tCsPadronCarteraDet ON tSHFOtorgamiento.CodPrestamo = REPLACE(tCsPadronCarteraDet.CodPrestamo, '-', '') INNER JOIN
	                      tCsCartera ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha INNER JOIN
	                      tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
	                      tClUbigeo ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) = tClUbigeo.CodUbiGeo
	WHERE     (LTRIM(RTRIM(ISNULL(tSHFOtorgamiento.SolucionVivienda, ''))) = '') And  tSHFOtorgamiento.ReporteInicio = @FI And  tSHFOtorgamiento.ReporteFin = @FF
End

SELECT tClPeriodo.Periodo, tClPeriodo.Descripcion 
FROM tSHFPeriodo INNER JOIN tClPeriodo ON tSHFPeriodo.ReporteFin = tClPeriodo.UltimoDia 
WHERE (tSHFPeriodo.Activo = 1)
GO