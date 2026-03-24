SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACarteraxGenero] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20181031'

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

select sucursal,genero
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,sum(saldocartera) saldocartera
,count(distinct D0a7nroptmo) D0a7nroptmo,sum(D0a7saldo) D1a7saldo, (sum(D0a7saldo)/sum(saldocapital))*100 D0a7Por
,count(distinct D8a30nroptmo) D8a30nroptmo,sum(D8a30saldo) D8a30saldo, (sum(D8a30saldo)/sum(saldocapital))*100 D8a30Por
,count(distinct Dm31nroptmo) Dm31nroptmo,sum(Dm31saldo) Dm31saldo, (sum(Dm31saldo)/sum(saldocapital))*100 DM31Por
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,cd.saldocapital,c.codoficina,o.nomoficina sucursal,case when cl.sexo=1 then 'M' else 'F' end genero
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
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=cd.codusuario
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
) a
group by sucursal,genero

drop table #ptmos

--select top 100 * from tcspadronclientes
GO

GRANT EXECUTE ON [dbo].[pCsCACarteraxGenero] TO [marista]
GO

GRANT EXECUTE ON [dbo].[pCsCACarteraxGenero] TO [public]
GO