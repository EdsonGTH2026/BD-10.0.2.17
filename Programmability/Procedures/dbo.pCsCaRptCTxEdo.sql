SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsCaRptCTxEdo
--EXEC pCsCaRptCTxEdo '20130831'
CREATE PROCEDURE [dbo].[pCsCaRptCTxEdo]
               ( @Fecha SMALLDATETIME )
AS  
--declare @fecha smalldatetime  
--set @fecha='20130831'  

--NULL	199138.8800	NO IDENTIFICADO  
SELECT u2.CodEstado CodProducto, --CodEstado
       SUM(d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldo,  
       CASE WHEN u2.DescUbiGeo IS NULL 
            THEN 'NO IDENTIFICADO' 
            ELSE CASE WHEN u2.DescUbiGeo = 'VERACRUZ DE IGNACIO DE LA LLAVE' 
                      THEN 'VERACRUZ'
                      ELSE u2.DescUbiGeo
                       END
             END NombreProdCorto--NombreEstado  
  FROM tCsCartera c WITH(NOLOCK)  
 INNER JOIN tCsCarteraDet     d WITH(NOLOCK) ON c.fecha = d.fecha AND c.codprestamo = d.codprestamo  
 LEFT OUTER JOIN tClOficinas  o WITH(NOLOCK) ON c.CodOficina = o.CodOficina
 LEFT OUTER JOIN tClUbigeo    u WITH(NOLOCK) ON o.CodUbiGeo  = u.CodUbiGeo
 LEFT OUTER JOIN tClUbigeo   u2 WITH(NOLOCK) ON u.CodEstado  = u2.CodEstado AND u2.codubigeotipo = 'ESTA'
 WHERE c.fecha   = @Fecha 
   AND c.cartera = 'ACTIVA'
 GROUP BY u2.CodEstado, u2.DescUbiGeo
 ORDER BY saldo desc--u2.CodEstado

/*
SELECT LEFT(v.CP1_Estado,6) CodProducto, --CodEstado
       SUM(d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldo,  
       CASE WHEN v.CP1_Estado IS NULL 
            THEN 'NO IDENTIFICADO' 
            ELSE CASE WHEN RIGHT(v.CP1_Estado,len(v.CP1_Estado)-7) = 'VERACRUZ DE IGNACIO DE LA LLAVE' 
                      THEN 'VERACRUZ'
                      ELSE RIGHT(v.CP1_Estado,len(v.CP1_Estado)-7)
                       END
             END NombreProdCorto--NombreEstado  
  FROM tCsCartera c WITH(NOLOCK)  
 INNER JOIN tCsCarteraDet      d WITH(NOLOCK) ON c.fecha = d.fecha AND c.codprestamo = d.codprestamo  
 INNER JOIN tCsPadronClientes  p WITH(NOLOCK) ON d.codusuario = p.codusuario
 LEFT OUTER JOIN vGnlUbigeo    v WITH(NOLOCK) ON ISNULL(p.CodUbiGeoDirFamPri, p.CodUbiGeoDirNegPri) = v.CodUbiGeo 
 WHERE c.fecha   = @Fecha 
   AND c.cartera = 'ACTIVA'
 GROUP BY v.CP1_Estado
*/



 
--select * from vGnlUbigeo
--SELECT * FROM tClOficinas WHERE CodOficina = '36'
--SELECT * FROM tClOficinas WHERE CodUbiGeo = '90200'
--36  290083
--35  290260
--update tcloficinas set codubigeo = '290083' where codoficina = '36'
--update tcloficinas set codubigeo = '290260' where codoficina = '35'
--90200
--select * from tcspadronclientes
--select * from tClUbigeo where codubigeo = '000029'
--select * from dbo.tClUbigeo where codubigeotipo = 'ESTA' and DescUbiGeo = 'TLAXCALA' --000029
-- select * from dbo.tClUbigeo where CodUbiGeo = '151027'     and CodEstado = 15 codubigeotipo = 'ESTA'
-- select * from dbo.tClUbigeo where CodUbiGeo = '90200'     and CodEstado = 15 codubigeotipo = 'ESTA'

--select * from dbo.tClUbigeo where CodEstado = '15' and codubigeotipo = 'ESTA'
 
 /*select o.*, u.codestado
  from tcloficinas o
 left outer join tClUbigeo     u with(nolock) on o.CodUbiGeo  = u.CodUbiGeo
 order by u.codestado
 */
 
 
 
GO