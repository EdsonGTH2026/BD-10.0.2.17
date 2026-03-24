SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCARenActSolicitud_vs2] @codsolicitud varchar(25),@codoficina varchar(4),@monto money,@cuotas int,@coddestino varchar(5),@codproducto varchar(5),@codtipoplaz varchar(2)
as
	  exec [10.0.2.14].finmas.dbo.pXaCARenActSolicitud_vs2 @codsolicitud,@codoficina,@monto,@cuotas,@coddestino,@codproducto,@codtipoplaz  -->Produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCARenActSolicitud @codsolicitud,@codoficina,@monto,@cuotas,@coddestino -->Pruebas
GO