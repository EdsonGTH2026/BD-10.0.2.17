SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsCaColocacionRenoReacDia '20190328','15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'
CREATE procedure [dbo].[pCsCaColocacionRenoReacDia] @fecha smalldatetime,@codoficina varchar(2000)
as
--declare @fecha smalldatetime
--declare @codoficina varchar(500)
--set @fecha='20190328'
--set @codoficina= '15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'

create table #Ptmos (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3),codfondo int)
insert into #Ptmos 
--exec [10.0.2.14].finmas.dbo.pCsCaColocacionRenoReacDia2 @fecha,@codoficina
select codprestamo,codusuario,fechadesembolso,montodesembolso,codproducto,codfondo
from [10.0.2.14].finmas.dbo.tcaprestamos ---with(nolock)
where fechadesembolso=@fecha and estado='VIGENTE'
and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))


--select p.codprestamo,p.codusuario,cl.codorigen,cl.codusuario
update #Ptmos
set codusuario=cl.codusuario
from #Ptmos p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

select
dbo.fdufechaaperiodo(p.desembolso) periodo
,sum(p.monto) totalmonto
,count(p.codprestamo) totalnro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
,sum(case when p.codfondo=20 then p.monto*0.3 else p.monto end) propio
,sum(case when p.codfondo=20 then p.monto*0.7 else 0 end) progresemos
from #Ptmos p with(nolock)
left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
group by dbo.fdufechaaperiodo(p.desembolso)
order by dbo.fdufechaaperiodo(p.desembolso)

drop table #liqreno
drop table #Ptmos





GO

GRANT EXECUTE ON [dbo].[pCsCaColocacionRenoReacDia] TO [marista]
GO