SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsCaRptVencimientosxRangos
--EXEC pCsCaRptVencimientosxRangos '20130918'
CREATE PROCEDURE [dbo].[pCsCaRptVencimientosxRangos]
               ( @Fecha SMALLDATETIME )
AS

DECLARE @FechaC SMALLDATETIME  
 SELECT @FechaC = FechaConsolidacion FROM vCsFechaConsolidacion  
     IF @Fecha  > @FechaC
        BEGIN
          SET @Fecha = @FechaC
        END
        --select * from vCsFechaConsolidacion
  print @Fecha

 SELECT DISTINCT @Fecha FechaInf, c.CodPrestamo, 
        CASE WHEN c.CodGrupo is null THEN ' ' ELSE cg.NombreGrupo END Grupo,
        pc.nomcliente Cliente,
        p.NombreProdCorto,
        c.FechaDesembolso, 
        MontoCuotaT Monto,
        --CuotasVenc.CAPI + CuotasVenc.INTE + CuotasVenc.INPE MontoCuota, --c.MontoDesembolso,
        CASE WHEN c.CodGrupo is null
             THEN pcd.SecuenciaCliente
             ELSE pcd.SecuenciaGrupo
              END Ciclo,         
        c.NroDiasAtraso DiasAtrasoActual,
        NroDiasAcumulado DiasAtrasoAcumulados,
        FechaMora.FechaEntroMora, --'' FechaEntroMora,
        c.FechaVencimiento,
        --select dateadd(day,1,getdate())
        CASE WHEN c.FechaVencimiento <= DATEADD(DAY,30,@Fecha)
             THEN 'X'
             ELSE ''
              END Vcmto30oMenosDias,
        CASE WHEN c.FechaVencimiento >= DATEADD(DAY,31,@Fecha) AND c.FechaVencimiento <= DATEADD(DAY,60,@Fecha)
             THEN 'X'
             ELSE ''
              END Vcmto31_60Dias,
        CASE WHEN c.FechaVencimiento >= DATEADD(DAY,61,@Fecha) AND c.FechaVencimiento <= DATEADD(DAY,89,@Fecha)
             THEN 'X'
             ELSE ''
              END Vcmto61_89Dias,
        CASE WHEN c.FechaVencimiento >= DATEADD(DAY,90,@Fecha)
             THEN 'X'
             ELSE ''
             END Vcmto90oMasDias
  FROM tCsCarteraDet   cd WITH(NOLOCK) 
 INNER JOIN tCsCartera  c WITH(NOLOCK) ON cd.Fecha = c.Fecha AND cd.CodPrestamo = c.CodPrestamo 
 INNER JOIN tClOficinas o WITH(NOLOCK) ON c.CodOficina = o.CodOficina 
 INNER JOIN tCsPadronCarteraDet pcd WITH(NOLOCK) ON cd.CodPrestamo = pcd.CodPrestamo 
                                                AND cd.CodUsuario  = pcd.CodUsuario 
 INNER JOIN tCaProducto p WITH(NOLOCK) ON c.CodProducto = p.CodProducto 
 INNER JOIN (SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento,
                    SUM(CAPI+INTE+INPE) MontoCuotaT
               FROM
                   (SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento, 
                           SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE
                     FROM (SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario,  
                                  CASE CodConcepto WHEN 'capi' 
                                                   THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS CAPI, 
                                  CASE CodConcepto WHEN 'inte' 
                                                   THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INTE, 
                                  CASE CodConcepto WHEN 'inpe' 
                                                   THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INPE, 
                                  CASE CodConcepto WHEN 'inve'
                                                   THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INVE 
                             FROM tCsPadronPlanCuotas 
                            WHERE EstadoCuota      <> 'CANCELADO' 
                              AND FechaVencimiento >= @Fecha
                            --AND FechaVencimiento >= '20130917' 
                              AND FechaVencimiento  = (Select min(ppc.FechaVencimiento) 
                                                         From tCsPadronPlanCuotas ppc 
                                                        Where ppc.EstadoCuota      <> 'CANCELADO' 
                                                          And ppc.FechaVencimiento >= @Fecha --'20130917'
                                                          And ppc.CodPrestamo = tCsPadronPlanCuotas.CodPrestamo
                                                          And ppc.CodUsuario  = tCsPadronPlanCuotas.CodUsuario
                                                       )
                              --and codprestamo = '011-158-06-03-00171'
                             -- AND (FechaVencimiento >= @Fecha) --'20130917' ) 
                            --AND (FechaVencimiento <= '20131231')
                          ) A 
                    --where codprestamo = '011-158-06-03-00171'
                    GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario
                   ) CuotasVenc
                    --where codprestamo = '011-158-06-03-00171'
             GROUP BY  Fecha, FechaVencimiento, CodPrestamo, CodUsuario
            ) TotalCuota ON cd.Fecha       = TotalCuota.Fecha 
                        AND cd.CodPrestamo = TotalCuota.CodPrestamo 
                        AND cd.CodUsuario  = TotalCuota.CodUsuario 
                        /*cd.Fecha       = CuotasVenc.Fecha 
                        AND cd.CodPrestamo = CuotasVenc.CodPrestamo 
                        AND cd.CodUsuario  = CuotasVenc.CodUsuario */
 INNER JOIN (SELECT CodPrestamo, CodUsuario, min(FechaVencimiento) FechaEntroMora
               FROM tCsPadronPlanCuotas
              WHERE DiasAtrCuota > 0 
                AND CodConcepto = 'CAPI'
              GROUP BY CodPrestamo, CodUsuario) FechaMora ON cd.CodPrestamo = FechaMora.CodPrestamo 
                                                         AND cd.CodUsuario  = FechaMora.CodUsuario 
                                                                                 
  LEFT OUTER JOIN (SELECT codusuario,nombrecompleto nomcliente FROM tcspadronclientes) pc ON cd.CodUsuario = pc.CodUsuario 
  LEFT OUTER JOIN tCsCarteraGrupos cg WITH(NOLOCK) ON c.CodOficina    = cg.CodOficina
                                                  AND c.CodGrupo      = cg.CodGrupo 
 WHERE c.cartera = 'ACTIVA' --c.Estado <> 'CASTIGADO' --'ACTIVA'
   AND c.Fecha   = @Fecha--'20130917'
 ORDER BY Vcmto30oMenosDias desc, Vcmto31_60Dias desc, Vcmto61_89Dias desc, Vcmto90oMasDias desc, c.CodPrestamo asc
 
--Próximos vencimientos a los rangos de 31 a 60, 61 a 89 y a 90 días, en los cuales 
--se necesitarían los campos de fecha de reporte, 
--numero de crédito, fecha de desembolso, nombre, producto, ciclo, monto, días de mora y fecha en que entro en mora.
 
-- SELECT * FROM tCsPadronPlanCuotas where CODPRESTAMO = '005-156-06-06-00432' and codconcepto = 'CAPI'

--select min(FechaVencimiento) FechaEntroMora from tCsPadronPlanCuotas where DiasAtrCuota > 0                                                                                 
/*        
        CASE WHEN c.CodGrupo is null
             THEN pc.nomcliente
             ELSE cg.NombreGrupo
              END ClienteGrupo,
*/

 --select min(FechaVencimiento) FechaEntroMora from tCsPadronPlanCuotas where DiasAtrCuota > 0 codprestamo = '006-156-06-08-00334'
 
 
 
 
 
 
 
 
 
 
/*
select * from tCsPadronCarteraDet
   FROM tCsCartera c WITH(NOLOCK)
  INNER JOIN tCsCarteraDet         cd WITH(NOLOCK) ON c.Fecha         = cd.Fecha
                                                  AND c.CodPrestamo   = cd.CodPrestamo 
                                                  AND c.CodUsuario    = cd.CodUsuario
  INNER JOIN tCsPadronCarteraDet  pcd WITH(NOLOCK) ON c.Fecha         = cd.Fecha
                                                  AND c.CodPrestamo   = cd.CodPrestamo 
  INNER JOIN tCsPadronClientes     pc WITH(NOLOCK) ON pcd.CodUsuario  = pc.CodUsuario 
  INNER JOIN tCaProducto            p WITH(NOLOCK) ON c.CodProducto   = p.CodProducto 
  LEFT OUTER JOIN tCsCarteraGrupos cg WITH(NOLOCK) ON c.CodOficina    = cg.CodOficina
                                                  AND c.CodGrupo      = cg.CodGrupo 
  WHERE c.Estado <> 'CASTIGADO'
    AND c.Fecha   = '20130916'

  --INNER JOIN tCsPadronPlanCuotas pc WITH(NOLOCK) ON c.CodPrestamo  = p.CodPrestamo 
  INNER JOIN tCsPadronClientes ase WITH(NOLOCK) ON pcd.CodPrestamo = cd.CodPrestamo 
                                               AND pcd.CodUsuario  = cd.CodUsuario 
                                               

 INNER JOIN (SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento, 
                    SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE
               FROM (SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario,  
                            CASE CodConcepto WHEN ''capi'' 
                                             THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS CAPI, 
                            CASE CodConcepto WHEN ''inte'' 
                                             THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INTE, 
                            CASE CodConcepto WHEN ''inpe'' 
                                             THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INPE, 
                            CASE CodConcepto WHEN ''inve'' 
                                             THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INVE 
                       FROM tCsPadronPlanCuotas 
                      WHERE (EstadoCuota <> 'CANCELADO') 
                        AND (FechaVencimiento >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') 
                        AND (FechaVencimiento <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''')) A 
            GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario) CuotasVenc ON tCsCarteraDet.Fecha = CuotasVenc.Fecha 
                                                                                 AND tCsCarteraDet.CodPrestamo = CuotasVenc.CodPrestamo --COLLATE Modern_Spanish_CI_AI 
                                                                                 AND tCsCarteraDet.CodUsuario = CuotasVenc.CodUsuario 




select * from tCsPadronClientes                                               
                                               
    
SELECT * FROM tCsPadronPlanCuotas

select * from tCsPlanCuotas where codprestamo = '010-116-06-00-00049' and CodConcepto = 'CAPI'
select * from tCsPadronPlanCuotas where codprestamo = '010-116-06-00-00049' and CodConcepto = 'CAPI'
 
DECLARE @Fecha SMALLDATETIME  
    SET @Fecha = FechaConsolidacion FROM vCsFechaConsolidacion  

 SELECT CAST(o.CodOficina AS decimal(10, 2)) AS CodOFi, o.CodOficina + ' ' + o.NomOficina AS Oficina,   
        ase.NombreCompleto AS Asesor, t.NombreTec, c.CodPrestamo, c.FechaVencimiento,   
        pc.NombreCompleto AS Cliente,   
        CASE p.tecnologia WHEN 1 THEN pc.NombreCompleto WHEN 3 THEN pc.NombreCompleto ELSE cg.NombreGrupo END AS ClienteGrupo, 
        c.FechaDesembolso, cd.MontoDesembolso, pcd.SecuenciaCliente,   
        cd.SaldoCapital, dac.DiasAtrCuota AS DiasAtrasoAcumulados, c.NroCuotas, c.NroCuotasPorPagar,   
        pcd.SecuenciaGrupo, pc.CodUsuario, tcsclbis.nombre BIS,   
        cd.InteresVigente + cd.InteresVencido AS Interes,   
        cd.MoratorioVigente + cd.MoratorioVencido AS Moratorio, c.NroDiasAtraso, c.Estado   
   FROM tCsPadronCarteraDet pcd 
  INNER JOIN tCsCartera c WITH(NOLOCK)
  INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.Fecha = cd.Fecha AND cd.CodPrestamo = cd.CodPrestamo 
  INNER JOIN tCsPadronClientes ase ON c.CodAsesor = ase.CodUsuario ON pcd.CodPrestamo = cd.CodPrestamo 
                                                                  AND pcd.CodUsuario  = cd.CodUsuario 
  INNER JOIN (SELECT Fecha, CodOficina, CodPrestamo, CodUsuario, SUM(DiasAtrCuota) AS DiasAtrCuota  
                FROM (SELECT DISTINCT Fecha, CodOficina, CodPrestamo, CodUsuario, CAST(DiasAtrCuota AS decimal(10, 2)) AS DiasAtrCuota, SecCuota  
                        FROM tCsPlanCuotas 
                       WHERE Fecha = @Fecha
                      ) a  
               GROUP BY Fecha, CodOficina, CodPrestamo, CodUsuario
              ) dac ON cd.Fecha       = dac.Fecha 
                   AND cd.CodOficina  = dac.CodOficina 
                   AND cd.CodPrestamo = dac.CodPrestamo 
                   AND cd.CodUsuario  = dac.CodUsuario 
  LEFT OUTER JOIN tCsCarteraGrupos  cg ON c.CodOficina  = cg.CodOficina AND c.CodGrupo = cg.CodGrupo 
  LEFT OUTER JOIN tCsPadronClientes pc ON cd.CodUsuario = pc.CodUsuario 
  LEFT OUTER JOIN tCaClTecnologia    t 
  INNER JOIN tCaProducto      p ON t.Tecnologia = p.Tecnologia ON c.CodProducto = p.CodProducto 
  LEFT OUTER JOIN tClOficinas o ON c.CodOficina = o.CodOficina 
  LEFT OUTER JOIN tcsclbis      ON c.BIS=tcsclbis.bis  
 WHERE (c.Estado <> 'castigado') 
   AND (c.Fecha = '20130916') 
--AND (dbo.fduFechaAPeriodo(tCsCartera.FechaVencimiento)   = @Periodo) 
   AND (c.CodOficina = '2')
/*
WHERE     (tCsCartera.Estado <> 'castigado') AND (tCsCartera.Fecha = @Fecha) 
AND (dbo.fduFechaAPeriodo(tCsCartera.FechaVencimiento)   = @Periodo) 
AND (tCsCartera.CodOficina = '2')
*/



DECLARE @Fecha smalldatetime  
Select @Fecha=FechaConsolidacion from vCsFechaConsolidacion  
  
SELECT     CAST(tClOficinas.CodOficina AS decimal(10, 2)) AS CodOFi, tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS Oficina,   
                      Asesor.NombreCompleto AS Asesor, tCaClTecnologia.NombreTec, tCsCartera.CodPrestamo, tCsCartera.FechaVencimiento,   
                      tCsPadronClientes.NombreCompleto AS Cliente,   
                      CASE tcaproducto.tecnologia WHEN 1 THEN tCsPadronClientes.NombreCompleto WHEN 3 THEN tCsPadronClientes.NombreCompleto ELSE tCsCarteraGrupos.NombreGrupo  
                       END AS ClienteGrupo, tCsCartera.FechaDesembolso, tCsCarteraDet.MontoDesembolso, tCsPadronCarteraDet.SecuenciaCliente,   
                      tCsCarteraDet.SaldoCapital, DiasAcumulados.DiasAtrCuota AS DiasAtrasoAcumulados, tCsCartera.NroCuotas, tCsCartera.NroCuotasPorPagar,   
                      tCsPadronCarteraDet.SecuenciaGrupo, tCsPadronClientes.CodUsuario, tcsclbis.nombre BIS,   
                      tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido AS Interes,   
                      tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido AS Moratorio, tCsCartera.NroDiasAtraso, tCsCartera.Estado  
FROM         tCsPadronCarteraDet INNER JOIN  
                      tCsCartera INNER JOIN  
                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN  
                      tCsPadronClientes Asesor ON tCsCartera.CodAsesor = Asesor.CodUsuario ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND   
                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN  
                          (SELECT     Fecha, CodOficina, CodPrestamo, CodUsuario, SUM(DiasAtrCuota) AS DiasAtrCuota  
                            FROM          (SELECT DISTINCT Fecha, CodOficina, CodPrestamo, CodUsuario, CAST(DiasAtrCuota AS decimal(10, 2)) AS DiasAtrCuota, SecCuota  
                                                    FROM          tCsPlanCuotas WHERE Fecha = @Fecha ) a  
                            GROUP BY Fecha, CodOficina, CodPrestamo, CodUsuario) DiasAcumulados ON tCsCarteraDet.Fecha = DiasAcumulados.Fecha AND   
                      tCsCarteraDet.CodOficina = DiasAcumulados.CodOficina AND   
                      tCsCarteraDet.CodPrestamo = DiasAcumulados.CodPrestamo COLLATE Modern_Spanish_CI_AI AND   
                      tCsCarteraDet.CodUsuario = DiasAcumulados.CodUsuario COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN  
                      tCsCarteraGrupos ON tCsCartera.CodOficina = tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo LEFT OUTER JOIN  
                      tCsPadronClientes ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN  
                      tCaClTecnologia INNER JOIN  
                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON tCsCartera.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN  
                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER join tcsclbis on tCsCartera.BIS=tcsclbis.bis  
WHERE     (tCsCartera.Estado <> 'castigado') 
AND (tCsCartera.Fecha = '20130916') 
--AND (dbo.fduFechaAPeriodo(tCsCartera.FechaVencimiento)   = @Periodo) 
AND (tCsCartera.CodOficina = '2')
 

*/
GO