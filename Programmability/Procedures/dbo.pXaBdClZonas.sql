SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pXaBdClZonas]
As
set nocount on
	select zona,nombre,responsable,dbo.fduOficinas3(zona) filtro, 'R: ' + nombre nemo
	from tclzona with(nolock)
	where activo=1
	and zona not in('ZSC')
	union
	select zona,nombre,isnull(responsable,'') responsable,dbo.fduOficinas3('%'),'0: Regiones ' nemo
	from tclzona with(nolock)
	where zona='ZZZ'
GO