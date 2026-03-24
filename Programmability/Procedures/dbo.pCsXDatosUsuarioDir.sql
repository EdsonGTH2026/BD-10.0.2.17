SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsXDatosUsuarioDir](@codusuario varchar(20)) as
begin
	exec [10.0.2.14].finmas.dbo.pCaXInfoCliente @codusuario
	--select * from [10.0.2.14].finmas.dbo.vDatosUsuarioDir  where codusuario = @codusuario  --PRODUCCION
	--select * from [10.0.2.14].alta14.dbo.vDatosUsuarioDir  where codusuario = @codusuario  --PRUEBAS
end
GO