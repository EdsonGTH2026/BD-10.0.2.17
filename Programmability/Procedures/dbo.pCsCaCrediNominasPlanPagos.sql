SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaCrediNominasPlanPagos]   
               (@FecCierre SMALLDATETIME )    
AS    

-----------------------------------
--PLAN PAGOS CREDITOS CREDINOMINA--
-----------------------------------  
SELECT    cast( tCsCartera.Fecha as varchar) AS Corte, tCsCartera.CodUsuario, tCsPadronClientes.NombreCompleto, tCsCartera.CodPrestamo, PlanCuotas.SecCuota, 
                      PlanCuotas.FechaVencimiento, PlanCuotas.Capital, PlanCuotas.Interes, PlanCuotas.IVA, PlanCuotas.Cuota
FROM         tCsCartera INNER JOIN
                          (SELECT     CodPrestamo, SecCuota, MAX(FechaVencimiento) AS FechaVencimiento, SUM(Capital) AS Capital, SUM(Interes) AS Interes, SUM(IVA) AS IVA, SUM(Capital) 
                                                   + SUM(Interes) + SUM(IVA) AS Cuota
                            FROM          (SELECT     CodPrestamo, CodConcepto, SecCuota, CASE CodConcepto WHEN 'CAPI' THEN SUM(MontoCuota) ELSE 0 END AS Capital, 
                                                                           CASE CodConcepto WHEN 'INTE' THEN SUM(MontoCuota) ELSE 0 END AS Interes, CASE CodConcepto WHEN 'IVAIT' THEN SUM(MontoCuota) 
                                                                           ELSE 0 END AS IVA, FechaVencimiento
                                                    FROM          tCsPadronPlanCuotas
                                                    WHERE      (CodPrestamo IN
                                                                               (SELECT     CodPrestamo
                                                                                 FROM          tCsCartera AS tCsCartera_1
                                                                                 WHERE      (Cartera = 'ADMINISTRATIVA') 
                                                                                /*
                                                                                 AND (Fecha IN
                                                                                                            (SELECT     FechaConsolidacion  AS Expr1
                                                                                                              FROM          vCsFechaConsolidacion))
                                                                                                              --*/
                                                                                                              ))
                                                    GROUP BY CodPrestamo, CodConcepto, SecCuota, FechaVencimiento) AS Datos
                            GROUP BY CodPrestamo, SecCuota) AS PlanCuotas ON tCsCartera.CodPrestamo = PlanCuotas.CodPrestamo LEFT OUTER JOIN
                      tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario
WHERE tCsCartera.Fecha = @FecCierre
/*
WHERE     (tCsCartera.Fecha IN
                          (SELECT     FechaConsolidacion AS Expr1
                            FROM          vCsFechaConsolidacion AS vCsFechaConsolidacion_1)) AND (tCsCartera.Cartera = 'ADMINISTRATIVA')
--*/                            
Order by tCsCartera.CodPrestamo, Seccuota                            
GO