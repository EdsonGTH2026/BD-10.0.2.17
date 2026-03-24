SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCaValidarPoliticasCicloEdadSolRen](@CodSolicitud varchar(20), @CodOficina varchar(3),@Ciclo int, @Periodicidad varchar(1), @Plazo int, @Tasa money, @MontoSolicitado money )
as
begin
	set nocount on
	exec [10.0.2.14].finmas..pCaValidarPoliticasCicloEdadSolRen @CodSolicitud, @CodOficina,@Ciclo, @Periodicidad, @Plazo, @Tasa, @MontoSolicitado 
end
GO