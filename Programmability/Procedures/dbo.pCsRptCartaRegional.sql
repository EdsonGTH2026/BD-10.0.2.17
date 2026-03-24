SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptCartaRegional]  @fecha smalldatetime,@zona varchar(5)
as
set nocount on 

select *
from  FNMGConsolidado.dbo.tcaCartaRegional  with(nolock)
where fecha=@fecha and zona=@zona
GO