SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[BI_CapitalxBuckets] as

declare @fechaactual smalldatetime
select @fechaactual = fechaconsolidacion from vcsfechaconsolidacion

declare @fechacorte smalldatetime
--select @fechacorte = fechaconsolidacion from vcsfechaconsolidacion
set @fechacorte = '20240414'--DATEADD(day,-(7*15),@fechaactual)

declare @fechafin smalldatetime
set @fechafin = dateadd(day,7,@fechacorte)

CREATE TABLE #Consolidado
(fecha smalldatetime,
Ptmos int,
Saldo money,
cubeta varchar(50),
pago money,
MontoTotalTran money)


While @fechacorte <= @fechaactual

Begin

select codprestamo, nrodiasatraso, saldocapital
,case when nrodiasatraso >= 90 then 'h.90+'
      when nrodiasatraso > 60 then 'g.61-90'
	  when nrodiasatraso > 30 then 'f.31-60'
	  when nrodiasatraso >= 22 then 'e.22-30'
	  when nrodiasatraso >= 16 then 'd.16-21'
	  when nrodiasatraso >= 8 then 'c.8-15'
	  when nrodiasatraso > 0 then 'b.1-7'
	  else 'a.0' end Cubeta
into #Cartera
from tcscartera with(nolock) 
where fecha = @fechacorte
  and codoficina not in('97','98','231','230','999') 
and cartera='ACTIVA'
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))

select CodigoCuenta, MontoCapitalTran, MontoTotalTran
into #trans
from tCsTransaccionDiaria
where CodigoCuenta in (select CodPrestamo from #Cartera)
and fecha > @fechacorte and fecha < @fechafin
--and Fecha not in ('20240929')
and codSistema='CA'
and tipoTransacNivel3=104
and extornado=0


insert into #Consolidado

select @fechacorte fecha, count(c.codprestamo) Ptmos, sum(c.saldocapital) Saldo, c.cubeta
, isnull(SUM(t.MontoCapitalTran),0) pago, isnull(SUM(t.MontoTotalTran),0) TotalTran
from #Cartera c
left outer join #trans t on t.CodigoCuenta = c.CodPrestamo
group by c.cubeta





drop table #Cartera
drop table #trans

set @fechacorte = dateadd(day,7,@fechacorte)
set @fechafin = case when dateadd(day,7,@fechafin) > @fechaactual then @fechaactual else dateadd(day,7,@fechafin) end

end

select * from #Consolidado

drop table #Consolidado
GO