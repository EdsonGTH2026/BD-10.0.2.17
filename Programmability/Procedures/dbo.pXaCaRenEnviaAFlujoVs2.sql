SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCaRenEnviaAFlujoVs2] @codsolicitud varchar(15),@codoficina varchar(3),@usuario varchar(15),@comentario varchar(200),@ciclo int
as
	exec [10.0.2.14].finmas.dbo.pXaCaRenEnviaAFlujoVs2 @codsolicitud,@codoficina,@usuario,@comentario,@ciclo   --produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCaRenEnviaAFlujo @codsolicitud,@codoficina,@usuario,@comentario  --pruebas
GO