SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pXaEstadosFlujoCredito] 
as
set nocount on

	exec [10.0.2.14].finmas.dbo.pXaEstadosFlujoCredito
GO