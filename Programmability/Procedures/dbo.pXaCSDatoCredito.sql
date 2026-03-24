SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaCSDatoCredito '339-170-06-07-01977'
CREATE procedure [dbo].[pXaCSDatoCredito] @codprestamo varchar(25)
as
--declare @codprestamo varchar(25)
--set @codprestamo='339-170-06-07-01977'

create table #ca17(
	nrodiasatraso int,
	estado varchar(10),
	saldo money,
	capi money,
	inte money,
	iva money,
	mora money,
	seguro money
)
insert into #ca17
select c.nrodiasatraso,substring(pd.estadocalculado,1,1) + lower(substring(pd.estadocalculado,2,len(pd.estadocalculado))) estado
,sum(case when pd.estadocalculado='CANCELADO' then 0 else montodevengado-montopagado-montocondonado end) saldo
,sum(case when pd.estadocalculado='CANCELADO' then 0 else case when codconcepto='CAPI' then montodevengado-montopagado-montocondonado else 0 end end) capi
,sum(case when pd.estadocalculado='CANCELADO' then 0 else case when codconcepto='INTE' then montodevengado-montopagado-montocondonado else 0 end end) inte
,sum(case when pd.estadocalculado='CANCELADO' then 0 else case when codconcepto in('IVAIT','IVAMO') then montodevengado-montopagado-montocondonado else 0 end end) iva
,sum(case when pd.estadocalculado='CANCELADO' then 0 else case when codconcepto='MORA' then montodevengado-montopagado-montocondonado else 0 end end) mora
,sum(case when pd.estadocalculado='CANCELADO' then 0 else case when codconcepto in('SDV') then montodevengado-montopagado-montocondonado else 0 end end) seguro
from tcspadronplancuotas p with(nolock)
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=p.codprestamo and pd.codusuario=p.codusuario
inner join tcscarteradet d with(nolock) on d.codprestamo=pd.codprestamo and d.codusuario=pd.codusuario and d.fecha=pd.fechacorte
inner join tcscartera c with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where p.codprestamo=@codprestamo--'339-170-06-07-01977'
group by c.nrodiasatraso,pd.estadocalculado

declare @f smalldatetime
select @f=max(fechaproceso) from [10.0.2.14].finmas.dbo.tclparametros

create table #ca14(
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

insert into #ca14
exec [10.0.2.14].finmas.dbo.pTcCjRecuperacionSaldosCredito @codprestamo,@f

Select s.*,c.saldohoy,c.saldoparaliquidar,c.proximopago
from #ca17 s cross join #ca14 c

drop table #ca17
drop table #ca14
GO