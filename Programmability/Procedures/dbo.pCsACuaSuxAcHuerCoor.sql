SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACuaSuxAcHuerCoor] @fecha datetime
as 
	--declare @fecha datetime
	--set @fecha='20181231'
	declare @fec smalldatetime
	set @fec=@fecha
	truncate table tCsACASucActHueCoor

	insert into tCsACASucActHueCoor
	exec pCsCuadroSucursalxActivoHuerfanoCoordinador30 @fec

GO