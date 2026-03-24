SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptCubetasPlantilla] @codoficina varchar(2000)
as
set nocount on
--declare @codoficina varchar(500)
--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

create table #pla(
	sec int,
	rango varchar(30),
	nro int
)
insert into #pla values(1,'0 a 3 Meses',0)
insert into #pla values(2,'3 a 6 Meses' ,0)
insert into #pla values(3,'6 a 9 Meses',0)
insert into #pla values(3,'9 a 12 Meses',0)
insert into #pla values(4,' + 12 Meses' ,0)

update #pla
set nro=a.nro
from #pla p
inner join (
select 
case when datediff(month,ingreso,@fecha)>=0 and datediff(month,ingreso,@fecha)<=3 then '0 a 3 Meses' 
	 when datediff(month,ingreso,@fecha)>=3.01 and datediff(month,ingreso,@fecha)<=6 then '3 a 6 Meses' 
	 when datediff(month,ingreso,@fecha)>=6.01 and datediff(month,ingreso,@fecha)<=9 then '6 a 9 Meses' 
	 when datediff(month,ingreso,@fecha)>=9.01 and datediff(month,ingreso,@fecha)<=12 then '9 a 12 Meses' 
	 when datediff(month,ingreso,@fecha)>=12.01 then ' + 12 Meses' 
	 else '' end Et, count(codusuario) nro
from tcsempleados
where codoficinanom in(select codigo from @sucursales) and estado=1 and codpuesto=66
group by case when datediff(month,ingreso,@fecha)>=0 and datediff(month,ingreso,@fecha)<=3 then '0 a 3 Meses' 
	 when datediff(month,ingreso,@fecha)>=3.01 and datediff(month,ingreso,@fecha)<=6 then '3 a 6 Meses' 
	 when datediff(month,ingreso,@fecha)>=6.01 and datediff(month,ingreso,@fecha)<=9 then '6 a 9 Meses' 
	 when datediff(month,ingreso,@fecha)>=9.01 and datediff(month,ingreso,@fecha)<=12 then '9 a 12 Meses' 
	 when datediff(month,ingreso,@fecha)>=12.01 then ' + 12 Meses' 
	 else '' end
) a on p.rango=a.et

declare @nro1 int
declare @nro2 int
select @nro1=sum(nro) from #pla where sec<90
insert into #pla values(90,'Total plantilla',@nro1)

select @nro2=sum(nropromotor) from tCsEmpleadosPlani where codoficina in(select codigo from @sucursales) and @fecha>=fechaini and @fecha<=fechafin
insert into #pla values(91,'Plantilla autorizada',@nro2)

insert into #pla values(92,'Vacantes',@nro2-@nro1)

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from @sucursales)

select rango
,sum(nroptmo) nroptmo,sum(saldocapital) saldocapital
,sum(VigenteNro) VigenteNro,sum(VigenteSaldo) VigenteSaldo
,sum(AtrasoNro) AtrasoNro,sum(AtrasoSaldo) AtrasoSaldo
,sum(VencidoNro) VencidoNro,sum(VencidoSaldo) VencidoSaldo
into #res
from (
	select rango,promotor
	,count(distinct codprestamo) nroptmo
	,sum(saldocapital) saldocapital
	,count(distinct D0a7nroptmo) VigenteNro,sum(D0a7saldo) VigenteSaldo, (sum(D0a7saldo)/sum(saldocapital))*100 VigentePor
	,count(distinct D8a30nroptmo) AtrasoNro,sum(D8a30saldo) AtrasoSaldo, (sum(D8a30saldo)/sum(saldocapital))*100 AtrasoPor
	,count(distinct D31nroptmo) VencidoNro,sum(D31saldo) VencidoSaldo, (sum(D31saldo)/sum(saldocapital))*100 VencidoPor
	from (
	  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
	  ,cd.saldocapital
	  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D0a7nroptmo
	  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D0a7saldo

	  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D8a30nroptmo
	  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D8a30saldo

	  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31nroptmo
	  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31saldo
	  --,cl.nombrecompleto promotor
	  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombrecompleto end promotor
	  ,case when datediff(month,ex.ingreso,'20190130')>=0 and datediff(month,ex.ingreso,'20190130')<=3 then '0 a 3 Meses' 
		 when datediff(month,ex.ingreso,'20190130')>=3.01 and datediff(month,ex.ingreso,'20190130')<=6 then '3 a 6 Meses' 
		 when datediff(month,ex.ingreso,'20190130')>=6.01 and datediff(month,ex.ingreso,'20190130')<=9 then '6 a 9 Meses' 
		 when datediff(month,ex.ingreso,'20190130')>=9.01 and datediff(month,ex.ingreso,'20190130')<=12 then '9 a 12 Meses' 
		 when datediff(month,ex.ingreso,'20190130')>=12.01 then ' + 12 Meses' 
		 else '' end rango
	  FROM tCsCartera c with(nolock)
	  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
	  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
	  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
	  left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
	  left outer join tcsempleados ex on ex.codusuario=c.codasesor
	  where c.fecha=@fecha and c.cartera='ACTIVA'
	  and c.codprestamo in(select codprestamo from #ptmos)
	
	) a
	group by rango,promotor
) b
where promotor<>'HUERFANO'
group by rango

select p.sec,p.rango,p.nro
,isnull(nroptmo,0) nroptmo,isnull(saldocapital,0) saldocapital
,isnull(VigenteNro,0) VigenteNro,isnull(VigenteSaldo,0) VigenteSaldo,case when isnull(saldocapital,0)=0 then 0 else (isnull(VigenteSaldo,0)/isnull(saldocapital,0))*100 end VigentePor
,isnull(AtrasoNro,0) AtrasoNro,isnull(AtrasoSaldo,0) AtrasoSaldo,case when isnull(saldocapital,0)=0 then 0 else (isnull(AtrasoSaldo,0)/isnull(saldocapital,0))*100 end AtrasoPor
,isnull(VencidoNro,0) VencidoNro,isnull(VencidoSaldo,0) VencidoSaldo,case when isnull(saldocapital,0)=0 then 0 else (isnull(VencidoSaldo,0)/isnull(saldocapital,0))*100 end VencidoPor
from #pla p
left outer join #res r on p.rango=r.rango

drop table #ptmos
drop table #pla
drop table #res

GO