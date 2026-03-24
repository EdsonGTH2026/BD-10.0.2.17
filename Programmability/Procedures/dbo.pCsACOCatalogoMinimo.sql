SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsACOCatalogoMinimo '20200101', '20200131'
CREATE PROCEDURE [dbo].[pCsACOCatalogoMinimo] @FechaIni smalldatetime, @FechaFin smalldatetime 
AS
SET NOCOUNT ON
--DECLARE @FechaIni	smalldatetime
--DECLARE @FechaFin	smalldatetime
--SET @FechaIni   = '20200101'
--SET @FechaFin   = '20200131'


DECLARE @AgOficina	char(1)
DECLARE @CodOficina	varchar(20)
DECLARE @Reporte	varchar(2)
DECLARE @Opera	char(1)

SET @AgOficina  = '0'
SET @Reporte	= '01'
SET @Opera	= '1' --0: No realiza calculo 1:calcula columnas
--SET @CodOficina	='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,98,99,70,71'
SET @CodOficina = ''
--Tabla temporal contable contiene los datos de la balanza
--DECLARE @tbAux table (
create  table #tbAux (
	Sesion			varchar(25),
	CodCta			varchar(25),
	CodOficina		varchar(5),
	CodFondo		varchar(5),
	DescCta			varchar(100),
	AnteDebe		decimal(16,4),
	AntHaber		decimal(16,4),
	MovDebe			decimal(16,4),
	MovHaber		decimal(16,4),
	SalAntTotal		decimal(16,4),
	SalFinDebe		decimal(16,4),
	SalFinHaber		decimal(16,4),
	SubMovDebe		decimal(16,4),
	SubMovHaber		decimal(16,4),
	SubSalFinDebe		decimal(16,4),
	SubSalFinHaber		decimal(16,4)
)

DECLARE @FechaInix	varchar(12)
DECLARE @FechaFinx	varchar(12)

SET @FechaInix   = dbo.fduFechaAAAAMMDD(@FechaIni)
SET @FechaFinx   = dbo.fduFechaAAAAMMDD(@FechaFin)

DECLARE @Servidor varchar(50)
DECLARE @BaseDatos varchar(50)
--select * FROM tCsServidores 
SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@FechaFin) as varchar(4)))
--print @BaseDatos
--print @Servidor
DECLARE @ctext varchar(800)

--SET @ctext = '['+@Servidor+'].'+@BaseDatos+'.dbo.pCsCoBalanceComprobacionDatos '''+@FechaInix+''','''+ @FechaFinx+''', '''+@AgOficina+''', '''+@CodOficina+''', ''1'''
----Exec FINMAS_CONTA2008.dbo.pCsCoBalanceComprobacionDatos @FechaInix, @FechaFin, @AgOficina, @CodOficina, '1'
--Exec (@ctext)

--SET @ctext = 'INSERT #tbAux SELECT * FROM '+'['+@Servidor+'].'+@BaseDatos+'.dbo.tCsCoAux '
--Exec (@ctext)

SET @ctext = 'INSERT #tbAux (codcta, codoficina, codfondo, antedebe, anthaber, salfindebe, salfinhaber) '
SET @ctext = @ctext + 'SELECT codcta, codoficina, codfondo, antdebe, anthaber, mesdebe, meshaber '
SET @ctext = @ctext + 'FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores '
SET @ctext = @ctext + 'WHERE gestion='''+cast(year(@FechaFin) as varchar(4))+''' and mes='+cast(month(@FechaFin) as varchar(2))+' '
EXEC(@ctext)
--print '@ctext:' + @ctext
--Obtengo la tabla plantilla
CREATE TABLE #Plantilla (
	Codigo 		varchar(10),
	Descripcion 	varchar(200),
	Nivel 		int,
	NivelReporte	int,
	OrdenNivel 	int,
	TipoValor 	varchar(2),
	Basedatos 	varchar(2),
	Operacion 	varchar(1000),
	CuentaCampo 	varchar(200),	
	TipoCampo	varchar(200),
	Valor 		decimal(16,2)
)

INSERT INTO #Plantilla (Codigo,Descripcion,Nivel,NivelReporte,OrdenNivel,TipoValor,Basedatos,Operacion,CuentaCampo,TipoCampo)
--SELECT Codigo,Descripcion,Nivel,NivelReporte,OrdenNivel,TipoValor,Basedatos,Operacion,CuentaCampo,TipoCampo FROM tCsCoPlantilla WHERE (Reporte = @Reporte)  and oculto=0
SELECT a.Codigo,a.Descripcion,a.Nivel,a.NivelReporte,a.OrdenNivel,
			 case when b.periodo is null then a.TipoValor else b.TipoValor end tipovalor,
			 case when b.periodo is null then a.Basedatos else b.Basedatos end Basedatos,
			 case when b.periodo is null then a.Operacion else b.Operacion end Operacion,
			 case when b.periodo is null then a.CuentaCampo else b.CuentaCampo end CuentaCampo,
			 case when b.periodo is null then a.TipoCampo else b.TipoCampo end TipoCampo
FROM tCsCoPlantilla a left join tCsCoPlantillahistorico b on a.reporte=b.reporte and a.codigo=b.codigo and b.periodo=dbo.fduFechaATexto(@FechaFin,'aaaamm')
WHERE (a.Reporte = @Reporte) and a.oculto=0 

--select * from #Plantilla 

--AND substring(codigo,1,1)=@Formato
--CURSOR PARA OBTENER LOS VALORES CONTABLES
DECLARE @Codigo varchar(10)
DECLARE @Operacion varchar(1000)
DECLARE @CuentaCampo varchar(200)
DECLARE @TipoCampo varchar(10)

--print '--------------------------------------------------- 1 '
DECLARE reg_calcula CURSOR FOR 
	SELECT Codigo, Operacion, CuentaCampo,TipoCampo FROM #Plantilla with(nolock)
	WHERE (TipoValor = 1) AND (Basedatos = 1)
OPEN reg_calcula

FETCH NEXT FROM reg_calcula 
INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo

WHILE @@FETCH_STATUS = 0
BEGIN
	--SEPARAR LAS CUENTAS QUE NECESITAMOS OBTENER SU VALOR
	--dbo.fduTablaValores	
	--SELECT * FROM dbo.fduTablaValores('33,1120000000,1140000000')
	--print '@Codigo: ' + @Codigo
	--print '@CuentaCampo: ' + @CuentaCampo
	--CURSOR POR CUENTA PARA FORMULA
	DECLARE @CodCuenta varchar(20)

	DECLARE reg_cuenta CURSOR FOR
			SELECT Codigo FROM dbo.fduTablaValores(@CuentaCampo)
	OPEN reg_cuenta
	FETCH NEXT FROM reg_cuenta 
	INTO @CodCuenta
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--print '@CodCuenta: '+@CodCuenta

		DECLARE @Valor decimal(16,4)
		DECLARE @SDebe decimal(16,4)
		DECLARE @SHaber decimal(16,4)
		--SELECT * FROM @tbAux 
		--WHERE SUBSTRING(CodCta,0,LEN(@CodCuenta))=@CodCuenta
		--print '@Valor1: ' + isnull(str(@Valor),'')
		SELECT @Valor = SUM(VALOR), @SDebe = SUM(SalFinHaber), @SHaber=SUM(SalFinDebe) 
		FROM (
			SELECT @CodCuenta AS Cuenta
			, CASE @TipoCampo WHEN 'debe' THEN ISNULL(SalFinDebe,0) - ISNULL(SalFinHaber ,0) ELSE ISNULL(SalFinHaber,0) - ISNULL(SalFinDebe,0) END AS VALOR
			, ISNULL(SalFinHaber,0) SalFinHaber, ISNULL(SalFinDebe,0) SalFinDebe  
		FROM #tbAux with(nolock) 
		--WHERE (SUBSTRING(CodCta, 1, LEN(@CodCuenta)) = @CodCuenta)
		WHERE CodCta= @CodCuenta
		) A
		--print '@Valor2: ' + str(@Valor)

		--if(@CodCuenta='1101')
		--begin
		--	SELECT @CodCuenta AS Cuenta
		--	, CASE @TipoCampo WHEN 'debe' THEN ISNULL(SalFinDebe,0) - ISNULL(SalFinHaber ,0) ELSE ISNULL(SalFinHaber,0) - ISNULL(SalFinDebe,0) END AS VALOR
		--	, ISNULL(SalFinHaber,0) SalFinHaber, ISNULL(SalFinDebe,0) SalFinDebe  
		--	FROM #tbAux with(nolock) WHERE (SUBSTRING(CodCta, 1, LEN(@CodCuenta)) = @CodCuenta)
		--end

		/*SELECT Cuenta, SUM(VALOR), SUM(SalFinHaber), SUM(SalFinDebe) FROM
		(SELECT @CodCuenta AS Cuenta, CASE @TipoCampo WHEN 'debe' THEN ISNULL(SalFinDebe,0) - ISNULL(SalFinHaber ,0)
		ELSE ISNULL(SalFinHaber,0) - ISNULL(SalFinDebe,0) END AS VALOR, ISNULL(SalFinHaber,0) SalFinHaber, ISNULL(SalFinDebe,0) SalFinDebe  
		FROM @tbAux WHERE (SUBSTRING(CodCta, 1, LEN(@CodCuenta)) = @CodCuenta)) A
		GROUP BY Cuenta
		PRINT '---------------------------'
		PRINT @CodCuenta
		PRINT @SDebe
		PRINT @SHaber
		PRINT '---------------------------'
		*/
		--ACTUALIZAR EL VALOR EN LA FORMULA
		--PRINT '('+CAST( ROUND(ISNULL(@Valor,0),2) AS varchar(20))+')'
		UPDATE #Plantilla
		SET Operacion = REPLACE(Operacion, '<' + @CodCuenta + '>', '('+CAST( ROUND(ISNULL(@Valor,0),2) AS varchar(20))+')')
		WHERE (Codigo = @Codigo)
	   FETCH NEXT FROM reg_cuenta 
	   INTO @CodCuenta
	END
	
	CLOSE reg_cuenta
	DEALLOCATE reg_cuenta

	--UPDATE #Plantilla
	--SET Operacion = REPLACE(REPLACE(Operacion,'<',''),'>','')
	--WHERE (Codigo = @Codigo)
	 
	--FIN DE SEPARAR LAS CUENTAS QUE NECESITAMOS OBTENER SU VALOR   
   FETCH NEXT FROM reg_calcula 
   INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo
END

CLOSE reg_calcula
DEALLOCATE reg_calcula

--print '--------------------------------------------------- 2 '

--DECLARE @Codigo varchar(10)
--DECLARE @Operacion varchar(1000)
--DECLARE @CuentaCampo varchar(200)
--DECLARE @TipoCampo varchar(10)
DECLARE @csql varchar(2000)

DECLARE reg_calcula CURSOR FOR 
	SELECT Codigo, Operacion, CuentaCampo FROM #Plantilla
	WHERE (TipoValor = 1) AND (Basedatos = 1)
OPEN reg_calcula
FETCH NEXT FROM reg_calcula 
INTO @Codigo, @Operacion, @CuentaCampo

WHILE @@FETCH_STATUS = 0
BEGIN
	--print '@Codigo' + @Codigo
	
	SET @csql = ' UPDATE #Plantilla '
	SET @csql = @csql + ' SET Valor = '+ @Operacion
	SET @csql = @csql + ' WHERE (Codigo = '''+@Codigo+''')'
	--print @csql
	exec (@csql)

	--FIN DE SEPARAR LAS CUENTAS QUE NECESITAMOS OBTENER SU VALOR   
   FETCH NEXT FROM reg_calcula 
   INTO @Codigo, @Operacion, @CuentaCampo
END

CLOSE reg_calcula
DEALLOCATE reg_calcula

--SELECT *
--FROM #Plantilla
--WHERE (TipoValor = 1) AND (Basedatos = 1)

-- VERIFICA LA EXISTENCIA DE VALORES DE BASE CONSOLIDADA
-- EJECUTA LOS PROCESOS DE BASE CONSOLIDADA

--print '--------------------------------------------------- 3 '

--DECLARE @FechaFin	smalldatetime
--SET @FechaFin   = '20200430'

--DECLARE @Codigo varchar(10)
--DECLARE @Operacion varchar(1000)
--DECLARE @CuentaCampo varchar(200)
--DECLARE @TipoCampo varchar(10)
--DECLARE @csql varchar(2000)

CREATE TABLE #tCsCoTmp (valor decimal(16, 2))
DECLARE @ValOpe decimal(16,2)

DECLARE reg_calcula_ope CURSOR FOR 
	SELECT Codigo, Operacion, CuentaCampo,TipoCampo FROM #Plantilla
	WHERE (TipoValor = 1) AND (Basedatos = 2)
OPEN reg_calcula_ope

FETCH NEXT FROM reg_calcula_ope 
INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo

WHILE @@FETCH_STATUS = 0
BEGIN
	--print '@Codigo: ' + @Codigo
	SET @csql = ' TRUNCATE TABLE #tCsCoTmp '
	SET @csql = @csql + ' INSERT INTO #tCsCoTmp '
	---dbo.fduSaldoCarteraQuirografarias ('20080630','VIGENTE',1) 
	SET @csql = @csql + ' SELECT ' + REPLACE(@Operacion,@CuentaCampo,''''+dbo.fduFechaAAAAMMDD(@FechaFin)+'''')
	
	--PRINT @csql
	EXEC (@csql)

	SELECT @ValOpe = ISNULL(Valor,0) FROM #tCsCoTmp
	--PRINT @ValOpe
	-- LUEGO DE OBTENER EL VALOR ACTUALIZAR EN EL TEMPORAL
	UPDATE #Plantilla
	-----------SET Operacion = REPLACE(Operacion, '<' + @CuentaCampo + '>', '('+CAST( @ValOpe AS varchar(20))+')')
	SET Valor = @ValOpe 
	WHERE (Codigo = @Codigo)

   FETCH NEXT FROM reg_calcula_ope 
   INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo
END

CLOSE reg_calcula_ope
DEALLOCATE reg_calcula_ope

--print '--------------------------------------------------- 4 '

DROP TABLE #tCsCoTmp

-- FIN EJECUTA LOS PROCESOS DE BASE CONSOLIDADA

--Realiza la operacion entre valores de los registros

if (@Opera=1)
	begin
		declare @Niveles int
		SELECT @Niveles = MAX(Nivel) FROM #Plantilla-- WHERE (Reporte = '01')
		
		while @Niveles >= 0
		begin
			DECLARE @CodRegistro varchar(20)
			DECLARE @CodCuentaCampo varchar(200)
			--print '@Niveles ' + str(@Niveles)

			DECLARE Registros CURSOR FOR 
				SELECT codigo,cuentacampo FROM #Plantilla WHERE (Nivel = @Niveles) AND (TipoValor = 2)
			OPEN Registros
			FETCH NEXT FROM Registros 
			INTO @CodRegistro,@CodCuentaCampo
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				--OBTENER LA CADENA DE VALORES
				--CREAR CURSOR DE LOS VALORES POR CAMPO
				--SELECT Codigo FROM dbo.fduTablaValores(@CodCuentaCampo)

				DECLARE @Campo varchar(20)
				DECLARE Campo_calcular CURSOR FOR
					SELECT Codigo FROM dbo.fduTablaValores(@CodCuentaCampo)				
				OPEN Campo_calcular
			
				FETCH NEXT FROM Campo_calcular
				INTO @Campo
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
						--PRINT @Campo
						DECLARE @Valorn VARCHAR(1000)--decimal(16,4)
						SELECT @Valorn = ISNULL(CAST(VALOR AS VARCHAR(50)),operacion) FROM #Plantilla WHERE codigo = @Campo
						--ACTUALIZAR EL VALOR EN LA FORMULA
						--PRINT '('+CAST( ROUND(ISNULL(@Valor,0),2) AS varchar(20))+')'
						UPDATE #Plantilla
						SET Operacion = REPLACE(Operacion, '<' + @Campo + '>', '('+CAST(ISNULL(@Valorn,0)as varchar(200))+')')
						WHERE (Codigo = @CodRegistro)
						
				   FETCH NEXT FROM Campo_calcular 
				   INTO @Campo
				END
				
				CLOSE Campo_calcular
				DEALLOCATE Campo_calcular
				--FIN OBTENER LA CADENA DE VALORES

				SELECT @Operacion = Operacion FROM #Plantilla WHERE (Codigo = @CodRegistro)
				
				SET @csql = ' UPDATE #Plantilla '
				SET @csql = @csql + ' SET Valor = '+ @Operacion
				SET @csql = @csql + ' WHERE (Codigo = '''+@CodRegistro+''')'
				--print @csql
				exec (@csql)

			--FIN DE RECORRER CUENTAS POR NIVEL   
			   FETCH NEXT FROM Registros 
			   INTO @CodRegistro,@CodCuentaCampo
			END
			
			CLOSE Registros
			DEALLOCATE Registros

			SET @Niveles = @Niveles - 1
		end
end

--Sin Realiza la operacion entre valores de los registros
SELECT codigo,descripcion,nivel,tipovalor,operacion,cuentacampo,valor
FROM #Plantilla 

DROP TABLE #tbAux
DROP TABLE #Plantilla
--drop table #tCsCoTmp

SET NOCOUNT OFF
-----------------------------------------------------
GO