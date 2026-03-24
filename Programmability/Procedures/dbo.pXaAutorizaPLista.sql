SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAutorizaPLista] @codautoriza varchar(15)
as
declare @fecha smalldatetime
select @fecha=max(fechaproceso) from [10.0.2.14].finmas.dbo.tclparametros

SELECT au.idautogenerada id,o.nomoficina sucursal,au.descripcion,au.campo1,u.nombrecompleto usuario
FROM [10.0.2.14].finmas.dbo.tSgAutoGenerada Au
inner join [10.0.2.14].finmas.dbo.tcloficinas o on o.codoficina=au.codofidestino
inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=au.coduscreo
WHERE au.ParaEnviar = 0 and au.fechahoracreo between @fecha and dateadd(second,-1,dateadd(day,1,@fecha))
and au.codautoriza=@codautoriza--'TC-014'
and au.Completada=0
order by au.idautogenerada

--declare @fecha smalldatetime
--select @fecha=max(fechaproceso) from [10.0.2.14].finmas_13072017.dbo.tclparametros

--SELECT au.idautogenerada id,o.nomoficina sucursal,au.descripcion,au.campo1,u.nombrecompleto usuario
--FROM [10.0.2.14].finmas_13072017.dbo.tSgAutoGenerada Au
--inner join [10.0.2.14].finmas_13072017.dbo.tcloficinas o on o.codoficina=au.codofidestino
--inner join [10.0.2.14].finmas_13072017.dbo.tususuarios u on u.codusuario=au.coduscreo
--WHERE au.ParaEnviar = 0 and au.fechahoracreo between @fecha and dateadd(second,-1,dateadd(day,1,@fecha))
--and au.codautoriza=@codautoriza--'TC-014'
--and au.Completada=0
--order by au.idautogenerada
GO