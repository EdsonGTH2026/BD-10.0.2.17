SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhRegistrarConsultaQeQAhorroVista] ( @CodUsuario varchar(20), @Solicitud varchar(20), @CodOficina varchar(3), @TipoUsuario varchar(10))
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pAhRegistrarConsultaQeQAhorroVista @CodUsuario, @Solicitud, @CodOficina, @TipoUsuario
END
GO