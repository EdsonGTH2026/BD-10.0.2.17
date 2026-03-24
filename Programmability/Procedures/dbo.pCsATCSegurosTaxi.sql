SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
--drop procedure pCsATCSegurosTaxi
CREATE procedure [dbo].[pCsATCSegurosTaxi] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
set ansi_warnings off
declare @fecini smalldatetime
declare @fecfin smalldatetime

select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

SELECT fecha,codoficina,nrotransaccion,nombrecliente,descripciontran,codcajero,montototaltran
FROM [FinamigoConsolidado].[dbo].[tCsTransaccionDiaria] with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='TC'
and tipotransacnivel1='I'
and tipotransacnivel3=37
--order by fecha

--select len('RAMOS MEJIA XICO POLIZA 0190125301')
GO