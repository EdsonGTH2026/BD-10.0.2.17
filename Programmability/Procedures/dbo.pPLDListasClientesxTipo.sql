SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pPLDListasClientesxTipo] @fecini smalldatetime,@fecfin smalldatetime,@tipo varchar(10)
as
	exec [10.0.2.14].finmas.dbo.pPLDListasClientesxTipo @fecini,@fecfin,@tipo
GO