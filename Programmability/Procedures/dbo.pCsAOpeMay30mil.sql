SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsAOpeMay30mil] @Fecha SMALLDATETIME
AS
	drop table tCsRptOpeMay30mil

	select fecha,codigocuenta,codsistema,codoficina,nrotransaccion,tipotransacnivel1,tipotransacnivel3,nombrecliente,descripciontran
	,montocapitaltran,montointerestran,montoinpetran,montocargos,montootrostran,montoimpuestos,montototaltran
	into tCsRptOpeMay30mil
	from tcstransacciondiaria with(nolock)
	where fecha=@Fecha--'20170101'-- and fecha<='20171231'
	--where fecha>='20171201' and fecha<='20171231'
	and tipotransacnivel2='EFEC'
	and montototaltran>=30000
	and extornado=0
	---order by fecha
GO