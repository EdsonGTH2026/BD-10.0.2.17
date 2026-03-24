SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaRptClientesOportunidades]
(@fecini smalldatetime,
@fecfin smalldatetime,
@codoficina varchar(250))
AS
BEGIN
	SET NOCOUNT ON;

--declare @T1 datetime
--declare @T2 datetime

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--declare @codoficina varchar(200)

--set @fecini='20120320'
--set @fecfin='20120331'
--set @codoficina = '3,5,7,9'

create table #tmp(
	codusuario varchar(15) NOT NULL,
	codoficina varchar(4) NOT NULL,
	monto	decimal(16,4),
	montocartera decimal(16,4) default(0),
	montoahorros decimal(16,4) default(0),
	montoservicios decimal(16,4) default(0),
	montoremesas decimal(16,4) default(0),
	montopagotelmex decimal(16,4) default(0),
	montotjtasaludo decimal(16,4) default(0),
	montotiempoaire decimal(16,4) default(0),
	montotjtaprepago decimal(16,4) default(0),
	montoextramigra decimal(16,4) default(0),	
	nrocartera decimal(16,4) default(0),
	nroahorros decimal(16,4) default(0),
	nroservicios decimal(16,4) default(0),
	nroremesas decimal(16,4) default(0),
	nropagotelmex decimal(16,4) default(0),
	nrotjtasaludo decimal(16,4) default(0),
	nrotiempoaire decimal(16,4) default(0),
	nrotjtaprepago decimal(16,4) default(0),
	nroextramigra decimal(16,4) default(0)
)

--set @T1 = getdate()

declare @cad varchar(2000)
set @cad = 'insert into #tmp (codusuario,codoficina,monto) '
set @cad = @cad + 'select codusuario,codoficina,sum(montototaltran) monto '
set @cad = @cad + 'from tcstransacciondiaria with(nolock) where codsistema=''TC'' and fecha>='''+dbo.fduFechaAAAAMMDD(@fecini)+''' and fecha<='''+dbo.fduFechaAAAAMMDD(@fecfin)+''' '
set @cad = @cad + 'and extornado=0 and tipotransacnivel3=23 and codoficina in ('+@codoficina+') '
set @cad = @cad + 'group by codusuario,codoficina '
exec (@cad)

--set @T2 = getdate()
--print 'insert inicial - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

create table #tran(
	codusuario varchar(15),
	codoficina varchar(4),
	montototaltran	decimal(16,4),
	tipotransacnivel3 tinyint,
	tipotransacnivel1 char(1)
)
set @cad = 'insert into #tran '
set @cad = @cad + 'select codusuario,codoficina,montototaltran,tipotransacnivel3,tipotransacnivel1 '
set @cad = @cad + 'from tcstransacciondiaria with(nolock) where codsistema=''TC'' and fecha>='''+dbo.fduFechaAAAAMMDD(@fecini)+''' and fecha<='''+dbo.fduFechaAAAAMMDD(@fecfin)+''' '
set @cad = @cad + 'and extornado=0 and codoficina in ('+@codoficina+') '
exec(@cad)

--set @T2 = getdate()
--print 'insert transaccion - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

update #tmp
set montocartera=ca.monto
from #tmp o inner join (
select c.codusuario,sum(c.monto) monto 
from tcspadroncarteradet c with(nolock) 
where estadocalculado not in('CANCELADO')
and codusuario in (select codusuario from #tmp) 
group by c.codusuario
) ca on ca.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update cartera - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

update #tmp
set montoahorros=ah.monto
from #tmp o inner join (
select p.codusuario,sum(a.saldocuenta) monto
from tcspadronahorros p with(nolock)
inner join tcsahorros a with(nolock) on a.codcuenta=p.codcuenta and a.fraccioncta=p.fraccioncta and a.renovado=p.renovado and a.fecha=p.fechacorte
where p.estadocalculado<>'CC'
and p.codusuario in (select codusuario from #tmp) 
group by p.codusuario
) ah on ah.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update ahorros - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

-- se inhabilita por el momento
--update #tmp
--set montoservicios=se.monto
--from #tmp o inner join (
--select codusuario,sum(montototaltran) monto
--from tcstransacciondiaria with(nolock) where codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 and tipotransacnivel3<>23 and tipotransacnivel1='I'
--group by codusuario,codoficina
--) se on se.codusuario=o.codusuario

update #tmp
set montoremesas=se.monto
from #tmp o inner join (
select codusuario,sum(montototaltran) monto
from #tran--tcstransacciondiaria 
with(nolock) where --codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 
--and 
tipotransacnivel3 in (1,6,11,22,26) and tipotransacnivel1='E'
group by codusuario
) se on se.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update remesas - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

--18	        PAGO TELMEX
update #tmp
set montopagotelmex=se.monto
from #tmp o inner join (
select codusuario,sum(montototaltran) monto
from #tran--tcstransacciondiaria 
with(nolock) 
where --codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 and 
tipotransacnivel3=18 and tipotransacnivel1='I'
group by codusuario
) se on se.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update telmex - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

--19	        TARJETA SALUDO
update #tmp
set montotjtasaludo=se.monto
from #tmp o inner join (
select codusuario,sum(montototaltran) monto
from #tran --tcstransacciondiaria 
with(nolock) 
where --codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 and 
tipotransacnivel3=19 and tipotransacnivel1='I'
group by codusuario
) se on se.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update tarjeta saludo - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

--21	        TIEMPO AIRE
update #tmp
set montotiempoaire=se.monto
from #tmp o inner join (
select codusuario,sum(montototaltran) monto
from #tran --tcstransacciondiaria 
with(nolock) 
where --codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 and 
tipotransacnivel3=21 and tipotransacnivel1='I'
group by codusuario
) se on se.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update tiempo aire - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

--25	        TARJETA PREPAGADA
update #tmp
set montotjtaprepago=se.monto
from #tmp o inner join (
select codusuario,sum(montototaltran) monto
from #tran --tcstransacciondiaria 
with(nolock) 
where --codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 and 
tipotransacnivel3=25 and tipotransacnivel1='I'
group by codusuario
) se on se.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update prepagada - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

--31	        RECURSOS EXTRABAJADORES MIGRANTES
update #tmp
set montoextramigra=se.monto
from #tmp o inner join (
select codusuario,sum(montototaltran) monto
from #tran --tcstransacciondiaria 
with(nolock) 
where --codsistema='TC' and fecha>=@fecini and fecha<=@fecfin
--and extornado=0 and 
tipotransacnivel3=31 and tipotransacnivel1='I'
group by codusuario
) se on se.codusuario=o.codusuario

--set @T2 = getdate()
--print 'update trabajadores - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

update #tmp
set nrocartera=1
where montocartera<>0

update #tmp
set nroahorros=1
where montoahorros<>0

--update #tmp
--set nroservicios=1
--where montoservicios<>0

update #tmp
set nroremesas=1
where montoremesas<>0

update #tmp
set nropagotelmex=1
where montopagotelmex<>0

update #tmp
set nrotjtasaludo=1
where montotjtasaludo<>0

update #tmp
set nrotiempoaire=1
where montotiempoaire<>0

update #tmp
set nrotjtaprepago=1
where montotjtaprepago<>0

update #tmp
set nroextramigra=1
where montoextramigra<>0

--set @T2 = getdate()
--print 'update numeros - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

select #tmp.codoficina,o.nomoficina,sum(monto) monto,count(#tmp.codusuario) nroopor
,sum(#tmp.montocartera) montocartera,sum(#tmp.nrocartera) nrocartera
,sum(#tmp.montoahorros) montoahorros,sum(#tmp.nroahorros) nroahorros
,sum(#tmp.montoservicios) montoservicios,sum(#tmp.nroservicios) nroservicios
,sum(#tmp.montoremesas) montoremesas,sum(#tmp.nroremesas) nroremesas

,sum(#tmp.montopagotelmex) montopagotelmex,sum(#tmp.nropagotelmex) nropagotelmex
,sum(#tmp.montotjtasaludo) montotjtasaludo,sum(#tmp.nrotjtasaludo) nrotjtasaludo
,sum(#tmp.montotiempoaire) montotiempoaire,sum(#tmp.nrotiempoaire) nrotiempoaire
,sum(#tmp.montotjtaprepago) montotjtaprepago,sum(#tmp.nrotjtaprepago) nrotjtaprepago
,sum(#tmp.montoextramigra) montoextramigra,sum(#tmp.nroextramigra) nroextramigra

from #tmp inner join tcloficinas o with(nolock) on o.codoficina=#tmp.codoficina
group by #tmp.codoficina,o.nomoficina

--set @T2 = getdate()
--print 'final - '+ cast( datediff(millisecond, @T1, @T2) as varchar(8))
--set @T1 = getdate()

drop table #tmp
drop table #tran

END
GO