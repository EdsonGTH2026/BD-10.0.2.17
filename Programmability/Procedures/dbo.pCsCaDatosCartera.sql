SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCaDatosCartera]
               ( @Fecha SMALLDATETIME)
AS
--DECLARE @Fecha SMALLDATETIME
--SET @Fecha   = '20130831' 

DECLARE @Periodo VARCHAR(6)
    SET @Periodo = dbo.fduFechaATexto(@Fecha, 'AAAAMM')

DECLARE @Actual	  SMALLDATETIME
DECLARE @Anterior SMALLDATETIME
	SET @Actual	  = DateAdd(Day, -1, Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, Cast(@Periodo + '01' As SmallDateTime)), 'AAAAMM') + '01' As SmallDateTime))
	SET @Anterior = DateAdd(Day, -1, Cast(@Periodo + '01' As SmallDateTime))
  --Print @Actual
  --Print @Anterior
    
--select * from tcscartera                        
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
/*
      (Select cd2.CapitalVencido+cd2.InteresVencido+cd2.MoratorioVencido 
		 From tCsCarteraDet cd2 with(nolock)
		Where cd2.CodPrestamo = cd.CodPrestamo 
		  And cd2.CodUsuario  = cd.CodUsuario
		  And cd2.Fecha       = @Anterior) AS CarteraVencidaAnterior,
*/
	   c.FechaVencimiento, 
	   DATEDIFF(day, c.FechaDesembolso, c.FechaVencimiento) DiasVencidos, 
	   --ISNULL(ROUND(Ahorro.Ahorro, 2), 0) AS Ahorro, 
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

	   --ROUND(Cuotas.Amortizacion, 2) AS Amortizacion, 

	   CASE WHEN NroDiasAtraso = 0
	        THEN 0 
	        WHEN NroDiasAtraso > 0 
	        THEN CuotaActual - NroCuotasPagadas END AS PagosVencidosConsecutivos, 
	   --ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroComprometido, 
	   --ISNULL(ROUND(Ahorro.Ahorro, 2), 0) - ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroNoComprometidoConCredito, 
	   ISNULL(Garantia.Garantia, 0) AS Garantia, 
/*	   
	   GarantiaReal = CASE WHEN ISNULL(Garantia.Garantia, 0) = 0 
	                       THEN 0
						   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN ISNULL(ROUND(Ahorro.Garantia, 2), 0)
						   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
						    And ISNULL(Garantia.Garantia, 0)         > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				    And ISNULL(Garantia.Garantia, 0)         < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
		 				  THEN ISNULL(Garantia.Garantia, 0) END,
*/
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
  INTO #DatosCartera
  FROM tCsCartera c with(nolock)
 INNER JOIN tCsCarteraDet cd with(nolock) ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo
  LEFT OUTER JOIN (Select Fecha, Codigo, SUM(Garantia) Garantia 
	   	             From tCsDiaGarantias g with(nolock) 
		            Where g.Fecha        = @Actual
		            Group By g.Fecha, g.Codigo) AS Garantia ON cd.Fecha       = Garantia.Fecha 
		                                                   AND cd.CodPrestamo = Garantia.Codigo
/*
  LEFT OUTER JOIN (Select CodPrestamo, CodUsuario, AVG(Cuota) AS Amortizacion
				     From (select CodPrestamo, CodUsuario, SecCuota, SUM(MontoCuota) AS Cuota
							 from tCsPadronPlanCuotas with(nolock)
							where CodConcepto in ('CAPI', 'INTE', 'IVAIT')
						    group by CodPrestamo, CodUsuario, SecCuota
						  ) AS Datos_1
					 group by CodPrestamo, CodUsuario) AS Cuotas ON cd.CodPrestamo = Cuotas.CodPrestamo
					                                            AND cd.CodUsuario  = Cuotas.CodUsuario */
 INNER JOIN tClOficinas    o with(nolock) ON o.codoficina  = c.codoficina 
 INNER JOIN tCaProducto    p with(nolock) ON c.codproducto = p.codproducto
 INNER JOIN tCaProdPerTipoCredito    tc with(nolock) ON c.CodTipoCredito   = tc.CodTipoCredito 
 INNER JOIN tCsPadronClientes        pc with(nolock) ON cd.CodUsuario       = pc.CodUsuario 
 LEFT OUTER JOIN vGnlUbigeo          vu with(nolock) ON ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) = vu.CodUbiGeo 
 LEFT OUTER JOIN tUsClSexo            s with(nolock) ON pc.Sexo            = s.Sexo
 LEFT OUTER JOIN tCaClDestino         d with(nolock) ON cd.CodDestino      = d.CodDestino
 LEFT OUTER JOIN tUsClEstadoCivil     e with(nolock) ON pc.CodEstadoCivil  = e.CodEstadoCivil
 LEFT OUTER JOIN tUsClTipoPropiedad   v with(nolock) ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = v.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
 LEFT OUTER JOIN tCaClModalidadPlazo mp with(nolock) ON c.ModalidadPlazo   = mp.ModalidadPlazo
 LEFT OUTER JOIN tClActividad         a with(nolock) ON pc.LabCodActividad = a.CodActividad
 LEFT OUTER JOIN tCaClTecnologia      t with(nolock) ON p.Tecnologia       = t.Tecnologia 
 LEFT OUTER JOIN tClZona   z with(nolock) ON o.Zona = z.Zona
WHERE c.fecha   = @Fecha 
  AND c.cartera = 'ACTIVA'

--select * from #DatosCartera where codprestamo = '006-157-06-02-00104' --11093
--select distinct 10488
--select 11093+11093
--SELECT * FROM #DatosCartera
SELECT CodPrestamo, CodUsuario, AVG(Cuota) AS Amortizacion
  INTO #Cuotas
  FROM (Select d.CodPrestamo, d.CodUsuario, SecCuota, SUM(MontoCuota) AS Cuota
          From #DatosCartera d
          Left Outer Join tCsPadronPlanCuotas pc with(nolock) On d.CodPrestamo = pc.CodPrestamo
		        		                                    And d.CodUsuario  = pc.CodUsuario 
         Where pc.CodConcepto in ('CAPI', 'INTE', 'IVAIT')
         Group By d.CodPrestamo, d.CodUsuario, SecCuota
        ) AS Cuotas
  GROUP BY CodPrestamo, CodUsuario
  
SELECT d.CodPrestamo, d.CodUsuario, cd1.CapitalVencido + cd1.InteresVencido + cd1.MoratorioVencido AS CarteraVencidaAnterior
  INTO #CarteraVencidaAnterior
  FROM #DatosCartera d		   
 INNER JOIN tCsCarteraDet AS cd1 with(nolock) ON d.CodPrestamo = cd1.CodPrestamo And d.CodUsuario = cd1.CodUsuario 
 INNER JOIN tCsCartera    AS  c1 with(nolock) ON cd1.Fecha = c1.Fecha And cd1.CodPrestamo = c1.CodPrestamo
 WHERE cd1.Fecha = @Anterior

 SELECT Fecha, Codigo AS CodPrestamo, DocPropiedad, SUM(Garantia) AS Garantia
   INTO #Garantias
   FROM tCsDiaGarantias with(nolock)
  WHERE Fecha = @Actual
  GROUP BY Fecha, DocPropiedad, Codigo --AS Garantias
--select * from #Garantias
--select * from #CarteraVencidaAnterior

SELECT   FechaInf , #DatosCartera.CodPrestamo Numero, FechaPrestamo, MontoInicial,	SaldoActual, FinLacp, Finalidad, Estatus, 
       Reestructurado, coalesce(v.CarteraVencidaAnterior,0) CarteraVencidaAnterior,#DatosCartera.FechaVencimiento , DiasVencidos, 
	   ISNULL(ROUND(Ahorro.Ahorro, 2), 0) AS Ahorro, 
       CVigIO, CVigIM, CVenIO, CVenIM, Sucursal, Poblacion, ZG,	Edad, Sexo, EstadoCivil, TipoDeVivienda, Actividad, TiempoDeResidencia, Plazo ModalidadPlazo, DXV, 
       --TipoDePrestamo, 
       PlanDelCredito, Tasa, NumeroDeAmortizaciones, FrecuenciaDePago,	PlazoEnMeses, ROUND(cu.Amortizacion, 2) AS Amortizacion, PagosVencidosConsecutivos,
   	   #DatosCartera.Garantia, 
   	   --GarantiaReal,
   	   --/*
	   GarantiaReal = CASE WHEN ISNULL(#DatosCartera.Garantia, 0) = 0 
	                       THEN 0
						   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN ISNULL(ROUND(Ahorro.Garantia, 2), 0)
						   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
						    And ISNULL(#DatosCartera.Garantia, 0)         > (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
						   THEN (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				   WHEN ISNULL(ROUND(Ahorro.Garantia, 2), 0) < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido) 
		 				    And ISNULL(#DatosCartera.Garantia, 0)         < (cd.SaldoCapital+cd.InteresVigente+cd.InteresVencido+cd.MoratorioVigente+cd.MoratorioVencido)
		 				  THEN ISNULL(#DatosCartera.Garantia, 0) END,
   	   --*/
   	   MontoExpuesto, ReservaExpuesta, Interes, ReservaInteres, #DatosCartera.NroDiasAtraso,
   	   
	   ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroComprometido, 
	   ISNULL(ROUND(Ahorro.Ahorro, 2), 0) - ISNULL(ROUND(Ahorro.Garantia, 2), 0) AS AhorroNoComprometidoConCredito, 
   	   
   	   #DatosCartera.PReservaCapital, 
   	   Tecnologia, Region
  FROM #DatosCartera         with(nolock) 
 INNER JOIN tCsCarteraDet cd with(nolock) ON #DatosCartera.CodPrestamo = cd.CodPrestamo AND #DatosCartera.Fecha = cd.Fecha  AND #DatosCartera.CodUsuario = cd.CodUsuario

  LEFT OUTER JOIN (Select Fecha, CodPrestamo, CodUsCuenta, SUM(SaldoCuenta) AS Ahorro, SUM(Garantia) AS Garantia
                     From (select a.Fecha, a.CodUsuario CodUsCuenta, a.CodCuenta, a.FraccionCta, a.Renovado, a.SaldoCuenta, Garantias.Garantia, Garantias.CodPrestamo
	  					     from tCsAhorros a with(nolock) 
				             left outer join (select * from #Garantias) AS Garantias ON a.Fecha     = Garantias.Fecha 
					 		                                                        And a.CodCuenta = Garantias.DocPropiedad
				            where a.Fecha = @Actual) AS Datos
                    group by Fecha, CodUsCuenta, CodPrestamo) AS Ahorro ON cd.CodUsuario = Ahorro.CodUsCuenta AND cd.Fecha = Ahorro.Fecha And cd.CodPrestamo = Ahorro.CodPrestamo 
  LEFT OUTER JOIN #CarteraVencidaAnterior v ON #DatosCartera.CodPrestamo = v.CodPrestamo   AND #DatosCartera.CodUsuario = v.CodUsuario
  LEFT OUTER JOIN #Cuotas                cu ON #DatosCartera.CodPrestamo = cu.CodPrestamo  AND #DatosCartera.CodUsuario = cu.CodUsuario
 ORDER BY #DatosCartera.CodPrestamo, #DatosCartera.CodUsuario                    

drop table #Cuotas
drop table #Garantias
drop table #DatosCartera
drop table #CarteraVencidaAnterior 
--11093

--select * from #DatosCartera where codprestamo = '006-156-06-09-00335'
--select * from tCsCartera where codprestamo = '006-156-06-09-00335' and fecha       = '20130831'
--select * from tCsCarteraDet where codprestamo = '006-156-06-09-00335' and fecha       = '20130831'
GO