SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaCosechasBase] 
AS
	
--declare @fecha smalldatetime
----declare @codoficina varchar(4)
----set @fecha ='20160609'
--select @fecha = fechaconsolidacion from vcsfechaconsolidacion
----set @codoficina='10'

----create table #veri(
----codprestamo varchar(25),
----codverificador varchar(250),
----codverificadorData varchar(250)
----)

----insert #veri (codprestamo,codverificador)
----SELECT p.codprestamo,s.codverificador
----FROM [10.0.2.14].[Finmas].[dbo].[tCaSolicitud] s
----inner join [10.0.2.14].[Finmas].[dbo].[tCaprestamos] p on p.codsolicitud=s.codsolicitud and p.codoficina=s.codoficina
----where s.codverificador is not null

----update #veri
----set codverificadorData=cl.codusuario
----from #veri v
----inner join tcspadronclientes cl on cl.codorigen=v.codverificador

----insert #veri (codprestamo,codverificador,codverificadorData)
----SELECT [Prestamoid],[verificador],[verificador]
----FROM [FinamigoConsolidado].[dbo].[_PromotorFijoAlta]

--create table #cid(codprestamo varchar(25),prestamoid varchar(25))
--insert into #cid
--SELECT codprestamo,case when len(codanterior)>7 then 0 else codanterior end
--FROM [10.0.2.14].[Finmas].[dbo].[tCaprestamos]
--where codoficina>100
--and estado<>'CANCELADO'
--and codoficina not in('230','231')

--create table #prorep(promotorreporte varchar(250),codprestamo varchar(25))
--insert into #prorep
--SELECT [Promotor Reporte],codprestamo
--FROM [FinamigoConsolidado].[dbo].[_PromotorFijo]
--union
--SELECT [promotorreporte],[Prestamoid]
--FROM [FinamigoConsolidado].[dbo].[_PromotorFijoAlta]

----######################################################

--	delete from tCsCaCosechasBase

--	insert into tCsCaCosechasBase
--	--select * from tCsCaCosechasBase
--	select pcd.CodPrestamo, pcd.CodUsuario,

----pcd.CodOficina,
----se cambio el num oficina a peticion de LF para restar 200 a las oficinas > 300
--(case
--when convert(integer,pcd.CodOficina) >= 300 then convert(varchar,(convert(integer,pcd.CodOficina) - 200))
--else
--pcd.CodOficina
--end ) as CodOficina,

--	o.nomoficina sucursal, pcd.CodProducto,
--	pcd.Desembolso, pcd.Monto, pcd.PrimerAsesor, pcd.UltimoAsesor,
--	pcd.Estadocalculado,t2.NroDiasAtraso,t2.saldo--,t2.Estado
--	,case when f.promotorreporte is null then pcd.PrimerAsesor else f.promotorreporte end as PromotorReporte,
--	case when cl.nombrecompleto is null then f.promotorreporte else cl.nombrecompleto end PromotorReporteNombre
--	,pcd.codverificador codverificadorData
--	,case  
--	    when datepart(MM,pcd.Desembolso) >= 1 and datepart(MM,pcd.Desembolso) <= 3 then '1' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
--	    when datepart(MM,pcd.Desembolso) >= 4 and datepart(MM,pcd.Desembolso) <= 6 then '2' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
--	    when datepart(MM,pcd.Desembolso) >= 7 and datepart(MM,pcd.Desembolso) <= 9 then '3' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
--	    when datepart(MM,pcd.Desembolso) >= 10 and datepart(MM,pcd.Desembolso) <= 12 then '4' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
--	    else '' end as Trimestre,         
--	(case when t2.NroDiasAtraso >= 4 then t2.saldo else 0 end ) as Saldo2,
--	(case when t2.saldo > 0 and t2.NroDiasAtraso >= 4 then 1 else 0 end ) as ContarSaldo2
--	,pid.prestamoid
	
--	from tcspadroncarteradet as pcd with(nolock)
--	left join (
--	    select
--	    c.CodPrestamo, cd.CodUsuario, c.NroDiasAtraso,
--	    saldo = cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16),
--	    Estado
--	    from tcscartera as c with(nolock)
--	    inner join tcscarteradet as cd with(nolock) on cd.Fecha = c.Fecha and cd.CodPrestamo = c.CodPrestamo
--	    where c.fecha = @fecha
--	) as t2 on t2.CodPrestamo = pcd.CodPrestamo and t2.CodUsuario = pcd.CodUsuario
--	left outer join #cid pid on pid.codprestamo=pcd.codprestamo
--	left outer join (select distinct codprestamo,promotorreporte from #prorep) f on f.codprestamo=isnull(pid.prestamoid,pcd.codprestamo)
--	--left outer join #veri v on v.codprestamo=isnull(pid.prestamoid,pcd.codprestamo)
--	left outer join tcspadronclientes cl with(nolock) on cl.codusuario=(case when f.promotorreporte is null then pcd.PrimerAsesor else f.promotorreporte end)
--	inner join tcloficinas o with(nolock) on o.codoficina=pcd.codoficina
--	where pcd.CodOficina not in ('42','97','98')
--	--where pcd.codoficina=@codoficina
--	and pcd.CodProducto not in ('167','168')
--	and pcd.Desembolso >= '20140101'
--	and pcd.estadocalculado<>'CANCELADO'
	
--------------
----drop table #veri
--drop table #cid
--drop table #prorep

--create table #x(
--	promotornombre varchar(250)
--)
--insert into #x
--select promotorreportenombre--,count(promotorreportenombre) n 
--from (
--	select promotorreporte,promotorreportenombre
--	from tCsCaCosechasBase with(nolock)
--	where promotorreporte<>'HUERFANO'
--	group by promotorreporte,promotorreportenombre
--) a
--group by promotorreportenombre
--having count(promotorreportenombre)>1

----select b.codprestamo,b.promotorreporte,b.promotorreportenombre,x.promotornombre
--update tCsCaCosechasBase
--set promotorreporte=x.promotornombre
--from tCsCaCosechasBase b inner join #x x on b.promotorreportenombre=x.promotornombre
--where b.promotorreporte<>x.promotornombre

----select b.codprestamo,b.promotorreporte,b.promotorreportenombre,x.promotornombre
----from tCsCaCosechasBase b inner join #x x on b.promotorreportenombre=x.promotornombre
------where b.promotorreporte<>x.promotornombre

--drop table #x

GO