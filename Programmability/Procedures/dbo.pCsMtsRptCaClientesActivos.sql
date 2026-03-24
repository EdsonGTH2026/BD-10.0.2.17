SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[pCsMtsRptCaClientesActivos] @Fecha smalldatetime, @FechaIni smalldatetime AS

--DECLARE @Fecha smalldatetime
--SET @Fecha = '20080127'


SELECT  @FechaIni = DATEADD([day], - 1, PrimerDia)  FROM          tClPeriodo
                    WHERE      periodo = CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 
                                           2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                                           + CAST(MONTH(@Fecha) AS varchar(2))

DECLARE @Periodo smalldatetime, @Oficina varchar(100), @NroClientes int, @Montos decimal(16,4), @NroReprestamos int, @DesemRepre decimal(16, 4)

create table #tb(periodo smalldatetime,fecha smalldatetime, Oficina varchar(100) ,descripcion varchar(100), monto decimal(16,4), agrupa int)

--Insertar los datos de las metas...
INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
SELECT    @FechaIni as Periodo, Fecha, oficina, NombreTec, NumClientes Monto, agrupa
FROM         (SELECT     Periodo, Fecha, oficina, COUNT(CodUsuario) AS NumClientes, NombreTec, agrupa
                       FROM          (SELECT      CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)) AS Periodo, @Fecha AS Fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                                                                      + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, tCsCarteraDet.CodUsuario, tCaClTecnologia.NombreTec, 
                                                                      3 AS agrupa
                                               FROM          tCsCartera INNER JOIN
                                                                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                                                                      tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                                                      tCaClTecnologia INNER JOIN
                                                                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON 
                                                                      tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN
                                                                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tCsCarteraDet.Fecha =@Fecha) AND (tCsCartera.Estado <> 'castigado')) A
                       GROUP BY Periodo, Fecha, oficina, NombreTec, agrupa) a
UNION
SELECT    @FechaIni as Periodo, @Fecha AS fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                      + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, tCaClTecnologia.NombreTec, tCsMtsCruzados.Monto, 2 AS agrupa
FROM         tCsMtsCruzados LEFT OUTER JOIN
                      tCaClTecnologia ON tCsMtsCruzados.CodigoX = tCaClTecnologia.Tecnologia LEFT OUTER JOIN
                      tClOficinas ON tCsMtsCruzados.CodigoY = tClOficinas.CodOficina
WHERE     (tCsMtsCruzados.Periodo = CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2))) AND (tCsMtsCruzados.CodigoX IN (1, 2, 3)) AND (tCsMtsCruzados.CodEntidadX = 3)
union
SELECT     @FechaIni as Periodo, Fecha, oficina, NombreTec, NumClientes Monto, agrupa
FROM         (SELECT     Periodo, Fecha, oficina, COUNT(DISTINCT CodUsuario) AS NumClientes, NombreTec, agrupa
                       FROM          (SELECT      CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)) AS Periodo, @Fecha AS Fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                                                                      + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, tCsCarteraDet.CodUsuario, tCaClTecnologia.NombreTec, 
                                                                      1 AS agrupa
                                               FROM          tCsCartera INNER JOIN
                                                                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                                                                      tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                                                      tCaClTecnologia INNER JOIN
                                                                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON 
                                                                      tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN
                                                                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tCsCarteraDet.Fecha = @FechaIni) AND (tCsCartera.Estado <> 'castigado')) A
                       GROUP BY Periodo, Fecha, oficina, NombreTec, agrupa) a
union 
--Saldosssss
SELECT   @FechaIni as  Periodo, Fecha, oficina, NombreTec + ' ($)' AS NombreTec, SaldoCartera AS Monto, agrupa
FROM         (SELECT     Periodo, Fecha, oficina, SUM(SaldoCapital) AS SaldoCartera, NombreTec, agrupa
                       FROM          (SELECT    CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)) AS Periodo, @Fecha AS Fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                                                                      + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                                                                      tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                                                       AS SaldoCapital, tCaClTecnologia.NombreTec,4 AS agrupa
                                               FROM          tCsCartera INNER JOIN
                                                                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                                                                      tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                                                      tCaClTecnologia INNER JOIN
                                                                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON 
                                                                      tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN
                                                                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Estado <> 'castigado')) A
                       GROUP BY Periodo, Fecha, oficina, NombreTec, agrupa) a
/*union
SELECT     Periodo, Fecha, oficina, NombreTec + ' ($)' AS NombreTec, SaldoCartera AS Monto, agrupa
FROM         (SELECT     Periodo, Fecha, oficina, SUM(SaldoCapital) AS SaldoCartera, NombreTec, agrupa
                       FROM          (SELECT    CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)) AS Periodo, @Fecha AS Fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                                                                      + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                                                                      tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                                                       AS SaldoCapital, tCaClTecnologia.NombreTec, 1 AS agrupa
                                               FROM          tCsCartera INNER JOIN
                                                                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                                                                      tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                                                      tCaClTecnologia INNER JOIN
                                                                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON 
                                                                      tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN
                                                                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tCsCarteraDet.Fecha = (SELECT     primerdia FROM          tClPeriodo
                                                                            WHERE      periodo = CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 
                                                                                                   2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                                                                                                   + CAST(MONTH(@Fecha) AS varchar(2)))) AND (tCsCartera.Estado <> 'castigado')) A
                       GROUP BY Periodo, Fecha, oficina, NombreTec, agrupa) a

*/
--Opero grupo 2 con 1, y genero grupo 3 resultados
/*DECLARE @Concepto varchar(100)

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

	if (@Montos<>0)
	begin
	 INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	 VALUES     (@Periodo, @Fecha, @Oficina, '% '+ @Concepto,(@Montos1 - @Montos)/@Montos*100, 3)
	end

   -- siguiente
   FETCH NEXT FROM sql_grupos 
   INTO @Oficina, @Concepto, @Montos 
END
CLOSE sql_grupos
DEALLOCATE sql_grupos
*/
select * from #tb order by Oficina
drop table #tb
GO