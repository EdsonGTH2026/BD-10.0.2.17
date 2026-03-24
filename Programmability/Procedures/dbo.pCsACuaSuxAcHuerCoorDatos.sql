SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACuaSuxAcHuerCoorDatos] @fecha smalldatetime,@codoficina varchar(4)
as 
	select * from tCsACASucActHueCoor
GO