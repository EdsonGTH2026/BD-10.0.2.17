SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptCartaPromotor2]   @fecha smalldatetime,@codoficina varchar(5)
as
set nocount on 

--declare @fecha smalldatetime
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--declare @codoficina varchar(5)
--set @codoficina='309'

select * from FNMGConsolidado.dbo.tcaCartaPromotor2 with(nolock)
where fecha=@fecha
and codoficina=@codoficina
GO