SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaPadronCartera] @Fecha varchar(10), @Codoficinas varchar(20), @CodProductos varchar(50), 
@CodAsesor varchar(400), @TipoColocacion varchar(50), @Tecnologia varchar(50), @DiaIni int,@DiaFin int, @FecIni varchar(10), @FecFin varchar(10)
AS

--SET @Fecha='20080422'

DECLARE @CSQL varchar(8000)

CREATE TABLE #tauxPadronCartera (
	Fecha smalldatetime,
	NomOficina varchar(30) ,
	CodPrestamo varchar(25)  ,
	NombreCompleto varchar(300)  ,
	DI varchar(20)  ,
	FechaNacimiento smalldatetime  ,
	Pais varchar(40) ,
	Actividad varchar(80)  ,
	Sexo varchar(9) ,
	EstadoCivil varchar(15) ,
	Lugar varchar(150)  ,
	EstadoMexico varchar(150)  ,
	DireccionDirFamPri varchar(150) ,
	TelefonoDirFamPri varchar(20)  ,
	EsEmpleado varchar(2)  ,
	Producto varchar(32) ,
	NombreTec varchar(50) ,
	Asesor varchar(300)  ,
	BIS int  ,
	Estado varchar(50) ,
	ProximoVencimiento smalldatetime  ,
	NumReprog int  ,
	FechaReprog smalldatetime  ,
	PrestamoReprog varchar(25)  ,
	FechaDesembolso smalldatetime  ,
	MontoDesembolso decimal(19, 4)  ,
	SaldoCapital decimal(19, 4)  ,
	NroDiasAtraso smallint  ,
	InteresVigente decimal(19, 4)  ,
	InteresVencido decimal(19, 4)  ,
	InteresCtaOrden decimal(19, 4)  ,
	InteresDevengado decimal(19, 4)  ,
	MoratorioVigente decimal(19, 4)  ,
	MoratorioVencido decimal(19, 4)  ,
	MoratorioCtaOrden decimal(19, 4)  ,
	MoratorioDevengado decimal(19, 4)  )


set @CSQL = 'INSERT INTO #tauxPadronCartera SELECT tCsCartera.Fecha, tClOficinas.NomOficina, tCsCartera.CodPrestamo, tCsPadronClientes.NombreCompleto, tCsPadronClientes.DI, ' +
	'tCsPadronClientes.FechaNacimiento, tClPaises.Pais, tClActividad.Nombre AS Actividad, ' +
	'CASE tCsPadronClientes.Sexo WHEN ''1'' THEN ''MASCULINO'' ELSE ''FEMENINO'' END AS Sexo, tUsClEstadoCivil.EstadoCivil, tCPLugar.Lugar, ' +
	'tCPClEstado.Estado AS EstadoMexico, tCsPadronClientes.DireccionDirFamPri, tCsPadronClientes.TelefonoDirFamPri, ' +
	'CASE tCsPadronClientes.UsEsEmpleado WHEN ''1'' THEN ''SI'' ELSE ''NO'' END AS EsEmpleado, CAST(tCaProducto.CodProducto AS varchar(5)) ' +
	'+ ''  '' + tCaProducto.NombreProdCorto AS Producto, tCaClTecnologia.NombreTec, Asesores.Asesor, tCsCartera.BIS, tCsCartera.Estado, ' +
	'tCsCartera.ProximoVencimiento, tCsCartera.NumReprog, tCsCartera.FechaReprog, tCsCartera.PrestamoReprog, tCsCartera.FechaDesembolso, ' +
	'tCsCartera.MontoDesembolso, tCsCarteraDet.SaldoCapital, tCsCartera.NroDiasAtraso, tCsCarteraDet.InteresVigente, tCsCarteraDet.InteresVencido, ' +
	'tCsCarteraDet.InteresCtaOrden, tCsCarteraDet.InteresDevengado, tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, ' +
	'tCsCarteraDet.MoratorioCtaOrden, tCsCarteraDet.MoratorioDevengado ' +
	'FROM  tCaClTecnologia INNER JOIN tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia RIGHT OUTER JOIN ' +
	'tCPLugar INNER JOIN tClUbigeo ON tCPLugar.IdLugar = tClUbigeo.IdLugar AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND ' +
	'tCPLugar.CodEstado = tClUbigeo.CodEstado INNER JOIN tCPClEstado ON tCPLugar.CodEstado = tCPClEstado.CodEstado INNER JOIN ' +
	'tCsCartera INNER JOIN tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = ' +
	'tCsCarteraDet.CodPrestamo INNER JOIN tCsPadronClientes ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN ' +
	'tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina INNER JOIN tClActividad ON ' +
	'tCsPadronClientes.LabCodActividad = tClActividad.CodActividad ON tClUbigeo.CodUbiGeo = tCsPadronClientes.CodUbiGeoDirFamPri ON ' +
	'tCaProducto.CodProducto = tCsCartera.CodProducto LEFT OUTER JOIN tUsClEstadoCivil ON tCsPadronClientes.CodEstadoCivil = ' +
	'tUsClEstadoCivil.CodEstadoCivil LEFT OUTER JOIN tClPaises ON tCsPadronClientes.CodPais = tClPaises.CodPais RIGHT OUTER JOIN ' +
	' (SELECT CodUsuario, NombreCompleto Asesor FROM tCsPadronClientes) Asesores ON tCsCartera.CodAsesor = Asesores.CodUsuario ' +
	'WHERE (tCsCartera.Fecha = '''+ @Fecha + ''') '

if  (@CodOficinas <> '')
begin
	SET @CSQL=@CSQL + ' AND (tCsCartera.CodOficina in('+@CodOficinas+')) '
end
if  (@CodProductos <> '')
begin
	SET @CSQL=@CSQL + ' AND (tCsCartera.CodProducto in('+@CodProductos+')) '
end
if (@CodAsesor <> '')
begin
	SET @CSQL=@CSQL + ' AND (tCsCartera.CodAsesor in('+@CodAsesor+')) '
end
if (@Tecnologia <>'')
begin
	SET @CSQL=@CSQL + ' AND (tCaProducto.Tecnologia in('+@Tecnologia+')) '
end
if @DiaFin<>0
begin
	SET @CSQL=@CSQL + ' AND (tCsCartera.NroDiasAtraso >='+@DiaIni+' and tCsCartera.NroDiasAtraso <='+@DiaFin+') '
end
if (@TipoColocacion<>'')
begin
	SET @CSQL=@CSQL + ' AND (tCsCartera.cartera ='+@TipoColocacion+') '
end
if  (@FecFin <> '')
begin
	SET @CSQL=@CSQL + ' AND (tCsCartera.FechaDesembolso >='''+@FecIni+''' and tCsCartera.FechaDesembolso <='''+@FecFin+''') '
end

exec (@CSQL)

Select * FROM #tauxPadronCartera
GO