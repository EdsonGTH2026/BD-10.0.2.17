SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--+++++++++++++++++++   OPERACION CARTERA: Transacciones OPR / INGRESOS EFECTIVO      +++++++++++++++++++++++++++
--TABLA DE CONSULTA: SE GENERA EN EL CIERRE DIARIO
--SI SE INGRESA UNA OPERACIÓN NO DETIENE LA OPERACIÓN, YA QUE ES DE CONSULTA EN 2.17
--zccu

CREATE PROCEDURE [dbo].[pCsAlertaMontosRelevantesPLD] 
AS  
SET NOCOUNT ON                      

BEGIN 

	DECLARE @fecha SMALLDATETIME
	DECLARE @fecini SMALLDATETIME
	DECLARE @TipoCambio DECIMAL(20,10)

	SELECT @fecha  = fechaconsolidacion FROM vcsfechaconsolidacion WITH(NOLOCK)---'20251124'--
	SET @fecini = @fecha--'20250101'--

	DELETE FROM [10.0.2.14].[FinamigoPLD].[DBO].tAlertaMontosRelevantes WHERE Fecha=@fecha
	insert into [10.0.2.14].[FinamigoPLD].[DBO].tAlertaMontosRelevantes (Fecha,codusuario,
	CodOficina,codigocuenta,renovado,codsistema,Instrumento,MontoDispersado,MontoEquivalente,TipoCredito,
	TipoReporte,OrganoSupervisor,SujetoObligado,LocalidadSucursal,Sucursal,TipoOperacion,InstrumentoMonetario,
	NroContrato,Monto,Moneda,FechaOperacion,FechaDetencionOperacion,Pais,TipoPersona,nombres,paterno,materno,
	usCURP,fechaNacimiento,Direccion,Colonia,CodLocalidad,telefonomovil,ActividadEconomica,
	rptaRegla,DictamenObservacion,FechaAlta)

	SELECT @fecha Fecha,cl.codusuario,P.CodOficina,t.codigocuenta,t.renovado,codsistema--,t.nombrecliente
	--,CASE WHEN codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' THEN 'Pago de credito efectivo'
	--			WHEN codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB') THEN 'Liquidación de credito efectivo'
	--			WHEN codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='OPR' THEN 'Desembolso OPR'
	--			WHEN codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='EFEC' THEN 'Desembolso efectivo'
	--			ELSE '' END Tipooperación
	,CASE WHEN codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' THEN 'Efectivo'
		  WHEN codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB') THEN 'Efectivo'
				WHEN codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='OPR' THEN 'OPR'
				WHEN codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='EFEC' THEN 'Efectivo'
				ELSE '' END Instrumento
	,CASE WHEN  codsistema='CA' and tipotransacnivel3 = 102 THEN ISNULL(sp.montoDesembolsoReal,t.montototaltran)
		  ELSE ISNULL(t.montototaltran,0)END MontoDispersado	
	,(tc.tipoCambio*7500) MontoEquivalente
	,CASE WHEN ISNULL(sp.montoDesembolsoReal,0)=0 THEN 'ORGANICA' ELSE 'ANTICIPADA' END 'TipoCredito'
	--,1 rptaRegla
	--,''DictamenObservacion
	--,null FechaRespuesta
	--,@fecha FechaSistema
	-----
	,'1' 'TipoReporte'
	,'001002' 'OrganoSupervisor'
	,'027004' 'SujetoObligado'
	,'01001002' 'LocalidadSucursal'
	,'98' 'Sucursal'
	,CASE WHEN codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' THEN '09'--'Pago de credito efectivo'
				WHEN codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB') THEN '09'--'Liquidación de credito efectivo'
				WHEN codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='OPR' THEN '07'--'Desembolso OPR'
				WHEN codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='EFEC' THEN '08'--'Desembolso efectivo'
				ELSE 'REVISAR' END 'TipoOperacion'
	,'01' 'InstrumentoMonetario'--- TODO EFECTIVO
	,REPLACE(t.codigocuenta,'-','')'NroCuenta'	
	,CASE WHEN  codsistema='CA' and tipotransacnivel3 = 102 THEN ISNULL(sp.montoDesembolsoReal,t.montototaltran)
		  ELSE ISNULL(t.montototaltran,0)END 'Monto'
	,'1' Moneda
	,dbo.fdufechaatexto(t.fecha,'AAAAMMDD')'FechaOperacion'
	,dbo.fdufechaatexto(@fecha,'AAAAMMDD')'FechaDetencionOperacion'
	,CASE WHEN CL.CodPais='4024' THEN 'MX' ELSE '' END 'Pais'
	,CASE WHEN cl.CodTPersona='01' THEN 1 ELSE 2 END 'TipoPersona'
	,cl.nombres,cl.paterno,cl.materno
	,CL.usCURP
	,CASE WHEN CL.CodTPersona='01' THEN dbo.fdufechaatexto(fechanacimiento,'AAAAMMDD')ELSE '' END fechaNacimiento
		
	,isnull([dbo].[fduLimpiaCadenavs1](cl.direcciondirfampri),[dbo].[fduLimpiaCadenavs1](cl.direcciondirnegpri))-- x_calle
	+ ' '+ UPPER(case when NumExtFam is null or rtrim(ltrim(NumExtFam))=''
	  then (case when NumExtNeg is null or ltrim(rtrim(NumExtNeg))='' 
										or rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtNeg,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#','')))='sn'
				 then 'S/N' 
				 else 
					case when substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtNeg,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5) ='' then
						'S/N' 
					else
						substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtNeg,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5)
					end 
				 end)
	  when rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#','')))='sn' 
			or rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#','')))='SINNUMERO' 
			then 'S/N'
	  else 
		case when substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5)=''
		then 'S/N'
		else substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5) end 
	  end) 
	+' CP '+isnull(cl.codPostalFam,cl.codpostalNeg) 'Direccion'
,u.descubigeo  'Colonia' 
--,cast(u.codmunicipio as int) 'Municipio'
--,es.descubigeo 'EstaCliente',mu.descubigeo 'MuniCliente'
	,lo.CodLocalidad
	,cl.telefonomovil
	,''as 'ActividadEconomica'
	,1 rptaRegla
	,''DictamenObservacion
	,@fecha FechaAlta
	FROM tcstransacciondiaria t WITH(NOLOCK)
	LEFT OUTER JOIN  [10.0.2.14].Finmas.dbo.tTcTipoCambio tc ON t.Fecha -1 >= tc.periodo and t.Fecha-1 <= tc.periodo
	LEFT OUTER JOIN  [10.0.2.14].[FINMAS].[DBO].[TCAPRESTAMOS] p ON p.codprestamo = t.CodigoCuenta
	LEFT OUTER JOIN  [10.0.2.14].[FINMAS].[DBO].[tcasolicitudrenovacionanticipadaproce] sp ON sp.codsolicitud=p.codsolicitud and sp.codoficina=p.codoficina
	INNER JOIN tcsPadronclientes cl on cl.codusuario=t.codusuario
	left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
	left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
	left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
	left outer join tClLocalidadPLD lo with(nolock) on lo.nombreLocalidad=mu.descubigeo and lo.estado=(case when es.descubigeo='MÉXICO' then 'ESTADO DE MEXICO' else es.descubigeo end)
	WHERE t.fecha>=@fecini
	AND t.fecha<=@fecha
	AND codsistema='CA'
	AND tipotransacnivel3 not in(2,3,0)
	AND t.codoficina<>'999'
	AND tipotransacnivel2 in ('OPR','EFEC')
	AND EXTORNADO = 0
	AND (CASE WHEN  codsistema='CA' and tipotransacnivel3 = 102 THEN ISNULL(sp.montoDesembolsoReal,t.montototaltran)
	ELSE ISNULL(t.montototaltran,0)END >= (tc.tipoCambio*7500))
	AND t.CodigoCuenta NOT IN (SELECT CUENTA FROM tCreditosExcluidos WITH(NOLOCK))

END

GO