SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCAColocionCartaPromotor] @codpromotor varchar(15),@fecini smalldatetime,@fecfin smalldatetime
as
set nocount on	
--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20190401'
--set @fecfin='20190430'
--declare @codpromotor varchar(15)
--set @codpromotor='GCC3012991'
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion--,a.codprestamo,a.desembolso,a.cancelacion	
into #liqreno	
from tcspadroncarteradet p with(nolock)	
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso	
and substring(p.codprestamo,5,3) = (case when substring(a.codprestamo,5,3) ='370' then '370' else '170' end)	
where p.desembolso>=@fecini	and p.desembolso<=@fecfin	
and p.codoficina<>'97' and p.primerasesor=@codpromotor
group by p.codprestamo,p.desembolso,p.codusuario	
having max(a.cancelacion) is not null	
	
select l.codprestamo,p.codprestamo codprestamo_ante,p.monto monto_ante,p.primerasesor codasesor_ante, p.secuenciacliente	
into #CredAnte	
from #liqreno l	
inner join tcspadroncarteradet p with(nolock) 	
on l.codusuario=p.codusuario and l.cancelacion=p.cancelacion	
and substring(l.codprestamo,5,3) = (case when substring(p.codprestamo,5,3) ='370' then '370' else '170' end)	
	
select --o.nomoficina sucursal,co.nombrecompleto coordinador,
count(p.codprestamo) nroPresamos, sum(p.monto) monto	
,case when l.cancelacion is NULL then 'NUEVO' ELSE	
	case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)
	then 'RENOVACION' else 'REACTIVACION' end
	END tipo_credito
--,an.codasesor_ante	
from tcspadroncarteradet p	
left outer join #liqreno l on l.codprestamo=p.codprestamo	
left outer join #CredAnte an on an.codprestamo=l.codprestamo	
left outer join tcspadronclientes co on co.codusuario=p.primerasesor
inner join tcloficinas o on o.codoficina=p.codoficina	
left outer join tcsempleados e on e.codusuario=p.primerasesor	
left outer join tcsempleados ex on ex.codusuario=an.codasesor_ante	
left outer join tcspadronclientes cox on cox.codusuario=an.codasesor_ante	
where p.desembolso>=@fecini and p.desembolso<=@fecfin	
and p.codoficina<>'97' and p.primerasesor=@codpromotor
group by --co.nombrecompleto,o.nomoficina,	
case when l.cancelacion is NULL then 'NUEVO' ELSE	
	case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)
	then 'RENOVACION' else 'REACTIVACION' end
	END
 	
drop table #liqreno	
drop table #CredAnte
GO