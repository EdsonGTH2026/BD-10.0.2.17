SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[pCsMtsRptCaSaldosCartera] @Fecha smalldatetime, @FechaIni smalldatetime AS

--DECLARE @Fecha smalldatetime
--SET @Fecha = '20080127'

SELECT  @FechaIni = DATEADD([day], - 1, PrimerDia)  FROM          tClPeriodo
                    WHERE      periodo = CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 
                                           2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                                           + CAST(MONTH(@Fecha) AS varchar(2))


DECLARE @Periodo smalldatetime, @Oficina varchar(100), @NroClientes int, @Montos decimal(16,4), @NroReprestamos int, @DesemRepre decimal(16, 4)

create table #tb(periodo  smalldatetime,fecha smalldatetime, Oficina varchar(100) ,descripcion varchar(100), monto decimal(16,4), agrupa int)

--Insertar los datos de las metas...
INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
SELECT     @FechaIni as Periodo, @Fecha AS fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                      + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina,
 tCsMtsConceptos.Descripcion, tCsMtsCruzados.Monto, 1 AS agrupa
FROM         tCsMtsCruzados LEFT OUTER JOIN
                      tCsMtsConceptos ON tCsMtsCruzados.CodigoX = tCsMtsConceptos.CodConceptos LEFT OUTER JOIN
                      tClOficinas ON tCsMtsCruzados.CodigoY = tClOficinas.CodOficina
WHERE     (tCsMtsCruzados.CodEntidadX = 2) AND (tCsMtsCruzados.CodigoX = '6') AND 
(tCsMtsCruzados.Periodo = CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)))
UNION
SELECT     @FechaIni as Periodo, Fecha, oficina, Nombre AS NombreTec, SaldoCartera AS Monto, agrupa
FROM         (SELECT     Periodo, Fecha, oficina, SUM(SaldoCapital) AS SaldoCartera, Nombre, agrupa
FROM          (SELECT   CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)) AS Periodo, @Fecha AS Fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                              + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                              tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                               AS SaldoCapital, 'SALDO CARTERA' AS Nombre, 3 AS agrupa
       FROM          tCsCartera INNER JOIN
                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                              tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                              tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
       WHERE      (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Estado <> 'castigado')) A
GROUP BY Periodo, Fecha, oficina, Nombre, agrupa) a
UNION
SELECT     @FechaIni as Periodo, Fecha, oficina, Nombre AS NombreTec, SaldoCartera AS Monto, agrupa
FROM         (SELECT     Periodo, Fecha, oficina, SUM(SaldoCapital) AS SaldoCartera, Nombre, agrupa
FROM          (SELECT   CAST(YEAR(@Fecha) AS char(4)) + REPLICATE('0', 2 - DATALENGTH(CAST(MONTH(@Fecha) AS varchar(2)))) 
                      + CAST(MONTH(@Fecha) AS varchar(2)) AS Periodo, @Fecha AS Fecha, REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) 
                              + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                              tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                               AS SaldoCapital, 'SALDO CARTERA' AS Nombre, 2 AS agrupa
       FROM          tCsCartera INNER JOIN
                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                              tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                              tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
       WHERE      (tCsCarteraDet.Fecha = @FechaIni) AND (tCsCartera.Estado <> 'castigado')) A
GROUP BY Periodo, Fecha, oficina, Nombre, agrupa) a

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
	where agrupa=3  and oficina=@Oficina and descripcion=@Concepto
	order by Oficina

	if (@Montos1 is null)
	begin
		set @Montos1 = 0
	end
	
	/*INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	VALUES     (@Periodo, @Fecha, @Oficina, @Concepto,(@Montos1 - @Montos), 3)*/

	if (@Montos<>0)
	begin
	 INSERT INTO #tb (periodo,fecha ,oficina,Descripcion, monto, agrupa)
	 VALUES     (@Periodo, @Fecha, @Oficina, '% '+ @Concepto,(@Montos1)/@Montos*100, 4)
	end

   -- siguiente
   FETCH NEXT FROM sql_grupos 
   INTO @Oficina, @Concepto, @Montos 
END
CLOSE sql_grupos
DEALLOCATE sql_grupos

select * from #tb order by Oficina
drop table #tb
GO