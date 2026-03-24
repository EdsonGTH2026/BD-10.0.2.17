SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaNotificacionesRegistradas]  @descripcion varchar(50), @vigenciaini smalldatetime, @vigenciafin smalldatetime
as
begin

	select 
	n.IdNotificacion, n.Descripcion, n.Texto1, n.Texto2, 
	n.NombreArchivo, n.Ruta,
n.RutaWeb, 
    n.VigenciaInicial, n.VigenciaFinal,
	t.IdNotificacionTipo,
	t.Descripcion as NotificacionTipo,
n.Predeterminada,
	n.Activo,
	(case when n.NombreArchivo <> '' then 1
	 else 0 end  ) as TieneImagen          
	from tCsXaNotificaciones as n with (nolock) 
	inner join tCsXaClNotificacionTipo as t with (nolock) on t.IdNotificacionTipo = n.IdNotificacionTipo
	where n.Activo = 1
	and n.descripcion like '%' + @descripcion + '%'
	and n.VigenciaInicial >= @vigenciaini
	and n.VigenciaFinal <= @vigenciafin

end
GO