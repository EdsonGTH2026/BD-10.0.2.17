SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaCuentasBalance] @FechaIni smalldatetime, @FechaFin smalldatetime, @Reporte varchar(2), @Opera	char(1), @IdSession varchar(20) output AS
--DECLARE @FechaIni	smalldatetime	--p
--DECLARE @FechaFin	smalldatetime	--p
--DECLARE @Reporte	varchar(2)		--p
--DECLARE @IdSession	varchar(20)		--p
--DECLARE @Opera		char(1)			--p

DECLARE @AgOficina	char(1)
DECLARE @CodOficina	varchar(20)
DECLARE @ctext 		varchar(8000)
DECLARE @tienegrupo	char(1)
DECLARE @csql varchar(2000)

--SET @FechaIni   = '20080101'--p
--SET @FechaFin   = '20081231'--p
--SET @Reporte	= '03'		--p

SET @AgOficina  = 0		
SET @CodOficina = ''	--OJO : colocar condicional
SET @Opera		= '1'	--0: No realiza calculo 1:calcula columnas

SET NOCOUNT ON

--Obtengo la configuracion de la plantilla
CREATE TABLE #Plantilla (
	Codigo 		varchar(10),
	Descripcion 	varchar(200),
	Nivel 		int,
	NivelReporte	int,
	OrdenNivel 	int,
	TipoValor 	varchar(2),
	Basedatos 	varchar(2),
	Operacion 	varchar(200),
	CuentaCampo 	varchar(200),	
	TipoCampo	varchar(200),
	Valor 		decimal(16,4),
	Oculto 		char(1),
	Grupo 		varchar(10),
	Fuente 		varchar(10)
)

INSERT INTO #Plantilla (Codigo,Descripcion,Nivel,NivelReporte,OrdenNivel,TipoValor,Basedatos,Operacion,CuentaCampo,TipoCampo,valor,Oculto,Grupo,Fuente)
--SELECT Codigo,Descripcion,Nivel,NivelReporte,OrdenNivel,TipoValor,Basedatos,Operacion,CuentaCampo,TipoCampo,valor,Oculto,Grupo,Fuente FROM tCsCoPlantilla
--WHERE (Reporte = @Reporte)
SELECT a.Codigo,a.Descripcion,a.Nivel,a.NivelReporte,a.OrdenNivel,
			 case when b.periodo is null then a.TipoValor else b.TipoValor end tipovalor,
			 case when b.periodo is null then a.Basedatos else b.Basedatos end Basedatos,
			 case when b.periodo is null then a.Operacion else b.Operacion end Operacion,
			 case when b.periodo is null then a.CuentaCampo else b.CuentaCampo end CuentaCampo,
			 case when b.periodo is null then a.TipoCampo else b.TipoCampo end TipoCampo,valor,Oculto,Grupo,Fuente
FROM tCsCoPlantilla a left join tCsCoPlantillahistorico b on a.reporte=b.reporte and a.codigo=b.codigo and b.periodo=dbo.fduFechaATexto(@FechaFin,'aaaamm')
WHERE (a.Reporte = @Reporte) --and a.oculto=0 


CREATE TABLE #tCsvalTmp (valor varchar(200))

CREATE TABLE #tbgrupos (
			Codigo			varchar(25),
			Cuentacampo		varchar(50),
			Operacion		varchar(100)
		)
SELECT @tienegrupo=TieneGrupos FROM tCsCoReportes WHERE (Reporte = @Reporte)

if(@tienegrupo='1')
	begin
		INSERT INTO #tbgrupos (Codigo,CuentaCampo,Operacion)
		SELECT Codigo, CuentaCampo, operacion FROM tCsCoPlantilla WHERE (Reporte = @Reporte) AND (Grupo = '1')
	end
else
	begin
		INSERT INTO #tbgrupos (Codigo,CuentaCampo,Operacion) values('0000000000','default','')
	end		

--SELECT * FROM #tbgrupos

DECLARE @grcodigo varchar(25)
DECLARE @groperacion varchar(200)
DECLARE @grcuentacampo varchar(25)

DECLARE genxgrupo CURSOR FOR 
SELECT Codigo,CuentaCampo,operacion FROM #tbgrupos
OPEN genxgrupo

FETCH NEXT FROM genxgrupo 
INTO @grcodigo, @grcuentacampo,@groperacion

WHILE @@FETCH_STATUS = 0
BEGIN

		DECLARE @FechaInitmp	smalldatetime
		DECLARE @FechaFintmp	smalldatetime

		if(@grcuentacampo<>'default')
			begin
					--calcula el nuevo periodo					
					SET @csql = ' TRUNCATE TABLE #tCsvalTmp '
					SET @csql = @csql + ' INSERT INTO #tCsvalTmp '
					SET @csql = @csql + ' SELECT ' + REPLACE(@groperacion,@grcuentacampo,''''+dbo.fduFechaAAAAMMDD(@FechaFintmp)+'''')
					--PRINT @csql
					EXEC (@csql)
					SELECT @FechaFintmp	=	CAST(Valor AS smalldatetime) FROM #tCsvalTmp

					SET @csql = ' TRUNCATE TABLE #tCsvalTmp '
					SET @csql = @csql + ' INSERT INTO #tCsvalTmp '
					SET @csql = @csql + ' SELECT ''' + REPLACE(cast((year(@FechaFintmp)-1) as varchar(4))+'0101''',@grcuentacampo,''''+dbo.fduFechaAAAAMMDD(@FechaFintmp)+'''')
					--PRINT @csql
					EXEC (@csql)
					SELECT @FechaInitmp	=	CAST(Valor AS smalldatetime) FROM #tCsvalTmp
			end
		else
			begin
					--calcula el nuevo periodo
					SET @FechaInitmp=@FechaIni
					SET @FechaFintmp=@FechaFin
			end
		if(@grcodigo='0000000000') SET @grcodigo = ''

	--print @FechaInitmp
	--print @FechaFintmp
		-----------------------------------------------
		----- RECUPERA INFORMACION SEGUN AGRUPACION ---
		-----------------------------------------------
		-----------------------------------------------
		-----------------------------------------------
		DECLARE @Servidor varchar(50)
		DECLARE @BaseDatos varchar(50)
		DECLARE @NomSrv varchar(100)
		SELECT @BaseDatos=NombreBD, @Servidor=NombreIP,@NomSrv=nombreservidor FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@FechaFintmp) as varchar(4)))

		if(@NomSrv=(select @@SERVERNAME))  SET @Servidor = ''
		else SET @Servidor = '['+@Servidor+'].'

		--Tabla temporal contable contiene los datos de la balanza
		CREATE TABLE #tbAux (
			Sesion			varchar(25),
			CodCta			varchar(25),
			CodOficina		varchar(5),
			CodFondo		varchar(5),
			DescCta		varchar(100),
			AnteDebe		decimal(16,4),
			AntHaber		decimal(16,4),
			MovDebe		decimal(16,4),
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
		
		SET @FechaInix   = dbo.fduFechaAAAAMMDD(@FechaInitmp)
		SET @FechaFinx   = dbo.fduFechaAAAAMMDD(@FechaFintmp)
		--Exec ('['+@Servidor+'].'+@BaseDatos+'.dbo.pCsCoBalanceComprobacionDatos '''+@FechaInix+''','''+@FechaFinx+''','+@AgOficina+','''+@CodOficina+''',''1''')
		--SET @ctext = 'INSERT #tbAux '
		--SET @ctext = @ctext + 'SELECT * FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tCsCoAux '

		SET @ctext = 'INSERT #tbAux (codcta, codoficina, codfondo, antedebe, anthaber, salfindebe, salfinhaber) '

		--SET @ctext = @ctext + 'SELECT codcta, '''' codoficina, '''' codfondo, saldoanterior, sum(anthaber) anthaber, '
		--SET @ctext = @ctext + 'sum(sfindebe) sfindebe, sum(sfinhaber) sfinhaber FROM ( '

		--SET @ctext = @ctext + 'select co.codcta, co.codoficina, co.codfondo, salant.saldoanterior, 0 anthaber, '
		--SET @ctext = @ctext + 'co.mesdebe + co.diadebe sfindebe, co.meshaber + co.diahaber sfinhaber '
		--SET @ctext = @ctext + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores co inner join ( '
		--SET @ctext = @ctext + 'select codcta, sum(antdebe - anthaber) + sum(mesdebe + diadebe - (meshaber + diahaber )) saldoanterior '
		--SET @ctext = @ctext + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores where gestion='''+cast(year(@FechaFintmp) as varchar(4))+''' and mes='+cast((month(@FechaFintmp)-1) as varchar(2))+' ' --and codcta='121010106' 
		--SET @ctext = @ctext + 'group by codcta ) salant on salant.codcta=co.codcta '
		--SET @ctext = @ctext + 'where co.gestion='''+cast(year(@FechaFintmp) as varchar(4))+''' and co.mes='+cast(month(@FechaFintmp) as varchar(2))+' '--and co.codcta='121010106' 

		--SET @ctext = @ctext + ') A '
		--SET @ctext = @ctext + 'GROUP BY codcta, saldoanterior '
		--salant.saldoanterior + tcomayores.mesdebe + tcomayores.diadebe - tcomayores.meshaber + tcomayores.diahaber
		--antedebe + salfindebe - salfinhaber
		
		SET @ctext = @ctext + 'SELECT codcta, '''' codoficina, '''' codfondo, SUM(saldoanterior) saldoanterior, sum(anthaber) anthaber, '
		SET @ctext = @ctext + 'sum(sfindebe) sfindebe, sum(sfinhaber) sfinhaber FROM ( '
		SET @ctext = @ctext + 'SELECT codcta, codoficina, codfondo, saldoanterior, anthaber, sfindebe, sfinhaber FROM ( '
		SET @ctext = @ctext + 'SELECT codcta, codoficina, codfondo, SUM(saldoanterior) saldoanterior, '
		SET @ctext = @ctext + 'SUM(anthaber) anthaber, SUM(sfindebe) sfindebe, SUM(sfinhaber) sfinhaber ' --SUM(saldoanterior)+
		SET @ctext = @ctext + 'FROM ( '
		SET @ctext = @ctext + 'select codcta, codoficina, codfondo, 0 saldoanterior, 0 anthaber, '
		SET @ctext = @ctext + 'mesdebe + diadebe sfindebe, meshaber + diahaber sfinhaber  '
		SET @ctext = @ctext + 'from '+@Servidor+@BaseDatos+'.dbo.tcomayores '
		SET @ctext = @ctext + 'where gestion='''+cast(year(@FechaFintmp) as varchar(4))+''' and mes='+cast(month(@FechaFintmp) as varchar(2))+' ' --and codcta IN ('38', '1802', '1807', '1808')
		SET @ctext = @ctext + 'union '
		SET @ctext = @ctext + 'select codcta, codoficina, codfondo, sum(antdebe - anthaber) + sum(mesdebe + diadebe - (meshaber + diahaber )) saldoanterior '
		SET @ctext = @ctext + ', 0 anthaber, 0 salfindebe, 0 salfinhaber '
		SET @ctext = @ctext + 'from '+@Servidor+@BaseDatos+'.dbo.tcomayores  '
		SET @ctext = @ctext + 'where gestion='''+cast(year(@FechaFintmp) as varchar(4))+''' and mes='+cast((month(@FechaFintmp)-1) as varchar(2))+' ' --and codcta IN ('38', '1802', '1807', '1808') 
		SET @ctext = @ctext + 'group by codcta, codoficina, codfondo '
		SET @ctext = @ctext + ') A '
		SET @ctext = @ctext + 'GROUP BY codcta, codoficina, codfondo '
		SET @ctext = @ctext + ') B '
		SET @ctext = @ctext + ') C '
		SET @ctext = @ctext + 'GROUP BY codcta '
		
		EXEC(@ctext)
		
		--CURSOR PARA OBTENER LOS VALORES CONTABLES
		DECLARE @Codigo varchar(10)
		DECLARE @Operacion varchar(200)
		DECLARE @CuentaCampo varchar(200)
		DECLARE @TipoCampo varchar(10)
		
		--print @grcodigo
		--SELECT Codigo, Operacion, CuentaCampo,TipoCampo FROM #Plantilla
		--WHERE (TipoValor = 1) AND (Basedatos = 1) and grupo = @grcodigo
		
		DECLARE reg_calcula CURSOR FOR 
		SELECT Codigo, Operacion, CuentaCampo,TipoCampo FROM #Plantilla
		WHERE (TipoValor = 1) AND (Basedatos = 1) and grupo = @grcodigo
		OPEN reg_calcula
		
		FETCH NEXT FROM reg_calcula 
		INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--SEPARAR LAS CUENTAS QUE NECESITAMOS OBTENER SU VALOR
			--dbo.fduTablaValores	
			--SELECT * FROM dbo.fduTablaValores('33,1120000000,1140000000')
			declare @unic bit
			set @unic = 1
			if(CHARINDEX(',',@TipoCampo,0)<>0) set @unic = 0

			--CURSOR POR CUENTA PARA FORMULA
			DECLARE @CodCuenta varchar(20)
			DECLARE @Naturaleza varchar(20)

			DECLARE reg_cuenta CURSOR FOR
			SELECT Codigo,Valor FROM dbo.fduTablaValoresCols(@CuentaCampo,@TipoCampo)
			OPEN reg_cuenta
		
			FETCH NEXT FROM reg_cuenta 
			INTO @CodCuenta,@Naturaleza
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @Valor decimal(16,4)
				DECLARE @SDebe decimal(16,4)
				DECLARE @SHaber decimal(16,4)
				--antedebe + salfindebe - salfinhaber
				SELECT @Valor = SUM(VALOR), @SDebe = SUM(SalFinHaber), @SHaber=SUM(SalFinDebe) FROM
				(SELECT @CodCuenta AS Cuenta,

				 --CASE @TipoCampo WHEN 'debe' THEN SalFinDebe - SalFinHaber --antedebe +
				--ELSE ( SalFinDebe - SalFinHaber )*(-1) END AS VALOR

				--case when @unic = 1 then
				--	CASE @TipoCampo 
				--	WHEN 'debe' THEN antedebe + SalFinDebe - SalFinHaber
				--	ELSE (antedebe + SalFinDebe - SalFinHaber )*(-1) END
				--else
					CASE @Naturaleza 
					WHEN 'debe' THEN antedebe + SalFinDebe - SalFinHaber
					WHEN 'haber' THEN (antedebe + SalFinDebe - SalFinHaber )*(-1)
					WHEN 'movdebe' THEN SalFinDebe - SalFinHaber
					WHEN 'movhaber' THEN (SalFinDebe - SalFinHaber )*(-1)
					WHEN 'solodebe'  THEN SalFinDebe
					WHEN 'solohaber' THEN (SalFinHaber )*(-1)
					ELSE antedebe + SalFinDebe - SalFinHaber END
					
				--end 
				AS VALOR

				,SalFinHaber,SalFinDebe  FROM #tbAux --antedebe +
				--WHERE (SUBSTRING(CodCta, 1, LEN(@CodCuenta)) = @CodCuenta)
				WHERE (CodCta = @CodCuenta)
				) A
				UPDATE #Plantilla
				SET Operacion = REPLACE(Operacion, '<' + @CodCuenta + '>', '('+CAST( ISNULL(@Valor,0) AS varchar(20))+')')
				WHERE (Codigo = @Codigo)

			   FETCH NEXT FROM reg_cuenta 
			   INTO @CodCuenta,@Naturaleza
			END
		
			CLOSE reg_cuenta
			DEALLOCATE reg_cuenta
		
			UPDATE #Plantilla
			SET Operacion = REPLACE(REPLACE(Operacion,'<',''),'>','')
			WHERE (Codigo = @Codigo)
			 
			--FIN DE SEPARAR LAS CUENTAS QUE NECESITAMOS OBTENER SU VALOR
		   FETCH NEXT FROM reg_calcula 
		   INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo
		END
		
		CLOSE reg_calcula
		DEALLOCATE reg_calcula
		
		
		DECLARE reg_calcula CURSOR FOR 
		SELECT Codigo, Operacion, CuentaCampo FROM #Plantilla
		WHERE (TipoValor = 1) AND (Basedatos = 1)  and grupo = @grcodigo
		
		OPEN reg_calcula
		
		FETCH NEXT FROM reg_calcula 
		INTO @Codigo, @Operacion, @CuentaCampo
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			SET @csql = ' UPDATE #Plantilla '
			SET @csql = @csql + ' SET Valor = '+ @Operacion
			SET @csql = @csql + ' WHERE (Codigo = '''+@Codigo+''')'
			exec (@csql)
		
			--FIN DE SEPARAR LAS CUENTAS QUE NECESITAMOS OBTENER SU VALOR   
		   FETCH NEXT FROM reg_calcula 
		   INTO @Codigo, @Operacion, @CuentaCampo
		END
		
		CLOSE reg_calcula
		DEALLOCATE reg_calcula
		
		-- VERIFICA LA EXISTENCIA DE VALORES DE BASE CONSOLIDADA
		-- EJECUTA LOS PROCESOS DE BASE CONSOLIDADA
		CREATE TABLE #tCsCoTmp (valor decimal(16, 4))
		DECLARE @ValOpe decimal(16,4)
		
		DECLARE reg_calcula_ope CURSOR FOR 
		SELECT Codigo, Operacion, CuentaCampo,TipoCampo FROM #Plantilla
		WHERE (TipoValor = 1) AND (Basedatos = 2)  and grupo = @grcodigo
		
		OPEN reg_calcula_ope
		
		FETCH NEXT FROM reg_calcula_ope 
		INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			SET @csql = ' TRUNCATE TABLE #tCsCoTmp '
			SET @csql = @csql + ' INSERT INTO #tCsCoTmp '
			---dbo.fduSaldoCarteraQuirografarias ('20080630','VIGENTE',1)
			SET @csql = @csql + ' SELECT ' + REPLACE(@Operacion,@CuentaCampo,''''+dbo.fduFechaAAAAMMDD(@FechaFintmp)+'''')
			EXEC (@csql)
		
			SELECT @ValOpe = ISNULL(Valor,0) FROM #tCsCoTmp
			-- LUEGO DE OBTENER EL VALOR ACTUALIZAR EN EL TEMPORAL
			UPDATE #Plantilla
			--SET Operacion = REPLACE(Operacion, '<' + @CuentaCampo + '>', '('+CAST( @ValOpe AS varchar(20))+')')
			SET Valor = @ValOpe 
			WHERE (Codigo = @Codigo)
		
		   FETCH NEXT FROM reg_calcula_ope 
		   INTO @Codigo, @Operacion, @CuentaCampo,@TipoCampo
		END
		
		CLOSE reg_calcula_ope
		DEALLOCATE reg_calcula_ope
		
		
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
		
					DECLARE Registros CURSOR FOR 
					SELECT codigo,cuentacampo FROM #Plantilla WHERE (Nivel = @Niveles) AND (TipoValor = 2)  and grupo = @grcodigo
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
		
		--DECLARE @IdSession varchar(20)
		SELECT @IdSession = dbo.fduFechaAAAAMMDD(getdate()) + CAST(@@SPID AS VARCHAR (10))
		
		--SELECT * FROM #Plantilla
		--WHERE (TipoValor = 1) AND (Basedatos = 1)
		
		DELETE FROM tCsCoPlantillaProces
		WHERE     (IDSession = @IdSession)
		
		INSERT INTO tCsCoPlantillaProces
		                      (IdSession, Reporte, Codigo, Descripcion, Nivel,NivelReporte, OrdenNivel, Operacion, CuentaCampo, valor,Oculto,Grupo,Fuente)
		SELECT    @IdSession as IdSession, @Reporte as Reporte, Codigo, Descripcion, Nivel,NivelReporte, OrdenNivel, Operacion, CuentaCampo, valor,Oculto,Grupo,Fuente
		FROM         #Plantilla
		
		DROP TABLE #tbAux
		
		-----------------------------------------------
		----- FIN									---
		----- RECUPERA INFORMACION SEGUN AGRUPACION ---
		-----------------------------------------------
		-----------------------------------------------
	FETCH NEXT FROM genxgrupo 
  INTO @grcodigo, @grcuentacampo, @groperacion
END

CLOSE genxgrupo
DEALLOCATE genxgrupo

		
--DELETE FROM tCsCoPlantillaProces
--WHERE     (IDSession = @IdSession)

--SELECT * FROM tCsCoPlantillaProces
--WHERE     (IDSession = @IdSession)

DROP TABLE #tCsvalTmp
DROP TABLE #tbgrupos
DROP TABLE #Plantilla

SET NOCOUNT OFF
GO