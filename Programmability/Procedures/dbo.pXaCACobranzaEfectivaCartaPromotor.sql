SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaCACobranzaEfectivaCartaPromotor '20190501','20190508','CVE0906861'
CREATE procedure [dbo].[pXaCACobranzaEfectivaCartaPromotor] @fecini smalldatetime,@fecfin smalldatetime,@codpromotor varchar(15)
as
--declare @fecini smalldatetime
--set @fecini ='20190501'
--declare @fecfin smalldatetime
--set @fecfin ='20190508'
--declare @codpromotor varchar(15)
--set @codpromotor='CVE0906861'

create table #Cob (
	fecha smalldatetime,
	codprestamo varchar(25),
	codusuario varchar(15),
	capital money
)
insert into #Cob
select fecha, codigocuenta,codusuario,montocapitaltran capital
from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
and codoficina not in('97','231','230')

declare @Ca table(codprestamo varchar(25),promotor varchar(25))
insert into @Ca
select p.codprestamo, p.ultimoAsesor
from tcspadroncarteradet p with(nolock)
where p.codprestamo in(select distinct codprestamo from #Cob)
and p.ultimoAsesor=@codpromotor--'GCC3012991'

select count(t.codprestamo) nro,sum(capital) capital
from #Cob t inner join @Ca c on t.codprestamo=c.codprestamo
--group by dbo.fdufechaaperiodo(t.fecha)

drop table #Cob

--declare @fecini smalldatetime
--set @fecini ='20190401'

--declare @fecfin smalldatetime
--set @fecfin ='20190430'

----select fecha, codigocuenta,codusuario,montocapitaltran capital
--select count(codigocuenta) nro,sum(montocapitaltran) capital
--from tcstransacciondiaria with(nolock)
--where fecha>=@fecini and fecha<=@fecfin
--and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
--and codoficina not in('97','231','230')
--and codigocuenta in(
--	select p.codprestamo
--	from tcspadroncarteradet p with(nolock)
--	where p.ultimoAsesor='GCC3012991'
--)
GO