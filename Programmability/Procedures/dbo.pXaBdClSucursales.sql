SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pXaBdClSucursales]
As
set nocount on
	SELECT o.CodOficina, o.NomOficina,o.zona,o.tipo,isnull(l.codusuario,'98CSM1803891') codusuario, 'S: ' + o.NomOficina nemo
	,isnull(codmicro,0) codmicro
	FROM   tClOficinas o with(nolock)
	left outer join [_CorreosLN] l with(nolock) on l.codoficina=o.codoficina
	where o.tipo not in('Cerrada','Contable','Matriz','Administrativa')
	and (cast(o.codoficina as int)<100 or cast(o.codoficina as int)>300)
	--and nomoficina<>'IXTLAHUACA'
	order by NomOficina
GO