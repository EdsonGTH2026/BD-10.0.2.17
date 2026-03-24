SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAAhAperturasdatos] @fecha smalldatetime,@codoficina varchar(4)
as select * from tCsAAhAperturas
GO