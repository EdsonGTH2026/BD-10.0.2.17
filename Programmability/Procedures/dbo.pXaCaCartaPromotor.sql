SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaCaCartaPromotor 'ECE740604FH300'
CREATE procedure [dbo].[pXaCaCartaPromotor] @codpromotor varchar(15)
as
set nocount on
declare @fecini smalldatetime
declare @fecfin smalldatetime
--set @fecini='20190401'
--set @fecfin='20190430'
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin) + '01'

declare @ultimodia smalldatetime
select @ultimodia=ultimodia from tclperiodo where primerdia<=@fecfin and ultimodia>=@fecfin

--declare @codpromotor varchar(15)
--set @codpromotor='GAA1701981'

declare @nivel varchar(20)
declare @meta_saldo money
set @nivel='POR DEFINIR'
set @meta_saldo=0
select @nivel=descripcion from tCsCaMetas where tipocodigo=2 and meta=2 and codigo=@codpromotor and fecha=@ultimodia--@fecfin
select @meta_saldo=monto from tCsCaMetas where tipocodigo=2 and meta=1 and codigo=@codpromotor and fecha=@ultimodia--@fecfin

create table #co(nro int,monto money, tipo varchar(15))
insert into #co
exec pXaCAColocionCartaPromotor @codpromotor,@fecini,@fecfin
--exec pXaCAColocionCartaPromotor 'GCC3012991','20190501','20190505'
--select * from #colocacion

declare @co_reno_nro int
declare @co_reno_monto money
declare @co_reac_nro int
declare @co_reac_monto money
declare @co_nuev_nro int
declare @co_nuev_monto money

set @co_reno_nro=0
set @co_reno_monto=0
set @co_reac_nro=0
set @co_reac_monto=0
set @co_nuev_nro=0
set @co_nuev_monto=0

select @co_reno_nro=nro from #co where tipo='RENOVACION'
select @co_reno_monto=monto from #co where tipo='RENOVACION'
select @co_reac_nro=nro from #co where tipo='REACTIVACION'
select @co_reac_monto=monto from #co where tipo='REACTIVACION'
select @co_nuev_nro=nro from #co where tipo='NUEVO'
select @co_nuev_monto=monto from #co where tipo='NUEVO'

--renovaciones
declare @reno_nro int
declare @reno_monto money
set @reno_nro=0
set @reno_monto=0
select @reno_nro=isnull(count(codprestamo),0), @reno_monto=isnull(sum(monto),0)
from tCsACaLIQUI_RR
where cancelacion>=@fecini and cancelacion<=@fecfin and codpromotor=@codpromotor
--where cancelacion>='20190501' and cancelacion<='20190505' and codpromotor='GCC3012991'
--codoficina=4 and 

--Universo a reactivar
declare @ure_nro_31 int, @ure_monto_31 money
declare @ure_nro_91 int, @ure_monto_91 money
declare @ure_nro_121 int, @ure_monto_121 money
declare @ure_nro_181 int, @ure_monto_181 money

declare @uni_re table(dias varchar(10),monto money, nro int)
insert into @uni_re

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20190501'
--set @fecfin='20190505'

select case when datediff(day,cancelacion,@fecfin)>=0 and datediff(day,cancelacion,@fecfin)<=90 then '31-90'
		when datediff(day,cancelacion,@fecfin)>=91 and datediff(day,cancelacion,@fecfin)<=120 then '91-120'
		when datediff(day,cancelacion,@fecfin)>=121 and datediff(day,cancelacion,@fecfin)<=180 then '121-180'
		when datediff(day,cancelacion,@fecfin)>=181 then '181+'
		else 'XX' end dias
,sum(monto) monto,count(codprestamo) nro
from tCsACaLIQUI_RR
where estado='Sin Renovar' --codoficina=4 and 
and atrasomaximo<=30  and codpromotor=@codpromotor--'GCC3012991'--
and cancelacion>='20180101' and cancelacion<dateadd(day,-1,@fecini)--'20190401'
group by case when datediff(day,cancelacion,@fecfin)>=0 and datediff(day,cancelacion,@fecfin)<=90 then '31-90'
		when datediff(day,cancelacion,@fecfin)>=91 and datediff(day,cancelacion,@fecfin)<=120 then '91-120'
		when datediff(day,cancelacion,@fecfin)>=121 and datediff(day,cancelacion,@fecfin)<=180 then '121-180'
		when datediff(day,cancelacion,@fecfin)>=181 then '181+'
		else 'XX' end

set @ure_nro_31=0
set @ure_nro_91=0
set @ure_nro_121=0
set @ure_nro_181=0
set @ure_monto_31=0
set @ure_monto_91=0
set @ure_monto_121=0
set @ure_monto_181=0

select @ure_nro_31=isnull(nro,0),@ure_monto_31=isnull(monto,0) from @uni_re where dias='31-90'
select @ure_nro_91=isnull(nro,0),@ure_monto_91=isnull(monto,0) from @uni_re where dias='91-120'
select @ure_nro_121=isnull(nro,0),@ure_monto_121=isnull(monto,0) from @uni_re where dias='121-180'
select @ure_nro_181=isnull(nro,0),@ure_monto_181=isnull(monto,0) from @uni_re where dias='181+'

create table #cobef(nro int,monto money)
insert into #cobef
exec pXaCACobranzaEfectivaCartaPromotor @fecini,@fecfin,@codpromotor
--exec pXaCACobranzaEfectivaCartaPromotor '20190501','20190505','GCC3012991'
declare @cob_ef_nro int
declare @cob_ef_monto int
set @cob_ef_nro=0
set @cob_ef_monto=0

select @cob_ef_nro=nro,@cob_ef_monto=monto from #cobef

declare @cob_progra money
set @cob_progra=0

declare @cob_progra_dia money
set @cob_progra_dia=0

declare @diasiguiente smalldatetime
set @diasiguiente=@fecfin+1
exec pXaCACobranzaPrograCartaPromotor @diasiguiente,@ultimodia,@codpromotor, @cob_progra out

exec pXaCACobranzaPrograCartaPromotor @diasiguiente,@diasiguiente,@codpromotor, @cob_progra_dia out

--exec pXaCACobranzaPrograCartaPromotor '20190401','20190430','GCC3012991',@cob_progra
--select @cob_progra

select sucursal,promotor,@nivel nivel,@meta_saldo metasaldo
--cartera inicial
,ini_nro,ini_monto,ini_venc_nro,ini_venc_monto
--, (case when ini_monto+isnull(ini_venc_monto,0)=0 then 0 else isnull(ini_venc_monto,0)/(ini_monto+isnull(ini_venc_monto,0)) end)*100 Ini_Imor30_Monto
,isnull(ini_mora16,0) Ini_Imor30_Monto
, (case when ini_nro+ini_venc_nro=0 then 0 else ini_venc_nro/(ini_nro+ini_venc_nro) end)*100 Ini_Imor30_Nro
----cartera hoy
,fin_nro,fin_monto,fin_venc_nro,fin_venc_monto
--, (case when fin_monto+isnull(fin_venc_monto,0)=0 then 0 else isnull(fin_venc_monto,0)/(fin_monto+isnull(fin_venc_monto,0)) end)*100 Fin_Imor30_Monto
,isnull(fin_mora16,0) Fin_Imor30_Monto
, (case when fin_nro+fin_venc_nro=0 then 0 else fin_venc_nro/(fin_nro+fin_venc_nro) end)*100 Fin_Imor30_Nro
--asignacion o retiros de cartera
,asi_nro_asi,asi_monto_asi,qui_nro_qui,qui_monto_qui 
--CRECIMIENTO PROPIO VIGENTE
,fin_monto-ini_monto-asi_monto_asi+qui_monto_qui cre_vig,(case when ini_monto=0 then 0 else (fin_monto-ini_monto-asi_monto_asi+qui_monto_qui)/ini_monto end )*100 cre_vig_por
--VALOR TABLERO
,dbo.dfuCACartaTableroBono(fin_nro,fin_venc_nro) valortablero
--Colocacion
,@co_reno_monto co_reno_monto,@co_reno_nro co_reno_nro
,@co_reac_monto co_reac_monto,@co_reac_nro co_reac_nro
,@co_nuev_monto co_nuev_monto,@co_nuev_nro co_nuev_nro
--Renovaciones
,@reno_monto reno_monto,@reno_nro reno_nro
,(case when @reno_monto=0 then 0 else cast(@co_reno_monto as decimal(16,2))/@reno_monto end)*100 RenoPor_Monto
,(case when cast(@reno_nro as decimal(16,2))=0 then 0 else cast(@co_reno_nro as decimal(16,2))/cast(@reno_nro as decimal(16,2)) end)*100 RenoPor_Nro
,(case when @reno_monto=0 then 0 else cast((@co_reno_monto+@co_reac_monto) as decimal(16,2))/@reno_monto end)*100 RenoReacPor_Monto
,(case when cast(@reno_nro as decimal(16,2))=0 then 0 else (cast(@co_reno_nro+@co_reac_nro as decimal(16,2)))/cast(@reno_nro as decimal(16,2)) end)*100 RenoReacPor_Nro
----Universo
,@ure_monto_31 ure_monto_31,@ure_nro_31 ure_nro_31
,@ure_monto_91 ure_monto_91,@ure_nro_91 ure_nro_91
,@ure_monto_121 ure_monto_121,@ure_nro_121 ure_nro_121
,@ure_monto_181 ure_monto_181,@ure_nro_181 ure_nro_181
,@ure_monto_31+@ure_monto_91+@ure_monto_121+@ure_monto_181 ure_monto
,@ure_nro_31+@ure_nro_91+@ure_nro_121+@ure_nro_181 ure_nro

----Cobranza
,isnull(@cob_ef_monto,0) cob_ef_monto
,isnull(@cob_progra,0)*1.15 cob_programada
,isnull(@cob_progra_dia,0)*1.15 cob_progra_dia
----select *
from tCsACrecimientoPromotor with(nolock) --where codoficina=4
where codpromotor=@codpromotor --'GCC3012991'

drop table #co
drop table #cobef
GO