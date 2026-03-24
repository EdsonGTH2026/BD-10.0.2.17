SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCosechasBase] @fecha smalldatetime, @codoficina varchar(4)
as
	select CodPrestamo,a.CodUsuario,a.CodOficina,sucursal,CodProducto,Desembolso,Monto,PrimerAsesor,UltimoAsesor,Estadocalculado
	,NroDiasAtraso,saldo,PromotorReporte,PromotorReporteNombre,a.codverificadorData,prestamoid,b.nombrecompleto verificador
	from tCsCaCosechasBase a with(nolock)
	left  outer join tcspadronclientes b with(nolock)
	on a.codverificadorData=b.codusuario


GO