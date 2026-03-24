SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptSituacionxOficina] @Fecha smalldatetime AS

Declare @tbAuxCartera table
(
	Fecha			smalldatetime,
	CodPrestamo		varchar(25),
	CodUsuario		varchar(25),
	CodOficina		int,
	NomOficina		varchar(30),
	Estado			varchar(50),
	MontoDesembolso		decimal(16,4),
	NroDiasAtraso		smallint,
	OtrosCargos		decimal(16,4),
	SaldoCapital		decimal(16,4),
	SaldoINTE		decimal(16,4),
	SaldoINPE		decimal(16,4),
	SaldoINTEVIG		decimal(16,4),
	SaldoINPEVIG		decimal(16,4),
	SaldoINTESus		decimal(16,4),
	SaldoINPESus		decimal(16,4),
	Tecnologia		varchar(50),
	NumReprog		int,		
	CodPrestamoVigReg	varchar(25),	
	unique clustered (Fecha,CodPrestamo,CodUsuario) 
)

insert into @tbAuxCartera (Fecha,CodPrestamo,CodUsuario,CodOficina,NomOficina,Estado,MontoDesembolso,NroDiasAtraso,OtrosCargos,SaldoCapital,SaldoINTE,SaldoINPE,SaldoINTEVIG,SaldoINPEVIG,SaldoINTESus,SaldoINPESus,Tecnologia,NumReprog,CodPrestamoVigReg)
SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, CAST(cd.CodOficina AS int) AS CodOficina, tClOficinas.NomOficina AS NomOficina, c.Estado, 
                      cd.MontoDesembolso, c.NroDiasAtraso, cd.OtrosCargos, cd.SaldoCapital, cd.SaldoInteres AS SaldoINTE, cd.SaldoMoratorio AS SaldoINPE, 
                      cd.InteresVigente + cd.InteresVencido AS SaldoINTEVIG, cd.MoratorioVigente + cd.MoratorioVencido AS SaldoINPEVIG, 
                      cd.InteresCtaOrden AS SaldoINTESus, cd.MoratorioCtaOrden AS SaldoINPESus, tCaClTecnologia.Veridico AS Tecnologia, ISNULL(c.NumReprog, 0) 
                      AS NumReprog, CASE WHEN tCsRenegociadosVigentes.REGISTRO > cd.Fecha THEN NULL ELSE tCsRenegociadosVigentes.CodPrestamo END AS CodPrestamoVigReg
FROM         tCaClTecnologia INNER JOIN
                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia RIGHT OUTER JOIN
                      tCsCartera c INNER JOIN
                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo LEFT OUTER JOIN
                      tCsRenegociadosVigentes ON c.CodPrestamo = tCsRenegociadosVigentes.CodPrestamo ON 
                      tCaProducto.CodProducto = c.CodProducto LEFT OUTER JOIN
                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina
WHERE     (cd.Fecha = @Fecha) AND (c.cartera in('ACTIVA'))

SELECT     Fecha, Tecnologia, CodOficina, NomOficina, SUM(NroCliente) AS NroCliente, SUM(NroPtmos) AS NroPtmos, SUM(MontoDesembolso) 
                      AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) 
                      AS NroCliente_30Dias, SUM(NroCliente_90Dias) AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, SUM(NroPtmos_0Dias) 
                      AS NroPtmos_0Dias, SUM(NroPtmos_30Dias) AS NroPtmos_30Dias, SUM(NroPtmos_90Dias) AS NroPtmos_90Dias, SUM(NroPtmos_MasDias) 
                      AS NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) 
                      AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias
FROM         (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, NroCliente, NroPtmos, MontoDesembolso, SaldoCapital, NroCliente_0Dias, NroCliente_30Dias, 
                                              NroCliente_90Dias, NroCliente_MasDias, CASE WHEN NroPtmos_0Dias = '' THEN 0 ELSE 1 END AS NroPtmos_0Dias, 
                                              CASE WHEN NroPtmos_30Dias = '' THEN 0 ELSE 1 END AS NroPtmos_30Dias, 
                                              CASE WHEN NroPtmos_90Dias = '' THEN 0 ELSE 1 END AS NroPtmos_90Dias, 
                                              CASE WHEN NroPtmos_MasDias = '' THEN 0 ELSE 1 END AS NroPtmos_MasDias, SaldoCap_0Dias, SaldoCap_30Dias, SaldoCap_90Dias, 
                                              SaldoCap_MasDias
                       FROM          (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, COUNT(DISTINCT CodUsuario) AS NroCliente, COUNT(DISTINCT CodPrestamo) 
                                                                      AS NroPtmos, SUM(ISNULL(MontoDesembolso, 0)) AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, 
                                                                      SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) AS NroCliente_30Dias, SUM(NroCliente_90Dias) 
                                                                      AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, NroPtmos_0Dias, NroPtmos_30Dias, 
                                                                      NroPtmos_90Dias, NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) 
                                                                      AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias
                                               FROM          (SELECT     a.Fecha, a.CodPrestamo, a.CodUsuario, a.CodOficina, a.NomOficina, a.Estado, a.NroDiasAtraso, 
                                                                                              a.SaldoCapital + ISNULL(a.SaldoINTEVIG, 0) + ISNULL(a.SaldoINPEVIG, 0) AS SaldoCapital, a.MontoDesembolso, 
                                                                                              a.Tecnologia, 

							CASE A.NumReprog WHEN 0 THEN (CASE a.NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END) 
                                                                                              ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN (CASE a.NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END) ELSE 0 END) END AS NroCliente_0Dias, 

                                                                                              CASE a.NumReprog WHEN 0 THEN (CASE WHEN a.NroDiasAtraso > 0 AND 
                                                                                              a.NroDiasAtraso <= 30 THEN 1 ELSE 0 END) 
                                                                                              ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) 
                                                                                              THEN (CASE WHEN a.NroDiasAtraso > 0 AND a.NroDiasAtraso <= 30 THEN 1 ELSE 0 END) ELSE 0 END) 
                                                                                              END AS NroCliente_30Dias, 

							CASE a.NumReprog WHEN 0 THEN (CASE WHEN a.NroDiasAtraso > 30 AND 
                                                                                              a.NroDiasAtraso < 90 THEN 1 ELSE 0 END) ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL)
                                                                                               THEN (CASE WHEN a.NroDiasAtraso > 30 AND a.NroDiasAtraso < 90 THEN 1 ELSE 0 END) ELSE 0 END) 
                                                                                              END AS NroCliente_90Dias, 

                                                                                              CASE WHEN a.NroDiasAtraso >= 90 THEN 1 ELSE (
														CASE a.NumReprog WHEN 0 THEN 0 

												ELSE  (  CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN 0 ELSE 1 END )   END
											) 
                                                                                              END AS NroCliente_MasDias, 

                                                                                              CASE a.NumReprog WHEN 0 THEN (CASE a.NroDiasAtraso WHEN 0 THEN a.codprestamo ELSE '' END) 
                                                                                              ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) 
                                                                                              THEN (CASE a.NroDiasAtraso WHEN 0 THEN a.codprestamo ELSE '' END) ELSE '' END) END AS NroPtmos_0Dias, 

                                                                                              CASE a.NumReprog WHEN 0 THEN (CASE WHEN a.NroDiasAtraso > 0 AND 
                                                                                              a.NroDiasAtraso <= 30 THEN a.codprestamo ELSE '' END) 
                                                                                              ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) 
                                                                                              THEN (CASE WHEN a.NroDiasAtraso > 0 AND a.NroDiasAtraso <= 30 THEN a.codprestamo ELSE '' END) ELSE '' END) 
                                                                                              END AS NroPtmos_30Dias,
							
							CASE a.NumReprog WHEN 0 THEN (CASE WHEN a.NroDiasAtraso > 30 AND 
                                                                                              a.NroDiasAtraso < 90 THEN a.codprestamo ELSE '' END) 
                                                                                              ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) 
                                                                                              THEN (CASE WHEN a.NroDiasAtraso > 30 AND a.NroDiasAtraso < 90 THEN a.codprestamo ELSE '' END) ELSE '' END) 
                                                                                              END AS NroPtmos_90Dias, 

                                                                                              CASE WHEN a.NroDiasAtraso >= 90 THEN a.codprestamo 
											ELSE (
												CASE a.NumReprog WHEN 0 THEN '' 
													ELSE  (  CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN '' ELSE a.codprestamo END )   END
												) END AS NroPtmos_MasDias, 

                                                                                              CASE a.NumReprog WHEN 0 THEN (CASE a.NroDiasAtraso WHEN 0 THEN a.saldocapital + isnull(SaldoINTEVIG, 0)  + isnull(a.SaldoINPEVIG, 0)
                                                                                              ELSE 0 END) ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) 
                                                                                              THEN (CASE a.NroDiasAtraso WHEN 0 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END) 
                                                                                              END AS SaldoCap_0Dias, 

							CASE a.NumReprog WHEN 0 THEN (CASE WHEN a.NroDiasAtraso > 0 AND 
                                                                                              a.NroDiasAtraso <= 30 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) ELSE 0 END) 
                                                                                              ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) 
                                                                                              THEN (CASE WHEN a.NroDiasAtraso > 0 AND a.NroDiasAtraso <= 30 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) 
                                                                                              + isnull(a.SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END) END AS SaldoCap_30Dias, 

                                                                                              CASE a.NumReprog WHEN 0 THEN (CASE WHEN a.NroDiasAtraso > 30 AND a.NroDiasAtraso < 90 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) ELSE 0 END) 
			                                                                                                       ELSE (CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN (CASE WHEN a.NroDiasAtraso > 30 AND a.NroDiasAtraso < 90 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END) 
										          END AS SaldoCap_90Dias, 

                                                                                              CASE WHEN a.NroDiasAtraso >= 90 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) 
											       ELSE ( 
													CASE a.NumReprog WHEN 0 THEN 0 
															ELSE (  CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN 0 ELSE a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) END ) END
												) 
											       END AS SaldoCap_MasDias

                                                                       FROM          ( SELECT  Fecha, CodPrestamo ,CodUsuario,	CodOficina, NomOficina, Estado, MontoDesembolso	, NroDiasAtraso, OtrosCargos, SaldoCapital, SaldoINTE, SaldoINPE, SaldoINTEVIG,
SaldoINPEVIG, SaldoINTESus, SaldoINPESus, Tecnologia, NumReprog, CodPrestamoVigReg  FROM  @tbAuxCartera) a ) b
                                               GROUP BY Fecha, Tecnologia, CodOficina, NomOficina, NroPtmos_0Dias, NroPtmos_30Dias, NroPtmos_90Dias, NroPtmos_MasDias) c) 
                      d
GROUP BY Fecha, Tecnologia, CodOficina, NomOficina
/*
SELECT     Fecha, Tecnologia, CodOficina, NomOficina, SUM(NroCliente) AS NroCliente, SUM(NroPtmos) AS NroPtmos, SUM(MontoDesembolso) 
                      AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) 
                      AS NroCliente_30Dias, SUM(NroCliente_90Dias) AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, SUM(NroPtmos_0Dias) 
                      AS NroPtmos_0Dias, SUM(NroPtmos_30Dias) AS NroPtmos_30Dias, SUM(NroPtmos_90Dias) AS NroPtmos_90Dias, SUM(NroPtmos_MasDias) 
                      AS NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) 
                      AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias
FROM         (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, NroCliente, NroPtmos, MontoDesembolso, SaldoCapital, NroCliente_0Dias, NroCliente_30Dias, 
                                              NroCliente_90Dias, NroCliente_MasDias, CASE WHEN NroPtmos_0Dias = '' THEN 0 ELSE 1 END AS NroPtmos_0Dias, 
                                              CASE WHEN NroPtmos_30Dias = '' THEN 0 ELSE 1 END AS NroPtmos_30Dias, 
                                              CASE WHEN NroPtmos_90Dias = '' THEN 0 ELSE 1 END AS NroPtmos_90Dias, 
                                              CASE WHEN NroPtmos_MasDias = '' THEN 0 ELSE 1 END AS NroPtmos_MasDias, SaldoCap_0Dias, SaldoCap_30Dias, SaldoCap_90Dias, 
                                              SaldoCap_MasDias
                       FROM          (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, COUNT(DISTINCT CodUsuario) AS NroCliente, COUNT(DISTINCT CodPrestamo) 
                                                                      AS NroPtmos, SUM(ISNULL(MontoDesembolso, 0)) AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, 
                                                                      SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) AS NroCliente_30Dias, SUM(NroCliente_90Dias) 
                                                                      AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, NroPtmos_0Dias, NroPtmos_30Dias, 
                                                                      NroPtmos_90Dias, NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) 
                                                                      AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias
                                               FROM          (SELECT     Fecha, CodPrestamo, CodUsuario, CodOficina, NomOficina, Estado, NroDiasAtraso, 
                                                                                              SaldoCapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) AS SaldoCapital, MontoDesembolso, Tecnologia, 
                                                                                             
							--CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END) 
                                                                                              --ELSE 0 END AS NroCliente_0Dias, 
							CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END) 
                                                                                              ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END) else 0 end) END AS NroCliente_0Dias, 
							
							CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN 1 ELSE 0 END) 
							ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then  (CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN 1 ELSE 0 END)  else 0 end) END AS NroCliente_30Dias, 

                                                                                              CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso < 90 THEN 1 ELSE 0 END) 
                                                                                              ELSE(case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then  (CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso < 90 THEN 1 ELSE 0 END)  else 0 end) END AS NroCliente_90Dias, 
 
							CASE WHEN NroDiasAtraso >= 90 THEN 1 ELSE (CASE NumReprog WHEN 0 THEN 0 ELSE 1 END) 
                                                                                              END AS NroCliente_MasDias,
 
                                                                                              --CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN codprestamo ELSE '' END) 
                                                                                              --ELSE '' END NroPtmos_0Dias, 
                                                                                              CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN codprestamo ELSE '' END) 
                                                                                              ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE NroDiasAtraso WHEN 0 THEN codprestamo ELSE '' END) else '' end)  END NroPtmos_0Dias, 

							CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN codprestamo ELSE '' END) 
							ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN codprestamo ELSE '' END)  else '' end)  END NroPtmos_30Dias, 

                                                                                              CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso < 90 THEN codprestamo ELSE '' END) 
							ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso < 90 THEN codprestamo ELSE '' END) else '' end)  END NroPtmos_90Dias, 

                                                                                              CASE WHEN NroDiasAtraso >= 90 THEN codprestamo ELSE (CASE NumReprog WHEN 0 THEN '' ELSE codprestamo END)
                                                                                               END NroPtmos_MasDias, 

                                                                                              --CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) ELSE 0 END) 
							--ELSE 0 END AS SaldoCap_0Dias, 
                                                                                              CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) ELSE 0 END) 
							ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE NroDiasAtraso WHEN 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) ELSE 0 END)  else 0 end) END AS SaldoCap_0Dias, 
							 
							 CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) 
                                                                                              ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END)   else 0 end) END AS SaldoCap_30Dias, 

							 CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso < 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) 
                                                                                              ELSE (case when codprestamo in (select codprestamo from tCsRenegociadosVigentes) then (CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso < 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END)   else 0 end)  END AS SaldoCap_90Dias, 

							 CASE WHEN NroDiasAtraso >= 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) 
                                                                                              + isnull(SaldoINPEVIG, 0) ELSE (CASE NumReprog WHEN 0 THEN 0 ELSE saldocapital + isnull(SaldoINTEVIG, 0) 
                                                                                              + isnull(SaldoINPEVIG, 0) END) END AS SaldoCap_MasDias

                                                                       FROM          (SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, 
									CAST(cd.CodOficina AS int) AS CodOficina, tClOficinas.NomOficina As NomOficina, 
									--C.CodAsesor AS CodOficina, tCsPadronClientes.NombreCompleto As NomOficina, 
									c.CodSolicitud, c.CodProducto, c.CodAsesor, 
                                                                                                                      CASE Veridico WHEN 'SOLIDARIO' THEN c.CodUsuario ELSE '' END AS Coordinador, c.CodTipoCredito, 
                                                                                                                      c.CodDestino, c.Estado, c.TipoReprog, c.NroCuotas, c.NroCuotasPagadas, c.NroCuotasPorPagar, 
                                                                                                                      c.FechaDesembolso, c.FechaVencimiento, cd.MontoDesembolso, c.NroDiasAtraso, cd.SaldoCapital, 
                                                                                                                      cd.CapitalVencido, cd.SaldoInteres AS SaldoINTE, cd.SaldoMoratorio AS SaldoINPE, cd.OtrosCargos, 
                                                                                                                      cd.UltimoMovimiento, cd.SaldoEnMora, cd.TipoCalificacion, 
                                                                                                                      cd.InteresVigente + cd.InteresVencido AS SaldoINTEVIG, 
                                                                                                                      cd.MoratorioVigente + cd.MoratorioVencido AS SaldoINPEVIG, cd.InteresCtaOrden AS SaldoINTESus, 
                                                                                                                      cd.MoratorioCtaOrden AS SaldoINPESus, c.Calificacion, c.ProvisionCapital, c.ProvisionInteres, 
                                                                                                                      c.GarantiaLiquidaMonetizada, c.GarantiaPreferidaMonetizada, c.GarantiaMuyRapidaRealizacion, 
                                                                                                                      c.TotalGarantia, c.TasaIntCorriente, c.TasaINVE, c.TasaINPE, cli.Cliente, cli.CodDocIden, cli.DI, 
                                                                                                                      tCaClTecnologia.Veridico AS Tecnologia, ISNULL(c.NumReprog, 0) AS NumReprog
                                                                                               FROM          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Cliente, CodDocIden, DI, 
                                                                                                                                              CodUbiGeoDirFamPri, DireccionDirFamPri, TelefonoDirFamPri, LabCodActividad
                                                                                                                       FROM          tCspadronClientes) cli RIGHT OUTER JOIN
                                                                                                                      tCsCartera c INNER JOIN
                                                                                                                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo LEFT OUTER JOIN
                                                                                                                      tCsPadronClientes ON c.CodAsesor = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                                                                                                                      tCaClTecnologia INNER JOIN
                                                                                                                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON 
                                                                                                                      c.CodProducto = tCaProducto.CodProducto ON cli.CodUsuario = cd.CodUsuario LEFT OUTER JOIN
                                                                                                                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina
                                                                                               WHERE      (cd.Fecha = @Fecha) AND c.estado not in ( 'CASTIGADO','ADMINISTRATIVO')
									--And C.CodOficina = 14
									) a) b
                                               GROUP BY Fecha, Tecnologia, CodOficina, NomOficina, NroPtmos_0Dias, NroPtmos_30Dias, NroPtmos_90Dias, NroPtmos_MasDias) c) 
                      d
GROUP BY Fecha, Tecnologia, CodOficina, NomOficina
ORDER BY Fecha, Tecnologia*/
GO