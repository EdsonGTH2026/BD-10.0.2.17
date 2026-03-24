SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pRptBovedaTransacciones] @fechapro smalldatetime , @CodOficina  varchar(4)
as
select	fecha,t.codoficina,o.NomOficina as descoficina,fecha fechapro,numbovtrans,fechatrans,t.codmoneda,m.descmoneda,
	montoentrada,montosalida,usdepositante,usreceptor,codmovide,codmovia,numcaja,numfondofijo,anulada 
from	tCsBovTransac t inner join tClOficinas o on t.codoficina=o.codoficina inner join tClMonedas m on 
	t.codmoneda=m.codmoneda
where fecha=@fechapro and t.codoficina=@CodOficina
GO