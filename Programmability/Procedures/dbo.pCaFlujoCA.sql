SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCaFlujoCA] @codusuario varchar(15), @secuenciacliente int
as
select u.codorigen,p.codprestamo codprestamoAnt,p.secuenciacliente 'SecuenciaClienteCiclo',p.estadocalculado estado--,u.MaxMonto,u.nrodiasmaximo
,c.tasaintcorriente
--into #CA
from tcspadroncarteradet p with(nolock)
--inner join #USC u with(nolock) on u.codusuario=p.codusuario and u.secuenciacliente=p.secuenciacliente
inner join tcscartera c with(nolock) on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
inner join tcspadronclientes u with(nolock) on u.codusuario=p.codusuario
where p.codusuario=@codusuario and p.secuenciacliente=@secuenciacliente
GO