SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIURegistroSeguimiento] @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(5), @Motivo int, @Filtro varchar(100), @TipoFiltro char(1), @CodAsesor varchar(20) AS

/*
DECLARE @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(5), @Motivo int, @Filtro varchar(100), @TipoFiltro char(1), @CodAsesor varchar(20)

SET @FecIni 	= '20090601'
SET @FecFin 	= '20090901'
SET @CodOficina = 6
SET @Motivo 	= '3'
SET @TipoFiltro = '0'
SET @Filtro 	= ''
SET @CodAsesor 	= '0'
*/
-- @Motivo
--	0: visitas registradas
--	1: compromisos
--	2: seguimientos
--	3: superviciones
--	4: consultas

DECLARE @csql varchar(8000)
SET @csql = 'SELECT tCsCaSegCartera.CodUsuario,'

if (@Motivo not in ('3','4')) SET @csql = @csql + ' tCsCaSegCartera.Fecha, '
else SET @csql = @csql + ' tCsCaSegCarterasup.Fechasup, '

SET @csql = @csql + 'tCsCaSegCartera.Hora, tCsCaSegCartera.Codprestamo, '
SET @csql = @csql + 'tCsPadronClientes.NombreCompleto,tCsCarteraGrupos.NombreGrupo, '

if (@Motivo not in ('3','4')) SET @csql = @csql + 'CASE motivo WHEN ''1'' THEN ''Visita'' WHEN ''2'' THEN ''Compromiso'' WHEN ''3'' THEN ''Verificación'' ELSE ''No definido'' END AS Motivo, '
if (@Motivo='3') SET @csql = @csql + '''Supervision'' AS Motivo, '
if (@Motivo='4') SET @csql = @csql + '''Consulta'' AS Motivo, '

if (@Motivo not in ('3','4')) SET @csql = @csql + 'substring(tCsCaSegCartera.resultado,1,50) + ''...'' Resultado  '
if (@Motivo='3') SET @csql = @csql + 'substring(tCsCaSegCarteraSup.ObsSupervision,1,50) + ''...'' Resultado  '
if (@Motivo='4') SET @csql = @csql + 'substring(tCsCaSegCarterasup.Consulta,1,50) + ''...'' Resultado  '

SET @csql = @csql + 'FROM tCsCarteraGrupos with(nolock) RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) ON tCsCarteraGrupos.CodOficina = '
SET @csql = @csql + 'tCsPadronCarteraDet.CodOficina AND tCsCarteraGrupos.CodGrupo = tCsPadronCarteraDet.CodGrupo '
SET @csql = @csql + 'RIGHT OUTER JOIN tCsCaSegCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCaSegCartera.Codprestamo '
SET @csql = @csql + 'AND tCsPadronCarteraDet.CodUsuario = tCsCaSegCartera.CodUsuario LEFT OUTER JOIN '
SET @csql = @csql + 'tCsPadronClientes with(nolock) ON tCsCaSegCartera.CodUsuario = tCsPadronClientes.CodUsuario '

if (@Motivo in ('3','4')) 
	begin
		SET @csql = @csql + 'INNER JOIN tCsCaSegCarteraSup with(nolock) ON tCsCaSegCarteraSup.CodUsuario = tCsCaSegCartera.CodUsuario AND '
		SET @csql = @csql + 'tCsCaSegCarteraSup.TipoSeguimiento = tCsCaSegCartera.TipoSeguimiento AND '
		SET @csql = @csql + 'tCsCaSegCarteraSup.Fecha = tCsCaSegCartera.Fecha AND tCsCaSegCarteraSup.Hora = tCsCaSegCartera.Hora '
	end

SET @csql = @csql + 'WHERE (tCsCaSegCartera.TipoSeguimiento = 1) AND (tCsCaSegCartera.CodOficina = '''+ @CodOficina +''') '

if (@TipoFiltro='0') SET @csql = @csql + ' AND tCsPadronClientes.NombreCompleto like ''%'+@Filtro+'%'' '
if (@TipoFiltro='1') SET @csql = @csql + ' AND tCsCarteraGrupos.NombreGrupo like ''%'+@Filtro+'%'' '
if (@TipoFiltro='2') SET @csql = @csql + ' AND tCsCaSegCartera.Codprestamo like ''%'+@Filtro+'%'' '

if (@CodAsesor<>'0') SET @csql = @csql + ' AND tCsCaSegCartera.CodUsuarioReg ='''+@CodAsesor+''''

if (@Motivo='0') SET @csql = @csql + ' AND tCsCaSegCartera.Fecha>='''+dbo.fduFechaAAAAMMDD(@FecIni)+''' AND tCsCaSegCartera.Fecha<='''+dbo.fduFechaAAAAMMDD(@FecFin)+''' '
if (@Motivo='1') SET @csql = @csql + ' AND tCsCaSegCartera.FechaCompro>='''+dbo.fduFechaAAAAMMDD(@FecIni)+''' AND tCsCaSegCartera.FechaCompro<='''+dbo.fduFechaAAAAMMDD(@FecFin)+''' '
if (@Motivo='2') SET @csql = @csql + ' AND tCsCaSegCartera.FechaSeg>='''+dbo.fduFechaAAAAMMDD(@FecIni)+''' AND tCsCaSegCartera.FechaSeg<='''+dbo.fduFechaAAAAMMDD(@FecFin)+''' '

if (@Motivo='3') SET @csql = @csql + ' AND tCsCaSegCarterasup.Fechasup>='''+dbo.fduFechaAAAAMMDD(@FecIni)+''' AND tCsCaSegCarterasup.Fechasup<='''+dbo.fduFechaAAAAMMDD(@FecFin)+''' '
if (@Motivo='4') SET @csql = @csql + ' AND tCsCaSegCarterasup.Fechasup>='''+dbo.fduFechaAAAAMMDD(@FecIni)+''' AND tCsCaSegCarterasup.Fechasup<='''+dbo.fduFechaAAAAMMDD(@FecFin)+''' AND (NOT (tCsCaSegCarteraSup.Consulta IS NULL)) '

--print @csql
exec (@csql)
GO