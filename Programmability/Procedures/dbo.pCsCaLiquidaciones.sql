SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaLiquidaciones] @fecha smalldatetime, @codoficina varchar(4)
as
--declare @fecha smalldatetime
--set @fecha = '20210210'
 
declare @fecini smalldatetime
set @fecini = dbo.fdufechaaperiodo( @fecha) + '01'

select p.codprestamo,cl.nombrecompleto,o.nomoficina,z.nombre,p.cancelacion
,d.saldocapital,d.interesvigente,d.interesvencido,d.interesctaorden
,d.otroscargos,d.cargomora,d.impuestos
from tcspadroncarteradet p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
inner join tcscarteradet d with(nolock) on d.codprestamo=p.codprestamo and d.codusuario=p.codusuario and d.fecha=p.fechacorte
where p.cancelacion>=@fecini and p.cancelacion<=@fecha--'20210209'
GO