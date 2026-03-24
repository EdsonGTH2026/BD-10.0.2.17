SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Drop Procedure pCsCaDesembolsosRecuperaciones 
-- Exec pCsCaDesembolsosRecuperacionesVs2  '20140424'
CREATE PROCEDURE  [dbo].[pCsCaDesembolsosRecuperacionesVs2ResDia] @Fecha SmalldateTime
AS
--declare @Fecha SmalldateTime
--set @Fecha='20140714'
--declare @Fecha SmalldateTime
--set @Fecha='20140720'
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
--select * from #fechas
--drop table #fechas

declare @periodo varchar(6)
set @periodo=dbo.fduFechaAPeriodo(@fecha)

SELECT f.fecha periodo
,count(distinct(case when secuenciacliente=1 then codprestamo else null end)) nrodesemanualN
,count(distinct(case when secuenciacliente=1 then codusuario else null end)) nrodesemanualNClie
,sum(case when secuenciacliente=1 then monto else null end) montodesemanualN
,count(distinct(case when secuenciacliente>1 then codprestamo else null end)) nrodesemanualRClie
,count(distinct(case when secuenciacliente>1 then codusuario else null end)) nrodesemanualR
,sum(case when secuenciacliente>1 then monto else null end) montodesemanualR
,count(distinct(codprestamo)) nro
,count(distinct(codusuario)) nroClie
,sum(monto) monto
FROM tCsPadronCarteraDet with(nolock)
inner join #fechas f on dbo.fdufechaaperiodo(desembolso)=dbo.fdufechaaperiodo(f.fecha)
where desembolso>=substring(@periodo,1,4)+'0101' and desembolso<=f.fecha
and TipoReprog='SINRE' and codoficina<>'98'
group by f.fecha 
order by f.fecha  desc

drop table #fechas
GO