SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhCorregirMontoPagoIntPerSTP](@codcuenta varchar(20), @renovado int, @montoOriginal money)
as
BEGIN
	declare @Monto money 
	declare @NroPago int
	declare @NroTransaccion int
	
	select top 1
	@Monto = Monto,
	@NroPago = NroPago
	from [10.0.2.14].finmas.dbo.tahintperiodicos where codcuenta = @codcuenta and renovado = @renovado 
	and FechaPagado >= '20210101' and FechaPagado <= '20210131'
	
	select @Monto, @NroPago
	
	select 
	@NroTransaccion = NroTrans
	from [10.0.2.14].finmas.dbo.tahtransaccionmaestra
	where codcuenta = @codcuenta and renovado = @renovado
	and CodTipoTrans = 3
	and Observacion like '%SPEI%'
	and MontoTotal = @montoOriginal
	and fecha >= '20210101' and fecha <= '20210131'
	
	select @NroTransaccion as '@NroTransaccion'
	
	if isnull(@NroTransaccion,-1) = -1
	begin
		print 'no se pudo obtener @NroTransaccion'
		return 0
	end
	print 'Actualiza datos'

	--update [10.0.2.14].finmas.dbo.tahtransaccionmaestra set
	--MontoTotal = @Monto,
	--Observacion = Observacion + ', ' + convert(varchar,@montoOriginal) 
	--where codcuenta = @codcuenta and renovado = @renovado
	--and CodTipoTrans = 3
	--and Observacion like '%SPEI%'
	--and MontoTotal = @montoOriginal
	--and NroTrans = @NroTransaccion
	--and fecha >= '20210101' and fecha <= '20210131'	
	
	update finamigoconsolidado.dbo.tcstransacciondiaria set
	MontoTotalTran = @Monto,
	DescripcionTran = DescripcionTran + ', ' + convert(varchar,@montoOriginal) 
	where codigocuenta = @codcuenta and renovado = @renovado
	and DescripcionTran like '%STP%'
	and TipoTransacNivel3 = 3
	and NroTransaccion = @NroTransaccion
	and fecha >= '20210101' and fecha <= '20210131'
	
	select * from finamigoconsolidado.dbo.tcstransacciondiaria 
	where codigocuenta = @codcuenta and renovado = @renovado
	and DescripcionTran like '%STP%'
	and TipoTransacNivel3 = 3
	and NroTransaccion = @NroTransaccion
	and fecha >= '20210101' and fecha <= '20210131'

END
GO