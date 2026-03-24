SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAutorizaPDatos] @id int
as
	SELECT a.codautoriza + ' ' + a.descautoriza autorizacion,upper(o.nomoficina) sucursal,au.descripcion,au.campo1,u.nombrecompleto usuario
	,au.fechahoracreo,au.Completada
	FROM [10.0.2.14].finmas.dbo.tSgAutoGenerada Au
	inner join [10.0.2.14].finmas.dbo.tcloficinas o on o.codoficina=au.codofidestino
	inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=au.coduscreo
	inner join [10.0.2.14].finmas.dbo.tsgautorizaciones a on a.codautoriza=au.codautoriza
	WHERE au.ParaEnviar = 0 --and au.fechahoracreo between @fecha and dateadd(second,-1,dateadd(day,1,@fecha))
	--and au.codautoriza='TC-014'
	--and au.Completada=0
	and au.idautogenerada=@id--76361--

	--	SELECT a.codautoriza + ' ' + a.descautoriza autorizacion,upper(o.nomoficina) sucursal,au.descripcion,au.campo1,u.nombrecompleto usuario
	--,au.fechahoracreo,au.Completada
	--FROM [10.0.2.14].finmas_13072017.dbo.tSgAutoGenerada Au
	--inner join [10.0.2.14].finmas_13072017.dbo.tcloficinas o on o.codoficina=au.codofidestino
	--inner join [10.0.2.14].finmas_13072017.dbo.tususuarios u on u.codusuario=au.coduscreo
	--inner join [10.0.2.14].finmas_13072017.dbo.tsgautorizaciones a on a.codautoriza=au.codautoriza
	--WHERE au.ParaEnviar = 0 --and au.fechahoracreo between @fecha and dateadd(second,-1,dateadd(day,1,@fecha))
	----and au.codautoriza='TC-014'
	----and au.Completada=0
	--and au.idautogenerada=@id--76361--
GO