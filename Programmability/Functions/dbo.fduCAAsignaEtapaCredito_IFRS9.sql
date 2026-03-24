SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--UNA FUNCION PARA ASGINAR ETAPA A UN CRÉDITO  
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--ZCCU  2025.08.15 Se asigna la etapa de acuerdo a los dias de atraso que se tienen al corte de cada mes. 
--					y esa etapa se mantiene durante el mes, aun cuando varie sus dias de atraso.
--ZCCU 20260218 Se cambia para que se calcule la etapa del credito de forma diaria, de acuerdo a los dias de atraso.
--				esta cambiará de forma diaria de acuerdo a los dias de atraso del crédito.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


CREATE FUNCTION [dbo].[fduCAAsignaEtapaCredito_IFRS9] (@CodPrestamo VARCHAR(35),@Fecha SMALLDATETIME)        
RETURNS varchar(2000)        
AS  
BEGIN  
-------------------PRUEBAS   
--DECLARE @CodPrestamo VARCHAR(30)  
--SET @CodPrestamo = '492-170-06-06-00471'--'431-370-06-00-04046'  
  
--DECLARE @Fecha SMALLDATETIME  
--SET @Fecha = '2026-02-04 00:00:00'--'20250820'--  
--------------------------  
  
  
DECLARE @FechaDesembolso SMALLDATETIME  
DECLARE @EtapaInicial INT  
DECLARE @NroAtrasoInicial INT  
  
DECLARE @EtapaActual INT  
DECLARE @SiguienteEtapa INT  
DECLARE @EtapaFinal INT  
DECLARE @SiguiEtapa_nroDias INT  
DECLARE @FechaEtapa SMALLDATETIME  
DECLARE @FechaEtapa3 SMALLDATETIME  
DECLARE @RESULTADO VARCHAR(2000)  
DECLARE @FechaEtapa3_FINAL VARCHAR(20)  
  
SELECT @FechaDesembolso = Desembolso FROM tCsPadronCarteraDet WITH(NOLOCK)WHERE CodPrestamo = @CodPrestamo  
--SELECT @FechaDesembolso  
SELECT @NroAtrasoInicial = 0  
  
IF  @NroAtrasoInicial >= 90  
 BEGIN   
  SET @EtapaInicial = 3--'ETAPA 3'  
  SET @SiguienteEtapa = 3  
 END  
IF @NroAtrasoInicial >= 31 AND @NroAtrasoInicial <= 89  
 BEGIN   
  SET @EtapaInicial = 2--'ETAPA 2'  
  SET @FechaEtapa3_FINAL = 'NO APLICA'  
  SET @SiguienteEtapa = 2  
 END  
IF @NroAtrasoInicial >= 0 AND @NroAtrasoInicial <= 30  
 BEGIN   
  SET @EtapaInicial = 1--'ETAPA 1'  
  SET @FechaEtapa3_FINAL = 'NO APLICA'  
  SET @SiguienteEtapa = 1  
 END  
--select @EtapaInicial   
   
DECLARE  @PadronEtapa TABLE (Row int IDENTITY(1,1),Fecha SMALLDATETIME,CodPrestamo VARCHAR(30),NroDiasAtraso INT)  
INSERT INTO @PadronEtapa  
SELECT    
Fecha,CodPrestamo,NroDiasAtraso---,'sin definir' Estado   
FROM tCsCartera C WITH(NOLOCK)  
WHERE 1=1
--and Fecha IN (SELECT UltimoDia from tclperiodo with(nolock))  
and Fecha >= @FechaDesembolso  
and Fecha <= @Fecha  
AND CodPrestamo = @CodPrestamo  
ORDER BY Fecha ASC  
  
 --- select * from @PadronEtapa
  
DECLARE @n INT  
DECLARE @i INT  
  
SELECT @n = COUNT(*) FROM @PadronEtapa   
SET @i = 1  
  
--DECLARE @EtapaActual INT  
--DECLARE @SiguienteEtapa INT  
--DECLARE @EtapaFinal INT  
--DECLARE @SiguiEtapa_nroDias INT  
--DECLARE @FechaEtapa SMALLDATETIME  
--DECLARE @FechaEtapa3 SMALLDATETIME  
--DECLARE @RESULTADO VARCHAR(2000)  
--DECLARE @FechaEtapa3_FINAL VARCHAR(20)  
  
  
SET @EtapaActual = @EtapaInicial  
  
WHILE @i <= @n  
 BEGIN   
   
 SELECT @SiguiEtapa_nroDias = NroDiasAtraso, @FechaEtapa = FECHA FROM @PadronEtapa Where ROW = @i  
   
   
 IF @EtapaActual = 3--'ETAPA 3'  
  BEGIN   
   IF @SiguiEtapa_nroDias = 0
		BEGIN   
		SET @SiguienteEtapa = 1
		END 
   ELSE	
     BEGIN
     SET @SiguienteEtapa = 3--'ETAPA 3'  
      
     END	
   --SET @EtapaActual = @SiguienteEtapa 
  -- BREAK   
  END  
    
  ELSE IF @EtapaActual = 2--'ETAPA 2'  
  BEGIN
       IF @SiguiEtapa_nroDias = 0
		BEGIN   
		SET @SiguienteEtapa = 1
		END  		
	   IF @SiguiEtapa_nroDias > 0 AND @SiguiEtapa_nroDias <= 89  
		BEGIN   
		SET @SiguienteEtapa = 2--'ETAPA 2'  
		END    
	   IF  @SiguiEtapa_nroDias >= 90  
		BEGIN   
		SET @SiguienteEtapa = 3--'ETAPA 3'  
		SET @FechaEtapa3 = @FechaEtapa  
		END     
  END  
     
 ELSE --IF @EtapaActual = 1--'ETAPA 1'  
  BEGIN   
   IF  @SiguiEtapa_nroDias >= 90  
    BEGIN   
    SET @SiguienteEtapa = 3--'ETAPA 3'  
    SET @FechaEtapa3 = @FechaEtapa  
    END  
   IF @SiguiEtapa_nroDias >= 31 AND @SiguiEtapa_nroDias <= 89  
    BEGIN   
    SET @SiguienteEtapa = 2--'ETAPA 2'  
    END  
   IF @SiguiEtapa_nroDias >= 0 AND @SiguiEtapa_nroDias <= 30  
    BEGIN   
    SET @SiguienteEtapa = 1--'ETAPA 1'  
    END  
  END  
   
 SET @EtapaActual = @SiguienteEtapa  
 SET @i = @i + 1  
   
 END   
  
SET @EtapaFinal = @SiguienteEtapa  
SET @FechaEtapa3_FINAL = dbo.fdufechaatexto(@FechaEtapa3,'AAAAMMDD')  
  
IF @FechaEtapa3_FINAL IS NULL  
 BEGIN   
 SET @FechaEtapa3_FINAL = 'NO APLICA'  
 END  
 
SET @RESULTADO = 'Etapa:'+ LTRIM(STR(@EtapaFinal)) + '_Fecha Etapa 3:' + LTRIM(@FechaEtapa3_FINAL) + '.'  
--SELECT  @RESULTADO  
  
  
 RETURN (@RESULTADO)   
END  
GO