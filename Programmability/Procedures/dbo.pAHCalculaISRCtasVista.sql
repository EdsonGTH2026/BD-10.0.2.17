SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pAHCalculaISRCtasVista] @por_isr decimal(16,8)
as
set nocount on
--declare @por_isr decimal(16,8)
--set @por_isr=0.97

declare @f1 decimal(16,8)
set @f1=@por_isr/cast(360 as decimal(16,4))
declare @f2 decimal(16,8)
set @f2=@f1/cast(100 as decimal(16,4))

--select @por_isr '@por_isr',@f1 '@f1',@f2 '@f2'

declare @fecfin smalldatetime
declare @fecini smalldatetime
select @fecfin=fechaconsolidacion+1 from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'
--select @fecfin, @fecini

select *
into #AhCtasISR
from [10.0.2.14].finmas.dbo._AhCtasISR

create table #ctas(fecha smalldatetime,codcuenta varchar(20),saldocuenta money)

declare @n tinyint
declare @i tinyint
set @n=day(@fecfin)
set @i=0

while (@i<@n)
begin
	insert into #ctas
	select fecha,codcuenta,saldocuenta
	from tcsahorros with(nolock)
	where fecha=dateadd(day,@i,@fecini)
	and codcuenta in(select codcuenta from #AhCtasISR)
	--select dateadd(day,@i,@fecini) 'x'
	set @i=@i+1
end

insert into #ctas
select @fecfin,codcuenta,saldocuenta from #AhCtasISR

--declare @por_isr decimal(16,8)
--set @por_isr=0.97
--declare @f1 decimal(16,8)
--set @f1=@por_isr/cast(360 as decimal(16,4))
--declare @f2 decimal(16,8)
--set @f2=@f1/cast(100 as decimal(16,4))
----select @por_isr '@por_isr',@f1 '@f1',@f2 '@f2'

--select i.codcuenta,i.ImpuestoAcum,x.*
update #AhCtasISR
set ImpuestoAcum=x.isr_acum
from #AhCtasISR i
inner join (
	select codcuenta,avg(saldocuenta) saldocuenta,round(avg(saldocuenta)*@f2,4) isr_acum
	from #ctas --with(nolock)
	group by codcuenta
) x on x.codcuenta=i.codcuenta

select codcuenta,ImpuestoAcum from #AhCtasISR

drop table #AhCtasISR
drop table #ctas

--select *
--from #ctas with(nolock)
--where codcuenta='098-116-06-2-9-00003'

GO