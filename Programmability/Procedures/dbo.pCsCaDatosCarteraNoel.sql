SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCaDatosCarteraNoel]
               ( @Fecha SMALLDATETIME)
AS

set nocount on
--DECLARE @Fecha SMALLDATETIME
--SET @Fecha   = '20150525' 

DECLARE @Periodo VARCHAR(6)
    SET @Periodo = dbo.fduFechaATexto(@Fecha, 'AAAAMM')

DECLARE @Actual	  SMALLDATETIME
DECLARE @Anterior SMALLDATETIME
	SET @Actual	  = DateAdd(Day, -1, Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, Cast(@Periodo + '01' As SmallDateTime)), 'AAAAMM') + '01' As SmallDateTime))
	SET @Anterior = DateAdd(Day, -1, Cast(@Periodo + '01' As SmallDateTime))

SELECT c.Fecha FechaInf,
       --cd.codusuario, 
       --@Fecha Fecha,                        
       Numero = c.CodPrestamo/*,
       c.FechaDesembolso FechaPrestamo,
       cd.MontoDesembolso MontoInicial,
	   cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido SaldoActual,
       tc.Descripcion AS FinLacp,
       d.DescDestino Finalidad,
       c.Estado Estatus,
       CASE WHEN c.TipoReprog IN ('REPRO')
            THEN 'SI'--'Reestructurado'
            ELSE 'NO' END AS Reestructurado,
       CarteraVencidaAnterior = isnull(V.CarteraVencidaAnterior, 0),
	   c.FechaVencimiento, 
	   DATEDIFF(day, c.FechaDesembolso, c.FechaVencimiento) DiasVencidos, 
       Ahorro = isnull(Ah.Ahorro, 0),
	   cd.InteresVigente AS CVigIO, 
	   cd.MoratorioVigente AS CVigIM, 
	   cd.InteresVencido AS CVenIO, 
	   cd.MoratorioVencido AS CVenIM, 
	   o.NomOficina AS Sucursal, 
	   SUBSTRING(vu.CP2_Municipio, 8, 100) AS Poblacion, 
	   Case vu.ZonaLugar When 'Urbano' Then 'Semiurbano' Else vu.ZonaLugar End AS ZG, 
	   dbo.fduEdad(pc.FechaNacimiento, c.Fecha) AS Edad, 
	   s.SHF AS Sexo, 
	   CASE s.SHF WHEN 'H' THEN e.Masculino WHEN 'M' THEN e.Femenino ELSE 'Desconocido' END AS EstadoCivil, 
	   TP.TipoPro AS TipoDeVivienda, 
  	   a.Nombre as Actividad, 
	   ISNULL(pc.TiempoResidirDirFam, pc.TiempoResidirDirNeg) AS TiempoDeResidencia, 
 	   ModalidadPlazo = CAST(c.NroCuotas AS Varchar(10)) + ' ' + CASE WHEN c.NroCuotas = 1 
  												                 THEN mp.Singular 
												                 WHEN c.NroCuotas > 1 
	 											                 THEN mp.Plural END,
       CASE WHEN DateDiff(Day, c.Fecha, FechaVencimiento) < 0 
	        THEN 0 
	        ELSE DateDiff(Day, c.Fecha, FechaVencimiento) END AS DXV, 
  	   p.NombreProdCorto PlanDelCredito, 
  	   c.TasaIntCorriente Tasa, 
  	   c.NroCuotasPagadas NumeroDeAmortizaciones, 
  	   c.NrodiasEntreCuotas FrecuenciaDePago, 
       DATEDIFF(Day, c.FechaDesembolso,c.FechaVencimiento) / 30 AS PlazoEnMeses, 
       CU.Amortizacion,
	   CASE WHEN NroDiasAtraso = 0
	        THEN 0 
	        WHEN NroDiasAtraso > 0 
	        THEN CuotaActual - NroCuotasPagadas END AS PagosVencidosConsecutivos, 
	   ISNULL(Garantia.Garantia, 0) AS Garantia, 
	   GarantiaReal = CASE WHEN ISNULL(Garantia.Garantia, 0) = 0 
	                       THEN 0
						   WHEN ISNULL(ROUND(Ah.Garantia, 2), 0) > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN ISNULL(ROUND(Ah.Garantia, 2), 0)
						   WHEN ISNULL(ROUND(Ah.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
						    And ISNULL(Garantia.Garantia, 0)         > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				   WHEN ISNULL(ROUND(Ah.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				    And ISNULL(Garantia.Garantia, 0)         < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
		 				  THEN ISNULL(Garantia.Garantia, 0) END,
	   CASE WHEN cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido-Isnull(Garantia.Garantia, 0) < 0 
	        THEN 0 
	        ELSE cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido-Isnull(Garantia.Garantia, 0) END AS MontoExpuesto, 
	   cd.SReservaCapital + cd.SReservaInteres AS ReservaExpuesta, 
	   cd.InteresVigente+cd.MoratorioVigente+cd.InteresVencido+cd.MoratorioVencido AS Interes, 
	   cd.SReservaInteres AS ReservaInteres, 
	   c.NroDiasAtraso,
	   AhorroComprometido = ISNULL(ROUND(Ah.Garantia, 2), 0),
	   AhorroNoComprometidoConCredito = ISNULL(ROUND(Ah.Ahorro, 2), 0) - ISNULL(ROUND(Ah.Garantia, 2), 0),
	   cd.PReservaCapital,
       t.NombreTec Tecnologia, 
       o.zona + ' ' + z.Nombre Region*/
FROM tCsCartera c
INNER JOIN tCsCarteraDet cd ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo
LEFT  JOIN (Select Fecha, Codigo, SUM(Garantia) Garantia 
   	        From tCsDiaGarantias g 
	        Where g.Fecha = @Actual
	        Group By g.Fecha, g.Codigo
) AS Garantia ON cd.Fecha = Garantia.Fecha
INNER JOIN tClOficinas    o ON o.codoficina  = c.codoficina 
INNER JOIN tCaProducto    p ON c.codproducto = p.codproducto
INNER JOIN tCaProdPerTipoCredito    tc ON c.CodTipoCredito   = tc.CodTipoCredito 
INNER JOIN tCsPadronClientes        pc ON cd.CodUsuario       = pc.CodUsuario 
left  join (
    SELECT CodPrestamo, CodUsuario, ROUND(AVG(Cuota), 2) AS Amortizacion
    FROM (
        Select d.CodPrestamo, d.CodUsuario, SecCuota, SUM(MontoCuota) AS Cuota
        From tCsCarteraDet d
        inner Join tCsPadronPlanCuotas pc On d.CodPrestamo = pc.CodPrestamo And d.CodUsuario  = pc.CodUsuario 
        Where d.fecha = @Fecha and pc.CodConcepto in ('CAPI', 'INTE', 'IVAIT')
        Group By d.CodPrestamo, d.CodUsuario, SecCuota
    ) AS Cuotas
    GROUP BY CodPrestamo, CodUsuario
) CU on CD.CodPrestamo = CU.CodPrestamo and CD.CodUsuario = CU.CodUsuario
left  join (
    SELECT cd.CodPrestamo, cd.CodUsuario, cd.CapitalVencido + cd.InteresVencido + cd.MoratorioVencido AS CarteraVencidaAnterior
    FROM tCsCarteraDet AS cd
    INNER JOIN tCsCartera AS c1 ON cd.Fecha = c1.Fecha And cd.CodPrestamo = c1.CodPrestamo
    WHERE cd.Fecha = @Anterior
    AND c1.cartera = 'ACTIVA'
) V on CD.CodPrestamo = V.CodPrestamo and CD.CodUsuario = V.CodUsuario
left join (
    Select CodPrestamo, CodUsCuenta, SUM(SaldoCuenta) AS Ahorro, SUM(Garantia) AS Garantia
    From (
        select a.Fecha, a.CodUsuario CodUsCuenta, a.CodCuenta, a.FraccionCta, a.Renovado, a.SaldoCuenta, Garantias.Garantia, Garantias.CodPrestamo
		from tCsAhorros a 
		left join (
            SELECT Fecha, Codigo AS CodPrestamo, DocPropiedad, SUM(Garantia) AS Garantia
            FROM tCsDiaGarantias
            WHERE Fecha = @Actual
            GROUP BY Fecha, DocPropiedad, Codigo 
		) Garantias ON a.Fecha = Garantias.Fecha And a.CodCuenta = Garantias.DocPropiedad
        where a.Fecha = @Actual
    ) AS Datos
    group by Fecha, CodUsCuenta, CodPrestamo
) AS Ah ON cd.CodUsuario = Ah.CodUsCuenta And cd.CodPrestamo = Ah.CodPrestamo 
LEFT  JOIN vGnlUbigeo          vu ON ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) = vu.CodUbiGeo 
LEFT  JOIN tUsClSexo            s ON pc.Sexo            = s.Sexo
LEFT  JOIN tCaClDestino         d ON cd.CodDestino      = d.CodDestino
LEFT  JOIN tUsClEstadoCivil     e ON pc.CodEstadoCivil  = e.CodEstadoCivil
LEFT  JOIN tUsClTipoPropiedad  TP ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = TP.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
LEFT  JOIN tCaClModalidadPlazo mp ON c.ModalidadPlazo   = mp.ModalidadPlazo
LEFT  JOIN tClActividad         a ON pc.LabCodActividad = a.CodActividad
LEFT  JOIN tCaClTecnologia      t ON p.Tecnologia       = t.Tecnologia 
LEFT  JOIN tClZona   z ON o.Zona = z.Zona
WHERE c.fecha   = @Fecha 
AND c.cartera = 'ACTIVA'
ORDER BY CD.CodPrestamo, CD.CodUsuario                    
--OPTION(RECOMPILE)

--10441

--------------------------------------------------------------------------------------------------------------------
/*
declare @DatosCartera table (
codusuario varchar(15),
FechaInf   datetime,
Fecha      datetime,
CodPrestamo     varchar(25),
FechaPrestamo   datetime,
MontoInicial    money,
SaldoActual     money,
FinLacp         varchar(50),
Finalidad       varchar(50),
Estatus         varchar(50),
Reestructurado   char(2),
FechaVencimiento datetime,
DiasVencidos     smallint,
CVigIO           money,
CVigIM           money,
CVenIO           money,
CVenIM           money,
Sucursal         varchar(50),
Poblacion        varchar(50),
ZG               varchar(50),
Edad             smallint,
Sexo             char(1),
EstadoCivil       varchar(50),
TipoDeVivienda     varchar(50),
TiempoDeResidencia smallint,
Plazo              varchar(50),
Actividad          varchar(150),
DXV                smallint,
TipoDePrestamo     varchar(50),
PlanDelCredito     varchar(50),
Tasa                   money,
NumeroDeAmortizaciones smallint,
FrecuenciaDePago       smallint,
PlazoEnMeses           smallint,
PagosVencidosConsecutivos smallint,
Garantia                  money,              
MontoExpuesto      money,                      
ReservaExpuesta    money,                      
Interes            money,                      
ReservaInteres     money,                      
NroDiasAtraso      smallint,
PReservaCapital    money,                      
Tecnologia         varchar(50),                                
Region             varchar(50)
)

insert into @DatosCartera
SELECT cd.codusuario, 
       c.Fecha FechaInf,
       @Fecha Fecha,                        
       c.CodPrestamo,
       c.FechaDesembolso FechaPrestamo,
       cd.MontoDesembolso MontoInicial,
	   cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido SaldoActual,
       tc.Descripcion AS FinLacp,
       d.DescDestino Finalidad,
       c.Estado Estatus,
       CASE WHEN c.TipoReprog IN ('REPRO') 
            THEN 'SI'--'Reestructurado' 
            ELSE 'NO' END AS Reestructurado, 
	   c.FechaVencimiento, 
	   DATEDIFF(day, c.FechaDesembolso, c.FechaVencimiento) DiasVencidos, 
	   cd.InteresVigente AS CVigIO, 
	   cd.MoratorioVigente AS CVigIM, 
	   cd.InteresVencido AS CVenIO, 
	   cd.MoratorioVencido AS CVenIM, 
	   o.NomOficina AS Sucursal, 
	   SUBSTRING(vu.CP2_Municipio, 8, 100) AS Poblacion, 
	   Case vu.ZonaLugar When 'Urbano' Then 'Semiurbano' Else vu.ZonaLugar End AS ZG, 
	   dbo.fduEdad(pc.FechaNacimiento, c.Fecha) AS Edad, 
	   s.SHF AS Sexo, 
	   CASE s.SHF WHEN 'H' THEN e.Masculino WHEN 'M' THEN e.Femenino ELSE 'Desconocido' END AS EstadoCivil, 
	   v.TipoPro AS TipoDeVivienda, 
	   ISNULL(pc.TiempoResidirDirFam, pc.TiempoResidirDirNeg) AS TiempoDeResidencia, 
 	   CAST(c.NroCuotas AS Varchar(10)) + ' ' + CASE WHEN c.NroCuotas = 1 
  												     THEN mp.Singular 
												     WHEN c.NroCuotas > 1 
	 											     THEN mp.Plural END AS Plazo,
  	   a.Nombre as Actividad, 
       CASE WHEN DateDiff(Day, c.Fecha, FechaVencimiento) < 0 
	        THEN 0 
	        ELSE DateDiff(Day, c.Fecha, FechaVencimiento) END AS DXV, 
	   tc.Descripcion TipoDePrestamo, 
  	   p.NombreProdCorto PlanDelCredito, 
  	   c.TasaIntCorriente Tasa, 
  	   c.NroCuotasPagadas NumeroDeAmortizaciones, 
  	   c.NrodiasEntreCuotas FrecuenciaDePago, 
       DATEDIFF(Day, c.FechaDesembolso,c.FechaVencimiento) / 30 AS PlazoEnMeses, 

	   CASE WHEN NroDiasAtraso = 0
	        THEN 0 
	        WHEN NroDiasAtraso > 0 
	        THEN CuotaActual - NroCuotasPagadas END AS PagosVencidosConsecutivos, 
	   ISNULL(Garantia.Garantia, 0) AS Garantia, 
	   CASE WHEN cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido-Isnull(Garantia.Garantia, 0) < 0 
	        THEN 0 
	        ELSE cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido-Isnull(Garantia.Garantia, 0) END AS MontoExpuesto, 
	   cd.SReservaCapital + cd.SReservaInteres AS ReservaExpuesta, 
	   cd.InteresVigente+cd.MoratorioVigente+cd.InteresVencido+cd.MoratorioVencido AS Interes, 
	   cd.SReservaInteres AS ReservaInteres, 
	   c.NroDiasAtraso, 
	   cd.PReservaCapital,
       t.NombreTec Tecnologia, 
       o.zona+ ' '+ z.Nombre Region
 -- INTO #DatosCartera
  FROM tCsCartera c
 INNER JOIN tCsCarteraDet cd ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo
 LEFT OUTER JOIN (Select Fecha, Codigo, SUM(Garantia) Garantia 
	   	             From tCsDiaGarantias g 
		            Where g.Fecha        = @Actual
		            Group By g.Fecha, g.Codigo) AS Garantia ON cd.Fecha       = Garantia.Fecha 
 INNER JOIN tClOficinas    o ON o.codoficina  = c.codoficina 
 INNER JOIN tCaProducto    p ON c.codproducto = p.codproducto
 INNER JOIN tCaProdPerTipoCredito    tc ON c.CodTipoCredito   = tc.CodTipoCredito 
 INNER JOIN tCsPadronClientes        pc ON cd.CodUsuario       = pc.CodUsuario 
 LEFT OUTER JOIN vGnlUbigeo          vu ON ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) = vu.CodUbiGeo 
 LEFT OUTER JOIN tUsClSexo            s ON pc.Sexo            = s.Sexo
 LEFT OUTER JOIN tCaClDestino         d ON cd.CodDestino      = d.CodDestino
 LEFT OUTER JOIN tUsClEstadoCivil     e ON pc.CodEstadoCivil  = e.CodEstadoCivil
 LEFT OUTER JOIN tUsClTipoPropiedad   v ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = v.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
 LEFT OUTER JOIN tCaClModalidadPlazo mp ON c.ModalidadPlazo   = mp.ModalidadPlazo
 LEFT OUTER JOIN tClActividad         a ON pc.LabCodActividad = a.CodActividad
 LEFT OUTER JOIN tCaClTecnologia      t ON p.Tecnologia       = t.Tecnologia 
 LEFT OUTER JOIN tClZona   z ON o.Zona = z.Zona
WHERE c.fecha   = @Fecha 
  AND c.cartera = 'ACTIVA'

----------------------------------------------------------------------------------------------
--create clustered index IX_Datoscartera1 on #DatosCartera (CodPrestamo, codUsuario)

declare @Cuotas Table (
    CodPrestamo varchar(25), 
    CodUsuario  varchar(15),
    Amortizacion money
)

insert into @Cuotas
SELECT CodPrestamo, CodUsuario, AVG(Cuota) AS Amortizacion
FROM (
    Select d.CodPrestamo, d.CodUsuario, SecCuota, SUM(MontoCuota) AS Cuota
    From @DatosCartera d
    Left Outer Join tCsPadronPlanCuotas pc On d.CodPrestamo = pc.CodPrestamo And d.CodUsuario  = pc.CodUsuario 
    Where pc.CodConcepto in ('CAPI', 'INTE', 'IVAIT')
    Group By d.CodPrestamo, d.CodUsuario, SecCuota
) AS Cuotas
GROUP BY CodPrestamo, CodUsuario

----------------------------------------------------------------------------------------------

declare @CarteraVencidaAnterior Table (
    CodPrestamo varchar(25), 
    CodUsuario  varchar(15),
    CarteraVencidaAnterior money
)

insert into @CarteraVencidaAnterior
SELECT d.CodPrestamo, d.CodUsuario, cd1.CapitalVencido + cd1.InteresVencido + cd1.MoratorioVencido AS CarteraVencidaAnterior
FROM @DatosCartera d		   
INNER JOIN tCsCarteraDet AS cd1 ON d.CodPrestamo = cd1.CodPrestamo And d.CodUsuario = cd1.CodUsuario 
INNER JOIN tCsCartera    AS  c1 ON cd1.Fecha = c1.Fecha And cd1.CodPrestamo = c1.CodPrestamo
WHERE cd1.Fecha = @Anterior

----------------------------------------------------------------------------------------------

--SELECT Fecha, Codigo AS CodPrestamo, DocPropiedad, SUM(Garantia) AS Garantia
--INTO #Garantias
--FROM tCsDiaGarantias
--WHERE Fecha = @Actual
--GROUP BY Fecha, DocPropiedad, Codigo --AS Garantias

----------------------------------------------------------------------------------------------

SELECT FechaInf, D.CodPrestamo Numero, FechaPrestamo, MontoInicial,	SaldoActual, FinLacp, Finalidad, Estatus, 
       Reestructurado, coalesce(v.CarteraVencidaAnterior,0) CarteraVencidaAnterior, D.FechaVencimiento , DiasVencidos, 
	   ISNULL(ROUND(Ahorro.Ahorro, 2), 0) AS Ahorro, 
       CVigIO, CVigIM, CVenIO, CVenIM, Sucursal, Poblacion, ZG,	Edad, Sexo, EstadoCivil, TipoDeVivienda, Actividad, TiempoDeResidencia, Plazo ModalidadPlazo, DXV, 
       PlanDelCredito, Tasa, NumeroDeAmortizaciones, FrecuenciaDePago,	PlazoEnMeses, ROUND(cu.Amortizacion, 2) AS Amortizacion, PagosVencidosConsecutivos,
   	   D.Garantia, 
	   GarantiaReal = CASE WHEN ISNULL(D.Garantia, 0) = 0 
	                       THEN 0
						   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN ISNULL(ROUND(Ahorro.Garantia, 2), 0)
						   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
						    And ISNULL(D.Garantia, 0)         > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				    And ISNULL(D.Garantia, 0)         < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
		 				  THEN ISNULL(D.Garantia, 0) END,
   	   MontoExpuesto, ReservaExpuesta, Interes, ReservaInteres, D.NroDiasAtraso,
   	   
	   ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroComprometido, 
	   ISNULL(ROUND(Ahorro.Ahorro, 2), 0) - ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroNoComprometidoConCredito, 
   	   D.PReservaCapital, 
   	   Tecnologia, Region
FROM @DatosCartera D      
INNER JOIN tCsCarteraDet cd ON D.CodPrestamo = cd.CodPrestamo AND D.Fecha = cd.Fecha  AND D.CodUsuario = cd.CodUsuario
LEFT JOIN (
    Select Fecha, CodPrestamo, CodUsCuenta, SUM(SaldoCuenta) AS Ahorro, SUM(Garantia) AS Garantia
    From (
        select a.Fecha, a.CodUsuario CodUsCuenta, a.CodCuenta, a.FraccionCta, a.Renovado, a.SaldoCuenta, Garantias.Garantia, Garantias.CodPrestamo
		from tCsAhorros a 
		left join (
            SELECT Fecha, Codigo AS CodPrestamo, DocPropiedad, SUM(Garantia) AS Garantia
            FROM tCsDiaGarantias
            WHERE Fecha = @Actual
            GROUP BY Fecha, DocPropiedad, Codigo 
		) Garantias ON a.Fecha = Garantias.Fecha And a.CodCuenta = Garantias.DocPropiedad
        where a.Fecha = @Actual
    ) AS Datos
    group by Fecha, CodUsCuenta, CodPrestamo
) AS Ahorro ON cd.CodUsuario = Ahorro.CodUsCuenta AND cd.Fecha = Ahorro.Fecha And cd.CodPrestamo = Ahorro.CodPrestamo 
LEFT JOIN @CarteraVencidaAnterior V ON D.CodPrestamo = v.CodPrestamo   AND D.CodUsuario = v.CodUsuario
LEFT JOIN @Cuotas                CU ON D.CodPrestamo = cu.CodPrestamo  AND D.CodUsuario = cu.CodUsuario
ORDER BY D.CodPrestamo, D.CodUsuario                    

--drop table #Cuotas
--drop table #Garantias
--drop table #DatosCartera
--drop table #CarteraVencidaAnterior
*/

GO