SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--select codusuario, count(codprestamo) nro
--from tcspadroncarteradet with(nolock)
--where codproducto=170 and estadocalculado<>'CANCELADO'
--group by codusuario
--having count(codprestamo)>1
--exec pXaCSHCreditos 'OQM641219F9MR9'
CREATE procedure [dbo].[pXaCSHCreditos] @codusuario varchar(15)
as
--declare @codusuario varchar(15)
--set @codusuario='OQM641219F9MR9'

create table #Ptmos(
	item int identity(1,1),
	codprestamo  varchar(25),
	saldo money,
	estado varchar(20),
	desembolso varchar(10),
	monto money,
	nrocuotaspagadas int
)
insert into #Ptmos (codprestamo,saldo,estado,desembolso,monto,nrocuotaspagadas)
select p.codprestamo
,case when p.estadocalculado='CANCELADO' then 0 else d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden
+d.otroscargos+d.impuestos+d.cargomora end saldo,p.estadocalculado estado
,dbo.fdufechaatexto(p.desembolso,'DD/MM/AAAA') desembolso,p.monto ,c.nrocuotasporpagar nrocuotaspagadas
from tcspadroncarteradet p with(nolock)
inner join tcscarteradet d with(nolock) on p.fechacorte=d.fecha and p.codprestamo=d.codprestamo
inner join tcscartera c with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where p.codusuario=@codusuario--'CGF611120M0I621'--
and p.estadocalculado<>'CANCELADO'
order by p.desembolso,p.secuenciacliente

declare @trans table(codprestamo varchar(25),pagado money)
insert into @trans
select codigocuenta,sum(montocapitaltran) montorecu
from tcstransacciondiaria with(nolock) where codusuario=@codusuario and codsistema='CA' and extornado=0 
and tipotransacnivel1<>'E' and tipotransacnivel3 not in(0,3)
group by codigocuenta

declare @f smalldatetime
select @f=max(fechaproceso) from [10.0.2.14].finmas.dbo.tclparametros

create table #ca14(
codprestamo varchar(25),
SaldoCapitalTotal money,
SaldoSeguroTotal money,
CapitalAtrasado money,
InteresDevengado money,
CargoXMora money,
Iva money,
SeguroEnMora money,
saldohoy money,
saldoparaliquidar money,
CuotaPactada money,
proximopago varchar(10),
DiasMora money
)
declare @codprestamo varchar(25)
declare @nro int
declare @count int
select @count=count(*) from #Ptmos
set @nro=0
while (@nro<>@count)
begin
	set @nro=@nro+1
	select @codprestamo=codprestamo from #Ptmos where item=@nro

	insert into #ca14 (SaldoCapitalTotal,SaldoSeguroTotal,CapitalAtrasado,InteresDevengado,CargoXMora,Iva,SeguroEnMora,saldohoy,saldoparaliquidar,CuotaPactada,proximopago,DiasMora)
	exec [10.0.2.14].finmas.dbo.pTcCjRecuperacionSaldosCredito @codprestamo,@f

	update #ca14 set codprestamo=@codprestamo where codprestamo is null
end

Select s.item,s.codprestamo,case when c.saldoparaliquidar=0 then 0 else s.saldo end saldo
,s.estado,s.desembolso,s.monto,s.nrocuotaspagadas,c.saldohoy,c.saldoparaliquidar,c.proximopago
,isnull(t.pagado,0) pagado,c.diasmora
from #Ptmos s inner join #ca14 c on c.codprestamo=s.codprestamo
left outer join @trans t on t.codprestamo=s.codprestamo
--select * from #Ptmos
--order by item desc

drop table #Ptmos
drop table #ca14
GO