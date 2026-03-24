SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCHPlantillaResumenDatos] @fecha smalldatetime,@codoficina varchar(4)
as select * from tCsAPlantillaResumen
GO