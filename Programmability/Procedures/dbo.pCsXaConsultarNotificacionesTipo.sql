SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaConsultarNotificacionesTipo]
as
begin

	select IdNotificacionTipo, Descripcion from tCsXaClNotificacionTipo with (nolock)
	where Activo = 1
	order by IdNotificacionTipo
end
GO