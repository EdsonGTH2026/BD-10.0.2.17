SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create function [dbo].[fCsValidarNumTransDataVsFinmas] (@CodCuenta varchar(20), @Renovado int)
returns varchar(10) as
BEGIN
declare @HayDif varchar(10)
declare @NumTranData int
declare @NumTranFinmas int

	set @HayDif = 'NO'
	--DATA vs FINMAS
	select 
	@NumTranData = count(td.NroTransaccion), @NumTranFinmas = count(tm.NroTrans)
	--count(td.NroTransaccion), count(tm.NroTrans)
	from finamigoconsolidado.dbo.tcstransacciondiaria as td with(nolock)
	left join [10.0.2.14].finmas.dbo.tahtransaccionmaestra as tm  on tm.CodCuenta = td.CodigoCuenta and tm.NroTrans = td.NroTransaccion and tm.CodTipoTrans = td.TipoTransacNivel3 and tm.codoficina = td.codoficina 
	where 	
	--td.codigocuenta +'-'+td.fraccioncta+'-' + cast(td.renovado as varchar(2)) = '098-211-06-2-5-00149-0-0' -- @NumCuenta 
	td.codigocuenta= @CodCuenta --'098-211-06-2-5-00149' 
	and td.renovado = @Renovado-- 1
	group by td.codigocuenta

	if @NumTranData = @NumTranFinmas
	begin 
		set @HayDif = 'OK'
	end
	else
	begin
		set @HayDif = 'Dif'
		return @HayDif
	end

	set @HayDif = ''
	--FINMAS vs DATA
	select 
	@NumTranFinmas = count(tm.NroTrans), @NumTranData = count(td.NroTransaccion)
	from  [10.0.2.14].finmas.dbo.tahtransaccionmaestra as tm 
	left join finamigoconsolidado.dbo.tcstransacciondiaria as td with(nolock) on tm.CodCuenta = td.CodigoCuenta and tm.NroTrans = td.NroTransaccion 
	where 	
	--tm.codcuenta +'-'+tm.fraccioncta+'-' + cast(tm.renovado as varchar(2)) = @NumCuenta 
	tm.codcuenta= @CodCuenta --'098-105-06-2-5-00199' 
	and tm.renovado = @Renovado--0
	group by tm.codcuenta

	if @NumTranData = @NumTranFinmas
	begin 
		set @HayDif = 'OK'
	end
	else
	begin
		set @HayDif = 'Dif'
	end

	return @HayDif 
END
GO