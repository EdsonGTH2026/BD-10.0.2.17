SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pXaCaLIQUINacioRenovadoDias '20181017'
CREATE procedure [dbo].[pXaCaLIQUINacioRenovadoDias] --@fecha smalldatetime
as
set nocount on

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

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
	NroNorenovado int,
	MntoNorenovado money,
	PorNoRenovado money
)

declare @fecini smalldatetime
declare @fecfin smalldatetime

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecfin=@fecha

create table #padron(
	codprestamo varchar(25),
	codusuario varchar(15),
	cancelacion smalldatetime,
	monto money,
	codproducto varchar(3),
	codoficina varchar(4),
	nrodiasmaximo int
)
insert into #padron
select codprestamo,codusuario,fechaultpago,montodesembolso,codproducto,codoficina,0
from [10.0.2.14].finmas.dbo.tcaprestamos
where estado='CANCELADO' and fechaultpago=(@fecfin+1) and codoficina not in('97','230','231','98')
and (codserviciop not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or codserviciop is null)

update #padron
set codusuario=p.codusuario
from tcspadronclientes p with(nolock)
inner join #padron x on x.codusuario=p.codorigen

insert into #padron
select codprestamo,codusuario,cancelacion,monto,codproducto,codoficina,nrodiasmaximo
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecini and cancelacion<=@fecfin
and (codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or codgrupo is null)
and codoficina not in('97','230','231','98')

create table #desem(
	codprestamo varchar(25),
	codproducto varchar(3),
	codusuario varchar(15),
	nuevomonto money,
	nuevodesembolso smalldatetime
)
insert into #desem
select codprestamo,codproducto,codusuario,montodesembolso,fechadesembolso
from [10.0.2.14].finmas.dbo.tcaprestamos
where estado='VIGENTE' and fechadesembolso=(@fecfin+1) and codoficina not in('97','98')

update #desem
set codusuario=p.codusuario
from tcspadronclientes p with(nolock)
inner join #desem x on x.codusuario=p.codorigen

insert into #desem
select codprestamo,codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini and desembolso<=@fecha

insert into #Ca (fecini,fecfin,fila,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado)
select @fecini,@fecfin
,case when p.nrodiasmaximo>=0 and p.nrodiasmaximo<=15 then '0 - 15'
	  when p.nrodiasmaximo>=16 and p.nrodiasmaximo<=29 then '16 - 29'
	  else '30+' end
,count(p.codprestamo) Nro,sum(p.monto) Monto
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 1 else 0 end
		 else 0 end) NroRenovado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then cr.nuevomonto else 0 end
		 else 0 end) MntoRenovado
	,sum(case when cr.nuevodesembolso is null then 1 else 0 end) NroNorenovado
	,sum(case when cr.nuevodesembolso is null then p.monto else 0 end) MntoNorenovado
from #padron p with(nolock)
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
left outer join(
       select codprestamo,codproducto,codusuario,nuevomonto,nuevodesembolso
       from #desem        
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
	   and cr.codproducto = (case when p.codproducto ='370' then '370' else '170' end)
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where z.zona<>'ZSC'
group by case when p.nrodiasmaximo>=0 and p.nrodiasmaximo<=15 then '0 - 15'
	  when p.nrodiasmaximo>=16 and p.nrodiasmaximo<=29 then '16 - 29'
	  else '30+' end

update #Ca
set PorRenovado=(MntoRenovado/Monto)*100,PorNoRenovado=(MntoNoRenovado/Monto)*100

select * from #Ca

drop table #Ca
drop table #padron
drop table #desem
GO