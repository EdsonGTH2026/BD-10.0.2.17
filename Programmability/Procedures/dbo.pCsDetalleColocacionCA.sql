SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsDetalleColocacionCA] @fecini smalldatetime,@fecfin smalldatetime
as
select 'Colocacion' Tipo
,c.codoficina,'VIGENTE' Estado
,sum(pc.monto) monto
,sum(case when c.codfondo<>'20' then
		case when c.codproducto in ('169','170') and substring(c.codprestamo,5,1)<>'3' then pc.monto else 0 end
		else 0 end) carteraFAProductivo
,sum(case when c.codfondo<>'20' then
		case when substring(c.codprestamo,5,1)='3' then pc.monto else 0 end
		else 0 end) carteraFAConsumo
,sum(case when c.codfondo<>'20' then
		case when c.codproducto not in ('169','170') and substring(c.codprestamo,5,1)<>'3' then pc.monto else 0 end
		else 0 end) carteraFALegado
,sum(case when c.codfondo='20' then pc.monto*0.3
		else 0 end) carteraProgresemos
,sum(case when c.codfondo='20' then pc.monto*0.7
		else 0 end) carteraProgresemos70
FROM tcspadroncarteradet pc
inner join tCsCartera c with(nolock) on pc.desembolso=c.fecha and pc.codprestamo=c.codprestamo	
where c.cartera='ACTIVA' and pc.desembolso>=@fecini
and pc.desembolso<=@fecfin
--and c.codprestamo in (select codprestamo from #ptmos)
and c.codoficina<>'97'
group by c.codoficina
GO

GRANT EXECUTE ON [dbo].[pCsDetalleColocacionCA] TO [marista]
GO