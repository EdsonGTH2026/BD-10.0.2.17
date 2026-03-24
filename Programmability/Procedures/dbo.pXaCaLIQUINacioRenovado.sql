SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pXaCaLIQUINacioRenovado '20181017'
CREATE procedure [dbo].[pXaCaLIQUINacioRenovado] --@fecha smalldatetime
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

declare @fecfinuno smalldatetime
set @fecfinuno = @fecfin+1

create table #padron(
	codprestamo varchar(25),
	codusuario varchar(15),
	cancelacion smalldatetime,
	monto money,
	codproducto varchar(3),
	codoficina varchar(4)
)
insert into #padron
exec [10.0.2.14].finmas.dbo.pXaCaLIQUINacioRenovado_Liq @fecfinuno
--select codprestamo,codusuario,fechaultpago,montodesembolso,codproducto,codoficina
--from [10.0.2.14].finmas.dbo.tcaprestamos
--where estado='CANCELADO' and fechaultpago=(@fecfin+1) and codoficina not in('97','230','231')
--and (codserviciop not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or codserviciop is null)

update #padron
set codusuario=p.codusuario
from tcspadronclientes p with(nolock)
inner join #padron x on x.codusuario=p.codorigen

insert into #padron
select codprestamo,codusuario,cancelacion,monto,codproducto,codoficina
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
exec [10.0.2.14].finmas.dbo.pXaCaLIQUINacioRenovado_Des @fecfinuno
--select codprestamo,codproducto,codusuario,montodesembolso,fechadesembolso
--from [10.0.2.14].finmas.dbo.tcaprestamos
--where estado='VIGENTE' and fechadesembolso=(@fecfin+1) and codoficina<>'97'

update #desem
set codusuario=p.codusuario
from tcspadronclientes p with(nolock)
inner join #desem x on x.codusuario=p.codorigen

insert into #desem
select codprestamo,codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini and desembolso<=@fecha

insert into #Ca (fecini,fecfin,fila,Nro,Monto,NroRenovado,MntoRenovado,NroNorenovado,MntoNorenovado)
select @fecini,@fecfin,z.nombre,count(p.codprestamo) Nro,sum(p.monto) Monto
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 1 else 0 end
		 else 0 end) NroRenovado
	,sum(case when cr.nuevodesembolso is not null then --1 
			case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then cr.nuevomonto else 0 end
		 else 0 end) MntoRenovado
	,sum(case when cr.nuevodesembolso is null then 1 else 0 end) NroNorenovado
	,sum(case when cr.nuevodesembolso is null then p.monto else 0 end) MntoNorenovado
--from tcspadroncarteradet p with(nolock)
from #padron p with(nolock)
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
--left outer join(
--       select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso
--	   ,secuenciacliente,y.secuenciaproductivo,y.secuenciaconsumo
--       from tcspadroncarteradet x
--       left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
--       where x.desembolso>=@fecini and x.desembolso<=@fecha--'20180927'--
--) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
--       and (case when cr.codproducto='370' then cr.secuenciaconsumo else cr.secuenciaproductivo end)=(case when p.codproducto='370' then s.secuenciaconsumo+1 else s.secuenciaproductivo+1 end)
left outer join(
       select codprestamo,codproducto,codusuario,nuevomonto,nuevodesembolso
       from #desem        
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
	   and cr.codproducto = (case when p.codproducto ='370' then '370' else '170' end)
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
--where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
--and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
--and p.codoficina not in('97','230','231')
where z.zona<>'ZSC'
group by z.nombre

update #Ca
set PorRenovado=(MntoRenovado/Monto)*100,PorNoRenovado=(MntoNoRenovado/Monto)*100

select * from #Ca

drop table #Ca
drop table #padron
drop table #desem

GO

GRANT EXECUTE ON [dbo].[pXaCaLIQUINacioRenovado] TO [marista]
GO