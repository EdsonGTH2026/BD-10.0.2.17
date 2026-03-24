SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCHPlantillaEmpleadosDatos] @fecha smalldatetime,@codoficina varchar(4)
as select * from tCsAPlantillaEmpleados
GO