SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhCalculaIntPeriodicoAcumulado] (@codcuenta varchar(25), @renovado int, @FecInicial smalldatetime, @FecFinal smalldatetime)
as
begin  
--Ver. 16-03-2021

	set nocount on
	--declare	@codcuenta varchar(25)
	declare	@fraccioncta varchar(5)
	--declare @renovado int
	--set @codcuenta='098-211-06-2-5-00221'
	set @fraccioncta='0'
	--set @renovado=0

	create table #tcsah(
		fecha smalldatetime,
		codcuenta varchar(25),
		fraccioncta varchar(5),
		renovado int,
		tasainteres money,
		saldocuenta money,
		interescalculado money,
		intacumulado money,
		calculado money,
		acumulado money,
		pagado money
	)
	insert into #tcsah(fecha,codcuenta,fraccioncta,renovado,tasainteres,saldocuenta,interescalculado,intacumulado)
	select fecha,codcuenta,fraccioncta,renovado,tasainteres,saldocuenta,interescalculado,intacumulado
	from tcsahorros with(nolock)
	where codcuenta=@codcuenta and fraccioncta=@fraccioncta and renovado=@renovado
	order by fecha

	--select * from #tcsah

	declare @fecini smalldatetime
	select @fecini=min(fecha) from #tcsah
	declare @fecfin smalldatetime
	select @fecfin=max(fecha) from #tcsah

	while (@fecini<=@fecfin)
	begin
		-- CALCULA EL DEVENGAMIENTO PARA PLAZOS FIJOS PERIODICOS
		UPDATE #tcsah 
		SET calculado = round((cast(tasainteres as decimal(16,2))/360)*cast(saldocuenta as decimal(16,2))/100,2)-- CUM se cambia para que se calcule directo el interes calculado diario 26.11.2018
		WHERE fecha=@fecini

		declare @acumulado money
		select @acumulado=isnull(acumulado,0) from #tcsah WHERE fecha=@fecini-1
		
		--select @acumulado as '@acumulado'   -comentar

		declare @m money
		SELECT @m=isnull(sum(monto),0) --monto
		from [10.0.2.14].finmas.dbo.tAhIntPeriodicos 
		WHERE CodCuenta=@codcuenta
		and FraccionCta=@fraccioncta and Renovado=@renovado and tipopago='INT'
		--and fechapagado=@fecini
		--and convert(smalldatetime,convert(char(10),fechapagado,103),103)=@fecini
		and convert(char(10),fechapagado,112)= convert(char(10),@fecini,112)

		-- ACUMULA LOS INTERESES 
		UPDATE #tcsah 
		SET Acumulado =  isnull(@acumulado,0) + calculado - isnull(@m,0),pagado=@m
		WHERE fecha=@fecini
		
		--select * from #tcsah WHERE fecha=@fecini --comentar
		set @fecini =dateadd(day,1,@fecini)
	end

	--select * from #tcsah
	select * from #tcsah where fecha >= @FecInicial 
	order by fecha
	
	declare @dif money
	select @dif = abs(intacumulado - acumulado) from #tcsah where fecha = @fecfin-- @Fecfinal
	
	if @dif > 0 
	begin
		print 'hay diferencia'
		
		--Actualiza DATA
		update tcsahorros
		set intacumulado=acumulado,interescalculado=calculado
		from tcsahorros a
		inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha
		where a.fecha>= '20210301'  --  @FecInicial --'20200301' --Solo actualiza del mes actual de agosto
	
		declare @acumulado2 money
		select @acumulado2 = intacumulado from tcsahorros where CodCuenta=@codcuenta and fraccioncta='0' and renovado=@renovado and fecha = @fecfin
				
		--Actualiza Finmas
		if @acumulado2 > 0
		begin
			update [10.0.2.14].finmas.dbo.tahcuenta set
			intAcumulado = @acumulado2
			WHERE CodCuenta=@codcuenta and fraccioncta='0' and renovado=@renovado
		end
	end
	else
	begin
		print 'no hay diferencia'
	end
	
	--select * from #tcsah --where fecha >= '20190101' order by fecha

	drop table #tcsah

end
GO