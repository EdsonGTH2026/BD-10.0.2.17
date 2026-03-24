SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*------ BUSQUEDA DE CUENTAS POR CURP 
VER. ZCCU_2025.10.01 Se crear el sp para consolidar todos los productos de un cliente,buscado por Curp
*/

CREATE PROCEDURE [dbo].[pCsBuscaClienteCurpDetalle] (@curp varchar(18),@fechaini smalldatetime,@fecha smalldatetime )  
AS 

BEGIN
SET NOCOUNT ON  
   
--------------------DESCOMENTAR PARA PRUEBAS 
------declare @curp varchar(18)  
------declare @fechaini smalldatetime ---transacciones  
------declare @fecha smalldatetime  

------set @curp = 'CAAI670101MGTNRS15'--'AIFM910722HMCVLR00'--AIVM870512MMCRRR08---CAAI670101MGTNRS15  
------set @fechaini = '20150101'     
------set @fecha = '20251201'  
------------------------------------- 

	DECLARE @Print AS BIT                  
	SET @Print = 0                   
	                 
	IF @Print = 1 PRINT 'INICIO ' + convert(VARCHAR, getdate())                    

	--============= Validar fechas vacias: Se consulta el mes en curso
	IF ISNULL(@fecha,'') = ''  
	 BEGIN  
	    IF @Print = 1 print '1- Fecha no ingresada, se ajusta la busqueda al mes en curso'                    
		SELECT @fecha = fechaconsolidacion FROM vcsfechaconsolidacion WITH(NOLOCK)
	 END 
	    
	IF ISNULL(@fechaini,'') = ''  
	 BEGIN   
	 	IF @Print = 1 PRINT '2- Fecha no ingresada, se ajusta la busqueda al mes en curso'                    
		SELECT @fechaini = cast(dbo.fdufechaaperiodo(@fecha)+'01' AS SMALLDATETIME)-1       
	 END   
	  
	----------- COINCIDENCIA POR CURP CLIENTE  
	IF @Print = 1 PRINT '3- Coincidencia de cliente por Curp'                    
    
    CREATE TABLE #Cliente (CodUsuario VARCHAR(30),NombreCompleto VARCHAR(200))
	INSERT INTO  #cliente (CodUsuario,NombreCompleto)
	SELECT  PC.codusuario, PC.NombreCompleto
	---FROM tCsPadronClientes as pc WITH(NOLOCK)
	FROM tCsConsolidaClientes as pc WITH(NOLOCK)
	WHERE 1=1  
	AND (uscurp = @curp or uscurpbd = @curp)  
	  
  
--************* CARTERA ACTIVA DEL CLIENTE 

	--================ CARTERA DE CREDITO  
	CREATE TABLE #Cartera (Fecha SMALLDATETIME
							,CodUsuario VARCHAR(30)
							,CodPrestamo VARCHAR(30)
							,Estado VARCHAR(20)
							,MontoDesembolso MONEY
							,SaldoCapital MONEY
							,FechaDesembolso SMALLDATETIME
							,FechaCancelacion SMALLDATETIME)
    --== ACTIVOS EN EL MES 
	INSERT INTO #Cartera (Fecha,CodUsuario,CodPrestamo,Estado,MontoDesembolso,SaldoCapital,FechaDesembolso)
	SELECT tc.fecha,c.codusuario,tc.codprestamo,'VIGENTE' estado, tc.MontoDesembolso, tc.SaldoCapital,tc.FechaDesembolso  
	FROM tCsCartera AS tc WITH(NOLOCK)
	INNER JOIN #cliente AS c WITH(NOLOCK) ON tc.fecha =  @fecha AND tc.codusuario = c.codusuario 
	WHERE 1 = 1  
	AND tc.fecha = @fecha 
	AND Cartera='ACTIVA'  
	AND tc.codusuario in (SELECT c.codusuario FROM #cliente WITH(NOLOCK)) 
	 
	 --== CANCELADOS EN EL PERIODO
	INSERT INTO #Cartera (Fecha,CodUsuario,CodPrestamo,Estado,MontoDesembolso,SaldoCapital,FechaDesembolso,FechaCancelacion)
	SELECT Cancelacion FECHA,pcd.CodUsuario, pcd.CodPrestamo,pcd.estadocalculado, pcd.monto MontoDesembolso, 0 SaldoCapital,pcd.Desembolso,pcd.Cancelacion
	FROM tCsPadronCarteraDet as pcd with(nolock)  
	WHERE 1 = 1 
	AND pcd.codusuario in (SELECT codusuario FROM #cliente WITH(NOLOCK)) 
	AND pcd.Cancelacion >= @fechaini
	AND pcd.Cancelacion <= @fecha  
	IF @Print = 1 PRINT '4- CUENTAS ACTIVAS Y CANCELADAS del cliente en CREDITO durante el periodo buscado'                    
	 
	--================ CARTERA DE AHORRO   
    CREATE TABLE #PadronAhorros (Fecha SMALLDATETIME
						,CodUsuario VARCHAR(30)
						,CodCuenta VARCHAR(30)
						,Renovado INT
						,FechaApertura SMALLDATETIME
						,Estado VARCHAR(20)
						,SaldoCuenta MONEY
						,MontoBloqueado MONEY
						,FechaCancelacion SMALLDATETIME)
	--====== CUENTAS ACTIVAS 					
	INSERT INTO #PadronAhorros (Fecha,CodUsuario,CodCuenta,Renovado,FechaApertura,Estado,SaldoCuenta,MontoBloqueado)					
	SELECT A.Fecha,A.CODUSUARIO,A.codcuenta,A.renovado,A.FechaApertura,A.idEstadoCta Estado ,A.SaldoCuenta
	,A.MontoBloqueado
	FROM tCsAhorros AS A WITH(NOLOCK)  
	INNER JOIN #cliente AS c WITH(NOLOCK) ON A.codusuario = c.codusuario  
	WHERE 1 = 1  
	AND A.Fecha = @fecha  
	AND A.codusuario in (SELECT c.codusuario FROM #cliente WITH(NOLOCK) )  
	
	--============= CANCELADOS EN EL PERIODO
	INSERT INTO #PadronAhorros (Fecha,CodUsuario,CodCuenta,Renovado,FechaApertura,Estado,SaldoCuenta,MontoBloqueado,FechaCancelacion)					
  	SELECT A.FecCancelacion Fecha,A.CodUsuario,A.codcuenta,A.renovado
  		,A.FecApertura,A.EstadoCalculado Estado,0 SaldoCuenta,0 MontoBloqueado,FecCancelacion
	FROM tCsPadronAhorros AS A WITH(NOLOCK) 
	INNER JOIN #cliente AS c WITH(NOLOCK)  ON A.codusuario = c.codusuario  
	WHERE 1 = 1  
	AND A.FecCancelacion >= @fechaini  
	AND A.FecCancelacion <= @fecha  
	AND A.codusuario in (SELECT c.codusuario FROM #cliente WITH(NOLOCK) )  
	IF @Print = 1 PRINT '5- CARTERA DE AHORRO '                    


	--=========== Transacciones DEL CLIENTE	
	CREATE TABLE #TX (CodigoCuenta VARCHAR(35),Renovado INT,NroMov INT,Ingresos MONEY,Retiros MONEY)
	
	INSERT INTO #TX(CodigoCuenta,Renovado,NroMov,Ingresos,Retiros)
	SELECT T.codigocuenta, T.Renovado 
		,COUNT(CASE WHEN tipotransacnivel1 in ('I', 'E') THEN 1 END) AS nroMov  
		,SUM(CASE WHEN tipotransacnivel1 in ('I') THEN t.MontoTotalTran ELSE 0 END) AS Ingresos  
		,SUM(CASE WHEN tipotransacnivel1 in ('E') THEN t.MontoTotalTran ELSE 0 END) AS Retiros  
	FROM  tcstransacciondiaria AS t WITH(NOLOCK)
	WHERE 1=1 
		AND T.Fecha >= @fechaini 
		AND T.Fecha <= @fecha  
		AND tipotransacnivel3 not in (2,3,0,15,16,62,63)  
		AND  codoficina <> '999'  
		AND CodUsuario in (SELECT CodUsuario FROM #Cliente WITH(NOLOCK))  
	GROUP BY t.codigocuenta , T.Renovado   
	
	IF @Print = 1 PRINT '6- TRANSACCIONES DEL CLIENTE'                    
  
  
	 CREATE TABLE #CuentasCliente(Fecha SMALLDATETIME
								 ,CodUsuario VARCHAR(30)
								 ,NombreCompleto VARCHAR(200)
								 ,CodCuenta VARCHAR(30)
								 ,Estado VARCHAR(50)
								 ,SaldoCuenta MONEY 
								 ,MontoBloqueado MONEY
								 ,Desembolso_Inversion MONEY
								 ,NroMovimientos INT
								 ,Ingresos_Acumulado MONEY
								 ,Retiro_Acumulado MONEY
								 ,TipoProducto VARCHAR(50) 
								 ,FechaApertura SMALLDATETIME
								 ,FechaCancelacion SMALLDATETIME)
  
--************** UNIFICACION CARTERA  
	INSERT INTO #CuentasCliente 
	SELECT CA.Fecha
	,CA.CODUSUARIO
	,c.NombreCompleto
	,CA.codprestamo AS CodCuenta
	,ca.estado  
	,ca.SaldoCapital,0 MontoBloqueado 
	,ISNULL(ca.MontoDesembolso,0) as Desembolso_Inversion  
	,ISNULL(tx.nroMov ,0)   Total_Movimientos  
	,ISNULL(tx.ingresos ,0) Ingresos_Acumulado  
	,ISNULL(tx.retiros ,0)  Retiros_Acumulado   
	,CASE   WHEN substring(CA.codprestamo,5,1)='1'  THEN 'Comercial' 
			WHEN substring(CA.codprestamo,5,1)<>'1'  THEN 'Consumo'
			ELSE 'Otro' END tipo 
	,CA.FechaDesembolso
	,CA.FechaCancelacion    
	FROM #cartera AS CA WITH(NOLOCK) 
	INNER JOIN  #CLIENTE AS C  WITH(NOLOCK) ON CA.codusuario = c.codusuario  
	LEFT OUTER JOIN #tx AS tx WITH(NOLOCK) ON CA.codprestamo = tx.codigocuenta  

	  
--*************** UNIFICACION AHORRO  
    INSERT INTO #CuentasCliente 

	SELECT PA.Fecha,PA.CODUSUARIO, C.NombreCompleto
	,PA.codcuenta +'-0-' + cast(PA.renovado AS VARCHAR(3))CodCuenta
	,CASE WHEN PA.Estado='CA' THEN 'CUENTA ACTIVA'   
		WHEN PA.Estado='CC' THEN 'CERRADA'  
		WHEN PA.Estado='CI' THEN 'CUENTA INACTIVA'  
		WHEN PA.Estado='CB' THEN 'CUENTA BLOQUEADA PARCIAL'  
		WHEN PA.Estado='BA' THEN 'BLOQUEO ACTIVO'  
		WHEN PA.Estado='BC' THEN 'BLOQUEO CANCELADO'  
		WHEN PA.Estado='BP' THEN 'BLOQUEO PARCIAL'  
		WHEN PA.Estado='CE' THEN 'CUENTA EXTORNADA'  
		WHEN PA.Estado='CF' THEN 'CUENTA DPF VENCIDA'  
		WHEN PA.Estado='CP' THEN 'CUENTA PIGNORADA'  
		WHEN PA.Estado='CR' THEN 'CUENTA RETENIDA'  
		WHEN PA.Estado='CS' THEN 'CUENTA PARA SORTEO'  
		WHEN PA.Estado='CT' THEN 'CUENTA BLOQUEADA TOTAL'  
		WHEN PA.Estado='CV' THEN 'CUENTA DPF LISTA PARA CANCELAR'  
		ELSE 'REVISAR' end Estado 
	,ISNULL(PA.saldocuenta,0)saldocuenta  
	,PA.MontoBloqueado
	,ISNULL(PA.saldocuenta,0) as Desembolso_Inversion
	,ISNULL(tx.nroMov,0)Total_Movimientos
	,ISNULL(tx.ingresos,0)Ingresos_Acumulado  
	,ISNULL(tx.retiros,0)Retiros_Acumulado  
	,CASE WHEN substring(PA.codcuenta,5,1) = '1'  THEN 'A la vista' 
		  WHEN substring(PA.codcuenta,5,1) <> '1' THEN 'Plazo fijo'
		ELSE 'Otro' end tipo   ---select *
	,PA.FechaApertura
	,PA.FechaCancelacion	
	FROM #padronahorros  AS PA WITH(NOLOCK)  
	INNER JOIN  #CLIENTE AS C  WITH(NOLOCK) ON PA.codusuario = C.codusuario  
	LEFT OUTER JOIN #tx  AS tx WITH(NOLOCK) ON PA.codcuenta = tx.CodigoCuenta and tx.renovado=PA.renovado  
	  
    INSERT INTO #CuentasCliente(fecha,CodUsuario,CodCuenta,NombreCompleto,Estado,SaldoCuenta
    ,MontoBloqueado,Desembolso_Inversion,NroMovimientos,Ingresos_Acumulado,Retiro_Acumulado)
   SELECT @fecha, 'ZZZ',COUNT(*),'Total de Productos','Total'
    ,SUM(SaldoCuenta) as SaldoCuenta  
    ,SUM(MontoBloqueado)
    ,SUM(Desembolso_Inversion)
    ,SUM(NroMovimientos)
    ,SUM(Ingresos_Acumulado)
    ,SUM(Retiro_Acumulado)
    FROM  #CuentasCliente WITH(NOLOCK)
   
    
    SELECT *,@fecha FechaConsulta 
    FROM  #CuentasCliente WITH(NOLOCK)

    
	DROP TABLE #CuentasCliente 
	DROP TABLE #cliente  
	DROP TABLE #padronahorros  
	DROP TABLE #cartera  
	DROP TABLE #tx 

  
  
END;
GO