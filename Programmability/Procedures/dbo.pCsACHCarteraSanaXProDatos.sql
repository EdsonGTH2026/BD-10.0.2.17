SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACHCarteraSanaXProDatos] @fecha      SMALLDATETIME ,            
                 @codoficina VARCHAR(300)
as
	select * from tCsRptCHCarteraSanaXPro
GO