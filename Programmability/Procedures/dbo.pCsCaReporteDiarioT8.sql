SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* TABLA 8. IMOR  */

Create Procedure [dbo].[pCsCaReporteDiarioT8]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @fech table(fecha smalldatetime )
insert into @fech 
select ultimodia from tclperiodo where ultimodia>=dateadd(month,-12,@fecha) and ultimodia<=@fecha
union select @fecha

create table #imor (fecha smalldatetime,fechaperiodo smalldatetime,Imor31 money, Imor60 money, Imor90 money)
insert into #imor
select @fecha fecha,i.fecha fechaPeriodo
,(sum(case when i.nrodiasatraso>=31 then d.saldocapital else 0 end)  
  /sum(d.saldocapital))*100 Imor31
,(sum(case when i.nrodiasatraso>=60 then d.saldocapital else 0 end)  
  /sum(d.saldocapital))*100 Imor60 
,(sum(case when i.nrodiasatraso>=90 then d.saldocapital else 0 end)  
  /sum(d.saldocapital))*100 Imor90
from tcscartera i with(nolock)
inner join tcscarteradet d with(nolock) on i.fecha=d.fecha and i.codprestamo=d.codprestamo  
where i.fecha in(select fecha from @fech)
and cartera='ACTIVA' and i.codoficina not in('97','230','231')
and i.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by i.fecha
order by i.fecha

select fecha, fechaperiodo,'Imor31' categoria, imor31 IMOR
from  #imor
union
select fecha, fechaperiodo,'Imor60' categoria, imor60 IMOR
from  #imor
union
select fecha, fechaperiodo,'Imor90' categoria, imor90 IMOR
from  #imor

drop table  #imor
GO