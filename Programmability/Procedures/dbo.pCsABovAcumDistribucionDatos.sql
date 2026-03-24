SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsABovAcumDistribucionDatos] @fecha smalldatetime, @codoficina varchar(500)
as
set nocount on
	select * from tCsABovAcumDistribucion where fechapro=@fecha
GO