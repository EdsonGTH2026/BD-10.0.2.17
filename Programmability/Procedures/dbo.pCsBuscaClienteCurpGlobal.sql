SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*------ BUSQUEDA DE CUENTAS POR CURP 
VER. ZCCU_2025.10.01 Se crear el sp para BUSCAR todos los usuarios un mismo cliente,buscado por Curp
*/  
CREATE PROCEDURE [dbo].[pCsBuscaClienteCurpGlobal] (@curp varchar(18))  
AS 

BEGIN
SET NOCOUNT ON  
    
		----declare @curp varchar(18)  
		----set @curp = 'CAAI670101MGTNRS15'--CAAI670101MGTNRS15  AIVM870512MMCRRR08
		  

		--------------------  
		DECLARE @Print AS BIT                  
		SET @Print = 0
		
		declare @fecha smalldatetime  
        		--set @fecha = '20250531'  
		SELECT @fecha = fechaconsolidacion FROM vcsfechaconsolidacion WITH(NOLOCK)
           
		IF @Print = 1 print 'INICIO ' + convert(varchar, getdate())                    


		IF ISNULL(@fecha,'') = ''  
		BEGIN  
			IF @Print = 1 print '1- Fecha no ingresada, se ajusta la busqueda al mes en curso'                    
			SELECT @fecha = fechaconsolidacion FROM vcsfechaconsolidacion WITH(NOLOCK)
		END 

		----------- COINCIDENCIA POR CURP CLIENTE  
		SELECT  pc.uscurp, pc.uscurpbd, pc.codusuario, pc.NombreCompleto, ' ' as perfilTrans, ' ' as montoTrans,codorigen,FechaIngreso ingreso  
		INTO #cliente
		-----FROM tCsPadronClientes as pc WITH(NOLOCK)
		FROM tCsConsolidaClientes as pc WITH(NOLOCK)
		WHERE 1=1  
		AND (uscurp = @curp or uscurpbd = @curp)  
		IF @Print = 1 print '2- Coincidencia de cliente por Curp'                    

		------------- RIESGO CLIENTE  
		CREATE TABLE #riesgoCliente(CODUSUARIO varchar(30),gradoRiesgo varchar(30) ,CODSISTEMA varchar(10),FECHAACTUALIZACION smalldatetime)  
		insert into #riesgoCliente  
		exec [10.0.2.14].Finmas.dbo.pCsUltimoGradoRiesgoCurp @Fecha ,@Curp   
		

		IF @Print = 1 print '3- Riesgo del cliente'                    

		------------- FECHA APERTURA - comentario: se solicita la fecha de relación comercial con el cliente  
		SELECT CodUsuario,MIN(FecApertura) FeRelacionComercial
		INTO #RelacionComercial
		FROM tCsPadronAhorros WITH(NOLOCK)
		WHERE CodUsuario IN (SELECT CodUsuario FROM #cliente WITH(NOLOCK))
		GROUP BY CodUsuario
		IF @Print = 1 print '4- Inicio de Relacion Comercial / primer contrato'                    

		-------- CONSULTA GENERAL CLIENTE  

		SELECT @fecha  FechaConsulta, c.codusuario CodUsuario
		,  c.uscurp CURP, c.nombrecompleto NombreCompleto 
		,isnull( r.gradoRiesgo,'Sin Grado Riesgo')GradoRiesgo  
		,CASE WHEN CODSISTEMA = 'IN' THEN 'INICIAL'   
		WHEN CODSISTEMA = 'MS' THEN 'MENSUAL'  
		WHEN CODSISTEMA = 'SM' THEN 'SEMESTRAL'  
		WHEN CODSISTEMA = 'AH' THEN 'APERTURA'  
		ELSE '' END TipoRiesgo  
		, isnull(ingreso,RE.FeRelacionComercial)Ingreso  
		, '' as PerfilTransaccional
		, '' as MontoTransaccional    
		from #cliente as c with(nolock)  
		left outer join #riesgocliente as r with(nolock) on c.CodOrigen = r.codusuario  
		left outer join #RelacionComercial Re WITH(NOLOCK) ON c.codusuario = RE.codusuario 

		DROP TABLE #cliente  
		DROP TABLE #riesgoCliente  
		DROP TABLE #RelacionComercial  
		
END;
GO