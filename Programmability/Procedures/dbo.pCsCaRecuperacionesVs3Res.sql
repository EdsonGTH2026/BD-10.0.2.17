SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
--drop procedure pCsCaRecuperacionesVs3
CREATE procedure [dbo].[pCsCaRecuperacionesVs3Res] @fecha SmalldateTime
as
--declare @fecha SmalldateTime
--set @fecha='20140620'

declare @periodo varchar(6)
set @periodo=dbo.fduFechaAPeriodo(@fecha)

select periodo,a.Anroop,a.AnroopN,a.AnroopR,a.AMontoPagado,a.AMontoPagadoN,a.AMontoPagadoR
from (
  SELECT dbo.fdufechaaperiodo(t.fecha) Periodo
  ,count(distinct t.codigocuenta) Anroop
  ,count(distinct(case when fc.ciclo=1 then t.codigocuenta else null end)) AnroopN
  ,count(distinct(case when fc.ciclo<>1 then t.codigocuenta else null end)) AnroopR
  ,sum(t.montototaltran) AMontoPagado
  ,sum(case when fc.ciclo=1 then t.montototaltran else 0 end) AMontoPagadoN
  ,sum(case when fc.ciclo<>1 then t.montototaltran else 0 end) AMontoPagadoR
  FROM tCsTransaccionDiaria t with(nolock)
  -->aqui
  left outer join (
    SELECT cl.codusuario, max(p.secuenciacliente) ciclo
    FROM tCspadronCarteradet p with(nolock)
    inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
    group by cl.codusuario
  ) fc on fc.codusuario=t.codusuario
  -->aqui
  where t.codsistema='CA' and t.extornado=0
  and t.fecha>=substring(@periodo,1,4)+'0101' and t.fecha<=@fecha
  and t.TipoTransacNivel1<>'E'
  and t.tipotransacnivel3 not in (2,101,3)
  group by dbo.fdufechaaperiodo(t.fecha)
) a
order by periodo desc
GO