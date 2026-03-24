SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIURptRegistroVisitas] @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(250)
as
--, @Seleccion char(1) AS @Tipo int, 

--declare @FecIni smalldatetime
--declare @FecFin smalldatetime
--declare @Tipo int
--declare @CodOficina varchar(250)
--declare @Seleccion char(1)

--set @FecIni ='20151209'
--set @FecFin ='20151209'
--set @Tipo =1
--set @CodOficina = '2,10,75,38'
--set @Seleccion =1

DECLARE @csql varchar(8000)
SET @csql = ' SELECT s.Fecha, convert(varchar, s.hora, 108) hora, s.NombreCompleto AS Cliente, s.Codprestamo, s.FechaSeg,  '
SET @csql = @csql + ' CASE s.Relacion WHEN ''1'' THEN ''Titular'' WHEN ''2'' THEN ''Conyuge'' WHEN ''3'' THEN ''Padre/Madre'' WHEN ''4'' THEN ''Hijo(a)'' WHEN ''5'' THEN '
SET @csql = @csql + ' ''Hermano(a)'' WHEN ''6'' THEN ''Tio(a)'' WHEN ''7'' THEN ''Vecino(a)'' WHEN ''8'' THEN ''Otros(a)'' ELSE ''No definido'' END AS Relacion,  '
SET @csql = @csql + ' s.Nombrecompleto, s.Resultado, s.Observacion, s.FechaCompro, '
SET @csql = @csql + ' s.MontoCompro, o.NomOficina, s.CodOficina, cl.nombrecompleto NomAsesor '
SET @csql = @csql + ' ,d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido saldocartera'
SET @csql = @csql + ' ,c.nrodiasatraso '

SET @csql = @csql + 'FROM tCsCaSegCartera s inner join tcloficinas o on o.codoficina=s.codoficina '
SET @csql = @csql + 'inner join tcspadronclientes cl on cl.codusuario=s.codusuarioreg '
SET @csql = @csql + 'inner join tcscarteradet d on d.fecha=dateadd(day,-1,s.fecha) and d.codprestamo=s.codprestamo and d.codusuario=s.codusuario '
SET @csql = @csql + 'inner join tcscartera c on c.fecha=d.fecha and c.codprestamo=d.codprestamo '

--SET @csql = @csql + ' FROM tCsCarteraDet INNER JOIN tCsPadronCarteraDet ON tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte AND tCsCarteraDet.CodPrestamo =  '
--SET @csql = @csql + ' tCsPadronCarteraDet.CodPrestamo AND tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario INNER JOIN tCsCartera ON  '
--SET @csql = @csql + ' tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN '
--SET @csql = @csql + ' (SELECT codusuario, nombrecompleto NomAsesor FROM tcspadronclientes) Asesores ON tCsCartera.CodAsesor = Asesores.codusuario '
--SET @csql = @csql + ' RIGHT OUTER JOIN tCsCaSegCartera ON tCsPadronCarteraDet.CodPrestamo = tCsCaSegCartera.Codprestamo AND '
--SET @csql = @csql + ' tCsPadronCarteraDet.CodUsuario = tCsCaSegCartera.CodUsuario LEFT OUTER JOIN tCsPadronClientes ON tCsCaSegCartera.CodUsuario = '
--SET @csql = @csql + ' tCsPadronClientes.CodUsuario LEFT OUTER JOIN tClOficinas ON tCsCaSegCartera.CodOficina = tClOficinas.CodOficina '
SET @csql = @csql + ' WHERE  (s.CodOficina in(' + @CodOficina + ')) '
SET @csql = @csql + ' and (s.Fecha >= '''+dbo.fduFechaATexto(@FecIni,'aaaaMMdd')+''') AND (s.Fecha <= '''+dbo.fduFechaATexto(@FecFin,'aaaaMMdd')+''')  '
SET @csql = @csql + ' and s.resultado<>'''' and s.codprestamo<>'''' and s.codusuarioreg<>''UMC1809791'' '
SET @csql = @csql + '  and s.formapago in (9,10) and fechaseg is null '--and s.tipocontacto=3

print @csql

exec (@csql)
GO