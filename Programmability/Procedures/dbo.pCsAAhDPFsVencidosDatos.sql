SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAAhDPFsVencidosDatos] @fecha smalldatetime,@codoficina varchar(4)
as select * from tCsAAhDPFsVencidos
GO