SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsPatmirHoja2Creditos
--EXEC pCsPatmirHoja2Creditos '20140101', '20140131'
CREATE PROCEDURE [dbo].[pCsPatmirHoja2Creditos]
               ( @FecIni SMALLDATETIME ,
                 @FecFin SMALLDATETIME )
AS                    

--DECLARE @fecini SMALLDATETIME
--DECLARE @fecfin SMALLDATETIME
--SET @fecini='20140601'
--SET @fecfin='20140630'

DECLARE @Fecha 	 SMALLDATETIME
DECLARE @Periodo VARCHAR(6)
    SET @Fecha   = @FecFin --'20130831'
    SET @Periodo = dbo.fduFechaAperiodo(@Fecha)
    
    /************************************ nuevo ******************************************/
    SELECT     CodPrestamo, CodUsuario, SUM(InteresDevengado) AS DevengadoMes, AVG(InteresDevengado) AS DevengadoPromedio
    into #prestamos1
                            FROM          tCsCarteraDet with(nolock)
                            WHERE      fecha between @fecini and @fecfin 
                            GROUP BY CodPrestamo, CodUsuario
                            
    SELECT     Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimaCapital, SUM(tCsPagoDet.MontoPagado) AS MontoUltimoCapital
into #prestamos
                            FROM          (SELECT     CodPrestamo, CodUsuario, MAX(Fecha) AS FechaUltimaCapital
                                                    FROM          tCsPagoDet with(nolock)
                                                    WHERE      (Fecha <= @Fecha) AND (CodConcepto IN ('CAPI') AND extornado = 0)
                                                    GROUP BY CodPrestamo, CodUsuario) Datos INNER JOIN
                                                   tCsPagoDet with(nolock) ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPagoDet.CodPrestamo AND 
                                                   Datos.FechaUltimaCapital = tCsPagoDet.Fecha AND 
                                                   Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPagoDet.CodUsuario
                            WHERE      (tCsPagoDet.CodConcepto IN ('CAPI')) AND extornado = 0
                            GROUP BY Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimaCapital
                            
                            SELECT     Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimoInteres, SUM(tCsPagoDet.MontoPagado) AS MontoUltimoInteres
into #pagodet1 
                            FROM          (SELECT     CodPrestamo, CodUsuario, MAX(Fecha) AS FechaUltimoInteres
                                                    FROM          tCsPagoDet
                                                    WHERE      (Fecha <= @Fecha) AND (CodConcepto IN ('INTE', 'INPE') AND extornado = 0)
                                                    GROUP BY CodPrestamo, CodUsuario) Datos INNER JOIN
                                                   tCsPagoDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPagoDet.CodPrestamo AND 
                                                   Datos.FechaUltimoInteres = tCsPagoDet.Fecha AND 
                                                   Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPagoDet.CodUsuario
                            WHERE      (tCsPagoDet.CodConcepto IN ('INTE', 'INPE')) AND extornado = 0
                            GROUP BY Datos.CodPrestamo, Datos.CodUsuario, Datos.FechaUltimoInteres
    
    /************************************ nuevo ******************************************/
    
    
    
SELECT DISTINCT 
                      tCsCarteraDet.Fecha, YEAR(tCsCarteraDet.Fecha) AS Año, MONTH(tCsCarteraDet.Fecha) AS Mes, tCsPadronClientes.NombreCompleto, 
                      tCsCarteraDet.CodUsuario, tCsCartera.CodOficina, tClOficinas.NomOficina, tCsCartera.CodProducto, tCsCarteraDet.CodPrestamo, 
                      tCaClTecnologia.NombreTec AS Tecnologia, tCaProdPerTipoCredito.Descripcion AS TipoCredito, 
                      CASE tCsCartera.Condonado WHEN 1 THEN 'Con Condonacion' WHEN 0 THEN 'Pago Periodico' ELSE 'No Especifica' END AS Condicion, 
                      tCsCartera.FechaDesembolso, tCsCarteraDet.MontoDesembolso, tCsCartera.FechaVencimiento, tCsCartera.TasaIntCorriente, 
                      tCsCartera.TasaINPE AS TasaIntMora, CASE tCsCartera.ModalidadPlazo WHEN 'M' THEN 'MENSUAL' ELSE 'No Identificado' END AS Frecuencia, 
                      tCsCartera.NroDiasAtraso, 
		              CapitalVigente = Case 	When tCsCartera.Estado = 'VIGENTE' Then tCsCarteraDet.SaldoCapital Else 0 End,
		              CapitalVencido = Case 	When tCsCartera.Estado = 'VENCIDO' Then tCsCarteraDet.SaldoCapital Else 0 End ,
                      tCsCarteraDet.InteresVigente, 
                      tCsCarteraDet.InteresVencido, 
                      tCsCarteraDet.InteresCtaOrden AS CtaOrdInteres, 
                      tCsCarteraDet.MoratorioCtaOrden AS CtaOrdMoratorio, InteresDevengado.DevengadoPromedio, 
                      InteresDevengado.DevengadoMes, 
                      CASE WHEN preservainteres <> 100 THEN tCsCarteraDet.SReservaInteres + tCsCarteraDet.SReservaCapital ELSE tCsCarteraDet.SReservaCapital END
                       AS ReservaPreventiva, CASE WHEN preservainteres = 100 THEN tCsCarteraDet.SReservaInteres ELSE 0 END AS ReservaP100Interes, 
                      UltimoCapital.FechaUltimaCapital, UltimoInteres.FechaUltimoInteres, UltimoCapital.MontoUltimoCapital, UltimoInteres.MontoUltimoInteres, 
                      tCsCartera.Estado, CASE WHEN tCsCartera.TipoReprog IN ('SINRE') THEN 'Normal' WHEN tCsCartera.TipoReprog IN ('REPRO') 
                      THEN 'Reestructurado' ELSE 'No Especificado' END AS Reestructurado, tCsCartera.NumReprog, Garantia.DescGarantia, Garantia.Garantia, 
                      ISNULL(Garantia.Formalizada, 'NO') AS Formalizada, tClFondos.NemFondo, 
                      tCsCarteraDet.SReservaCapital + tCsCarteraDet.SReservaInteres AS EPreventiva, tCsCarteraDet.CargoMora, Mora.PagoXMora, Comision.Comision, 
                      tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, tCsCartera.CodAsesor, tCsPadronClientes_1.NombreCompleto AS Expr1
Into #BBBBB
FROM         tCaProducto INNER JOIN
                      tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia RIGHT OUTER JOIN
                      tCsCartera LEFT OUTER JOIN
                      tCsPadronClientes tCsPadronClientes_1 ON tCsCartera.CodAsesor = tCsPadronClientes_1.CodUsuario ON 
                      tCaProducto.CodProducto = tCsCartera.CodProducto LEFT OUTER JOIN
                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
                          ( SELECT     CodPrestamo, SUM(TotalPagado) AS Comision
                            FROM          tCsConceptosPrestamo
                            WHERE      (TipoCobro = 'A') AND (RTRIM(LTRIM(ConceptoDeCalculo)) IN ('', NULL))
                            GROUP BY CodPrestamo) Comision ON tCsCartera.CodPrestamo = Comision.CodPrestamo COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
                          (SELECT     Datos.Codigo, Datos.TipoGarantia, Filtro.Garantia, tGaClTipoGarantias.DescGarantia, Formalizada = 'SI'
                            FROM          (SELECT     Codigo, MAX(Garantia) AS Garantia
                                                    FROM          (SELECT     Codigo, TipoGarantia, SUM(MoComercial) AS Garantia
                                                                            FROM          tCsGarantias
                                                                            WHERE      (EstGarantia NOT IN ('INACTIVO'))
                                                                            GROUP BY Codigo, TipoGarantia) Datos
                                                    GROUP BY Codigo) Filtro INNER JOIN
                                                       (SELECT     Codigo, TipoGarantia, SUM(MoComercial) AS Garantia
                                                         FROM          tCsGarantias
                                                         WHERE      (EstGarantia NOT IN ('INACTIVO'))
                                                         GROUP BY Codigo, TipoGarantia) Datos ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia LEFT OUTER JOIN
                                                   tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia) Garantia ON 
                      tCsCartera.CodPrestamo = Garantia.Codigo COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
                      tCaClProvision ON tCsCartera.Estado = tCaClProvision.Estado AND tCsCartera.NroDiasAtraso >= tCaClProvision.DiasMinimo AND 
                      tCsCartera.NroDiasAtraso <= tCaClProvision.DiasMaximo RIGHT OUTER JOIN
                         
                          (select * from #prestamos1) 
                         
                          InteresDevengado RIGHT OUTER JOIN
                         
                          (select * from #pagodet1) 
                          
                          UltimoInteres RIGHT OUTER JOIN
                      tCsCarteraDet LEFT OUTER JOIN
                          (SELECT     CodPrestamo, CodUsuario, SUM(MontoPagado) AS PagoXMora
                            FROM          tCsPagoDet
                            WHERE      (CodConcepto = 'MORA') AND (dbo.fduFechaAPeriodo(Fecha) = @Periodo)
                            GROUP BY CodPrestamo, CodUsuario)
                             Mora ON tCsCarteraDet.CodPrestamo = Mora.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
                      tCsCarteraDet.CodUsuario = Mora.CodUsuario COLLATE Modern_Spanish_CI_AI ON 
                      UltimoInteres.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo AND 
                      UltimoInteres.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodUsuario LEFT OUTER JOIN
                         
                          ( select * from #prestamos ) 
                          
                       UltimoCapital ON 
                      tCsCarteraDet.CodPrestamo = UltimoCapital.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
                      tCsCarteraDet.CodUsuario = UltimoCapital.CodUsuario COLLATE Modern_Spanish_CI_AI ON 
                      InteresDevengado.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo AND 
                      InteresDevengado.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodUsuario ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND 
                      tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN
                      tCaProdPerTipoCredito ON tCsCartera.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito LEFT OUTER JOIN
                      tCsPadronClientes ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                      tClFondos ON tCsCartera.CodFondo = tClFondos.CodFondo
--inner join #clientes c on c.codusuario=tCsCarteraDet.codusuario --and c.codcuenta=ah.codcuenta
WHERE (tCsCarteraDet.Fecha = @Fecha) --AND (tCsCartera.Estado NOT IN ('CASTIGADO'))
  AND tCsCarteraDet.codusuario IN (Select CodUsuario From tCsFondReportados Where CodFondo = 'PT')
  
SELECT DISTINCT '0468' AS FolioIF,
       cd.codusuario AS CveSocioCte,
       cd.codprestamo+'-'+cd.codusuario AS NumContrato,
       cl.codoficina AS Sucursal, 
       --pr.DestinoComentario AS ClasifCredito,--tc.DescTipoCre AS ClasifCredito,
       case when pr.DestinoComentario like '%comercial%'    then 'Comercial' 
            when pr.DestinoComentario like '%vivienda%'     then 'Vivienda' 
            when pr.DestinoComentario like '%consumo%'      then 'Consumo'
            when pr.DestinoComentario like '%prenda%'       then 'Consumo'
            when pr.DestinoComentario like '%microcredito%' then 'Microcrédito' end AS ClasifCredito,
       convert(char(3),ca.codproducto) + ' ' + pr.NombreProd AS ProdCredito,
       'Pago periodico de capital e intereses' AS ModalidadPago, --pl.DescTipoPlan 
	   replicate('0',2-len(cast(day(ca.FechaDesembolso)as varchar(2)))) + cast(day(ca.FechaDesembolso) as varchar(2)) +'/'+replicate('0',2-len(cast(month(ca.FechaDesembolso)as varchar(2)))) + cast(month(ca.FechaDesembolso) as varchar(2)) +'/'+cast(year(ca.FechaDesembolso)as char(4)) FechaOtorgamiento,
	   isnull(ca.MontoDesembolso,0) AS MontoOriginal,
       case when ca.fechavencimiento is null then '' else replicate('0',2-len(cast(day(ca.fechavencimiento)as varchar(2)))) + cast(day(ca.fechavencimiento) as varchar(2)) +'/'+replicate('0',2-len(cast(month(ca.fechavencimiento)as varchar(2)))) + cast(month(ca.fechavencimiento) as varchar(2)) +'/'+cast(year(ca.fechavencimiento)as char(4)) end FechaVencimiento,
       convert(numeric(16,1),ca.TasaIntCorriente) as TasaOrdNominalAnual,
       convert(numeric(16,1),ca.TasaINPE) as TasaMoratoriaNominalAnual,
       case when ca.ModalidadPlazo = 'A' then ca.NroCuotas * 12
            when ca.ModalidadPlazo = 'D' and ca.NroCuotas <= 30 then 1
            when ca.ModalidadPlazo = 'D' and ca.NroCuotas > 30 then convert(numeric(16),ca.NroCuotas/30)
            when ca.ModalidadPlazo = 'M' then ca.NroCuotas 
            when ca.ModalidadPlazo = 'Q' then ca.NroCuotas * 2
            when ca.ModalidadPlazo = 'S' then ca.NroCuotas * 4 end AS PlazoCredito, 
       --tp.desctipoplaz as PlazoCredito, -- SELECT * FROM tCAClTipoPlaz
       case when ca.ModalidadPlazo = 'A' then 30
            when ca.ModalidadPlazo = 'D' then 30
            when ca.ModalidadPlazo = 'M' then 30 
            when ca.ModalidadPlazo = 'Q' then 15
            when ca.ModalidadPlazo = 'S' then 7 end AS FrecPagoCapital, 
       --isnull(tp.DiaTipoPlaz,30) as FrecPagoCapital,
       case when ca.ModalidadPlazo = 'A' then 30
            when ca.ModalidadPlazo = 'D' then 30
            when ca.ModalidadPlazo = 'M' then 30 
            when ca.ModalidadPlazo = 'Q' then 15
            when ca.ModalidadPlazo = 'S' then 7 end AS FrecPagoInteres, 
       --isnull(tp.DiaTipoPlaz,30) as FrecPagoInteres,
       isnull(ca.NroDiasAtraso,0) as DiasMora,
	   CapitalVigente = Case 	When ca.Estado = 'VIGENTE' OR ca.Estado = 'CASTIGADO' Then isnull(cd.SaldoCapital,0) Else 0 End,
	   CapitalVencido = Case 	When ca.Estado = 'VENCIDO' Then isnull(cd.SaldoCapital,0) Else 0 End ,
       isnull(cd.InteresVigente,0)  as IntDevengNoCobradVigente,
       isnull(cd.InteresVencido,0)  as IntDevengNoCobradVencidos,
       isnull(cd.InteresCtaOrden,0) as IntDevengNoCobradCtasOrden,
       --replicate('0',2-len(cast(day(cd.UltimoMovimiento)as varchar(2)))) + cast(day(cd.UltimoMovimiento) as varchar(2)) +'/'+replicate('0',2-len(cast(month(cd.UltimoMovimiento)as varchar(2)))) + cast(month(cd.UltimoMovimiento) as varchar(2)) +'/'+cast(year(cd.UltimoMovimiento)as char(4)) as FechaUltPagoCapital,
       isnull(replicate('0',2-len(cast(day(tt.FechaUltimaCapital)as varchar(2)))) + cast(day(tt.FechaUltimaCapital) as varchar(2)) +'/'+replicate('0',2-len(cast(month(tt.FechaUltimaCapital)as varchar(2)))) + cast(month(tt.FechaUltimaCapital) as varchar(2)) +'/'+cast(year(tt.FechaUltimaCapital)as char(4)),'') as FechaUltPagoCapital,
       isnull(tt.MontoUltimoCapital,0) as MontoUltPagoCapital,
       isnull(replicate('0',2-len(cast(day(tt.FechaUltimoInteres)as varchar(2)))) + cast(day(tt.FechaUltimoInteres) as varchar(2)) +'/'+replicate('0',2-len(cast(month(tt.FechaUltimoInteres)as varchar(2)))) + cast(month(tt.FechaUltimoInteres) as varchar(2)) +'/'+cast(year(tt.FechaUltimoInteres)as char(4)),'') AS FechaUltPagoIntereses,
       isnull(tt.MontoUltimoInteres,0)  AS MontoUltPagoIntereses,
       CASE WHEN ca.TipoReprog IN ('SINRE') THEN 'Normal' WHEN ca.TipoReprog IN ('REPRO') THEN 'Reestructurado' ELSE 'Normal' END AS RenovEstrucNorm,
       case when ca.Estado = 'VENCIDO' then 'Vencido' else 'Vigente' end as VigenteVencido,
       isnull(ca.TotalGarantia,0) AS MontoGarantiaLiquida,
       'Saldos Insolutos' AS TipoTasaOrdNormal,
       ' ' TipoGarantiaAdic,
       ' ' as MontoGarantiaAdic,
       isnull(s.NombreCompleto,'PEREZ MORALES EDITH JOSSIANI') AS AsesorCredito
  into #Hoja2     
  FROM tcscarteradet cd with(nolock) 
 /*inner join (select ultimodia from tclperiodo with(nolock)
              where ultimodia>=@fecini--ultimodia=@fecfin --ultimodia>=@fecini --and ultimodia=@fecfin '
             ) p on cd.fecha=p.ultimodia*/
--inner join #clientes c on c.codusuario=cd.codusuario --and c.codcuenta=ah.codcuenta
inner join tcscartera ca with(nolock) on ca.codprestamo=cd.codprestamo and ca.fecha=cd.fecha
inner join tcspadronclientes cl with(nolock) on cl.codusuario=ca.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=cl.codoficina
inner join tcaproducto pr with(nolock) on ca.codproducto = pr.codproducto
--left outer join tCaClTipoPlan pl with(nolock) on ca. = pl.CodTipoPlan
inner join tCAClTipoPlaz tp with(nolock) on ca.ModalidadPlazo = tp.CodTipoPlaz
inner join #BBBBB tt with(nolock) on ca.codusuario = tt.codusuario and ca.codprestamo = tt.codprestamo
left outer join tsgusuarios s ON cl.CodUsResp = s.CodUsuario
where cd.fecha = @Fecha--'20130831' --398
and cd.codusuario IN (Select CodUsuario From tCsFondReportados Where CodFondo = 'PT') --(select cvesociocte from #hoja11)

SELECT * FROM #Hoja2 


DROP TABLE #BBBBB
DROP TABLE #Hoja2 
drop table #prestamos
drop table #prestamos1
drop table #pagodet1 
GO