SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAAhProxVencimientosDatos] @fecha smalldatetime,@codoficina varchar(4)
as select * from tCsAAhProxVencimientos
GO