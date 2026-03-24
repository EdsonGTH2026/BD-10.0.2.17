SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXSolicitudProceDet](@IdProceso varchar(10))
as
BEGIN
	--Comentar
	--declare @CodOficinaCodSolicitud varchar(23)
	--set @CodOficinaCodSolicitud = '324SOL-0001024'
	/*
	declare @CodSolicitud varchar(20)
	declare @CodOficina varchar(3)
	--Obtiene codoficina
	select @CodOficina = left(@CodOficinaCodSolicitud,  charindex( 'SOL',@CodOficinaCodSolicitud,0) -1)
	--obtiene codsolicitud
	select @CodSolicitud = substring(@CodOficinaCodSolicitud,  charindex( 'SOL',@CodOficinaCodSolicitud,0), 25)
	*/
	--select @CodOficina, @CodSolicitud
	exec [10.0.2.14].finmas.dbo.pCaXSolicitudProceDet @IdProceso  --PRODUCCION
	--exec [10.0.2.14].alta14.dbo.pCaXSolicitudProceDet @IdProceso  --PRUEBAS
END

GO