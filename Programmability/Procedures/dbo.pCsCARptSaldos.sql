SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsCARptSaldos '20180930','20181031'
CREATE procedure [dbo].[pCsCARptSaldos] @fecini smalldatetime,@fecfin smalldatetime
as
--declare @fecfin smalldatetime
--declare @fecini smalldatetime

--set @fecfin='20181031'
--set @fecini='20180930'

create table #ptmos1 (codprestamo varchar(25))
insert into #ptmos1
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecini
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

create table #ptmos2 (codprestamo varchar(25))
insert into #ptmos2
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecfin
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

select sucursal,promotor,codasesor,ingreso,sum(D0a7saldo) INI_D1a7saldo,sum(D8a30saldo) INI_D8a30saldo,sum(Dm31saldo) INI_Dm31sald
,count(distinct D0a7nroptmo) INI_D0a7nroptmo,count(distinct D8a30nroptmo) INI_D8a30nroptmo,count(distinct Dm31nroptmo) INI_Dm31nroptmo
,count(distinct codprestamo) INI_Nroptmo
into #CAini
from (
  SELECT c.Fecha,c.CodPrestamo,o.nomoficina sucursal,co.nombrecompleto promotor,e.ingreso,p.ultimoasesor codasesor
  ,cd.saldocapital
  ,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end
   else null end D0a7nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end 
   else 0 end D0a7saldo
  
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end
   else null end D8a30nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end
   else 0 end D8a30saldo

  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end Dm31nroptmo
  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end Dm31saldo
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  left outer join tcspadronclientes co with(nolock) on co.codusuario=p.ultimoasesor
  left outer join tcsempleados e on e.codusuario=co.codusuario
  where c.fecha=@fecini and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos1)
) a
group by sucursal,promotor,codasesor,ingreso

select sucursal,promotor,codasesor,ingreso,sum(D0a7saldo) FIN_D1a7saldo,sum(D8a30saldo) FIN_D8a30saldo,sum(Dm31saldo) FIN_Dm31sald
,count(distinct D0a7nroptmo) FIN_D0a7nroptmo,count(distinct D8a30nroptmo) FIN_D8a30nroptmo,count(distinct Dm31nroptmo) FIN_Dm31nroptmo
,count(distinct codprestamo) FIN_Nroptmo
into #CAfin
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal,co.nombrecompleto promotor,e.ingreso,p.ultimoasesor codasesor
  ,cd.saldocapital
  ,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end
   else null end D0a7nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end 
   else 0 end D0a7saldo
  
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end
   else null end D8a30nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end
   else 0 end D8a30saldo

  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end Dm31nroptmo
  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end Dm31saldo
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  left outer join tcspadronclientes co with(nolock) on co.codusuario=p.ultimoasesor
  left outer join tcsempleados e on e.codusuario=co.codusuario
  where c.fecha=@fecfin and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos2)
) a
group by sucursal,promotor,codasesor,ingreso

--sucursal
--promotor
--f. ingreso

--(capital + interes) (solo cartera activa) INICIAL
--SaldoVigente (0-7)
--SaldoAtrasado (8-30)
--SaldoVencido (31+)

--(capital + interes) (solo cartera activa) FINAL
--SaldoVigente (0-7)
--SaldoAtrasado (8-30)
--SaldoVencido (31+)

--Cartera nro clientes final		
--NroClientesVig (0-7)
--NroClientesAtr(8-30)
--NroClientesVenc(31+)

--NroClientesInicial (0-30)		--> N
--NroClientesAsignados			--> O
--NroClientesFinal (0-30)		--> P

--Crecimiento -->=(P4-N4)-O4

--select * from #CAini
select isnull(f.sucursal,i.sucursal) sucursal
,isnull(f.promotor,i.promotor) promotor,isnull(f.ingreso,i.ingreso) ingreso
,i.INI_D1a7saldo,i.INI_D8a30saldo,i.INI_Dm31sald
,f.FIN_D1a7saldo,f.FIN_D8a30saldo,f.FIN_Dm31sald
,f.FIN_D0a7nroptmo,f.FIN_D8a30nroptmo,f.FIN_Dm31nroptmo
,i.INI_Nroptmo
,f.FIN_Nroptmo
from #CAfin f
full outer join #CAini i on i.sucursal=f.sucursal and i.promotor=f.promotor
--536

drop table #ptmos1
drop table #ptmos2
drop table #CAini
drop table #CAfin
GO

GRANT EXECUTE ON [dbo].[pCsCARptSaldos] TO [marista]
GO