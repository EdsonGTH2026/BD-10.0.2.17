SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAutorizaPendientes] @usuario varchar(15)
as
--declare @usuario varchar(15)
--set @usuario='aballesteross'--'curbiza'--'abotellos'--
----select * from [10.0.2.14].finmas.dbo.tsgusuarios where nombrecompleto like '%ballesteros%'

declare @fecha smalldatetime
select @fecha=max(fechaproceso) from [10.0.2.14].finmas.dbo.tclparametros

declare @codusuario varchar(15)
select @codusuario=codusuario from [10.0.2.14].finmas.dbo.tsgusuarios where usuario=@usuario--'avillanuevag'

declare @zona varchar(4)
select @zona=zona from tclzona where activo=1 and responsable=(select codusuario from tcspadronclientes with(nolock) where codorigen=@codusuario)

if((select count(codoficina) from tcloficinas with(nolock) where tipo<>'Cerrada' and zona=@zona) > 0)
begin
	SELECT au.CodAutoriza,a.descautoriza
	,sum(case when au.Completada=0 then 1 else 0 end) pendientes
	,sum(case when au.Completada=1 then 1 else 0 end) completados
	,sum(case when au.Usada=1 then 1 else 0 end) usados,isnull(c.codusuario,'') codusuario
	FROM [10.0.2.14].finmas.dbo.tSgAutoGenerada Au --with(nolock)
	inner join [10.0.2.14].finmas.dbo.tSgAutorizaciones a --with(nolock) 
	on a.CodAutoriza=au.CodAutoriza
	left outer join [10.0.2.14].finmas.dbo.tSgComitesMiembros c on c.codcomite=a.codcomite and c.codusuario=@codusuario--'8VGA2209741'
	WHERE au.ParaEnviar = 0 and au.fechahoracreo between @fecha and dateadd(second,-1,dateadd(day,1,@fecha))
	and au.codofidestino in (select codoficina from tcloficinas with(nolock) where tipo<>'Cerrada' and zona=@zona)
	group by au.CodAutoriza,a.descautoriza,c.codusuario
	order by au.CodAutoriza
end
else
	begin
		SELECT au.CodAutoriza,a.descautoriza
		,sum(case when au.Completada=0 then 1 else 0 end) pendientes
		,sum(case when au.Completada=1 then 1 else 0 end) completados
		,sum(case when au.Usada=1 then 1 else 0 end) usados,isnull(c.codusuario,'') codusuario
		FROM [10.0.2.14].finmas.dbo.tSgAutoGenerada Au --with(nolock)
		inner join [10.0.2.14].finmas.dbo.tSgAutorizaciones a --with(nolock) 
		on a.CodAutoriza=au.CodAutoriza
		left outer join [10.0.2.14].finmas.dbo.tSgComitesMiembros c on c.codcomite=a.codcomite and c.codusuario=@codusuario--'8VGA2209741'
		WHERE au.ParaEnviar = 0 and au.fechahoracreo between @fecha and dateadd(second,-1,dateadd(day,1,@fecha))
		group by au.CodAutoriza,a.descautoriza,c.codusuario
		order by au.CodAutoriza

	end
--select top 10 * 
--FROM [10.0.2.14].finmas.dbo.tSgAutoGenerada Au --with(nolock)
GO