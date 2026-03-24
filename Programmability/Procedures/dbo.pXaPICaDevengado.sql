SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*********************************
Procedure:          dbo.pXaPICaDevengado
Create Date:        sin definir
Author:             Sistemas-App
Description:        Calcula el devengado total en el mes de créditos menores a 90 días de atraso.
Call by:            [FinamigoConsolidado.pXaPICaDevengado]
                    [App FINAMIGO]
                    [APP]
Used By:            [App FINAMIGO]
Parameter(s):       Ninguno
Usage:              EXEC pXaPICaDevengado                            
**********************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
sin definir         SISTEMAS-FINAMIGO    Consulta devengado total

2023-07-18          SISTEMAS-zchavezd    Se optiza, generando tablas temporales de tcsCartera y tcsCarteraDet
*********************************/
CREATE procedure [dbo].[pXaPICaDevengado]  
as  
SET NOCOUNT ON        
BEGIN
declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
declare @fecini smalldatetime  
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' 
 
CREATE TABLE #CA (FECHA SMALLDATETIME,CODPRESTAMO VARCHAR(30),CODFONDO TINYINT)
INSERT INTO #CA
select FECHA,CODPRESTAMO,CODFONDO 
from tcscartera C with(nolock) 
where fecha>=@fecini and fecha<=@fecha
and c.codoficina not in('97','231','98','999') 
and c.estado='VIGENTE'  
and c.NroDiasAtraso<=89 

CREATE TABLE #CADET (FECHA SMALLDATETIME,CODPRESTAMO VARCHAR(30),INTERESDEVENGADO MONEY)
INSERT INTO #CADET
select FECHA,CODPRESTAMO,interesdevengado
from tcscarteradet with(nolock) 
where fecha>=@fecini and fecha<=@fecha
AND CODPRESTAMO IN (SELECT CODPRESTAMO FROM #CA WITH(NOLOCK))
 
 ---SP_HELPINDEX  tcscarteraDET
 -- 00:00:23 segundos
select sum(t.interesdevengado) total  
,sum(case when c.codfondo=20 then t.interesdevengado*0.7 when c.codfondo=21 then t.interesdevengado*0.75 else 0 end) progresemos  
,sum(case when c.codfondo=20 then t.interesdevengado*0.3 when c.codfondo=21 then t.interesdevengado*0.25 else t.interesdevengado end) finamigo  
FROM #CA C WITH(NOLOCK)
inner join #CADET t with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo 

DROP TABLE #CA
DROP TABLE #CADET

---4:22 minutos
--select sum(t.interesdevengado) total  
--,sum(case when c.codfondo=20 then t.interesdevengado*0.7 when c.codfondo=21 then t.interesdevengado*0.75 else 0 end) progresemos  
--,sum(case when c.codfondo=20 then t.interesdevengado*0.3 when c.codfondo=21 then t.interesdevengado*0.25 else t.interesdevengado end) finamigo  
--from tcscarteradet t with(nolock)  
--inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo  
--where c.NroDiasAtraso<=89 and t.fecha>=@fecini and t.fecha<=@fecha  
--and c.codoficina not in('97','231','98') and c.estado='VIGENTE' 

END 
GO