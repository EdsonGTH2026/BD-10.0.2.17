SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaNotificacionesAsignadasUsuario] @codusuario varchar(20), @idtipo integer
as
begin
	SET NOCOUNT ON
	/*
	--<<<<<<< comentar pruebas
	declare @codusuario varchar(20)
	declare @idtipo integer
	set @codusuario = 'KEJ0512831'
	set @idtipo = 1
	-->>>>>>> comentar pruebas
	*/

	--crea tabla temporal
	create table #NotifXUsuario
	(
	IdNotificacion integer ,
	VigenciaInicial smalldatetime,
	VigenciaFinal smalldatetime,
	Descripcion varchar(50),
	Texto1 varchar(100),
	Texto2 varchar(100),
	RutaWeb varchar(200)
	)

	-- select * from #NotifXUsuario
	insert into #NotifXUsuario (IdNotificacion, VigenciaInicial, VigenciaFinal,descripcion, Texto1,Texto2, RutaWeb)
	select 
	nu.IdNotificacion,
	nu.VigenciaInicial,                                        
	nu.VigenciaFinal,
	n.Descripcion,
	n.Texto1,
	n.Texto2,
	'http://200.57.180.150/notificacionesapp/' + n.NombreArchivo as RutaWeb
	from tCsXaNotificacionUsuario as nu with(nolock)
	inner join tCsXaNotificaciones as n with(nolock) on n.IdNotificacion = nu.IdNotificacion
	where 
	nu.Activo = 1
	and n.IdNotificacionTipo = @idtipo
	and nu.CodUsuario = @codusuario --'KEJ0512831'
	and nu.VigenciaInicial <= getdate()                                       
	and nu.VigenciaFinal >= getdate()

	--valida que haya notificaciones
	declare @numnotif integer
	select @numnotif = count(IdNotificacion) from #NotifXUsuario
	print '@numnotif = ' + convert(varchar, @numnotif) --comentar
	
	if @numnotif = 0 and @idtipo in (1,2) --solo de tipo PUBLICIDAD o PAGO
	begin
		--Si no hay notificaciones, entonces inserta la notficacion default para todos los usuarios
		print 'inserta notificaciones default'
		insert into #NotifXUsuario (IdNotificacion, VigenciaInicial, VigenciaFinal,Descripcion,Texto1,Texto2, RutaWeb)
		select 
		n.IdNotificacion,
		n.VigenciaInicial,                                        
		n.VigenciaFinal,
		n.Descripcion,
		n.Texto1,
		n.Texto2,
		'http://200.57.180.150/notificacionesapp/' + n.NombreArchivo as RutaWeb
		from  tCsXaNotificaciones as n with(nolock)
		where 
		n.Activo = 1
		and n.IdNotificacionTipo = @idtipo
		and n.Predeterminada = 1
		and n.VigenciaInicial <= getdate()
		and n.VigenciaFinal >= getdate()
	
	end 

	--Si la notificacion es de tipo 1 (Publicidad), tambien busca de tipo 3 (cumpleaños)
	if @idtipo = 1
	begin
		insert into #NotifXUsuario (IdNotificacion, VigenciaInicial, VigenciaFinal,Descripcion, Texto1,Texto2, RutaWeb)
		select 
		nu.IdNotificacion,
		nu.VigenciaInicial,                                        
		nu.VigenciaFinal,
		n.Descripcion,
		n.Texto1,
		n.Texto2,
		'http://200.57.180.150/notificacionesapp/' + n.NombreArchivo as RutaWeb
		from tCsXaNotificacionUsuario as nu with(nolock)
		inner join tCsXaNotificaciones as n with(nolock) on n.IdNotificacion = nu.IdNotificacion
		where 
		nu.Activo = 1
		and n.IdNotificacionTipo = 3 --CUMPLEAÑOS
		and nu.CodUsuario = @codusuario --'KEJ0512831'
		and nu.VigenciaInicial <= getdate()                                       
		and nu.VigenciaFinal >= getdate()
	end

	--regresa los datos obtenidos
	select IdNotificacion, VigenciaInicial, VigenciaFinal,Descripcion, Texto1,Texto2, RutaWeb from #NotifXUsuario
	--borra la tabla temporal
	drop table #NotifXUsuario

end
GO