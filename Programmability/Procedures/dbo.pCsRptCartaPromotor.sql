SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptCartaPromotor]  @fecha smalldatetime,@codoficina varchar(3)
as
set nocount on 

select  *
from FNMGConsolidado.dbo.tCaCartaPromotor with(nolock)
where fecha=@fecha and codoficina=@codoficina

GO