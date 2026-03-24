SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* FUNCION PARA EL CALCULO DEL LA PROBABILIDAD DE INCUMPLIMIENTO: Nuevo calculo de reservas IFRS9  
 ZCCU  2025.09.04  
 Se necesita dos parametros importantes: valor de puntos asignados por el tipo se sector: primario/secundario/terciario  
 y el puntaje crediticio  
*/  
CREATE FUNCTION [dbo].[fduProbabilidadIncumplimiento_IFRS9] (@Sector INT, @PuntajeCrediticio INT,@ETAPA INT)       
RETURNS DECIMAL(20,15)        
AS  
  
BEGIN  
---------------------------- PRUEBAS   
/*    
DECLARE @Sector INT  
SET @Sector=2  
  
DECLARE @PuntajeCrediticio INT  
SET @PuntajeCrediticio=453  
  
  
DECLARE @ETAPA VARCHAR(30)  
SET @ETAPA=2  
*/
------------------------------------  
--DECLARAR VARIABLES  
DECLARE @PuntajeSector INT  
DECLARE @Incumplimiento DECIMAL(20,15)  
  
SELECT @PuntajeSector = Valor FROM DBO.tCIFRS9SectorEconomicoPI WITH(NOLOCK) WHERE CodSectorEconomico = @Sector  
  
SET @Incumplimiento = 1/(1 + (EXP(-(@PuntajeSector - @PuntajeCrediticio)*(LOG(2)/40))))  
  
IF @ETAPA = 3  
 BEGIN   
 SET @Incumplimiento = 1  
 END  
  
--SELECT @Sector, @PuntajeCrediticio,@PuntajeSector,@Incumplimiento  
RETURN (@Incumplimiento)   
END
GO