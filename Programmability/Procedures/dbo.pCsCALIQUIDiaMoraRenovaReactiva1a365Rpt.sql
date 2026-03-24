SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCALIQUIDiaMoraRenovaReactivaRpt '20180927'
CREATE procedure [dbo].[pCsCALIQUIDiaMoraRenovaReactiva1a365Rpt] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20190219'--'20180831'--
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
from tcspadroncarteradet p with(nolock) where p.cancelacion>=dbo.fdufechaaperiodo(dateadd(month,-12,@fecha))+'01' and p.cancelacion<=@fecha
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231','999')

insert into #dias 
select codprestamo,max(nrodiasatraso) nrodiasatraso
from tcscartera with(nolock)
where codprestamo in (select codprestamo from #ptmos)
group by codprestamo

declare @fecini smalldatetime
declare @fecfin smalldatetime

set @fecini=dbo.fdufechaaperiodo(dateadd(month,-12,@fecha))+'01'--dbo.fdufechaaperiodo(@fecha)+'01'
set @fecfin=@fecha

insert into #Ca (fecini,fecfin,fila,grupo,DiaMora,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado)
select fecini,fecfin,fila,fila,DiaMora,Nro,Monto,NroRenovado,MntoRenovado,NroReactivado,MntoReactivado,NroNorenovado,MntoNorenovado
from (
	select @fecini fecini,@fecfin fecfin,dbo.fdufechaaperiodo(@fecfin) fila
		,case when d.nrodiasatraso>=1 and d.nrodiasatraso<=90 then 1
			  when d.nrodiasatraso>=91 and d.nrodiasatraso<=365 then 2
			  --when d.nrodiasatraso>=30 then 3
			 end orden 
		,case when d.nrodiasatraso>=1 and d.nrodiasatraso<=90 then '1-90'
			  when d.nrodiasatraso>=91 and d.nrodiasatraso<=365 then '91-365'
			  --when d.nrodiasatraso>=30 then '30+'
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
	and d.nrodiasatraso>=1
	and d.nrodiasatraso<=365
	group by 	case when d.nrodiasatraso>=1 and d.nrodiasatraso<=90 then 1
			  when d.nrodiasatraso>=91 and d.nrodiasatraso<=365 then 2
			  --when d.nrodiasatraso>=30 then 3
			 end 
		,case when d.nrodiasatraso>=1 and d.nrodiasatraso<=90 then '1-90'
			  when d.nrodiasatraso>=91 and d.nrodiasatraso<=365 then '91-365'
			  --when d.nrodiasatraso>=30 then '30+'
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