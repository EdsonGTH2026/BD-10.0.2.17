SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext pCsAhBonoAhorro
--EXEC pCsAhBonoAhorro '20140201', '20140228'    
--DROP PROC pCsAhBonoAhorro    
--/*    
CREATE PROCEDURE [dbo].[pCsAhBonoAhorro]    
               ( @FecIni SMALLDATETIME ,    
                 @FecFin SMALLDATETIME )    
AS    
--*/    
/*    
DECLARE @FecIni  SMALLDATETIME    
DECLARE @FecFin  SMALLDATETIME    
    SET @FecIni  = '20131001'    
    SET @FecFin  = '20131031'    
--*/    
    
DECLARE @FecIniA SMALLDATETIME    
DECLARE @FecFinA SMALLDATETIME    
DECLARE @Periodo VARCHAR(6)    
    SET @Periodo = dbo.fduFechaATexto(@FecFin, 'AAAAMM')    
    SET @FecIniA = DATEADD(MONTH,-1,@FecIni)    
    SET @FecFinA = DATEADD(DAY, -1, CAST(@Periodo + '01' As SmallDateTime))    
    
--DATOS GENERALES MES ACTUAL    
 SELECT ah.CodOficina, o.NomOficina AS Sucursal,    
        ah.CodAsesor, c.NombreCompleto, ah.FechaApertura,    
        case when ah.FechaApertura >= @FecIni and ah.FechaApertura <= @FecFin    
             then 'S'    
             else 'N' end Nuevo,     
        ah.CodProducto, left(ah.CodProducto,1) TipoProd, plazo, ah.SaldoCuenta,     
        ah.SaldoCuenta SaldoCtaConRenov, ah.Renovado, ah.CodCuenta, Garantia, ah.CodPrestamo,    
        coalesce(ExistGar.NumGar,0) as TotalGar, ah.codusuario    
   INTO #BonoAh            
   FROM tcsahorros ah with(nolock)     
  INNER JOIN tcloficinas       o with(nolock) ON ah.codoficina  = o.codoficina    
  INNER JOIN tcspadronclientes c with(nolock) ON ah.codasesor   = c.codusuario      
  LEFT OUTER JOIN (select codigo, count(*) NumGar    
                     from tcsgarantias with(nolock)    
                    group by codigo     
                   ) as ExistGar ON ah.codprestamo = ExistGar.codigo    
  WHERE ah.Fecha = @FecFin    
  ORDER BY o.NomOficina    
--select * from #BonoAh    
    
--select * from tcsahorros    
--SELECT * FROM tcspadronclientes WHERE codprestamo = '030-123-06-04-00026'    
--select * from tcsgarantias where codigo = '030-123-06-04-00026'     
    
--SALDO GLOBAL (DPF Y A LA VISTA) POR SUCURSAL DEL MES ACTUAL    
SELECT CodOficina, sum(SaldoCuenta) SaldoGlobalMesAct    
  INTO #SaldoGlobalMesAct    
  FROM #BonoAh      
 GROUP BY CodOficina    
--select * from #SaldoGlobalMesAct    
    
--SALDO AHORRO PURO (DPF Y A LA VISTA)    
SELECT CodOficina, sum(SaldoCuenta) SaldoPuroMesAct    
  INTO #SaldoPuroMesAct    
  FROM #BonoAh      
 WHERE CodPrestamo IS NULL    
    OR TotalGar = 0       
 GROUP BY CodOficina    
    
--SALDO GLOBAL (DPF Y A LA VISTA) POR SUCURSAL DEL MES ANTERIOR     
 SELECT ah.CodOficina, sum(ah.SaldoCuenta) SaldoGlobalMesAnt    
   INTO #SaldoGlobalMesAnt        
   FROM tcsahorros ah with(nolock)     
  WHERE ah.Fecha = @FecFinA    
  GROUP BY ah.CodOficina    
--select * from #SaldoGlobalMesAnt      
    
--SALDO AHORRO PURO (DPF Y A LA VISTA) DEL MES ANTERIOR    
 SELECT ah.CodOficina, ah.SaldoCuenta, ah.CodPrestamo,    
        coalesce(ExistGar.NumGar,0) as TotalGar --sum(ah.SaldoCuenta) SaldoPuroMesAnt    
   INTO #SaldoPuroMesAntDet        
   FROM tcsahorros ah with(nolock)     
  LEFT OUTER JOIN (select codigo, count(*) NumGar    
                     from tcsgarantias with(nolock)    
                    group by codigo     
                   ) as ExistGar ON ah.codprestamo = ExistGar.codigo      
  WHERE ah.Fecha = @FecFinA --'20130831'    
        
 SELECT CodOficina, sum(SaldoCuenta) SaldoPuroMesAnt    
   INTO #SaldoPuroMesAnt    
   FROM #SaldoPuroMesAntDet      
  WHERE CodPrestamo IS NULL    
     OR TotalGar = 0       
  GROUP BY CodOficina    
      
--BONO ADMINISTRACION    
--drop table #BonoAdm  
SELECT DISTINCT b.CodOficina, b.Sucursal, SaldoGlobalMesAnt, SaldoPuroMesAnt, SaldoGlobalMesAct, SaldoPuroMesAct, Crecimiento.Crecimiento,    
       case when Crecimiento.Crecimiento > 0 then 'S'    else 'N' end PagaBonoAdm,    
       case when Crecimiento.Crecimiento > 0 then VarAdm else 0   end BonoAdm    
  INTO #BonoAdm                
  FROM #BonoAh b    
  LEFT OUTER JOIN (Select distinct sact.CodOficina, SUM(sact.SaldoGlobalMesAct-sant.SaldoGlobalMesAnt) Crecimiento    
      From #SaldoGlobalMesAnt sant     
                     left outer join #SaldoGlobalMesAct sact ON sact.CodOficina = sant.CodOficina    
                    Group By sact.CodOficina) AS Crecimiento ON b.CodOficina = Crecimiento.CodOficina    
  LEFT OUTER JOIN #SaldoGlobalMesAnt ant ON b.CodOficina = ant.CodOficina    
  LEFT OUTER JOIN #SaldoGlobalMesAct act ON b.CodOficina = act.CodOficina    
  LEFT OUTER JOIN #SaldoPuroMesAnt  pant ON b.CodOficina = pant.CodOficina    
  LEFT OUTER JOIN #SaldoPuroMesAct  pact ON b.CodOficina = pact.CodOficina    
  --LEFT OUTER JOIN tCsAhFactoresBono    f ON Crecimiento.Crecimiento between f.MtoMin and f.MtoMax    
  LEFT OUTER JOIN tCsAhFactoresBono    f ON act.SaldoGlobalMesAct between f.MtoMin and f.MtoMax    
 ORDER BY b.Sucursal    
 --select * from tCsAhFactoresBono    
 --select * from #BonoAdm    
    
--PARA LAS RENOVACIONES CONSIDERAR EL SALDO QUE AUMENTO LA CUENTA, EN CASO CONTRARIO NO SE CONSIDERA Y ES CERO EL SALDO DE LA CUENTA PARA EFECTOS DEL CALCULO DEL BONO    
SELECT b.CodOficina, b.Sucursal, b.CodAsesor, b.NombreCompleto Asesor, b.CodProducto, b.CodCuenta, b.Plazo, b.FechaApertura, b.SaldoCuenta,     
       b.CodUsuario, 'N' ObtenerDif    
       --b.SaldoCuenta - coalesce(a.SaldoCuenta,0) DifRenovacion, b.Renovado        
  INTO #Nuevos    
  FROM #BonoAh b    
  --LEFT OUTER JOIN tCsAhorros a ON b.CodCuenta = a.CodCuenta    
 WHERE b.Plazo   >= 180    
   AND b.TipoProd = '2'    
   AND b.Nuevo    = 'S'    
--drop table #Nuevos       
--select * from #Nuevos order by codusuario    
    
 select codusuario, max(FecApertura) FecApertura    
  into #FecAper    
  from tCsPadronAhorros     
 where codusuario IN (select distinct codusuario from #Nuevos) --'GOF1801461'     
   and fecapertura < @FecIni--'20130901'    
   and left(codproducto,1) = '2'    
 group by codusuario     
--select * from #FecAper    
--drop table #FecAper    
    
SELECT pa.codusuario, pa.codcuenta, pa.estadocalculado, pa.FecApertura, pa.FecCancelacion, pa.MonApertura    
  INTO #CtaAnt    
  FROM tCsPadronAhorros pa with (nolock)    
  LEFT OUTER JOIN #FecAper f ON f.codusuario = pa.Codusuario     
 WHERE pa.codusuario IN (select distinct codusuario from #Nuevos) --'GOF1801461'     
   AND LEFT(pa.codproducto,1) = '2'    
   AND pa.FecApertura = f.FecApertura    
--select * from #CtaAnt    
--drop table #CtaAnt    
    
--SE DESCARTAN LOS USUARIOS QUE TIENEN UNA CUENTA ANTERIOR ABIERTA    
DELETE FROM #CtaAnt WHERE EstadoCalculado = 'CA'    
    
SELECT f.codoficina, f.codusuario, sum(f.SaldoCuentaAbrio - f.SaldoCtaCerro) MontoRenovo    
  INTO #MtoRenov    
  FROM (SELECT n.codoficina, n.codusuario, sum(SaldoCuenta) SaldoCuentaAbrio,  sum(MonApertura) SaldoCtaCerro    
          FROM #Nuevos n    
          LEFT OUTER JOIN #CtaAnt a ON n.codusuario = a.codusuario    
         WHERE n.FechaApertura = a.FecCancelacion    
         GROUP BY n.codoficina, n.codusuario) AS f    
 GROUP BY f.codoficina, f.codusuario        
--drop table #MtoRenov    
--select * from #MtoRenov       
     
UPDATE #MtoRenov SET MontoRenovo = 0 WHERE MontoRenovo < 0     
--select * from #MtoRenov where codusuario = 'GOF1801461   '    
--select n.SaldoCuenta, * from #Nuevos where codusuario = 'GOF1801461   '    
--select * from #CtaAnt  where codusuario = 'GOF1801461   '    
    
UPDATE n    
   SET n.ObtenerDif = 'S'    
  FROM #Nuevos n, #MtoRenov r    
 WHERE n.CodUsuario = r.CodUsuario    
     
    
SELECT n.CodOficina, n.Sucursal, n.CodAsesor, n.Asesor, sum(t.SaldoCuenta) TotalAsesor    
  INTO #TotAsesor    
  FROM #Nuevos n    
  LEFT OUTER JOIN (SELECT CodUsuario, coalesce(sum(SaldoCuenta),0) SaldoCuenta    
                     FROM #Nuevos     
                    WHERE ObtenerDif = 'N'      
                    GROUP BY CodUsuario --Sin Renovacion    
                    UNION ALL    
                   SELECT CodUsuario, MontoRenovo SaldoCuenta    
                     FROM #MtoRenov     --Con Renovacion    
                   ) AS t ON n.Codusuario = t.CodUsuario    
 GROUP BY n.CodOficina, n.Sucursal, n.CodAsesor, n.Asesor                       
 --drop table #TotAsesor    
--select * from #Nuevos where codusuario in (select codusuario from #MtoRenov)    
--select * from #MtoRenov--9    
     
--SALDO SUCURSAL EN DPF NO MENORES A 180 DIAS MES ACTUAL    
--drop table #SaldoSucMesDPF180    
SELECT CodOficina, sum(TotalAsesor) SaldoSucMesDPF180    
  INTO #SaldoSucMesDPF180    
  FROM #TotAsesor     
 GROUP BY CodOficina      
--drop table #SaldoSucMesDPF180    
 --select * from #Nuevos    
 --select * from #SaldoSucMesDPF180    
     
--select * from #TotAsesor     
--BONO NUEVOS    
SELECT a.CodOficina, a.Sucursal, a.CodAsesor, a.Asesor, a.TotalAsesor, s.SaldoSucMesDPF180,     
       case when s.SaldoSucMesDPF180 > 50000 then 'S'    else 'N' end PagaBonoNvo,    
       case when s.SaldoSucMesDPF180 > 50000 then VarNvo else 0   end Porcentaje,    
       case when s.SaldoSucMesDPF180 > 50000 then a.TotalAsesor * FacNvo else 0 end BonoAsesor --(VarNvo/100) else 0 end BonoAsesor         
  INTO #BonoNvo  --8    
  FROM #TotAsesor a    
 INNER JOIN #SaldoSucMesDPF180 s ON a.CodOficina = s.CodOficina    
  LEFT OUTER JOIN tCsAhFactoresBono f ON a.TotalAsesor between f.MtoMin and f.MtoMax    
--select * from #BonoNvo    
    
 -- UNIENDO AMBOS BONOS       
--SELECT DISTINCT @FecFin Fecha, b.CodOficina, b.Sucursal, a.SaldoGlobalMesAnt, a.SaldoPuroMesAnt, a.SaldoGlobalMesAct, a.SaldoPuroMesAct, a.Crecimiento,    
--       case when a.PagaBonoAdm = 'S' then 'SI' else 'NO' end PagaBonoAdm, a.BonoAdm,    
--       coalesce(b.CodAsesor,'---') CodAsesor, coalesce(b.NombreCompleto,'----------') Asesor, --n.CodProducto, n.Plazo,     
--       coalesce(n.TotalAsesor,0) TotalAsesor, coalesce(n.SaldoSucMesDPF180,0) SaldoSucMesDPF180,    
--       case when n.PagaBonoNvo = 'S' then 'SI' else 'NO' end PagaBonoNvo, coalesce(n.Porcentaje,0) Porcentaje, coalesce(n.BonoAsesor,0) BonoAsesor     
--  FROM #BonoAh b    
--  LEFT OUTER JOIN #BonoAdm a ON b.CodOficina = a.CodOficina    
--  LEFT OUTER JOIN #BonoNvo n ON b.CodOficina = n.CodOficina and b.codasesor = n.codasesor    
-- ORDER BY b.Sucursal asc, n.CodAsesor asc--, n.SaldoCuenta desc    

 -- UNIENDO AMBOS BONOS       
SELECT DISTINCT /*@FecFin Fecha,*/ b.CodOficina, b.Sucursal, a.SaldoGlobalMesAnt, a.SaldoPuroMesAnt, a.SaldoGlobalMesAct, a.SaldoPuroMesAct, a.Crecimiento,    
       case when a.PagaBonoAdm = 'S' then 'SI' else 'NO' end PagaBonoAdm, cast(a.BonoAdm as money)BonoAdm,    
       ltrim(rtrim(coalesce(b.CodAsesor,'---'))) as CodAsesor, ltrim(rtrim(coalesce(b.NombreCompleto,'----------'))) as Asesor, --n.CodProducto, n.Plazo,     
       cast(coalesce(n.TotalAsesor,0) as money) as  TotalAsesor, cast(coalesce(n.SaldoSucMesDPF180,0) as money) as SaldoSucMesDPF180,    
       case when n.PagaBonoNvo = 'S' then 'SI' else 'NO' end PagaBonoNvo, coalesce(n.Porcentaje,0) Porcentaje, cast(coalesce(n.BonoAsesor,0) as money) BonoAsesor     
  FROM #BonoAh b    
  LEFT OUTER JOIN #BonoAdm a ON b.CodOficina = a.CodOficina    
  LEFT OUTER JOIN #BonoNvo n ON b.CodOficina = n.CodOficina and b.codasesor = n.codasesor    
 ORDER BY b.Sucursal asc, n.CodAsesor asc--, n.SaldoCuenta desc    
      
  
      
--select * from #BonoAh    
--select * from #BonoAdm    
--select * from #BonoNvo    
       
drop table #BonoAh      
drop table #SaldoGlobalMesAct    
drop table #SaldoGlobalMesAnt    
drop table #SaldoSucMesDPF180    
drop table #BonoNvo    
drop table #BonoAdm    
drop table #SaldoPuroMesAct    
drop table #SaldoPuroMesAntDet    
drop table #SaldoPuroMesAnt    
drop table #Nuevos    
drop table #FecAper    
drop table #CtaAnt    
drop table #MtoRenov    
drop table #TotAsesor    
    
/*    
SELECT b.CodOficina, b.Sucursal, b.CodAsesor, b.NombreCompleto Asesor, b.CodProducto, b.CodCuenta, b.Plazo, b.FechaApertura, b.Renovado,    
       b.SaldoCuenta, TotalAsesor.TotalAsesor, s.SaldoSucMesDPF180,     
       case when s.SaldoSucMesDPF180 > 50000 then 'S'    else 'N' end PagaBonoNvo,    
       case when s.SaldoSucMesDPF180 > 50000 then VarNvo else 0   end Porcentaje,    
       case when s.SaldoSucMesDPF180 > 50000 then TotalAsesor * FacNvo else 0 end BonoAsesor --(VarNvo/100) else 0 end BonoAsesor         
  INTO #BonoNvo     
  FROM #BonoAh b    
 INNER JOIN #SaldoSucMesDPF180 s ON b.CodOficina = s.CodOficina    
  LEFT OUTER JOIN (Select bo.CodOficina,bo.CodAsesor, sum(bo.SaldoCuenta) TotalAsesor    
                    From #BonoAh bo    
                   Where Plazo   >= 180    
                     And TipoProd = '2'    
                     And Nuevo    = 'S'    
                   Group By bo.CodOficina, bo.CodAsesor    
                  ) AS TotalAsesor ON b.CodOficina = TotalAsesor.CodOficina And b.CodAsesor = TotalAsesor.CodAsesor    
  LEFT OUTER JOIN tCsAhFactoresBono f ON TotalAsesor.TotalAsesor between f.MtoMin and f.MtoMax    
 WHERE Plazo   >= 180    
   AND TipoProd = '2'    
   AND Nuevo    = 'S'    
 ORDER BY b.Sucursal    
    
*/    
 /*    
SELECT a.CodOficina, a.Sucursal, a.SaldoGlobalMesAnt, a.SaldoGlobalMesAct, a.Crecimiento,     
       case when a.PagaBonoAdm = 'S' then 'SI' else 'NO' end PagaBonoAdm, a.BonoAdm,    
       coalesce(n.CodAsesor,'---') CodAsesor, coalesce(n.Asesor,'----------') Asesor, n.CodProducto, n.Plazo,     
       n.FechaApertura,     
       n.SaldoCuenta, n.TotalAsesor, n.SaldoSucMesDPF180,    
       case when n.PagaBonoNvo = 'S' then 'SI' else 'NO' end PagaBonoNvo, n.Porcentaje, n.BonoAsesor, n.CodCuenta, case when n.Renovado = 1 then 'S' else 'N' end Renovado    
  FROM #BonoAdm a    
  LEFT OUTER JOIN #BonoNvo n ON a.CodOficina = n.CodOficina    
 ORDER BY a.Sucursal asc, n.CodAsesor asc, n.SaldoCuenta desc    
*/    
/*    
SELECT DISTINCT a.CodOficina, a.Sucursal, a.SaldoGlobalMesAnt, a.SaldoGlobalMesAct, a.Crecimiento,     
       case when a.PagaBonoAdm = 'S' then 'SI' else 'NO' end PagaBonoAdm, a.BonoAdm,    
       coalesce(n.CodAsesor,'---') CodAsesor, coalesce(n.Asesor,'----------') Asesor, --n.CodProducto, n.Plazo,     
       --n.FechaApertura,     
       --n.SaldoCuenta,     
       n.TotalAsesor, n.SaldoSucMesDPF180,    
       case when n.PagaBonoNvo = 'S' then 'SI' else 'NO' end PagaBonoNvo, n.Porcentaje, n.BonoAsesor--,     
       --n.CodCuenta, case when n.Renovado = 1 then 'S' else 'N' end Renovado    
  FROM #BonoAdm a    
  LEFT OUTER JOIN #BonoNvo n ON a.CodOficina = n.CodOficina    
 ORDER BY a.Sucursal asc, n.CodAsesor asc--, n.SaldoCuenta desc    
*/     
    
/*    
select * from tCsAhFactoresBono    
      
 --select * from tcsahorros    
idTipoProd DescTipoProd    
1   Ahorro a la Vista                                    
2  Deposito a Plazo Fijo                             
3 Ordenes de Pago                                   
4 Compensación por Tiempo de Seguro    
select * from tAhClTipoProducto    
 select * from tcloficinas    
 select * from tcspadronclientes    
     
     
Comisión por Crecimiento Variable 2    
$       %    
0 _ 499,999     0.050    
500,000 _ 999,999   0.100    
1,000,000 _ 1,999,999  0.125    
2,000,000 _ 2,499,999  0.150    
2,500,000 _ 2,999,999  0.175    
3,000,000 _ 3,999,999  0.200    
4,000,000 >     0.250    
    
--drop table tCsAhFactoresBono    
CREATE TABLE tCsAhFactoresBono    
           ( MtoMin NUMERIC(16)   ,    
             MtoMax NUMERIC(16)   ,    
             VarAdm NUMERIC(16,2) ,    
             VarNvo NUMERIC(16,3) ,    
             FacNvo NUMERIC(16,4) )    
    
INSERT INTO tCsAhFactoresBono VALUES(0      , 499999, 250.00, 0.025, 0.0003)    
INSERT INTO tCsAhFactoresBono VALUES(500000 , 999999, 500.00, 0.075, 0.0005)    
INSERT INTO tCsAhFactoresBono VALUES(1000000,1999999, 750.00, 0.100, 0.0010)    
INSERT INTO tCsAhFactoresBono VALUES(2000000,2499999,1000.00, 0.125, 0.0013)    
INSERT INTO tCsAhFactoresBono VALUES(2500000,2999999,1250.00, 0.150, 0.0015)    
INSERT INTO tCsAhFactoresBono VALUES(3000000,3999999,1500.00, 0.175, 0.0018)    
INSERT INTO tCsAhFactoresBono VALUES(4000000,9999999,2000.00, 0.200, 0.0020)    
    
    
    
    
     /*case when Crecimiento.Crecimiento > 0     
            then case when Crecimiento.Crecimiento <= 499999      
                      then 250     
                      else case when Crecimiento.Crecimiento >= 500000 and Crecimiento.Crecimiento <= 999999     
                                then 500    
                                else case when Crecimiento.Crecimiento >= 1000000 and Crecimiento.Crecimiento <= 1999999     
                                          then 750    
                                          else case when Crecimiento.Crecimiento >= 2000000 and Crecimiento.Crecimiento <= 2499999     
                                                    then 1000    
                                                    else case when Crecimiento.Crecimiento >= 2500000 and Crecimiento.Crecimiento <= 2999999     
                                                              then 1250    
                                                              else case when Crecimiento.Crecimiento >= 3000000 and Crecimiento.Crecimiento <= 3999999     
            then 1500    
                                                                        else case when Crecimiento.Crecimiento >= 4000000    
                                                                                  then 2000    
                                                                                  else 0    
                                                                                  end    
                                                                        end    
                                                              end    
                                                    end    
                                          end        
                                end    
                      end              
            else 0    
            end BonoAdm    
*/    
    
          /*then case when s.SaldoSucMesDPF180 <= 499999    
                      then 0.050    
                      else case when s.SaldoSucMesDPF180 >= 500000 and s.SaldoSucMesDPF180 <= 999999     
                                then 0.100    
                                else case when s.SaldoSucMesDPF180 >= 1000000 and s.SaldoSucMesDPF180 <= 1999999     
                                          then 0.125    
                                          else case when s.SaldoSucMesDPF180 >= 2000000 and s.SaldoSucMesDPF180 <= 2499999     
                                                    then 0.150    
                                                    else case when s.SaldoSucMesDPF180 >= 2500000 and s.SaldoSucMesDPF180 <= 2999999     
                                                              then 0.175    
                                                              else case when s.SaldoSucMesDPF180 >= 3000000 and s.SaldoSucMesDPF180 <= 3999999     
                                                                        then 0.200    
                                                                        else case when s.SaldoSucMesDPF180 >= 4000000    
                                                                                  then 0.250    
                                                                                  else 0    
                                                                                  end    
                                                                        end    
                                                              end    
                                                    end    
                                          end        
                                end    
                      end                
            else 0    
            end Porcentaje,*/    
                
          /*then case when s.SaldoSucMesDPF180 <= 499999    
                      then TotalAsesor * (0.050/100)    
                      else case when s.SaldoSucMesDPF180 >= 500000 and s.SaldoSucMesDPF180 <= 999999     
                                then TotalAsesor * (0.100/100)    
                                else case when s.SaldoSucMesDPF180 >= 1000000 and s.SaldoSucMesDPF180 <= 1999999     
                                          then TotalAsesor * (0.125/100)    
                                          else case when s.SaldoSucMesDPF180 >= 2000000 and s.SaldoSucMesDPF180 <= 2499999     
                                                    then TotalAsesor * (0.150/100)    
                                                    else case when s.SaldoSucMesDPF180 >= 2500000 and s.SaldoSucMesDPF180 <= 2999999     
                                                              then TotalAsesor * (0.175/100)    
                                                              else case when s.SaldoSucMesDPF180 >= 3000000 and s.SaldoSucMesDPF180 <= 3999999     
                                                                        then TotalAsesor * (0.200/100)    
                                                                        else case when s.SaldoSucMesDPF180 >= 4000000    
                                                                         then TotalAsesor * (0.250/100)    
                                                                                  else 0    
                                                                                  end    
                                                                        end    
                                                              end    
                                                    end    
                                          end        
                                end    
                      end                
            else 0    
            end BonoAsesor*/    
    
    
 */    
    
       --ah.codusuario AS CveSocCte,    
       --ah.codcuenta AS Cuenta,    
           
 --INNER JOIN tcspadronahorros cl with(nolock) ON cl.codusuario=ah.codusuario    
 --INNER JOIN tcspadronclientes cl with(nolock) ON cl.codusuario=ah.codusuario    
--     
--tcspadronclientes    
    
/*    
 SELECT ah.CodOficina, o.NomOficina AS Sucursal,    
        ah.CodAsesor, c.NombreCompleto, ah.FechaApertura,    
        ah.CodProducto, left(ah.CodProducto,1) TipoProd,    
        plazo, ah.SaldoCuenta, ah.*    
   --INTO #BonoAh            
   FROM tcsahorros ah with(nolock)     
  INNER JOIN tcloficinas       o with(nolock) ON ah.codoficina = o.codoficina    
  INNER JOIN tcspadronclientes c with(nolock) ON ah.codasesor  = c.codusuario      
  WHERE ah.Fecha = '20130930'    
    --AND ah.CodOficina = '2'    
    --AND ah.CodAsesor = 'BCM2304901'    
    AND left(ah.CodProducto,1) = '2'     
    AND ah.plazo >= 180    
  ORDER BY o.NomOficina    
  select distinct codcuenta from tcsahorros where codusuario = 'RAT1510821'    
  select * from tcspadronclientes where codusuario = 'RAT1510821'    
      
select * from tcsahorros where codcuenta in ('002-110-06-2-1-00027','002-110-06-2-9-00015','002-203-06-2-5-00478')    
and fecha = ' ah.Fecha = '20130930''    
  ROMUALDO ADAYA TERESA        
      
  */ 
GO