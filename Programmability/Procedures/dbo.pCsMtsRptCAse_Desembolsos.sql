SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsMtsRptCAse_Desembolsos] @Fecha smalldatetime, @FechaIni smalldatetime AS

--DECLARE @Fecha smalldatetime
--SET @Fecha = '20080127'

DECLARE @Periodo char(6), @Oficina varchar(100), @NroClientes int, @Montos decimal(16,4), @NroReprestamos int, @DesemRepre decimal(16, 4)

create table #tb(periodo char(6),fecha smalldatetime, Oficina varchar(100) ,descripcion varchar(100), monto decimal(16,4), agrupa int)

--Insertar los datos del consolidado
DECLARE sql_cur CURSOR FOR 
--SQL
SELECT     Periodo, replicate('0',2-datalength(CAST(CodOficina AS VARCHAR(2)))) + CAST(CodOficina AS VARCHAR(2)) + ' ' + NomOficina Oficina, NroCliente, MontoDesembolso, Represtamos, DesembReprestamos
FROM         (SELECT     CAST(YEAR(Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(Fecha) AS varchar(2)))) + CAST(MONTH(Fecha) AS varchar(2)) 
                                              AS Periodo, CodOficina, NomOficina, SUM(NroCliente) AS NroCliente, SUM(NroPtmos) AS NroPtmos, SUM(MontoDesembolso) 
                                              AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) 
                                              AS NroCliente_30Dias, SUM(NroCliente_90Dias) AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, 
                                              SUM(NroPtmos_0Dias) AS NroPtmos_0Dias, SUM(NroPtmos_30Dias) AS NroPtmos_30Dias, SUM(NroPtmos_90Dias) AS NroPtmos_90Dias, 
                                              SUM(NroPtmos_MasDias) AS NroPtmos_MasDias, SUM(SaldoCap_0Dias) AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) 
                                              AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) AS SaldoCap_90Dias, SUM(SaldoCap_MasDias) AS SaldoCap_MasDias, sum(Represtamos) Represtamos, sum(DesembReprestamos) DesembReprestamos
                       FROM          (SELECT     Fecha, Tecnologia2, CodOficina, NomOficina, NroCliente, NroPtmos, MontoDesembolso, SaldoCapital, NroCliente_0Dias, 
                                                                      NroCliente_30Dias, NroCliente_90Dias, NroCliente_MasDias, 
                                                                      CASE WHEN NroPtmos_0Dias = '' THEN 0 ELSE 1 END AS NroPtmos_0Dias, 
                                                                      CASE WHEN NroPtmos_30Dias = '' THEN 0 ELSE 1 END AS NroPtmos_30Dias, 
                                                                      CASE WHEN NroPtmos_90Dias = '' THEN 0 ELSE 1 END AS NroPtmos_90Dias, 
                                                                      CASE WHEN NroPtmos_MasDias = '' THEN 0 ELSE 1 END AS NroPtmos_MasDias, SaldoCap_0Dias, SaldoCap_30Dias, 
                                                                      SaldoCap_90Dias, SaldoCap_MasDias, Represtamos, DesembReprestamos
                                               FROM          (SELECT     Fecha, Tecnologia2, CodOficina, NomOficina, COUNT(CodUsuario) AS NroCliente, COUNT(DISTINCT CodPrestamo) 
                                                                                              AS NroPtmos, sum(ISNULL(MontoDesembolso, 0)) AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, 
                                                                                              SUM(NroCliente_0Dias) AS NroCliente_0Dias, SUM(NroCliente_30Dias) AS NroCliente_30Dias, 
                                                                                              SUM(NroCliente_90Dias) AS NroCliente_90Dias, SUM(NroCliente_MasDias) AS NroCliente_MasDias, 
                                                                                              NroPtmos_0Dias, NroPtmos_30Dias, NroPtmos_90Dias, NroPtmos_MasDias, SUM(SaldoCap_0Dias) 
                                                                                              AS SaldoCap_0Dias, SUM(SaldoCap_30Dias) AS SaldoCap_30Dias, SUM(SaldoCap_90Dias) AS SaldoCap_90Dias, 
                                                                                              SUM(SaldoCap_MasDias) AS SaldoCap_MasDias, sum(Represtamos) Represtamos, sum(DesembReprestamos) DesembReprestamos
                                                                       FROM          (SELECT     Fecha, CodPrestamo, CodUsuario, CodOficina, NomOficina, Estado, NroDiasAtraso, 
                                                                                                                      SaldoCapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) AS SaldoCapital, MontoDesembolso, 
                                                                                                                      Tecnologia2, CASE NroDiasAtraso WHEN 0 THEN 1 ELSE 0 END AS NroCliente_0Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 0 AND NroDiasAtraso <= 30 THEN 1 ELSE 0 END AS NroCliente_30Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 30 AND NroDiasAtraso <= 90 THEN 1 ELSE 0 END AS NroCliente_90Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 90 THEN 1 ELSE 0 END AS NroCliente_MasDias, 
                                                                                                                      CASE NroDiasAtraso WHEN 0 THEN codprestamo ELSE '' END NroPtmos_0Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 0 AND 
                                                                                                                      NroDiasAtraso <= 30 THEN codprestamo ELSE '' END NroPtmos_30Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 30 AND 
                                                                                                                      NroDiasAtraso <= 90 THEN codprestamo ELSE '' END NroPtmos_90Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 90 THEN codprestamo ELSE '' END NroPtmos_MasDias, 
                                                                                                                      CASE NroDiasAtraso WHEN 0 THEN saldocapital + isnull(SaldoINTEVIG, 0) 
                                                                                                                      ELSE 0 END AS SaldoCap_0Dias, CASE WHEN NroDiasAtraso > 0 AND 
                                                                                                                      NroDiasAtraso <= 30 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) 
                                                                                                                      ELSE 0 END AS SaldoCap_30Dias, CASE WHEN NroDiasAtraso > 30 AND 
                                                                                                                      NroDiasAtraso <= 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) 
                                                                                                                      ELSE 0 END AS SaldoCap_90Dias, 
                                                                                                                      CASE WHEN NroDiasAtraso > 90 THEN saldocapital + isnull(SaldoINTEVIG, 0) + isnull(SaldoINPEVIG, 0) 
                                                                                                                      ELSE 0 END AS SaldoCap_MasDias, Represtamos, DesembReprestamos
                                                                                               FROM          (SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, CAST(cd.CodOficina AS int) AS CodOficina, tClOficinas.NomOficina, c.CodSolicitud, c.CodProducto, 
								                      c.CodAsesor, CASE  c.codproducto WHEN '116' THEN c.CodUsuario ELSE '' END AS Coordinador, c.CodTipoCredito, c.CodDestino, c.Estado, 
								                      c.TipoReprog, c.NroCuotas, c.NroCuotasPagadas, c.NroCuotasPorPagar, c.FechaDesembolso, c.FechaVencimiento, cd.MontoDesembolso, 
								                      c.NroDiasAtraso, cd.SaldoCapital, cd.CapitalVencido, cd.SaldoInteres AS SaldoINTE, cd.SaldoMoratorio AS SaldoINPE, cd.OtrosCargos, 
								                      cd.UltimoMovimiento, cd.SaldoEnMora, cd.TipoCalificacion, cd.InteresVigente AS SaldoINTEVIG, cd.MoratorioVigente AS SaldoINPEVIG, 
								                      cd.InteresCtaOrden AS SaldoINTESus, cd.MoratorioCtaOrden AS SaldoINPESus, c.Calificacion, c.ProvisionCapital, c.ProvisionInteres, 
								                      c.GarantiaLiquidaMonetizada, c.GarantiaPreferidaMonetizada, c.GarantiaMuyRapidaRealizacion, c.TotalGarantia, c.TasaIntCorriente, c.TasaINVE, 
								                      c.TasaINPE, cli.Cliente, cli.CodDocIden, cli.DI, 
								                      CASE  c.codproducto WHEN '121' THEN 'SOLIDARIO' WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS Tecnologia, 
								                      CASE  c.codproducto WHEN '121' THEN 'PREFACIL' WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS Tecnologia2, 
								                      CASE WHEN tCsPadronCarteraDet.SecuenciaCliente > 1 THEN 1 ELSE 0 END AS Represtamos, 
								                      CASE WHEN tCsPadronCarteraDet.SecuenciaCliente > 1 THEN cd.MontoDesembolso ELSE 0 END AS DesembReprestamos
								FROM         tCsCartera c INNER JOIN
								                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo LEFT OUTER JOIN
								                      tCsPadronCarteraDet ON cd.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
								                      cd.CodUsuario = tCsPadronCarteraDet.CodUsuario LEFT OUTER JOIN
								                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Cliente, CodDocIden, DI, CodUbiGeoDirFamPri, DireccionDirFamPri, 
								                                                   TelefonoDirFamPri, LabCodActividad
								                            FROM          tCspadronClientes) cli ON cd.CodUsuario = cli.CodUsuario LEFT OUTER JOIN
								                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina
                                                                                                                       WHERE      (cd.Fecha = @Fecha) AND (c.estado <> 'CASTIGADO') AND (c.FechaDesembolso >= @FechaIni AND 
                                                                                                                                              c.FechaDesembolso <= @Fecha)) a) b
                                                                       GROUP BY Fecha, Tecnologia2, CodOficina, NomOficina, NroPtmos_0Dias, NroPtmos_30Dias, 
                                                                                              NroPtmos_90Dias, NroPtmos_MasDias) c) d
                       GROUP BY Fecha, CodOficina, NomOficina) e
--SQL
OPEN sql_cur

FETCH NEXT FROM sql_cur 
INTO @Periodo, @Oficina, @NroClientes, @Montos, @NroReprestamos, @DesemRepre

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	VALUES     (@Periodo, @Fecha, @Oficina, 'NUEVOS CLIENTES',@NroClientes, 2)
	
	INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	VALUES     (@Periodo, @Fecha, @Oficina, 'DESEMBOLSOS', @Montos, 2)

	INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	VALUES     (@Periodo, @Fecha, @Oficina, 'NUEVOS REPRESTAMOS', @NroReprestamos, 2)

	INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	VALUES     (@Periodo, @Fecha, @Oficina, 'DESEMBOLSOS REPRESTAMOS', @DesemRepre, 2)
   -- siguiente
   FETCH NEXT FROM sql_cur 
   INTO @Periodo, @Oficina, @NroClientes, @Montos, @NroReprestamos, @DesemRepre
END
CLOSE sql_cur
DEALLOCATE sql_cur

--Insertar los datos de las metas...
INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
SELECT     tCsMtsCruzados.Periodo, @Fecha as fecha, replicate('0',2 - datalength(tClOficinas.CodOficina)) + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina as oficina, tCsMtsConceptos.Descripcion, tCsMtsCruzados.Monto,1 as agrupa
FROM         tCsMtsCruzados LEFT OUTER JOIN
                      tCsMtsConceptos ON tCsMtsCruzados.CodigoX = tCsMtsConceptos.CodConceptos LEFT OUTER JOIN
                      tClOficinas ON tCsMtsCruzados.CodigoY = tClOficinas.CodOficina
WHERE     (tCsMtsCruzados.Periodo = CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2))) and (tCsMtsCruzados.CodigoX IN (1, 2, 3, 4, 5))  AND (tCsMtsCruzados.CodEntidadX = 2)
--Opero grupo 2 con 1, y genero grupo 3 resultados
DECLARE @Concepto varchar(100)

DECLARE sql_grupos CURSOR FOR 
select Oficina,descripcion, monto from #tb where agrupa=1 order by Oficina
OPEN sql_grupos

FETCH NEXT FROM sql_grupos
INTO @Oficina, @Concepto, @Montos

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @Montos1 decimal(16,4)
	select @Montos1 = monto from #tb 
	where agrupa=2  and oficina=@Oficina and descripcion=@Concepto
	order by Oficina

	if (@Montos1 is null)
	begin
		set @Montos1 = 0
	end
	
	INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	VALUES     (@Periodo, @Fecha, @Oficina, @Concepto,(@Montos1 - @Montos), 3)

	/*if (@Montos<>0)
	begin
	 INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	 VALUES     (@Periodo, @Fecha, @Oficina, '% '+ @Concepto,(@Montos1 - @Montos)/@Montos*100, 3)
	end*/

   -- siguiente
   FETCH NEXT FROM sql_grupos 
   INTO @Oficina, @Concepto, @Montos 
END
CLOSE sql_grupos
DEALLOCATE sql_grupos

select * from #tb order by Oficina
drop table #tb
GO