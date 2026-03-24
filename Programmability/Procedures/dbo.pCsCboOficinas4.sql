SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboOficinas4]
As
set nocount on
	SELECT CodOficina, NomOficina,zona,tipo
	FROM   tClOficinas with(nolock)
	where tipo not in('Cerrada','Contable','Matriz','Administrativa')
	and (cast(codoficina as int)<100 or cast(codoficina as int)>300)
	--and nomoficina<>'IXTLAHUACA'
	order by NomOficina
GO