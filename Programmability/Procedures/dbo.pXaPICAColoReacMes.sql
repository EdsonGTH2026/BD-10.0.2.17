SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaPICAColoReacMes] @codoficina varchar(2000),@codasesor varchar(15)
as
set nocount on

declare @fecha smalldatetime
select @fecha=fechaconsolidacion+1 from vcsfechaconsolidacion
--set @fecha='20180930'
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
declare @fecfin smalldatetime
set @fecfin=@fecha

--declare @codoficina varchar(500)
--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120
--,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341
--,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'
----set @codoficina='4'
--declare @codasesor varchar(15)
------set @codasesor='CSL1612751'
------set @codasesor='UMC7909181'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

delete from @sucursales where codigo in('97','98','999')

create table #Ptmos2 (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3))
--ALTER TABLE #Ptmos2 WITH NOCHECK ADD CONSTRAINT [PK_#Ptmos2] PRIMARY KEY CLUSTERED (codprestamo)  ON [PRIMARY] 
CREATE INDEX [IX_Ptmos2] ON [dbo].[#Ptmos2]([codusuario],[desembolso],[codproducto]) WITH  FILLFACTOR = 100 ON [PRIMARY]

insert into #Ptmos2 
select codprestamo,codusuario,desembolso,monto,codproducto
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini
and desembolso<=@fecfin
and codoficina not in('97','999')
--and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
and codoficina in(select codigo from @sucursales)
and (ultimoasesor=@codasesor or @codasesor='' or @codasesor is null)

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)

insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos2 p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

declare @tb table(
	cancela varchar(20),
	reactivadomonto money,
	reactivadonro int
)
insert into @tb
select
case when year(l.cancelacion)<year(@fecha) then '0Anteriores' else dbo.fdufechaaperiodo(l.cancelacion) end cancela
,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
from #Ptmos2 p with(nolock)
inner join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
group by case when year(l.cancelacion)<year(@fecha) then '0Anteriores' else dbo.fdufechaaperiodo(l.cancelacion) end
having sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)>0
order by case when year(l.cancelacion)<year(@fecha) then '0Anteriores' else dbo.fdufechaaperiodo(l.cancelacion) end

declare @f smalldatetime
set @f=@fecha
create table #De(i int identity(1,1),periodo varchar(20),reactivadomonto money,reactivadonro int)
insert into #De (periodo,reactivadomonto,reactivadonro)
exec pCsCaColocacionRenoReacDia_ReacMes @f,@codoficina

--select t.cancela
--,t.reactivadomonto+isnull(d.reactivadomonto,0) reactivadomonto
--,t.reactivadonro+isnull(d.reactivadonro,0) reactivadonro
--from @tb t
--left outer join #de d on t.cancela=d.periodo

Select cancela,sum(reactivadomonto) reactivadomonto,sum(reactivadonro) reactivadonro
from (
	select t.cancela
	,t.reactivadomonto
	,t.reactivadonro
	from @tb t
	union
	select periodo,reactivadomonto,reactivadonro from #de
) a
group by cancela

drop table #liqreno
drop table #Ptmos2
drop table #de

--cancela	reactivadomonto	reactivadonro
--0Anteriores	9519360.00	1282
GO