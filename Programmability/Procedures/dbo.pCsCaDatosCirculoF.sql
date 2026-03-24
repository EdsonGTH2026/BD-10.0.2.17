SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext pCsCaDatosCirculoF
CREATE PROCEDURE [dbo].[pCsCaDatosCirculoF]
              ( @Fecha  varchar(11))
AS

--DECLARE @Fecha varchar(11)
--    SET @Fecha = '20140228' 
DECLARE @primerdia varchar(11)
 SELECT @primerdia=primerdia FROM tclperiodo WHERE ultimodia=@Fecha 
 
CREATE TABLE #Nombres
           ( Tipo CHAR(15),
             Fecha SMALLDATETIME,
             CodPrestamo VARCHAR(25),
             CodUsuario CHAR(15),
             Cancelacion SMALLDATETIME,
             CodUsuarioOrigen CHAR(15))
  
INSERT INTO #Nombres
/***************  vINTFNombreCartera  ******************/  
SELECT DISTINCT 'Cartera' AS Tipo, cd.Fecha, cd.CodPrestamo, cd.CodUsuario, '19000101' Cancelacion, '' CodUsuarioOrigen
  FROM tCsPadronClientes pc
 INNER JOIN tCsCarteraDet cd with(nolock) ON pc.CodUsuario = cd.CodUsuario  
 INNER JOIN tcscartera     c with(nolock) ON c.codprestamo = cd.codprestamo AND c.fecha = cd.fecha  
 WHERE cd.Fecha = @Fecha  
 --19184
union  
/***************  vINTFNombreAvales  ******************/  
SELECT 'Aval' AS Tipo, cd.Fecha, cd.CodPrestamo, cd.CodUsuario, '19000101' Cancelacion, '' CodUsuarioOrigen   
  FROM tCsPadronClientes pc with(nolock) 
 INNER JOIN (SELECT ca.Fecha, mg.Codigo AS CodPrestamo, pa.CodUsuario  
                   , mg.EstGarantia,ca.FechaDesembolso  
                FROM tCsMesGarantias mg with(nolock)   
               INNER JOIN tCsClientes ct with(nolock) ON mg.DocPropiedad = ct.CodOrigen   
               INNER JOIN tCsPadronClientes pa with(nolock) ON ct.CodUsuario = pa.CodOriginal   
               INNER JOIN tCsCartera ca with(nolock) ON mg.Fecha=ca.Fecha-->0seg  
                 AND mg.Codigo = ca.CodPrestamo  
               WHERE ca.Fecha = @Fecha -->1253
                 AND (ca.nrodiasacumulado > 0)  
              ) cd ON pc.CodUsuario = cd.CodUsuario  
WHERE cd.EstGarantia NOT IN ('INACTIVO')
union  
/***************  vINTFNombreCancelados  ******************/  
SELECT cd.Tipo  --'Cancelados' AS Tipo  
     , cd.Fecha, cd.CodPrestamo, cd.CodUsuario, cd.Cancelacion, cd.CodUsuarioOrigen
  FROM tCsPadronClientes pc with(nolock)
 INNER JOIN  
         (  
          /*titulares*/  
          --select * from tCsPadronCarteraDet where codprestamo = '019-162-06-05-00213' and fecha = '20131031' VLA0101631     
               SELECT     CAST(dbo.fduFechaATexto(DATEADD([Month], 1, CAST(dbo.fduFechaATexto(Cancelacion, 'AAAAMM') + '01' AS SmallDateTime)), 'AAAAMM')   
               + '01' AS SmallDateTime) - 1 AS Fecha, Cancelacion, CodPrestamo, CodUsuario,tCsPadronCarteraDet.desembolso FechaDesembolso, 'CanceladosT' tipo, CodUsuario CodUsuarioOrigen
               FROM tCsPadronCarteraDet with(nolock)  
               WHERE (EstadoCalculado = 'CANCELADO')  
               and tCsPadronCarteraDet.cancelacion>=@primerdia  and tCsPadronCarteraDet.cancelacion<=@fecha  
--               and codprestamo='026-156-06-00-00400'  
             union  
             /*avales*/  
             SELECT @fecha fecha, tCspadronCarteradet.cancelacion,tCsMesGarantias.Codigo AS CodPrestamo  
             , tCsPadronClientes.CodUsuario,tCsPadronCarteraDet.desembolso FechaDesembolso, 'CanceladosA' tipo, tCsPadronCarteraDet.codusuario  CodUsuarioOrigen
                FROM tCsMesGarantias with(nolock)  
                INNER JOIN tCsClientes with(nolock) ON tCsMesGarantias.DocPropiedad = tCsClientes.CodOrigen   
                INNER JOIN tCsPadronClientes with(nolock) ON tCsClientes.CodUsuario = tCsPadronClientes.CodOriginal   
                INNER JOIN tCspadronCarteradet with(nolock)   
                ON tCsMesGarantias.Fechsalida=tCspadronCarteradet.cancelacion  
                AND tCsMesGarantias.Codigo = tCspadronCarteradet.CodPrestamo  
                WHERE tCspadronCarteradet.cancelacion>=@primerdia and tCspadronCarteradet.cancelacion<=@fecha  
                --and tCspadronCarteradet.codprestamo='026-156-06-00-00400'   
             /*codeudores*/  
                union  
                select @fecha fecha, tCspadronCarteradet.cancelacion,tCspadronCarteradet.CodPrestamo
                ,tCsPrestamoCodeudor.codusuario,tCsPadronCarteraDet.desembolso FechaDesembolso, 'CanceladosC' tipo,  tCsPadronCarteraDet.codusuario  CodUsuarioOrigen
                from tCspadronCarteradet with(nolock) inner join   
                tCsPrestamoCodeudor with(nolock) on tCsPrestamoCodeudor.CodPrestamo = tCspadronCarteradet.CodPrestamo  
                --tCsPadronClientes.CodUsuario = dbo.tCsPrestamoCodeudor.CodUsuario   
                WHERE tCspadronCarteradet.cancelacion>=@primerdia and tCspadronCarteradet.cancelacion<=@fecha  
                --and tCspadronCarteradet.codprestamo='026-156-06-00-00400'  
                  
       ) cd ON pc.CodUsuario = cd.CodUsuario  --2056
union  
/***************  vINTFNombreCodeudores  ******************/  
SELECT 'Codeudor' AS Tipo, cd.Fecha, cd.CodPrestamo, co.CodUsuario,'19000101' Cancelacion, '' CodUsuarioOrigen
  FROM tCsPadronClientes pc
 INNER JOIN dbo.tCsPrestamoCodeudor co with(nolock)   
 INNER JOIN dbo.tCsCarteraDet       cd with(nolock) ON co.CodPrestamo = cd.CodPrestamo 
                                                    ON pc.CodUsuario  = co.CodUsuario   
 INNER JOIN tcscartera ca with(nolock) ON ca.codprestamo = cd.codprestamo AND ca.fecha=cd.fecha  
 WHERE cd.Fecha = @Fecha  
 --30445
 
/*
--SELECT * FROM #Nombres order by codusuario
--SELECT * FROM #Nombres --30455
select Tipo, count(*) Mov from #Nombres group by tipo
select Tipo, count(*) Mov from tCsBuroxTblReInom group by tipo
Cartera	19184
Aval	 1251
Codeudor  954
C         2056
CanceladosT	1079
CanceladosA	189
CanceladosC	788
select sum(1079+189+788)
*/
--drop table #tCsMesPlanCuotas
CREATE TABLE #tCsMesPlanCuotas
          (  fecha SMALLDATETIME,  
             codprestamo varchar(25),  
             MontoDevengado decimal(16,4),  
             MontoPagado decimal(16,4),  
             MontoCondonado decimal(16,4),  
             DiasAtrCuota int  )  
INSERT INTO #tCsMesPlanCuotas  
SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota  
  FROM tCsMesPlanCuotas with(nolock) 
 WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))  
   AND Fecha = @Fecha 
--select * from #tCsMesPlanCuotas

--drop table #FecPrimerInc
CREATE TABLE #FecPrimerInc
          (  codprestamo VARCHAR(25),
             FecPrimVenc SMALLDATETIME    )  
INSERT INTO #FecPrimerInc  
  SELECT CodPrestamo, coalesce(min(fechavencimiento),'') FecPrimVenc  
    FROM tCsPadronPlanCuotas with(nolock) 
   WHERE CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')
     AND DiasAtrCuota>0  
     AND FechaVencimiento<=@Fecha  
     AND CodPrestamo in (select distinct codprestamo from #Nombres)
   GROUP BY CodPrestamo
   
   --select * from tCsPadronPlanCuotas
CREATE TABLE #FecUltCuota
          (  codprestamo VARCHAR(25),
             FecUltCuota SMALLDATETIME    )  
INSERT INTO #FecUltCuota  
  SELECT CodPrestamo, coalesce(max(FechaPagoConcepto),'') FecUltCuota  
    FROM tCsPadronPlanCuotas with(nolock) 
   WHERE CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')
     --AND FechaVencimiento<=@Fecha  
     AND CodPrestamo in (select distinct codprestamo from #Nombres)
   GROUP BY CodPrestamo   
   
--drop table #MontoPagar
CREATE TABLE #MontoPagar
          (  codprestamo VARCHAR(25),
             MontoPagar  NUMERIC(16,2))  
INSERT INTO #MontoPagar  
SELECT CodPrestamo, Round(SUM(MontoCuota), 0)MontoPagar --CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar  
  FROM tCsPadronPlanCuotas with(nolock)  
 WHERE SecCuota = 1
   AND CodPrestamo in (select distinct codprestamo from #Nombres)
 GROUP BY CodPrestamo
 
--drop table #CreditoMaximo
CREATE TABLE #CreditoMaximo
          (  CodUsuario    VARCHAR(25),
             CreditoMaximo NUMERIC(16,2))  
INSERT INTO #CreditoMaximo
SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo  
  FROM (SELECT pad.CodUsuario, ca.FechaDesembolso, ca.MontoDesembolso  
          FROM tCsPadronCarteraDet pad with(nolock)
         INNER JOIN tCsCartera ca with(nolock) ON pad.FechaCorte = ca.Fecha AND pad.CodPrestamo = ca.CodPrestamo  
       ) Datos   
 WHERE Datos.FechaDesembolso <= @Fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg  
   AND Datos.CodUsuario in (select distinct codusuario from tcsCarteraDet where Fecha = @Fecha and codprestamo in( select distinct codprestamo from #Nombres))
 GROUP BY Datos.CodUsuario  
 
--drop table #SaldoVencido
--select * from #SaldoVencido
CREATE TABLE #SaldoVencido
          (  Fecha        SMALLDATETIME,
             CodPrestamo  VARCHAR(25),
             SaldoVencido NUMERIC(16,2) )  
INSERT INTO #SaldoVencido(Fecha, CodPrestamo, SaldoVencido)
SELECT coalesce(Fecha,'19000101') Fecha, coalesce(CodPrestamo,''), COALESCE(Round(SUM(MontoDevengado- MontoPagado - MontoCondonado), 0),0) --AS SaldoVencido  
  FROM (Select Fecha, CodPrestamo, MontoDevengado, MontoPagado, MontoCondonado,DiasAtrCuota 
          From #tCsMesPlanCuotas
        ) Vencido  
 WHERE (DiasAtrCuota = 1)  
 GROUP BY Fecha, CodPrestamo
--                  ) Vencido ON cd.Fecha = Vencido.Fecha AND cd.CodPrestamo = Vencido.CodPrestamo

--drop table #MtoUltPago
/*
CREATE TABLE #MtoUltPago
          (  codprestamo VARCHAR(25),
             codusuario  VARCHAR(25),
             MtoUltPago  NUMERIC(16,2))  
INSERT INTO #MtoUltPago
SELECT Cuotas.CodPrestamo, Cuotas.CodUsuario, SUM(Cuotas.MontoCuota) MtoUltPago
  FROM (Select n.CodPrestamo, n.CodUsuario, Max(pc.FechaPagoConcepto) FechaUltPago
          From #Nombres n
          Inner Join tCsPadronPlanCuotas pc with(nolock) ON pc.codprestamo = n.codprestamo and pc.codusuario = n.codusuario
           And pc.EstadoCuota = 'CANCELADO'
           --and pc.codprestamo = '039-156-06-00-00060' and pc.codusuario = 'XCP3006661' 
              --Where CodPrestamo IN (select distinct codprestamo from #Nombres) --11917
              Group By n.CodPrestamo, n.CodUsuario) UltPago
  LEFT OUTER JOIN (SELECT n.CodPrestamo, n.CodUsuario, pc.CodConcepto, pc.FechaPagoConcepto, pc.MontoCuota--, pc.* --pc.CodPrestamo, SUM(pc.MontoCuota) AS Cuota
                     FROM #Nombres n
                     INNER JOIN tCsPadronPlanCuotas pc with(nolock) ON pc.codprestamo = n.codprestamo and pc.codusuario = n.codusuario
                    WHERE pc.CodConcepto in ('CAPI', 'INTE', 'IVAIT')
                      AND pc.EstadoCuota = 'CANCELADO'
                      --and pc.codprestamo = '039-156-06-00-00060' and pc.codusuario = 'XCP3006661' --order by pc.Fecha desc 
        ) Cuotas ON UltPago.CodPrestamo = Cuotas.codprestamo AND UltPago.CodUsuario = Cuotas.CodUsuario AND UltPago.FechaUltPago = Cuotas.FechaPagoConcepto      
 GROUP BY Cuotas.CodPrestamo, Cuotas.CodUsuario   
 --039-156-06-00-00060-XCP3006661  
 --select * from #Nombres  where codprestamo = '039-156-06-00-00060' 
*/
--/*
CREATE TABLE #DatosCirculo(Tipo CHAR(2),
ClaveOtorgante         CHAR(10)   , NombreOtorgante     VARCHAR(40), IdentificadorDeMedio CHAR(10), FechaExtraccion   CHAR(8) , NotaOtorgante      VARCHAR(100),
NumVersion             CHAR(2)    , ApellidoPaterno        CHAR(30), ApellidoMaterno   VARCHAR(30), ApellidoAdicional CHAR(30), Nombres	           VARCHAR(50) ,
FechaNacimiento        CHAR(8)    , RFC	                   CHAR(13), CURP                 CHAR(18), Nacionalidad      CHAR(2) , Residencia	       CHAR(1)     ,
NumeroLicenciaConducir CHAR(1)    , EstadoCivil            CHAR(1) , Sexo                 CHAR(1) , ClaveElectorIFE   CHAR(20), NumeroDependientes CHAR(2)     ,	
FechaDefuncion	       CHAR(8)    , IndicadorDefuncion     CHAR(1) , TipoPersona	      CHAR(2) , Direccion	      CHAR(80), ColoniaPoblacion   CHAR(65)    ,
Delegacion	           VARCHAR(65), Ciudad              VARCHAR(65), Estado	              CHAR(4) , CP                CHAR(5) , FechaResidencia	   CHAR(8)     ,
NumeroTelefono	       CHAR(20)   , TipoDomicilio	       CHAR(1) , TipoAsentamiento	  CHAR(2) , NombreEmpresa	  CHAR(1) , DireccionE         CHAR(1)     ,
ColoniaPoblacionE      VARCHAR(65), DelegacionMunicipio VARCHAR(65), CiudadE              CHAR(1) , EstadoE           CHAR(4) , CP_E               CHAR(5)	   ,
NumeroTelefonoE        CHAR(20)   , ExtensionE             CHAR(8) , Fax                  CHAR(1) , PuestoE	          CHAR(1) , FechaContratacion  CHAR(8)     ,
ClaveMoneda	           CHAR(2)    , SalarioMensual         CHAR(9) , FechaUltimoDiaEmpleo CHAR(8) , FechaVerificacionEmpleo CHAR(1), ClaveActualOtorgante CHAR(10),
NombreOtorgante2       VARCHAR(40), CuentaActual	    VARCHAR(30), TipoResponsabilidad  CHAR(1) , TipoCuenta	      CHAR(1) , TipoContrato       CHAR(2)     ,	
ClaveUnidadMonetaria   CHAR(2)    , ValorActivoValuacion   CHAR(1) , NumeroPagos	      CHAR(4) , FrecuenciaPagos	  CHAR(1) , MontoPagar	       NUMERIC(16) ,
FechaAperturaCuenta	   CHAR(8)    , FechaUltimoPago        CHAR(8) , FechaUltimaCompra    CHAR(8) ,	FechaCierreCuenta CHAR(8) ,	FechaCorte	       CHAR(8)     ,
Garantia               CHAR(1)    ,	CreditoMaximo	    NUMERIC(16), SaldoActual	  NUMERIC(16) , LimiteCredito NUMERIC(16) , SaldoVencido	   NUMERIC (16),
NumeroPagosVencidos    NUMERIC(16), PagoActual              CHAR(2), HistoricoPagos	      CHAR(1) , ClavePrevencion	  CHAR(2) , TotalPagosReportados CHAR(1)   ,
ClaveAnteriorOtorgante CHAR(1)    , NombreAnteriorOtorgante	CHAR(1), NumeroCuentaAnterior CHAR(1) ,	FechaPrimerIncumplimiento CHAR(8), SaldoInsoluto NUMERIC(16)) --,MontoUltimoPago        NUMERIC(16))--, CodPrestamo             CHAR(25))
   
--------------------------CARTERA----------------------------------
INSERT INTO #DatosCirculo
SELECT 'CA',--cd.codusuario, cd.codprestamo, --n.Tipo, 
       '0003420046' ClaveOtorgante,
       'FINAMIGO' NombreOtorgante,
       '' IdentificadorDeMedio,
       dbo.fduFechaATexto(@Fecha,'AAAAMMDD') FechaExtraccion,  
       '' NotaOtorgante,                      
       2 NumVersion,
       isnull(left(pc.Paterno,30),'') ApellidoPaterno,
       isnull(left(pc.Materno,30),'') ApellidoMaterno,
       '' ApellidoAdicional,
       isnull(left(pc.Nombres,50),'') Nombres,
       dbo.fduFechaATexto(pc.FechaNacimiento,'AAAAMMDD') FechaNacimiento,
       isnull(left(coalesce(pc.usRFC,''),13),'') RFC,
       isnull(left(coalesce(pc.usCURP,''),18),'') CURP,
       'MX' Nacionalidad,
        case v.CodTipoPro
             when 'PRO' then '1'
             when 'ALQ' then '2'
             when 'ANT' then '3'
             when 'COM' then '4'
             else '1' end Residencia,
       '' NumeroLicenciaConducir,
       coalesce(pc.CodEstadoCivil,'') EstadoCivil, --select distinct CodEstadoCivil from tCsPadronClientes
       CASE s.SHF WHEN 'H' THEN 'M' WHEN 'M' THEN 'F' ELSE '' END AS Sexo, 
       CASE WHEN pc.CodDocIden = 'RFC' THEN left(DI,20) ELSE '' END AS ClaveElectorIFE,
       coalesce(pc.UsNDependientes,0) NumeroDependientes,
       '' FechaDefuncion,
       '' IndicadorDefuncion,
       'PF' TipoPersona,
       isnull(left(isnull(pc.direcciondirfampri+' '+isnull(pc.NumExtFam,'')+' '+isnull(pc.NumIntFam,''),pc.direcciondirnegpri+' '+isnull(pc.NumExtNeg,'')+' '+isnull(pc.NumIntNeg,'')),80),'') Direccion,
       isnull(left(colo.DescUbiGeo,65),'') ColoniaPoblacion,
       isnull(left(tClUbiGeo.DescUbiGeo,65),'') Delegacion,
       'MEXICO' Ciudad,
       case estado.NomUbiGeo         when 'ALS' then 'AGS'   when 'BIA' then 'BC'     when 'BOR' then 'BCS'    when 'CEE' then 'CAMP'
            when 'CZA' then 'COAH'   when 'CIA' then 'COL'   when 'CAS' then 'CHIS'   when 'CUA' then 'CHIH'   when 'DFL' then 'DF'
            when 'DAO' then 'DGO'    when 'GJO' then 'GTO'   when 'GRO' then 'GRO'    when 'HAO' then 'HGO'    when 'JIO' then 'JAL'
            when 'MIO' then 'MEX'    when 'MDO' then 'MICH'  when 'MES' then 'MOR'    when 'NAT' then 'NAY'    when 'NLN' then 'NL'
            when 'OAA' then 'OAX'    when 'PBA' then 'PUE'   when 'QÉO' then 'QRO'    when 'QNO' then 'QROO'   when 'SPÍ' then 'SLP'
            when 'SAA' then 'SIN'    when 'SOA' then 'SON'   when 'TAO' then 'TAB'    when 'TLS' then 'TAMP'   when 'TCA' then 'TLAX'
            when 'VIE' then 'VER'    when 'YAN' then 'YUC'   when 'ZTS' then 'ZAC'           
            else '' end Estado,    -- select * from tClUbiGeo where codubigeotipo like'%ESTA%' isnull(pc.codpostalfam,pc.codpostalneg) CP, --estado.DescUbiGeo Estado,
       isnull(left(replace(isnull(pc.codpostalfam,pc.codpostalneg),'_',''),5),'') CP, 
       '' FechaResidencia,
       isnull(left(replace(isnull(pc.TelefonoDirFamPri,pc.TelefonoDirNegPri),'_',''),20),'') NumeroTelefono,
       '' TipoDomicilio,
       '' TipoAsentamiento,
       '' NombreEmpresa,
       '' Direccion,
       '' ColoniaPoblacion,
       '' DelegacionMunicipio,
       '' Ciudad,
       '' Estado,
       '' CP,
       '' NumeroTelefono,
       '' Extension,
       '' Fax,
       '' Puesto,
       '' FechaContratacion,
       '' ClaveMoneda,
       '' SalarioMensual,
       '' FechaUltimoDiaEmpleo,
       '' FechaVerificacionEmpleo,
       '0003420046' ClaveActualOtorgante,
       'FINAMIGO' NombreOtorgante,
       --select * from tcscartera where fecha = '20131031' and codproducto = '156' order by codprestamo
       cd.CodPrestamo + '-' +cd.Codusuario CuentaActual,
       --replace('-','',n.CodPrestamo)+''+n.Codusuario CuentaActual,
       case when c.codgrupo IS NOT NULL or c.codgrupo <> '' --'156' 
            then 'O' else case n.Tipo 
                               when 'Codeudor' then 'M'
                               when 'Aval'     then 'A' 
                               else 'I'
                    end end  TipoResponsabilidad,         
       case when p.codproducto = '304' then 'P' else 'Q' end TipoCuenta,
       case p.codproducto 
            when '156' then 'GS' 
            when '123' then 'MC'
            when '302' then 'CP'
            else 'PQ' end TipoContrato,
       'MX' ClaveUnidadMonetaria,
       '' ValorActivoValuacion,
       c.NroCuotas NumeroPagos,
       mp.ModalidadPlazo FrecuenciaPagos,   --c.NrodiasEntreCuotas FrecuenciaPagos
       --coalesce(mo.MontoPagar,0) MontoPagar,--coalesce(MontoPagar.MontoPagar,0) MontoPagar,
       coalesce(case when mo.MontoPagar >  ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) 
                     then c.CuotaActual
                     else mo.MontoPagar end,0) MontoPagar,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaAperturaCuenta,
       isnull(dbo.fduFechaATexto(c.FechaUltimoMovimiento,'AAAAMMDD'),'') FechaUltimoPago,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaUltimaCompra,
       case when mo.MontoPagar = 0 then dbo.fduFechaATexto(uc.FecUltCuota,'AAAAMMDD') else '19000101' end FechaCierreCuenta,
       --select * from tCsCartera where codprestamo = '021-123-06-04-00060'
       isnull(dbo.fduFechaATexto(pcd.FechaCorte,'AAAAMMDD'),'') FechaCorte, --select fechacorte,* from tcscarteradet
	   '' AS Garantia, 
       coalesce(cm.CreditoMaximo, cd.MontoDesembolso) CreditoMaximo,
       ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) SaldoActual,
       --cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido SaldoActual,
       cd.MontoDesembolso LimiteCredito,
       coalesce(sv.SaldoVencido,0) SaldoVencido,--coalesce(Vencido.SaldoVencido,0) SaldoVencido, --cd.CapitalVencido + cd.InteresVencido + cd.MoratorioVencido SaldoVencido,
	   c.CuotaActual - c.NroCuotasPagadas NumeroPagosVencidos,
	   CASE WHEN (CuotaActual - NroCuotasPagadas) = 0
	        THEN 'V'
	        ELSE case when CuotaActual - NroCuotasPagadas >= 84 then '84' 
	                  else convert(char(2),case when len(CuotaActual - NroCuotasPagadas) = 1 
	                  then '0'+convert(char(1),(CuotaActual - NroCuotasPagadas))
	                  else convert(char(5),CuotaActual - NroCuotasPagadas) end) end
	        END PagoActual,
	   '' HistoricoPagos,
	   '' ClavePrevencion,
	   '' TotalPagosReportados,
	   '' ClaveAnteriorOtorgante,
	   '' NombreAnteriorOtorgante,
	   '' NumeroCuentaAnterior,
	   COALESCE(dbo.fduFechaATexto(fi.FecPrimVenc,'AAAAMMDD'),'') FechaPrimerIncumplimiento,
       ROUND(isnull(c.SaldoCapital,0), 0) SaldoInsoluto --CASE WHEN n.Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(c.SaldoCapital,0), 0) END AS SaldoInsoluto
       --*/
       --coalesce(mu.MtoUltPago,0) MontoUltimoPago--, cd.codprestamo
       /*
       select SaldoCapital SaldoCapitalAsSaldoInsoluto, SaldoCapital,SaldoInteresCorriente, SaldoINVE, SaldoINPE
              --(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) 
         from tcscartera where codprestamo = '004-116-06-03-00958' and fecha = '20131031'
         */
         --select distinct codgrupo from tCsCartera where codprestamo = '018-116-06-03-00521'
         --SaldoActual	SaldoInsoluto	SaldoCapital	SaldoInteresCorriente	SaldoINVE	SaldoINPE
--8971.0000	8600.0000	8600.0000	370.5700	0.0000	0.0000
 --'021-123-06-04-00060'
  --select SaldoCapital,	SaldoInteresCorriente	SaldoINVE,	SaldoINPE,
--select c.SaldoCapital,c.SaldoInteresCorriente,c.SaldoINVE,c.SaldoINPE
  FROM tCsCartera c
 INNER JOIN tCsCarteraDet cd with(nolock) ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo
 --select * from tCsPadronClientes where codusuario = 'CHM2202661'
 --select * from tcsusuariosdireccion
 INNER JOIN tCsPadronClientes pc with(nolock) ON cd.CodUsuario = pc.CodUsuario
 INNER JOIN tCsPadronCarteraDet pcd ON cd.CodPrestamo = pcd.CodPrestamo and cd.codusuario = pcd.codusuario
 INNER JOIN #Nombres n with(nolock) ON cd.fecha = n.Fecha AND cd.CodPrestamo = n.CodPrestamo and cd.codusuario = n.codusuario
 INNER JOIN tClOficinas       o with(nolock) ON o.codoficina  = c.codoficina 
 INNER JOIN tCaProducto       p with(nolock) ON c.codproducto = p.codproducto
 LEFT OUTER JOIN tClUbiGeo Colo with(nolock) ON Colo.CodUbiGeo = ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) 
 LEFT OUTER JOIN tClUbiGeo estado with(nolock) ON SUBSTRING(SUBSTRING(Colo.CodArbolConta, 1, 19), 1, 13)=estado.CodArbolConta          
 LEFT OUTER JOIN tClUbiGeo with(nolock) ON SUBSTRING(Colo.CodArbolConta, 1, 19) = tClUbiGeo.CodArbolConta      
 LEFT OUTER JOIN tCaClModalidadPlazo mp with(nolock) ON mp.ModalidadPlazo = c.ModalidadPlazo   
 LEFT OUTER JOIN #FecPrimerInc fi ON cd.CodPrestamo = fi.CodPrestamo
 LEFT OUTER JOIN #SaldoVencido sv ON cd.Fecha = sv.Fecha AND cd.CodPrestamo = sv.CodPrestamo
 LEFT OUTER JOIN tUsClSexo            s with(nolock) ON pc.Sexo            = s.Sexo
 LEFT OUTER JOIN tUsClTipoPropiedad v with(nolock) ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = v.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
 LEFT OUTER JOIN #MontoPagar mo ON cd.CodPrestamo = mo.CodPrestamo
 LEFT OUTER JOIN #CreditoMaximo cm ON cd.CodUsuario = cm.CodUsuario
 LEFT OUTER JOIN #FecUltCuota uc ON cd.CodPrestamo = uc.CodPrestamo
 --LEFT OUTER JOIN #MtoUltPago mu ON cd.CodPrestamo = mu.CodPrestamo and cd.CodUsuario = mu.CodUsuario
WHERE cd.fecha = @Fecha --'20131031' 
  AND n.Tipo   = 'Cartera'
  --and c.codprestamo = '021-123-06-04-00060'
  AND n.codprestamo not in ('004-116-06-03-00958')
--and n.codprestamo in ('017-116-06-01-00855','011-156-06-05-00022','011-156-06-05-00022','017-116-06-01-00925','017-156-06-08-00316','082-158-06-02-00018') 
--order by n.codusuario
--select * from tCsBuroxTblReICue where codprestamo in ('017-116-06-01-00855','011-156-06-05-00022','011-156-06-05-00022','017-116-06-01-00925','017-156-06-08-00316','082-158-06-02-00018') order by claveusuario, codprestamo
union  
--------------------------AVALES----------------------------------  
SELECT 'AV',--cd.codusuario, cd.codprestamo, --n.Tipo, 
       '0003420046' ClaveOtorgante,
       'FINAMIGO' NombreOtorgante,
       '' IdentificadorDeMedio,
       dbo.fduFechaATexto(@Fecha,'AAAAMMDD') FechaExtraccion,  
       '' NotaOtorgante,                      
       2 NumVersion,
       isnull(left(pc.Paterno,30),'') ApellidoPaterno,
       isnull(left(pc.Materno,30),'') ApellidoMaterno,
       '' ApellidoAdicional,
       isnull(left(pc.Nombres,50),'') Nombres,
       dbo.fduFechaATexto(pc.FechaNacimiento,'AAAAMMDD') FechaNacimiento,
       isnull(left(coalesce(pc.usRFC,''),13),'') RFC,
       isnull(left(coalesce(pc.usCURP,''),18),'') CURP,
       'MX' Nacionalidad,
        case v.CodTipoPro
             when 'PRO' then '1'
             when 'ALQ' then '2'
             when 'ANT' then '3'
             when 'COM' then '4'
             else '1' end Residencia,
       '' NumeroLicenciaConducir,
       coalesce(pc.CodEstadoCivil,'') EstadoCivil, --select distinct CodEstadoCivil from tCsPadronClientes
       CASE s.SHF WHEN 'H' THEN 'M' WHEN 'M' THEN 'F' ELSE '' END AS Sexo, 
       CASE WHEN pc.CodDocIden = 'RFC' THEN left(DI,20) ELSE '' END AS ClaveElectorIFE,
       coalesce(pc.UsNDependientes,0) NumeroDependientes,
       '' FechaDefuncion,
       '' IndicadorDefuncion,
       'PF' TipoPersona,
       isnull(left(isnull(pc.direcciondirfampri+' '+isnull(pc.NumExtFam,'')+' '+isnull(pc.NumIntFam,''),pc.direcciondirnegpri+' '+isnull(pc.NumExtNeg,'')+' '+isnull(pc.NumIntNeg,'')),80),'') Direccion,
       isnull(left(colo.DescUbiGeo,65),'') ColoniaPoblacion,
       isnull(left(tClUbiGeo.DescUbiGeo,65),'') Delegacion,
       'MEXICO' Ciudad,
       case estado.NomUbiGeo         when 'ALS' then 'AGS'   when 'BIA' then 'BC'     when 'BOR' then 'BCS'    when 'CEE' then 'CAMP'
            when 'CZA' then 'COAH'   when 'CIA' then 'COL'   when 'CAS' then 'CHIS'   when 'CUA' then 'CHIH'   when 'DFL' then 'DF'
            when 'DAO' then 'DGO'    when 'GJO' then 'GTO'   when 'GRO' then 'GRO'    when 'HAO' then 'HGO'    when 'JIO' then 'JAL'
            when 'MIO' then 'MEX'    when 'MDO' then 'MICH'  when 'MES' then 'MOR'    when 'NAT' then 'NAY'    when 'NLN' then 'NL'
            when 'OAA' then 'OAX'    when 'PBA' then 'PUE'   when 'QÉO' then 'QRO'    when 'QNO' then 'QROO'   when 'SPÍ' then 'SLP'
            when 'SAA' then 'SIN'    when 'SOA' then 'SON'   when 'TAO' then 'TAB'    when 'TLS' then 'TAMP'   when 'TCA' then 'TLAX'
            when 'VIE' then 'VER'    when 'YAN' then 'YUC'   when 'ZTS' then 'ZAC'           
            else '' end Estado,    
       isnull(left(replace(isnull(pc.codpostalfam,pc.codpostalneg),'_',''),5),'') CP, 
       '' FechaResidencia,
       isnull(left(replace(isnull(pc.TelefonoDirFamPri,pc.TelefonoDirNegPri),'_',''),20),'') NumeroTelefono,
       '' TipoDomicilio,
       '' TipoAsentamiento,
       '' NombreEmpresa,
       '' Direccion,
       '' ColoniaPoblacion,
       '' DelegacionMunicipio,
       '' Ciudad,
       '' Estado,
       '' CP,
       '' NumeroTelefono,
       '' Extension,
       '' Fax,
       '' Puesto,
       '' FechaContratacion,
       '' ClaveMoneda,
       '' SalarioMensual,
       '' FechaUltimoDiaEmpleo,
       '' FechaVerificacionEmpleo,
       '0003420046' ClaveActualOtorgante,
       'FINAMIGO' NombreOtorgante,
       n.CodPrestamo + '-' +n.Codusuario CuentaActual,
       --replace('-','',n.CodPrestamo)+''+n.Codusuario CuentaActual,
       --case when p.codproducto = '156' 
       case when c.codgrupo IS NOT NULL or c.codgrupo <> '' --'156' 
            then 'O' else case n.Tipo 
                               when 'Codeudor' then 'M'
                               when 'Aval'     then 'A' 
                               else 'I'
                    end end  TipoResponsabilidad,         
       case when p.codproducto = '304' then 'P' else 'Q' end TipoCuenta,
       case p.codproducto 
            when '156' then 'GS' 
            when '123' then 'MC'
            when '302' then 'CP'
            else 'PQ' end TipoContrato,
       'MX' ClaveUnidadMonetaria,
       '' ValorActivoValuacion,
       c.NroCuotas NumeroPagos,
       mp.ModalidadPlazo FrecuenciaPagos,    --c.NrodiasEntreCuotas FrecuenciaPagos
       coalesce(case when mo.MontoPagar >  ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) 
                     then c.CuotaActual
                     else mo.MontoPagar end,0) MontoPagar,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaAperturaCuenta,
       dbo.fduFechaATexto(c.FechaUltimoMovimiento,'AAAAMMDD') FechaUltimoPago,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaUltimaCompra,
        --case when mo.MontoPagar = 0 then uc.FecUltCuota else '' end FechaCierreCuenta,
       case when mo.MontoPagar = 0 then dbo.fduFechaATexto(uc.FecUltCuota,'AAAAMMDD') else '19000101' end FechaCierreCuenta,
       dbo.fduFechaATexto(pcd.FechaCorte,'AAAAMMDD')  FechaCorte, --select fechacorte,* from tcscarteradet
	   '' AS Garantia, 
     coalesce(cm.CreditoMaximo, cd.MontoDesembolso) CreditoMaximo,
       ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) SaldoActual,
       --cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido SaldoActual,
       cd.MontoDesembolso LimiteCredito,
       coalesce(sv.SaldoVencido,0) SaldoVencido,--coalesce(Vencido.SaldoVencido,0) SaldoVencido, --cd.CapitalVencido + cd.InteresVencido + cd.MoratorioVencido SaldoVencido,
	   c.CuotaActual - c.NroCuotasPagadas NumeroPagosVencidos,
	   CASE WHEN (CuotaActual - NroCuotasPagadas) = 0
	        THEN 'V'
	        ELSE case when CuotaActual - NroCuotasPagadas >= 84 then '84' 
	                  else convert(char(2),case when len(CuotaActual - NroCuotasPagadas) = 1 
	                  then '0'+convert(char(1),(CuotaActual - NroCuotasPagadas))
	                  else convert(char(5),CuotaActual - NroCuotasPagadas) end) end
	        END PagoActual,
	   '' HistoricoPagos,
	   '' ClavePrevencion,
	   '' TotalPagosReportados,
	   '' ClaveAnteriorOtorgante,
	   '' NombreAnteriorOtorgante,
	   '' NumeroCuentaAnterior,
	   COALESCE(dbo.fduFechaATexto(fi.FecPrimVenc,'AAAAMMDD'),'') FechaPrimerIncumplimiento,
       ROUND(isnull(c.SaldoCapital,0), 0) SaldoInsoluto--CASE WHEN n.Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(c.SaldoCapital,0), 0) END AS SaldoInsoluto
       --coalesce(mu.MtoUltPago,0) MontoUltimoPago
--select n.codusuario, n.codprestamo, n.tipo   
  FROM #Nombres n 
 INNER JOIN tCsCartera c with(nolock) ON c.fecha = n.Fecha AND c.CodPrestamo = n.CodPrestamo --and c.codusuario = n.codusuario
 INNER JOIN tCsCarteraDet cd with(nolock) ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo
 INNER JOIN tCsPadronClientes pc with(nolock) ON pc.CodUsuario = n.CodUsuario
 INNER JOIN tCsPadronCarteraDet pcd ON pcd.CodPrestamo = cd.CodPrestamo and pcd.codusuario = cd.codusuario
 INNER JOIN tClOficinas       o with(nolock) ON o.codoficina  = c.codoficina 
 INNER JOIN tCaProducto       p with(nolock) ON c.codproducto = p.codproducto
 LEFT OUTER JOIN tUsClTipoPropiedad v with(nolock) ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = v.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
 LEFT OUTER JOIN tUsClSexo            s with(nolock) ON pc.Sexo            = s.Sexo
 LEFT OUTER JOIN tClUbiGeo Colo with(nolock) ON Colo.CodUbiGeo = ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) 
 LEFT OUTER JOIN tClUbiGeo estado with(nolock) ON SUBSTRING(SUBSTRING(Colo.CodArbolConta, 1, 19), 1, 13)=estado.CodArbolConta          
 LEFT OUTER JOIN tClUbiGeo with(nolock) ON SUBSTRING(Colo.CodArbolConta, 1, 19) = tClUbiGeo.CodArbolConta      
 LEFT OUTER JOIN tCaClModalidadPlazo mp with(nolock) ON mp.ModalidadPlazo = c.ModalidadPlazo   
 LEFT OUTER JOIN #FecPrimerInc fi ON n.CodPrestamo = fi.CodPrestamo
 LEFT OUTER JOIN #SaldoVencido sv ON cd.Fecha = sv.Fecha AND cd.CodPrestamo = sv.CodPrestamo
 LEFT OUTER JOIN #MontoPagar mo ON n.CodPrestamo = mo.CodPrestamo
 LEFT OUTER JOIN #CreditoMaximo cm ON cd.CodUsuario = cm.CodUsuario
 LEFT OUTER JOIN #FecUltCuota uc ON cd.CodPrestamo = uc.CodPrestamo
 --LEFT OUTER JOIN #MtoUltPago mu ON cd.CodPrestamo = mu.CodPrestamo  and cd.CodUsuario = mu.CodUsuario
WHERE n.Tipo = 'Aval' --1251
--and n.codprestamo in ('002-118-06-00-00055','002-118-06-00-00081','002-118-06-00-00082','002-118-06-00-00090','002-118-06-00-00272')
--order by n.codusuario, n.codprestamo
--select * from tCsBuroxTblReICue where codprestamo in ('002-118-06-00-00055','002-118-06-00-00081','002-118-06-00-00082','002-118-06-00-00090','002-118-06-00-00272') order by responsabilidad, claveusuario, codprestamo
union
-------------CODEUDORES-------------------
SELECT 'CO',--cd.codusuario, cd.codprestamo, --n.Tipo, 
       '0003420046' ClaveOtorgante,
       'FINAMIGO' NombreOtorgante,
       '' IdentificadorDeMedio,
       dbo.fduFechaATexto(@Fecha,'AAAAMMDD') FechaExtraccion,  
       '' NotaOtorgante,                      
       2 NumVersion,
       isnull(left(pc.Paterno,30),'') ApellidoPaterno,
       isnull(left(pc.Materno,30),'') ApellidoMaterno,
       '' ApellidoAdicional,
       isnull(left(pc.Nombres,50),'') Nombres,
       dbo.fduFechaATexto(pc.FechaNacimiento,'AAAAMMDD') FechaNacimiento,
       isnull(left(coalesce(pc.usRFC,''),13),'') RFC,
       isnull(left(coalesce(pc.usCURP,''),18),'') CURP,
       'MX' Nacionalidad,
        case v.CodTipoPro
             when 'PRO' then '1'
             when 'ALQ' then '2'
             when 'ANT' then '3'
             when 'COM' then '4'
             else '1' end Residencia,
       '' NumeroLicenciaConducir,
       coalesce(pc.CodEstadoCivil,'') EstadoCivil, --select distinct CodEstadoCivil from tCsPadronClientes
       CASE s.SHF WHEN 'H' THEN 'M' WHEN 'M' THEN 'F' ELSE '' END AS Sexo, 
       CASE WHEN pc.CodDocIden = 'RFC' THEN left(DI,20) ELSE '' END AS ClaveElectorIFE,
       coalesce(pc.UsNDependientes,'') NumeroDependientes,
       '' FechaDefuncion,
       '' IndicadorDefuncion,
       'PF' TipoPersona,
       isnull(left(isnull(pc.direcciondirfampri+' '+isnull(pc.NumExtFam,'')+' '+isnull(pc.NumIntFam,''),pc.direcciondirnegpri+' '+isnull(pc.NumExtNeg,'')+' '+isnull(pc.NumIntNeg,'')),80),'') Direccion,
       isnull(left(colo.DescUbiGeo,65),'') ColoniaPoblacion,
       isnull(left(tClUbiGeo.DescUbiGeo,65),'') Delegacion,
       'MEXICO' Ciudad,
       case estado.NomUbiGeo         when 'ALS' then 'AGS'   when 'BIA' then 'BC'     when 'BOR' then 'BCS'    when 'CEE' then 'CAMP'
            when 'CZA' then 'COAH'   when 'CIA' then 'COL'   when 'CAS' then 'CHIS'   when 'CUA' then 'CHIH'   when 'DFL' then 'DF'
            when 'DAO' then 'DGO'    when 'GJO' then 'GTO'   when 'GRO' then 'GRO'    when 'HAO' then 'HGO'    when 'JIO' then 'JAL'
            when 'MIO' then 'MEX'    when 'MDO' then 'MICH'  when 'MES' then 'MOR'    when 'NAT' then 'NAY'    when 'NLN' then 'NL'
            when 'OAA' then 'OAX'    when 'PBA' then 'PUE'   when 'QÉO' then 'QRO'    when 'QNO' then 'QROO'   when 'SPÍ' then 'SLP'
            when 'SAA' then 'SIN'    when 'SOA' then 'SON'   when 'TAO' then 'TAB'    when 'TLS' then 'TAMP'   when 'TCA' then 'TLAX'
            when 'VIE' then 'VER'    when 'YAN' then 'YUC'   when 'ZTS' then 'ZAC'           
            else '' end Estado,    
       isnull(left(replace(isnull(pc.codpostalfam,pc.codpostalneg),'_',''),5),'') CP, 
       '' FechaResidencia,
       isnull(left(replace(isnull(pc.TelefonoDirFamPri,pc.TelefonoDirNegPri),'_',''),20),'') NumeroTelefono,
       '' TipoDomicilio,
       '' TipoAsentamiento,
       '' NombreEmpresa,
       '' Direccion,
       '' ColoniaPoblacion,
       '' DelegacionMunicipio,
       '' Ciudad,
       '' Estado,
       '' CP,
       '' NumeroTelefono,
       '' Extension,
       '' Fax,
       '' Puesto,
       '' FechaContratacion,
       '' ClaveMoneda,
       '' SalarioMensual,
       '' FechaUltimoDiaEmpleo,
       '' FechaVerificacionEmpleo,
       '0003420046' ClaveActualOtorgante,
       'FINAMIGO' NombreOtorgante,
       cd.CodPrestamo + '-' +cd.Codusuario CuentaActual,
       --replace('-','',n.CodPrestamo)+''+n.Codusuario CuentaActual,
       --case when p.codproducto = '156' 
       case when c.codgrupo IS NOT NULL or c.codgrupo <> '' --'156' 
            then 'O' else case n.Tipo 
                               when 'Codeudor' then 'M'
                               when 'Aval'     then 'A' 
                               else 'I'
                    end end  TipoResponsabilidad,         
       case when p.codproducto = '304' then 'P' else 'Q' end TipoCuenta,
       case p.codproducto 
            when '156' then 'GS' 
            when '123' then 'MC'
            when '302' then 'CP'
            else 'PQ' end TipoContrato,
       'MX' ClaveUnidadMonetaria,
       '' ValorActivoValuacion,
       c.NroCuotas NumeroPagos,
       mp.ModalidadPlazo FrecuenciaPagos,    --c.NrodiasEntreCuotas FrecuenciaPagos
       --coalesce(mo.MontoPagar,0) MontoPagar,
       coalesce(case when mo.MontoPagar >  ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) 
                     then c.CuotaActual
                     else mo.MontoPagar end,0) MontoPagar,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaAperturaCuenta,
       isnull(dbo.fduFechaATexto(c.FechaUltimoMovimiento,'AAAAMMDD'),'') FechaUltimoPago,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaUltimaCompra,
       --case when mo.MontoPagar = 0 then uc.FecUltCuota else '' end FechaCierreCuenta,
       case when mo.MontoPagar = 0 then dbo.fduFechaATexto(uc.FecUltCuota,'AAAAMMDD') else '19000101' end FechaCierreCuenta,
       isnull(dbo.fduFechaATexto(pcd.FechaCorte,'AAAAMMDD'),'')  FechaCorte, --select fechacorte,* from tcscarteradet
	   '' AS Garantia, 
     --c.MontoDesembolso CreditoMaximo,       
     coalesce(cm.CreditoMaximo, cd.MontoDesembolso) CreditoMaximo, 
       ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) SaldoActual,
       --cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido SaldoActual,
       cd.MontoDesembolso LimiteCredito,
       coalesce(sv.SaldoVencido,0) SaldoVencido,--coalesce(Vencido.SaldoVencido,0) SaldoVencido, --cd.CapitalVencido + cd.InteresVencido + cd.MoratorioVencido SaldoVencido,
	   c.CuotaActual - c.NroCuotasPagadas NumeroPagosVencidos,
	   CASE WHEN (CuotaActual - NroCuotasPagadas) = 0
	        THEN 'V'
	        ELSE case when CuotaActual - NroCuotasPagadas >= 84 then '84' 
	                  else convert(char(2),case when len(CuotaActual - NroCuotasPagadas) = 1 
	                  then '0'+convert(char(1),(CuotaActual - NroCuotasPagadas))
	                  else convert(char(5),CuotaActual - NroCuotasPagadas) end) end
	        END PagoActual,
	   '' HistoricoPagos,
	   '' ClavePrevencion,
	   '' TotalPagosReportados,
	   '' ClaveAnteriorOtorgante,
	   '' NombreAnteriorOtorgante,
	   '' NumeroCuentaAnterior,
	   COALESCE(dbo.fduFechaATexto(fi.FecPrimVenc,'AAAAMMDD'),'') FechaPrimerIncumplimiento,
       ROUND(isnull(c.SaldoCapital,0), 0) SaldoInsoluto--CASE WHEN n.Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(c.SaldoCapital,0), 0) END AS SaldoInsoluto
       --coalesce(mu.MtoUltPago,0) MontoUltimoPago
--select n.codusuario, n.codprestamo, n.tipo   
  FROM #Nombres n 
 INNER JOIN tCsCartera c with(nolock) ON c.fecha = n.Fecha AND c.CodPrestamo = n.CodPrestamo --and c.codusuario = n.codusuario
 INNER JOIN tCsCarteraDet cd with(nolock) ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo
 INNER JOIN tCsPadronClientes pc with(nolock) ON pc.CodUsuario = n.CodUsuario
 INNER JOIN tCsPadronCarteraDet pcd ON pcd.CodPrestamo = cd.CodPrestamo and pcd.codusuario = cd.codusuario
 INNER JOIN tClOficinas       o with(nolock) ON o.codoficina  = c.codoficina 
 INNER JOIN tCaProducto       p with(nolock) ON c.codproducto = p.codproducto
 LEFT OUTER JOIN tUsClTipoPropiedad v with(nolock) ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = v.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
 LEFT OUTER JOIN tUsClSexo            s with(nolock) ON pc.Sexo            = s.Sexo
 LEFT OUTER JOIN tClUbiGeo Colo with(nolock) ON Colo.CodUbiGeo = ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) 
 LEFT OUTER JOIN tClUbiGeo estado with(nolock) ON SUBSTRING(SUBSTRING(Colo.CodArbolConta, 1, 19), 1, 13)=estado.CodArbolConta          
 LEFT OUTER JOIN tClUbiGeo with(nolock) ON SUBSTRING(Colo.CodArbolConta, 1, 19) = tClUbiGeo.CodArbolConta      
 LEFT OUTER JOIN tCaClModalidadPlazo mp with(nolock) ON mp.ModalidadPlazo = c.ModalidadPlazo   
 LEFT OUTER JOIN #FecPrimerInc fi ON n.CodPrestamo = fi.CodPrestamo
 LEFT OUTER JOIN #SaldoVencido sv ON cd.Fecha = sv.Fecha AND cd.CodPrestamo = sv.CodPrestamo
 LEFT OUTER JOIN #MontoPagar mo ON n.CodPrestamo = mo.CodPrestamo
 LEFT OUTER JOIN #CreditoMaximo cm ON cd.CodUsuario = cm.CodUsuario
 LEFT OUTER JOIN #FecUltCuota uc ON cd.CodPrestamo = uc.CodPrestamo
 --LEFT OUTER JOIN #MtoUltPago mu ON cd.CodPrestamo = mu.CodPrestamo  and cd.CodUsuario = mu.CodUsuario
WHERE n.Tipo = 'Codeudor' --7954
--and n.codprestamo in  ('015-162-06-06-00038','035-162-06-00-00032','075-162-06-00-00632','016-158-06-04-00212','041-158-06-08-00099')
--order by n.codusuario, n.codprestamo
--select * from tCsBuroxTblReICue where codprestamo in ('015-162-06-06-00038','035-162-06-00-00032','075-162-06-00-00632','016-158-06-04-00212','041-158-06-08-00099') order by responsabilidad, claveusuario, codprestamo
union
-------------CANCELADOS-------------------
SELECT 'CN',--cd.codusuario, cd.codprestamo, --n.Tipo, 
       '0003420046' ClaveOtorgante,
       'FINAMIGO' NombreOtorgante,
       '' IdentificadorDeMedio,
       dbo.fduFechaATexto(@Fecha,'AAAAMMDD') FechaExtraccion,  
       '' NotaOtorgante,                      
       2 NumVersion,
       isnull(left(pc.Paterno,30),'') ApellidoPaterno,
       isnull(left(pc.Materno,30),'') ApellidoMaterno,
       '' ApellidoAdicional,
       isnull(left(pc.Nombres,50),'') Nombres,
       dbo.fduFechaATexto(pc.FechaNacimiento,'AAAAMMDD') FechaNacimiento,
       isnull(left(coalesce(pc.usRFC,''),13),'') RFC,
       isnull(left(coalesce(pc.usCURP,''),18),'') CURP,
       'MX' Nacionalidad,
        case v.CodTipoPro
             when 'PRO' then '1'
             when 'ALQ' then '2'
             when 'ANT' then '3'
             when 'COM' then '4'
             else '1' end Residencia,
       '' NumeroLicenciaConducir,
       coalesce(pc.CodEstadoCivil,'') EstadoCivil, --select distinct CodEstadoCivil from tCsPadronClientes
       CASE s.SHF WHEN 'H' THEN 'M' WHEN 'M' THEN 'F' ELSE '' END AS Sexo, 
       CASE WHEN pc.CodDocIden = 'RFC' THEN left(DI,20) ELSE '' END AS ClaveElectorIFE,
       coalesce(pc.UsNDependientes,'') NumeroDependientes,
       '' FechaDefuncion,
       '' IndicadorDefuncion,
       'PF' TipoPersona,
       isnull(left(isnull(pc.direcciondirfampri+' '+isnull(pc.NumExtFam,'')+' '+isnull(pc.NumIntFam,''),pc.direcciondirnegpri+' '+isnull(pc.NumExtNeg,'')+' '+isnull(pc.NumIntNeg,'')),80),'') Direccion,
       isnull(left(colo.DescUbiGeo,65),'') ColoniaPoblacion,
       isnull(left(tClUbiGeo.DescUbiGeo,65),'') Delegacion,
       'MEXICO' Ciudad,
       case estado.NomUbiGeo         when 'ALS' then 'AGS'   when 'BIA' then 'BC'     when 'BOR' then 'BCS'    when 'CEE' then 'CAMP'
            when 'CZA' then 'COAH'   when 'CIA' then 'COL'   when 'CAS' then 'CHIS'   when 'CUA' then 'CHIH'   when 'DFL' then 'DF'
            when 'DAO' then 'DGO'    when 'GJO' then 'GTO'   when 'GRO' then 'GRO'    when 'HAO' then 'HGO'    when 'JIO' then 'JAL'
            when 'MIO' then 'MEX'    when 'MDO' then 'MICH'  when 'MES' then 'MOR'    when 'NAT' then 'NAY'    when 'NLN' then 'NL'
            when 'OAA' then 'OAX'    when 'PBA' then 'PUE'   when 'QÉO' then 'QRO'    when 'QNO' then 'QROO'   when 'SPÍ' then 'SLP'
            when 'SAA' then 'SIN'    when 'SOA' then 'SON'   when 'TAO' then 'TAB'    when 'TLS' then 'TAMP'   when 'TCA' then 'TLAX'
            when 'VIE' then 'VER'    when 'YAN' then 'YUC'   when 'ZTS' then 'ZAC'           
            else '' end Estado,    
       isnull(left(replace(isnull(pc.codpostalfam,pc.codpostalneg),'_',''),5),'') CP, 
       '' FechaResidencia,
       isnull(left(replace(isnull(pc.TelefonoDirFamPri,pc.TelefonoDirNegPri),'_',''),20),'') NumeroTelefono,
       '' TipoDomicilio,
       '' TipoAsentamiento,
       '' NombreEmpresa,
       '' Direccion,
       '' ColoniaPoblacion,
       '' DelegacionMunicipio,
       '' Ciudad,
       '' Estado,
       '' CP,
       '' NumeroTelefono,
       '' Extension,
       '' Fax,
       '' Puesto,
       '' FechaContratacion,
       '' ClaveMoneda,
       '' SalarioMensual,
       '' FechaUltimoDiaEmpleo,
       '' FechaVerificacionEmpleo,
       '0003420046' ClaveActualOtorgante,
       'FINAMIGO' NombreOtorgante,
       n.CodPrestamo + '-' +n.codusuario CuentaActual,
       --replace('-','',n.CodPrestamo)+''+n.Codusuario CuentaActual,
       --case when p.codproducto = '156' 
       case when c.codgrupo IS NOT NULL or c.codgrupo <> '' --'156' 
            then 'O' else case rtrim(n.Tipo)
                               when 'CanceladosC' then 'M'
                               when 'CanceladosA' then 'A' 
                               when 'CanceladosT' then 'I'
                    end end  TipoResponsabilidad,         
       case when p.codproducto = '304' then 'P' else 'Q' end TipoCuenta,
       case p.codproducto 
            when '156' then 'GS' 
            when '123' then 'MC'
            when '302' then 'CP'
            else 'PQ' end TipoContrato,
       'MX' ClaveUnidadMonetaria,
       '' ValorActivoValuacion,
       c.NroCuotas NumeroPagos,
       mp.ModalidadPlazo FrecuenciaPagos,    --c.NrodiasEntreCuotas FrecuenciaPagos
       0 MontoPagar, --coalesce(mo.MontoPagar,0) MontoPagar,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaAperturaCuenta,
       isnull(dbo.fduFechaATexto(c.FechaUltimoMovimiento,'AAAAMMDD'),'') FechaUltimoPago,
       dbo.fduFechaATexto(c.FechaDesembolso,'AAAAMMDD') FechaUltimaCompra,
       case when uc.FecUltCuota = '19000101' then dbo.fduFechaATexto(pcd.Cancelacion,'AAAAMMDD') else dbo.fduFechaATexto(uc.FecUltCuota,'AAAAMMDD') end FechaCierreCuenta,
       isnull(dbo.fduFechaATexto(pcd.FechaCorte,'AAAAMMDD'),'') FechaCorte, --select fechacorte,* from tcscarteradet
	   '' AS Garantia, 
     --c.MontoDesembolso CreditoMaximo,       
       coalesce(cm.CreditoMaximo, cd.MontoDesembolso) CreditoMaximo,
       0 SaldoActual,--ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0) SaldoActual,
       --cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido SaldoActual,
       cd.MontoDesembolso LimiteCredito,
       0 SaldoVencido, --coalesce(Vencido.SaldoVencido,0) SaldoVencido, --cd.CapitalVencido + cd.InteresVencido + cd.MoratorioVencido SaldoVencido,
	   0 NumeroPagosVencidos, --c.CuotaActual - c.NroCuotasPagadas NumeroPagosVencidos,
	   CASE WHEN (CuotaActual - NroCuotasPagadas) = 0
	        THEN 'V'
	        ELSE case when CuotaActual - NroCuotasPagadas >= 84 then '84' 
	                  else convert(char(2),case when len(CuotaActual - NroCuotasPagadas) = 1 
	                  then '0'+convert(char(1),(CuotaActual - NroCuotasPagadas))
	                  else convert(char(5),CuotaActual - NroCuotasPagadas) end) end
	        END PagoActual,
	   '' HistoricoPagos,
	   '' ClavePrevencion,
	   '' TotalPagosReportados,
	   '' ClaveAnteriorOtorgante,
	   '' NombreAnteriorOtorgante,
	   '' NumeroCuentaAnterior,
	   COALESCE(dbo.fduFechaATexto(fi.FecPrimVenc,'AAAAMMDD'),'') FechaPrimerIncumplimiento,
       0 SaldoInsoluto--ROUND(isnull(c.SaldoCapital,0), 0) SaldoInsoluto--CASE WHEN n.Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(c.SaldoCapital,0), 0) END AS SaldoInsoluto
       --coalesce(mu.MtoUltPago,0) MontoUltimoPago
  FROM #Nombres n 
    --select * from tCsPadronCarteraDet where codprestamo ='074-304-06-07-00045'
 INNER JOIN tCsPadronCarteraDet pcd ON pcd.CodPrestamo = n.CodPrestamo and pcd.codusuario = n.codusuarioorigen
 INNER JOIN tCsCartera c with(nolock) ON c.CodPrestamo = pcd.CodPrestamo AND c.Fecha = pcd.FechaCorte   
 INNER JOIN tCsCarteraDet cd with(nolock) ON c.fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo and c.codusuario = cd.codusuario--n.codusuarioorigen
 INNER JOIN tCsPadronClientes pc with(nolock) ON n.codusuarioorigen = pc.CodUsuario  
 INNER JOIN tClOficinas       o with(nolock) ON o.codoficina  = c.codoficina 
 INNER JOIN tCaProducto       p with(nolock) ON c.codproducto = p.codproducto
 LEFT OUTER JOIN tUsClTipoPropiedad v with(nolock) ON ISNULL(pc.TipoPropiedadDirFam, pc.TipoPropiedadDirNeg) = v.CodTipoPro  --#DatosCartera.TipoDeVivienda = v.CodTipoPro
 LEFT OUTER JOIN tUsClSexo            s with(nolock) ON pc.Sexo            = s.Sexo
 LEFT OUTER JOIN tClUbiGeo Colo with(nolock) ON Colo.CodUbiGeo = ISNULL(pc.CodUbiGeoDirFamPri, pc.CodUbiGeoDirNegPri) 
 LEFT OUTER JOIN tClUbiGeo estado with(nolock) ON SUBSTRING(SUBSTRING(Colo.CodArbolConta, 1, 19), 1, 13)=estado.CodArbolConta          
 LEFT OUTER JOIN tClUbiGeo with(nolock) ON SUBSTRING(Colo.CodArbolConta, 1, 19) = tClUbiGeo.CodArbolConta      
 LEFT OUTER JOIN tCaClModalidadPlazo mp with(nolock) ON mp.ModalidadPlazo = c.ModalidadPlazo   
 LEFT OUTER JOIN #FecPrimerInc fi ON n.CodPrestamo = fi.CodPrestamo
 LEFT OUTER JOIN #CreditoMaximo cm ON cd.CodUsuario = cm.CodUsuario
 LEFT OUTER JOIN #FecUltCuota uc ON cd.CodPrestamo = uc.CodPrestamo
 --LEFT OUTER JOIN #MtoUltPago mu ON cd.CodPrestamo = mu.CodPrestamo  and cd.CodUsuario = mu.CodUsuario
 where n.tipo like '%Cancelado%' -- 2056
--   and n.codprestamo in ('026-158-06-00-00261','026-156-06-00-00400','026-158-06-02-00056','026-158-06-02-00056','026-156-06-00-00400','026-158-06-00-00261','026-156-06-00-00400','026-158-06-02-00056','026-156-06-00-00400')
 --order by n.codusuario, n.codprestamo
--select * from tCsBuroxTblReICue where codprestamo in ('026-158-06-00-00261','026-156-06-00-00400','026-158-06-02-00056','026-158-06-02-00056','026-156-06-00-00400','026-158-06-00-00261','026-156-06-00-00400','026-158-06-02-00056','026-156-06-00-00400') order by responsabilidad, claveusuario, codprestamo


/*
drop table #Nombres  
drop table #tCsMesPlanCuotas  
drop table #FecPrimerInc  
drop table #MontoPagar
drop table #CreditoMaximo
drop table #SaldoVencido
drop table #FecUltCuota
--drop table #DatosCirculo
*/
/*
select * from #Nombres where codprestamo = '014-158-06-02-00275'
select tipo,tiporesponsabilidad, * from #DatosCirculo where cuentaactual like '%014-158-06-02-00275%'
select * from #DatosCirculo where cuentaactual like '%074-304-06-07-00045%' 
select * from #MontoPagar where codprestamo = '074-304-06-07-00045' 
select * from tCsPadronPlanCuotas where codprestamo = '074-304-06-07-00045' and seccuota = 1
   -AAA1708801
*/

--drop table #MtoUltPago 

--TOTALES FINAL

--select * from #DatosCirculo where SaldoActual < SaldoInsoluto
--/*
SELECT --case when charindex(' ',replace(Direccion,'_','')) = 0 then Direccion + ' SN' else Direccion end Direccion,--MONTOPAGAR, SALDOACTUAL,--SaldoVencido, pagoactual,case when TipoResponsabilidad in ('A','I') then replace(left(CuentaActual,20),'-','') else replace(replace(CuentaActual,'Ñ','N'),'-','') end CuentaActual,
       --tipo, cuentaactual as cta,saldoactual, saldoinsoluto,
       dc.ClaveOtorgante, dc.NombreOtorgante, dc.IdentificadorDeMedio, dc.FechaExtraccion, dc.NotaOtorgante, dc.NumVersion, 
       case when dc.ApellidoPaterno = '' then dc.ApellidoMaterno else replace(dc.ApellidoPaterno,'Ñ','N') end ApellidoPaterno,
       case when dc.ApellidoPaterno = '' then 'no proporcionado' else replace(dc.ApellidoMaterno,'Ñ','N') end ApellidoMaterno, 
       dc.ApellidoAdicional, dc.Nombres, dc.FechaNacimiento, replace(dc.RFC,'Ñ','N') RFC, dc.CURP, dc.Nacionalidad, dc.Residencia, 
       dc.NumeroLicenciaConducir, case when dc.EstadoCivil = 'U' then 'L' else dc.EstadoCivil end EstadoCivil, dc.Sexo, dc.ClaveElectorIFE, 
       dc.NumeroDependientes, dc.FechaDefuncion, dc.IndicadorDefuncion, dc.TipoPersona, 
       case when charindex(' ',replace(dc.Direccion,'_','')) = 0 then dc.Direccion + ' SN' else replace(dc.Direccion,'_','') end Direccion,
       dc.ColoniaPoblacion, dc.Delegacion, dc.Ciudad, dc.Estado, dc.CP, dc.FechaResidencia, 
       case when dc.NumeroTelefono = '0' or dc.NumeroTelefono = '' then 'no proporcionado' else dc.NumeroTelefono end NumeroTelefono, 
       dc.TipoDomicilio, dc.TipoAsentamiento, dc.NombreEmpresa, dc.DireccionE, dc.ColoniaPoblacionE, dc.DelegacionMunicipio, dc.CiudadE, dc.EstadoE, 
       dc.CP_E, dc.NumeroTelefonoE, dc.ExtensionE, dc.Fax, dc.PuestoE, dc.FechaContratacion, dc.ClaveMoneda, dc.SalarioMensual,
       dc.FechaUltimoDiaEmpleo, dc.FechaVerificacionEmpleo, dc.ClaveActualOtorgante, dc.NombreOtorgante2, 
       case when dc.TipoResponsabilidad in ('A','I') then replace(left(dc.CuentaActual,20),'-','') else replace(replace(dc.CuentaActual,'Ñ','N'),'-','') end CuentaActual,
       dc.TipoResponsabilidad, dc.TipoCuenta, dc.TipoContrato, dc.ClaveUnidadMonetaria, dc.ValorActivoValuacion, dc.NumeroPagos, dc.FrecuenciaPagos,
       dc.MontoPagar, dc.FechaAperturaCuenta, dc.FechaUltimoPago, dc.FechaUltimaCompra, 
       case when dc.FechaCierreCuenta = '' or dc.FechaCierreCuenta = '19000101' then '' else dc.FechaCierreCuenta end FechaCierreCuenta,
       dc.FechaCorte, dc.Garantia, dc.CreditoMaximo, case when dc.MontoPagar = 0 then 0 else dc.SaldoActual end SaldoActual, 
       dc.LimiteCredito, SaldoVencido, dc.NumeroPagosVencidos,
       case when dc.SaldoVencido = 0 then 'V' else dc.PagoActual end PagoActual, dc.HistoricoPagos, dc.ClavePrevencion, dc.TotalPagosReportados, 
       dc.ClaveAnteriorOtorgante, dc.NombreAnteriorOtorgante, dc.NumeroCuentaAnterior,
       dc.FechaPrimerIncumplimiento, case when dc.MontoPagar = 0 then 0 else dc.SaldoInsoluto end SaldoInsoluto, --MontoUltimoPago
       TotalSaldosActuales, TotalSaldosVencidos, TotalElementosNombreReportados, TotalElementosDireccionReportados,
       TotalElementosEmpleoReportados, TotalElementosCuentaReportados, Total.NombreOtorgante N, DomicilioDevolucion
  into #x
  FROM #DatosCirculo dc, (SELECT SUM(SaldoActual)    TotalSaldosActuales,
       SUM(SaldoVencido)   TotalSaldosVencidos,
       COUNT(Nombres)      TotalElementosNombreReportados,
       COUNT(Direccion)    TotalElementosDireccionReportados,
       0                   TotalElementosEmpleoReportados,
       COUNT(CuentaActual) TotalElementosCuentaReportados,
       NombreOtorgante,
       (Select Direccion From tcloficinas Where codoficina = '98') DomicilioDevolucion
          FROM #DatosCirculo
         GROUP BY NombreOtorgante) Total   
         where Direccion <> '' AND CP <> ''
--and cuentaactual like '%021-123-06-04-00060%'
select * from #x
GO