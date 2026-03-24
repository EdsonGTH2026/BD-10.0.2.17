SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACliConfirmaCelDatos] @fecha smalldatetime, @codoficina varchar(5)
as
	select * from tCsACliConfirmaCel
GO