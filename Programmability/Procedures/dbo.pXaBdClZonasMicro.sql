SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pXaBdClZonasMicro]
As
set nocount on
	select cast(codmicro as varchar(2)) codmicro,nombremicro,isnull(responsable,'') responsable,dbo.fduOficinasMicro(codmicro) filtro, 'M: ' + nombremicro nemo
	,zona
	--select *
	from tclzonamicro with(nolock)
	where activo=1
	union
	select 'MMM','Todas microregiones','' responsable,dbo.fduOficinasMicro('%'),'0: Microregiones' nemo,'' zona
GO