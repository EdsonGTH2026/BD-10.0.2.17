SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhRptSaldoMovi_diarios] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20210324'
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

select codproducto,fecha,count(codigocuenta) nro
--,tipotransacnivel1,tipotransacnivel2,tipotransacnivel3,descripciontran,montototaltran,codmotivo
,count(case when tipotransacnivel1='I' then codigocuenta else null end) NRO_IN
,sum(case when tipotransacnivel1='I' and substring(descripciontran,9,12)='Depósito STP' then montototaltran else 0 end) TRANS_STP
,sum(case when tipotransacnivel1='I' and substring(descripciontran,9,12)<>'Depósito STP' then montototaltran else 0 end) DEPO_BANCO
,count(case when tipotransacnivel1='E' then codigocuenta else null end) NRO_OUT
,sum(case when tipotransacnivel1='E' and tipotransacnivel3<>62 then montototaltran else 0 end) RETIRO
,sum(case when tipotransacnivel1='E' and tipotransacnivel3=62 then montototaltran else 0 end) ISR
into #Mov
from tcstransacciondiaria with(nolock)
where codsistema='AH'
and fecha>=@fecini--'20210301'
and fecha<=@fecha
--and codproducto='211'
group by codproducto,fecha

select a.codproducto,pr.nombre producto,a.fecha,a.nro,a.saldo,isnull(m.nro,0) nro_tx,isnull(m.nro_in,0) nro_in
,isnull(m.trans_stp,0) trans_stp,isnull(m.depo_banco,0) depo_banco
,isnull(m.nro_out,0) nro_out,isnull(m.retiro,0) retiro--,m.*
,isnull(m.isr,0) ISR
from (
	select codproducto,fecha,count(codproducto) nro, sum(saldocuenta) saldo
	from tcsahorros with(nolock)
	where fecha>=@fecini--'20210301'
	and fecha<=@fecha
	--and codproducto='211'
	group by codproducto,fecha
) a left outer join #Mov m with(nolock) on a.fecha=m.fecha and a.codproducto=m.codproducto
inner join tahproductos pr with(nolock) on pr.idproducto=a.codproducto

drop table #Mov
GO