SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAColoCoorHuer] @fecfin smalldatetime
as
	--declare @fecfin smalldatetime
	--set @fecfin='20180912'
	truncate table tCsACAColoCoorHuer
	insert into tCsACAColoCoorHuer
	exec pCsCAColoCoorHuer @fecfin
GO