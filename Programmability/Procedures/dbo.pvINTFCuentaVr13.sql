SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pvINTFCuentaVr13] @fecha smalldatetime AS
	SET NOCOUNT ON

--declare @fecha smalldatetime  --COMENTAR
--set @fecha = '20161031'   --COMENTAR

create table #tblmop(
  codprestamo char(19),
  codusuario  varchar(15),
  numeroplan  tinyint,
  seccuota    smallint,
  MOP         varchar(3)
)

insert into #tblmop
SELECT DISTINCT PC.CodPrestamo, PC.CodUsuario, PC.NumeroPlan, PC.SecCuota, 
       CASE WHEN substring(PC.codprestamo, 5, 3) = '303' THEN '01' ELSE B.MOP END MOP
FROM tCsPadronPlanCuotas PC with(nolock) 
INNER JOIN tCsBuroMOP B ON PC.DiasAtrCuota >= B.Inicio AND PC.DiasAtrCuota <= B.Fin
where PC.FechaVencimiento <= @fecha--demora 29seg; 972,383reg

---------------------------------------------------------------------------------------
create table #tblmesgar(
  fecha         smalldatetime,
  codigo        varchar(25),
  ImporteAvaluo money,
  DescGarantia  varchar(300)
)

insert into #tblmesgar
SELECT Filtro.Fecha, Datos.Codigo, sum(Filtro.Garantia) AS ImporteAvaluo ,'CREDITO GARANTIZADO' DescGarantia
       --, tGaClTipoGarantias.DescGarantia
FROM (
    SELECT Fecha, Codigo, MAX(Garantia) AS Garantia
    FROM (
        SELECT Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
        FROM tCsMesGarantias tCsGarantias with(nolock)
        WHERE (Estgarantia NOT IN ('INACTIVO')) and fecha=@fecha
        GROUP BY Fecha, Codigo, TipoGarantia
    ) Datos
    GROUP BY Fecha, Codigo
) Filtro 
INNER JOIN (
    SELECT Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
    FROM tCsMesGarantias tCsGarantias with(nolock)
    WHERE (Estgarantia NOT IN ('INACTIVO')) and fecha=@fecha
    GROUP BY FEcha, Codigo, TipoGarantia
) Datos ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND Filtro.Fecha = Datos.Fecha 
LEFT JOIN tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia
group by Filtro.Fecha, Datos.Codigo

--------------------------------------------------------------------------------------
create table #tCsMesPlanCuotas(
  fecha          smalldatetime,
  codprestamo    char(19),
  MontoDevengado money,
  MontoPagado    money,
  MontoCondonado money,
  DiasAtrCuota   smallint
)

insert into #tCsMesPlanCuotas
SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, 
       CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
FROM tCsMesPlanCuotas with(nolock) --demora 01:32 min
WHERE CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE') AND EstadoConcepto NOT IN ('ANULADO', 'CANCELADO')
and fecha=@fecha

--------------------------------------------------------------------------------------
create table #PrimerIncumplimiento(
  codprestamo char(19),
  fechapi     smalldatetime
)

insert into #PrimerIncumplimiento
SELECT CodPrestamo, min(fechavencimiento) fechavencimiento
FROM tCsPadronPlanCuotas with(nolock) --demora 00:01 min tCsMesPlanCuotas
WHERE CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')
and DiasAtrCuota > 0
and fechavencimiento <= @fecha
group by CodPrestamo

--OJO
--create table #PaseVencido(codprestamo varchar(25),fechavencido smalldatetime)
--insert into #PaseVencido
--SELECT CodPrestamo, MAX(Fecha) AS Fecha
--FROM (
--		SELECT DISTINCT CodPrestamo, Estado,fecha
--        FROM tCsCartera with(nolock)
--		where codprestamo in (select codprestamo from tCsBuroxTblReInom)
--		and Estado = 'VENCIDO' and nrodiasatraso=90
--		and fecha<=@fecha--'20151031'
--) T 
--GROUP BY CodPrestamo, Estado

-------------------------------------------------------------------------------------
create table #MontoUltPago (
	fecha   datetime,
    codprestamo  char(19),
    montoultpago money
)

insert into #MontoUltPago
SELECT t.Fecha,
       t.CodigoCuenta codprestamo, sum(t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran) monto
FROM tCsTransaccionDiaria t with(nolock)
inner join (--7594
	select distinct b.codprestamo,c.FechaUltimoMovimiento 
	from tCsBuroxTblReINomVr13 b with(nolock) --6932
	inner join tcscartera c with(nolock) on c.codprestamo=b.codprestamo
	where c.fecha=@fecha--'20151031'
	union
	select distinct b.codprestamo,c.cancelacion FechaUltimoMovimiento
	from tCsBuroxTblReINomVr13 b with(nolock) --662
	inner join tcspadroncarteradet c with(nolock) on c.codprestamo=b.codprestamo
	where c.cancelacion<=@fecha--'20151031'
) b on t.codigocuenta=b.codprestamo
and t.fecha=b.FechaUltimoMovimiento --(CASE WHEN left(Tipo,10) = 'Cancelados' THEN t.fecha ELSE dateadd(day,-1,t.fecha) END)
where t.fecha <= @fecha--'20151031' 
and t.codsistema = 'CA' and t.TipoTransacNivel1='I' and t.TipoTransacNivel3 in(104,105) -- not in(101,100,99)
and t.extornado = 0
group by t.Fecha,t.CodigoCuenta

----------------------------------------------------------------------------------------
--<<<<<<<<<<<<<< OSC: Crea y llena la tabla de Plazo en Meses
create table #PlazoMeses(
    codprestamo varchar(25),
    meses       decimal(16,2),
    MontoDesembolso int
)

insert into #PlazoMeses
    /*
    select 
    CodPrestamo, 
    cast((datediff(d, FechaDesembolso , FechaVencimiento) / 30.4) as decimal(18, 2) ) as m2,
    convert(int,MontoDesembolso)
    from dbo.tCsCartera where fecha = @fecha
    */
select distinct b.CodPrestamo, cast((datediff(d, c.FechaDesembolso , c.FechaVencimiento) / 30.4) as decimal(18, 2) ) as m2,
       convert(int,c.MontoDesembolso)
from tCsBuroxTblReINomVr13 b with(nolock) --6932
inner join tcscartera c with(nolock) on c.codprestamo = b.codprestamo
where c.fecha = @fecha--'20151031'
and isnull(c.FechaVencimiento,'1900-01-01') <> '19000101'

union

select distinct c.CodPrestamo, cast((datediff(d, c.FechaDesembolso , c.FechaVencimiento) / 30.4) as decimal(18, 2) ) as m2,
       convert(int,c.MontoDesembolso)
from tcscartera c 
where exists(
    select 1 from tCsBuroxTblReINomVr13 b with(nolock) 
    where c.codprestamo = b.codprestamo)
and c.fecha <= @fecha
and isnull(c.FechaVencimiento,'1900-01-01') <> '19000101'

-->>>>>>>>>>>>>> OSC



------------------------------------------------------------------------------------

truncate table tCsBuroxTblReICueVr13

insert into tCsBuroxTblReICueVr13  --DESCOMENTAR

-- select  * from tCsBuroxTblReICueVr13

/************************************vINTFCuentaCartera****************************************/
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabeceraVr13.ClaveUsuario, vINTFCabeceraVr13.NombreUsuario, 
       --RESPONSABILIDAD:
       Responsabilidad = case when tCsCartera.FechaDesembolso>='20130101' 
                              then CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'C' ELSE tCaClTecnologia.Responsabilidad END
                              else CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END 
                         end,
       TipoCuenta = 'I',
       TipoContrato = case when tCsCartera.FechaDesembolso>='20130101' 
                           then case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
                           else tCaProducto.TipoContrato
                      end,
       UnidadMonetaria = CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END,
       ImporteAvaluo   = CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END,
       NumeroPagos     = CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END,
       FrecuenciaPagos = CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END, 
       MontoPagar      = CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END,
       Apertura        = CASE WHEN Tipo = 'Aval' 
                              THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                              ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END,
      -- UltimoPago      = dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA'), --OSC: se comento por el bloque de abajo, para evitar que fec apertura sea igual a fec ult pago
UltimoPago = ( CASE WHEN (CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                               ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') 
                          END) <> dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')
               		THEN
			        	dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')
	           		ELSE
			       		--'xxx'
						dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')
               		END ),
       Disposicion     = CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                              ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END,
       Cancelacion     = CASE WHEN Tipo = 'Cancelados' 
                              THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') 
                              ELSE '' END,
       Reporte         = vINTFCabeceraVr13.FechaReporte,
       Garantia        = CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END,
       CreditoMaximo.CreditoMaximo,
       SaldoActual     = CASE WHEN Tipo = 'Cancelados' THEN 0
                              ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + 0.5, 0) END, 
       LimiteCredito   = '',
       SaldoVencido    = case when tCscartera.codoficina='97' --then 0
                              then case when tCscartera.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',
		                                                                '097-303-06-04-00544', '097-303-06-06-00528',
		                                                                '097-303-06-08-00609', '097-303-06-08-00744',
		                                                                '097-303-06-09-00628')
		                                then Vencido.SaldoVencido else 0 
                                   end
                              else CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END 
                         end,
       PagosVencidos   = case when tCscartera.codoficina='97' then 0
                              else CASE WHEN tipo = 'Cancelados' 
                                        THEN 0 
                                        ELSE case when tCsCartera.NroCuotas = tCsCartera.CuotaActual and tCsCartera.NroDiasAtraso > 0 
                                                  then tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas 
                                                  else case when tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas < 0 
                                                            then 0
                                                            else tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas
                                                       end
                                             end
                                   END
                         end,
       ----MOP: Manner Of Payment
       MOP = CASE WHEN dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                       tCsCartera.FechaDesembolso = dbo.tCsCartera.FechaUltimoMovimiento THEN '00' 
                  WHEN Tipo = 'Cancelados' Then '01' 
                  WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
                  WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
                  WHEN tCscartera.Cartera = 'CASTIGADA' Then '97'
                  WHEN substring(tCscartera.codprestamo,5, 3) = '303' 
                  THEN --'01'
                       case when tCscartera.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',
           '097-303-06-04-00544', '097-303-06-06-00528',
                                                            '097-303-06-08-00609', '097-303-06-08-00744',
                                                            '097-303-06-09-00628') 
                            then tCsBuroMOP.MOP else '01' 
                       end
                  ELSE tCsBuroMOP.MOP 
             END,
       HistoricoPagos = '',
       --OBSERVACION
       Observacion    = CASE WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
                             WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
                             ELSE '' END,
       Historico.PagosReportados, 
       Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
       FprimerIncum    = case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end,
       SaldoInsoluto   = CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END,
       FinSegmento     = 'FIN',
       Montoultpago    = isnull(Moultpago.Montoultpago,0),
       PlazoMeses      = isnull(PlazoM.meses,0.00), --OSC
       MontoDesembolso = isnull(PlazoM.MontoDesembolso, 0), --OSC
       NrodiasAtraso   = isnull(tCsCartera.NrodiasAtraso,0)  --OSC
/*FROM <----------*/
FROM (
    SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
    FROM tCsPadronPlanCuotas with(nolock)
    WHERE --(SecCuota = 1)
   (SecCuota = (select max(SecCuota) from tCsPadronPlanCuotas as m where m.codprestamo = tCsPadronPlanCuotas.codprestamo))
    GROUP BY CodPrestamo) MontoPagar 
    RIGHT JOIN (
        SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
        AS MOP04, SUM(MOP05) AS MOP05
        FROM (
            SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
                   CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
                   CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
            FROM #tblmop Datos
        ) Datos
        GROUP BY CodPrestamo
    ) Historico 
    RIGHT JOIN (
        select * from tCsBuroxTblReINomVr13 where tipo='Cartera'
    ) VISTA ON Historico.CodPrestamo = VISTA.CodPrestamo  --tCsBuroxTblReINomVr13
    LEFT JOIN (
        SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido
        from #tCsMesPlanCuotas Vencido
        WHERE DiasAtrCuota = 1
        GROUP BY Fecha, CodPrestamo
    ) Vencido ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo 
    LEFT JOIN (
        SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
        FROM (--inicialmente demora 04:15min, luego me saco 25seg
            SELECT D.CodUsuario, C.FechaDesembolso, C.MontoDesembolso
            FROM tCsPadronCarteraDet D with(nolock) 
            INNER JOIN tCsCartera C with(nolock) ON D.FechaCorte = C.Fecha AND D.CodPrestamo = C.CodPrestamo
        ) Datos 
        where Datos.FechaDesembolso<=@fecha
        GROUP BY Datos.CodUsuario
    ) CreditoMaximo ON VISTA.CodUsuario = CreditoMaximo.CodUsuario
    LEFT JOIN tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo 
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario 
LEFT OUTER JOIN (
     select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar
     ) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
LEFT OUTER JOIN #MontoUltPago Moultpago on  Moultpago.codprestamo=VISTA.CodPrestamo
left outer join #PlazoMeses as PlazoM on PlazoM.codprestamo=VISTA.CodPrestamo
CROSS JOIN [FinAmigoExterno_191115].dbo.vINTFCabeceraVr13 vINTFCabeceraVr13

--where VISTA.CodPrestamo = '037-170-06-05-00988'

union

/************************************vINTFCuentaAvales****************************************/

SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabeceraVr13.ClaveUsuario, vINTFCabeceraVr13.NombreUsuario, 
        --RESPONSABILIDAD:
        case when tCsCartera.FechaDesembolso>='20130101' then
          CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'C' ELSE tCaClTecnologia.Responsabilidad END
        else
          CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END 
        end
        AS Responsabilidad,
        'I' AS TipoCuenta
        ,case when tCsCartera.FechaDesembolso>='20130101' then
          case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
        else
          tCaProducto.TipoContrato
        end 
        as TipoContrato
        , 
        CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END AS UnidadMonetaria, 
        CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
        CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
        CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
        CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar,

        CASE WHEN Tipo = 'Aval' 
             THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
             ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') 
             END AS Apertura, 
        --CASE WHEN Tipo = 'Aval' 
        --     THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
        --     ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago, 

--OSC: se comento por el bloque de abajo, para evitar que fec apertura sea igual a fec ult pago
UltimoPago = ( CASE WHEN (CASE WHEN Tipo = 'Aval' 
                               THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                               ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') 
                               END) <> 
                         (CASE WHEN Tipo = 'Aval' 
                               THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
                               ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') 
                               END)
               THEN
			        (CASE WHEN Tipo = 'Aval' 
                               THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
                               ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') 
                        END)
	           ELSE
			       --''
					dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')
               END ),

        CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
        ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion, 
        CASE WHEN Tipo = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') 
        ELSE '' END AS Cancelacion, 
        vINTFCabeceraVr13.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
        CreditoMaximo.CreditoMaximo, 
        CASE WHEN Tipo = 'Cancelados' THEN 0 
        ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE+ tCsCartera.SaldoINPE, 0) END AS SaldoActual
        , '' AS LimiteCredito,
        CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 
        PagosVencidos = CASE WHEN tipo = 'Cancelados' 
                             THEN 0 
                             ELSE case when tCsCartera.NroCuotas = tCsCartera.CuotaActual and tCsCartera.NroDiasAtraso > 0 
                                       then tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas 
                                       else case when tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas < 0 
                                                 then 0
                                                 else tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas
                                            end
                                  end
                        END, 
          ----MOP: Manner Of Payment
          CASE 
		        WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                     		       tCsCartera.FechaDesembolso = tCsCartera.FechaUltimoMovimiento THEN '00' 
		        WHEN 	Tipo = 'Cancelados' Then '01' 
		        WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
		        WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
		        WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
		        ELSE tCsBuroMOP.MOP
            END
        AS MOP
        , '' AS HistoricoPagos,
        --OBSERVACION
          CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			        WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			        ELSE '' END AS Observacion,
        Historico.PagosReportados, 
        Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta,
        case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
        CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,
        'FIN' AS FinSegmento
        ,isnull(Moultpago.Montoultpago,0) Montoultpago
        ,isnull(PlazoM.meses, 0.00) as PlazoMeses --OSC
        ,isnull(PlazoM.MontoDesembolso, 0) as MontoDesembolso, --OSC
        NrodiasAtraso   = isnull(tCsCartera.NrodiasAtraso,0)  --OSC
/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE --(SecCuota = 1)
      (SecCuota = (select max(SecCuota) from tCsPadronPlanCuotas as m where m.codprestamo = tCsPadronPlanCuotas.codprestamo))
      GROUP BY CodPrestamo) MontoPagar 
      RIGHT OUTER JOIN
            (SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
             AS MOP04, SUM(MOP05) AS MOP05
             FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
                   CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
                   CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
                   FROM (select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop) Datos
                    ) Datos
             GROUP BY CodPrestamo) Historico 
RIGHT OUTER JOIN (select * from tCsBuroxTblReINomVr13 where tipo='Aval') VISTA 
LEFT JOIN (
    SELECT Fecha, CodPrestamo, Round(SUM(MontoDevengado - MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido
    FROM #tCsMesPlanCuotas Vencido
    WHERE DiasAtrCuota = 1
    GROUP BY Fecha, CodPrestamo
) Vencido ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo 

ON Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaProducto 
ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo 
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND 
tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) 
ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario 

LEFT OUTER JOIN
     (SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
      FROM (SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
            FROM tCsPadronCarteraDet with(nolock) 
            INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            ) Datos 
      where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg
      GROUP BY Datos.CodUsuario
      ) CreditoMaximo ON CreditoMaximo.CodUsuario =tCsCartera.codusuario--VISTA.CodUsuario
LEFT OUTER JOIN (select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
LEFT OUTER JOIN #MontoUltPago Moultpago on  Moultpago.codprestamo=VISTA.CodPrestamo
left outer join #PlazoMeses as PlazoM on PlazoM.codprestamo=VISTA.CodPrestamo
CROSS JOIN [FinAmigoExterno_191115].dbo.vINTFCabeceraVr13 vINTFCabeceraVr13

union

/************************************vINTFCuentaCancelados****************************************/
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabeceraVr13.ClaveUsuario, vINTFCabeceraVr13.NombreUsuario, 
        --RESPONSABILIDAD:
        case when tCsPadronCarteraDet.desembolso>='20130101' then
          CASE Tipo WHEN 'CanceladosT' THEN tCaClTecnologia.Responsabilidad WHEN 'CanceladosA' THEN 'C' WHEN 'CanceladosC' THEN 'C' ELSE '' END
        else
          CASE Tipo WHEN 'CanceladosT' THEN tCaClTecnologia.Responsabilidad WHEN 'CanceladosA' THEN 'C' WHEN 'CanceladosC' THEN 'J' ELSE '' END
        end
        AS Responsabilidad,
        'I' AS TipoCuenta
        ,case when tCsPadronCarteraDet.desembolso>='20130101' then
          case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
        else
          tCaProducto.TipoContrato
        end as TipoContrato
        , CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END AS UnidadMonetaria, 
        CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
        CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
        CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
        CASE WHEN left(Tipo,10) = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, 
        CASE WHEN Tipo = 'Aval' 
             THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
             ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') 
             END AS Apertura, 

       -- CASE WHEN Tipo = 'Aval' 
       --      THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
       --      ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago,

UltimoPago = ( CASE WHEN (CASE WHEN Tipo = 'Aval' 
                               THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                               ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') 
                          END) <> 
                         (CASE WHEN Tipo = 'Aval' 
                               THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
                               ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') 
                          END)
               THEN
			        (CASE WHEN Tipo = 'Aval' 
                          THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
                          ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') 
                     END)
	           ELSE
			       --''
					dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')
               END ),
 
        CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
        ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion, 
        CASE WHEN left(Tipo,10) = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') ELSE '' END AS Cancelacion, 
        vINTFCabeceraVr13.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
        CreditoMaximo.CreditoMaximo, 
        SaldoActual = CASE WHEN left(Tipo,10) = 'Cancelados' 
                           THEN 0 
                           ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + 0.5, 0)
                      END,
        '' AS LimiteCredito, 
        CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 

  PagosVencidos = CASE WHEN left(Tipo,10) = 'Cancelados' 
                             THEN 0 
                             ELSE case when tCsCartera.NroCuotas = tCsCartera.CuotaActual and tCsCartera.NroDiasAtraso > 0 
                                       then tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas 
                                       else case when tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas < 0 
                                                 then 0
                                                 else tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas
                                            end
                                  end
                        END,
        ----MOP: Manner Of Payment
        CASE 
	        WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                   		         tCsCartera.FechaDesembolso = tCsCartera.FechaUltimoMovimiento THEN '00' 
	      WHEN 	left(Tipo,10) = 'Cancelados' Then '01' 
	        WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
	        WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
	        WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'		
	        ELSE 	tCsBuroMOP.MOP END AS MOP, '' AS HistoricoPagos, 
        --OBSERVACION
        CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			        WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			        ELSE '' END AS Observacion, 
        Historico.PagosReportados, 
        Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
        case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
        CASE WHEN --Tipo = 'Cancelados' 
		left(Tipo,10) = 'Cancelados'
		THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,
        'FIN' AS FinSegmento
        ,isnull(Moultpago.Montoultpago,0) Montoultpago
        ,isnull(PlazoM.meses, 0.00) as PlazoMeses  --OSC
        ,isnull(PlazoM.MontoDesembolso, 0) as MontoDesembolso, --OSC
        NrodiasAtraso   = isnull(tCsCartera.NrodiasAtraso,0)  --OSC

/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE --(SecCuota = 1)
      (SecCuota = (select max(SecCuota) from tCsPadronPlanCuotas as m where m.codprestamo = tCsPadronPlanCuotas.codprestamo))
      GROUP BY CodPrestamo) MontoPagar 
      RIGHT OUTER JOIN
      (
      SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) AS MOP04, SUM(MOP05) AS MOP05
      FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
            CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
            CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
            FROM (select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop) Datos
            ) Datos
            GROUP BY CodPrestamo) Historico 
RIGHT OUTER JOIN (select * from tCsBuroxTblReINomVr13 where tipo IN('CanceladosT','CanceladosC','CanceladosA')) VISTA 
LEFT JOIN (
    SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido
    FROM #tCsMesPlanCuotas Vencido
    WHERE DiasAtrCuota = 1
    GROUP BY Fecha, CodPrestamo
) Vencido ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo 

ON Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo 
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) 
ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo

LEFT OUTER JOIN
     (SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
      FROM (
            SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
            FROM tCsPadronCarteraDet with(nolock)             
            INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            ) Datos 
      where Datos.FechaDesembolso<=@fecha
      GROUP BY Datos.CodUsuario) CreditoMaximo ON CreditoMaximo.CodUsuario = tCsPadronCarteraDet.codusuario
LEFT OUTER JOIN
     (select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
LEFT OUTER JOIN #MontoUltPago Moultpago on  Moultpago.codprestamo=VISTA.CodPrestamo
left outer join #PlazoMeses as PlazoM on PlazoM.codprestamo=VISTA.CodPrestamo
CROSS JOIN [FinAmigoExterno_191115].dbo.vINTFCabeceraVr13 vINTFCabeceraVr13

union


/************************************vINTFCuentaCodeudores****************************************/
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabeceraVr13.ClaveUsuario, vINTFCabeceraVr13.NombreUsuario, 
        --RESPONSABILIDAD:
        case when tCsCartera.FechaDesembolso>='20130101' then
          CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'C' ELSE tCaClTecnologia.Responsabilidad END
        else
          CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END 
        end
        AS Responsabilidad,
        'I' AS TipoCuenta
        , case when tCsCartera.FechaDesembolso>='20130101' then
          case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
        else
          tCaProducto.TipoContrato
        end as TipoContrato
        , 
        tClMonedas_1.INTF UnidadMonetaria, 
        CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
        tCsCartera.NroCuotas NumeroPagos,
        tCaClModalidadPlazo_1.INTF FrecuenciaPagos,
        CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, --> aqui venta
        dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA')  Apertura,
        --dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')  UltimoPago,

UltimoPago = ( CASE WHEN (dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA')) <> dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')
               THEN
			        dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')
	           ELSE
			       --''
					dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')
               END ),

        dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA')  Disposicion,
          CASE WHEN Tipo = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') 
          ELSE '' END AS Cancelacion,
        vINTFCabeceraVr13.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
        CreditoMaximo.CreditoMaximo, 
        SaldoActual = CASE WHEN Tipo = 'Cancelados' 
                           THEN 0 
                           ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE+ tCsCartera.SaldoINPE, 0) 
                      END,-->aqui venta
        '' AS LimiteCredito,
        CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 

        PagosVencidos = CASE WHEN tipo = 'Cancelados' 
                             THEN 0
                             ELSE case when tCsCartera.NroCuotas = tCsCartera.CuotaActual and tCsCartera.NroDiasAtraso > 0 
                                       then tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas 
                                       else case when tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas < 0 
                                                 then 0
                                                 else tCsCartera.CuotaActual - 1 - tCsCartera.NroCuotasPagadas
                                            end
                                  end
                        END,
        ----MOP: Manner Of Payment
          CASE 
		        WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                  tCsCartera.FechaDesembolso = tCsCartera.FechaUltimoMovimiento THEN '00' 
		        WHEN 	Tipo = 'Cancelados' Then '01' 
		        WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
		        WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
		        WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
		        ELSE 	tCsBuroMOP.MOP
            END AS MOP
        , '' AS HistoricoPagos, 
        --OBSERVACION
            CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			        WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			        ELSE '' END AS Observacion,
        Historico.PagosReportados, 
        Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
        case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
        CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,
        'FIN' AS FinSegmento
        ,isnull(Moultpago.Montoultpago,0) Montoultpago
        ,isnull(PlazoM.meses, 0.00) as PlazoMeses  --OSC
        ,isnull(PlazoM.MontoDesembolso, 0) as MontoDesembolso, --OSC
        NrodiasAtraso   = isnull(tCsCartera.NrodiasAtraso,0)  --OSC

--/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE --(SecCuota = 1)
      (SecCuota = (select max(SecCuota) from tCsPadronPlanCuotas as m where m.codprestamo = tCsPadronPlanCuotas.codprestamo))
      GROUP BY CodPrestamo) MontoPagar 
RIGHT OUTER JOIN
      (SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
       AS MOP04, SUM(MOP05) AS MOP05
       FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
             CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
             CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
             FROM (select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop) Datos
             ) Datos
             GROUP BY CodPrestamo) Historico 
RIGHT OUTER JOIN (select * from tCsBuroxTblReINomVr13 where tipo='Codeudor') VISTA 
LEFT JOIN (
    SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido
    FROM #tCsMesPlanCuotas Vencido
    WHERE DiasAtrCuota = 1
    GROUP BY Fecha, CodPrestamo
) Vencido ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo 
ON Historico.CodPrestamo = VISTA.CodPrestamo 

LEFT OUTER JOIN tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND 
                      tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario 
LEFT OUTER JOIN(
     SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
     FROM (SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
           FROM tCsPadronCarteraDet with(nolock) 
           INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            ) Datos 
      where Datos.FechaDesembolso<=@fecha
     GROUP BY Datos.CodUsuario) CreditoMaximo 
     ON CreditoMaximo.CodUsuario=tCsCartera.CodUsuario
LEFT OUTER JOIN
     (select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar ) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
LEFT OUTER JOIN #MontoUltPago Moultpago on  Moultpago.codprestamo=VISTA.CodPrestamo
left outer join #PlazoMeses as PlazoM on PlazoM.codprestamo=VISTA.CodPrestamo
CROSS JOIN [FinAmigoExterno_191115].dbo.vINTFCabeceraVr13 vINTFCabeceraVr13

update tcsburoxtblreicueVr13 
set SaldoActual = SaldoVencido
where SaldoVencido = SaldoActual + 1

--Actualiza las observaciones de creditos canceldados con condonación
update cue set
Observacion = 'LC',
SaldoActual = 0,
SaldoVencido = 0,
MOP = '01',
MontoPagar = 0, 
Cancelacion = replace(convert(varchar(10), pcd.Cancelacion,104),'.','') 
from tCsBuroxTblReICueVr13 as cue
inner join tCsTransaccionDiaria as td on td.CodigoCuenta = cue.CodPrestamo and year(td.Fecha) = substring(cue.Reporte,5,4) and month(td.Fecha) = substring(cue.Reporte,3,2)
inner join tCsPadronCarteraDet as pcd on pcd.CodPrestamo = cue.CodPrestamo
where td.DescripcionTran like '%condonacion%'
and pcd.Cancelacion = td.Fecha

--Actualiza MOP error
update tCsBuroxTblReICueVr13 set
MOP = '02'
where 
SaldoVencido > 0 
and MOP in ('00','UR', '01' ) 
and Cancelacion = ''




drop table #tblmop
drop table #tblmesgar
drop table #tCsMesPlanCuotas
drop table #PrimerIncumplimiento
drop table #MontoUltPago
drop table #PlazoMeses

GO