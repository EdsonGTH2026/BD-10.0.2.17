SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptCicloPromotor] @codoficina varchar(2000)
as
set nocount on
--declare @codoficina varchar(500)
--set @codoficina='37'

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
where fecha=@fecha--@fecini
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from @sucursales)

select @fecha fecha,sucursal,promotor,max(isnull(antiguedad,0)) antiguedad
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital

,count(distinct D1a2nroptmo) D1a2nroptmo,sum(D1a2saldo31) D1a2saldo,sum(D1a2saldoCi) D1a2saldoCi
,count(distinct D3a4nroptmo) D3a4nroptmo,sum(D3a4saldo31) D3a4saldo,sum(D3a4saldoCi) D3a4saldoCi
,count(distinct D5a6nroptmo) D5a6nroptmo,sum(D5a6saldo31) D5a6saldo,sum(D5a6saldoCi) D5a6saldoCi
,count(distinct D7nroptmo) D7nroptmo,sum(D7saldo31) D7saldo,sum(D7saldoCi) D7saldoCi

,(case when sum(D1a2saldoCi)=0 then 0 else sum(D1a2saldo31)/sum(D1a2saldoCi) end)*100 DM1a2imor
,(case when sum(D3a4saldoCi)=0 then 0 else sum(D3a4saldo31)/sum(D3a4saldoCi) end)*100 DM3a4imor
,(case when sum(D5a6saldoCi)=0 then 0 else sum(D5a6saldo31)/sum(D5a6saldoCi) end)*100 DM5a6imor
,(case when sum(D7saldoCi)=0 then 0 else sum(D7saldo31)/sum(D7saldoCi) end)*100 DM7imor

from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal,cd.saldocapital
  
  	  ,case when pd.secuenciacliente>=0 and pd.secuenciacliente<=2 then 		
				case when c.NroDiasAtraso>=31 then cd.codprestamo else null end
			else null end D1a2nroptmo
	  ,case when pd.secuenciacliente>=0 and pd.secuenciacliente<=2 then 			
				case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end
			else 0 end D1a2saldo31
	  ,case when pd.secuenciacliente>=0 and pd.secuenciacliente<=2 then cd.saldocapital else 0 end D1a2saldoCi

	  ,case when pd.secuenciacliente>=3 and pd.secuenciacliente<=4 then
				case when c.NroDiasAtraso>=31 then cd.codprestamo else null end
			else null end D3a4nroptmo
	  ,case when pd.secuenciacliente>=3 and pd.secuenciacliente<=4 then 
				case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end
			else 0 end D3a4saldo31
	  ,case when pd.secuenciacliente>=3 and pd.secuenciacliente<=4 then cd.saldocapital else 0 end D3a4saldoCi

	  ,case when pd.secuenciacliente>=5 and pd.secuenciacliente<=6 then
				case when c.NroDiasAtraso>=31 then cd.codprestamo else null end
			else null end D5a6nroptmo
	  ,case when pd.secuenciacliente>=5 and pd.secuenciacliente<=6 then
				case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end
			else 0 end D5a6saldo31
	  ,case when pd.secuenciacliente>=5 and pd.secuenciacliente<=6 then cd.saldocapital else 0 end D5a6saldoCi

	  ,case when pd.secuenciacliente>=7 then 
				case when c.NroDiasAtraso>=31 then cd.codprestamo else null end
			else null end D7nroptmo
	  ,case when pd.secuenciacliente>=7 then
				case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end
			else 0 end D7saldo31
	  ,case when pd.secuenciacliente>=7 then cd.saldocapital else 0 end D7saldoCi

  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombres +' '+ cl.paterno end promotor
  ,datediff(month,ex.ingreso,@fecha) antiguedad
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
  left outer join tcsempleados ex with(nolock) on ex.codusuario=c.codasesor
  inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=cd.codprestamo and pd.codusuario=cd.codusuario
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
  --and c.NroDiasAtraso<31
) a
group by sucursal,promotor

drop table #ptmos

--pCsCaRptCicloPromotor '37'
GO