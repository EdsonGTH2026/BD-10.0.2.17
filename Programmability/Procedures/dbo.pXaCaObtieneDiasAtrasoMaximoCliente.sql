SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCaObtieneDiasAtrasoMaximoCliente] ( @CodUsuario varchar(20), @AtrasoMaximoCliente int output)
as
BEGIN
--Ver 11-11-2020
	set nocount on
	------------------------ Obtiene los dias de atraso del cliente
	--declare @AtrasoMaximoCliente int
	--select @AtrasoMaximoCliente = max(atrasomaximo) from finamigoconsolidado.dbo.tCsACaLIQUI_RR with(nolock) where codusuario = @CodUsuario --Considerando todos los creditos 
	select top 1 @AtrasoMaximoCliente = atrasomaximo from finamigoconsolidado.dbo.tCsACaLIQUI_RR with(nolock) where codusuario = @CodUsuario order by cancelacion desc  --considerando el ultimo credito cancelado
	set @AtrasoMaximoCliente = isnull(@AtrasoMaximoCliente,0)
	
	--select @AtrasoMaximoCliente
END	
GO