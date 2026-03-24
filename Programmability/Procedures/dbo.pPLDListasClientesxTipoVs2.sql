SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pPLDListasClientesxTipoVs2] @fecini smalldatetime,@fecfin smalldatetime,@tipo varchar(10),@por money
as
	exec [10.0.2.14].finmas.dbo.pPLDListasClientesxTipoVs2 @fecini,@fecfin,@tipo,@por
GO