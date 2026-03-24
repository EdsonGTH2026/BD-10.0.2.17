SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [FinamigoConsolidado]
--GO
--/****** Object:  StoredProcedure [dbo].[pCsCaRecuperacionesVs3Res]    Script Date: 07/16/2014 11:22:05 ******/
--SET ANSI_NULLS OFF
--GO
--SET QUOTED_IDENTIFIER OFF
--GO
----drop procedure pCsCaRecuperacionesVs3
CREATE procedure [dbo].[pCsCaRecuperacionesVs3ResDia] @fecha SmalldateTime
as
--declare @fecha SmalldateTime
--set @fecha='20140620'

create table #fechas(fecha smalldatetime)

declare @ultimodiafebrero int
select @ultimodiafebrero=day(ultimodia) from tclperiodo where año=year(@Fecha) and mes=2

declare @f int
set @f=month(@Fecha)

while @f>0
begin
  --select isdate('20140230')
  --select isdate('20140132')
  declare @cadfecha varchar(8)
  set @cadfecha=cast(year(@Fecha) as varchar(4))
        +replicate('0',2-len(cast(@f as varchar(2))))+cast(@f as varchar(2))
        +replicate('0',2-len(cast(day(@Fecha) as varchar(2)))) + cast(day(@Fecha) as varchar(2))
        
  if(@f=2)
  begin
    if(day(@Fecha)<=@ultimodiafebrero)
    begin
      set @ultimodiafebrero=day(@Fecha)
    end
    set @cadfecha=cast(year(@Fecha) as varchar(4))
        +replicate('0',2-len(cast(@f as varchar(2))))+cast(@f as varchar(2))
        +replicate('0',2-len(cast(@ultimodiafebrero as varchar(2)))) + cast(@ultimodiafebrero as varchar(2))
  end
  
  if(isdate(@cadfecha)=0)
    begin
      set @cadfecha=cast(year(@Fecha) as varchar(4))
        +replicate('0',2-len(cast(@f as varchar(2))))+cast(@f as varchar(2))
        +replicate('0',2-len(cast(day(@Fecha)-1 as varchar(2)))) + cast(day(@Fecha)-1 as varchar(2))
        if(isdate(@cadfecha)=0)
          begin
            set @cadfecha=cast(year(@Fecha) as varchar(4))
            +replicate('0',2-len(cast(@f as varchar(2))))+cast(@f as varchar(2))
            +replicate('0',2-len(cast(day(@Fecha)-1 as varchar(2)))) + cast(day(@Fecha)-1 as varchar(2))
          end
    end
  
  insert #fechas
  values(
  --      cast(year(@Fecha) as varchar(4))
  --      +replicate('0',2-len(cast(@f as varchar(2))))+cast(@f as varchar(2))
  --      +replicate('0',2-len(cast(day(@Fecha) as varchar(2)))) + cast(day(@Fecha) as varchar(2))
  @cadfecha
  )
  set @f=@f-1
end

declare @periodo varchar(6)
set @periodo=dbo.fduFechaAPeriodo(@fecha)

select periodo,a.Anroop,a.AnroopN,a.AnroopR,a.AMontoPagado,a.AMontoPagadoN,a.AMontoPagadoR
from (
  SELECT f.fecha Periodo
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
  inner join #fechas f on dbo.fdufechaaperiodo(t.fecha)=dbo.fdufechaaperiodo(f.fecha)
  where t.codsistema='CA' and t.extornado=0
  and t.fecha>=substring(@periodo,1,4)+'0101' and t.fecha<=f.fecha--@fecha
  and t.TipoTransacNivel1<>'E'
  and t.tipotransacnivel3 not in (2,101,3)
  group by f.fecha
) a
order by periodo desc

drop table #fechas
GO