SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pGrListaOficinas]
as
select * from tcloficinas order by 6
GO