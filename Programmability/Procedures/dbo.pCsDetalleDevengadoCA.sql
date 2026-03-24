SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsDetalleDevengadoCA] @fecini smalldatetime,@fecfin smalldatetime
as
	--drop table #tca
	create table #tca(
		codprestamo varchar(25),
		prestamoid varchar(25),
		codserviciop varchar(25)
	)
	insert into #tca (codprestamo,prestamoid,codserviciop)
	select codprestamo,codanterior,codserviciop
	from [10.0.2.14].finmas.dbo.tcaprestamos --where codoficina>100
	where cast(codoficina as int)>100 and cast(codoficina as int)<300
	and codoficina not in('97','230','231')
	
	select 'Devengado' Tipo
	,case when cast(c.codoficina as int)>=100 and cast(c.codoficina as int)<=300 then (cast(c.codoficina as int) + 200) else c.codoficina end codoficina
	,sum(cd.interesdevengado) interesdevengado
	,sum(case when c.codfondo<>'20' then
			case when c.codproducto in ('169','170') and substring(c.codprestamo,5,1)<>'3' then cd.interesdevengado else 0 end
			else 0 end) carteraFAProductivo
	,sum(case when c.codfondo<>'20' then
			case when substring(c.codprestamo,5,1)='3' then cd.interesdevengado else 0 end
			else 0 end) carteraFAConsumo
	,sum(case when c.codfondo<>'20' then
			case when c.codproducto not in ('169','170') and substring(c.codprestamo,5,1)<>'3' then cd.interesdevengado else 0 end
			else 0 end) carteraFALegado
	,sum(case when c.codfondo='20' then cd.interesdevengado*0.3
			else 0 end) carteraProgresemos
	,sum(case when c.codfondo='20' then cd.interesdevengado*0.7
			else 0 end) carteraProgresemos70
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	where c.cartera='ACTIVA' 
	and (c.fecha>=@fecini
	and c.fecha<=@fecfin
	)
	and c.estado='VIGENTE'
	and c.codoficina not in('97','230','231')
	and c.codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
	group by case when cast(c.codoficina as int)>=100 and cast(c.codoficina as int)<=300 then (cast(c.codoficina as int) + 200) else c.codoficina end

	drop table #tca
GO

GRANT EXECUTE ON [dbo].[pCsDetalleDevengadoCA] TO [marista]
GO