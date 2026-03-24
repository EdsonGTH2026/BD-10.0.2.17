SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaCosechasBasexSuc] @fecha smalldatetime, @codoficina varchar(4)
as
	--declare @codoficina varchar(2000)
	--set @codoficina='4,5,6'
	
	select CodPrestamo,CodUsuario,CodOficina,sucursal,CodProducto,Desembolso,Monto,PrimerAsesor,UltimoAsesor,Estadocalculado
	,NroDiasAtraso,saldo,PromotorReporte,PromotorReporteNombre,codverificadorData,prestamoid
	from tCsCaCosechasBase with(nolock)
	where codoficina in (
		select codigo from dbo.fduTablaValores(@codoficina)
	)

GO