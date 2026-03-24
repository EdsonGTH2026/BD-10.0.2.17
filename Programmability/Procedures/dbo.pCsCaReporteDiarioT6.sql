SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA 6. TENDENCIA DE CARTERA FA POR BUCKETS */

Create Procedure [dbo].[pCsCaReporteDiarioT6]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @fech table(fecha smalldatetime)
insert into @fech
select ultimodia from tclperiodo 
where ultimodia>=dateadd(month,-12,@fecha) and ultimodia<=@fecha
union select @fecha

select @fecha fecha,fecha fechaPeriodo
,(case when nrodiasatraso = 0 then '0dm' 
 when nrodiasatraso>=1 and nrodiasatraso<=7 then '1a7dm' 
 when nrodiasatraso>=8 and nrodiasatraso <=15 then '8a15dm'
 when nrodiasatraso>=16 and nrodiasatraso <=30 then  '16a30dm'
 when nrodiasatraso>=31 and nrodiasatraso <=60 then   '31a60dm'
 when nrodiasatraso>=61 and nrodiasatraso <=89 then  '61a89dm'
 when nrodiasatraso>=90 and nrodiasatraso <=120 then  '90a120dm'
 when nrodiasatraso>=121 and nrodiasatraso <=150 then '121a150dm'
 when nrodiasatraso>=151 and nrodiasatraso <=180 then  '151a180dm'
 when nrodiasatraso>=181 and nrodiasatraso <=210 then   '181a210dm'
 when nrodiasatraso>=211 and nrodiasatraso <=240 then '211a240dm'
 when nrodiasatraso>=241 then '241dm' else '' end) Cubetas
,sum(saldocapital) saldoCapitalTOTAL
,case when nrodiasatraso>=0 and nrodiasatraso<=30 then 'VIGENTE 0-30'
 when nrodiasatraso>=31 and nrodiasatraso<=89 then 'ATRASADO 31-89'
 when nrodiasatraso>=90  then 'VENCIDO 90+' end Categoria
from tcscartera i with(nolock)
where fecha in(select fecha from @fech )
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))group by fecha,(case when nrodiasatraso = 0 then '0dm' 
 when nrodiasatraso>=1 and nrodiasatraso<=7 then '1a7dm'  when nrodiasatraso>=8 and nrodiasatraso <=15 then '8a15dm'
 when nrodiasatraso>=16 and nrodiasatraso <=30 then  '16a30dm' when nrodiasatraso>=31 and nrodiasatraso <=60 then   '31a60dm'
 when nrodiasatraso>=61 and nrodiasatraso <=89 then  '61a89dm' when nrodiasatraso>=90 and nrodiasatraso <=120 then  '90a120dm'
 when nrodiasatraso>=121 and nrodiasatraso <=150 then '121a150dm' when nrodiasatraso>=151 and nrodiasatraso <=180 then  '151a180dm'
 when nrodiasatraso>=181 and nrodiasatraso <=210 then   '181a210dm' when nrodiasatraso>=211 and nrodiasatraso <=240 then '211a240dm'
 when nrodiasatraso>=241 then '241dm' else '' end) 
 ,case when nrodiasatraso>=0 and nrodiasatraso<=30 then 'VIGENTE 0-30'
 when nrodiasatraso>=31 and nrodiasatraso<=89 then 'ATRASADO 31-89' when nrodiasatraso>=90  then 'VENCIDO 90+' END
order by fecha
GO