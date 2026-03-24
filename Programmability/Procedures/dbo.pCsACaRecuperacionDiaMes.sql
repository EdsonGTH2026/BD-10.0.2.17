SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaRecuperacionDiaMes] @fecfin smalldatetime
as
declare @fecini smalldatetime
--declare @fecfin smalldatetime
set @fecini='20170101'
--set @fecfin='20180829'

create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop
from [10.0.2.14].finmas.dbo.tcaprestamos --where codoficina>100
where cast(codoficina as int)>100 and cast(codoficina as int)<300
and codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9')

select dbo.fdufechaaperiodo(t.fecha) periodo
,sum(montocapitaltran) capital
,sum(case when day(t.fecha)>=1 and day(t.fecha)<=5 then montocapitaltran else 0 end) rec_1a5
,(sum(case when day(t.fecha)>=1 and day(t.fecha)<=5 then montocapitaltran else 0 end)/sum(montocapitaltran))*100 por_1a5
,sum(case when day(t.fecha)>=6 and day(t.fecha)<=10 then montocapitaltran else 0 end) rec_6a10
,(sum(case when day(t.fecha)>=6 and day(t.fecha)<=10 then montocapitaltran else 0 end)/sum(montocapitaltran))*100 por_6a10
,sum(case when day(t.fecha)>=11 and day(t.fecha)<=15 then montocapitaltran else 0 end) rec_11a15
,(sum(case when day(t.fecha)>=11 and day(t.fecha)<=15 then montocapitaltran else 0 end)/sum(montocapitaltran))*100 por_11a15
,sum(case when day(t.fecha)>=16 and day(t.fecha)<=20 then montocapitaltran else 0 end) rec_16a20
,(sum(case when day(t.fecha)>=16 and day(t.fecha)<=20 then montocapitaltran else 0 end)/sum(montocapitaltran))*100 por_16a20
,sum(case when day(t.fecha)>=21 and day(t.fecha)<=25 then montocapitaltran else 0 end) rec_21a25
,(sum(case when day(t.fecha)>=21 and day(t.fecha)<=25 then montocapitaltran else 0 end)/sum(montocapitaltran))*100 por_21a25
,sum(case when day(t.fecha)>=26 and day(t.fecha)<=31 then montocapitaltran else 0 end) rec_26a31
,(sum(case when day(t.fecha)>=26 and day(t.fecha)<=31 then montocapitaltran else 0 end)/sum(montocapitaltran))*100 por_26a31
from tcstransacciondiaria t with(nolock)
--inner join (select codprestamo, desembolso from tcspadroncarteradet with(nolock) group by codprestamo, desembolso) p on p.codprestamo=t.codigocuenta
where t.fecha>=@fecini and t.fecha<=@fecfin and t.montocapitaltran<>0
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codoficina<>'97'
and t.codigocuenta not in(select codprestamo from #tca)
group by dbo.fdufechaaperiodo(t.fecha)
order by dbo.fdufechaaperiodo(t.fecha)
--periodo	capital
--201801	32765841.54
--201802	28785121.59
--201803	30793552.01
--201805	32818913.15
--201804	32449479.27
--201806	31792374.79

drop table #tca

GO

GRANT EXECUTE ON [dbo].[pCsACaRecuperacionDiaMes] TO [marista]
GO