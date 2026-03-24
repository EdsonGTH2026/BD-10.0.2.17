SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsRptCaDistribucionDiasMoraF1]
@Fecha 		SmallDateTime,
@Ubicacion	Varchar(100),
@ClaseCartera	Varchar(100),
@Distribucion	Varchar(100)
As
--Set @Fecha 		= '20080831'
--Set @Ubicacion		= 'ZZZ'
--Set @ClaseCartera 	= 'ACTIVA'
--Set @Distribucion	= 'WHERE (Reporte = ''CA02'')' 
	
Declare @TipoSaldo	Varchar(1000)
Set 	@TipoSaldo 		= '01' 
Declare @Select 	Varchar(4000)
Declare @GroupBy 	Varchar(4000)
Declare @MesAnterior	SmallDateTime
Declare @Nivel1	Varchar(100)
Declare @Depende	Varchar(2)
Declare @Formula	Varchar(1000)
Declare @Cadena	Varchar(4000)
Declare @DI		Int
Declare @DF		Int

Set @MesAnterior = DateAdd(Day, -1, dbo.fduFechaATexto(@Fecha, 'AAAAMM') + '01')

CREATE TABLE #DatosBasicosF1 (
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha] [smalldatetime] NULL ,
	[Nivel1] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel2] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Reporte] [varchar] (5) COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] [varchar] (10) COLLATE Modern_Spanish_CI_AI NULL ,
	[DI] [Int] NULL,
	[DF] [Int] NULL,
	[ZCodUsuario] [decimal](38, 4) NULL ,
	[ZCodAsesor] [decimal](38, 4) NULL ,
	[ZTotal] [decimal](38, 4) NULL) 

SELECT     @Nivel1 = Nombre, @Depende = Depende, @Formula = Formula
FROM         tCsPrNivelDiasAtraso
WHERE     (NivelDiaAtraso = @Distribucion)

Set 	@Cadena = 'Insert Into #DatosBasicosF1 (DI, DF) SELECT MIN(pInicio) AS Minimo, MAX(PFin) AS Maximo FROM tCsPrReportesAnexos ' +  @Formula
Exec	(@Cadena)

Select @DI = DI, @DF = DF
From  #DatosBasicosF1

Truncate Table #DatosBasicosF1

Set @Select 		= 'SELECT Detalle.Cartera, Detalle.Fecha, '''+ @Nivel1 +''' AS Nivel1, ''Datos al Mes Anterior'' AS Nivel2, tCsPrReportesAnexos.Reporte, ''Z'' AS Identificador, '+ Cast(@DI as Varchar(10)) +' As DI, ' + Cast(@DF as Varchar(10)) +' AS DF '
Set @GroupBy		= 'GROUP BY Detalle.Cartera, Detalle.Fecha, tCsPrReportesAnexos.Reporte'
INSERT INTO #DatosBasicosF1
Exec pCsRptCaDistribucionDiasMora 	@MesAnterior, 
					@Ubicacion, 
					@ClaseCartera,
					@Depende,
					@TipoSaldo,
					@Select,
					@GroupBy
					

Set @Select 	= 'SELECT Detalle.Cartera, Detalle.Fecha, '''+ @Nivel1 +''' AS Nivel1, tCsPrReportesAnexos.Descripcion AS Nivel2, tCsPrReportesAnexos.Reporte, tCsPrReportesAnexos.Identificador AS Identificador, tCsPrReportesAnexos.PInicio As DI, tCsPrReportesAnexos.PFin As DF '
Set @GroupBy	= 'GROUP BY Detalle.Cartera, Detalle.Fecha, tCsPrReportesAnexos.Reporte, tCsPrReportesAnexos.Identificador, tCsPrReportesAnexos.Descripcion, tCsPrReportesAnexos.PInicio, tCsPrReportesAnexos.PFin '
INSERT INTO #DatosBasicosF1
Exec pCsRptCaDistribucionDiasMora 	@Fecha, 
					@Ubicacion, 
					@ClaseCartera,
					@Distribucion,
					@TipoSaldo,
					@Select,
					@GroupBy

Set @Select 		= 'SELECT Detalle.Cartera, Detalle.Fecha, '''+ @Nivel1 +''' AS Nivel1, ''Total'' AS Nivel2, tCsPrReportesAnexos.Reporte, ''Z'' AS Identificador, '+ Cast(@DI as Varchar(10)) +' As DI, '+ Cast(@DF as Varchar(10)) +' As DF '
Set @GroupBy		= 'GROUP BY Detalle.Cartera, Detalle.Fecha, tCsPrReportesAnexos.Reporte '
INSERT INTO #DatosBasicosF1
Exec pCsRptCaDistribucionDiasMora 	@Fecha, 
					@Ubicacion, 
					@ClaseCartera,
					@Depende,
					@TipoSaldo,
					@Select,
					@GroupBy

Declare @CUbicacion	Varchar(500)
Declare @Tabla		Varchar(100)
Declare @OtroDato	Varchar(100)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 	Out, 	@Tabla 	Out,  @OtroDato Out	

Select Ubicacion = @Ubicacion, TipoSaldo = @TipoSaldo, #DatosBasicosF1.* from #DatosBasicosF1
DROP TABLE #DatosBasicosF1
GO