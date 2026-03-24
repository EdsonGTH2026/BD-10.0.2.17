SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pApiPepsiCADispersiones] @codprestamo varchar(20),@monto money,@nrocuotas tinyint
as

--declare @codprestamo varchar(20)
--declare @monto money
--declare @nrocuotas tinyint
--set @codprestamo='008-170-06-06-05043'
--set @monto=1200
--set @nrocuotas=4

begin tran

if not exists(select 1
						from tcaprestamos with(nolock) --enlineacred,codlineacre
						--where fechadesembolso>='20211001'
						where codprestamo=@codprestamo
						and estado NOT IN('CANCELADO','CASTIGADO','ANULADO','APROBADO','TRAMITE'))
begin
	select '0' rpta, 'Crédito inactivo.' msj
	return
end

if (exists(select 1
						from tcaprestamoslineas with(nolock)
						where codprestamo=@codprestamo and estado=2))
	begin
		select '0' rpta, 'Crédito con dispersion pendiente.' msj
		return
	end

declare @montodesembolso money
select @montodesembolso=montodesembolso
from tcaprestamos with(nolock)
where codprestamo=@codprestamo

declare @fechaproceso smalldatetime
select @fechaproceso=fechaproceso from tclparametros with(nolock) where codoficina='98'

declare @saldodisponible money
if (exists(select 1
	from tcaprestamoslineas with(nolock)
	where codprestamo=@codprestamo))
	begin
		select @saldodisponible=saldodisponible
		from tcaprestamoslineas with(nolock)
		where codprestamo=@codprestamo
	end
else
	begin
		insert into tcaprestamoslineas
		values (@codprestamo,@montodesembolso,@montodesembolso,0)
		set @saldodisponible = @montodesembolso
	end

if(@saldodisponible<=0)
begin
	select '0' rpta, 'Sin saldo disponible.' msj
	return
end
if(@saldodisponible<@monto)
begin
	select '0' rpta, 'Saldo insuficiente.' msj
	return
end

if exists(select 1
					from tcaprestamoslineadisper with(nolock)
					where codprestamo=@codprestamo and fechadispersion=@fechaproceso and monto=@monto)
	begin
		select '0' rpta, 'Existe una dispersion por el mismo monto el día de hoy.' msj
		return
	end

declare @nrodispersion int
select @nrodispersion=max(numeroplan)
from tcaprestamoslineadisper with(nolock)
where codprestamo=@codprestamo

set @nrodispersion = case when @nrodispersion is null then 0 else @nrodispersion + 1 end

insert into tcaprestamoslineadisper (codprestamo,numeroplan,monto,fechadispersion,nrocuotas,saldoanterior,estado)
values (@codprestamo,@nrodispersion,@monto,@fechaproceso,@nrocuotas,@saldodisponible,1) --Estados--> 1:registrado, 2:Afectado 3:Aplicado

--++++++++++++++++ calcula cuotas
declare @rpt varchar(25)
exec pCaCalculoCuotas_Pepsico @CodPrestamo,@nrodispersion,@monto,@nrocuotas,@rpt out
if(@@error<>0)
BEGIN
	ROLLBACK TRAN
	select '0' codprestamo,'Error al generar tabla de pagos' rpta
	RETURN 
END
if(@rpt<>'')
BEGIN
	ROLLBACK TRAN
	select '0' codprestamo,'Error al generar tabla de pagos.'+@rpt rpta
	RETURN 
END

declare @fecven smalldatetime
select @fecven=max(fechavencimiento) from tcacuotas with(nolock) where codprestamo=@CodPrestamo and numeroplan=@nrodispersion

update tcaprestamoslineadisper set fechavencimiento=@fecven,estado=2  -- genero la tabla
where codprestamo=@CodPrestamo and numeroplan=@nrodispersion

update tcaprestamoslineas set saldoutilizado=saldoutilizado+@monto,saldodisponible=saldodisponible-@monto
where codprestamo=@CodPrestamo

declare @CodSolicitud varchar(25)
declare @CodOficina varchar(4)
declare @numeroplan int
declare @rpta char(1)
declare @msj varchar(200)

/*
exec pApiPepsiCATransferenciaSTP @CodSolicitud,@CodOficina,@numeroplan,@rpta out,@msj out
if(@@error<>0)
BEGIN
	ROLLBACK TRAN
	select '0' codprestamo,'Error al generar transferencia' rpta
	RETURN 
END
if(@rpta<>'1')
BEGIN
	ROLLBACK TRAN
	select '0' codprestamo,'Error en transferencia.'+@msj rpta
	RETURN 
END
*/

select '1' codprestamo,'Numero dispersion '+ str(@nrodispersion)+'. '+@msj as rpta

commit tran
GO