SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsMBSolicitudUpdateLaLo 'guzma'
CREATE procedure [dbo].[pCsMBSolicitudUpdateLaLo] @codoficina varchar(4),@codsolicitud varchar(15),@latitud decimal(14,9),@longitud decimal(14,9)
as 

update [10.0.2.14].FinMas.dbo.tcaprestamovivienda
set latitud=@latitud, longitud=@longitud
where codoficina=@codoficina and codsolicitud=@codsolicitud
GO