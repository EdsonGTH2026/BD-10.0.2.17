SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE View [dbo].[vCsCaGarantias]
As
SELECT     Fecha, Formalizada, Cartera, CodPrestamo, SUM(NroGarantias) AS NroGarantias, CASE WHEN MIN(MDG) = MAX(MDG) THEN MIN(MDG) ELSE Replace(MIN(MDG) 
                      + '<>' + MAX(MDG), '  ', ' ') END AS MDG, SUM(GarantiaLiquida) AS GarantiaLiquida, SUM(GarantiaPrendaria) AS GarantiaPrendaria, SUM(GarantiaHipotecaria) 
                      AS GarantiaHipotecaria, SUM(GarantiaOtras) AS GarantiaOtras
FROM         (SELECT     Datos.Fecha, Datos.CodPrestamo, SUM(Datos.NroGarantias) AS NroGarantias, 
              CASE WHEN Datos.MiDG = Datos.MaDG THEN Datos.MiDG ELSE Replace(Datos.MiDG + '<>' + Datos.MaDG, '  ', ' ') END AS MDG, 
              SUM(Datos.GarantiaLiquida) AS GarantiaLiquida, SUM(Datos.GarantiaPrendaria) AS GarantiaPrendaria, SUM(Datos.GarantiaHipotecaria) 
              AS GarantiaHipotecaria, SUM(Datos.GarantiaOtras) AS GarantiaOtras, Datos.Formalizada, ISNULL(Datos.Cartera, tCsCartera.Cartera) AS Cartera
              FROM (SELECT tCsDiaGarantias.Fecha, ISNULL(tCsCartera_2.CodPrestamo, tCsDiaGarantias.Codigo) AS CodPrestamo, COUNT(*) AS NroGarantias, 
                      MIN(tCsDiaGarantias.DescGarantia) AS MiDG, MAX(tCsDiaGarantias.DescGarantia) AS MaDG, 
                      CASE WHEN tCsDiaGarantias.TipoGarantia IN ( '-A-', 'GADPF', 'GARAH') THEN SUM(tCsDiaGarantias.Garantia) ELSE 0 END AS GarantiaLiquida, 
                      CASE WHEN tCsDiaGarantias.TipoGarantia IN ('1', 'DOCIN', 'ME1', 'P06', 'PC2', 'PD9', 'VH1', 'VH2') THEN SUM(tCsDiaGarantias.Garantia) 
                      ELSE 0 END AS GarantiaPrendaria, 0 AS GarantiaHipotecaria, CASE WHEN tCsDiaGarantias.TipoGarantia NOT IN ('1', 'DOCIN', 'ME1', 'P06', 
                      'PC2', 'PD9', 'VH1', 'VH2', '-A-', 'GADPF', 'GARAH') THEN SUM(tCsDiaGarantias.Garantia) ELSE 0 END AS GarantiaOtras, 
                      tCsDiaGarantias.Formalizada, tCsCartera_2.Cartera
                      FROM tCsDiaGarantias with(nolock) LEFT OUTER JOIN
                      tCsCartera AS tCsCartera_2 with(nolock) ON tCsDiaGarantias.Fecha = tCsCartera_2.Fecha AND tCsDiaGarantias.Codigo = tCsCartera_2.CodSolicitud AND 
                      tCsDiaGarantias.CodOficina = tCsCartera_2.CodOficina
                                               --WHERE      (tCsDiaGarantias.Fecha = '20110930')
                      GROUP BY tCsDiaGarantias.Fecha, ISNULL(tCsCartera_2.CodPrestamo, tCsDiaGarantias.Codigo), tCsDiaGarantias.TipoGarantia, 
                                                                      tCsDiaGarantias.Formalizada, tCsCartera_2.Cartera) AS Datos INNER JOIN
                                              tCsCartera ON Datos.Fecha = tCsCartera.Fecha AND Datos.CodPrestamo = tCsCartera.CodPrestamo
                       GROUP BY Datos.Fecha, Datos.CodPrestamo, Datos.MiDG, Datos.MaDG, Datos.Formalizada, ISNULL(Datos.Cartera, tCsCartera.Cartera)) AS Datos
GROUP BY Fecha, CodPrestamo, Formalizada, Cartera



GO