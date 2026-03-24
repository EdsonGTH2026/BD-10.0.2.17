SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUPadronCallCenter]  @Tipo char(1), @CodOficina varchar(2) , @DiaIni int, @DiaFin int, @Estado varchar(10), @Nombre varchar(50), @CodAsesor varchar(25) , @Filtro char(1)  AS

/*DECLARE  
@Tipo char(1), 
@CodOficina varchar(2) , 
@DiaIni int, @DiaFin int, 
@Estado varchar(10), 
@Nombre varchar(50), 
@CodAsesor varchar(25) , 
@Filtro char(1)

SET @Tipo 		= '2'
SET @CodOficina = '6'
SET @DiaIni		= 0
SET @DiaFin		= 15
SET @Estado		= 'ACTIVA'
SET @Nombre		= ''
SET @CodAsesor	= ''
SET @Filtro = '0'*/

DECLARE @Fecha smalldatetime
DECLARE @FechaSig smalldatetime

SELECT @Fecha = FechaConsolidacion FROM vCsFechaConsolidacion
SELECT @FechaSig = DATEADD([day], 1, @Fecha)

DECLARE @Filtrox varchar(800)
SET @Filtrox = ''
if @Filtro = '0'
	begin
		SET @Filtrox = ' tCsPadronClientes.NombreCompleto '
	end
if @Filtro = '1'
	begin
		SET @Filtrox = ' tCsCarteraGrupos.NombreGrupo '
	end
if @Filtro = '2'
	begin
		SET @Filtrox = ' tCsCartera.CodPrestamo '
	end

DECLARE @csql varchar(8000)

SET @csql = 'SELECT CodUsuario, CodPrestamo, NombreCompleto, FechaVencimiento, Estado, NroDiasAtraso, SUM(DeudaTotal) AS DeudaTotal, NroSeg, '
SET @csql = @csql + 'NombreGrupo, VctoCredito, NroCuotas, NroCuotasPorPagar, DescDestino, Direccion, Telefono, Municipio, Color,SecuenciaCliente '
SET @csql = @csql + 'FROM (SELECT tCsCarteradet.CodUsuario, tCsCartera.CodPrestamo, tCsPadronClientes.NombreCompleto, DATEADD([day], - tCsCartera.NroDiasAtraso, '
SET @csql = @csql + 'tCsCartera.Fecha) AS FechaVencimiento, tCsCartera.Estado, tCsCartera.NroDiasAtraso, '

if (@Tipo=0 or @Tipo=1 )
	begin
		SET @csql = @csql + 'tCsCarteraDet.SaldoCapital + ISNULL(tCsCarteraDet.InteresVigente, 0) + ISNULL(tCsCarteraDet.InteresVencido, 0) + '
		SET @csql = @csql + 'ISNULL(tCsCarteraDet.MoratorioVigente, 0)+ ISNULL(tCsCarteraDet.MoratorioVencido, 0) + ISNULL(tCsCarteraDet.CargoMora, 0) '
		SET @csql = @csql + '+ ISNULL(tCsCarteraDet.OtrosCargos, 0) + ISNULL(tCsCarteraDet.Impuestos, 0) '
	end
if (@Tipo = 2) 
	begin
		SET @csql = @csql + 'tCsPlanCuotas.MontoDevengado - ISNULL(tCsPlanCuotas.MontoPagado, 0) - ISNULL(tCsPlanCuotas.MontoCondonado, 0) '
	end

SET @csql = @csql + 'AS DeudaTotal, ISNULL(Seguimientos.Contador, 0) AS NroSeg, tCsCarteraGrupos.NombreGrupo, '
SET @csql = @csql + 'tCsCartera.FechaVencimiento AS VctoCredito, tCsCartera.NroCuotas, tCsCartera.NroCuotasPorPagar, tCaClDestino.DescDestino, '
SET @csql = @csql + 'ISNULL(tCsPadronClientes.DireccionDirFamPri, tCsPadronClientes.DireccionDirNegPri) AS Direccion, ISNULL(tCsPadronClientes.TelefonoDirFamPri, '
SET @csql = @csql + 'tCsPadronClientes.TelefonoDirNegPri) AS Telefono, tCPClMunicipio.Municipio, CASE WHEN tCsCartera.NroDiasAtraso > 1 AND '
SET @csql = @csql + 'tCsCartera.NroDiasAtraso <= 3 THEN ''c0ffc0'' WHEN tCsCartera.NroDiasAtraso > 3 AND tCsCartera.NroDiasAtraso <= 10 THEN ''ffff9b'' WHEN '
SET @csql = @csql + 'tCsCartera.NroDiasAtraso > 10 THEN ''ffc0c0'' ELSE ''dedfde'' END Color,tCsPadronCarteraDet.SecuenciaCliente '
SET @csql = @csql + 'FROM tClUbigeo with(nolock) LEFT OUTER JOIN tCPClMunicipio ON '
SET @csql = @csql + 'tClUbigeo.CodEstado = tCPClMunicipio.CodEstado AND tClUbigeo.CodMunicipio = tCPClMunicipio.CodMunicipio RIGHT OUTER JOIN '
SET @csql = @csql + 'tCsPadronClientes with(nolock) ON tClUbigeo.CodUbiGeo = tCsPadronClientes.CodUbiGeoDirFamPri RIGHT OUTER JOIN tCsCartera with(nolock) INNER JOIN '
SET @csql = @csql + 'tCsCarteraDet with(nolock) ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN '
SET @csql = @csql + 'tCaClDestino ON tCsCartera.CodDestino = tCaClDestino.CodDestino LEFT OUTER JOIN tCsCarteraGrupos ON tCsCartera.CodOficina = '
SET @csql = @csql + 'tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo ON tCsPadronClientes.CodUsuario = tCsCarteradet.CodUsuario LEFT OUTER JOIN '
SET @csql = @csql + '(SELECT CodUsuario, COUNT(CodUsuario) AS Contador FROM tCsCaSegCartera WHERE (TipoSeguimiento = ''2'') AND (Fecha >= '''+dbo.fduFechaAAAAMMDD(DATEADD([day], - 7, @Fecha))+''') '
SET @csql = @csql + 'GROUP BY CodUsuario) Seguimientos ON tCsCarteraDet.CodUsuario = Seguimientos.CodUsuario COLLATE Modern_Spanish_CI_AI '
SET @csql = @csql + 'INNER JOIN tCsPadronCarteraDet with(nolock) ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND '
SET @csql = @csql + 'tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario AND tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte '

if (@Tipo = 2) 
	begin
		SET @csql = @csql + 'INNER JOIN tCsPlanCuotas with(nolock) ON tCsCarteraDet.CodOficina = tCsPlanCuotas.CodOficina AND tCsCarteraDet.Fecha = tCsPlanCuotas.Fecha '
		SET @csql = @csql + 'AND tCsCarteraDet.CodPrestamo = tCsPlanCuotas.CodPrestamo AND tCsCarteraDet.CodUsuario = tCsPlanCuotas.CodUsuario '
	end
-------------------------------
--Where
if (@Tipo=0) 
	begin
		SET @csql = @csql + 'WHERE (tCsCartera.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecha)+''') AND (tCsCartera.CodOficina = '''+@CodOficina+''') AND (tCsCartera.Cartera = '''+@Estado+''') AND '
		SET @csql = @csql + '( '+@Filtrox+' LIKE ''%' + @Nombre + '%'' ) AND (tCsCartera.CodAsesor like ''%' + @CodAsesor + '%'')) A '
	end
if (@Tipo=1) 
	begin
		SET @csql = @csql + 'WHERE (tCsCartera.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecha)+''') AND (tCsCartera.Cartera = '''+@Estado+''') AND (tCsCartera.CodOficina = '''+@CodOficina+''') '
		SET @csql = @csql + 'AND (tCsCartera.NroDiasAtraso > '+cast(@DiaIni as varchar(4))+') AND (tCsCartera.NroDiasAtraso < '+cast(@DiaFin as varchar(4))+') AND  '
		SET @csql = @csql + '( '+@Filtrox+' LIKE ''%' + @Nombre + '%'')  AND (tCsCartera.CodAsesor LIKE ''%' + @CodAsesor + '%'')) A '		
	end
if (@Tipo=2) 
	begin
		SET @csql = @csql + 'WHERE (tCsCarteraDet.CodOficina = '''+@CodOficina+''') AND (tCsCarteraDet.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecha)+''') AND (tCsCartera.Cartera = '''+@Estado+''') AND '
		SET @csql = @csql + '(tCsPlanCuotas.EstadoCuota <> ''cancelado'') AND (tCsPlanCuotas.CodConcepto IN (''CAPI'', ''INTE'', ''INPE'')) AND '
		SET @csql = @csql + '(tCsPlanCuotas.FechaVencimiento <= '''+ dbo.fduFechaAAAAMMDD(DATEADD([day],@DiaFin, @FechaSig)) +''') AND (tCsPlanCuotas.FechaVencimiento >= '''+dbo.fduFechaAAAAMMDD(@FechaSig)+''') AND '
		SET @csql = @csql + '( '+@Filtrox+' LIKE ''%' + @Nombre + '%''   ) AND (tCsCartera.CodAsesor LIKE ''%' + @CodAsesor + '%'' )) A '
	end

--Group by
SET @csql = @csql + 'GROUP BY CodUsuario, CodPrestamo, NombreCompleto, FechaVencimiento, Estado, NroDiasAtraso, NroSeg, NombreGrupo, '
SET @csql = @csql + 'VctoCredito, NroCuotas, NroCuotasPorPagar, DescDestino, Direccion, Telefono, Municipio, Color,SecuenciaCliente '
SET @csql = @csql + 'ORDER BY CodUsuario, CodPrestamo '

--print @csql
exec (@csql)
GO