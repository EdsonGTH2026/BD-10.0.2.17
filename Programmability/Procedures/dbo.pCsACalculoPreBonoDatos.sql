SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACalculoPreBonoDatos] @fecha smalldatetime,@codoficina AS varchar(2)
as
select fecha,codasesor,sucursal,nombrepromotor,puesto,O_CCBM,O_CAM,O_CER7,O_CER60,O_NCre60,A_CCBM,A_CAM,A_CER7,A_CER60,A_NCre60 from tCsRptCACalculoPreBono
GO