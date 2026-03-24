SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptSaldosViAtVe] @codoficina varchar(500)
as
set nocount on
--declare @codoficina varchar(500)
--set @codoficina='4,5,6,15'

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from @sucursales)

select @fecha fecha,sucursal
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0a7nroptmo) VigenteNro,sum(D0a7saldo) VigenteSaldo, (sum(D0a7saldo)/sum(saldocapital))*100 VigentePor
,count(distinct D8a30nroptmo) AtrasoNro,sum(D8a30saldo) AtrasoSaldo, (sum(D8a30saldo)/sum(saldocapital))*100 AtrasoPor
,count(distinct D31nroptmo) VencidoNro,sum(D31saldo) VencidoSaldo, (sum(D31saldo)/sum(saldocapital))*100 VencidoPor
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
  ,cd.saldocapital
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D0a7nroptmo
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D0a7saldo

  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D8a30nroptmo
  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D8a30saldo

  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31nroptmo
  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31saldo
   
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  where c.fecha=@fecha and c.cartera='ACTIVA'
  --and c.codoficina not in('97','231','231')
  and c.codprestamo in(select codprestamo from #ptmos)

) a
group by sucursal

drop table #ptmos
GO