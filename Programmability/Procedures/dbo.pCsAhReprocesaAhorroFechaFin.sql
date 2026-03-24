SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAhReprocesaAhorroFechaFin] @codcuenta varchar(25),@fraccioncta varchar(5),@renovado int,@fecfin smalldatetime
as
set nocount on
--declare @fecfin smalldatetime
--declare	@codcuenta varchar(25)
--declare	@fraccioncta varchar(5)
--declare @renovado int

--set @fecfin='20210731'
--set @codcuenta='098-211-06-2-0-00414'
--set @fraccioncta='0'
--set @renovado=1

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
and fecha<=@fecfin
order by fecha

declare @fecini smalldatetime
select @fecini=min(fecha) from #tcsah
--declare @fecfin smalldatetime
--select @fecfin=max(fecha) from #tcsah

while (@fecini<=@fecfin)
begin
	-- CALCULA EL DEVENGAMIENTO PARA PLAZOS FIJOS PERIODICOS
	--UPDATE #tcsah 
	--SET calculado = round((cast(tasainteres as decimal(16,2))/360)*cast(saldocuenta as decimal(16,2))/100,2)-- CUM se cambia para que se calcule directo el interes calculado diario 26.11.2018
	--WHERE fecha=@fecini

	UPDATE #tcsah 
	SET calculado = case when fechavencimiento is null then round((cast(tasainteres as decimal(16,2))/360)*cast(saldocuenta as decimal(16,2))/100,2)
					else
						case when fecha<fechavencimiento then round((cast(tasainteres as decimal(16,2))/360)*cast(saldocuenta as decimal(16,2))/100,2) else 0 end
					end
	WHERE fecha=@fecini	

	declare @acumulado money
	declare @capitalanterior money
	select @acumulado=acumulado,@capitalanterior=saldocuenta from #tcsah WHERE fecha=@fecini-1

	if (isnull(@capitalanterior,0)=0)
	begin
		select @capitalanterior=saldocuenta from #tcsah WHERE fecha=@fecini
	end

	declare @m money
	declare @cap money
	set @m=0
	set @cap=0
	SELECT @m=isnull(sum(monto),0) --monto
	from tCsIntPeriodicos 
	WHERE CodCuenta=@codcuenta
	and FraccionCta=@fraccioncta and Renovado=@renovado and tipopago='INT'
	--and fechapagado=@fecini
	and convert(smalldatetime,convert(char(10),fechareal,103),103)=@fecini
	
	SELECT @cap=isnull(sum(monto),0) --monto
	from tCsIntPeriodicos 
	WHERE CodCuenta=@codcuenta
	and FraccionCta=@fraccioncta and Renovado=@renovado and tipopago='AMO'
	--and fechapagado=@fecini
	and convert(smalldatetime,convert(char(10),fechareal,103),103)=@fecini

	declare @intca money
	set @intca=0
	SELECT @intca=isnull(InteresReinvertir,0)
	from --[10.0.2.14].finmas.dbo. select * from 
	tcsIntPeriodicosDetVariable
	WHERE CodCuenta=@codcuenta and FraccionCta=@fraccioncta and Renovado=@renovado 
	and nropago in(
		SELECT nropago from tCsIntPeriodicos
		WHERE CodCuenta=@codcuenta and FraccionCta=@fraccioncta and Renovado=@renovado and tipopago='INT'
		--and fechapagado=@fecini
		and convert(smalldatetime,convert(char(10),fechapagado,103),103)=@fecini
	)
	
	-- ACUMULA LOS INTERESES 
	UPDATE #tcsah 
	SET Acumulado = case when isnull(@acumulado,0) + calculado - isnull(@m,0)<0 and abs(isnull(@acumulado,0) + calculado - isnull(@m,0))<1 then 0 else isnull(@acumulado,0) + calculado - isnull(@m,0) end
					,pagado=@m
					,saldocuenta=@capitalanterior-isnull(@cap,0)+isnull(@intca,0),intcap=isnull(@intca,0)
					,cappag=isnull(@cap,0)
	--SET Acumulado = case when @fecini='20190531' then 0 else isnull(@acumulado,0) + calculado - isnull(@m,0) end,pagado=@m
	WHERE fecha=@fecini

	set @fecini =dateadd(day,1,@fecini)
end

select codcuenta,fraccioncta,renovado,acumulado from #tcsah with(nolock) where fecha=@fecfin

drop table #tcsah

GO