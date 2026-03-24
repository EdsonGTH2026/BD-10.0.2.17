SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsNacProductividad] 
as
declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion

declare @fec smalldatetime
set @fec=dateadd(day,(-1)*day(@Fecfin),@Fecfin)+1

declare @fechas table(fecha smalldatetime)
while(@fec<=@Fecfin)
begin
          --print dbo.fdufechaatexto(@fec,'DD-MM-AAAA') + ' ' + str(datepart(weekday,@fec))
          if(datepart(weekday,@fec) not in (1,7))
          begin
                    declare @x int
                    select @x=count(*) from tcaclfechasnoven with(nolock) where fechanoven=@fec
                    --print @x
                    if (@x=0)
                    begin
                              insert into @fechas
                              select @fec
                    end 
          end
          set @Fec=@Fec+1
end

declare @nro money
select @nro=count(*)
from @fechas


create table #ptmos (region varchar(50), asi_nro_des int, crecimiento int)
insert into #ptmos
select distinct region, sum(asi_nro_des),sum(crecimiento)
from tcsacrecimientopromotor with(nolock)
where codoficina not in('97','230','231')
and promotor <> 'huerfano'
group by region

select @fecfin fecha, case when @nro =0 then 0 else asi_nro_des/@nro end creditosxdia, * 
from #ptmos 
order by region
 
drop table #ptmos
GO