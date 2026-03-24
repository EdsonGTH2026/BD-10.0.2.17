SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCaAJReprocesaPrestamoAlta]
    @CodPrestamo char(19),@nroaj int
--WITH ENCRYPTION
AS

set nocount on
    
 --   declare @CodPrestamo char(19)
	--declare @nroaj int
 --   set @CodPrestamo = '316-170-06-07-00083'
	--set @nroaj=1
    
    --print @CodPrestamo
    declare @PagosSeguro table (
        FechaPago   datetime,
        SecPago     int,
        MontoSeguro smallmoney 
    )

    insert into @PagosSeguro (FechaPago,SecPago,MontoSeguro)
    select r.FechaPago, r.SecPago, sum(MontoPagado)
    from tcaajpagoreg r inner join tcaajpagodet d on d.codoficina = r.codoficina and d.secpago = r.secpago and r.extornado = 0
    where codprestamo = @CodPrestamo and d.codconcepto = 'SDV' and r.nroaj=@nroaj
    group by r.FechaPago, r.SecPago    
    
    -- 1. INICIALIZA PRESTAMO
    -- *******************************************************************************************************
    update tcaAJPrestamos 
    set fechaproceso = fechadesembolso, aceptapago = 1, estado = 'VIGENTE', PROCESARPRES = 1, diasmora = 0
    where codprestamo = @CodPrestamo and nroaj=@nroaj
    
    update tcaAJcuotascli
    set montopagado = 0, 
        SECPAGO = 0, 
        estadoconcepto = 'APROBADO', 
        FECHAPAGO = NULL, 
        ESTADOCONCEPTOANT = '', 
        FECHAPAGOANT = NULL, 
        SECPAGOANT = 0, 
        MONTOPAGADOANT=0, 
        montocondonado = 0, 
        MontoPrevision = 0
    WHERE codprestamo = @CodPrestamo and nroaj=@nroaj

    delete tCaAJCuotasCliDiario WHERE CodPrestamo = @CodPrestamo and nroaj=@nroaj
        
    update tcaAJcuotascli set montodevengado = 0, MontoDevengadoAnt = 0
    WHERE codconcepto in ('inte', 'ivait')
    and codprestamo = @CodPrestamo and nroaj=@nroaj

    update tcaAJcuotas 
    set estadocUOTA = 'APROBADO', 
        FECHAPAGO = NULL, 
        ESTADOCUOTAANT = '', 
        FECHAPAGOANT = NULL, 
        diasatrcuota = 0
    WHERE codprestamo = @CodPrestamo and nroaj=@nroaj
        
    update tcaAJcuotas 
    set estadocUOTA = 'VIGENTE'
    WHERE codprestamo = @CodPrestamo
    AND SECCUOTA = 1 and nroaj=@nroaj

    delete tcaAJpagodet where exists (
        select 1 from tcaAJpagoreg r
        where codprestamo = @CodPrestamo
        and tcaAJpagodet.codoficina=r.codoficina and tcaAJpagodet.secpago=r.secpago
        and extornado = 0 and nroaj=@nroaj
    )
    
-- 2. PAGA Y DEVENGA DESDE FECHADESEMBOLSO HASTA FECHA DE HOY
-- *******************************************************************************************************
    declare @Saldo money
    declare @FechaProceso datetime
    set @FechaProceso = (select max(FechaProceso) from tClParametros where cast(codoficina as int) > 100)

    declare @FechaIniCierre  smalldatetime
    declare @FechaFinCierre  smalldatetime
    DECLARE @CodPrestamoRepro char(19)
    declare @ControlarTiempo bit
    declare @Cuotas          smallint

    select @FechaIniCierre=fechadesembolso, @Cuotas= Cuotas
    from tCaAJPrestamos where CodPrestamo = @CodPrestamo and nroaj=@nroaj
    
    update tcaAJcuotascli
    set montocuota = 0,
        montodevengado = 0,
        montopagado = 0
    WHERE CodPrestamo = @CodPrestamo AND SECCUOTA=@Cuotas AND CODCONCEPTO='PAGTA' and nroaj=@nroaj
        
    set @FechaFinCierre  = (select fechaproceso from tclparametros 
								where codoficina in (select codoficina from tCaAJPrestamos where CodPrestamo = @CodPrestamo)
							) + 1    -- a manana para que su fecha quede en hoy aunque para devengar no se hace de manana solo hasta hoy
    set @ControlarTiempo = 0
    declare @T1 datetime
    declare @T2 datetime

    declare @FechaParaCerrar smalldatetime
    declare @FechaParaPagar  smalldatetime

    declare @CoduSUARIO varchar(15)
    declare @CodOficina varchar(5)
    declare @SecPago  int
    declare @MontoSeguro money

    DECLARE @DEV TABLE (
        codprestamo char(19), 
        TasaInteres smallmoney, 
        SecCuota tinyint,
        SaldoCapital money,
        FechaDesembolso smalldatetime,
        DiasPeriodo tinyint,
        Fecha1erVencimiento smalldatetime,
        GraciaCapital tinyint,
        FechaGracia smalldatetime,
        EsFeriado bit,
        VencimientoCuotaActual smalldatetime,
        UltimoVencimiento smalldatetime,
        NroDias tinyint,
        CeroPorFeriado tinyint,
        INTE1Dia float,
        IVA money,
        InteAcum money
    )    

    set @FechaParaPagar = @FechaIniCierre

    while @FechaParaPagar <= @FechaFinCierre
    begin
        SET @FechaParaCerrar = dateadd(d, 1, @FechaParaPagar)
        -------------------------------------------------------------------------------------------------------------------------------
        -- CONDONA 
        declare @codconcepto varchar(7)
        declare @MontoCondonar money
        declare @SaldoConcepto money
        declare @MontoPago     money
        declare @seccuota int
        if exists (select 1 from tCaAJOpRecuperables where codprestamo = @CodPrestamo and FechaRegistro = @FechaParaPagar and tipoop='002' and nroaj=@nroaj)
        begin
            update tCaAJCuotasCli
            set MontoCondonado = z.MontoOp
            from (
                select r.codprestamo, d.CodConcepto, d.seccuota, d.codusuario, d.montoop 
                from tCaAJOpRecuperables r
                inner join tCaOpAJRecuperablesdet d on r.codprestamo = d.CodPrestamo and r.secpago = d.secpago and r.nroaj=d.r.nroaj
                where r.codprestamo = @CodPrestamo and r.FechaRegistro = @FechaParaPagar and r.nroaj=@nroaj
            ) z
            where tCaAJCuotasCli.CodPrestamo = z.codprestamo
            and tCaAJCuotasCli.CodConcepto = z.CodConcepto and tCaAJCuotasCli.seccuota = z.seccuota and tCaAJCuotasCli.codusuario = z.codusuario
			and tCaAJCuotasCli.nroaj=@nroaj


            update tCaAJCuotas
            set FechaPago = @FechaParaPagar, EstadoCuota = 'CANCELADO'
            from (
                select seccuota, SaldoCuota = sum(Montodevengado - montopagado - Montocondonado)
                from tcaAJcuotascli
                where codprestamo = @CodPrestamo and nroaj=@nroaj
                group by seccuota
                having sum(Montodevengado - montopagado - Montocondonado) = 0
            ) Z
            where tCaAJCuotas.CodPrestamo = @CodPrestamo
            and tCaAJCuotas.SecCuota = z.seccuota
            and tCaAJCuotas.FechaPago is null
			and tCaAJCuotas.nroaj=@nroaj
            
            if exists (select 1
                       from tcaAJcuotascli where codprestamo = @CodPrestamo and nroaj=@nroaj
                       having sum(Montodevengado - montopagado - Montocondonado) = 0)
                update tCaAJPrestamos
                set Estado = 'CANCELADO',ProcesarPres = 0--,AceptaPago = 0
                where CodPrestamo = @CodPrestamo and nroaj=@nroaj
        end -- fin condona

        --  REALIZA PAGO DE LA FECHA
        DECLARE CU1 CURSOR FOR
            select r.CodPrestamo, r.CodOficina, r.SecPago, r.MontoPago, MontoSeguro = isnull(s.MontoSeguro, 0)
            from tCaAJPagoreg r
            left join @PagosSeguro s on r.fechapago = s.fechapago and r.secpago = s.secpago
            where r.CodPrestamo = @CodPrestamo and r.FechaPago = @FechaParaPagar and r.Extornado = 0 and r.nroaj=@nroaj
            order by r.fechahorareal --secpago
        OPEN CU1
        FETCH NEXT FROM CU1 INTO @CodPrestamo, @CodOficina, @SecPago, @MontoPago, @MontoSeguro
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- antes de hacer el pago, si el saldo es menor al monto de pago se asume que es el ultimo pago
            -- y rehabilita cualquier pagta
            select @Saldo = isnull(sum(MontoDevengado - MontoPagado - MontoCondonado), 0)
            from tCaAJCuotasCli where Codprestamo = @CodPrestamo and nroaj=@nroaj
            
            if @MontoPago > @Saldo
            begin
                update tcaAJcuotascli
                set montocuota = @MontoPago - @Saldo,
                    montodevengado = @MontoPago - @Saldo
                    --montopagado = @MontoPago - @Saldo
                WHERE CodPrestamo = @CodPrestamo and nroaj=@nroaj
                AND SECCUOTA = @Cuotas AND CODCONCEPTO = 'PAGTA'
            end
           
            if @MontoPago >= @MontoSeguro and @MontoSeguro > 0
                -- 1. AFECTA PAGO SEGURO
                EXEC pCaAJAfectaPagoALTASeguro
				   @nroaj		= @nroaj,
                   @CodPrestamo = @CodPrestamo,
                   @FechaPago   = @FechaParaPagar,
                   @CodOficina  = @CodOficina,
                   @MontoPago   = @MontoSeguro,
                   @PrSecPago   = @SecPago output
            
            set @MontoPago = isnull(@MontoPago - @MontoSeguro, 0)
               
            -- 2 AFECTA PAGO CREDITO
            if @MontoPago > 0
            begin
               exec pCaAJAfectaPagoALTAMonto
				   @nroaj		= @nroaj,
                   @CodPrestamo	 = @CodPrestamo,
                   @FechaPago    = @FechaParaPagar,
                   @CodOficina   = @codoficina,
                   @MontoPago    = @MontoPago,
                   @PrSecPago    = @SecPago output,
                   @PrBitLiquida = 0   -- Indica si se está liquidando el préstamo
            end
            
            FETCH NEXT FROM CU1 INTO @CodPrestamo, @CodOficina, @SecPago, @MontoPago, @MontoSeguro
        END
        CLOSE CU1
        DEALLOCATE CU1
        -------------------------------------------------------------------------------------------------------------------------
        if exists (select 1 from tCaAJPrestamos where codprestamo = @CodPrestamo and Procesarpres = 1 and nroaj=@nroaj)
            and @FechaParaCerrar < @FechaFinCierre
        begin
            -- 6. *******************  DEVENGA NORMAL (SIMULA CIERRE) ****************************
            DELETE @DEV
            INSERT INTO @DEV
            select *, IVA = 0, InteAcum = 0
            from (
                select *, INTE1Dia = SaldoCapital * TasaInteres  / 360. * case NroDias when 0 then 0 else 1 end * CeroPorFeriado
                from (
                    select *, NroDias = case when FechaGracia is null /*FechaGracia es para gracia intermedia*/
                                             then case when B.GraciaCapital > 0
                                                       then case when @FechaParaCerrar > dateadd(d, GraciaCapital, FechaDesembolso)
                                                                 then 1 else 0 end
                                                       else case when @FechaParaCerrar > dateadd(d, -DiasPeriodo , Fecha1erVencimiento) -- con >= no funciona
                                                                 then 1 else 0
                                                            end
                                                  end
                                             else 0
                                        end,
                           CeroPorFeriado = case when EsFeriado = 1 and VencimientoCuotaActual = @FechaParaCerrar and VencimientoCuotaActual <= UltimoVencimiento
                                            then 0 else 1 end
                    from (
                        select P.CodPrestamo, P.TasaInteres, Cu.seccuota, 
                               SaldoCapital = (select sum(montodevengado - Montopagado - MontoCondonado)
                                               from tcaAJcuotascli cc
                                               where cc.codprestamo = @CodPrestamo and cc.nroaj=@nroaj
                                               and codconcepto = 'capi'),
                               P.fechaDesembolso, P.DiasPeriodo, CI.Fecha1erVencimiento, P.GraciaCapital, FechaGracia,
                               EsFeriado = isnull(FE2.EsFeriado, 0),
                               VencimientoCuotaActual = CU.FechaVencimiento, UV.UltimoVencimiento
                        from (
                            -- 1. datos generales del prestamo
                            select CodPrestamo, P.CodOficina, P.FechaDesembolso, P.GraciaCapital,
                                   DiasPeriodo = CASE P.CodTipoPlaz when 'S' then 7 when 'Q' then 15 when 'M' then 30 else 0 end,
                                   TasaInteres = isnull((select ValorConcepto / 100 from tcaConcPre I
                                                         where I.Codprestamo = P.CodPrestamo and I.CodConcepto = 'INTE'), 0)
                            from tCaAJPrestamos P with(nolock)
                            where P.codprestamo = @CodPrestamo and P.nroaj=@nroaj
                        ) P
                        left join (
                            -- 2.   join (este query determina que cuota de cada prestamo es la vigente)
                            -- 2.A. vigentes reales
                            select p.codprestamo, Seccuota = min(c.seccuota), FechaInicio = MIN(c.FechaInicio), FechaVencimiento = MIN(c.FechaVencimiento)
                            from tcaAJprestamos P
                            inner join tcaAJcuotas     c on p.codprestamo = c.codprestamo and p.nroaj=c.nroaj
                            inner join tcaAJcuotascli cc on c.codprestamo = cc.codprestamo and c.seccuota = cc.seccuota and c.nroaj=cc.nroaj
                            where p.codprestamo = @CodPrestamo and p.nroaj=@nroaj
                            and montodevengado - Montopagado - MontoCondonado > 0
                            and c.FechaVencimiento >= @FechaParaCerrar
                            group by p.codprestamo
                            union all
                            -- 2.B. ultima cuota del credito vencido (para seguir calculando interes)
                            select p.codprestamo, c.seccuota, c.FechaInicio, FechaVencimiento = @FechaParaCerrar
                            from tcaAJprestamos P
                            inner join tcaAJcuotas     c on p.codprestamo = c.codprestamo and p.nroaj=c.nroaj
                            inner join tcaAJcuotascli cc on c.codprestamo = cc.codprestamo and c.seccuota = cc.seccuota and c.nroaj=cc.nroaj
                            where p.codprestamo = @CodPrestamo and P.nroaj=@nroaj
                            and montodevengado - Montopagado - MontoCondonado > 0
                            and c.SecCuota = P.Cuotas
                            and @FechaParaCerrar > c.FechaVencimiento
                            group by p.codprestamo, c.seccuota, c.FechaInicio
                        ) CU on P.CodPrestamo = Cu.CodPrestamo
                        left join (
                            select p.codprestamo, FechaIniCred = dateadd(d, -7, min(C.FechaVencimiento)), Fecha1erVencimiento = min(c.FechaVencimiento)
                            from tcaAJprestamos P
                            inner join tcaAJcuotas c on p.codprestamo = c.codprestamo and p.nroaj=c.nroaj
                            where p.codprestamo = @CodPrestamo and P.nroaj=@nroaj
                            and c.SecCuota = 1
                            group by p.codprestamo
                        ) CI on P.CodPrestamo = CI.CodPrestamo
                        left join (
                            select codprestamo, FechaGracia
                            from tCaPrestamosGraciaIntermedia -->>> OJOOOOOO no se replicara porque solo se ven unos casos que salieron en la migracion
                            where FechaGracia = @FechaParaCerrar
                        ) GR on GR.codprestamo = CI.CodPrestamo
                        left join (
                            select CodOficina, EsFeriado = 1 from tcaclfechasnoven 
                            where FechaNoven = @FechaParaCerrar and not (datepart(dw, @FechaParaCerrar) = 1 or datepart(dw, @FechaParaCerrar) = 7)
                        ) FE2 on P.CodOficina = FE2.CodOficina
                        left join (
                            select codprestamo, UltimoVencimiento = max(FechaVencimiento)
                            from tcaAJcuotas
                            where codprestamo = @CodPrestamo and nroaj=@nroaj
                            group by codprestamo
                        ) UV on P.CodPrestamo = UV.CodPrestamo
                    ) B
                ) C
            ) D
            
            ------------------------------------------------------------------------------------------------------
            --SELECT * FROM @DEV   ----2:43
            
            insert into tCaAJCuotasCliDiario
                  (nroaj,CodPrestamo, SecCuota           , Fecha           , MontoDevengadoDiario)
            select @nroaj,codprestamo, isnull(seccuota, 0), @FechaParaCerrar, isnull(INTE1Dia, -0.000001)
            from @dev
            
			-- actualiza saldos
			update tCaAJCuotasCliDiario
			set saldocapital=isnull(x.saldocapital,0),saldointeres=isnull(x.saldointeres,0)+MontoDevengadoDiario
				,saldomoratorio=isnull(x.saldomoratorio,0),saldoseguros=isnull(x.saldoseguros,0),saldocargomora=isnull(x.saldocargomora,0)
			from tCaAJCuotasCliDiario c
			inner join (
				select C.codprestamo
				,sum(case when cc.codconcepto='CAPI' then MontoDevengado - MontoPagado - MontoCondonado else 0 end) saldocapital
				,sum(case when cc.codconcepto='INTE' then MontoDevengado - MontoPagado - MontoCondonado else 0 end) saldointeres
				,sum(case when cc.codconcepto='INPE' then MontoDevengado - MontoPagado - MontoCondonado else 0 end) saldomoratorio
				,sum(case when cc.codconcepto='SDV' then MontoDevengado - MontoPagado - MontoCondonado else 0 end) saldoseguros
				,sum(case when cc.codconcepto='MORA' then MontoDevengado - MontoPagado - MontoCondonado else 0 end) saldocargomora
				from tCaAJCuotas C
				inner join tcaAJcuotascli CC on C.CodPrestamo=CC.CodPrestamo and C.SecCuota=CC.SecCuota and c.nroaj=cc.nroaj
				where C.Codprestamo = @CodPrestamo and c.nroaj=@nroaj and c.estadocuota<>'CANCELADO'
				group by C.codprestamo
			) x on c.codprestamo=x.codprestamo
            where c.nroaj=@nroaj and c.codprestamo=@codprestamo and c.fecha=@FechaParaCerrar
            
            -- select count(*) from tCaCuotasCliDiario -- 1101643
            update D
            set D.InteAcum = Acum.InteAcum
            from @DEV D
            inner join (
                select D.CodPrestamo, D.SecCuota, InteAcum = round(sum(D.MontoDevengadoDiario), 2)
                from tCaAJCuotasCliDiario D
                inner join @DEV V on D.CodPrestamo = V.CodPrestamo and D.SecCuota = V.SecCuota
				where nroaj=@nroaj
                group by D.CodPrestamo, D.SecCuota
            ) Acum on D.codprestamo = Acum.codprestamo and Acum.Seccuota = D.Seccuota 

            update @DEV set IVA = round(InteAcum * .16, 2)

            update tcaAJcuotascli
            set MontoDevengadoAnt = MontoDevengado,
                MontoDevengado = case when codconcepto = 'INTE' 
                                      then z.InteAcum --+ isnull(tcacuotascli.MontoPrevision, 0) -- antes usaba MontoPagado
                                      else z.IVA      --+ isnull(tcacuotascli.MontoPrevision, 0) -- antes usaba MontoPagado
                                 end
            from @dev Z
            where tcaAJcuotascli.codprestamo = z.codprestamo and tcaAJcuotascli.seccuota = Z.SECCUOTA and tcaAJcuotascli.codconcepto in ('INTE', 'IVAIT')
            and tCaAJCuotasCli.nroaj=@nroaj

            update tcaAJcuotas
            set ESTADOcuota = 'VIGENTE'
            from @dev Z
            where tcaAJcuotas.codprestamo = z.codprestamo and tcaAJcuotas.seccuota = Z.SECCUOTA and tcaAJCuotas.nroaj=@nroaj

            set @T2 = getdate()
            if @ControlarTiempo = 1 print '* '+  convert(varchar(10), @FechaParaPagar, 103) + ':   ' + cast( datediff(second, @T1, @T2) as char(3)) + ' - Tiempo Devenga'
            set @T1 = getdate()

            --- 5. calcula dias mora y actualiza en tCaCuotas SEGUN EL METODO FINMAS
            update tCaAJCuotas
            Set DiasAtrCuotaHist = DiasAtrCuota,
                DiasAtrCuota     = Z.DiasAtraso,
                EstadoCuotaAnt   = EstadoCuota,
                EstadoCuota      = 'VENCIDO'
            from (
                select C.codprestamo, C.seccuota, C.FechaVencimiento, DiasAtraso = datediff(d, C.FechaVencimiento, @FechaParaCerrar) ,
                       Saldo = sum(MontoDevengado - MontoPagado - MontoCondonado)
                from tCaAJCuotas C
                inner join tcaAJcuotascli CC on C.CodPrestamo=CC.CodPrestamo and C.SecCuota=CC.SecCuota and c.nroaj=cc.nroaj
                where C.Codprestamo = @CodPrestamo and c.nroaj=@nroaj
                and C.FechaVencimiento < @FechaParaCerrar
                group by C.codprestamo, C.seccuota, C.FechaVencimiento
                having sum(MontoDevengado - MontoPagado - MontoCondonado) > 0
            ) Z
            where tCaAJCuotas.CodPrestamo = Z.CodPrestamo and tCaAJCuotas.SecCuota = Z.SecCuota and tCaAJCuotas.nroaj=@nroaj

            --- 6. Actualiza Dias mora en tCaPrestamos SEGUN METODO ALTA
            if @FechaParaCerrar = @FechaFinCierre
            begin
                update tCaAJPrestamos
                set DiasMora = Z.DiasMora
                from (
		            select *, DiasMora = case when SaldoAtrasado = 0 then 0
		                                      else case when @FechaParaCerrar > FechaVencimiento -- ya paso la fecha vencim del prestamo
		                                                then DiasMoraAntMasUno
		                                                else case when DiasMoraAntMasUno < CalculoDias
		                                                          then DiasMoraAntMasUno
		                                                          else CalculoDias
		                                                     end
		                                           end
		                                 end
		            from (
		                select *, DiasMoraAntMasUno = DiasMoraAnt + 1,
		                       CalculoDias = round((SaldoAtrasado / Amortizacion) + 0.2, 0) * DiasPeriodo -- diasperiodo
		                from (
		                    SELECT P.CodPrestamo, DiasMoraAnt = DiasMora, P.FechaVencimiento, A.Amortizacion,
		                           SaldoAtrasado = isnull(C.SaldoAtrasado, 0), DiasPeriodo = CASE P.CodTipoPlaz when 'S' then 7 when 'Q' then 15 when 'M' then 30 end
		                    FROM tCaAJPrestamos P
		                    inner join (
		                        SELECT CodPrestamo, Amortizacion = sum(MontoCuota)
		                        from TCAAJCUOTASCLI
		                        WHERE CODPRESTAMO = @CodPrestamo and nroaj=@nroaj
                                and SecCuota = 1
                                and CodConcepto in ('CAPI', 'INTE')
		                        group by CodPrestamo --order by 1, 2
		                    ) A on P.codprestamo = A.CodPrestamo
		                    left join (
		                        SELECT c.CodPrestamo, SaldoAtrasado = sum(MontoDevengado - MontoPagado - MontoCondonado)
		                        from TCAAJCUOTAS C
		                        INNER JOIN TCAAJCUOTASCLI cc ON c.CODPRESTAMO = cc.CODPRESTAMO AND c.SECCUOTA = cc.SECCUOTA
		                        WHERE c.CODPRESTAMO = @CodPrestamo and c.nroaj=@nroaj
		                        and C.FechaVencimiento < @FechaParaCerrar
		                        and cc.CodConcepto in ('CAPI', 'INTE')
                                group by c.CodPrestamo
		                    ) C on P.codprestamo = C.CodPrestamo 
		                    WHERE p.CODPRESTAMO = @CodPrestamo and p.nroaj=@nroaj
                            and ProcesarPres = 1
		                ) A
		            ) B
                ) Z
                where tCaAJPrestamos.CodPrestamo = Z.CodPrestamo and tCaAJPrestamos.nroaj=@nroaj
            end
            
            --- 7. ACTUALIZA ESTADO VENCIDO EN TCAPRESTAMOS
            ----------------------------------------------
            update tCaAJPrestamos
            set Estado = 'VENCIDO'
            --select estado, diasmora, *  from tcaprestamos
            WHERE CODPRESTAMO  = @CodPrestamo and nroaj=@nroaj
            and procesarpres = 1
            and DiasMora > 90

            --- 10. ACTUALIZA FECHA DE CIERRE AL SIGUIENTE DIA    
            update tcaAJprestamos set fechaproceso = @FechaParaCerrar 
            where codprestamo = @CodPrestamo and nroaj=@nroaj
            and ProcesarPres = 1

        end -- if exists (select 1 from tCaPrestamos where codprestamo = @CodPrestamo and Procesarpres = 1)
        else
            set @FechaParaPagar = @FechaFinCierre -- si ya cancelo el credito ya no procesa nignuna fecha mas

        set @FechaParaPagar= dateadd(dd, 1, @FechaParaPagar)

    end -- del while
GO