SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaColocacionDiaOficinaReRe_vs2] @codoficinas varchar(2000)
as
set nocount on
Declare @FechaT 		SmallDateTime
Select @FechaT = FechaConsolidacion From vCsFechaConsolidacion
Declare @fecha smalldatetime
set @fecha=(@FechaT+1)

----<<<<<< COMENTAR
--declare @codoficinas varchar(500)
--set @codoficinas = '15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120
--,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'
------<<<<<< COMENTAR

declare @ncli int
declare @mdia decimal(16,2)
declare @macu decimal(16,2)

create table #De(i int identity(1,1),periodo varchar(10),totalmonto money,totalnro int
				,renovadomonto money,renovadonro int,anticipadomonto money,anticipadonro int
				,reactivadomonto money,reactivadonro int
				,nuevomonto money,nuevonro int,propio money,progresemos money,cubo money)
insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro,propio,progresemos,cubo)
--exec pCsCaColocacionRenoReacDia @fecha,@codoficinas
exec pCsCaColocacionRenoReacDia_vs2 @fecha,@codoficinas

declare @nrodia int
select @nrodia=count(*) from #De

if(day(@fecha)=1)
begin
	insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro)
	select dbo.fdufechaaperiodo(@fecha) periodo,0,0,0,0,0,0,0,0 from #De
end

declare @m1 smalldatetime
declare @m2 smalldatetime
declare @m3 smalldatetime
set @m1=dateadd(month,-1,@FechaT+1)
set @m2=dateadd(month,-2,@FechaT+1)
set @m3=dateadd(month,-3,@FechaT+1)
declare @m1i smalldatetime
declare @m2i smalldatetime
declare @m3i smalldatetime
declare @m0i smalldatetime
set @m0i=dbo.fdufechaatexto(@FechaT+1,'AAAAMM')+'01'
set @m1i=dbo.fdufechaatexto(@m1,'AAAAMM')+'01'
set @m2i=dbo.fdufechaatexto(@m2,'AAAAMM')+'01'
set @m3i=dbo.fdufechaatexto(@m3,'AAAAMM')+'01'

insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro)
exec pCsCaColocacionRenoReac_vs2 @m0i,@FechaT,@codoficinas
insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro)
exec pCsCaColocacionRenoReac_vs2 @m1i,@m1,@codoficinas
insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro)
exec pCsCaColocacionRenoReac_vs2 @m2i,@m2,@codoficinas
insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,anticipadomonto,anticipadonro,reactivadomonto,reactivadonro)
exec pCsCaColocacionRenoReac_vs2 @m3i,@m3,@codoficinas

if(@nrodia<>0)
begin
	update #De
	set periodo='En el día'
	where i=1

--select *
update #De
set totalmonto=x.totalmonto,totalnro=x.totalnro,renovadomonto=x.renovadomonto,renovadonro=x.renovadonro,reactivadomonto=x.reactivadomonto,reactivadonro=x.reactivadonro
,anticipadomonto=x.anticipadomonto,anticipadonro=x.anticipadonro
from #De d cross join
	(
	select a.totalmonto+b.totalmonto totalmonto,
	a.totalnro+b.totalnro totalnro,
	a.renovadomonto+b.renovadomonto renovadomonto,
	a.renovadonro+b.renovadonro renovadonro,
	a.anticipadomonto+b.anticipadomonto anticipadomonto,
	a.anticipadonro+b.anticipadonro anticipadonro,
	a.reactivadomonto+b.reactivadomonto reactivadomonto,
	a.reactivadonro+b.reactivadonro reactivadonro
	from #De a cross join #De b
	where a.i=1 and b.i=2
	) x
where i=2
end

update #De set nuevonro=totalnro-renovadonro-anticipadonro-reactivadonro,nuevomonto=totalmonto-anticipadomonto-renovadomonto-reactivadomonto

select * from #De

drop table #De
GO