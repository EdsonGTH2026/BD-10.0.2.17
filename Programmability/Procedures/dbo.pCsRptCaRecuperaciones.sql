SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Exec pCsRptCaRecuperaciones 1, 'Ninguno', 'ZZZ', 'CASTIGADA', '20100101', '20101231'
--Drop Procedure pCsRptCaRecuperaciones
CREATE Procedure [dbo].[pCsRptCaRecuperaciones]
@Dato			Int,
@Archivo		Varchar(54),
@Ubicacion		Varchar(100),
@ClaseCartera	Varchar(100),	
@CorteInicial 	SmallDateTime, 	
@CorteFinal 	SmallDateTime 	
As
--1: No respetar clase de cartera en Pagos.
--2: Respetar clase de cartera en Pagos.

Print 'INICIO'
Print Getdate()

Declare @Cadena			Varchar(4000)
Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera 	Varchar(500)
Declare @OtroDato		Varchar(100)

Set 	@CorteInicial 	= @CorteInicial - 1	

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AOscar]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[AOscar] End

CREATE TABLE [dbo].[AOscar] (
	[Nro] [Float],
	[CodOficina] [float] NULL ,
	[Observacion] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[Dato] [varchar] (4000) COLLATE Modern_Spanish_CI_AI NULL ,
	[ClienteGrupo] [varchar] (1) COLLATE Modern_Spanish_CI_AI NULL ,
	[CoincidenciaBase] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NULL ,
	[CodUsuario] [varchar] (15) COLLATE Modern_Spanish_CI_AI NULL ,
	[FechaDesembolso] [smalldatetime] NULL ,
	[Desembolso] [decimal](18, 4) NULL ,
	[NroCuotas] [int] NULL ,	
	[Estado] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL,

	[FechaCastigo] [smalldatetime] NULL ,
	[CapitalCastigado] [decimal](18, 4) NULL ,
	[InteresCastigadoVig] [decimal](18, 4) NULL ,
	[InteresCastigadoVen] [decimal](18, 4) NULL ,
	[InteresCastigadoOrd] [decimal](18, 4) NULL ,
	[MoratorioCastigadoVig] [decimal](18, 4) NULL ,
	[MoratorioCastigadoVen] [decimal](18, 4) NULL ,
	[MoratorioCastigadoOrd] [decimal](18, 4) NULL ,
	[MoraCastigada] [decimal](18, 4) NULL ,
	[OtrosCargosCastigado] [decimal](18, 4) NULL ,
	[ImpuestosCastigado] [decimal](18, 4) NULL ,
	[TotalCastigada] AS (	isnull([CapitalCastigado],0) 		+ 
				isnull([InteresCastigadoVig],0) 	+ 
				isnull([InteresCastigadoVen],0)		+ 
				isnull([InteresCastigadoOrd],0) 	+ 
				isnull([MoratorioCastigadoVig],0) 	+ 
				isnull([MoratorioCastigadoVen],0) 	+
				isnull([MoratorioCastigadoOrd],0) 	+
				isnull([MoraCastigada],0) 		+ 
				isnull([OtrosCargosCastigado],0) 	+ 
				isnull([ImpuestosCastigado],0)) ,		
	[CorteInicial] [smalldatetime] NULL ,
	[CapitalCierre] [decimal](18, 4) NULL ,
	[InteresCierreVig] [decimal](18, 4) NULL ,
	[InteresCierreVen] [decimal](18, 4) NULL ,
	[InteresCierreOrd] [decimal](18, 4) NULL ,
	[MoratorioCierreVig] [decimal](18, 4) NULL ,
	[MoratorioCierreVen] [decimal](18, 4) NULL ,
	[MoratorioCierreOrd] [decimal](18, 4) NULL ,
	[MoraCierre] [decimal](18, 4) NULL ,
	[OtrosCargosCierre] [decimal](18, 4) NULL ,
	[ImpuestosCierre] [decimal](18, 4) NULL ,
	[TotalCierre] AS (	isnull([CapitalCierre],0) 		+ 
				isnull([InteresCierreVig],0) 		+ 
				isnull([InteresCierreVen],0)		+ 
				isnull([InteresCierreOrd],0) 		+ 
				isnull([MoratorioCierreVig],0) 		+ 
				isnull([MoratorioCierreVen],0) 		+
				isnull([MoratorioCierreOrd],0) 		+
				isnull([MoraCierre],0) 			+ 
				isnull([OtrosCargosCierre],0) 		+ 
				isnull([ImpuestosCierre],0)) ,		
	[CorteFinal] [smalldatetime] NULL ,
	[CapitalActual] [decimal](18, 4) NULL ,
	[InteresActualVig] [decimal](18, 4) NULL ,
	[InteresActualVen] [decimal](18, 4) NULL ,
	[InteresActualOrd] [decimal](18, 4) NULL ,
	[MoratorioActualVig] [decimal](18, 4) NULL ,
	[MoratorioActualVen] [decimal](18, 4) NULL ,
	[MoratorioActualOrd] [decimal](18, 4) NULL ,
	[MoraActual] [decimal](18, 4) NULL ,
	[OtrosCargosActual] [decimal](18, 4) NULL ,
	[ImpuestosActual] [decimal](18, 4) NULL ,
	[TotalActual] AS (	isnull([CapitalActual],0) 		+ 
				isnull([InteresActualVig],0) 		+ 
				isnull([InteresActualVen],0)		+ 
				isnull([InteresActualOrd],0) 		+	 
				isnull([MoratorioActualVig],0) 		+ 
				isnull([MoratorioActualVen],0) 		+
				isnull([MoratorioActualOrd],0) 		+
				isnull([MoraActual],0) 			+ 
				isnull([OtrosCargosActual],0) 		+ 
				isnull([ImpuestosActual],0)) ,			
	[CapitalPago] [decimal](18, 4) NULL ,
	[InteresPago] [decimal](18, 4) NULL ,
	[MoratorioPago] [decimal](18, 4) NULL ,
	[MoraPago] [decimal](18, 4) NULL ,
	[OtrosCargosPago] [decimal](18, 4) NULL ,
	[ImpuestosPago] [decimal](18, 4) NULL ,
	[TotalPago] AS (	isnull([CapitalPago],0) 		+ 
				isnull([InteresPago],0) 		+ 
				isnull([MoratorioPago],0) 		+ 
				isnull([MoraPago],0) 			+ 
				isnull([OtrosCargosPago],0) 		+ 
				isnull([ImpuestosPago],0)) ,	
	[FechaCancelacion] [smalldatetime] NULL ,	
	[FechaCorte]	[smalldatetime] NULL ,	
	[DeudaTotal]	[decimal](18, 4) NULL ,
	[CierreEnero]	[decimal](18, 4) NULL ,
	[PagoALaFecha]	[decimal](18, 4) NULL, 
	[ClaseCartera]	[varchar] (50) COLLATE Modern_Spanish_CI_AI NULL,
	[CCI]	[smalldatetime] NULL ,	
	[CCF]	[smalldatetime] NULL 	
) ON [PRIMARY]

If @Archivo <> 'Ninguno'
Begin
	Set @Cadena = 'Insert Into AOscar (Dato, CodPrestamo, Nro, Observacion) '
	Set @Cadena = @Cadena + 'SELECT ClienteGrupo, CodPrestamo, Nro, Observacion '	
	Set @Cadena = @Cadena + 'FROM OPENDATASOURCE (''Microsoft.Jet.OLEDB.4.0'', ' 	
	Set @Cadena = @Cadena + '''Data Source="\\10.0.1.13\finmas\Kemy\'+ @Archivo +'"; Extended Properties=Excel 8.0'' )...[Hoja1$] Tabla '
	
	Exec (@Cadena)	
		
	UPDATE    AOscar
	SET              CodPrestamo = Datos.codprestamo
	FROM         (SELECT     Datos.Nro, Datos.Dato, Datos.CodUsuario, MAX(tCsPadronCarteraDet.CodPrestamo) AS CodPrestamo, Datos.FechaCorte
	                       FROM          (SELECT     AOscar.Nro, AOscar.Dato, tCsPadronClientes.CodUsuario, MAX(tCsPadronCarteraDet.FechaCorte) AS FechaCorte
	                                               FROM          AOscar INNER JOIN
	                                                                      tCsPadronClientes with(nolock) ON AOscar.Dato = tCsPadronClientes.NombreCompleto INNER JOIN
	                                                                      tCsPadronCarteraDet with(nolock) ON tCsPadronClientes.CodUsuario = tCsPadronCarteraDet.CodUsuario
	                                               WHERE      (AOscar.CodPrestamo IS NULL)
	                                               GROUP BY AOscar.Nro, AOscar.Dato, tCsPadronClientes.CodUsuario) Datos INNER JOIN
	                                              tCsPadronCarteraDet with(nolock) ON Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario AND 
	                                              Datos.FechaCorte = tCsPadronCarteraDet.FechaCorte
	                       GROUP BY Datos.Nro, Datos.Dato, Datos.CodUsuario, Datos.FechaCorte) Datos INNER JOIN
	                      AOscar ON Datos.Nro = AOscar.Nro AND Datos.Dato COLLATE Modern_Spanish_CI_AI = AOscar.Dato
	
	UPDATE    AOscar
	SET              CodPrestamo = Datos.codprestamo
	FROM         (SELECT     Datos.Nro, Datos.Dato, Datos.CodUsuario, MAX(tCsPadronCarteraDet.CodPrestamo) AS CodPrestamo, Datos.FechaCorte
	                       FROM          (SELECT     AOscar.Nro, AOscar.Dato, tCsPadronCarteraDet.CodGrupo AS CodUsuario, MAX(tCsPadronCarteraDet.FechaCorte) 
	                                                                      AS FechaCorte
	                                               FROM          AOscar INNER JOIN
	                                                                      tCsCarteraGrupos with(nolock) ON AOscar.Dato = tCsCarteraGrupos.NombreGrupo INNER JOIN
	                                                                      tCsPadronCarteraDet with(nolock) ON tCsCarteraGrupos.CodGrupo = tCsPadronCarteraDet.CodGrupo
	                                               WHERE      (AOscar.CodPrestamo IS NULL) AND (tCsCarteraGrupos.CodOficina = 4)
	                                               GROUP BY AOscar.Nro, AOscar.Dato, tCsPadronCarteraDet.CodGrupo) Datos INNER JOIN
	                                              tCsPadronCarteraDet with(nolock) ON Datos.FechaCorte = tCsPadronCarteraDet.FechaCorte AND 
	                                              Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodGrupo
	                       GROUP BY Datos.Nro, Datos.Dato, Datos.CodUsuario, Datos.FechaCorte) Datos INNER JOIN
	                      AOscar ON Datos.Nro = AOscar.Nro AND Datos.Dato COLLATE Modern_Spanish_CI_AI = AOscar.Dato
End
If @Archivo = 'Ninguno'
Begin
	Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
	Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out
	
	Set @Cadena = 'Insert Into AOscar (CodPrestamo, CCI, CCF) '
	Set @Cadena = @Cadena + 'SELECT CodPrestamo, MIN(tCsCartera.Fecha) AS CCI, MAX(tCsCartera.Fecha) AS CCF '
	Set @Cadena = @Cadena + 'FROM tCsCartera with(nolock) '
	Set @Cadena = @Cadena + 'WHERE (Cartera IN ('+ @CClaseCartera +')) AND '
	Set @Cadena = @Cadena + '(Fecha >= '''+ dbo.fduFechaATexto(@CorteInicial, 'AAAAMMDD') +''') AND (Fecha '
	Set @Cadena = @Cadena + '<= '''+ dbo.fduFechaATexto(@CorteFinal, 'AAAAMMDD') +''') AND (CodOficina IN ('+ @CUbicacion +')) '
--	Set @Cadena = @Cadena + 'AND codasesor in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50)) ' -- filtro solo para legal
	Set @Cadena = @Cadena + 'GROUP BY CodPrestamo '
	Print @Cadena
	Exec (@Cadena)
End

UPDATE    AOscar	
SET       Codusuario = tcscartera.codusuario	
FROM      AOscar INNER JOIN	
          tCsPadronCarteraDet with(nolock) ON AOscar.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN	
          tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha	

Print 'INICIO1'
Print Getdate()

UPDATE    AOscar	
SET       Fechacorte = tcspadroncarteradet.fechacorte, ClienteGrupo = CASE WHEN codgrupo IS NULL OR	
          rtrim(ltrim(codgrupo)) = '' THEN 'C' ELSE 'G' END, CodOficina = tcspadroncarteradet.codoficina	
FROM      AOscar INNER JOIN	
          tCsPadronCarteraDet with(nolock) ON AOscar.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND AOscar.CodUsuario = tCsPadronCarteraDet.CodUsuario	

UPDATE    AOscar	
SET       fechacorte = tcspadroncarteradet.fechacorte	
FROM      AOscar INNER JOIN	
          tCsPadronCarteraDet with(nolock) ON AOscar.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND AOscar.CodUsuario = tCsPadronCarteraDet.CodUsuario	
	
UPDATE    AOscar
SET              clasecartera = Cartera
FROM         AOscar INNER JOIN
                          (SELECT     CodPrestamo, Cartera
                            FROM          tCsCartera with(nolock)
                            WHERE      (Fecha = @CorteFinal)) Cartera ON AOscar.CodPrestamo = Cartera.CodPrestamo COLLATE Modern_Spanish_CI_AI

UPDATE    AOscar
SET              ClaseCArtera = Cartera
FROM         AOscar INNER JOIN
                      tCsPadronCarteraDet with(nolock) ON AOscar.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN
                      tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
WHERE     (AOscar.ClaseCartera IS NULL)

Print 'INICIO3'
Print Getdate()
UPDATE  AOscar	
SET     coincidenciabase = tCsPadronClientes.Nombre1 + ', ' + tCsPadronClientes.Paterno, 
		desembolso		= tcscarteradet.montodesembolso,	
		DeudaTotal		= tCsCarteraDet.SaldoCapital + tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio + tCsCarteraDet.OtrosCargos + tCsCarteraDet.Impuestos + tCsCarteraDet.CargoMora,
		CierreEnero		=  ISNULL(Antes.SaldoCapital, 0) + ISNULL(Antes.SaldoInteres, 0) + ISNULL(Antes.SaldoMoratorio, 0) + ISNULL(Antes.OtrosCargos, 0) 
						  + ISNULL(Antes.Impuestos, 0) + ISNULL(Antes.CargoMora, 0),	
		PagoAlaFecha	= Pago.MontoPagado,
		FechaDesembolso = tCsCartera.FechaDesembolso, 
		Estado = tCsCartera.Estado,
		NroCuotas = tCsCartera.NroCuotas,
		FechaCancelacion = tCsPadronCarteraDet.Cancelacion,
		FechaCastigo	= tCsCartera.FechaCastigo,
		CorteInicial	= @CorteInicial, 
		CorteFinal 	= @CorteFinal
FROM         AOscar INNER JOIN	
                      tCsPadronCarteraDet with(nolock) ON AOscar.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 	
                      AOscar.CodUsuario = tCsPadronCarteraDet.CodUsuario INNER JOIN	
                      tCsPadronClientes with(nolock) ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN	
                      tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 	
                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN	
                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN	
                          (SELECT     CodPrestamo, CodUsuario, SUM(MontoPagado) AS MontoPagado	
                            FROM          tCsPagoDet with(nolock)	
                            WHERE      (Extornado = 0) AND (Fecha > @CorteInicial) And (Fecha <= @CorteFinal)	
                            GROUP BY CodPrestamo, CodUsuario) Pago ON tCsPadronCarteraDet.CodPrestamo = Pago.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 	
                      tCsPadronCarteraDet.CodUsuario = Pago.CodUsuario COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN	
                          (SELECT     *	
                            FROM          tcscarteradet with(nolock)	
                            WHERE      fecha = @CorteInicial) Antes ON tCsPadronCarteraDet.CodPrestamo = Antes.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 	
                      tCsPadronCarteraDet.CodUsuario = Antes.CodUsuario COLLATE Modern_Spanish_CI_AI	
WHERE     (AOscar.ClienteGrupo = 'C')		
	
UPDATE  AOscar	
SET     coincidenciabase = tCsPadronClientes.NombreCompleto, desembolso = tcscartera.montodesembolso,	
	DeudaTotal = tCsCartera.SaldoCapital + tCsCartera.SaldoINPE + tCsCartera.SaldoINVE + tCsCartera.OtrosCargos + tCsCartera.Impuestos + tCsCartera.CargoMora +  tCsCartera.SaldoInteresCorriente,
	CierreEnero =  ISNULL(Antes.SaldoCapital, 0) + ISNULL(Antes.SaldoINVE, 0) + ISNULL(Antes.SaldoINPE, 0) + ISNULL(Antes.OtrosCargos, 0) 
                      + ISNULL(Antes.Impuestos, 0) + ISNULL(Antes.CargoMora, 0) + ISNULL(Antes.SaldoInteresCorriente, 0),	
	PagoAlaFecha   = Pago.MontoPagado,
	FechaDesembolso = tCsCartera.FechaDesembolso, 
	Estado = tCsCartera.Estado,
	NroCuotas = tCsCartera.NroCuotas,
	FechaCancelacion = tCsPadronCarteraDet.Cancelacion,
	FechaCastigo	= tCsCartera.FechaCastigo,
	CorteInicial	= @CorteInicial, 
	CorteFinal 	= @CorteFinal
FROM         AOscar INNER JOIN	
                      tCsPadronCarteraDet with(nolock) ON AOscar.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 	
                      AOscar.CodUsuario = tCsPadronCarteraDet.CodUsuario INNER JOIN	
                      tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 	
                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN	
                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN	
                          (SELECT     CodOficina, codgrupo, NombreGrupo AS Nombrecompleto	
                            FROM          tCsCarteraGrupos with(nolock)) tCsPadronClientes ON tCsPadronCarteraDet.CodOficina = tCsPadronClientes.CodOficina AND 	
                      tCsPadronCarteraDet.CodGrupo = tCsPadronClientes.codgrupo LEFT OUTER JOIN	
                          (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado	
                            FROM          tCsPagoDet with(nolock)	
                            WHERE      (Extornado = 0) AND (Fecha > @CorteInicial) And (Fecha <= @CorteFinal)
                            GROUP BY CodPrestamo) Pago ON tCsPadronCarteraDet.CodPrestamo = Pago.CodPrestamo COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN	
                          (SELECT     *	
                            FROM          tcscartera	with(nolock)
                            WHERE      fecha = @CorteInicial) Antes ON tCsPadronCarteraDet.CodPrestamo = Antes.CodPrestamo COLLATE Modern_Spanish_CI_AI	
WHERE     (AOscar.ClienteGrupo = 'G') 

UPDATE    AOscar
SET     CapitalCastigado 	= Castigo.CapitalCastigado, 
		InteresCastigadoVig 	= Castigo.InteresVig, 
		InteresCastigadoVen 	= Castigo.InteresVen, 
		InteresCastigadoOrd 	= Castigo.InteresOrd, 
		MoratorioCastigadoVig 	= Castigo.MoratorioVig,
		MoratorioCastigadoVen 	= Castigo.MoratorioVen,
		MoratorioCastigadoOrd 	= Castigo.MoratorioOrd,
		MoraCastigada		= Castigo.MoraCastigada,
		OtrosCargosCastigado	= Castigo.OtrosCargosCastigado,
		ImpuestosCastigado	= castigo.ImpuestosCastigado
FROM         AOscar INNER JOIN
                          (SELECT     Datos.CodPrestamo, 
					SUM(tCsCarteraDet.SaldoCapital) 	AS CapitalCastigado, 
					SUM(tCsCarteraDet.InteresVigente) 	AS InteresVig, 
					SUM(tCsCarteraDet.InteresVencido) 	AS InteresVen, 
					SUM(tCsCarteraDet.InteresCtaOrden) 	AS InteresOrd, 
	                              	SUM(tCsCarteraDet.MoratorioVigente) 	AS MoratorioVig,
					SUM(tCsCarteraDet.MoratorioVencido) 	AS MoratorioVen,
					SUM(tCsCarteraDet.MoratorioCtaOrden) 	AS MoratorioOrd,				
				 	SUM(tCsCarteraDet.CargoMora) 		As MoraCastigada,
					SUM(tCsCarteraDet.OtrosCargos) 		As OtrosCargosCastigado,
					SUM(tCsCarteraDet.Impuestos) 		As ImpuestosCastigado
                            FROM          (SELECT     tCsCarteraDet.CodPrestamo, MIN(tCsCarteraDet.Fecha) AS Fecha
                                                    FROM          tCsCarteraDet with(nolock) INNER JOIN
                                                                           tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                                                    WHERE      (tCsCartera.Estado = 'CASTIGADO')
                                                    GROUP BY tCsCarteraDet.CodPrestamo) Datos INNER JOIN
                                                   tCsCarteraDet with(nolock) ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo AND 
                                                   Datos.Fecha = tCsCarteraDet.Fecha
                            GROUP BY Datos.CodPrestamo) Castigo ON AOscar.CodPrestamo = Castigo.CodPrestamo COLLATE Modern_Spanish_CI_AI

Print 'MEDIO'
Print Getdate()


UPDATE  AOscar
SET     CapitalCastigado		= Capital, 
		MoraCastigada			= Mora, 
		OtrosCargosCastigado	= OtrosCargos, 
		ImpuestosCastigado		= Impuestos,
		FechaCastigo			= Castigado.Fecha
FROM     (SELECT     Fecha, CodPrestamo, SUM(Capital) AS Capital, SUM(Interes) AS Interes, SUM(Moratorio) AS Moratorio, SUM(Mora) AS Mora, SUM(Impuestos) AS Impuestos, 
                                              SUM(Otroscargos) AS Otroscargos
                       FROM          (SELECT     tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodPrestamo, CASE WHEN codconcepto = 'CAPI' THEN Montoop ELSE 0 END AS Capital, 
                                                                      CASE WHEN codconcepto = 'INTE' THEN Montoop ELSE 0 END AS Interes, 
                                                                      CASE WHEN codconcepto = 'INPE' THEN Montoop ELSE 0 END AS Moratorio, CASE WHEN codconcepto IN ('IVACM', 'IVAIT', 'IVAMO') 
                                                                      THEN Montoop ELSE 0 END AS Impuestos, CASE WHEN codconcepto NOT IN ('CAPI', 'INTE', 'INPE', 'IVACM', 'IVAIT', 'IVAMO', 'MORA') 
                                                                      THEN Montoop ELSE 0 END AS Otroscargos, CASE WHEN codconcepto IN ('MORA') THEN Montoop ELSE 0 END AS Mora
                                               FROM          tCsOpRecuperablesDet with(nolock) INNER JOIN
                                                                      tCsOpRecuperables with(nolock) ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND 
                                                                      tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND 
                                                                      tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
                                               WHERE      (tCsOpRecuperables.TipoOp = '003')) Datos
                       GROUP BY Fecha, CodPrestamo) Castigado INNER JOIN
                      AOscar ON Castigado.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

UPDATE    Aoscar
SET              InteresCastigadovig = Interes * vigente, interescastigadoven = interes * vencido, InterescastigadoOrd = interes * orden
FROM         (SELECT     Nro, CodPrestamo, ISNULL(Vigente, 0) AS Vigente, ISNULL(Vencido, 0) AS Vencido, CASE WHEN isnull(Vigente, 0) + isnull(vencido, 0) + isnull(orden, 0) 
                                              = 0 THEN 1 ELSE orden END AS Orden
                       FROM          (SELECT     Nro, CodPrestamo, InteresCastigadoVig / CASE (AOscar.InteresCastigadoVig + AOscar.InteresCastigadoVen + AOscar.InteresCastigadoOrd) 
                                                                      WHEN 0 THEN 1 ELSE (AOscar.InteresCastigadoVig + AOscar.InteresCastigadoVen + AOscar.InteresCastigadoOrd) END AS Vigente, 
                                                                      InteresCastigadoVen / CASE (AOscar.InteresCastigadoVig + AOscar.InteresCastigadoVen + AOscar.InteresCastigadoOrd) 
                                                                      WHEN 0 THEN 1 ELSE (AOscar.InteresCastigadoVig + AOscar.InteresCastigadoVen + AOscar.InteresCastigadoOrd) END AS Vencido, 
                                                                      InteresCastigadoOrd / CASE (AOscar.InteresCastigadoVig + AOscar.InteresCastigadoVen + AOscar.InteresCastigadoOrd) 
                                                                      WHEN 0 THEN 1 ELSE (AOscar.InteresCastigadoVig + AOscar.InteresCastigadoVen + AOscar.InteresCastigadoOrd) END AS Orden
                                               FROM          AOscar) Datos) Datos INNER JOIN
                          (SELECT     Fecha, CodPrestamo, SUM(Capital) AS Capital, SUM(Interes) AS Interes, SUM(Moratorio) AS Moratorio, SUM(Mora) AS Mora, SUM(Impuestos) 
                                                   AS Impuestos, SUM(Otroscargos) AS Otroscargos
                            FROM          (SELECT     tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodPrestamo, CASE WHEN codconcepto = 'CAPI' THEN Montoop ELSE 0 END AS Capital,
                                                                            CASE WHEN codconcepto = 'INTE' THEN Montoop ELSE 0 END AS Interes, 
                                                                           CASE WHEN codconcepto = 'INPE' THEN Montoop ELSE 0 END AS Moratorio, CASE WHEN codconcepto IN ('IVACM', 'IVAIT', 'IVAMO') 
                                                                           THEN Montoop ELSE 0 END AS Impuestos, CASE WHEN codconcepto NOT IN ('CAPI', 'INTE', 'INPE', 'IVACM', 'IVAIT', 'IVAMO', 'MORA') 
                                                                           THEN Montoop ELSE 0 END AS Otroscargos, CASE WHEN codconcepto IN ('MORA') THEN Montoop ELSE 0 END AS Mora
                                                    FROM          tCsOpRecuperablesDet with(nolock) INNER JOIN
                                                                           tCsOpRecuperables with(nolock) ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND 
                                                                           tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND 
                                                                           tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND 
                                                                           tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
                                                    WHERE      (tCsOpRecuperables.TipoOp = '003')) Datos
                            GROUP BY Fecha, CodPrestamo) Castigado ON Datos.CodPrestamo = Castigado.CodPrestamo INNER JOIN
                      AOscar ON Datos.Nro = AOscar.Nro AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo


UPDATE    Aoscar
SET              MoratorioCastigadovig = Moratorio * vigente, Moratoriocastigadoven = Moratorio * vencido, MoratoriocastigadoOrd = Moratorio * orden
FROM         (SELECT     Nro, CodPrestamo, ISNULL(Vigente, 0) AS Vigente, ISNULL(Vencido, 0) AS Vencido, CASE WHEN isnull(Vigente, 0) + isnull(vencido, 0) + isnull(orden, 0) 
                                              = 0 THEN 1 ELSE orden END AS Orden
                       FROM          (SELECT     Nro, CodPrestamo, MoratorioCastigadoVig / CASE (AOscar.MoratorioCastigadoVig + AOscar.MoratorioCastigadoVen + AOscar.MoratorioCastigadoOrd) 
                                                                      WHEN 0 THEN 1 ELSE (AOscar.MoratorioCastigadoVig + AOscar.MoratorioCastigadoVen + AOscar.MoratorioCastigadoOrd) END AS Vigente, 
                                                                      MoratorioCastigadoVen / CASE (AOscar.MoratorioCastigadoVig + AOscar.MoratorioCastigadoVen + AOscar.MoratorioCastigadoOrd) 
                                                                      WHEN 0 THEN 1 ELSE (AOscar.MoratorioCastigadoVig + AOscar.MoratorioCastigadoVen + AOscar.MoratorioCastigadoOrd) END AS Vencido, 
                                                                      MoratorioCastigadoOrd / CASE (AOscar.MoratorioCastigadoVig + AOscar.MoratorioCastigadoVen + AOscar.MoratorioCastigadoOrd) 
                                                                      WHEN 0 THEN 1 ELSE (AOscar.MoratorioCastigadoVig + AOscar.MoratorioCastigadoVen + AOscar.MoratorioCastigadoOrd) END AS Orden
                                               FROM          AOscar) Datos) Datos INNER JOIN
                          (SELECT     Fecha, CodPrestamo, SUM(Capital) AS Capital, SUM(Interes) AS Interes, SUM(Moratorio) AS Moratorio, SUM(Mora) AS Mora, SUM(Impuestos) 
                                                   AS Impuestos, SUM(Otroscargos) AS Otroscargos
                            FROM          (SELECT     tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodPrestamo, CASE WHEN codconcepto = 'CAPI' THEN Montoop ELSE 0 END AS Capital,
                                                                            CASE WHEN codconcepto = 'INTE' THEN Montoop ELSE 0 END AS Interes, 
                                                                           CASE WHEN codconcepto = 'INPE' THEN Montoop ELSE 0 END AS Moratorio, CASE WHEN codconcepto IN ('IVACM', 'IVAIT', 'IVAMO') 
                                                                           THEN Montoop ELSE 0 END AS Impuestos, CASE WHEN codconcepto NOT IN ('CAPI', 'INTE', 'INPE', 'IVACM', 'IVAIT', 'IVAMO', 'MORA') 
                                                                           THEN Montoop ELSE 0 END AS Otroscargos, CASE WHEN codconcepto IN ('MORA') THEN Montoop ELSE 0 END AS Mora
                                                    FROM          tCsOpRecuperablesDet with(nolock) INNER JOIN
                                                                           tCsOpRecuperables with(nolock) ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND 
                                                                           tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND 
                                                                           tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND 
                                                                           tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
                                                    WHERE      (tCsOpRecuperables.TipoOp = '003')) Datos
                            GROUP BY Fecha, CodPrestamo) Castigado ON Datos.CodPrestamo = Castigado.CodPrestamo INNER JOIN
                      AOscar ON Datos.Nro = AOscar.Nro AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo




UPDATE    AOscar
SET             CapitalCierre 		= Castigo.CapitalCastigado, 
		InteresCierreVig 	= Castigo.InteresVig, 
		InteresCierreVen 	= Castigo.InteresVen, 
		InteresCierreOrd 	= Castigo.InteresOrd, 
		MoratorioCierreVig 	= Castigo.MoratorioVig,
		MoratorioCierreVen 	= Castigo.MoratorioVen,
		MoratorioCierreOrd 	= Castigo.MoratorioOrd,
		MoraCierre		= Castigo.MoraCastigada,
		OtrosCargosCierre	= Castigo.OtrosCargosCastigado,
		ImpuestosCierre		= castigo.ImpuestosCastigado
FROM         AOscar INNER JOIN
                          (SELECT     Datos.CodPrestamo, 
					SUM(tCsCarteraDet.SaldoCapital) 	AS CapitalCastigado, 
					SUM(tCsCarteraDet.InteresVigente) 	AS InteresVig, 
					SUM(tCsCarteraDet.InteresVencido) 	AS InteresVen, 
					SUM(tCsCarteraDet.InteresCtaOrden) 	AS InteresOrd, 
	                              	SUM(tCsCarteraDet.MoratorioVigente) 	AS MoratorioVig,
					SUM(tCsCarteraDet.MoratorioVencido) 	AS MoratorioVen,
					SUM(tCsCarteraDet.MoratorioCtaOrden) 	AS MoratorioOrd,				
				 	SUM(tCsCarteraDet.CargoMora) 		As MoraCastigada,
					SUM(tCsCarteraDet.OtrosCargos) 		As OtrosCargosCastigado,
					SUM(tCsCarteraDet.Impuestos) 		As ImpuestosCastigado
                            FROM          (SELECT     tCsCarteraDet.CodPrestamo, MIN(tCsCarteraDet.Fecha) AS Fecha
                                                    FROM          tCsCarteraDet with(nolock)
                                                    WHERE      (tCsCarteraDet.Fecha = @CorteInicial)
                                                    GROUP BY tCsCarteraDet.CodPrestamo) Datos INNER JOIN
                                                   tCsCarteraDet with(nolock) ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo AND 
                                                   Datos.Fecha = tCsCarteraDet.Fecha
                            GROUP BY Datos.CodPrestamo) Castigo ON AOscar.CodPrestamo = Castigo.CodPrestamo COLLATE Modern_Spanish_CI_AI

UPDATE    AOscar
SET             CapitalActual 		= Castigo.CapitalCastigado, 
		InteresActualVig 	= Castigo.InteresVig, 
		InteresActualVen 	= Castigo.InteresVen, 
		InteresActualOrd 	= Castigo.InteresOrd, 
		MoratorioActualVig 	= Castigo.MoratorioVig,
		MoratorioActualVen 	= Castigo.MoratorioVen,
		MoratorioActualOrd 	= Castigo.MoratorioOrd,
		MoraActual		= Castigo.MoraCastigada,
		OtrosCargosActual	= Castigo.OtrosCargosCastigado,
		ImpuestosActual		= castigo.ImpuestosCastigado
FROM         AOscar INNER JOIN
                          (SELECT     Datos.CodPrestamo, 
					SUM(tCsCarteraDet.SaldoCapital) 	AS CapitalCastigado, 
					SUM(tCsCarteraDet.InteresVigente) 	AS InteresVig, 
					SUM(tCsCarteraDet.InteresVencido) 	AS InteresVen, 
					SUM(tCsCarteraDet.InteresCtaOrden) 	AS InteresOrd, 
	                              	SUM(tCsCarteraDet.MoratorioVigente) 	AS MoratorioVig,
					SUM(tCsCarteraDet.MoratorioVencido) 	AS MoratorioVen,
					SUM(tCsCarteraDet.MoratorioCtaOrden) 	AS MoratorioOrd,				
				 	SUM(tCsCarteraDet.CargoMora) 		As MoraCastigada,
					SUM(tCsCarteraDet.OtrosCargos) 		As OtrosCargosCastigado,
					SUM(tCsCarteraDet.Impuestos) 		As ImpuestosCastigado
                            FROM          (SELECT     tCsCarteraDet.CodPrestamo, MIN(tCsCarteraDet.Fecha) AS Fecha
                                                    FROM          tCsCarteraDet with(nolock)
                                                    WHERE      (tCsCarteraDet.Fecha = @CorteFinal)
                                                    GROUP BY tCsCarteraDet.CodPrestamo) Datos INNER JOIN
                                                   tCsCarteraDet with(nolock) ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo AND 
                                                   Datos.Fecha = tCsCarteraDet.Fecha
                            GROUP BY Datos.CodPrestamo) Castigo ON AOscar.CodPrestamo = Castigo.CodPrestamo COLLATE Modern_Spanish_CI_AI


UPDATE    AOscar
SET       Estado = 'CANCELADO'
WHERE     (FechaCancelacion IS NOT NULL) And FechaCorte + 1 = FechaCancelacion

UPDATE    AOscar
SET              OtrosCargosCastigado = 0
WHERE     (OtrosCargosCastigado = ImpuestosCastigado)

UPDATE    AOscar
SET              OtrosCargosCierre = 0
WHERE     (OtrosCargosCierre = ImpuestosCierre)

UPDATE    AOscar
SET              OtrosCargosActual = 0
WHERE     (OtrosCargosActual = ImpuestosActual)

--REGISTRO DE PAGOS
If @Dato = 1  --- NO RESPETA CLASE DE CARTERA
Begin
	UPDATE    Aoscar
	SET       CapitalPago = MontoPagado
	FROM      (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM          tCsPagoDet with(nolock)
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
										AND (CodConcepto IN ('CAPI'))
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE    Aoscar
	SET       InteresPago = MontoPagado
	FROM      (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM          tCsPagoDet with(nolock)
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
										AND (CodConcepto IN ('INTE'))
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE		Aoscar
	SET         MoratorioPago = MontoPagado
	FROM        (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM          tCsPagoDet with(nolock)
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
									AND (CodConcepto IN ('INPE'))
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE    Aoscar
	SET       ImpuestosPago = MontoPagado
	FROM      (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM          tCsPagoDet with(nolock)
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
								AND (CodConcepto IN ('IVACM', 'IVAIT', 'IVAMO'))
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo


	UPDATE    Aoscar
	SET       MoraPago = MontoPagado
	FROM      (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM          tCsPagoDet with(nolock)
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
								AND (CodConcepto IN ('MORA'))
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE    Aoscar
	SET       OtrosCargosPago = MontoPagado
	FROM      (SELECT     CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM          tCsPagoDet with(nolock)
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
								AND (CodConcepto NOT IN ('CAPI', 'INPE', 'INTE', 'IVACM', 'IVAIT', 'IVAMO', 'MORA'))
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo
End
If @Dato = 2  --- RESPETA CLASE DE CARTERA
Begin
	UPDATE    Aoscar
	SET       CapitalPago = MontoPagado
	FROM      (SELECT     tCsPagoDet.CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM     tCsPagoDet with(nolock) INNER JOIN
									AOscar ON tCsPagoDet.CodPrestamo = AOscar.CodPrestamo AND tCsPagoDet.Fecha >= AOscar.CCI AND tCsPagoDet.Fecha <= AOscar.CCF
						   WHERE    (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
									AND (CodConcepto IN ('CAPI'))
						   GROUP BY tCsPagoDet.CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE    Aoscar
	SET       InteresPago = MontoPagado
	FROM      (SELECT     tCsPagoDet.CodPrestamo, SUM(MontoPagado) AS MontoPagado
						    FROM     tCsPagoDet with(nolock) INNER JOIN
									AOscar ON tCsPagoDet.CodPrestamo = AOscar.CodPrestamo AND tCsPagoDet.Fecha >= AOscar.CCI AND tCsPagoDet.Fecha <= AOscar.CCF
							WHERE    (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
									AND (CodConcepto IN ('INTE'))
							GROUP BY tCsPagoDet.CodPrestamo) Datos INNER JOIN
							AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE		Aoscar
	SET         MoratorioPago = MontoPagado
	FROM        (SELECT     tCsPagoDet.CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM     tCsPagoDet with(nolock) INNER JOIN
									AOscar ON tCsPagoDet.CodPrestamo = AOscar.CodPrestamo AND tCsPagoDet.Fecha >= AOscar.CCI AND tCsPagoDet.Fecha <= AOscar.CCF
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
									AND (CodConcepto IN ('INPE'))
						   GROUP BY tCsPagoDet.CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE    Aoscar
	SET       ImpuestosPago = MontoPagado
	FROM      (SELECT     tCsPagoDet.CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM     tCsPagoDet with(nolock) INNER JOIN
									AOscar ON tCsPagoDet.CodPrestamo = AOscar.CodPrestamo AND tCsPagoDet.Fecha >= AOscar.CCI AND tCsPagoDet.Fecha <= AOscar.CCF
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
								AND (CodConcepto IN ('IVACM', 'IVAIT', 'IVAMO'))
						   GROUP BY tCsPagoDet.CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo


	UPDATE    Aoscar
	SET       MoraPago = MontoPagado
	FROM      (SELECT     tCsPagoDet.CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM     tCsPagoDet with(nolock) INNER JOIN
									AOscar ON tCsPagoDet.CodPrestamo = AOscar.CodPrestamo AND tCsPagoDet.Fecha >= AOscar.CCI AND tCsPagoDet.Fecha <= AOscar.CCF
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
								AND (CodConcepto IN ('MORA'))
						   GROUP BY tCsPagoDet.CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo

	UPDATE    Aoscar
	SET       OtrosCargosPago = MontoPagado
	FROM      (SELECT     tCsPagoDet.CodPrestamo, SUM(MontoPagado) AS MontoPagado
						   FROM     tCsPagoDet with(nolock) INNER JOIN
									AOscar ON tCsPagoDet.CodPrestamo = AOscar.CodPrestamo AND tCsPagoDet.Fecha >= AOscar.CCI AND tCsPagoDet.Fecha <= AOscar.CCF
						   WHERE      (Extornado = 0) AND (Fecha >= @CorteInicial) AND (Fecha <= @CorteFinal) 
								AND (CodConcepto NOT IN ('CAPI', 'INPE', 'INTE', 'IVACM', 'IVAIT', 'IVAMO', 'MORA'))
						   GROUP BY tCsPagoDet.CodPrestamo) Datos INNER JOIN
						  AOscar ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = AOscar.CodPrestamo
End

UPDATE    Aoscar
SET       FechaCancelacion = Recuperacion.fecha
FROM      AOscar INNER JOIN
                          (SELECT     CodPrestamo, MAX(Fecha) AS Fecha
                            FROM          tCsPagoDet with(nolock)
                            WHERE      (Extornado = 0) AND (Fecha <= @CorteFinal)
                            GROUP BY tCsPagoDet.CodPrestamo) Recuperacion ON AOscar.CodPrestamo = Recuperacion.CodPrestamo COLLATE Modern_Spanish_CI_AI
WHERE     (AOscar.FechaCancelacion IS NULL)

--Select Ubicacion = @Ubicacion, ClaseCartera = @ClaseCartera,* from Aoscar
Select Nro, ClaseCartera = @ClaseCartera, CoincidenciaBase as Dato, CodPrestamo, Observacion, FechaDesembolso = 
	dbo.fduFechaAtexto(FechaDesembolso, 'DD') + '/' +
	dbo.fduFechaAtexto(FechaDesembolso, 'MM') + '/' +
	dbo.fduFechaAtexto(FechaDesembolso, 'AAAA') 
	, Desembolso, NroCuotas, Estado, 
	FechaCastigo = dbo.fduFechaAtexto(FechaCastigo, 'DD') + '/' +
	dbo.fduFechaAtexto(FechaCastigo, 'MM') + '/' +
	dbo.fduFechaAtexto(FechaCastigo, 'AAAA') , 
             CapitalCastigado, InteresCastigadoVig, InteresCastigadoVen, InteresCastigadoOrd, MoratorioCastigadoVig, MoratorioCastigadoVen, 
	MoratorioCastigadoOrd, MoraCastigada, OtrosCargosCastigado, ImpuestosCastigado, 
	CtaBalanceCastigada = InteresCastigadoVig + InteresCastigadoVen + MoratorioCastigadoVig + MoratorioCastigadoVen,
	CtaOrdenCastigada = InteresCastigadoOrd + MoratorioCastigadoOrd,
	TotalCastigada, 
	CorteInicial =  dbo.fduFechaAtexto(CorteInicial, 'DD') + '/' +
	dbo.fduFechaAtexto(CorteInicial, 'MM') + '/' +
	dbo.fduFechaAtexto(CorteInicial, 'AAAA') ,  CapitalCierre, InteresCierreVig, InteresCierreVen, InteresCierreOrd, 
             MoratorioCierreVig, MoratorioCierreVen, MoratorioCierreOrd, MoraCierre, OtrosCargosCierre, ImpuestosCierre, 
	CtaBalanceCierre = InteresCierreVig + InteresCierreVen + MoratorioCierreVig + MoratorioCierreVen,
	CtaOrdenCierre = InteresCierreOrd + MoratorioCierreOrd,
	TotalCierre, CorteFinal =  dbo.fduFechaAtexto(CorteFinal, 'DD') + '/' +
	dbo.fduFechaAtexto(CorteFinal, 'MM') + '/' +
	dbo.fduFechaAtexto(CorteFinal, 'AAAA') , CapitalActual, InteresActualVig, 
             InteresActualVen, InteresActualOrd, MoratorioActualVig, MoratorioActualVen, MoratorioActualOrd, MoraActual, OtrosCargosActual, ImpuestosActual, 
	CtaBalanceActual = InteresActualVig + InteresActualVen + MoratorioActualVig + MoratorioActualVen,
	CtaOrdenActual = InteresActualOrd + MoratorioActualOrd,
	TotalActual, 
             CapitalPago, InteresPago, MoratorioPago, MoraPago, OtrosCargosPago, ImpuestosPago, TotalPago, FechaCancelacion =  dbo.fduFechaAtexto(FechaCancelacion, 'DD') + '/' +
	dbo.fduFechaAtexto(FechaCancelacion, 'MM') + '/' +
	dbo.fduFechaAtexto(FechaCancelacion, 'AAAA') 
--, FechaCorte, DeudaTotal, CierreEnero, 
 --       PagoALaFecha 
From Aoscar

Print 'FIN'
Print Getdate()
GO