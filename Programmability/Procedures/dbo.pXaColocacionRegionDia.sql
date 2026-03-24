SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pXaColocacionRegionDia] @codoficinas varchar(500)
as
BEGIN
	set nocount on

	Declare @FechaT SmallDateTime
	--set @FechaT='20180906'
	Select @FechaT = FechaConsolidacion From vCsFechaConsolidacion  --CHECAR
	
	declare @ncli int
	declare @mdia decimal(16,2)
	declare @macu decimal(16,2)
	
	select codoficina,count(codprestamo) nro,
	sum(montodesembolso) monto
	into #Dia
	from [10.0.2.14].finmas.dbo.tcaprestamos
	where fechadesembolso=@FechaT+1 and estado='VIGENTE'
		and codoficina in (select VALUE from dbo.fSplit(',',@codoficinas) )
	group by codoficina
	
	--select * from #Dia --comentar
	
	select @FechaT +1 fecha, isnull(p.codoficina,d.codoficina) codoficina,isnull(p.monto,0)+isnull(d.monto,0) as monto,
	isnull(p.nro,0)+isnull(d.nro,0) as nro
	into #Des
	from (
		SELECT codoficina,sum(monto) as monto, count(codprestamo) as nro
		FROM tCsPadronCarteraDet with(nolock)
		where desembolso>=dbo.fdufechaatexto(@FechaT+1,'AAAAMM')+'01' 
		and codoficina<>'97'
		and desembolso<=@FechaT
			and codoficina in (select VALUE from dbo.fSplit(',',@codoficinas) )
		group by codoficina
	) p
	full outer join #Dia d on p.codoficina=d.codoficina
	
	--select * from #Des --comentar
	
	declare @m1 smalldatetime
	declare @m2 smalldatetime
	declare @m3 smalldatetime
	set @m1=dateadd(month,-1,@FechaT+1)
	set @m2=dateadd(month,-2,@FechaT+1)
	set @m3=dateadd(month,-3,@FechaT+1)
	
	declare @macu1 decimal(16,2)
	declare @macu2 decimal(16,2)
	declare @macu3 decimal(16,2)
	
	insert into #Des
	SELECT @m1 periodo,codoficina,sum(monto) monto, count(codprestamo) as nro
	FROM tCsPadronCarteraDet with(nolock)
	where desembolso>=dbo.fdufechaatexto(@m1,'AAAAMM')+'01' and codoficina<>'97' and desembolso<=@m1
and codoficina in (select VALUE from dbo.fSplit(',',@codoficinas) )
	group by codoficina
	
	insert into #Des
	SELECT @m2 periodo,codoficina,sum(monto) monto, count(codprestamo) as nro
	FROM tCsPadronCarteraDet with(nolock)
	where desembolso>=dbo.fdufechaatexto(@m2,'AAAAMM')+'01' and codoficina<>'97' and estadocalculado<>'ANULADO' and desembolso<=@m2
and codoficina in (select VALUE from dbo.fSplit(',',@codoficinas) )
	group by codoficina
	
	insert into #Des
	SELECT @m3 periodo,codoficina,sum(monto) monto, count(codprestamo) as nro
	FROM tCsPadronCarteraDet with(nolock)
	where desembolso>=dbo.fdufechaatexto(@m3,'AAAAMM')+'01' and codoficina<>'97' and estadocalculado<>'ANULADO' and desembolso<=@m3
and codoficina in (select VALUE from dbo.fSplit(',',@codoficinas) )
	group by codoficina
	
	select convert(varchar, d.fecha, 103) as fecha,
	--,o.nomoficina sucursal
	z.nombre,sum(d.monto) as monto, count(d.nro) as nro
	from #Des d
	inner join tcloficinas o on o.codoficina=d.codoficina
	inner join tclzona z on z.zona=o.zona
	group by d.fecha,z.nombre
	
	drop table #Dia
	drop table #Des

END
GO