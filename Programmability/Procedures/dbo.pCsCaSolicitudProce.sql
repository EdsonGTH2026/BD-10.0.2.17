SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaSolicitudProce] @fecha smalldatetime
as
	exec [10.0.2.14].finmas.dbo.pCaSolicitudProce @fecha
GO