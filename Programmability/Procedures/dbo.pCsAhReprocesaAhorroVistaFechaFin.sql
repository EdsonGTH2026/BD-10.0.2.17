SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhReprocesaAhorroVistaFechaFin] @codcuenta varchar(25),@fraccioncta varchar(5),@renovado int,@fmin smalldatetime
as
set nocount on
--declare @fmin smalldatetime
--declare	@codcuenta varchar(25)
--declare	@fraccioncta varchar(5)
--declare @renovado int
--set @fmin='20210713'
--set @codcuenta='002-102-06-2-0-00313'--'084-105-06-2-1-00085'
--set @fraccioncta='0'
--set @renovado=0

declare @fecini smalldatetime
select @fecini='20210601'

create table #tcsah(
	fecha smalldatetime,
	codcuenta varchar(25),
	fraccioncta varchar(5),
	renovado int,
	fechaapertura smalldatetime,
	tasainteres money,
	saldocuenta money,
	interescalculado money,
	intacumulado money,
	calculado money,
	acumulado money,
	pagado money,
	intcap money,
	cappag money,
	fechavencimiento smalldatetime
)
insert into #tcsah(fecha,codcuenta,fraccioncta,renovado,fechaapertura,tasainteres,saldocuenta,interescalculado,intacumulado,fechavencimiento)
select fecha,codcuenta,fraccioncta,renovado,fechaapertura,tasainteres,saldocuenta,interescalculado,intacumulado,fechavencimiento
from tcsahorros with(nolock)
where codcuenta=@codcuenta and fraccioncta=@fraccioncta and renovado=@renovado
and fecha>=@fecini
--and fecha<=@fecfin
order by fecha

--declare @fecini smalldatetime
----select @fecini=min(fecha) from #tcsah
--select @fecini='20210701'
declare @fecfin smalldatetime
select @fecfin=max(fecha) from #tcsah

while (@fecini<=@fecfin)
begin
	UPDATE #tcsah 
	SET calculado = case when fechavencimiento is null then round((cast(tasainteres as decimal(16,4))/360/100)*saldocuenta,4)
					else
						case when fecha<fechavencimiento then round((cast(tasainteres as decimal(16,2))/360)*cast(saldocuenta as decimal(16,2))/100,4) else 0 end
					end
	WHERE fecha=@fecini	

	declare @acumulado money
	declare @capitalanterior money
	select @acumulado=isnull(acumulado,0) from #tcsah WHERE fecha=@fecini-1

	--if (isnull(@capitalanterior,0)=0)
	--begin
	--	select @capitalanterior=saldocuenta from #tcsah WHERE fecha=@fecini
	--end
		
	-- ACUMULA LOS INTERESES 
	UPDATE #tcsah 
	set acumulado= case when fecha in(select ultimodia from tclperiodo) then 0 else calculado+isnull(@acumulado,0) end
	--SET Acumulado = case when isnull(@acumulado,0) + calculado - isnull(@m,0)<0 and abs(isnull(@acumulado,0) + calculado - isnull(@m,0))<1 then 0 else isnull(@acumulado,0) + calculado - isnull(@m,0) end
					--,pagado=@m
					--,saldocuenta = case when fecha in(select ultimodia from tclperiodo) then @capitalanterior+isnull(@acumulado,0) else saldocuenta end
					--,cappag=isnull(@cap,0)
	--SET Acumulado = case when @fecini='20190531' then 0 else isnull(@acumulado,0) + calculado - isnull(@m,0) end,pagado=@m
	WHERE fecha=@fecini

	set @fecini =dateadd(day,1,@fecini)
end

--select * from #tcsah
update tcsahorros
set intacumulado=acumulado--,interescalculado=calculado
from tcsahorros a
inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha
where a.fecha>=@fmin

drop table #tcsah

GO