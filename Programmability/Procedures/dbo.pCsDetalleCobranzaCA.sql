SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsDetalleCobranzaCA] @fecini2 smalldatetime,@fecfin2 smalldatetime
as
declare @fecfin smalldatetime
declare @fecini smalldatetime
--set @fecfin='20170630'
--set @fecini='20170601'
set @fecfin=@fecfin2
set @fecini=@fecini2

----drop table #tca
create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop
from [10.0.2.14].finmas.dbo.tcaprestamos --where codoficina>100
where cast(codoficina as int)>100 and cast(codoficina as int)<300

select --'Cob_Capital' tipo,
case when cast(t.codoficinacuenta as int)>=100 and cast(t.codoficinacuenta as int)<=300 then (cast(t.codoficinacuenta as int) + 200) else t.codoficinacuenta end codoficina
,isnull(c.estado,cx.estado) estado
,sum(t.montocapitaltran) capi
,sum(t.montointerestran) inte
,sum(t.montoinpetran) intmora
,sum(t.montocargos) carmora
,sum(t.montootrostran) otros
,sum(t.montoimpuestos) impuestos
,sum(t.montototaltran) total
,sum(case when isnull(c.codfondo,cx.codfondo)<>'20' then
			case when isnull(c.codproducto,cx.codproducto) in ('169','170') and substring(isnull(c.codprestamo,cx.codprestamo),5,1)<>'3' then t.montocapitaltran else 0 end
		  else 0 end) carteraFAProductivo_CAPI
,sum(case when isnull(c.codfondo,cx.codfondo)<>'20' then
		case when substring(isnull(c.codprestamo,cx.codprestamo),5,1)='3' then t.montocapitaltran else 0 end
		else 0 end) carteraFAConsumo_CAPI
,sum(case when isnull(c.codfondo,cx.codfondo)<>'20' then
		case when isnull(c.codproducto,cx.codproducto) not in ('169','170') and substring(isnull(c.codprestamo,cx.codprestamo),5,1)<>'3' then t.montocapitaltran else 0 end
		else 0 end) carteraFALegado_CAPI
,sum(case when isnull(c.codfondo,cx.codfondo)='20' then t.montocapitaltran*0.3 else 0 end) carteraProgresemos_CAPI
,sum(case when isnull(c.codfondo,cx.codfondo)='20' then t.montocapitaltran*0.7 else 0 end) carteraProgresemos_CAPI70

,sum(case when isnull(c.codfondo,cx.codfondo)<>'20' then
			case when isnull(c.codproducto,cx.codproducto) in ('169','170') and substring(isnull(c.codprestamo,cx.codprestamo),5,1)<>'3' then t.montointerestran+t.montoinpetran else 0 end
		  else 0 end) carteraFAProductivo_INTE
,sum(case when isnull(c.codfondo,cx.codfondo)<>'20' then
		case when substring(isnull(c.codprestamo,cx.codprestamo),5,1)='3' then t.montointerestran+t.montoinpetran else 0 end
		else 0 end) carteraFAConsumo_INTE
,sum(case when isnull(c.codfondo,cx.codfondo)<>'20' then
		case when isnull(c.codproducto,cx.codproducto) not in ('169','170') and substring(isnull(c.codprestamo,cx.codprestamo),5,1)<>'3' then t.montointerestran+t.montoinpetran else 0 end
		else 0 end) carteraFALegado_INTE
,sum(case when isnull(c.codfondo,cx.codfondo)='20' then (t.montointerestran+t.montoinpetran)*0.3 else 0 end) carteraProgresemos_INTE
,sum(case when isnull(c.codfondo,cx.codfondo)='20' then (t.montointerestran+t.montoinpetran)*0.7 else 0 end) carteraProgresemos_INTE70

from tcstransacciondiaria t with(nolock)
left outer join tcscartera c with(nolock) on t.codigocuenta=c.codprestamo and (t.fecha-1)=c.fecha
left outer join (select pd.codprestamo,p.codfondo,p.estado,p.codproducto
				 from tcspadroncarteradet pd with(nolock) 
				 inner join tcscartera p with(nolock) on pd.codprestamo=p.codprestamo and pd.fechacorte=p.fecha
				 group by pd.codprestamo, p.codfondo,p.estado,p.codproducto
) cx on t.codigocuenta=cx.codprestamo
where t.codsistema='CA' and t.fecha>=@fecini and t.fecha<=@fecfin
and t.codoficinacuenta not in('97','230','231')
and t.codigocuenta not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
and t.tipotransacnivel1='I'
and t.tipotransacnivel3<>0
and t.extornado=0
--and t.codoficinacuenta='3'
group by case when cast(t.codoficinacuenta as int)>=100 and cast(t.codoficinacuenta as int)<=300 then (cast(t.codoficinacuenta as int) + 200) else t.codoficinacuenta end
,isnull(c.estado,cx.estado)

drop table #tca

GO

GRANT EXECUTE ON [dbo].[pCsDetalleCobranzaCA] TO [marista]
GO