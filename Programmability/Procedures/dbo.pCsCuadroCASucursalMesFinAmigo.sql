SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----exec pCsCuadroCASucursalMesFinAmigo '20170828'
--drop procedure pCsCuadroCASucursalMesFinAmigo
CREATE procedure [dbo].[pCsCuadroCASucursalMesFinAmigo] @fecfin datetime
as
--declare @fecfin datetime
--set @fecfin='20171130'
declare @fecini datetime
set @fecini= dbo.fdufechaaperiodo(@fecfin)+'01'

declare @fecfin_a datetime
set @fecfin_a = dateadd(day,-1,@fecini)

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
--drop table #cuadro
create table #cuadro(
	codoficina varchar(3),
	sucursal varchar(30),
	scapitalini money default(0),
	sinteresvigini money default(0),
	sinteresvigfin money default(0),
	sctaorden money default(0),
	recucapital money default(0),
	colocacion money default(0),
	scapitalfin money default(0),
	ingint money default(0),
	ingrealint money default(0),
	ingmoratorio money default(0),
	ingseguros money default(0),

	scapitalvenini money default(0),
	scapitalvenfin money default(0),
	sinteresvenini money default(0),
	sinteresvenfin money default(0),

	smoratoriovigini money default(0),
	smoratoriovenini money default(0),
	smoratoriovigfin money default(0),
	smoratoriovenfin money default(0)
)
insert into #cuadro (codoficina,sucursal)
select codoficina,nomoficina
from tcloficinas
where codoficina not in ('230','231','97','98','99')
and (cast(codoficina as int)<100 or cast(codoficina as int)>300)
union
select codoficina,nomoficina
from tcloficinas
where codoficina=150

update #cuadro
set scapitalini=saldocapital,sinteresvigini=interes,smoratoriovigini=moratorio
from #cuadro a
inner join (
	select 
		case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end codoficina
	,sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end)+sum(case when c.codfondo='20' then cd.saldocapital*0.3 else 0 end) saldocapital
	,sum(case when c.codfondo<>'20' then (cd.interesvigente+cd.interesvencido) else 0 end)+sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) interes
	,sum(cd.moratoriovigente) + sum(cd.moratoriovencido) moratorio
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	where c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
	and c.codoficina<>'97' and c.estado<>'VENCIDO'
	and c.codprestamo not in (select codprestamo from #tca)
	group by --case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end
		case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end
) b on a.codoficina=b.codoficina

update #cuadro
set scapitalvenini=saldocapital,sinteresvenini=interes,smoratoriovenini=moratorio
from #cuadro a
inner join (
	select 
		case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end codoficina
	,sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end)+sum(case when c.codfondo='20' then cd.saldocapital*0.3 else 0 end) saldocapital
	,sum(case when c.codfondo<>'20' then (cd.interesvigente+cd.interesvencido) else 0 end)+sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) interes
	,sum(cd.moratoriovigente) + sum(cd.moratoriovencido) moratorio
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	where c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
	and c.codoficina<>'97' and c.estado='VENCIDO'
	and c.codprestamo not in (select codprestamo from #tca)
	group by --case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end
		case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end
) b on a.codoficina=b.codoficina

update #cuadro
set scapitalfin=saldocapital,sinteresvigfin=interes,sctaorden=ctaorden,smoratoriovigfin=moratorio
from #cuadro a
inner join (
	select --case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end codoficina
	case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end codoficina
	,sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end)+sum(case when c.codfondo='20' then cd.saldocapital*0.3 else 0 end) saldocapital
	,sum(case when c.codfondo<>'20' then (cd.interesvigente+cd.interesvencido) else 0 end)+sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) interes
	,sum(case when c.codfondo<>'20' then cd.interesctaorden else 0 end)+sum(case when c.codfondo='20' then cd.interesctaorden*0.3 else 0 end) ctaorden
	,sum(cd.moratoriovigente) + sum(cd.moratoriovencido) moratorio
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	where c.cartera='ACTIVA' and c.fecha=@fecfin--'20161231' --
	and c.codoficina<>'97' and c.estado<>'VENCIDO'
	and c.codprestamo not in (select codprestamo from #tca)
	group by --case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end
		case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end
) b on a.codoficina=b.codoficina

update #cuadro
set scapitalvenfin=saldocapital,sinteresvenfin=interes,smoratoriovenfin=moratorio
from #cuadro a
inner join (
	select --case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end codoficina
	case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end codoficina
	,sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end)+sum(case when c.codfondo='20' then cd.saldocapital*0.3 else 0 end) saldocapital
	,sum(case when c.codfondo<>'20' then (cd.interesvigente+cd.interesvencido) else 0 end)+sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) interes
	,sum(case when c.codfondo<>'20' then cd.interesctaorden else 0 end)+sum(case when c.codfondo='20' then cd.interesctaorden*0.3 else 0 end) ctaorden
	,sum(cd.moratoriovigente) + sum(cd.moratoriovencido) moratorio
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	where c.cartera='ACTIVA' and c.fecha=@fecfin--'20161231' --
	and c.codoficina<>'97' and c.estado='VENCIDO'
	and c.codprestamo not in (select codprestamo from #tca)
	group by --case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end
		case when c.codoficina='150' then c.codoficina
			 when c.codoficina='131' then '37'
			 else 
				(case when (cast(c.codoficina as int)<100 or cast(c.codoficina as int)>300) then c.codoficina else cast((cast(c.codoficina as int)+200) as varchar(4)) end) 
		 end
) b on a.codoficina=b.codoficina

/*recuperacion capital*/
--select @m1=sum(case when c.codfondo<>'20' then t.montocapitaltran else 0 end) 
--+ sum(case when c.codfondo='20' then t.montocapitaltran*0.3 else 0 end) --capitalFinamigo
--,@m2=sum(case when c.codfondo='20' then t.montocapitaltran*0.7 else 0 end) --capitalProgresemos
update #cuadro
set recucapital=capital,ingrealint=interes
from #cuadro a
inner join (
	select --case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end codoficina
	case when codoficinacuenta='150' then codoficinacuenta
			 when codoficinacuenta='131' then '37'
			 else 
				(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
		 end codoficina
	--,sum(t.montocapitaltran) capital
	,sum(case when c.codfondo<>'20' then t.montocapitaltran else 0 end) + sum(case when c.codfondo='20' then t.montocapitaltran*0.3 else 0 end) capital
	--,sum(montointerestran) interes
	,sum(case when c.codfondo<>'20' then t.montointerestran else 0 end) + sum(case when c.codfondo='20' then t.montointerestran*0.3 else 0 end) interes
	from tcstransacciondiaria t with(nolock)
	inner join (select codprestamo, fechacorte 
				from tcspadroncarteradet with(nolock)
				group by codprestamo, fechacorte
				) p on p.codprestamo=t.codigocuenta
	inner join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=p.fechacorte
	where t.fecha>=@fecini and t.fecha<=@fecfin--'20170813'
	and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
	and t.codigocuenta not in(select codprestamo from #tca)
	group by --case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end
		case when codoficinacuenta='150' then codoficinacuenta
			 when codoficinacuenta='131' then '37'
			 else 
				(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
		 end
) b on a.codoficina=b.codoficina

/*COLOCACION*/
--select @m1=sum(case when c.codfondo<>'20' then pc.monto else 0 end) 
--+ sum(case when c.codfondo='20' then pc.monto*0.3 else 0 end) --capitalFinamigo
--,@m2=sum(case when c.codfondo='20' then pc.monto*0.7 else 0 end) --capitalProgresemos
update #cuadro
set colocacion=monto
from #cuadro a
inner join (
	select pc.codoficina--,sum(pc.monto) monto
	,sum(case when c.codfondo<>'20' then pc.monto else 0 end) + sum(case when c.codfondo='20' then pc.monto*0.3 else 0 end) monto
	FROM tcspadroncarteradet pc
	inner join tCsCartera c with(nolock) on pc.desembolso=c.fecha and pc.codprestamo=c.codprestamo	
	where c.cartera='ACTIVA' and pc.desembolso>=@fecini--'20170101' --
	and pc.desembolso<=@fecfin--'20170131' --
	and c.codoficina<>'97'
	and c.codprestamo not in (select codprestamo from #tca)
	group by pc.codoficina
) b on a.codoficina=b.codoficina

/*ingresos reales int mora seguros*/
update #cuadro
set ingmoratorio=moratorios,ingseguros=seguros -- se pago el interes cuando se obtiene el capital para calcular el fondo
from #cuadro a
inner join (
	select --case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end codoficina
		case when codoficinacuenta='150' then codoficinacuenta
			 when codoficinacuenta='131' then '37'
			 else 
				(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
		 end codoficina	
	,sum(montoinpetran+montocargos) moratorios
	,sum(MontoOtrosTran) seguros
	from tcstransacciondiaria t with(nolock)
	where t.fecha>=@fecini and t.fecha<=@fecfin
	and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
	and t.codoficina<>'97'
	and t.codigocuenta not in(select codprestamo from #tca)
	group by --case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end
		case when codoficinacuenta='150' then codoficinacuenta
			 when codoficinacuenta='131' then '37'
			 else 
				(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
		 end
) b on a.codoficina=b.codoficina

/*devengado*/
create table #c(fecha datetime,codprestamo varchar(25),codfondo int)
insert into #c
--declare @c table(fecha datetime,codprestamo varchar(25),codfondo int)
--insert into @c
select c.fecha,c.codprestamo,c.codfondo
FROM tCsCartera c with(nolock) 
where c.cartera='ACTIVA' 
and (c.fecha>=@fecini--'20170801'--
and c.fecha<=@fecfin--'20170828'--
)
and c.codoficina<>'97'
and c.estado='VIGENTE'
and c.codprestamo not in (select codprestamo from #tca)

--select codprestamo,interesdevengado
--select @m1=sum(case when c.codfondo<>'20' then d.interesdevengado else 0 end) 
--+ sum(case when c.codfondo='20' then d.interesdevengado*0.3 else 0 end) 
update #cuadro
set ingint=interesdevengado
from #cuadro a
inner join (
	select --case when (cast(d.codoficina as int)<100 or cast(d.codoficina as int)>300) then d.codoficina else cast((cast(d.codoficina as int)+200) as varchar(4)) end codoficina
	case when d.codoficina='150' then d.codoficina
			 when d.codoficina='131' then '37'
			 else 
				(case when (cast(d.codoficina as int)<100 or cast(d.codoficina as int)>300) then d.codoficina else cast((cast(d.codoficina as int)+200) as varchar(4)) end) 
		 end codoficina
	--,sum(d.interesdevengado) interesdevengado
	,sum(case when c.codfondo<>'20' then d.interesdevengado else 0 end) + sum(case when c.codfondo='20' then d.interesdevengado*0.3 else 0 end)  interesdevengado
	from tcscarteradet d with(nolock)
	inner join #c c on c.codprestamo=d.codprestamo and c.fecha=d.fecha
	where d.codprestamo in(select codprestamo from #c)
	and d.fecha>=@fecini--'20170807'--
	and d.fecha<=@fecfin--'20170813'--
	group by --case when (cast(d.codoficina as int)<100 or cast(d.codoficina as int)>300) then d.codoficina else cast((cast(d.codoficina as int)+200) as varchar(4)) end
		case when d.codoficina='150' then d.codoficina
			 when d.codoficina='131' then '37'
			 else 
				(case when (cast(d.codoficina as int)<100 or cast(d.codoficina as int)>300) then d.codoficina else cast((cast(d.codoficina as int)+200) as varchar(4)) end) 
		 end 
) b on a.codoficina=b.codoficina
drop table #c

--delete from #cuadro where scapitalini=0 and scapitalfin=0 and ingint=0

select * from #cuadro

drop table #cuadro
drop table #tca
GO

GRANT EXECUTE ON [dbo].[pCsCuadroCASucursalMesFinAmigo] TO [marista]
GO