SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAPagosCreditos] @fecha smalldatetime, @codoficina varchar(4)
as

declare @fecini smalldatetime
declare @fecfin smalldatetime

select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

select fecha,codigocuenta codprestamo,nrotransaccion,codcajero,montototaltran
from tcstransacciondiaria with(nolock)
where codsistema='CA' and fecha>=@fecini and fecha<=@fecfin
and tipotransacnivel1='I'
and tipotransacnivel3 in(104,105)
GO