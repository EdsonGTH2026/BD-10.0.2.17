SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsExCarteraAsesor] @codasesor varchar(15), @fecha smalldatetime
as
SELECT cd.codusuario, cl.nombrecompleto cliente
,sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocartera
,count(c.codprestamo) nroprestamos
FROM tCsCartera c with(nolock)
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
inner join tcspadronclientes cl with(nolock) on cl.codusuario=cd.codusuario
where c.fecha=@fecha and c.nrodiasatraso<61
and c.codasesor=@codasesor
and c.cartera='ACTIVA'
And c.codproducto<>'164'
group by cd.codusuario, cl.nombrecompleto
GO