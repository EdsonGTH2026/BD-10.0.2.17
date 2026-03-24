SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[pCsConsultaMovDivContableCtas211] @fecini smalldatetime,@fecfin smalldatetime  
as    
set nocount on    

--declare @fecini smalldatetime
--declare @fecfin smalldatetime

--set @fecini='20240901'
--set @fecfin='20240930'

declare @ctas table (codigocuenta varchar(40),fraccioncta int ,renovado int ,CuentaDivContable varchar(40),Depositos money ,Retiros money)
insert into @ctas
select t.codigocuenta,fraccioncta,1,t.codigocuenta+'-' + t.fraccioncta+'-' + '1' as 'CuentaDivContable'
,sum(case when tipotransacnivel1='I' then montototaltran else 0 end) 'Depositos'
,sum(case when tipotransacnivel1='E' then montototaltran else 0 end) 'Retiros'
--select *
--into @ctas
from tcstransacciondiaria t with(nolock)
where t.fecha>=@fecini--'20240901' 
and t.fecha<=@fecfin--'20240930'
and t.codsistema='AH' and t.extornado=0 and t.montototaltran<>0
and t.tipotransacnivel3 not in(9,10,11,12,15,16,62)
and t.CodProducto=111
and t.DescripcionTran like '%GARA%'
--and t.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
group by t.codigocuenta,fraccioncta,renovado
UNION
select t.codigocuenta,fraccioncta,renovado,t.codigocuenta+'-' + t.fraccioncta+'-' + '0' as 'CuentaDivContable'
,sum(case when tipotransacnivel1='I' then montototaltran else 0 end) 'Depositos'
,sum(case when tipotransacnivel1='E' then montototaltran else 0 end) 'Retiros'
--select *
from tcstransacciondiaria t with(nolock)
where t.fecha>=@fecini--'20240901' 
and t.fecha<=@fecfin--'20240930'
and t.codsistema='AH' and t.extornado=0 and t.montototaltran<>0
and t.tipotransacnivel3 not in(9,10,11,12,15,16,62)
and t.CodProducto=111
and t.DescripcionTran not like  '%GARA%'
--and t.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
group by t.codigocuenta,fraccioncta,renovado


--------------------Temporales

---FECHA DEL PRIMER DEPOSITO
declare @fpd table (codigocuenta varchar(40),fraccioncta int ,renovado int 
,fechapd smalldatetime)
insert into @fpd

select codigocuenta,fraccioncta,renovado--,t.codigocuenta+'-' + t.fraccioncta+'-' + '1' as 'CuentaDivContable'
,min(fecha) fechapd
--into @fpd
from tcstransacciondiaria t with(nolock)
where codsistema='AH' and tipotransacnivel1='I' and extornado=0
and t.CodProducto=111
--and t.DescripcionTran not like  '%GARA%'
--and t.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
group by codigocuenta,fraccioncta,renovado


--MONTO DEL PRIMER DEPOSITO 
declare @mpd table (codigocuenta varchar(40),fraccioncta int ,renovado int ,fecha smalldatetime
,CuentaDivContable varchar(40),montompd money )
insert into @mpd

----- PERTENECE A UN MOVIMIENTO DE GARANTIA
select T.codigocuenta,T.fraccioncta,1,T.fecha,t.codigocuenta+'-' + t.fraccioncta+'-' + '1' as 'CuentaDivContable'
,sum(montototaltran) montompd
--INTO @mpd
from tcstransacciondiaria T with(nolock)
INNER JOIN @fpd FPD ON FPD.CODIGOCUENTA=T.CODIGOCUENTA AND FPD.RENOVADO=T.Renovado AND T.Fecha=FPD.fechapd
where codsistema='AH' and tipotransacnivel1='I' and extornado=0
and t.DescripcionTran  like  '%GARA%'
--and T.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
and t.CodProducto=111
group by T.codigocuenta,T.fraccioncta,T.renovado,T.fecha
--UNION--
--- PERTENECE A UN MOVIMIENTO DE AHORRO
INSERT INTO @mpd
select T.codigocuenta,T.fraccioncta,T.renovado,T.fecha,t.codigocuenta+'-' + t.fraccioncta+'-' + '0' as 'CuentaDivContable'
,sum(montototaltran) montompd
from tcstransacciondiaria T with(nolock)
INNER JOIN @fpd FPD ON FPD.CODIGOCUENTA=T.CODIGOCUENTA AND FPD.RENOVADO=T.Renovado AND T.Fecha=FPD.fechapd
where codsistema='AH' and tipotransacnivel1='I' and extornado=0
and t.CodProducto=111
and t.DescripcionTran NOT like  '%GARA%'
--and T.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
group by T.codigocuenta,T.fraccioncta,T.renovado,T.fecha



---FECHA DE ULTIMO PAGO ** DE FORMA GENERAL
select codigocuenta,fraccioncta,renovado,max(cast(rtrim(dbo.fdufechaatexto(fecha,'AAAAMMDD')+' '+tranhora+':'+tranminuto+':'+transegundo) as datetime)) fulpagocli--,min(fecha) fechapd
,max(fecha) feculdep
INTO #fup
from tcstransacciondiaria T with(nolock)
where codsistema='AH' and extornado=0--and tipotransacnivel1='I' 
and t.CodProducto='111'
--and codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
and tipotransacnivel3 in(1,2,3,4,14,18,19,27,28)
and fecha<=@fecfin
group by codigocuenta,fraccioncta,renovado



---MONTO DEL ULTIMO PAGO


declare @mup table (codigocuenta varchar(40),fraccioncta int ,renovado int ,fecha smalldatetime
,CuentaDivContable varchar(40),monto money )
insert into @mup

------------- CORRESPONDE A EL ULTIMO MONTO A GARANTIAS
select --top 1 
T.codigocuenta,T.fraccioncta,1,T.fecha,t.codigocuenta+'-' + t.fraccioncta+'-' + '1' as 'CuentaDivContable'
,sum(montototaltran) monto
--INTO @mup
from tcstransacciondiaria T with(nolock)
INNER JOIN #fup fup ON fup.CODIGOCUENTA=T.CODIGOCUENTA AND fup.RENOVADO=T.Renovado AND T.Fecha=fup.feculdep
where T.codsistema='AH' and T.extornado=0--and tipotransacnivel1='I' 
and t.CodProducto='111'
--and T.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
and t.DescripcionTran  like  '%GARA%'
and tipotransacnivel3 in(1,2,3,4,14,18,19,27,28)
group by T.codigocuenta,T.fraccioncta,T.renovado,T.fecha--,tranhora,tranminuto
--UNION
INSERT INTO @mup
select --top 1 
T.codigocuenta,T.fraccioncta,T.renovado,T.fecha,t.codigocuenta+'-' + t.fraccioncta+'-' + '0' as 'CuentaDivContable'
,sum(montototaltran) monto
from tcstransacciondiaria T with(nolock)
INNER JOIN #fup fup ON fup.CODIGOCUENTA=T.CODIGOCUENTA AND fup.RENOVADO=T.Renovado AND T.Fecha=fup.feculdep
where T.codsistema='AH' and T.extornado=0--and tipotransacnivel1='I' 
and t.CodProducto='111'
--and T.codigocuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')
and t.DescripcionTran NOT like  '%GARA%'
and tipotransacnivel3 in(1,2,3,4,14,18,19,27,28)
group by T.codigocuenta,T.fraccioncta,T.renovado,T.fecha--,tranhora,tranminuto

--SELECT *
--FROM tCsAhorros A WITH(NOLOCK)
--LEFT OUTER JOIN @ctas C ON C.codigocuenta=a.CodCuenta and c.renovado=a.Renovado
--WHERE CodProducto=111
--AND Fecha='20240930'---@fecfin--
--and a.CodCuenta in(
--	'003-111-06-2-0-01491',
--	'016-105-06-2-2-02044',
--	'025-111-06-2-6-00044',
--	'098-211-06-2-8-00629')--CuentaDivContable

--select * 
--from @fpd fpd with(nolock)
--left outer join @ctas ctas with(nolock) ON ctas.codigocuenta=fpd.codigocuenta and ctas.renovado=fpd.Renovado
--left outer join @mpd mpd with(nolock) ON mpd.codigocuenta=fpd.codigocuenta and mpd.renovado=fpd.Renovado

------------------------------- Movimientos de ajuste - entre cuentas 
declare @TxInterno table (CodCuenta varchar(40),fraccioncta int ,renovado int ,NumContrato varchar(40),Depositos money ,Retiros money)
insert into @TxInterno
select CodCuenta,fraccioncta,renovado,NumContrato 
,sum(case when tipotransacnivel1='I' then montototaltran else 0 end) 'Depositos'
,sum(case when tipotransacnivel1='E' then montototaltran else 0 end) 'Retiros'
from FNMGConsolidado.dbo.tCsTransaccionR841 WITH(NOLOCK)
WHERE Fecha=@fecfin--'20240930'--
and TipoTransacNivel3 in (3,4)
and Extornado=0
group by CodCuenta,fraccioncta,renovado,NumContrato
------------------------------------------------

select x.codigoCuenta,x.fraccionCta,x.renovado,x.CuentaDivContable,
SUM(x.Depositos)Depositos,
SUM(x.Retiros)Retiros,
max(x.FechaPrimerDeposito)FechaPrimerDeposito,
SUM(x.MontoPrimerDep)MontoPrimerDep,
max(x.FechaUltimoMovi)FechaUltimoMovi,
SUM(x.MontoUltimoMov)MontoUltimoMov
into #base
from (
select ctas.codigoCuenta,ctas.fraccionCta,ctas.renovado,ctas.CuentaDivContable,ctas.Depositos,ctas.Retiros,
 '' FechaPrimerDeposito,0 MontoPrimerDep,
 '' FechaUltimoMovi, 0 MontoUltimoMov
 from @ctas ctas --with(nolock) 
 union
 select mpd.codigoCuenta,mpd.fraccionCta,mpd.renovado,mpd.CuentaDivContable,0 Depositos,0 Retiros,
 Fecha FechaPrimerDeposito,montompd MontoPrimerDep,
  '' FechaUltimoMovi, 0 MontoUltimoMov
 from @mpd mpd --with(nolock)
 union
 select mup.codigoCuenta,mup.fraccionCta,mup.renovado,mup.CuentaDivContable,0 Depositos,0 Retiros,
 '' FechaPrimerDeposito,0 MontoPrimerDep,
 fecha FechaUltimoMovi, Monto MontoUltimoMov
 from @mup mup-- with(nolock)
 union all
 select tx.CodCuenta codigoCuenta,tx.fraccionCta,tx.renovado,tx.NumContrato CuentaDivContable,tx.Depositos,tx.Retiros,
 '' FechaPrimerDeposito,0 MontoPrimerDep,
 '' FechaUltimoMovi, 0 MontoUltimoMov
 from @TxInterno tx-- with(nolock)
 )x 
group by x.codigoCuenta,x.fraccionCta,x.renovado,x.CuentaDivContable--,FechaPrimerDeposito,FechaUltimoMovi


select * from #base
--where codigoCuenta='333-111-06-2-9-00709'


drop table #base
--drop table  @ctas
--drop table  @fpd 
--drop table  @mpd 
drop table  #fup 
--drop table  @mup
GO