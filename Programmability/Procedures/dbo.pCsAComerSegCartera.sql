SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerSegCartera] @fecha smalldatetime,@codoficina as varchar(4)
as
 select * from tCsRptAComerSegCartera
GO

GRANT EXECUTE ON [dbo].[pCsAComerSegCartera] TO [jarriagaa]
GO