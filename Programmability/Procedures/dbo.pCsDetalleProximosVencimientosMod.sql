SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsDetalleProximosVencimientosMod] @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(200), @Agrupar varchar(1000), @Calcular varchar(1000)  AS
/*
DECLARE @Fecha smalldatetime
DECLARE @FecIni smalldatetime 
DECLARE @FecFin smalldatetime
DECLARE @CodOficina varchar(100)
DECLARE @Agrupar varchar(1000)

DECLARE @Calcular varchar(1000)

SET @Fecha 			= '20090527'
SET @FecIni 		= '20090601'
SET @FecFin 		= '20090630'
SET @CodOficina = '2,3,4,5'
SET @Agrupar 		= 'oficina,asesor'--'oficina,sum(capital) capital,sum(montocuota) Monto'--' oficina,nombretec,asesor,sum(capital) capital '
														--oficina, fechavencimiento, sum(capital) capital, sum(montocuota) Monto
SET @Calcular		= 'capital'
*/
--print dbo.fduFechaATexto(@Fecha,'dd/mm/aaaa')

CREATE TABLE #DetallePV (
	Oficina varchar (200) ,
	NombreTec varchar (50) ,
	Asesor varchar (300) ,
	CodPrestamo varchar (25) ,
	NomCliente varchar (300) ,
	Fecha varchar(10),
	Capital decimal(16, 4) ,
	Interes decimal(16, 4) ,
	Moratorio decimal(16, 4) ,
	MontoCuota decimal(16, 4)
)

insert #DetallePV
exec pCsDetalleProximosVencimientos @FecIni, @FecFin, @CodOficina, ''

--select * from #DetallePV

/*
DECLARE @TABLA varchar(255)--,
DECLARE @PIVOT VARCHAR(255)--,
DECLARE @AGRUPACION varchar(255)--,
DECLARE @CAMPO varchar(255)--,
DECLARE @CALCULO varchar(20)

SET @TABLA = '_AAA'
SET @PIVOT = 'fecha'
SET @AGRUPACION = 'oficina, asesor'
SET @CAMPO = 'capital'
SET @CALCULO = 'sum'
*/
exec pCsSgUtilCrosstab '#DetallePV','fecha',@Agrupar,@Calcular,'sum'

drop table #DetallePV
GO