SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaColocacionRenoReacDia_DiaMax_vs2] @fecha smalldatetime,@codoficina varchar(2000)
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20200923'
--declare @codoficina varchar(500)
--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322'
--set @codoficina=@codoficina+',122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131'
--set @codoficina=@codoficina+',4,41,430,431,432,232,433,233,5,6,8,25,114,28'

create table #Ptmos (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,tiporeprog char(5))
insert into #Ptmos 
select codprestamo,codusuario,fechadesembolso,montodesembolso,isnull(tiporeprog,'SINRE') tiporeprog
from [10.0.2.14].finmas.dbo.tcaprestamos
where fechadesembolso=@fecha and estado='VIGENTE'
and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))

update #Ptmos
set codusuario=cl.codusuario
from #Ptmos p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

select x.codusuario--,x.codprestamo codprestamonuevo,p.codprestamo
,min(isnull(p.nrodiasmaximo,0)) nrodiasmaximo
into #dias
from #liqreno x with(nolock)
inner join tcspadroncarteradet p with(nolock) on x.codusuario=p.codusuario and x.cancelacion=p.cancelacion
group by x.codusuario

select
case when p.tiporeprog='RENOV' then '0 - 15'
	else 
		case when d.nrodiasmaximo>=0 and d.nrodiasmaximo<=15 then '0 - 15'
		  when d.nrodiasmaximo>=16 and d.nrodiasmaximo<=29 then '16 - 29'
		  when d.nrodiasmaximo>=30 then '30+'
		  else 'XX' end
	end dias
,sum(p.monto) totalmonto
,count(p.codprestamo) totalnro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog='SINRE' then p.monto else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog='SINRE' then p.codusuario else null end) renovadonro

,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) or p.tiporeprog='RENOV' then
			case when p.tiporeprog='RENOV' then p.monto else 0 end
		else 0 end) anticipadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) or p.tiporeprog='RENOV' then 
			case when p.tiporeprog='RENOV' then p.codusuario else null end
		else null end) anticipadonro

,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog<>'RENOV' then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog<>'RENOV' then p.codusuario else null end) reactivadonro
from #Ptmos p with(nolock)
left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
left outer join #dias d with(nolock) on d.codusuario=p.codusuario
group by case when p.tiporeprog='RENOV' then '0 - 15'
	else 
		case when d.nrodiasmaximo>=0 and d.nrodiasmaximo<=15 then '0 - 15'
		  when d.nrodiasmaximo>=16 and d.nrodiasmaximo<=29 then '16 - 29'
		  when d.nrodiasmaximo>=30 then '30+'
		  else 'XX' end
	end

drop table #liqreno
drop table #Ptmos
drop table #dias
GO