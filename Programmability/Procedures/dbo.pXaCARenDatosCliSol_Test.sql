SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
CREATE procedure [dbo].[pXaCARenDatosCliSol_Test] @codsolicitud varchar(25),@codoficina varchar(4)
as
	--exec [10.0.2.14].finmas.dbo.pXaCARenDatosCliSol @codsolicitud,@codoficina   --produccion
	exec [10.0.2.14].finmas_20190315ini.dbo.pXaCARenDatosCliSol @codsolicitud,@codoficina  --pruebas
GO