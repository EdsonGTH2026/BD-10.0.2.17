SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCHRelacionEmpleados] @Codoficina varchar(2000), @fecha smalldatetime 
AS

--declare @fecha smalldatetime
--set @fecha='20210802'

declare @csql varchar(5000)

set @csql = ' SELECT NomOficina, CodEmpleado, CURP, RFC, CE, NombreSistema, NombreCH, Nacimiento, Estado, Puesto, Domicilio, Ubicacion, Tiempo '
set @csql = @csql + ' EstadoCivil, TipoPro, Escolaridad, DataNegocio, Correo '
--set @csql = @csql + ' case EnRango when ''1'' then Ingreso when ''2'' then FechaAlta else null end Ingreso,'
--set @csql = @csql + ' case EnRango when ''1'' then Salida when ''2'' then FechaBaja else null end Salida, '
set @csql = @csql + ' ,ingreso '
set @csql = @csql + ' ,salida '
set @csql = @csql + ' ,Nivel,codusuario,codorigen '
set @csql = @csql + ' FROM ( SELECT tClOficinas.NomOficina, tCsEmpleados.CodEmpleado, tCsEmpleados.CURP, tCsEmpleados.RFC, tCsEmpleados.CE, tCsPadronClientes.NombreCompleto AS NombreSistema, '
set @csql = @csql + ' tCsEmpleados.Paterno + '' '' + tCsEmpleados.Materno + '', '' + tCsEmpleados.Nombres AS NombreCH, tCsEmpleados.Nacimiento, CASE tCsEmpleados.Estado WHEN ''1''  '
set @csql = @csql + ' THEN ''ACTIVO'' ELSE ''BAJA'' END AS Estado, tCsClPuestos.Descripcion AS Puesto, tCsEmpleados.Domicilio, tCsEmpleados.Ubicacion, tCsEmpleados.Tiempo, '
set @csql = @csql + ' tUsClEstadoCivil.EstadoCivil, tUsClTipoPropiedad.TipoPro, tCsEmpleados.Escolaridad, tCsEmpleados.DataNegocio, tCsEmpleados.Correo, tCsEmpleados.Ingreso, '
set @csql = @csql + ' tCsEmpleados.Salida, tCsClPuestos.Nivel,tCsEmpleadosPeriodos.FechaAlta, tCsEmpleadosPeriodos.FechaBaja '
--set @csql = @csql + ' ,case when (tCsEmpleados.INGRESO < '''+dbo.fduFechaAAAAMMDD(@fecha)+''') and (tCsEmpleados.Salida > '''+dbo.fduFechaAAAAMMDD(@fecha)+''' or tCsEmpleados.Salida is null )  then ''1'' '
--set @csql = @csql + ' when (tCsEmpleadosPeriodos.FechaAlta < '''+dbo.fduFechaAAAAMMDD(@fecha)+''') and (tCsEmpleadosPeriodos.FechaBaja > '''+dbo.fduFechaAAAAMMDD(@fecha)+''')  then ''2'' else ''0'' end EnRango '
set @csql = @csql + ' ,''0'' EnRango'
set @csql = @csql + ' ,tCsEmpleados.codusuario,tCsPadronClientes.codorigen '
set @csql = @csql + ' FROM tCsEmpleados with(nolock) LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON tCsEmpleados.TipoPropiedad = tUsClTipoPropiedad.CodTipoPro '
set @csql = @csql + ' LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON tCsEmpleados.EstadoCivil = tUsClEstadoCivil.CodEstadoCivil LEFT OUTER JOIN tCsClPuestos with(nolock) ON '
set @csql = @csql + ' tCsEmpleados.CodPuesto = tCsClPuestos.Codigo LEFT OUTER JOIN tClOficinas with(nolock) ON tCsEmpleados.CodOficinaNom = tClOficinas.CodOficina '
set @csql = @csql + ' LEFT OUTER JOIN tCsPadronClientes with(nolock) ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN '
set @csql = @csql + ' tCsEmpleadosPeriodos with(nolock) on tCsEmpleadosPeriodos.CURP = tCsEmpleados.CURP AND tCsEmpleadosPeriodos.RFC = tCsEmpleados.RFC '
--set @csql = @csql + ' WHERE (tCsEmpleados.CodOficinaNom IN ())   '
set @csql = @csql + ' where tCsEmpleados.estado=''1'' ) A  '
--set @csql = @csql + ' where enrango<>''0'''
--print @csql
exec ( @csql )

GO