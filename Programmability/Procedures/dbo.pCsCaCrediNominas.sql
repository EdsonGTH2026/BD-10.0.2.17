SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaCrediNominas]   
               (@FecCierre SMALLDATETIME )    
AS    

----------------------------------
--LISTA LOS CREDITOS CREDINOMINA--
----------------------------------
SELECT     cast(tCsCartera.Fecha as varchar) AS Corte, tCsCartera.CodUsuario, tCsPadronClientes.NombreCompleto, tCsCartera.CodPrestamo, tCsCartera.FechaDesembolso, 
           tCsCartera.FechaVencimiento, tCsCartera.MontoDesembolso, tCsCartera.NroCuotas, PlanCuotas.Interes, PlanCuotas.IVA, PlanCuotas.Cuota
FROM         tCsCartera INNER JOIN
                          (SELECT     CodPrestamo, SUM(Capital) AS Capital, SUM(Interes) AS Interes, SUM(IVA) AS IVA, AVG(Cuota) AS Cuota
                            FROM          (SELECT     CodPrestamo, SecCuota, SUM(Capital) AS Capital, SUM(Interes) AS Interes, SUM(IVA) AS IVA, SUM(Capital) + SUM(Interes) + SUM(IVA) 
                                                                           AS Cuota
                                                    FROM          (SELECT     CodPrestamo, CodConcepto, SecCuota, CASE CodConcepto WHEN 'CAPI' THEN SUM(MontoCuota) ELSE 0 END AS Capital, 
                                                                                                   CASE CodConcepto WHEN 'INTE' THEN SUM(MontoCuota) ELSE 0 END AS Interes, 
                                                                                                   CASE CodConcepto WHEN 'IVAIT' THEN SUM(MontoCuota) ELSE 0 END AS IVA
                                                                            FROM          tCsPadronPlanCuotas
                                                                            WHERE      (CodPrestamo IN
                                                                                                       (SELECT codprestamo --,fecha, CodPrestamo,*
                                                                                                          FROM tCsCartera
                                                                                                         WHERE (Cartera = 'ADMINISTRATIVA') 
                                                                                                           --and codprestamo='097-303-06-00-00863'
                                                                                                         --order by fecha desc--, codprestamo
                                                                                                         /*
                                                                                                         AND (Fecha IN
                                                                                                                                    (SELECT     FechaConsolidacion AS Expr1
                                                                                                                                      FROM          vCsFechaConsolidacion))
                                                                                                                                      --*/
                                                                                                                                      ))
                                                                            GROUP BY CodPrestamo, CodConcepto, SecCuota) AS Datos
                                                    GROUP BY CodPrestamo, SecCuota) AS Datos
                            GROUP BY CodPrestamo) AS PlanCuotas ON tCsCartera.CodPrestamo = PlanCuotas.CodPrestamo LEFT OUTER JOIN
                      tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario
WHERE tCsCartera.Fecha = @FecCierre
/*
WHERE     (tCsCartera.Fecha IN
                          (SELECT     FechaConsolidacion  AS Expr1
                            FROM          vCsFechaConsolidacion)) AND (tCsCartera.Cartera = 'ADMINISTRATIVA')
                           -- */
Order by tCsCartera.CodPrestamo

GO