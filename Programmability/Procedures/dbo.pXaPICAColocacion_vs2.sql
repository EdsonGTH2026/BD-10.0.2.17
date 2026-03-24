SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaPICAColocacion_vs2] @codoficina varchar(2000),@codasesor varchar(15)
as
set nocount on

declare @fecha smalldatetime
select @fecha=fechaconsolidacion+1 from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
declare @fecfin smalldatetime
set @fecfin=@fecha

--declare @codoficina varchar(2000)
--set @codoficina='1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,23,24,25,114,26,27,28,29,3,30,301,101,302,102,303,103,304,104,305,105,307,'
--set @codoficina=@codoficina+'107,308,108,309,109,31,310,110,311,111,313,113,315,115,316,116,317,117,318,118,319,119,32,320,120,321,121,'
--set @codoficina=@codoficina+'322,122,323,123,324,124,325,125,326,126,327,127,328,128,329,129,33,330,130,332,132,333,133,334,134,335,'
--set @codoficina=@codoficina+'135,336,136,337,137,338,138,339,139,34,340,140,341,141,342,142,343,143,344,144,345,145,346,146,347'
--set @codoficina=@codoficina+',147,348,148,349,149,35,352,152,354,154,355,155,356,156,36,361,161,362,162,363,163,364,164,365,165,366,166'
--set @codoficina=@codoficina+',368,168,369,169,37,131,370,170,371,171,372,172,373,173,374,174,375,175,377,177,378,178,379,179,38,380,180'
--set @codoficina=@codoficina+',381,181,382,182,383,183,384,184,385,185,386,186,387,187,388,188,389,189,39,390,190,391,191,392,192,393,193,394,'
--set @codoficina=@codoficina+'194,395,195,396,196,397,197,399,199,4,40,400,200,401,201,402,202,403,203,405,205,406,206,407,207,408,208,'
--set @codoficina=@codoficina+'41,410,210,411,211,412,212,413,213,414,214,415,215,416,216,417,217,419,219,42,420,220,421,221,422,222,423,223,'
--set @codoficina=@codoficina+'424,224,425,225,426,226,427,227,428,228,429,229,430,431,432,232,433,233,434,234,435,235,436,236,437,237,438,238,'
--set @codoficina=@codoficina+'439,239,440,240,441,241,442,242,443,243,444,244,445,245,446,246,447,247,448,248,449,249,450,250,451,251,5,6,7,70,71,72,73,74,75,76,77,78,79,8,80,81,82,83,84,9,98'
------set @codoficina='4'
--declare @codasesor varchar(15)
----------set @codasesor='CSL1612751'
----------set @codasesor='UMC7909181'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

delete from @sucursales where codigo in('97','98','999')

create table #Ptmos2 (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,tiporeprog char(5),codfondo int)
CREATE INDEX [IX_Ptmos2] ON [dbo].[#Ptmos2]([codusuario],[desembolso]) WITH  FILLFACTOR = 100 ON [PRIMARY]

insert into #Ptmos2 
select p.codprestamo,p.codusuario,p.desembolso,p.monto,p.tiporeprog,c.codfondo
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha
where p.desembolso>=@fecini
and p.desembolso<=@fecfin
and p.codoficina not in('97','999')
and p.codoficina in(select codigo from @sucursales)
and (p.ultimoasesor=@codasesor or @codasesor='' or @codasesor is null)

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)

insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos2 p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

declare @f smalldatetime
set @f=@fecha--+1
create table #De(i int identity(1,1),periodo varchar(10),totalmonto money,totalnro int
				,renovadomonto money,renovadonro int,anticipadomonto money,anticipadonro int
				,reactivadomonto money,reactivadonro int,nuevomonto money,nuevonro int,propio money,progresemos money,cubo money)
insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro,propio,progresemos,cubo)
exec pCsCaColocacionRenoReacDia_vs2 @f,@codoficina

update #De set nuevomonto=totalmonto-renovadomonto-anticipadomonto-reactivadomonto,nuevonro=totalnro-renovadonro-anticipadonro-reactivadonro

declare @tb table(
periodo varchar(6),
totalmonto money,
totalnro int,
renovadomonto money,
renovadonro int,
renovadopor money,
anticipadomonto money,
anticipadonro int,
anticipadopor money,
reactivadomonto money,
reactivadonro int,
reactivadopor money,
nuevomonto money,
nuevonro int,
nuevopor money,
propio money,
progresemos money
)

insert into @tb (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro,nuevomonto,nuevonro,propio,progresemos)
select a.periodo,sum(a.totalmonto) totalmonto,sum(a.totalnro) totalnro
,sum(a.renovadomonto) renovadomonto,sum(a.renovadonro) renovadonro
,sum(a.anticipadomonto) anticipadomonto,sum(a.anticipadonro) anticipadonro
,sum(a.reactivadomonto) reactivadomonto,sum(a.reactivadonro) reactivadonro
,sum(a.nuevomonto) nuevomonto,sum(a.nuevonro) nuevonro
,sum(a.propio) propio
,sum(a.progresemos) progresemos
from (
	select
	dbo.fdufechaaperiodo(p.desembolso) periodo
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
	
	,sum(p.monto)
		-sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog='SINRE' then p.monto else 0 end)
		-sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) or p.tiporeprog='RENOV' then 
				case when p.tiporeprog='RENOV' then p.monto else 0 end
			else 0 end) --anticipadomonto
		-sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog<>'RENOV' then p.monto else 0 end) nuevomonto
	,count(p.codprestamo)
		-count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog='SINRE' then p.codusuario else null end)
		-count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) or p.tiporeprog='RENOV' then 
				case when p.tiporeprog='RENOV' then p.codusuario else null end
			else null end) --anticipadonro
		-count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) and p.tiporeprog<>'RENOV' then p.codusuario else null end) nuevonro
	
	,sum(case when p.codfondo=20 then p.monto*0.3 else p.monto end) propio
	,sum(case when p.codfondo=20 then p.monto*0.7 else 0 end) progresemos
	from #Ptmos2 p with(nolock)
	left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
	group by dbo.fdufechaaperiodo(p.desembolso)
	union
	select periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro,nuevomonto,nuevonro,propio,progresemos
	from #de
) a
group by a.periodo

update @tb set renovadopor=(renovadomonto/totalmonto)*100,anticipadopor=(anticipadomonto/totalmonto)*100,reactivadopor=(reactivadomonto/totalmonto)*100,nuevopor=(nuevomonto/totalmonto)*100

select * from @tb

drop table #liqreno
drop table #Ptmos2
drop table #De

GO