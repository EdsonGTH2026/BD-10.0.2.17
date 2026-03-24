SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pXaSolicitudesDiaEstado] @estado varchar(20)
as
set nocount on

	exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaEstado @estado

GO