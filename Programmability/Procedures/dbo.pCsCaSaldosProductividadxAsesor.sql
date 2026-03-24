SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaSaldosProductividadxAsesor]   AS


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
	Asesor	varchar(200),
	SecuenciaCliente int,
	unique clustered (Fecha,CodPrestamo,CodUsuario) 
)

insert into @tbAuxCartera (Fecha,CodPrestamo,CodUsuario,CodOficina,NomOficina,Estado,MontoDesembolso,NroDiasAtraso,OtrosCargos,SaldoCapital,SaldoINTE,SaldoINPE,SaldoINTEVIG,SaldoINPEVIG,SaldoINTESus,SaldoINPESus,Tecnologia,NumReprog,CodPrestamoVigReg,Asesor,SecuenciaCliente)
SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, CAST(cd.CodOficina AS int) AS CodOficina, tClOficinas.NomOficina AS NomOficina, c.Estado, 
                      cd.MontoDesembolso, c.NroDiasAtraso, cd.OtrosCargos, cd.SaldoCapital, cd.SaldoInteres AS SaldoINTE, cd.SaldoMoratorio AS SaldoINPE, 
                      cd.InteresVigente + cd.InteresVencido AS SaldoINTEVIG, cd.MoratorioVigente + cd.MoratorioVencido AS SaldoINPEVIG, 
                      cd.InteresCtaOrden AS SaldoINTESus, cd.MoratorioCtaOrden AS SaldoINPESus, tCaClTecnologia.Veridico AS Tecnologia, ISNULL(c.NumReprog, 0) 
                      AS NumReprog, CASE WHEN tCsRenegociadosVigentes.REGISTRO > cd.Fecha THEN NULL ELSE tCsRenegociadosVigentes.CodPrestamo  END AS CodPrestamoVigReg, Asesores.NombreCompleto Asesor, cd.SecuenciaCliente
FROM         tCsRenegociadosVigentes RIGHT OUTER JOIN
                      tCsCartera c INNER JOIN
                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo LEFT OUTER JOIN
                      tCsPadronClientes Asesores ON c.CodAsesor = Asesores.CodUsuario ON tCsRenegociadosVigentes.CodPrestamo = c.CodPrestamo LEFT OUTER JOIN
                      tCaClTecnologia INNER JOIN
                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON c.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN
                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina
WHERE      (cd.Fecha IN (SELECT     UltimoDia
FROM         tClPeriodo
WHERE     (Periodo >=
                          (SELECT     dbo.fduFechaATexto(DATEADD([month], - 3, MAX(Periodo) + '01'), 'AAAAMM') AS Periodo
                            FROM          tClPeriodo)))) AND (c.cartera in('ACTIVA'))

--- consulta matriz
SELECT     Fecha, Tecnologia, CodOficina, NomOficina, ASESOR, SUM(NroCliente) AS NroCliente, SUM(NroPtmos) AS NroPtmos, SUM(MontoDesembolso) 
                      AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCartera, SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) 
                      AS NroCliente_30Dias, SUM(NroCliente_90Dias) AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, SUM(NroPtmos_0Dias) 
                      AS NroPtmos_0Dias, SUM(NroPtmos_30Dias) AS NroPtmos_30Dias, SUM(NroPtmos_90Dias) AS NroPtmos_90Dias, SUM(NroPtmos_MasDias) 
                      AS NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) 
                      AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias, SUM(NroCliente_Nuevos) AS NroCliente_Nuevos, SUM(NroCliente_Repres) 
                      AS NroCliente_Repres, SUM(Desem_Nuevos) AS Desem_Nuevos, SUM(Desem_Repres) AS Desem_Repres, SUM(Capital) AS Capital, SUM(SaldoINTE) 
                      AS SaldoINTE, SUM(SaldoINPE) AS SaldoINpE, SUM(SaldoReprogMenor30) SaldoReprogMenor30, sum(NroClientesReprogMenor30) NroClientesReprogMenor30
								,SUM(SaldoReprogMayor30) SaldoReprogMayor30, sum(NroClientesReprogMayor30) NroClientesReprogMayor30
FROM         (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, NroCliente, NroPtmos, MontoDesembolso, SaldoCapital, NroCliente_0Dias, NroCliente_30Dias, 
                                              NroCliente_90Dias, NroCliente_MasDias, CASE WHEN NroPtmos_0Dias = '' THEN 0 ELSE 1 END AS NroPtmos_0Dias, 
                                              CASE WHEN NroPtmos_30Dias = '' THEN 0 ELSE 1 END AS NroPtmos_30Dias, 
                                              CASE WHEN NroPtmos_90Dias = '' THEN 0 ELSE 1 END AS NroPtmos_90Dias, 
                                              CASE WHEN NroPtmos_MasDias = '' THEN 0 ELSE 1 END AS NroPtmos_MasDias, SaldoCap_0Dias, SaldoCap_30Dias, SaldoCap_90Dias, 
                                              SaldoCap_MasDias, ASESOR, NroCliente_Nuevos, NroCliente_Repres, Desem_Nuevos, Desem_Repres, Capital, SaldoINTE, 
                                              SaldoINPE, SaldoReprogMenor30, NroClientesReprogMenor30,SaldoReprogMayor30, NroClientesReprogMayor30
                       FROM          (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, COUNT(DISTINCT CodUsuario) AS NroCliente, COUNT(DISTINCT CodPrestamo) 
                                                                      AS NroPtmos, SUM(ISNULL(MontoDesembolso, 0)) AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, 
                                                                      SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) AS NroCliente_30Dias, SUM(NroCliente_90Dias) 
                                                                      AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, NroPtmos_0Dias, NroPtmos_30Dias, 
                                                                      NroPtmos_90Dias, NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) 
                                                                      AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias, asesor, 
                                                                      SUM(NroCliente_Nuevos) NroCliente_Nuevos, SUM(NroCliente_Repres) NroCliente_Repres, SUM(Desem_Nuevos) 
                                                                      Desem_Nuevos, SUM(Desem_Repres) Desem_Repres, SUM(Capital) Capital, SUM(SaldoINTEVIG) SaldoINTE, 
                                                                      SUM(SaldoINPEVIG) SaldoINpE, SUM(SaldoReprogMenor30) SaldoReprogMenor30, sum(NroClientesReprogMenor30) NroClientesReprogMenor30
								,SUM(SaldoReprogMayor30) SaldoReprogMayor30, sum(NroClientesReprogMayor30) NroClientesReprogMayor30

                                               FROM          (SELECT     Fecha, CodPrestamo, CodUsuario, CodOficina, NomOficina, Estado, NroDiasAtraso, SaldoCapital Capital, 
                                                              SaldoINTEVIG, SaldoINPEVIG, SaldoCapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) AS SaldoCapital, 
                                                              MontoDesembolso, Tecnologia, 
                                                              
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
                                                              CASE WHEN a.NroDiasAtraso >= 90 THEN 1 ELSE (CASE a.NumReprog WHEN 0 THEN 0 
								ELSE  (  CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN 0 ELSE 1 END )   END) 
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
                                                              CASE WHEN a.NroDiasAtraso >= 90 THEN a.codprestamo ELSE (CASE a.NumReprog WHEN 0 THEN '' 
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

                                                          CASE WHEN a.NroDiasAtraso >= 90 THEN a.saldocapital + isnull(a.SaldoINTEVIG, 0) + isnull(a.SaldoINPEVIG, 0) ELSE ( 
							  CASE a.NumReprog WHEN 0 THEN 0 ELSE (  CASE WHEN NOT (CodPrestamoVigReg IS NULL) THEN 0 ELSE a.saldocapital + isnull(a.SaldoINTEVIG, 0) 
							  + isnull(a.SaldoINPEVIG, 0) END ) END	) END AS SaldoCap_MasDias,

								asesor, 
                                                              CASE WHEN SecuenciaCliente = 1 THEN 1 ELSE 0 END AS NroCliente_Nuevos, 
                                                              CASE WHEN SecuenciaCliente > 1 THEN 1 ELSE 0 END AS NroCliente_Repres, 
                                                              CASE WHEN SecuenciaCliente = 1 THEN MontoDesembolso ELSE 0 END AS Desem_Nuevos, 
                                                              CASE WHEN SecuenciaCliente > 1 THEN MontoDesembolso ELSE 0 END AS Desem_Repres,

							CASE WHEN NroDiasAtraso = 0 THEN (CASE WHEN NumReprog > 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END SaldoReprogMenor30,
							CASE WHEN NroDiasAtraso = 0 THEN (CASE WHEN NumReprog > 0 THEN 1 ELSE 0 END) ELSE 0 END NroClientesReprogMenor30,
							CASE WHEN NroDiasAtraso > 0 THEN (CASE WHEN NumReprog > 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END  SaldoReprogMayor30,
							CASE WHEN NroDiasAtraso > 0 THEN (CASE WHEN NumReprog > 0 THEN 1 ELSE 0 END) ELSE 0 END  NroClientesReprogMayor30

                                                                       FROM          (
SELECT  Fecha, CodPrestamo ,CodUsuario,	CodOficina, NomOficina, Estado, MontoDesembolso	, NroDiasAtraso, OtrosCargos, SaldoCapital, SaldoINTE, SaldoINPE, SaldoINTEVIG,
SaldoINPEVIG, SaldoINTESus, SaldoINPESus, Tecnologia, NumReprog, CodPrestamoVigReg,Asesor,SecuenciaCliente  FROM  @tbAuxCartera
) a) b
                                               GROUP BY Fecha, Tecnologia, CodOficina, NomOficina, NroPtmos_0Dias, NroPtmos_30Dias, NroPtmos_90Dias, NroPtmos_MasDias, 
                                                                      ASESOR) c) d
GROUP BY Fecha, Tecnologia, CodOficina, NomOficina, ASESOR
ORDER BY Fecha, Tecnologia

/*
SELECT     Fecha, Tecnologia, CodOficina, NomOficina, ASESOR, SUM(NroCliente) AS NroCliente, SUM(NroPtmos) AS NroPtmos, SUM(MontoDesembolso) 
                      AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCartera, SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) 
                      AS NroCliente_30Dias, SUM(NroCliente_90Dias) AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, SUM(NroPtmos_0Dias) 
                      AS NroPtmos_0Dias, SUM(NroPtmos_30Dias) AS NroPtmos_30Dias, SUM(NroPtmos_90Dias) AS NroPtmos_90Dias, SUM(NroPtmos_MasDias) 
                      AS NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) 
                      AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias, SUM(NroCliente_Nuevos) AS NroCliente_Nuevos, SUM(NroCliente_Repres) 
                      AS NroCliente_Repres, SUM(Desem_Nuevos) AS Desem_Nuevos, SUM(Desem_Repres) AS Desem_Repres, SUM(Capital) AS Capital, SUM(SaldoINTE) 
                      AS SaldoINTE, SUM(SaldoINPE) AS SaldoINpE, SUM(SaldoReprogMenor30) SaldoReprogMenor30, sum(NroClientesReprogMenor30) NroClientesReprogMenor30
								,SUM(SaldoReprogMayor30) SaldoReprogMayor30, sum(NroClientesReprogMayor30) NroClientesReprogMayor30
FROM         (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, NroCliente, NroPtmos, MontoDesembolso, SaldoCapital, NroCliente_0Dias, NroCliente_30Dias, 
                                              NroCliente_90Dias, NroCliente_MasDias, CASE WHEN NroPtmos_0Dias = '' THEN 0 ELSE 1 END AS NroPtmos_0Dias, 
                                              CASE WHEN NroPtmos_30Dias = '' THEN 0 ELSE 1 END AS NroPtmos_30Dias, 
                                              CASE WHEN NroPtmos_90Dias = '' THEN 0 ELSE 1 END AS NroPtmos_90Dias, 
                                              CASE WHEN NroPtmos_MasDias = '' THEN 0 ELSE 1 END AS NroPtmos_MasDias, SaldoCap_0Dias, SaldoCap_30Dias, SaldoCap_90Dias, 
                                              SaldoCap_MasDias, ASESOR, NroCliente_Nuevos, NroCliente_Repres, Desem_Nuevos, Desem_Repres, Capital, SaldoINTE, 
                                              SaldoINPE, SaldoReprogMenor30, NroClientesReprogMenor30,SaldoReprogMayor30, NroClientesReprogMayor30
                       FROM          (SELECT     Fecha, Tecnologia, CodOficina, NomOficina, COUNT(DISTINCT CodUsuario) AS NroCliente, COUNT(DISTINCT CodPrestamo) 
                                                                      AS NroPtmos, SUM(ISNULL(MontoDesembolso, 0)) AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, 
                                                                      SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) AS NroCliente_30Dias, SUM(NroCliente_90Dias) 
                                                                      AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, NroPtmos_0Dias, NroPtmos_30Dias, 
                                                                      NroPtmos_90Dias, NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) 
                                                                      AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias, asesor, 
                                                                      SUM(NroCliente_Nuevos) NroCliente_Nuevos, SUM(NroCliente_Repres) NroCliente_Repres, SUM(Desem_Nuevos) 
                                                                      Desem_Nuevos, SUM(Desem_Repres) Desem_Repres, SUM(Capital) Capital, SUM(SaldoINTEVIG) SaldoINTE, 
                                                                      SUM(SaldoINPEVIG) SaldoINpE, SUM(SaldoReprogMenor30) SaldoReprogMenor30, sum(NroClientesReprogMenor30) NroClientesReprogMenor30
								,SUM(SaldoReprogMayor30) SaldoReprogMayor30, sum(NroClientesReprogMayor30) NroClientesReprogMayor30

                                               FROM          (SELECT     Fecha, CodPrestamo, CodUsuario, CodOficina, NomOficina, Estado, NroDiasAtraso, SaldoCapital Capital, 
                                                                                              SaldoINTEVIG, SaldoINPEVIG, SaldoCapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) AS SaldoCapital, 
                                                                                              MontoDesembolso, Tecnologia, 
                                                                                              CASE NumReprog WHEN 0 THEN CASE NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END ELSE 0 END AS NroCliente_0Dias,
                                                                                               CASE NumReprog WHEN 0 THEN CASE WHEN NroDiasAtraso > 0 AND 
                                                                                              NroDiasAtraso <= 30 THEN 1 ELSE 0 END ELSE 0 END AS NroCliente_30Dias, 
                                                                                              CASE NumReprog WHEN 0 THEN CASE WHEN NroDiasAtraso > 30 AND 
                                                                                              NroDiasAtraso < 90 THEN 1 ELSE 0 END ELSE 0 END AS NroCliente_90Dias, 
                                                                                              CASE WHEN NroDiasAtraso >= 90 THEN 1 ELSE (CASE NumReprog WHEN 0 THEN 0 ELSE 1 END) 
                                                                                              END AS NroCliente_MasDias, 
                                                                                              CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN codprestamo ELSE '' END) 
                                                                                              ELSE '' END NroPtmos_0Dias, CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 0 AND 
                                                                                              NroDiasAtraso <= 30 THEN codprestamo ELSE '' END) ELSE '' END NroPtmos_30Dias, 
                                                                                              CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 30 AND 
                                                                                              NroDiasAtraso < 90 THEN codprestamo ELSE '' END) ELSE '' END NroPtmos_90Dias, 
                                                                                              CASE WHEN NroDiasAtraso >= 90 THEN codprestamo ELSE (CASE NumReprog WHEN 0 THEN '' ELSE codprestamo END)
                                                                                               END NroPtmos_MasDias, 
                                                                                              CASE NumReprog WHEN 0 THEN (CASE NroDiasAtraso WHEN 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) 
                                                                                              ELSE 0 END) ELSE 0 END AS SaldoCap_0Dias, CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 0 AND
                                                                                               NroDiasAtraso <= 30 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) 
                                                                                              ELSE 0 END AS SaldoCap_30Dias, CASE NumReprog WHEN 0 THEN (CASE WHEN NroDiasAtraso > 30 AND 
                                                                                              NroDiasAtraso < 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) 
                                                                                              ELSE 0 END AS SaldoCap_90Dias, CASE WHEN NroDiasAtraso >= 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) 
                                                                                              + isnull(SaldoINPEVIG, 0) ELSE (CASE NumReprog WHEN 0 THEN 0 ELSE saldocapital + isnull(SaldoINTEVIG, 0) 
                                                                                              + isnull(SaldoINPEVIG, 0) END) END AS SaldoCap_MasDias, asesor, 
                                                                                              CASE WHEN SecuenciaCliente = 1 THEN 1 ELSE 0 END AS NroCliente_Nuevos, 
                                                                                              CASE WHEN SecuenciaCliente > 1 THEN 1 ELSE 0 END AS NroCliente_Repres, 
                                                                                              CASE WHEN SecuenciaCliente = 1 THEN MontoDesembolso ELSE 0 END AS Desem_Nuevos, 
                                                                                              CASE WHEN SecuenciaCliente > 1 THEN MontoDesembolso ELSE 0 END AS Desem_Repres,

							CASE WHEN NroDiasAtraso = 0 THEN (CASE WHEN NumReprog > 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END SaldoReprogMenor30,
							CASE WHEN NroDiasAtraso = 0 THEN (CASE WHEN NumReprog > 0 THEN 1 ELSE 0 END) ELSE 0 END NroClientesReprogMenor30,
							CASE WHEN NroDiasAtraso > 0 THEN (CASE WHEN NumReprog > 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) ELSE 0 END) ELSE 0 END  SaldoReprogMayor30,
							CASE WHEN NroDiasAtraso > 0 THEN (CASE WHEN NumReprog > 0 THEN 1 ELSE 0 END) ELSE 0 END  NroClientesReprogMayor30

                                                                       FROM          (SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, CAST(cd.CodOficina AS int) AS CodOficina, 
                                                                                                                      tClOficinas.NomOficina, c.CodSolicitud, c.CodProducto, c.CodAsesor, 
                                                                                                                      CASE c.codproducto WHEN '116' THEN c.CodUsuario ELSE '' END AS Coordinador, c.CodTipoCredito, 
                                                                                                                      c.CodDestino, c.Estado, c.TipoReprog, c.NroCuotas, c.NroCuotasPagadas, c.NroCuotasPorPagar, 
                                                                                                                      c.FechaDesembolso, c.FechaVencimiento, cd.MontoDesembolso, c.NroDiasAtraso, cd.SaldoCapital, 
                                                                                                                      cd.CapitalVencido, cd.SaldoInteres AS SaldoINTE, cd.SaldoMoratorio AS SaldoINPE, cd.OtrosCargos, 
                                                                                                                      cd.UltimoMovimiento, cd.SaldoEnMora, cd.TipoCalificacion, 
                                                                                                                      cd.InteresVigente + cd.InteresVencido AS SaldoINTEVIG, 
                                                                                                                      cd.MoratorioVigente + cd.MoratorioVencido AS SaldoINPEVIG, cd.InteresCtaOrden AS SaldoINTESus, 
                                                                                                                      cd.MoratorioCtaOrden AS SaldoINPESus, c.Calificacion, c.ProvisionCapital, c.ProvisionInteres, 
                                                                                                                      c.GarantiaLiquidaMonetizada, c.GarantiaPreferidaMonetizada, c.GarantiaMuyRapidaRealizacion, 
                                                                                                                      c.TotalGarantia, c.TasaIntCorriente, c.TasaINVE, c.TasaINPE, cli.Cliente, cli.CodDocIden, cli.DI, 
                                                                                                                      CASE c.codproducto WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS Tecnologia, 
                                                                                                                      ISNULL(c.NumReprog, 0) AS NumReprog, 
                                                                                                                      tCsPadronClientes.Paterno + ' ' + tCsPadronClientes.Materno + ', ' + tCsPadronClientes.Nombres AS Asesor,
                                                                                                                       tCsPadronCarteraDet.SecuenciaCliente
                                                                                               FROM          tCsCartera c INNER JOIN
                                                                                                                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo INNER JOIN
                                                                                                                      tCsPadronCarteraDet ON cd.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                                                                                                                      cd.CodUsuario = tCsPadronCarteraDet.CodUsuario LEFT OUTER JOIN
                                                                                                                      tCsPadronClientes ON c.CodAsesor = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                                                                                                                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Cliente, CodDocIden, DI, 
                                                                                                                                                   CodUbiGeoDirFamPri, DireccionDirFamPri, TelefonoDirFamPri, LabCodActividad
                                                                                                                            FROM          tCspadronClientes) cli ON cd.CodUsuario = cli.CodUsuario LEFT OUTER JOIN
                                                                                                                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina
                                                                                               WHERE  cd.Fecha in ('20071031','20071130','20071231', '20080131','20080229','20080331','20080430','20080531','20080630','20080731','20080831','20080930','20081031')  and  c.CARTERA = 'ACTIVA') a) b
                                               GROUP BY Fecha, Tecnologia, CodOficina, NomOficina, NroPtmos_0Dias, NroPtmos_30Dias, NroPtmos_90Dias, NroPtmos_MasDias, 
                                                                      ASESOR) c) d
GROUP BY Fecha, Tecnologia, CodOficina, NomOficina, ASESOR
ORDER BY Fecha, Tecnologia
GO
*/
GO