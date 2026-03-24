SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create Procedure [dbo].[pCsCboOficinas3]
As
set nocount on
	SELECT CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + NomOficina NomOficina
	FROM   tClOficinas
	where tipo not in('Cerrada','Contable','Matriz','Administrativa')
	and (cast(codoficina as int)<100 or cast(codoficina as int)>300)
	order by cast(codoficina as int)
GO