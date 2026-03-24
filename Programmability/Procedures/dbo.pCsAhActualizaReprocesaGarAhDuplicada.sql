SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhActualizaReprocesaGarAhDuplicada] (@CodProducto varchar(3), @CodCuenta varchar(20),@NroTransBorrar integer,@MontoTotal money,@FecTransaccion smalldatetime)
as
set nocount on
/*
declare @CodCuenta varchar(20)
declare @NroTransBorrar integer
declare @MontoTotal money
declare @FecTransaccion smalldatetime

set @CodCuenta = '025-111-06-2-8-00775'
set @NroTransBorrar = 450543
set @MontoTotal = 473.37
set @FecTransaccion = '20200109'
*/

declare @CodOficina varchar(3)
declare @Fec smalldatetime
declare @FecIni smalldatetime
declare @FecHoy smalldatetime

declare @Credito money              
declare @Debito money               
declare @Saldo money
declare @NroTrans integer

set @CodOficina = substring(@CodCuenta,1,3)
set @CodOficina = convert(varchar,convert(int,@CodOficina))
select @FecIni = FechaApertura from [10.0.2.14].finmas.dbo.tahcuenta where codcuenta = @CodCuenta
select @FecHoy = FechaUltCierre from [10.0.2.14].finmas.dbo.tClParametros where convert(int,CodOficina) = convert(int, @CodOficina)

print '@CodCuenta[' + convert(varchar,@CodCuenta) + '], @Fec[' + convert(varchar,@FecIni, 112) + '], @FecHoy[' + convert(varchar,@FecHoy, 112) + ']'

--select top 10 * from tAhDetalleTransMaestra where codoficina = @CodOficina and NroTrans = @NroTransBorrar
--select * from tahtransaccionmaestra where codcuenta = @CodCuenta and NroTrans = @NroTransBorrar and montototal = @MontoTotal

if @NroTransBorrar <> 0 and @MontoTotal <> 0
begin
	print 'Elimina transaccion duplicada'
	--Elimina la transaccion duplicada en Finmas
	delete from [10.0.2.14].finmas.dbo.tAhDetalleTransMaestra where CodOficina = @CodOficina and NroTrans = @NroTransBorrar
	delete from [10.0.2.14].finmas.dbo.tahtransaccionmaestra where codcuenta = @CodCuenta and NroTrans = @NroTransBorrar and montototal = @MontoTotal
	
	--Elimina la transaccion duplicada en Data
	delete from finamigoconsolidado.dbo.tCsTransaccionDiaria where CodigoCuenta = @CodCuenta and fecha = @FecTransaccion and NroTransaccion= @NroTransBorrar and MontoTotalTran = @MontoTotal
end

--Genera el extracto de la cuenta para obtener los saldo segun los movimientos
exec [10.0.2.14].finmas.dbo.pAhGeneraExtracto @CodCuenta,'0',0,@FecIni,@FecHoy,'xxx'
--SELECT * FROM tAhAuxExtracto WHERE Usuario='xxx' ORDER BY Fecha, NroTrans compute sum(credito), sum(debito) 

SELECT CodCuenta, Fecha, Descripcion, Credito, Debito, Saldo 
FROM [10.0.2.14].finmas.dbo.tAhAuxExtracto WHERE Usuario='xxx' 
ORDER BY Fecha, NroTrans 

set @Fec = @FecIni
set @Credito = 0              
set @Debito = 0               
set @Saldo = 0

--Obtiene el saldo inicial
select @Saldo = Saldo
FROM [10.0.2.14].finmas.dbo.tAhAuxExtracto WHERE Usuario='xxx' and Descripcion = 'SALDO ANTERIOR' and CodCuenta = @CodCuenta
set @Saldo = isnull(@Saldo,0)
	
while @Fec <= @FecHoy
begin	
	set @Credito = 0              
	set @Debito = 0  
	set @NroTrans = 0

	SELECT  --CodCuenta, Fecha, Descripcion, Credito, Debito, Saldo
	@Credito = sum(Credito), @Debito = sum(Debito) --, @NroTrans = NroTrans --, @Saldo=Saldo  
	FROM [10.0.2.14].finmas.dbo.tAhAuxExtracto WHERE Usuario='xxx' and convert(varchar,Fecha,112) = convert(varchar,@Fec,112) and CodCuenta = @CodCuenta 
	--order by NroTrans desc
	
	--Recualcula el saldo
	if isnull(@Credito,0.00) <> 0.00 or isnull(@Debito,0.00) <> 0.00
	begin
		print 'Recalcula saldo'
		set @Saldo = @Saldo + @Credito - @Debito		
	end
	
	print '@Fec[' + convert(varchar,@Fec, 112) + '], @Credito[' + convert(varchar,@Credito) + '], @Debito[' + convert(varchar,@Debito) + '], @Saldo[' + convert(varchar,@Saldo) + ']'	  
	
/*
	--Actualiza los saldo en la fecha procesada (de momento no)
	--if @Fec >= '20191201'
	--begin
	--	print 'Actualiza saldo transaccion maestra finmas'
	--	update tahtransaccionmaestra set 
	--	SaldoCta = @Saldo
	--	where codcuenta = @CodCuenta
	--	and convert(varchar,Fecha,112) = convert(varchar,@Fec,112)
	--	--and NroTrans = @NroTrans
	--end		
*/
	--Actualiza los montos en la fecha procesada
	if @Fec >= '20191215' and @Saldo >= 0
	begin			
		print 'actializa saldo tcsahorros data'
		update finamigoconsolidado.dbo.tcsahorros set
		SaldoCuenta = @Saldo, 
		SaldoMonetizado = @Saldo
		where codoficina = @CodOficina and CodProducto = @CodProducto and renovado = 0 
		and codcuenta = @CodCuenta 
		and convert(varchar,fecha,112) = convert(varchar,@Fec,112)
	end	
	
	set @Fec = @Fec + 1
end


--Por ultimo actualiza el saldo de la cuenta 
if @Saldo >= 0
begin
	print 'actializa saldo tahcuenta'
	update [10.0.2.14].finmas.dbo.tahcuenta set SaldoCuenta = @Saldo --, MontoBloqueado = 0 , idEstadoCta = 'CA' 
	where codcuenta = @CodCuenta
end

--update [10.0.2.14].finmas.dbo.tmpGarantiaAh170Corregir2 set procesado = 1 
--where codcuenta = @CodCuenta

print 'FIN'


GO