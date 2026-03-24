SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[pCsUNISAP2] @Sistema 	Varchar(2), @Fecha		SmallDateTime
AS

--declare @Sistema 	Varchar(2)
--declare @Fecha		SmallDateTime

--set @Sistema='CA'
--set @Fecha='20120131'

Declare @Periodo	Varchar(6)
Declare @FechaI		SmallDateTime

declare @T1 datetime
declare @T2 datetime

set @T1 = getdate()

set nocount on

Set @Periodo	= dbo.fduFechaATexto(@Fecha, 'AAAAMM')
Set @FechaI 	= Cast(@Periodo + '01' as SmallDateTime)

set @T2 = getdate()
print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. inicial'
set @T1 = getdate()

If @Sistema = 'AH'
Begin
	
	CREATE TABLE #LLLLL(
		[Fecha] [datetime] NOT NULL,
		[CodCuenta] [varchar](25) NOT NULL,
		[FraccionCta] [varchar](8) NOT NULL,
		[Renovado] [tinyint] NOT NULL,
		[CodOficina] [varchar](4) NULL,
		[CodProducto] [varchar](3) NULL,
		[CodMoneda] [tinyint] NULL,
		[CodUsuario] [varchar](15) NULL,
		[FormaManejo] [smallint] NULL,
		[FechaApertura] [datetime] NULL,
		[FechaVencimiento] [datetime] NULL,
		[FechaCierre] [datetime] NULL,
		[TasaInteres] [money] NULL,
		[FechaUltMov] [datetime] NULL,
		[TipoCambioFijo] [decimal](18, 7) NULL,
		[SaldoCuenta] [money] NULL,
		[SaldoMonetizado] [money] NULL,
		[MontoInteres] [money] NULL,
		[IntAcumulado] [money] NULL,
		[MontoInteresCapitalizado] [money] NULL,
		[MontoBloqueado] [money] NULL,
		[MontoRetenido] [money] NULL,
		[InteresCalculado] [money] NULL,
		[Plazo] [numeric](10, 0) NULL,
		[Lucro] [bit] NULL,
		[CodAsesor] [varchar](15) NULL,
		[CodOficinaUltTransaccion] [varchar](4) NULL,
		[TipoUltTransaccion] [smallint] NULL,
		[FechaUltCapitalizacion] [datetime] NULL,
		[IdDocRespaldo] [int] NULL,
		[NroSerie] [varchar](25) NULL,
		[idEstadoCta] [char](2) NULL,
		[NomCuenta] [varchar](80) NULL,
		[FondoConfirmar] [money] NULL,
		[Observacion] [varchar](500) NULL,
		[EnGarantia] [bit] NULL,
		[Garantia] [varchar](50) NULL,
		[CuentaPreferencial] [bit] NULL,
		[CuentaReservada] [bit] NULL,
		[CodCuentaAnt] [varchar](25) NULL,
		[AplicaITF] [bit] NULL,
		[PorcCliente] [int] NULL,
		[PorcInst] [int] NULL,
		[idTipoCapi] [smallint] NULL,
		[FechaCambioEstado] [datetime] NULL,
		[FechaInactivacion] [datetime] NULL,
		[NroSolicitud] [varchar](25) NULL,
		[CodTipoInteres] [smallint] NULL,
		[IdTipoRenova] [smallint] NULL,
		[PlazoDiasRenov] [int] NULL,
		[InteresCapitalizable] [bit] NULL,
		[CodPrestamo] [varchar](25) NULL,
		[MontoGarantia] [money] NULL,
		[TipoConta] [varchar](10) NULL,
		[ContaCodigo] [varchar](25) NULL,
		[DevengadoMes] [money] NULL,
		[SaldoPromedio] [money] NULL) 
	
	insert Into #LLLLL 
	Select *, DevengadoMes = 0, SaldoPromedio = 0 From tCsAhorros with(nolock) Where Fecha = @Fecha

	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. tcsahorros'
	set @T1 = getdate()	

	create table #mes (
		codcuenta varchar(25),
		FraccionCta varchar(8),
		Renovado tinyint,
		DevengadoMes money,
		SaldoPromedio money
	) ON [PRIMARY]

	insert into #mes
	SELECT        CodCuenta, FraccionCta, Renovado, SUM(InteresCalculado) AS DevengadoMes, AVG(SaldoCuenta + IntAcumulado) AS SaldoPromedio
	FROM            tCsAhorros with(nolock)
	--WHERE        (dbo.fduFechaAPeriodo(Fecha) = @Periodo)
	where fecha>=@FechaI and fecha<=@Fecha
	GROUP BY CodCuenta, FraccionCta, Renovado

	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. gruop csahorros'
	set @T1 = getdate()

	UPDATE       #LLLLL
	SET                DevengadoMes = Mes.DevengadoMes, SaldoPromedio = Mes.SaldoPromedio
	FROM            #LLLLL  INNER JOIN
	--	 (SELECT        CodCuenta, FraccionCta, Renovado, SUM(InteresCalculado) AS DevengadoMes, AVG(SaldoCuenta + IntAcumulado) AS SaldoPromedio
	--	   FROM            tCsAhorros with(nolock)
	--	   WHERE        (dbo.fduFechaAPeriodo(Fecha) = @Periodo)
	--	   GROUP BY CodCuenta, FraccionCta, Renovado) 
	#mes AS Mes ON #LLLLL.CodCuenta = Mes.CodCuenta AND #LLLLL.FraccionCta = Mes.FraccionCta AND 
	 #LLLLL.Renovado = Mes.Renovado 

	drop table #mes

	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. update mes'
	set @T1 = getdate()

	DELETE FROM tCsUnisapAH
	WHERE     (Fecha = @Fecha)

	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. delete tcsunisapah'
	set @T1 = getdate()	

	INSERT INTO tCsUnisapAH (Fecha, CodCuenta, FraccionCta, Renovado, CodUsuario, NombreCompleto, DescTipoProd, FechaApertura, FechaVencimiento, Plazo, PagoRendimiento, 
	                      TasaInteres, SaldoBruto, IntAcumulado1, SaldoTotal, MontoDPF, IntAcumulado, DevengadoMes, SaldoPromedio, NomOficina, Ubigeo,nomproducto,fechaalta,municipio)
	SELECT        @Fecha AS Fecha, tCsAhorros.CodCuenta, tCsAhorros.FraccionCta, tCsAhorros.Renovado, tCsAhorros.CodUsuario, tCsPadronClientes.NombreCompleto, 
	 tAhClTipoProducto.DescTipoProd, tCsAhorros.FechaApertura, tCsAhorros.FechaVencimiento, CASE ISNULL(tCsAhorros.Plazo, 0) 
	 WHEN 0 THEN 'A LA VISTA' ELSE CAST(ISNULL(tCsAhorros.Plazo, 0) AS varchar(50)) END AS Plazo, DATEDIFF(day, 
	 CASE WHEN tCsAhorros.FechaApertura < @FechaI THEN @FechaI ELSE tCsAhorros.FechaApertura END, @Fecha) + 1 AS PagoRendimiento, tCsAhorros.TasaInteres, 
	 tCsAhorros.SaldoCuenta AS SaldoBruto, tCsAhorros.IntAcumulado AS IntAcumulado1, tCsAhorros.SaldoCuenta + tCsAhorros.IntAcumulado AS SaldoTotal, 
	 CASE TAhProductos.idTipoProd WHEN 2 THEN saldocuenta END AS MontoDPF, tCsAhorros.IntAcumulado, tCsAhorros.DevengadoMes, tCsAhorros.SaldoPromedio, 
	 tClOficinas.NomOficina, ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) AS Ubigeo, 
	 tAhProductos.nombre,tCsPadronClientes.fechaingreso,m.municipio
	FROM            tClOficinas RIGHT OUTER JOIN
	 #LLLLL AS tCsAhorros ON tClOficinas.CodOficina = tCsAhorros.CodOficina LEFT OUTER JOIN
	 tAhClTipoProducto INNER JOIN
	 tAhProductos with(nolock) ON tAhClTipoProducto.idTipoProd = tAhProductos.idTipoProd 
	 ON tCsAhorros.CodProducto = tAhProductos.idProducto LEFT OUTER JOIN
	 tCsPadronClientes with(nolock) ON tCsAhorros.CodUsuario = tCsPadronClientes.CodUsuario
	left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(tCsPadronClientes.codubigeodirfampri,tCsPadronClientes.codubigeodirnegpri)
	left outer join (select codarbolconta, descubigeo municipio from tclubigeo with(nolock) where codubigeotipo='MUNI') m on m.codarbolconta=substring(u.codarbolconta,1,19)
	WHERE        (tCsAhorros.Fecha = @Fecha)
	
	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. insert'
	set @T1 = getdate()

	Drop Table #LLLLL

  print 'fin ahorros'

End
If @Sistema = 'CA'
Begin
  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. Ingresa a CA'
  set @T1 = getdate()
	
	Exec pCsDiaGarantias @Fecha --ojo bloqueo temporal - analizar porque se debe ejecutar siempre???? no lo veo
	
	set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. pCsDiaGarantias'
  set @T1 = getdate()

	DELETE FROM tCsUnisapCA     --OJOO HABILITAR 
	WHERE     (Fecha = @Fecha)
	
	set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. delete tCsUnisapCA'
  set @T1 = getdate()
	
	IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Kemy]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin DROP TABLE [dbo].[Kemy] End

	Select * 
	Into Kemy
	From tCsCarteraDet with(nolock)
	Where Fecha = @Fecha
  --Tiempo 41140  mseg. kemy
  --Tiempo 250    mseg. kemy
  	
  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. kemy'
  set @T1 = getdate()

  --ultimo capital
  create table #tCsPagoDetUC (
    codprestamo varchar(25),
    codusuario varchar(15),
    FechaUltimaCapital smalldatetime
  )  
  insert into #tCsPagoDetUC
  SELECT     CodPrestamo, CodUsuario, MAX(Fecha) AS FechaUltimaCapital
  FROM          tCsPagoDet with(nolock)
	WHERE      (Fecha <=@Fecha) --'20120131' )
	AND (CodConcepto IN ('CAPI')) AND (Extornado = 0)
	GROUP BY CodPrestamo, CodUsuario

--	drop table #tCsPagoDetUC

	set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. ultimo capital'
  set @T1 = getdate()
  --mora
  create table #tCsPagoDetMo (
    codprestamo varchar(25),
    codusuario varchar(15),
    PagoXMora decimal(16,4)
  )  
  insert into #tCsPagoDetMo
  SELECT     CodPrestamo, CodUsuario, SUM(MontoPagado) AS PagoXMora
	FROM          tCsPagoDet with(nolock)
	WHERE      (CodConcepto = 'MORA') 
	--AND (dbo.fduFechaAPeriodo(Fecha) = @Periodo)
	and (Fecha>= @FechaI) AND (Fecha <= @Fecha)
	GROUP BY CodPrestamo, CodUsuario
	set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. mora'
  set @T1 = getdate()
  --ultimo interes
  create table #tCsPagoDetUI (
    codprestamo varchar(25),
    codusuario varchar(15),
    FechaUltimoInteres smalldatetime
  )  
  insert into #tCsPagoDetUI
  SELECT     CodPrestamo, CodUsuario, MAX(Fecha) AS FechaUltimoInteres
	FROM          tCsPagoDet with(nolock)
	WHERE      (Fecha <= @Fecha) AND (CodConcepto IN ('INTE', 'INPE')) AND (Extornado = 0)
	GROUP BY CodPrestamo, CodUsuario

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. ultimo interes'
  set @T1 = getdate()
  --interes devengado
  create table #intdevengado (
    codprestamo varchar(25),
    codusuario varchar(15),
    SaldoPromedio decimal(16,4),
    DevengadoMes decimal(16,4),
    DevengadoPromedio decimal(16,4)
  )  
  insert into #intdevengado
  SELECT     CodPrestamo, CodUsuario, AVG(SaldoCapital + InteresVigente + InteresVencido + MoratorioVigente + MoratorioVencido) AS SaldoPromedio, 
	SUM(InteresDevengado) AS DevengadoMes, AVG(InteresDevengado + MoratorioDevengado) AS DevengadoPromedio
	FROM          tCsCarteraDet with(nolock)
	--WHERE      (dbo.fduFechaAPeriodo(Fecha) = @Periodo) AND (Fecha <= @Fecha)
	--WHERE      (dbo.fduFechaAPeriodo(Fecha) = '201201') AND (Fecha <= '20120131')
  WHERE      (Fecha>= @FechaI) AND (Fecha <= @Fecha) -- 1 minuto al menos jajaja
  and codprestamo not in (select distinct codprestamo from tcspadroncarteradet with(nolock) --where codgrupo not in('ALTA1','ALTA2','ALTA4') 
							where codoficina in(230,231) or (codgrupo in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9','ALTA10'))
						)--and codproducto=169
	GROUP BY CodPrestamo, CodUsuario

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. interes devegando'
  set @T1 = getdate()

 --comision
  create table #comision (
    codprestamo varchar(25),
    Comision decimal(16,4)
  )  
  insert into #comision
	SELECT     CodPrestamo, SUM(TotalPagado) AS Comision
	FROM          tCsConceptosPrestamo with(nolock)
	WHERE      (TipoCobro = 'A') AND (RTRIM(LTRIM(ConceptoDeCalculo)) IN ('', NULL))
	and codprestamo not in (select distinct codprestamo from tcspadroncarteradet with(nolock) --where codgrupo not in('ALTA1','ALTA2','ALTA4') 
							where codoficina in(230,231) or (codgrupo in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9','ALTA10'))
							)--and codproducto=169
	GROUP BY CodPrestamo

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. comision'
  set @T1 = getdate()

 --garantias vCsCaGarantias

CREATE TABLE #vCsCaGarantias1 (
	[Fecha] [smalldatetime] NOT NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[NroGarantias] [int] NULL ,
	[MiDG] [varchar] (200) COLLATE Modern_Spanish_CI_AI NULL ,
	[MaDG] [varchar] (200) COLLATE Modern_Spanish_CI_AI NULL ,
	[GarantiaLiquida] [decimal](38, 4) NULL ,
	[GarantiaPrendaria] [decimal](38, 4) NULL ,
	[GarantiaHipotecaria] [int] NOT NULL ,
	[GarantiaOtras] [decimal](38, 4) NULL ,
	[Formalizada] [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Cartera] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL 
) ON [PRIMARY]

insert into #vCsCaGarantias1
SELECT tCsDiaGarantias.Fecha, ISNULL(tCsCartera_2.CodPrestamo, tCsDiaGarantias.Codigo) AS CodPrestamo, COUNT(*) AS NroGarantias
, MIN(isnull(tCsDiaGarantias.DescGarantia,tCsDiaGarantias.tipogarantia)) AS MiDG
, MAX(isnull(tCsDiaGarantias.DescGarantia,tCsDiaGarantias.tipogarantia)) AS MaDG, 
CASE WHEN tCsDiaGarantias.TipoGarantia IN ('-A-', 'GADPF', 'GARAH') THEN SUM(tCsDiaGarantias.Garantia) 
ELSE 0 END AS GarantiaLiquida, CASE WHEN tCsDiaGarantias.TipoGarantia IN ('1', 'DOCIN', 'ME1', 'P06', 'PC2', 'PD9', 'VH1', 
'VH2','Joya') THEN SUM(tCsDiaGarantias.Garantia) ELSE 0 END AS GarantiaPrendaria, 0 AS GarantiaHipotecaria, 
CASE WHEN tCsDiaGarantias.TipoGarantia NOT IN ('1', 'DOCIN', 'ME1', 'P06', 'PC2', 'PD9', 'VH1', 'VH2', '-A-', 'GADPF', 'GARAH','Joya') 
THEN SUM(tCsDiaGarantias.Garantia) ELSE 0 END AS GarantiaOtras, tCsDiaGarantias.Formalizada, tCsCartera_2.Cartera
FROM tCsDiaGarantias WITH (nolock) LEFT OUTER JOIN
tCsCartera AS tCsCartera_2 WITH (nolock) ON tCsDiaGarantias.Fecha = tCsCartera_2.Fecha AND 
tCsDiaGarantias.Codigo = tCsCartera_2.CodSolicitud AND tCsDiaGarantias.CodOficina = tCsCartera_2.CodOficina
where tCsDiaGarantias.Fecha=@Fecha--'20120131'
GROUP BY tCsDiaGarantias.Fecha, ISNULL(tCsCartera_2.CodPrestamo, tCsDiaGarantias.Codigo), tCsDiaGarantias.TipoGarantia, 
tCsDiaGarantias.Formalizada, tCsCartera_2.Cartera

CREATE TABLE #vCsCaGarantias2 (
	[Fecha] [smalldatetime] ,
	[Formalizada] [varchar] (2) ,
	[Cartera] [varchar] (50) , 
	[CodPrestamo] [varchar] (25) ,
	[NroGarantias] [int] ,
	[MDG] [varchar] (200) ,
	[GarantiaLiquida] [decimal](38, 4) ,
	[GarantiaPrendaria] [decimal](38, 4) ,
	[GarantiaHipotecaria] [decimal](38, 4) ,
	[GarantiaOtras] [decimal](38, 4)
) ON [PRIMARY]

insert into #vCsCaGarantias2
SELECT  Fecha, Formalizada, Cartera, CodPrestamo, SUM(NroGarantias) AS NroGarantias, CASE WHEN MIN(MDG) = MAX(MDG) THEN MIN(MDG) 
ELSE Replace(MIN(MDG) + '<>' + MAX(MDG), '  ', ' ') END AS MDG, SUM(GarantiaLiquida) AS GarantiaLiquida, SUM(GarantiaPrendaria) 
AS GarantiaPrendaria, SUM(GarantiaHipotecaria) AS GarantiaHipotecaria, SUM(GarantiaOtras) AS GarantiaOtras
FROM (SELECT Datos.Fecha, Datos.CodPrestamo, SUM(Datos.NroGarantias) AS NroGarantias, 
			CASE WHEN Datos.MiDG = Datos.MaDG THEN Datos.MiDG ELSE Replace(Datos.MiDG + '<>' + Datos.MaDG, '  ', ' ') END AS MDG, 
      SUM(Datos.GarantiaLiquida) AS GarantiaLiquida, SUM(Datos.GarantiaPrendaria) AS GarantiaPrendaria, SUM(Datos.GarantiaHipotecaria) 
      AS GarantiaHipotecaria, SUM(Datos.GarantiaOtras) AS GarantiaOtras, Datos.Formalizada, ISNULL(Datos.Cartera, tCsCartera.Cartera) 
      AS Cartera
      FROM #vCsCaGarantias1 AS Datos INNER JOIN
            tCsCartera ON Datos.Fecha = tCsCartera.Fecha AND Datos.CodPrestamo = tCsCartera.CodPrestamo
            GROUP BY Datos.Fecha, Datos.CodPrestamo, Datos.MiDG, Datos.MaDG, Datos.Formalizada, 
						ISNULL(Datos.Cartera, tCsCartera.Cartera)) Datos
GROUP BY Fecha, CodPrestamo, Formalizada, Cartera

drop table #vCsCaGarantias1
--drop table #vCsCaGarantias2

 set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. vCsCaGarantias'
  set @T1 = getdate()

 --CtasOrdenRecuperado
  create table #COrecup (
    codprestamo varchar(25),
    codusuario varchar(15),
    CtasOrdenRecuperado decimal(16,4)
  )  ON [PRIMARY]

	insert into #COrecup
	SELECT tCsPagoDet.CodPrestamo, tCsPagoDet.CodUsuario, SUM(tCsPagoDet.MontoPagado) AS CtasOrdenRecuperado
	FROM tCsPagoDet with(nolock) LEFT OUTER JOIN
	tCsPadronPlanCuotas with(nolock) INNER JOIN
	tCsPadronCarteraDet with(nolock) ON tCsPadronPlanCuotas.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
	tCsPadronPlanCuotas.CodUsuario = tCsPadronCarteraDet.CodUsuario ON tCsPagoDet.CodConcepto = tCsPadronPlanCuotas.CodConcepto AND 
	tCsPagoDet.SecCuota = tCsPadronPlanCuotas.SecCuota AND tCsPagoDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
	tCsPagoDet.CodUsuario = tCsPadronCarteraDet.CodUsuario
	--WHERE (dbo.fduFechaAPeriodo(tCsPagoDet.Fecha) = '201201')--@Periodo) 
	WHERE 	(tCsPagoDet.Fecha>= @FechaI) AND (tCsPagoDet.Fecha <= @Fecha)
	--WHERE 	(tCsPagoDet.Fecha>= '20120101') AND (tCsPagoDet.Fecha <= '20120131')
	AND (tCsPagoDet.CodConcepto IN ('INTE', 'INPE')) AND (tCsPagoDet.Extornado = 0) AND 
	(DATEDIFF(d, tCsPadronPlanCuotas.FechaVencimiento, tCsPagoDet.Fecha) >= 90)
	and tCsPagoDet.codprestamo not in (select distinct codprestamo from tcspadroncarteradet with(nolock) --where codgrupo not in('ALTA1','ALTA2','ALTA4')
										where codoficina in(230,231) or (codgrupo in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9','ALTA10'))
										)--and codproducto=169
	GROUP BY tCsPagoDet.CodPrestamo, tCsPagoDet.CodUsuario

 set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. #COrecup'
  set @T1 = getdate()


	Print 'Inicia Inserccion'
	INSERT INTO tCsUnisapCA
	SELECT DISTINCT 
						  tCsCarteraDet.Fecha, YEAR(tCsCarteraDet.Fecha) AS Año, MONTH(tCsCarteraDet.Fecha) AS Mes, tCsPadronClientes.NombreCompleto, tCsCarteraDet.CodUsuario, 
						  tCsCartera.CodOficina, tClOficinas.NomOficina, tCsCartera.CodProducto, tCsCarteraDet.CodPrestamo, tCaClTecnologia.NombreTec AS Tecnologia, 
						  tCaProdPerTipoCredito.Descripcion AS TipoCredito,
						  CASE tCsCartera.Condonado WHEN 1 THEN 'Con Condonacion' WHEN 0 THEN 'Pago Periodico' ELSE 'No Especifica' END AS Condicion, 
						  tCsCartera.FechaDesembolso, tCsCarteraDet.MontoDesembolso, tCsCartera.FechaVencimiento, tCsCartera.TasaIntCorriente, tCsCartera.TasaINPE AS TasaIntMora, 
						  tCsCartera.NroCuotas, ISNULL(tCaClModalidadPlazo.Descripcion, 'No Identificado(' + tCsCartera.ModalidadPlazo + ')') AS Frecuencia, tCsCartera.NroDiasAtraso, 
						  CASE WHEN tCsCartera.Estado = 'VIGENTE' THEN tCsCarteraDet.SaldoCapital ELSE 0 END AS CapitalVigente, CASE WHEN tCsCartera.Estado IN ('VENCIDO', 
						  'CASTIGADO') THEN tCsCarteraDet.SaldoCapital ELSE 0 END AS CapitalVencido, tCsCarteraDet.InteresVigente, tCsCarteraDet.InteresVencido, 
						  tCsCarteraDet.InteresCtaOrden AS CtaOrdInteres, tCsCarteraDet.MoratorioCtaOrden AS CtaOrdMoratorio, InteresDevengado.SaldoPromedio, 
						  InteresDevengado.DevengadoPromedio, InteresDevengado.DevengadoMes, ISNULL(OrdenRecuperada.CtasOrdenRecuperado, 0) AS CtasOrdenRecuperado, 
						  CASE WHEN preservainteres <> 100 THEN tCsCarteraDet.SReservaInteres + tCsCarteraDet.SReservaCapital ELSE tCsCarteraDet.SReservaCapital END AS ReservaPreventiva,
						   CASE WHEN preservainteres = 100 THEN tCsCarteraDet.SReservaInteres ELSE 0 END AS ReservaP100Interes, UltimoCapital.FechaUltimaCapital, 
						  UltimoInteres.FechaUltimoInteres, UltimoCapital.MontoUltimoCapital, UltimoInteres.MontoUltimoInteres, tCsCartera.Estado, 
						  CASE WHEN tCsCartera.TipoReprog IN ('SINRE','REFRE','REPRO') THEN 'Normal' WHEN tCsCartera.TipoReprog IN ('REEST') 
						  THEN 'Reestructurado' ELSE 'No Especificado' END AS Reestructurado
						  ,case when tCsCartera.TipoReprog IN('SINRE','REFRE') THEN 0 ELSE tCsCartera.NumReprog END NumReprog
						  , ISNULL(Garantia.NroGarantias, 0) AS NroGarantias, 
						  ISNULL(Garantia.DescGarantia, '') AS DescGarantia, ISNULL(Garantia.GarantiaLiquida, 0) AS GarantiaLiquida, ISNULL(Garantia.GarantiaPrendaria, 0) 
						  AS GarantiaPrendaria, ISNULL(Garantia.GarantiaHipotecaria, 0) AS GarantiaHipotecaria, ISNULL(Garantia.GarantiaOtras, 0) AS GarantiaOtras, 
						  ISNULL(Garantia.Formalizada, 'NO') AS Formalizada, tClFondos.Redescuento, tClFondos.NemFondo, 
						  tCsCarteraDet.SReservaCapital + tCsCarteraDet.SReservaInteres AS EPreventiva, tCsCarteraDet.CargoMora, Mora.PagoXMora, Comision.Comision, 
						  tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, tCsCartera.CodAsesor, tCsPadronClientes_1.NombreCompleto AS Asesor, 
						  ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) AS CodUbigeo, tCsPadronClientes.FechaNacimiento, DATEDIFF(year, 
						  tCsPadronClientes.FechaNacimiento, tCsCarteraDet.Fecha) AS Edad, tCsPadronClientes.usCURP, tCsPadronClientes.UsRFC, ISNULL(tUsClEstadoCivil.EstadoCivil, 
						  'No Identificado') AS EstadoCivil, ISNULL(tUsClSexo.Nombre, 'No Identificado') AS Sexo, tCsPadronClientes.RubroNegocio, tCsPadronClientes.Actividad, 
						  tCsPadronClientes.GradoInstruccion, tCPClEstado.Estado AS EstadoDireccion, tCPClMunicipio.Municipio, ISNULL(tCPLugar.Lugar, tClUbigeo.DescUbiGeo) AS Lugar, 
						  ISNULL(tCsPadronClientes.DireccionDirFamPri, tCsPadronClientes.DireccionDirNegPri) AS Direccion, tCsCartera.FechaCastigo, NULL AS DiasXX
	FROM         tClFondos RIGHT OUTER JOIN
						  tCsPadronClientes with(nolock) LEFT OUTER JOIN
						  tClUbigeo INNER JOIN
						  tCPClEstado INNER JOIN
						  tCPLugar INNER JOIN
						  tCPClMunicipio ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado ON 
						  tCPClEstado.CodEstado = tCPClMunicipio.CodEstado ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND 
						  tClUbigeo.CodEstado = tCPLugar.CodEstado ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) 
						  = tClUbigeo.CodUbiGeo LEFT OUTER JOIN
						  tUsClEstadoCivil ON tCsPadronClientes.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil LEFT OUTER JOIN
						  tUsClSexo ON tCsPadronClientes.Sexo = tUsClSexo.Sexo RIGHT OUTER JOIN
						  tCaClProvision RIGHT OUTER JOIN
						  tCsPadronClientes AS tCsPadronClientes_1 with(nolock) RIGHT OUTER JOIN
						  tCsCartera with(nolock) LEFT OUTER JOIN
						  tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo ON 
						  tCsPadronClientes_1.CodUsuario = tCsCartera.CodAsesor LEFT OUTER JOIN
						  tCaProducto INNER JOIN
						  tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia ON tCsCartera.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN
						  tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
							-- ojo aqui
							--  (SELECT     CodPrestamo, SUM(TotalPagado) AS Comision
							--	FROM          tCsConceptosPrestamo with(nolock)
							--	WHERE      (TipoCobro = 'A') AND (RTRIM(LTRIM(ConceptoDeCalculo)) IN ('', NULL))
							--	GROUP BY CodPrestamo) 
								#comision AS Comision 

								ON tCsCartera.CodPrestamo = Comision.CodPrestamo LEFT OUTER JOIN
						-- ojo aqui
						 (SELECT CodPrestamo AS Codigo, MDG AS DescGarantia, Formalizada, GarantiaLiquida, GarantiaPrendaria, GarantiaHipotecaria, GarantiaOtras, 
													   NroGarantias
								FROM          #vCsCaGarantias2--vCsCaGarantias
								WHERE      (Fecha = @Fecha)) 
							
							AS Garantia ON tCsCartera.CodPrestamo = Garantia.Codigo ON tCaClProvision.Estado = tCsCartera.Estado AND 
						  tCaClProvision.DiasMinimo <= tCsCartera.NroDiasAtraso AND tCaClProvision.DiasMaximo >= tCsCartera.NroDiasAtraso RIGHT OUTER JOIN
							  
							 -- (SELECT     CodPrestamo, CodUsuario, AVG(SaldoCapital + InteresVigente + InteresVencido + MoratorioVigente + MoratorioVencido) AS SaldoPromedio, 
								--					   SUM(InteresDevengado) AS DevengadoMes, AVG(InteresDevengado + MoratorioDevengado) AS DevengadoPromedio
								--FROM          tCsCarteraDet with(nolock)
								--WHERE      (dbo.fduFechaAPeriodo(Fecha) = @Periodo) AND (Fecha <= @Fecha)
								--GROUP BY CodPrestamo, CodUsuario) 
								#intdevengado AS InteresDevengado RIGHT OUTER JOIN
							  (SELECT     Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimaCapital, SUM(tCsPagoDet.MontoPagado) AS MontoUltimoCapital
								FROM          #tCsPagoDetUC AS Datos INNER JOIN
								-- ojo aqui
								            tCsPagoDet with(nolock) ON Datos.CodPrestamo = tCsPagoDet.CodPrestamo AND Datos.FechaUltimaCapital = tCsPagoDet.Fecha AND 
													   Datos.CodUsuario = tCsPagoDet.CodUsuario
								WHERE      (tCsPagoDet.CodConcepto IN ('CAPI')) AND (tCsPagoDet.Extornado = 0)
								GROUP BY Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimaCapital) AS UltimoCapital RIGHT OUTER JOIN
							  -- ojo aqui
							  -- (SELECT     CodPrestamo, CodUsuario, SUM(MontoPagado) AS PagoXMora
								--FROM          tCsPagoDet with(nolock)
								--WHERE      (CodConcepto = 'MORA') AND (dbo.fduFechaAPeriodo(Fecha) = @Periodo)
								--GROUP BY CodPrestamo, CodUsuario)
								#tCsPagoDetMo
								 AS Mora RIGHT OUTER JOIN
							  (SELECT     Fecha, CodPrestamo, CodUsuario, CodOficina, CodDestino, MontoDesembolso, SaldoCapital, SaldoInteres, SaldoMoratorio, OtrosCargos, Impuestos, 
													   CargoMora, UltimoMovimiento, CapitalAtrasado, CapitalVencido, SaldoEnMora, TipoCalificacion, InteresVigente, InteresVencido, InteresCtaOrden, 
													   InteresDevengado, MoratorioVigente, MoratorioVencido, MoratorioCtaOrden, MoratorioDevengado, SecuenciaCliente, SecuenciaGrupo, PReservaCapital, 
													   SReservaCapital, PReservaInteres, SReservaInteres, IDA, IReserva
								FROM          Kemy) AS tCsCarteraDet LEFT OUTER JOIN

								/*
							  (SELECT     tCsPagoDet.CodPrestamo, tCsPagoDet.CodUsuario, SUM(tCsPagoDet.MontoPagado) AS CtasOrdenRecuperado
								FROM         tCsPagoDet with(nolock) LEFT OUTER JOIN
													  tCsPadronPlanCuotas with(nolock) INNER JOIN
													  tCsPadronCarteraDet with(nolock) ON tCsPadronPlanCuotas.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
													  tCsPadronPlanCuotas.CodUsuario = tCsPadronCarteraDet.CodUsuario ON tCsPagoDet.CodConcepto = tCsPadronPlanCuotas.CodConcepto AND 
													  tCsPagoDet.SecCuota = tCsPadronPlanCuotas.SecCuota AND tCsPagoDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
													  tCsPagoDet.CodUsuario = tCsPadronCarteraDet.CodUsuario
								WHERE (tCsPagoDet.Fecha>= @FechaI) AND (tCsPagoDet.Fecha <= @Fecha)    --(dbo.fduFechaAPeriodo(tCsPagoDet.Fecha) = @Periodo) 
	              AND (tCsPagoDet.CodConcepto IN ('INTE', 'INPE')) AND (tCsPagoDet.Extornado = 0) AND (DATEDIFF(d, 
													  tCsPadronPlanCuotas.FechaVencimiento, tCsPagoDet.Fecha) >= 90)
								GROUP BY tCsPagoDet.CodPrestamo, tCsPagoDet.CodUsuario) 
								*/
								#COrecup AS OrdenRecuperada 

							ON tCsCarteraDet.CodPrestamo = OrdenRecuperada.CodPrestamo AND 
						  tCsCarteraDet.CodUsuario = OrdenRecuperada.CodUsuario ON Mora.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
						  Mora.CodUsuario = tCsCarteraDet.CodUsuario LEFT OUTER JOIN
							  (SELECT     Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimoInteres, SUM(tCsPagoDet.MontoPagado) AS MontoUltimoInteres
								FROM        
								  --(SELECT     CodPrestamo, CodUsuario, MAX(Fecha) AS FechaUltimoInteres
										--				FROM          tCsPagoDet with(nolock)
										--				WHERE      (Fecha <= @Fecha) AND (CodConcepto IN ('INTE', 'INPE')) AND (Extornado = 0)
										--				GROUP BY CodPrestamo, CodUsuario) 
														#tCsPagoDetUI	AS Datos INNER JOIN
													   tCsPagoDet with(nolock) ON Datos.CodPrestamo = tCsPagoDet.CodPrestamo AND Datos.FechaUltimoInteres = tCsPagoDet.Fecha AND 
													   Datos.CodUsuario = tCsPagoDet.CodUsuario
								WHERE      (tCsPagoDet.CodConcepto IN ('INTE', 'INPE')) AND (tCsPagoDet.Extornado = 0)
								GROUP BY Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimoInteres) AS UltimoInteres ON tCsCarteraDet.CodPrestamo = UltimoInteres.CodPrestamo AND 
						  tCsCarteraDet.CodUsuario = UltimoInteres.CodUsuario ON UltimoCapital.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
						  UltimoCapital.CodUsuario = tCsCarteraDet.CodUsuario ON InteresDevengado.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
						  InteresDevengado.CodUsuario = tCsCarteraDet.CodUsuario ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
						  tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN
						  tCaProdPerTipoCredito ON tCsCartera.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito ON tCsPadronClientes.CodUsuario = tCsCarteraDet.CodUsuario ON 
						  tClFondos.CodFondo = tCsCartera.CodFondo
  where tCsCarteraDet.codprestamo not in (
											select distinct codprestamo from tcspadroncarteradet with(nolock) 
											where codoficina in(230,231) or (codgrupo in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9','ALTA10'))
											--where codoficina in(230,231) or (codgrupo in('ALTA1','ALTA2','ALTA4'))
										 )--and codproducto=169
--where tCsCarteraDet.CodPrestamo='002-157-06-00-00060'
  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. mora'
  set @T1 = getdate()
	Print 'Finaliza Inserccion'

	drop table #tCsPagoDetUC
	drop table #tCsPagoDetMo
	drop table #tCsPagoDetUI
	drop table #intdevengado
	drop table #comision
--	drop table #vCsCaGarantias1
	drop table #vCsCaGarantias2
	drop table #COrecup

	IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Kemy]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin DROP TABLE [dbo].[Kemy] End        

	UPDATE    tCsUnisapCA
	SET              diasultimacancelacion = DATEDIFF([day], tCsPadronCarteraDet.CancelacionAnterior, tCsUnisapCA.Fecha)
	FROM         tCsUnisapCA INNER JOIN
                       tCsPadronCarteraDet ON tCsUnisapCA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND tCsUnisapCA.CodUsuario = tCsPadronCarteraDet.CodUsuario
	WHERE     (tCsUnisapCA.Fecha = @Fecha)

  set @T2 = getdate()
  print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' mseg. fin'
  set @T1 = getdate()
  
End
GO