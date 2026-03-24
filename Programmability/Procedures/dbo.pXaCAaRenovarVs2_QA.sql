SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----pXaCAaRenovarVs2_QA '308','LFA801001F17I1'
CREATE procedure [dbo].[pXaCAaRenovarVs2_QA] @codoficina varchar(4),@codasesor varchar(15)
as
set nocount on
--declare @codoficina varchar(3)
--set @codoficina='318'
--declare @codasesor varchar(15)
--set @codasesor='NPS970721FH000'
----select * from tcloficinas where nomoficina like '%omete%'
----select * from tcsempleados where nombres+' '+paterno+' '+materno like '%martha%davila%'

declare @fecha smalldatetime
--set @fecha='20190507'
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
declare @fecfin smalldatetime

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'--'20190501'
set @fecfin=@fecha

/*se comenta para que no sea lento*/
--select s.codsolicitud,s.codusuario,s.fechadesembolso,s.montoaprobado--,case when a.codsolicitud is null then 0 else 1 end enapp
--into #panel
--from [10.0.2.14].finamigoQA_2.dbo.tcasolicitud s
--left outer join [10.0.2.14].finamigoQA_2.dbo.tcasolicitudproce p on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina
--where p.estado not in(9,10,11,70,71) and s.codoficina=@codoficina

--update #panel
--set codusuario=p.codusuario
--from tcspadronclientes p with(nolock) inner join #panel x on x.codusuario=p.codorigen

/*se comenta para que no sea lento*/
--select s.codsolicitud,s.codoficina,s.codusuario,s.fechadesembolso,s.montoaprobado
--into #panel2
--from [10.0.2.14].finamigoQA_2.dbo.tcasolicitud s
--inner join [10.0.2.14].finamigoQA_2.dbo.tCaSolicitudApp a on s.codsolicitud=a.codsolicitud and s.codoficina=a.codoficina
--left outer join [10.0.2.14].finamigoQA_2.dbo.tCaSolicitudproce p on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina
--where s.codoficina=@codoficina and p.idproceso is null and s.codestado='TRAMITE'

--update #panel2
--set codusuario=p.codusuario
--from tcspadronclientes p with(nolock) inner join #panel2 x on x.codusuario=p.codorigen

select case when l.codpromotor is not null then
			case when l.cancelacion>=@fecini and l.cancelacion<=@fecfin then 'Renovaciones' else 'Reactivaciones' end 
	   else 
			case when datediff(month,l.cancelacion,@fecha)<=1 then 'Huerfano 0 a 1 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=2 and datediff(month,l.cancelacion,@fecha)<=3 then 'Huerfano 2 a 3 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=4 and datediff(month,l.cancelacion,@fecha)<=6 then 'Huerfano 4 a 6 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=7 and datediff(month,l.cancelacion,@fecha)<=9 then 'Huerfano 7 a 9 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=10 and datediff(month,l.cancelacion,@fecha)<=12 then 'Huerfano 10 a 12 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=13 then 'Huerfano +13 Meses'
			else 'Por definir' end 
	   end origen
,l.cliente,l.fechavencimiento,l.codprestamo,l.atrasomaximo diasmora,l.fechadesembolso fechafesembolso,l.monto montofesembolso,c.nrocuotas cuotas
,c.codsolicitud,l.codoficina,substring(l.codprestamo,5,3) codproducto,isnull(l.codpromotor,'') codasesor,isnull(l.codprestamonuevo,'') newcodsolicitud,l.coordinador promotor,l.secuenciacliente+1 ciclo
--,l.cancelacion
--,datediff(month,l.cancelacion,@fecha) dif
from tCsACaLIQUI_RR_QA l with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=l.codprestamo and c.fecha=l.fechadesembolso
where l.codoficina=@codoficina 
and (l.codpromotor in(@codasesor) or l.codpromotor is null)--'AGJ1104961'--and coordinador='ARCE GONZALEZ JACQUELINE'
and l.estado not in('Renovado','Reactivado','En Proceso')
and l.atrasomaximo>=0 and l.atrasomaximo<=30


--drop table #panel
--drop table #panel2

--select * 
--into tCsACaLIQUI_RR_QA
--from tCsACaLIQUI_RR with(nolock)


GO