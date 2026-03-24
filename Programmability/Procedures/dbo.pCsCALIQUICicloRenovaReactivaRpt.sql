SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCALIQUICicloRenovaReactivaRpt '20180927'
CREATE procedure [dbo].[pCsCALIQUICicloRenovaReactivaRpt] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20200401'--'20180831'--

create table #Ca(
	item int identity(1,1),
	fecini smalldatetime,
	fecfin smalldatetime,
	fila varchar(30),
	Ciclo varchar(10),
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
from tcspadroncarteradet p with(nolock) where p.cancelacion>=dbo.fdufechaaperiodo(dateadd(month,-12,@fecha))+'01' and p.cancelacion<=@fecha
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231','999')

insert into #dias 
select codprestamo,max(nrodiasatraso) nrodiasatraso
from tcscartera with(nolock)
where codprestamo in (select codprestamo from #ptmos)
group by codprestamo

delete from #dias where nrodiasatraso>=30

declare @fecini smalldatetime
declare @fecfin smalldatetime

declare @x int
set @x=12
while (@x<>0)
begin	
	set @fecini=dbo.fdufechaaperiodo(dateadd(month,-1*@x,@fecha))+'01'
	--set @fecfin=dateadd(month,-1*@x,@fecha)
	select @fecfin=ultimodia from tclperiodo where primerdia<=dateadd(month,-1*@x,@fecha) and ultimodia>=dateadd(month,-1*@x,@fecha)

	insert into #Ca (fecini,fecfin,fila,Ciclo,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
	select fecini,fecfin,fila,Ciclo,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado
	from (
		select @fecini fecini,@fecfin fecfin,dbo.fdufechaaperiodo(@fecfin) fila
		,case when p.secuenciacliente=1 then 1
				  when p.secuenciacliente=2 then 2
				  when p.secuenciacliente=3 then 3
				  when p.secuenciacliente in(4,5,6) then 4
				  when p.secuenciacliente in(7,8,9) then 5
				  when p.secuenciacliente>=10 then 6
			 end orden 
		,case when p.secuenciacliente=1 then 'Ciclo 1'
			  when p.secuenciacliente=2 then 'Ciclo 2'
			  when p.secuenciacliente=3 then 'Ciclo 3'
			  when p.secuenciacliente in(4,5,6) then 'Ciclo 4-6'
			  when p.secuenciacliente in(7,8,9) then 'Ciclo 7-9'
			  when p.secuenciacliente>=10 then 'Ciclo 10+'
		 end ciclo
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
		group by case when p.secuenciacliente=1 then 'Ciclo 1'
				  when p.secuenciacliente=2 then 'Ciclo 2'
				  when p.secuenciacliente=3 then 'Ciclo 3'
				  when p.secuenciacliente in(4,5,6) then 'Ciclo 4-6'
				  when p.secuenciacliente in(7,8,9) then 'Ciclo 7-9'
				  when p.secuenciacliente>=10 then 'Ciclo 10+'
				end
				,case when p.secuenciacliente=1 then 1
				  when p.secuenciacliente=2 then 2
				  when p.secuenciacliente=3 then 3
				  when p.secuenciacliente in(4,5,6) then 4
				  when p.secuenciacliente in(7,8,9) then 5
				  when p.secuenciacliente>=10 then 6
			 end
	) a
	order by orden

	set @x=@x-1
end

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecfin=@fecha

insert into #Ca (fecini,fecfin,fila,Ciclo,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
select fecini,fecfin,fila,Ciclo,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado
from (
	select @fecini fecini,@fecfin fecfin,dbo.fdufechaaperiodo(@fecfin) fila
	,case when p.secuenciacliente=1 then 1
			  when p.secuenciacliente=2 then 2
			  when p.secuenciacliente=3 then 3
			  when p.secuenciacliente in(4,5,6) then 4
			  when p.secuenciacliente in(7,8,9) then 5
			  when p.secuenciacliente>=10 then 6
		 end orden 
	,case when p.secuenciacliente=1 then 'Ciclo 1'
			  when p.secuenciacliente=2 then 'Ciclo 2'
			  when p.secuenciacliente=3 then 'Ciclo 3'
			  when p.secuenciacliente in(4,5,6) then 'Ciclo 4-6'
			  when p.secuenciacliente in(7,8,9) then 'Ciclo 7-9'
			  when p.secuenciacliente>=10 then 'Ciclo 10+'
		 end Ciclo
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
	group by case when p.secuenciacliente=1 then 'Ciclo 1'
				when p.secuenciacliente=2 then 'Ciclo 2'
				when p.secuenciacliente=3 then 'Ciclo 3'
				when p.secuenciacliente in(4,5,6) then 'Ciclo 4-6'
				when p.secuenciacliente in(7,8,9) then 'Ciclo 7-9'
				when p.secuenciacliente>=10 then 'Ciclo 10+'
			end
			,case when p.secuenciacliente=1 then 1
				  when p.secuenciacliente=2 then 2
				  when p.secuenciacliente=3 then 3
				  when p.secuenciacliente in(4,5,6) then 4
				  when p.secuenciacliente in(7,8,9) then 5
				  when p.secuenciacliente>=10 then 6
			 end
) a
order by orden

update #Ca
set PorRenovado=(MntoRenovado/Monto)*100,PorNoRenovado=(MntoNoRenovado/Monto)*100,PorReactivado=(MntoReactivado/Monto)*100

select * from #Ca

drop table #Ca
drop table #dias
drop table #ptmos
GO