SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCaRptIngresosVsProgramado
CREATE procedure [dbo].[pCsCaRptIngresosVsProgramado] @periodo varchar(6)
as

--declare @periodo varchar(6)
--set @periodo ='201503'

create table #tmp(
	periodo varchar(6),
	nrosemana int,
	fechaini smalldatetime,
	fechafin smalldatetime,
	fecha smalldatetime,
	codprestamo varchar(25),
	capital decimal(16,2),
	interes decimal(16,2),
	interesIVA as cast(interes*0.16 as decimal(16,2)),
	moratorio decimal(16,2),
	moratorioIVA as cast(moratorio*0.16 as decimal(16,2)),
	otros decimal(16,2),
	cargoxmora decimal(16,2),
	cargoxmoraIVA decimal(16,2),
	pagoanticipado decimal(16,2),
	total decimal(16,2),
	producto varchar(150)
)

insert into #tmp (periodo,nrosemana,fechaini,fechafin,fecha, codprestamo,capital,interes,moratorio,otros,pagoanticipado,total,producto)
SELECT ps.periodo,ps.nrosemana,ps.fechaini,ps.fechafin,fecha,codigocuenta,MontoCapitalTran,MontoInteresTran,MontoINpeTran
,case when tipotransacnivel3<>101 then MontoOtrosTran else 0 end MontoOtrosTran
,case when tipotransacnivel3=101 then MontoOtrosTran else 0 end pagoanticipado
,MontoTotalTran
,case when pc.codproducto in('163','302') then 'Convenio Amigo' else rtrim(ltrim(pc.Nombreprod)) end producto
FROM tCsTransaccionDiaria t with(nolock)
left outer join tcspadroncarteraotroprod op on op.codprestamo=substring(t.codigocuenta,5,3)
inner join tcaproducto pc with(nolock) on pc.codproducto=(case when substring(t.codigocuenta,5,3) in ('157','158','159','160','161','162') then '166' 
                                                               else isnull(op.codproducto,substring(t.codigocuenta,5,3)) end)
inner join (select * from fduTablaSemanaPeriodosFC(@periodo)) ps on t.Fecha>=ps.fechaini and t.Fecha<=ps.fechafin
where --t.fecha>='20150101' and t.fecha<='20150131' and 
t.codsistema='CA' 
and t.extornado='0'
and t.tipotransacnivel1='I' --and tipotransacnivel3 not in (104,105)
and t.codoficina<>97

--update #tmp
--set fecha=x.fecha,codprestamo=x.codigocuenta,capital=x.MontoCapitalTran,interes=x.MontoInteresTran,moratorio=x.MontoINpeTran
--,otros=x.MontoOtrosTran,pagoanticipado=x.pagoanticipado,total=x.MontoTotalTran
--from #tmp s
--inner join (
--	SELECT ps.periodo,ps.nrosemana,ps.fechaini,ps.fechafin,fecha,codigocuenta,MontoCapitalTran,MontoInteresTran,MontoINpeTran
--	,case when tipotransacnivel3<>101 then MontoOtrosTran else 0 end MontoOtrosTran
--	,case when tipotransacnivel3=101 then MontoOtrosTran else 0 end pagoanticipado
--	,MontoTotalTran
--	,case when pc.codproducto in('163','302') then 'Convenio Amigo' else rtrim(ltrim(pc.Nombreprod)) end producto
--	FROM tCsTransaccionDiaria t with(nolock)
--	left outer join tcspadroncarteraotroprod op on op.codprestamo=substring(t.codigocuenta,5,3)
--	inner join tcaproducto pc with(nolock) on pc.codproducto=(case when substring(t.codigocuenta,5,3) in ('157','158','159','160','161','162') then '166' 
--																																 else isnull(op.codproducto,substring(t.codigocuenta,5,3)) end)
--	inner join (select * from fduTablaSemanaPeriodosFC(@periodo)) ps on t.Fecha>=ps.fechaini and t.Fecha<=ps.fechafin
--	where --t.fecha>='20150101' and t.fecha<='20150131' and 
--	t.codsistema='CA' 
--	and t.extornado='0'
--	and t.tipotransacnivel1='I' --and tipotransacnivel3 not in (104,105)
--	and t.codoficina<>97
--) x on s.periodo=x.periodo and s.nrosemana=x.nrosemana and s.fechaini=x.fechaini and s.fechafin=x.fechafin and s.Producto=x.Producto

--select * from #tmp

update #tmp
set cargoxmora=case when otros-interesiva-moratorioiva<0 then 0 else otros-interesiva-moratorioiva end

update #tmp
set cargoxmora=cast(cargoxmora/1.16 as decimal(16,2)),cargoxmoraIVA=cast((cargoxmora/1.16)*0.16 as decimal(16,2))

CREATE TABLE #tmpsemanas(
	periodo varchar(6) NULL,
	nrosemana int NULL,
	fechaini smalldatetime NULL,
	fechafin smalldatetime NULL,
	producto varchar(150) NULL,
	capital decimal(38, 2) NULL default(0),
	interes decimal(38, 2) NULL default(0),
	moratorio decimal(38, 2) NULL default(0),
	cargoxmora decimal(38, 2) NULL default(0),
	interesIVA decimal(38, 2) NULL default(0),
	moratorioIVA decimal(38, 2) NULL default(0),
	cargoxmoraIVA decimal(38, 2) NULL default(0),
	pagoanticipado decimal(38, 2) NULL default(0),
	total decimal(38, 2) NULL default(0),
	
	Procapital decimal(38, 2) NULL default(0),
	Prointeres decimal(38, 2) NULL default(0),
	Procuotatotal decimal(38, 2) NULL default(0),
	Difcapital as capital-Procapital,
	Difinteres as interes-Prointeres
) ON [PRIMARY]

insert into #tmpsemanas(periodo,nrosemana,fechaini,fechafin,producto)
select periodo,nrosemana,fechaini,fechafin,producto
from fduTablaSemanaPeriodosFC(@periodo) x
cross join (
SELECT distinct case when codproducto in('163','302') then 'Convenio Amigo' else rtrim(ltrim(Nombreprod)) end producto
FROM [FinamigoConsolidado].[dbo].[tCaProducto]
where codproducto in ('163','302','164','123','166','168','167','156','165')
) a

--insert into #tmpsemanas(periodo,nrosemana,fechaini,fechafin,producto,capital,interes,moratorio,cargoxmora,interesIVA,moratorioIVA,cargoxmoraIVA,
--	pagoanticipado,total)
--select periodo,nrosemana,fechaini,fechafin,producto,sum(capital) capital,sum(interes) interes,sum(moratorio)moratorio,sum(cargoxmora) cargoxmora
--,sum(interesiva) interesIVA,sum(moratorioIVA) moratorioIVA,sum(cargoxmoraIVA) cargoxmoraIVA
--,sum(pagoanticipado) pagoanticipado--,sum(pagoanticipadoIVA) pagoanticipadoIVA
--,sum(total) total
--from #tmp
--where codprestamo not in (select codprestamo from [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago])
--group by periodo,nrosemana,fechaini,fechafin,producto

--insert into #tmpsemanas(periodo,nrosemana,fechaini,fechafin,producto,capital,interes,moratorio,cargoxmora,interesIVA,moratorioIVA,cargoxmoraIVA,
--	pagoanticipado,total)

update #tmpsemanas
set capital=x.capital,interes=x.interes,moratorio=x.moratorio --fecha=x.fecha,codprestamo=x.codigocuenta,
,cargoxmora=x.cargoxmora,interesiva=x.interesIVA,moratorioIVA=x.moratorioIVA,cargoxmoraIVA=x.cargoxmoraIVA
,pagoanticipado=x.pagoanticipado,total=x.total
from #tmpsemanas s
inner join (
	select periodo,nrosemana,fechaini,fechafin,producto,sum(capital) capital,sum(interes) interes,sum(moratorio)moratorio,sum(cargoxmora) cargoxmora
	,sum(interesiva) interesIVA,sum(moratorioIVA) moratorioIVA,sum(cargoxmoraIVA) cargoxmoraIVA
	,sum(pagoanticipado) pagoanticipado--,sum(pagoanticipadoIVA) pagoanticipadoIVA
	,sum(total) total
	from #tmp
	where codprestamo not in (select codprestamo from [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago])
	group by periodo,nrosemana,fechaini,fechafin,producto
) x on s.periodo=x.periodo and s.nrosemana=x.nrosemana and s.fechaini=x.fechaini and s.fechafin=x.fechafin and s.Producto=x.Producto

drop table #tmp

--select *
update #tmpsemanas
set Procapital=x.capi, Prointeres=x.inte, Procuotatotal=x.MontoCuota
from #tmpsemanas s
inner join (
	select periodo,nrosemana,fechaini,fechafin,Producto, sum(capi) capi, sum(inte) inte, sum(MontoCuota) MontoCuota
	from (
	SELECT CuotasVenc.periodo,CuotasVenc.nrosemana,CuotasVenc.fechaini,CuotasVenc.fechafin,c.CodPrestamo
	,CuotasVenc.FechaVencimiento,CuotasVenc.CAPI,CuotasVenc.INTE,CuotasVenc.CAPI + CuotasVenc.INTE MontoCuota
	,case when pc.codproducto in('163','302') then 'Convenio Amigo' else rtrim(ltrim(pc.Nombreprod)) end producto
	FROM tCsCarteraDet cd with(nolock)
	INNER JOIN tCsCartera c with(nolock) ON cd.Fecha =c.Fecha AND cd.CodPrestamo =c.CodPrestamo 
	INNER JOIN (
		SELECT periodo,nrosemana,fechaini,fechafin,Fecha, CodPrestamo, CodUsuario, FechaVencimiento, SUM(CAPI) AS CAPI, SUM(INTE) AS INTE--, SUM(INPE) AS INPE
		FROM (
				SELECT ps.periodo,ps.nrosemana,ps.fechaini,ps.fechafin,p.Fecha, p.FechaVencimiento, p.CodPrestamo, p.CodUsuario
				, CASE p.CodConcepto WHEN 'capi' THEN p.MontoDevengado ELSE 0 END AS CAPI
				, CASE p.CodConcepto WHEN 'inte' THEN p.MontoDevengado ELSE 0 END AS INTE
				FROM tCsPadronPlanCuotas p with(nolock)
				inner join (select * 
								from fduTablaSemanaPeriodosFC(@periodo)
								) ps
					on p.FechaVencimiento>=ps.fechaini and p.FechaVencimiento<=ps.fechafin
				--WHERE (p.FechaVencimiento >= '20150101') AND (p.FechaVencimiento <= '20150131')
				) A 
		GROUP BY periodo,nrosemana,fechaini,fechafin,Fecha, FechaVencimiento, CodPrestamo, CodUsuario
	) CuotasVenc 
	ON cd.Fecha=CuotasVenc.Fecha AND cd.CodPrestamo=CuotasVenc.CodPrestamo AND cd.CodUsuario=CuotasVenc.CodUsuario
	inner join tcaproducto pc with(nolock) on pc.codproducto=(case when substring(c.codprestamo,5,3) in ('157','158','159','160','161','162') then '166' 
																																 else isnull(c.codproducto,substring(c.codprestamo,5,3)) end)
	WHERE c.cartera='ACTIVA'
	) a
	group by periodo,nrosemana,fechaini,fechafin,Producto
) x on s.periodo=x.periodo and s.nrosemana=x.nrosemana and s.fechaini=x.fechaini and s.fechafin=x.fechafin and s.Producto=x.Producto

select *
from #tmpsemanas

drop table #tmpsemanas

GO