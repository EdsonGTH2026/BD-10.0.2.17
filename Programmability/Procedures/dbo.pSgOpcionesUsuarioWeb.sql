SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgOpcionesUsuarioWeb] @Usuario varchar(20), @Operativa varchar(20),@CodSistema varchar(5) AS
--declare @Usuario varchar(20)
--declare @Operativa varchar(20)

--set @Usuario = 'curbiza'
--set @Operativa = '1'
declare @csql varchar(2000)

set @csql = 'SELECT sgo.Opcion, sgo.Nombre, sgo.OpcionPare, sga.Acceder,  sga.Anadir, '
set @csql = @csql + 'sga.Editar, sga.Grabar, sga.Cancelar,  sga.Eliminar, sga.Imprimir, '
set @csql = @csql + 'sga.cerrar, sgo.TipoObj,  CASE sgo.TipoObj '
set @csql = @csql + 'WHEN ''2'' THEN sgo.ObjetoWeb + ''?ID='' + sgo.Objeto + ''&PF='' + CAST(sga.Acceder AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Anadir AS CHAR(1)) + CAST(sga.Editar AS CHAR(1)) + CAST(sga.Grabar AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Cancelar AS CHAR(1)) + CAST(sga.Eliminar AS CHAR(1)) + CAST(sga.Imprimir AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Cerrar AS CHAR(1)) + ''&op='' + sgo.Opcion + ''&to='' + cast(sgo.TipoObj as varchar(2)) '
set @csql = @csql + 'WHEN ''3'' THEN sgo.ObjetoWeb + ''?ID='' + sgo.Objeto + ''&PF='' + CAST(sga.Acceder AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Anadir AS CHAR(1)) + CAST(sga.Editar AS CHAR(1)) + CAST(sga.Grabar AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Cancelar AS CHAR(1)) + CAST(sga.Eliminar AS CHAR(1)) + CAST(sga.Imprimir AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Cerrar AS CHAR(1)) + ''&op='' + sgo.Opcion + ''&to='' + cast(sgo.TipoObj as varchar(2)) '
set @csql = @csql + 'ELSE sgo.ObjetoWeb + ''?PF='' + CAST(sga.Acceder AS CHAR(1))  '
set @csql = @csql + '+ CAST(sga.Anadir AS CHAR(1)) + CAST(sga.Editar AS CHAR(1)) + CAST(sga.Grabar AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Cancelar AS CHAR(1)) + CAST(sga.Eliminar AS CHAR(1)) + CAST(sga.Imprimir AS CHAR(1)) '
set @csql = @csql + '+ CAST(sga.Cerrar AS CHAR(1))  + ''&op='' + sgo.Opcion  END  ObjWeb,  '
set @csql = @csql + 'EsTerminal, LEN(REPLACE(sgo.Opcion, ''0'', '''')) AS pos '
set @csql = @csql + 'FROM tSgOptions sgo INNER JOIN tSgAcciones sga ON sgo.CodSistema = sga.CodSistema '
set @csql = @csql + 'AND sgo.Opcion = sga.Opcion INNER JOIN tSgUsSistema ON sga.CodSistema '
set @csql = @csql + '= tSgUsSistema.CodSistema AND sga.CodGrupo = tSgUsSistema.CodGrupo '
set @csql = @csql + 'WHERE (sgo.Activo = 1) AND (sgo.CodSistema = '''+@CodSistema+''') '
set @csql = @csql + 'AND  (tSgUsSistema.Usuario = '''+@Usuario+''') '
if @Operativa='1' set @csql = @csql + ' and sgo.AyudaCtx=''0'' '
--print @csql
exec (@csql)
GO