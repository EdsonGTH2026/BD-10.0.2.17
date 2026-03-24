SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCALIQUINacioRenovaReactivaRpt '20180927'
CREATE procedure [dbo].[pCsCALIQUINacioRenovaReactivaRpt] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20181016'--'20180831'--

create table #Ca(
	item int identity(1,1),
	fecini smalldatetime,
	fecfin smalldatetime,
	fila varchar(30),
	Nro int,
	Monto money,
	NroRenovado int,	
	MntoRenovado money,
	PorRenovado money,
	PorRenovadoNum money,
	NroReactivado int,
	MntoReactivado money,
	PorReactivado money,
	NroNorenovado int,
	MntoNorenovado money,
	PorNorenovado money
)

declare @fecini smalldatetime
declare @fecfin smalldatetime

declare @x int
set @x=6
while (@x<>0)
begin	
	--insert into #periodos(fecini,fecfin)
	--values(dbo.fdufechaaperiodo(dateadd(month,-1*@x,@fecha))+'01',dateadd(month,-1*@x,@fecha))
	set @fecini=dbo.fdufechaaperiodo(dateadd(month,-1*@x,@fecha))+'01'
	--set @fecfin=dateadd(month,-1*@x,@fecha)
	select @fecfin=ultimodia from tclperiodo where primerdia<=dateadd(month,-1*@x,@fecha) and ultimodia>=dateadd(month,-1*@x,@fecha)

	insert into #Ca (fecini,fecfin,fila,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
	select @fecini,@fecfin,dbo.fdufechaaperiodo(@fecfin),count(p.codprestamo) Nro,sum(p.monto) Monto
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 1 else 0 end
		 else 0 end) NroRenovado
	--,sum(case when cr.nuevodesembolso is not null then --1 
	--		case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then p.monto else 0 end
	--	 else 0 end) MntoRenovado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then cr.nuevomonto else 0 end
		 else 0 end) MntoRenovado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)<>dbo.fdufechaaperiodo(cr.nuevodesembolso) then 1 else 0 end
		 else 0 end) NroReactivado
	--,sum(case when cr.nuevodesembolso is not null then --1 
	--		case when dbo.fdufechaaperiodo(p.cancelacion)<>dbo.fdufechaaperiodo(cr.nuevodesembolso) then p.monto else 0 end
	--	 else 0 end) MntoReactivado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)<>dbo.fdufechaaperiodo(cr.nuevodesembolso) then cr.nuevomonto else 0 end
		 else 0 end) MntoReactivado
	,sum(case when cr.nuevodesembolso is null then 1 else 0 end) NroNorenovado
	,sum(case when cr.nuevodesembolso is null then p.monto else 0 end) MntoNorenovado
	from tcspadroncarteradet p with(nolock)	
	left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
	left outer join(
		   select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo
		   ,y.secuenciaconsumo
		   from tcspadroncarteradet x with(nolock)
		   left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
		   where x.desembolso>=@fecini and x.desembolso<=@fecha--'20180927'--
	) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
		   --and (case when cr.codproducto='370' then cr.secuenciaconsumo else cr.secuenciaproductivo end)
				 -- =(case when p.codproducto='370' then s.secuenciaconsumo+1 else s.secuenciaproductivo+1 end)
	inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
	where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
	and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
	and p.codoficina not in('97','230','231','999')
	and o.zona<>'ZSC'

	set @x=@x-1
end

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecfin=@fecha

insert into #Ca (fecini,fecfin,fila,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
select @fecini,@fecfin,dbo.fdufechaaperiodo(@fecfin),count(p.codprestamo) Nro,sum(p.monto) Monto
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 1 else 0 end
		 else 0 end) NroRenovado
	--,sum(case when cr.nuevodesembolso is not null then --1 
	--		case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then p.monto else 0 end
	--	 else 0 end) MntoRenovado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then cr.nuevomonto else 0 end
		 else 0 end) MntoRenovado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)<>dbo.fdufechaaperiodo(cr.nuevodesembolso) then 1 else 0 end
		 else 0 end) NroReactivado
	--,sum(case when cr.nuevodesembolso is not null then --1 
	--		case when dbo.fdufechaaperiodo(p.cancelacion)<>dbo.fdufechaaperiodo(cr.nuevodesembolso) then p.monto else 0 end
	--	 else 0 end) MntoReactivado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)<>dbo.fdufechaaperiodo(cr.nuevodesembolso) then cr.nuevomonto else 0 end
		 else 0 end) MntoReactivado
	,sum(case when cr.nuevodesembolso is null then 1 else 0 end) NroNorenovado
	,sum(case when cr.nuevodesembolso is null then p.monto else 0 end) MntoNorenovado
from tcspadroncarteradet p with(nolock)
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
left outer join(
       select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo
       ,y.secuenciaconsumo
       from tcspadroncarteradet x with(nolock)
       left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
       where x.desembolso>=@fecini and x.desembolso<=@fecha--'20180927'--
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
       --and (case when cr.codproducto='370' then cr.secuenciaconsumo else cr.secuenciaproductivo end)
       --       =(case when p.codproducto='370' then s.secuenciaconsumo+1 else s.secuenciaproductivo+1 end)
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231','999')
and o.zona<>'ZSC'

update #Ca
set PorRenovado=case when Monto=0 then 0 else (MntoRenovado/Monto)*100 end
,PorRenovadoNum=case when cast(Nro as money)=0 then 0 else (cast(NroRenovado as money)/cast(Nro as money))*100 end
,PorNoRenovado=case when Monto=0 then 0 else (MntoNoRenovado/Monto)*100 end
,PorReactivado=case when Monto=0 then 0 else (MntoReactivado/Monto)*100 end

insert into #Ca (fila,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado,porrenovado,pornorenovado)
select 'Promedio 6 meses',avg(nro),avg(Monto),avg(NroRenovado),avg(MntoRenovado),avg(NroNorenovado),avg(MntoNorenovado),avg(porrenovado),avg(pornorenovado)
from #Ca
where fecini<@fecini

insert into #Ca (fila,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado,porrenovado,pornorenovado)
select 'Mes actual vs Promedio',a.nro-c.nro,a.Monto-c.Monto,a.NroRenovado-c.NroRenovado,a.MntoRenovado-c.MntoRenovado,a.NroNorenovado-c.NroNorenovado,a.MntoNorenovado-c.MntoNorenovado
,a.porrenovado-c.porrenovado,a.pornorenovado-c.pornorenovado
from #Ca c
cross join #Ca a 
where c.fila='Promedio 6 meses' and a.fecfin=@fecfin

select * from #Ca

drop table #Ca
GO