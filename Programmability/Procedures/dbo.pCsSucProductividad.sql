SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsSucProductividad] @zona varchar(5)
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
--declare @zona varchar(5)
--set @zona='Z14'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codoficina
from tcloficinas
where zona=@zona

create table #ptmos ( fecha smalldatetime,region varchar(50),sucursal varchar(50), promotor  varchar(50),creditosxdia money, crecimiento int,creditosdesembolsados int)
insert into #ptmos
select distinct fecha,region,sucursal,promotor,(case when @nro=0 then 0 else asi_nro_des/@nro end),crecimiento,asi_nro_des
from tcsacrecimientopromotor with(nolock)
where codoficina not in('97','230','231')
and codoficina in(select codigo from @sucursales)
   
select * from #ptmos where promotor <> 'huerfano'
order by sucursal
 
drop table #ptmos 
--SELECT * 
--FROM Tcsacrecimientopromotor
GO