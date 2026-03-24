SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pPLDCaLiquidacionesAnticipadas] @fecini smalldatetime,@fecfin smalldatetime
as
set nocount on
--declare @t1 datetime
--declare @t2 datetime

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20220201'
--set @fecfin='20220228'
--4,847

--set @t1=getdate()

declare @can table (codprestamo varchar(20),cancelacion smalldatetime)
insert into @can
select codprestamo,cancelacion
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecini and cancelacion<=@fecfin

--set @t2=getdate()
--print '1-->' + cast(datediff(millisecond,@t1,@t2) as varchar(20))
--set @t1=getdate()

declare @liquidados  table (
	cliente varchar(200),
	codprestamo varchar(20),
	monto money,
	nrocuotas int,
	periocidad varchar(20),
	cuotaliquida int,
	montototaltran money,
	coddestino varchar(10),
	liquidacion datetime,
	fechahora datetime,
	tipotransacnivel1 char(1),
	tipotransacnivel2 varchar(10),
	tipotransacnivel3 tinyint
) 
insert into @liquidados
select t.nombrecliente cliente,t.codigocuenta codprestamo,p.monto,p.nrocuotas,ca.modalidadplazo periocidad,ca.cuotaactual cuotaliquida
,t.montototaltran,t.coddestino,t.fecha liquidacion
,cast(
replicate('0',2-len(ltrim(rtrim(t.tranhora))))+ltrim(rtrim(t.tranhora))+':'
+replicate('0',2-len(ltrim(rtrim(t.tranminuto))))+ltrim(rtrim(t.tranminuto))+':'
+replicate('0',2-len(ltrim(rtrim(t.transegundo))))+ltrim(rtrim(t.transegundo))+'.'+cast(t.tranmicrosegundo as varchar(5)) 
as datetime) fechahora,t.tipotransacnivel1,t.tipotransacnivel2,t.tipotransacnivel3
from tcstransacciondiaria t with(nolock)
inner join tcspadroncarteradet p with(nolock) on p.codprestamo=t.codigocuenta
inner join tcscartera ca with(nolock) on ca.codprestamo=p.codprestamo and ca.fecha=p.fechacorte
inner join @can cx on cx.codprestamo=t.codigocuenta and cx.cancelacion=t.fecha
where t.fecha>=@fecini and t.fecha<=@fecfin
and t.codsistema='CA'
--and t.tipotransacnivel3=105
and t.codigocuenta IN--='003-170-06-00-03853'
(select codprestamo from @can )--with(nolock)

--set @t2=getdate()
--print '2-->' + cast(datediff(millisecond,@t1,@t2) as varchar(20))
--set @t1=getdate()

----drop table #LFM
--select codprestamo, max(fechahora) fechahora
--into #LFM
--from #liquidados with(nolock)
--group by codprestamo

--set @t2=getdate()
--print '3-->' + cast(datediff(millisecond,@t1,@t2) as varchar(20))
--set @t1=getdate()

----select *
--delete from #liquidados --> 3,392
--from #liquidados l with(nolock)
--left outer join #LFM o with(nolock) on l.codprestamo=o.codprestamo and l.fechahora=o.fechahora
--where o.codprestamo is null

declare @montoprogra table(codprestamo varchar(20), montocuota money)
insert into @montoprogra
select codprestamo, sum(montocuota) montocuota
from tcspadronplancuotas with(nolock)
where codprestamo in (select codprestamo from @can)
and codconcepto in('CAPI','INTE','IVAIT','SDV')
and seccuota=1
and numeroplan>=0
group by codprestamo

--set @t2=getdate()
--print '4-->' + cast(datediff(millisecond,@t1,@t2) as varchar(20))
--set @t1=getdate()

select l.cliente,l.codprestamo,l.monto,l.nrocuotas,l.periocidad
,m.montocuota,l.cuotaliquida
,l.montototaltran
,case when l.coddestino='DC' then 'Renovacion anticipada'
			when l.coddestino='1' then 'Pago en sucursal'
			when l.coddestino='2' then 'Pago en campo'
			when l.coddestino='7' then 'Garantia liquida'
			when l.coddestino='DB' then 'Pago bancario'
			else 
				case when l.tipotransacnivel3=2 then 'Liquidado x condonacion' else l.coddestino end
			end formapago

,l.liquidacion
from @liquidados l
left outer join @montoprogra m on l.codprestamo=m.codprestamo
where l.coddestino<>'DC'
--select * from #liquidados

--set @t2=getdate()
--print '5-->' + cast(datediff(millisecond,@t1,@t2) as varchar(20))
--set @t1=getdate()


--drop table #liquidados
--drop table #can
--drop table #LFM
--drop table #montoprogra

--Cliente
--No. De contrato
--Monto de crédito
--Plazo crédito 
--No. De pagos
--Periodicidad de pago
--monto de pago según tabla amortización
--número de pago en el que se liquida
--monto liquidacion
--forma de pago 
--fecha de liquidación
GO