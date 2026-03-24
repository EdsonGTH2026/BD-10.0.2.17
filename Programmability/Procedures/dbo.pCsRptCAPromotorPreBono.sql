SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptCAPromotorPreBono] @codasesor varchar(15)
as
	select * 
	from tCsRptCACalculoPreBono with(nolock)
	where codasesor=@codasesor
GO