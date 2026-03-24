SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsDetalleSaldosCA '20170630'
----drop procedure pCsDetalleSaldosCA
CREATE procedure [dbo].[pCsDetalleSaldosCA] @fecha2 smalldatetime
as
declare @fecha smalldatetime
--set @fecini='20170601'
set @fecha=@fecha2

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

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo from tcscartera with(nolock)
where fecha=@fecha and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))

/*SALDO CARTERA ANTERIOR*/
select --'SaldoAnterior' Tipo,
case when cast(c.codoficina as int)>=100 and cast(c.codoficina as int)<=300 then (cast(c.codoficina as int) + 200) else c.codoficina end codoficina,c.estado
,sum(cd.saldocapital) saldocapital
,sum(cd.interesvigente) interesvigente
,sum(cd.interesvencido) interesvencido
,sum(case when c.codfondo='20' then cd.interesvigente*0.3 else 0 end) interesvigenteProgre30
,sum(case when c.codfondo='20' then cd.interesvencido*0.3 else 0 end) interesvencidoProgre30
,sum(case when c.codfondo='20' then cd.interesvigente*0.7 else 0 end) interesvigenteProgre70
,sum(case when c.codfondo='20' then cd.interesvencido*0.7 else 0 end) interesvencidoProgre70
,sum(cd.moratoriovigente) moratoriovigente
,sum(cd.moratoriovencido) moratoriovencido
,sum(cd.impuestos) impuestos
,sum(cd.cargomora) cargoxmora
,sum(cd.otroscargos) otroscargos
,sum(case when c.codfondo<>'20' then
		case when c.codproducto in ('169','170') and substring(c.codprestamo,5,1)<>'3' then cd.saldocapital else 0 end
		else 0 end) carteraFAProductivo
,sum(case when c.codfondo<>'20' then
		case when substring(c.codprestamo,5,1)='3' then cd.saldocapital else 0 end
		else 0 end) carteraFAConsumo
,sum(case when c.codfondo<>'20' then
		case when c.codproducto not in ('169','170') and substring(c.codprestamo,5,1)<>'3' then cd.saldocapital else 0 end
		else 0 end) carteraFALegado
,sum(case when c.codfondo='20' then cd.saldocapital*0.3
		else 0 end) carteraProgresemos30
,sum(case when c.codfondo='20' then cd.saldocapital*0.7
		else 0 end) carteraProgresemos70
FROM tCsCartera c with(nolock) 
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
where c.fecha=@fecha
and c.codprestamo in (select codprestamo from #ptmos)
group by case when cast(c.codoficina as int)>=100 and cast(c.codoficina as int)<=300 then (cast(c.codoficina as int) + 200) else c.codoficina end,c.estado

drop table #tca
drop table #ptmos

GO

GRANT EXECUTE ON [dbo].[pCsDetalleSaldosCA] TO [marista]
GO