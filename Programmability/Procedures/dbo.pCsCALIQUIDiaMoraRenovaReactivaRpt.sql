SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCALIQUIDiaMoraRenovaReactivaRpt '20180927'
CREATE procedure [dbo].[pCsCALIQUIDiaMoraRenovaReactivaRpt] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20200401'--'20180831'--
set nocount on
create table #Ca(
	item int identity(1,1),
	fecini smalldatetime,
	fecfin smalldatetime,
	grupo varchar(10),
	fila varchar(30),
	DiaMora varchar(10),
	Nro int,
	Monto money,
	NroRenovado int,
	MntoRenovado money,
	PorRenovado money,
	NroReactivado int,
	MntoReactivado money,
	PorReactivado money,
	NroNorenovado int,
	MntoNorenovado money,
	PorNorenovado money
)

create table #dias(codprestamo varchar(25),nrodiasatraso int)
create table #ptmos (codprestamo varchar(25))

insert into #ptmos
select codprestamo
from tcspadroncarteradet p with(nolock) where p.cancelacion>=dbo.fdufechaaperiodo(dateadd(month,-6,@fecha))+'01' and p.cancelacion<=@fecha
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231','999')

insert into #dias 
select codprestamo,max(nrodiasatraso) nrodiasatraso
from tcscartera with(nolock)
where codprestamo in (select codprestamo from #ptmos)
group by codprestamo

declare @fecini smalldatetime
declare @fecfin smalldatetime

declare @x int
set @x=6
while (@x<>0)
begin	
	print '@x: ' + str(@x)
	set @fecini=dbo.fdufechaaperiodo(dateadd(month,-1*@x,@fecha))+'01'
	--set @fecfin=dateadd(month,-1*@x,@fecha)
	select @fecfin=ultimodia from tclperiodo where primerdia<=dateadd(month,-1*@x,@fecha) and ultimodia>=dateadd(month,-1*@x,@fecha)

	insert into #Ca (fecini,fecfin,fila,grupo,DiaMora,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
	select fecini,fecfin,fila,fila,DiaMora,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado
	from (
		select @fecini fecini,@fecfin fecfin,dbo.fdufechaaperiodo(@fecfin) fila
		,case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then 1
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then 2
			  when d.nrodiasatraso>=30 then 3
			 end orden 
		,case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then '0-15'
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then '16-29'
			  when d.nrodiasatraso>=30 then '30+'
		 end DiaMora
		,count(p.codprestamo) Nro,sum(p.monto) Monto
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
		inner join #dias d on d.codprestamo=p.codprestamo
		inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
		where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
		and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
		and p.codoficina not in('97','230','231','999')
		and o.zona<>'ZSC'
		group by case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then 1
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then 2
			  when d.nrodiasatraso>=30 then 3
			 end
		,case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then '0-15'
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then '16-29'
			  when d.nrodiasatraso>=30 then '30+'
		 end
	) a
	order by orden

	set @x=@x-1
end

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecfin=@fecha

insert into #Ca (fecini,fecfin,fila,grupo,DiaMora,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
select fecini,fecfin,fila,fila,DiaMora,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado
from (
	select @fecini fecini,@fecfin fecfin,dbo.fdufechaaperiodo(@fecfin) fila
	,case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then 1
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then 2
			  when d.nrodiasatraso>=30 then 3
			 end orden 
		,case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then '0-15'
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then '16-29'
			  when d.nrodiasatraso>=30 then '30+'
		 end DiaMora
	,count(p.codprestamo) Nro,sum(p.monto) Monto
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
	inner join #dias d on d.codprestamo=p.codprestamo
	inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
	where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
	and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
	and p.codoficina not in('97','230','231','999')
	and o.zona<>'ZSC'
	group by case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then 1
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then 2
			  when d.nrodiasatraso>=30 then 3
			 end
		,case when d.nrodiasatraso>=0 and d.nrodiasatraso<=15 then '0-15'
			  when d.nrodiasatraso>=16 and d.nrodiasatraso<=29 then '16-29'
			  when d.nrodiasatraso>=30 then '30+'
		 end
) a
order by orden

update #Ca
set PorRenovado=(MntoRenovado/Monto)*100,PorNoRenovado=(MntoNoRenovado/Monto)*100,PorReactivado=(MntoReactivado/Monto)*100

insert into #Ca (fila,grupo,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado,porrenovado,pornorenovado)
select 'Promedio 6 meses','Resumen',avg(nro),avg(Monto),avg(NroRenovado),avg(MntoRenovado),avg(NroNorenovado),avg(MntoNorenovado),avg(porrenovado),avg(pornorenovado)
from #Ca
where fecini<@fecini and DiaMora='0-15'

insert into #Ca (fila,grupo,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado,porrenovado,pornorenovado)
select 'Deficit','Resumen',a.nro-c.nro,a.Monto-c.Monto,a.NroRenovado-c.NroRenovado,a.MntoRenovado-c.MntoRenovado,a.NroNorenovado-c.NroNorenovado,a.MntoNorenovado-c.MntoNorenovado
,a.porrenovado-c.porrenovado,a.pornorenovado-c.pornorenovado
from #Ca c
cross join #Ca a 
where c.fila='Promedio 6 meses' and a.fecfin=@fecfin and a.DiaMora='0-15' 

insert into #Ca (fila,grupo,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado)
select c.ti,'Resumen'
,case when c.nro=0 then 0 else (a.nro/c.nro)*100 end nro
,case when c.Monto=0 then 0 else (a.Monto/c.Monto)*100 end Monto
,case when c.NroRenovado=0 then 0 else (a.NroRenovado/c.NroRenovado)*100 end NroRenovado
,case when c.MntoRenovado=0 then 0 else (a.MntoRenovado/c.MntoRenovado)*100 end MntoRenovado
,case when c.NroNorenovado=0 then 0 else (a.NroNorenovado/c.NroNorenovado)*100 end NroNorenovado
,case when c.MntoNorenovado=0 then 0 else (a.MntoNorenovado/c.MntoNorenovado)*100 end MntoNorenovado
from (
	select '%  0-15 mes actual' ti,sum(nro) nro,sum(Monto) Monto,sum(NroRenovado) NroRenovado,sum(MntoRenovado) MntoRenovado,sum(NroNorenovado) NroNorenovado,sum(MntoNorenovado) MntoNorenovado
	from #Ca
	where fecfin=@fecfin
) c
cross join #Ca a
where a.fecfin=@fecfin
and a.DiaMora='0-15' 

select * from #Ca

drop table #Ca
drop table #dias
drop table #ptmos
GO