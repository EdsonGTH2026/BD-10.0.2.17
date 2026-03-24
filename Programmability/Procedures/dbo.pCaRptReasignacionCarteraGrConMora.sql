SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop proc pCaRptReasignacionCarteraGrConMora  
--exec pCaRptReasignacionCarteraGrConMora '98ABM2401771'  
--select * from pCaRptReasignacionCarteraGrConMora where maquina = '98ABM2401771'
CREATE PROCEDURE [dbo].[pCaRptReasignacionCarteraGrConMora](@Usuario CHAR(15))                                
AS                                
SET NOCOUNT ON   



--DECLARE @Usuario CHAR(15)
--SELECT @Usuario =  '98ABM2401771'
SELECT (case when len(c.CodOficina) = 1 then '0'+c.CodOficina else c.codoficina end)+ ' '+ o.NomOficina CodOficina,   
       c.CodPrestamo,   
       case when c.codgrupo is null then r.NombreCompleto else r.NombreGrupo end as NombrePrestamo,  
       --u1.NombreCompleto AS AsesorActual,  
       u1.NombreCompleto AS AsesorActual,  
       c.FechaDesembolso,  
       c.MontoDesembolso,  
       c.DiasMora DiasAtraso,  
       u2.NombreCompleto AS AsesorNuevo,
       u3.NombreCompleto AS Solicita,
       --case when s.PerfilReg is null then '' else 'GR' end AS Perfil,
       --c.FechaIngMora,
       case when (case when s.PerfilReg is null then '' else 'GR' end) = 'GR' AND c.FechaIngMora is not null then 'S' else 'N' end Tipo,
       (Select isnull(sum(cc.MontoCuota),0)  
          From tCaCuotasCli      cc 
         Inner Join tCaClConcepto p ON cc.CodConcepto = p.CodConcepto 
         Inner Join tCaCuotas     c ON c.CodPrestamo = cc.CodPrestamo AND c.SecCuota = cc.SecCuota AND c.NumeroPlan = cc.NumeroPlan
         Where r.CodPrestamo = cc.CodPrestamo  
           And c.EstadoCuota != 'CANCELADO'
           And cc.CodConcepto = 'CAPI') as CAPI, 
       (Select isnull(sum(cc.MontoCuota),0)
          From tCaCuotasCli      cc 
         Inner Join tCaClConcepto p ON cc.CodConcepto = p.CodConcepto 
         Inner Join tCaCuotas     c ON c.CodPrestamo = cc.CodPrestamo AND c.SecCuota = cc.SecCuota AND c.NumeroPlan = cc.NumeroPlan
         Where r.CodPrestamo = cc.CodPrestamo  
           And c.EstadoCuota != 'CANCELADO'
           And cc.CodConcepto = 'INTE') as INTE, 
       (Select isnull(sum(cc.MontoCuota),0)  
          From tCaCuotasCli      cc 
         Inner Join tCaClConcepto p ON cc.CodConcepto = p.CodConcepto 
         Inner Join tCaCuotas     c ON c.CodPrestamo = cc.CodPrestamo AND c.SecCuota = cc.SecCuota AND c.NumeroPlan = cc.NumeroPlan
         Where r.CodPrestamo = cc.CodPrestamo  
           And c.EstadoCuota != 'CANCELADO'
           And cc.CodConcepto = 'INPE') as INPE 
  INTO #CredGrMora           
  FROM tCaPrestamos c with (nolock)
 INNER JOIN tCaPrestamosReasignaTMP  r ON c.CodPrestamo = r.CodPrestamo  
 INNER JOIN tClOficinas              o ON c.CodOficina  = o.CodOficina  
 INNER JOIN tUsUsuarios             u1 ON c.CodAsesor   = u1.CodUsuario  
 INNER JOIN tUsUsuarios             u2 ON r.CodAsesor   = u2.CodUsuario  
 INNER JOIN tUsUsuarios             u3 ON u3.CodUsuario = @Usuario
 LEFT OUTER JOIN tsgusuarios         s ON r.CodAsesor   = s.CodUsuario  AND s.PerfilReg like '%GR%'
 WHERE r.Maquina      = @Usuario--'51ADMIN'           
   AND r.Seleccionado = 1  
   
SELECT * FROM #CredGrMora WHERE Tipo = 'S'
DROP TABLE #CredGrMora
   
--select * from tCaPrestamosReasignaTMP
--select * from tususuarios where codusuario = '98BMJ0208681        '
--select * from tCaPrestamosReasignaTMP  
--DELETE from tCaPrestamosReasignaTMP  
/*
SELECT r2.CodPrestamo, CC.CodConcepto, sum(CC.MontoCuota) SaldoCuota
  FROM tCaPrestamosReasignaTMP  r2 
 INNER JOIN tCaCuotasCli CC ON r2.CodPrestamo = CC.CodPrestamo  
 INNER JOIN tCaClConcepto P ON CC.CodConcepto = P.CodConcepto 
 INNER JOIN tCaCuotas     C ON C.CodPrestamo = CC.CodPrestamo AND C.SecCuota = CC.SecCuota AND C.NumeroPlan = CC.NumeroPlan
 WHERE C.EstadoCuota != 'CANCELADO'
   AND CC.CodConcepto IN ('CAPI','INTE', 'INPE')
 GROUP BY r2.CodPrestamo, CC.CodConcepto
*/

/*
insert into tCaPrestamosReasignaTMP values (1,'005-162-06-00-00359','HERNANDEZ LECHUGA CAYETANO', 'Individual', '01','VIGENTE','IPN','98ABM2401771','3HDM2001821' ,'5')
select * from tCaPrestamosReasignaTMP where codprestamo = '005-162-06-00-00359'
HERNANDEZ LECHUGA CAYETANO




select SecCuota, EstadoCuota,* from tCaCuotas where codprestamo = '005-162-06-00-00359'
select * from tCaCuotasCli where codprestamo = '005-162-06-00-00359'

select CodUsuario,CodAsesorAnt, FechaCambioAsesor, codAsesor, FechaIngMora, * from tCaPrestamos where codprestamo = '005-162-06-00-00359'
select * from tususuarios where codusuario ='5AQR2202861'    
select * from tususuarios where codusuario ='3HDM2001821' --ultimo
select perfilreg,* from tsgusuarios where codusuario ='3HDM2001821'
select perfilreg,* from tsgusuarios where codusuario ='5AQR2202861'
select perfilreg,* from tsgusuarios where codusuario ='10GHM1802921'
select * from tususuarios where codusuario ='5HLC0709541'

HERNANDEZ DAVILA MAYLLARI

       select case when NumeroPlan = 0 then 'Normal' else 'Conces.' end Plann, 
              SecCuota, FechaInicio, FechaVencimiento, FechaPago, DiasAtrCuota, EstadoCuota, Orden, 
              CodConcepto , DescConcepto, MontoCuota, MontoDevengado, MontoPagado, MontoCondonado, Saldo 
       from ( 
            select C.NumeroPlan, CC.SecCuota, C.FechaInicio, C.FechaVencimiento, C.FechaPago, C.DiasAtrCuota, C.EstadoCuota, 
                   P.Orden, CC.CodConcepto, P.DescConcepto, sum(CC.MontoCuota) MontoCuota,
                  sum(CASE WHEN II.Descuento = 0 AND C.EstadoCuota != 'CANCELADO' THEN CC.MontoCuota
                           ELSE CC.MontoDevengado
                      END) 
                   MontoDevengado, sum(CC.MontoPagado) MontoPagado, sum(CC.MontoCondonado) MontoCondonado, 
                   sum(CASE WHEN II.Descuento = 0 AND C.EstadoCuota != 'CANCELADO' THEN CC.MontoCuota
                            ELSE CC.MontoDevengado
                      END - CC.MontoPagado - CC.MontoCondonado) Saldo 
            from tCaCuotasCli CC
          inner join tCaClConcepto P on CC.CodConcepto = P.CodConcepto 
          inner join tCaCuotas C on C.CodPrestamo = CC.CodPrestamo and C.SecCuota = CC.SecCuota and C.NumeroPlan = CC.NumeroPlan
          LEFT OUTER JOIN tCaCuotas CANT ON C.CodPrestamo = CANT.CodPrestamo
                                        AND C.NumeroPlan = CANT.NumeroPlan
                                        AND C.SecCuota - 1 = CANT.SecCuota
          inner join tCaPrestamos PP ON PP.CodPrestamo = CC.CodPrestamo
          inner join tCaProdInteres II ON II.CodProducto = PP.CodProducto
          where CC.CodPrestamo = '005-162-06-00-00359'
          group by C.NumeroPlan, CC.SecCuota, C.FechaInicio, C.FechaVencimiento, C.FechaPago, C.DiasAtrCuota, C.EstadoCuota,P.Orden, CC.CodConcepto, P.DescConcepto 
       ) Z 
       order by 1 desc, 2, orden
*/
GO