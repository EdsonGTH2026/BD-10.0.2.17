SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCalcularDatosCartera] (@Paso Int, @Fecha SmallDateTime)
As

set nocount on
--***********************************************************************************************************************
If @Paso = 1
Begin
	--Sentencias en cadena una depende de la otra, nunca ejecutar por separado
	UPDATE tCsCartera
	SET    Cartera = 'CASTIGADA'
	WHERE  Fecha = @Fecha and Cartera IS NULL AND Estado = 'CASTIGADO'

	UPDATE tCsCartera
	SET    Cartera = 'ADMINISTRATIVA'
	WHERE  Fecha = @Fecha AND CodOficina = 97
	
	UPDATE tCsCartera
	SET    Cartera = 'ACTIVA'
	WHERE  Fecha = @Fecha and Cartera IS NULL
End


--***********************************************************************************************************************
If @Paso = 2
Begin
	Declare @Periodo	Varchar(6)
	Declare @PA		Varchar(6)
	Declare @Periodos	Int	
	
	-- Depuración de Fecha de Reprog Nulos...
	/* cum 2020.05.14 lo hace mal
	UPDATE tcsCartera
	SET    FechaReprog = Filtro.Fecha
	FROM (
	    SELECT CodPrestamo, MIN(Fecha) AS Fecha
        FROM   tCsCartera
        WHERE CodPrestamo IN (
								SELECT DISTINCT CD.CodPrestamo
	                          FROM tCsPadronCarteraDet CD with(nolock) 
	                          INNER JOIN tCsCartera C with(nolock) ON CD.FechaCorte = C.Fecha AND CD.CodPrestamo = C.CodPrestamo
	                          WHERE CD.TipoReprog NOT IN ('SINRE') AND (C.FechaReprog IS NULL)
	                         )
	    AND TipoReprog NOT IN ('SINRE')
        GROUP BY CodPrestamo
    ) Filtro 
    WHERE Filtro.CodPrestamo = tCsCartera.CodPrestamo AND Filtro.Fecha <= tCsCartera.Fecha
	*/
	Set @Periodos = 3
	Set @Periodo = dbo.fduFechaAPeriodo(@Fecha)
	
	SELECT    @PA=  dbo.fduFechaAPeriodo(DATEADD([month],  -1 * (@Periodos - 1), PrimerDia)) 
	FROM         tClPeriodo
	WHERE     (Periodo = @Periodo)
	
	Print @Periodo
	Print @PA

/*	CUM 2020.05.14
	Insert Into tCsRenegociadosVigentes
    select '' Periodo, '' Registro, f.codprestamo, f.DiasAcumulado, f.PagoCorrec, ca.TipoReprog, ca.NumReprog, ca.FechaReprog, ca.PrestamoReprog, '' as RP
    from tcscartera ca with(nolock)
    inner join (
        select distinct codprestamo, fechacorte from tCsPadronCarteraDet with(nolock) 
        where (TipoReprog NOT IN ('SINRE','REFRE')) and estadocalculado not in('CASTIGADO','CANCELADO')--<>'CALCULADO'
    ) p on p.codprestamo = ca.codprestamo and p.fechacorte = ca.fecha
    inner join (
        select codprestamo, sum(diasatrcuota) DiasAcumulado, sum(PagoCorrec) PagoCorrec 
        from (
            select a.codprestamo, a.seccuota, a.fechavencimiento, a.diasatrcuota, a.fechapagoconcepto, a.estadocuota
                   ,case when (dbo.fduFechaAPeriodo(a.fechavencimiento)>=dbo.fduFechaAPeriodo(a.fechapagoconcepto)) and a.estadocuota='CANCELADO' then 1 else 0 end PagoCorrec
            from (
                select codprestamo, seccuota, fechavencimiento, max(cast(diasatrcuota as int)) diasatrcuota, max(fechapagoconcepto) fechapagoconcepto, estadocuota
                       , dbo.fduFechaAPeriodo(fechavencimiento) periodoven
                from tcspadronplancuotas with(nolock)
                --where codprestamo='034-156-06-00-00164'--'009-158-06-08-00059'--'004-162-06-00-01430'--'008-158-06-04-00202'--'002-122-06-05-01269'
                where codprestamo in (select distinct codprestamo 
                                      from tCsPadronCarteraDet with(nolock) 
                                      where TipoReprog NOT IN ('SINRE','REFRE') and estadocalculado not in('CASTIGADO','CANCELADO')--<> 'CALCULADO'
                                      and codprestamo not in (SELECT CodPrestamo FROM tCsRenegociadosVigentes with(nolock))
                                     )
                group by CodPrestamo, SecCuota, EstadoCuota, FechaVencimiento
            ) a
            where a.fechavencimiento <= @Fecha--'20131007'
            --and dbo.fduFechaAPeriodo(a.fechavencimiento)>='201308'--este ya no calcular periodos en where es lento
            and a.periodoven>=@PA--'201308'
        ) x
        group by codprestamo
        having sum(PagoCorrec) >= @Periodos--2
    ) f on f.codprestamo = ca.codprestamo
	*/

/*	SELECT  Periodo = @Periodo, Registro = @Fecha, CodPrestamo, SUM(NroDiasAtraso) AS DiasAcumulado, COUNT(*) AS Periodos, TipoReprog, NumReprog, FechaReprog, PrestamoReprog, RP = TipoReprog
	FROM         (SELECT     Datos.CodPrestamo, Datos.Periodo, Datos.MDias, Datos.FechaReprog, ProximoVencimiento.ProximoVencimiento, 
	                                              tCsCartera.NroDiasAtraso, tCsCartera.TipoReprog, tCsCartera.NumReprog, tCsCartera.PrestamoReprog
	                       FROM          (SELECT     tCsPadronCarteraDet.CodPrestamo, dbo.fduFechaAPeriodo(tCsCartera.Fecha) AS Periodo, MAX(tCsCartera.NroDiasAtraso) 
	                                                                      AS MDias, tCsCartera.FechaReprog, MIN(tCsCartera.ProximoVencimiento) AS ProximoVencimiento
	                                               FROM          tCsPadronCarteraDet with(nolock) INNER JOIN
	                                                                      tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	                                               WHERE      (tCsPadronCarteraDet.TipoReprog NOT IN ('SINRE')) AND (tCsCartera.Fecha >= tCsCartera.FechaReprog)
	                                               GROUP BY tCsPadronCarteraDet.CodPrestamo, dbo.fduFechaAPeriodo(tCsCartera.Fecha), tCsCartera.FechaReprog) Datos INNER JOIN
	                                                  (SELECT     tCsPadronCarteraDet.CodPrestamo, dbo.fdufechaaperiodo(MIN(tCsCartera.ProximoVencimiento)) AS ProximoVencimiento
	                                                    FROM          tCsPadronCarteraDet with(nolock) INNER JOIN
	                                                                           tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	                                                    WHERE      (tCsPadronCarteraDet.TipoReprog NOT IN ('SINRE')) AND (tCsCartera.Fecha >= tCsCartera.FechaReprog)
	                                                    GROUP BY tCsPadronCarteraDet.CodPrestamo) ProximoVencimiento ON Datos.CodPrestamo = ProximoVencimiento.CodPrestamo AND 
	                                              Datos.Periodo >= ProximoVencimiento.ProximoVencimiento INNER JOIN
	                                              tClPeriodo with(nolock) ON Datos.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo INNER JOIN
	                                              tCsCartera with(nolock) ON tClPeriodo.UltimoDia = tCsCartera.Fecha AND 
	                                              Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo
	                       WHERE      (Datos.Periodo <= @Periodo) AND (tClPeriodo.Periodo >= @PA)) Reprogramados
	WHERE     (CodPrestamo NOT IN
	                          (SELECT     CodPrestamo
	                            FROM          tCsRenegociadosVigentes with(nolock)))
	GROUP BY CodPrestamo, TipoReprog, NumReprog, FechaReprog, PrestamoReprog
	HAVING      (SUM(NroDiasAtraso) = 0) AND (COUNT(*) = @Periodos)
	
	Insert Into tCsRenegociadosVigentes
	SELECT     Periodo = @Periodo, Registro = @Fecha, tCsCartera.CodPrestamo, tCsCartera.NroDiasAtraso, @Periodos AS Periodos, tCsCartera.TipoReprog, tCsCartera.NumReprog, 
	                      tCsCartera.FechaReprog, tCsCartera.PrestamoReprog, tCsCartera.TipoReprog AS RP
	FROM         tCsCartera with(nolock) INNER JOIN
	                      tCsCartera Anterior with(nolock) ON tCsCartera.CodPrestamo = Anterior.CodPrestamo --AND tCsCartera.ProximoVencimiento <> Anterior.ProximoVencimiento
	WHERE     (tCsCartera.Fecha = @Fecha) AND (tCsCartera.CodPrestamo IN
	                          (SELECT     CodPrestamo
	                            FROM          (SELECT     Datos.CodPrestamo, Datos.Periodo, Datos.MDias, Datos.FechaReprog, ProximoVencimiento.ProximoVencimiento, 
	                                                                           tCsCartera.NroDiasAtraso, tCsCartera.TipoReprog, tCsCartera.NumReprog, tCsCartera.PrestamoReprog
	                                                    FROM          (SELECT     tCsPadronCarteraDet.CodPrestamo, dbo.fduFechaAPeriodo(tCsCartera.Fecha) AS Periodo, 
	                                                                                                   MAX(tCsCartera.NroDiasAtraso) AS MDias, tCsCartera.FechaReprog, MIN(tCsCartera.ProximoVencimiento) 
	                                                                                                   AS ProximoVencimiento
	                                                                            FROM          tCsPadronCarteraDet with(nolock) INNER JOIN
	                                                                                                   tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	                                                                            WHERE      (tCsPadronCarteraDet.TipoReprog NOT IN ('SINRE')) AND (tCsCartera.Fecha >= tCsCartera.FechaReprog)
	                                                                            GROUP BY tCsPadronCarteraDet.CodPrestamo, dbo.fduFechaAPeriodo(tCsCartera.Fecha), tCsCartera.FechaReprog) 
	                                                                           Datos INNER JOIN
	                                                                               (SELECT     tCsPadronCarteraDet.CodPrestamo, dbo.fdufechaaperiodo(MIN(tCsCartera.ProximoVencimiento)) 
	                                                                                                        AS ProximoVencimiento
	                                                                                 FROM          tCsPadronCarteraDet with(nolock) INNER JOIN
	                                                                                                        tCsCartera with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	                                                                                 WHERE      (tCsPadronCarteraDet.TipoReprog NOT IN ('SINRE')) AND (tCsCartera.Fecha >= tCsCartera.FechaReprog)
	                                                                                 GROUP BY tCsPadronCarteraDet.CodPrestamo) ProximoVencimiento ON 
	                                                                           Datos.CodPrestamo = ProximoVencimiento.CodPrestamo AND 
	                                                                           Datos.Periodo >= ProximoVencimiento.ProximoVencimiento INNER JOIN
	                                                                           tClPeriodo with(nolock) ON Datos.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo INNER JOIN
	                                                                           tCsCartera with(nolock) ON tClPeriodo.UltimoDia = tCsCartera.Fecha AND 
	                                                                           Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo
	                                                    WHERE      (Datos.Periodo <= @Periodo) AND (tClPeriodo.Periodo >= @PA)) Reprogramados
	                            WHERE      (CodPrestamo NOT IN
	                                                       (SELECT     CodPrestamo
	                                                         FROM          tCsRenegociadosVigentes with(nolock)))
	                            GROUP BY CodPrestamo, TipoReprog, NumReprog, FechaReprog, PrestamoReprog
	                            HAVING      (SUM(NroDiasAtraso) = 0) AND (COUNT(*) = @Periodos - 1))) AND (tCsCartera.NroDiasAtraso = 0) AND (Anterior.Fecha = @Fecha - 1)

	DELETE FROM tCsRenegociadosVigentes
	WHERE     (CodPrestamo IN
	                          (SELECT     CodPrestamo
	                            FROM          (SELECT DISTINCT 
	                                                                           tCsPlanCuotas.CodPrestamo, tCsPlanCuotas.SecCuota, tCsPlanCuotas.EstadoCuota, tCsPlanCuotas.FechaVencimiento
	                                                    FROM          tCsRenegociadosVigentes INNER JOIN
	                                                                           tCsPadronCarteraDet with(nolock) ON tCsRenegociadosVigentes.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN
	                                                                           tCsPlanCuotas with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsPlanCuotas.Fecha AND 
	                                                                           tCsPadronCarteraDet.CodUsuario = tCsPlanCuotas.CodUsuario AND 
	                                                                           tCsPadronCarteraDet.CodPrestamo = tCsPlanCuotas.CodPrestamo
	                                                    WHERE      (tCsRenegociadosVigentes.Registro = @Fecha) AND (tCsPlanCuotas.EstadoCuota = 'CANCELADO') AND 
	                                                                           (tCsPlanCuotas.FechaVencimiento >= DateAdd(Month, -1 * (@Periodos), @Fecha))) Datos
	                            GROUP BY CodPrestamo, EstadoCuota
	                            HAVING      (COUNT(*) < @Periodos))) And CodPrestamo not in ('006-162-06-04-00002')
*/
	--VERIFICAR QUE EL DATO 90 del siguiente escript debe ser dinamico
    
    --noel original
	--UPDATE tCscartera
	--SET    Estado = 'VIGENTE', Capitalvigente = Saldocapital, Capitalvencido = 0
	--FROM   tCsRenegociadosVigentes with(nolock) 
	--INNER JOIN tCsCartera ON tCsRenegociadosVigentes.CodPrestamo = tCsCartera.CodPrestamo AND tCsRenegociadosVigentes.Registro <= tCsCartera.Fecha AND tCsCartera.NroDiasAtraso < 90 AND tCsCartera.Fecha = @Fecha 

    -- noel corregido
	UPDATE tCscartera
	SET    Estado = 'VIGENTE', Capitalvigente = Saldocapital, Capitalvencido = 0
	FROM   tCsRenegociadosVigentes Z with(nolock) 
	where  Z.CodPrestamo = tCsCartera.CodPrestamo AND Z.Registro <= tCsCartera.Fecha AND tCsCartera.NroDiasAtraso < 90 AND tCsCartera.Fecha = @Fecha 

    --noel original
	--UPDATE    tCsCarteraDet
	--SET              InteresVigente = SaldoInteres, Interesvencido = 0, MoratorioVigente = SaldoMoratorio, MoratorioVencido = 0
	--FROM         tCsRenegociadosVigentes with(nolock) INNER JOIN
	--                      tCsCartera with(nolock) ON tCsRenegociadosVigentes.CodPrestamo = tCsCartera.CodPrestamo AND tCsRenegociadosVigentes.Registro <= tCsCartera.Fecha AND 
	--                      tCsCartera.NroDiasAtraso < 90 AND tCsCartera.Fecha = @Fecha INNER JOIN
	--                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo

    -- noel corregido
	UPDATE tCsCarteraDet
	SET    InteresVigente = SaldoInteres, MoratorioVigente = SaldoMoratorio, MoratorioVencido = 0, Interesvencido = 0
	FROM (
	    SELECT Fecha, C.CodPrestamo
	    FROM tCsRenegociadosVigentes RV with(nolock) 
	    INNER JOIN tCsCartera C with(nolock) ON RV.CodPrestamo = C.CodPrestamo AND RV.Registro <= C.Fecha AND C.NroDiasAtraso < 90 AND C.Fecha = @Fecha
	) Z
	where Z.Fecha = tCsCarteraDet.Fecha AND Z.CodPrestamo = tCsCarteraDet.CodPrestamo

End

--***********************************************************************************************************************
/*
If @Paso = 3
Begin
	
	Declare @C	  Int
	/*
	SELECT     @C = COUNT(*) 
	FROM         tCsCartera01
	WHERE     (Fecha = @Fecha)
	
	If @C > 0 
	Begin
		Delete From tCsCarteraDet Where Fecha = @Fecha
		
		INSERT INTO tCsCarteraDet
		(Fecha, CodPrestamo, CodUsuario, CodOficina, MontoDesembolso, SaldoCapital, SaldoInteres, SaldoMoratorio, OtrosCargos, Impuestos, 
		                      UltimoMovimiento, SaldoEnMora, CapitalAtrasado, CapitalVencido, TipoCalificacion, InteresVigente, InteresVencido, InteresCtaOrden, 
		                      InteresDevengado, MoratorioVigente, MoratorioVencido, MoratorioCtaOrden, MoratorioDevengado, CargoMora, SecuenciaCliente, SecuenciaGrupo, CodDestino)	
		SELECT     tCsCartera01.Fecha, tCsCartera01.CodPrestamo, tCsCartera01.CodUsuario, tCsCartera01.CodOficina, tCsCartera01.MontoDesembolso, 
		                      tCsCartera01.SaldoCapital, tCsCartera01.SaldoINTE, tCsCartera01.SaldoINPE, tCsCartera01.OtrosCargos, tCsCartera01.Impuestos, 
		                      tCsCartera01.FechaUltimoMovimiento, tCsCartera01.SaldoEnMora, tCsCartera01.SaldoCapitalAtrasado, tCsCartera01.SaldoCapitalVencido, 
		                      tCsCartera01.TipoCalificacion, 
		                      CASE WHEN tcscartera.estado = 'VENCIDO' THEN 0 WHEN tcscartera.estado = 'VIGENTE' THEN tcscartera01.SaldoINTEVIG ELSE 0 END AS InteresVigente,
		                       CASE WHEN tcscartera.estado = 'VENCIDO' THEN tcscartera01.SaldoINTEVIG WHEN tcscartera.estado = 'VIGENTE' THEN 0 ELSE 0 END AS InteresVencido,
		                       tCsCartera01.SaldoINTESus, tCsCartera01.INTEDevDia AS InteresDevengado, 
		                      CASE WHEN tcscartera.estado = 'VENCIDO' THEN 0 WHEN tcscartera.estado = 'VIGENTE' THEN tcscartera01.SaldoINPEVIG ELSE 0 END AS MoratorioVigente,
		                       CASE WHEN tcscartera.estado = 'VENCIDO' THEN tcscartera01.SaldoINPEVIG WHEN tcscartera.estado = 'VIGENTE' THEN 0 ELSE 0 END AS MoratorioVencido,
		                       tCsCartera01.SaldoINPESus, tCsCartera01.INPEDevDia AS MoratorioDevengado, tCsCartera01.SaldoCargoMora, tCsCartera01.SecuenciaCliente, 
		                      tCsCartera01.SecuenciaGrupo, tCsCartera01.CodDestino
		FROM         tCsCartera RIGHT OUTER JOIN
		                      tCsCartera01 ON tCsCartera.Fecha = tCsCartera01.Fecha AND tCsCartera.CodPrestamo = tCsCartera01.CodPrestamo
		WHERE     (tCsCartera01.Fecha = @Fecha)
	End 
	*/
	--CALCULO DE LA PROVISION 
	Update   D
	Set	PReservaCapital	= Prov.PReservaCapital, 
		SReservaCapital	= Prov.SReservaCapital, 
		PReservaInteres	= Prov.PReservaInteres, 
		SReservaInteres	= Prov.SReservaInteres,
		IReserva	    = Prov.Identificador
	FROM (
	    SELECT D.Fecha, D.CodPrestamo, D.CodUsuario, PR.Capital AS PReservaCapital, 
               CAST(PR.Capital AS decimal(19, 4)) / 100 * D.SaldoCapital AS SReservaCapital, PR.Interes AS PReservaInteres,
               (CAST(PR.Interes AS decimal(19, 4)) / 100) * (D.InteresVigente + D.InteresVencido + D.MoratorioVigente + D.MoratorioVencido) AS SReservaInteres, 
               C.CodTipoCredito, C.TipoReprog, C.Estado, D.SaldoCapital,
               D.InteresVigente, D.InteresVencido, D.MoratorioVigente, D.MoratorioVencido, C.NroDiasAtraso, PR.Identificador
        FROM tCsCarteraDet D 
        LEFT JOIN tCsCartera C ON D.Fecha = C.Fecha AND D.CodPrestamo = C.CodPrestamo 
        LEFT JOIN tCaClProvision PR ON C.CodTipoCredito = PR.CodTipoCredito AND 
                              C.TipoReprog = PR.TipoReprog AND C.Fecha <= PR.VigenciaFin AND 
                              C.Fecha >= PR.VigenciaInicio AND C.NroDiasAtraso <= PR.DiasMaximo AND 
                              C.NroDiasAtraso >= PR.DiasMinimo AND C.Estado = PR.Estado
        WHERE D.Fecha = @Fecha
    ) Prov
    INNER JOIN tCsCarteraDet D 
            ON Prov.CodPrestamo = D.CodPrestamo AND Prov.Fecha = D.Fecha AND Prov.CodUsuario = D.CodUsuario


	--CALCULO DE LA PROVISION PARA REESTRUCTURADOS VIGENTES 
    UPDATE tCsCarteraDet
    SET PReservaCapital	= Prov.PReservaCapital, 
        SReservaCapital	= Prov.SReservaCapital, 
        PReservaInteres	= Prov.PReservaInteres, 
        SReservaInteres	= Prov.SReservaInteres,
        IReserva	    = Prov.Identificador
    FROM (
        SELECT D.Fecha, D.CodPrestamo, D.CodUsuario, PR.Capital AS PReservaCapital, 
              CAST(PR.Capital AS decimal(19, 4)) / 100 * D.SaldoCapital AS SReservaCapital, 
              PR.Interes AS PReservaInteres, 
              (CAST(PR.Interes AS decimal(19, 4)) / 100) * (D.InteresVigente + D.InteresVencido + D.MoratorioVigente + D.MoratorioVencido) 
              AS SReservaInteres, C.CodTipoCredito, C.TipoReprog, C.Estado, D.SaldoCapital, 
              D.InteresVigente, D.InteresVencido, D.MoratorioVigente, D.MoratorioVencido, 
              C.NroDiasAtraso, PR.Identificador
        FROM tCsCartera C
        INNER JOIN tCsCarteraDet D ON C.CodPrestamo = D.CodPrestamo AND C.Fecha = D.Fecha 
        INNER JOIN tCsRenegociadosVigentes RV ON C.CodPrestamo = RV.CodPrestamo
        INNER JOIN tClPeriodo O ON O.Periodo = RV.Periodo AND C.Fecha >= O.UltimoDia 
        LEFT  JOIN tCaClProvision PR ON RV.ReprogProvision = PR.TipoReprog AND C.CodTipoCredito = PR.CodTipoCredito 
                                    AND C.Fecha <= PR.VigenciaFin AND C.Fecha >= PR.VigenciaInicio 
                                    AND C.NroDiasAtraso <= PR.DiasMaximo AND C.NroDiasAtraso >= PR.DiasMinimo 
                                    AND C.Estado = PR.Estado
        WHERE D.Fecha = @Fecha
    ) Prov
    INNER JOIN tCsCarteraDet D
            ON Prov.CodPrestamo = D.CodPrestamo AND Prov.Fecha = D.Fecha AND Prov.CodUsuario = D.CodUsuario
			
End
*/
--***********************************************************************************************************************
/*
If @Paso = 4 --- ACTUALIZANDO VALOR DE IDA EN tCsCarteraDet y tCsPadronClientes
Begin
    UPDATE tcscarteradet
    SET  ida = origen.ida
    FROM (SELECT Fecha, CodUsuario, IAtrasoDia + IAtrasoMes + IAtrasoAño AS IDA
          FROM   tCsDiasAtraso with(nolock)
          WHERE Aceptado = 1 And Fecha = @Fecha
    ) Origen INNER JOIN tCsCarteraDet ON Origen.CodUsuario = tCsCarteraDet.CodUsuario AND Origen.Fecha = tCsCarteraDet.Fecha

    UPDATE tCsCarteraDet
    SET  IDA = IDA.IDA
    FROM tCsCarteraDet 
    INNER JOIN (
        SELECT Fecha, CodPrestamo, MIN(IDA) AS IDA
        FROM   tCsCarteraDet
        WHERE Fecha = @Fecha AND IDA IS NOT NULL
        GROUP BY Fecha, CodPrestamo
    ) IDA ON tCsCarteraDet.Fecha = IDA.Fecha AND tCsCarteraDet.CodPrestamo = IDA.CodPrestamo COLLATE Modern_Spanish_CI_AI
    WHERE tCsCarteraDet.IDA IS NULL AND tCsCarteraDet.Fecha = @Fecha
    
    UPDATE tcspadronclientes
    SET  IDA = datos.ida
    FROM (
        SELECT Corte.CodUsuario, Corte.Fecha, tCsCarteraDet.IDA
        FROM (
            SELECT CodUsuario, MAX(Fecha) AS Fecha
            FROM tCsCarteraDet with(nolock)
            GROUP BY CodUsuario
        ) Corte INNER JOIN tCsCarteraDet ON Corte.CodUsuario = tCsCarteraDet.CodUsuario AND Corte.Fecha = tCsCarteraDet.Fecha
    ) Datos
    INNER JOIN tCsPadronClientes ON Datos.CodUsuario = tCsPadronClientes.CodUsuario
End
*/

--***********************************************************************************************************************
If @Paso = 5
Begin

    Delete From tCsClientesAhorrosFecha  
    Where Fecha = @Fecha   
       
    Insert Into tCsClientesAhorrosFecha   
            (Fecha,   CodOficina, CodCuenta, FraccionCta, Renovado, CodUsCuenta, Coordinador, idEstado, FormaManejo, CodUsuario, Observacion)
    SELECT A.Fecha, A.CodOficina, ISNULL(CA.CodCuenta, A.CodCuenta) AS CodCuenta, ISNULL(CA.FraccionCta, A.FraccionCta) AS FraccionCTa,
           ISNULL(CA.Renovado, A.Renovado) AS Renovado, ISNULL(CA.CodUsCuenta, A.CodUsuario) AS UsCuenta,
           ISNULL(CA.Coordinador, 1) AS Coordinador, ISNULL(CA.idEstado, 'AC') AS idEstado, A.FormaManejo, A.CodUsuario,
           CASE WHEN CA.CodCuenta IS NULL
                THEN 'Cuenta de Ahorro: ' + A.CodCuenta + ', no tiene registrado titular en la tabla de clientes de ahorros'
                ELSE 'Registro Automático' END AS Observacion
    FROM tCsClientesAhorros CA with(nolock)   
    RIGHT JOIN tCsAhorros A with(nolock) ON CA.CodCuenta = A.CodCuenta AND CA.FraccionCta = A.FraccionCta AND CA.Renovado = A.Renovado  
    WHERE A.Fecha = @Fecha  

    UPDATE tCsClientesAhorrosFecha
    SET    Coordinador = 0
    WHERE  Fecha = @Fecha

    UPDATE tCsClientesAhorrosFecha  
    SET    Coordinador = 1  
    WHERE  FormaManejo = 1 AND Fecha = @Fecha  

    UPDATE tCsClientesAhorrosFecha  
    SET    Coordinador = 1  
    WHERE  Fecha = @Fecha AND FormaManejo <> 1 AND CodUsCuenta = CodUsuario  

    Declare @CodCuenta  Varchar(25)  
    Declare @FraccionCta Varchar(8)  
    Declare @Renovado Int  
    Declare @Suma  Decimal(18, 4)  
    Declare @Contador Int  
    Declare @CodUsuario Varchar(15)  

    Declare curFragmento1 Cursor For   
        SELECT CodCuenta, FraccionCta, Renovado, Suma = SUM(CAST(Coordinador AS int))
        FROM tCsClientesAhorrosFecha
        WHERE Fecha = @Fecha And idEstado = 'AC'
        and CodCuenta <> '073-110-06-2-9-00052'  --OJO OMAR **X*X*X*X*X*X*X*X*X*X*X*X*X*X*X*X*X*X*X************************
        GROUP BY CodCuenta, FraccionCta, Renovado
        HAVING  SUM(CAST(Coordinador AS int)) <> 1  
    Open curFragmento1  
    Fetch Next From curFragmento1 Into @CodCuenta, @FraccionCta, @Renovado, @Suma  
    While @@Fetch_Status = 0  
    Begin   

        If @Suma <> 0   
        Begin   
            SELECT @Suma = COUNT(*)   
            FROM   tCsClientesAhorrosFecha with(nolock)  
            WHERE  CodCuenta = @CodCuenta AND Fecha = @Fecha AND FraccionCta = @FraccionCta AND Renovado = @Renovado And CodUsCuenta = CodUsuario  
        End

        If @Suma Is null Begin Set @Suma = 0 End  
         
        If @Suma = 0  
        Begin  
            SELECT @Contador = COUNT(*)   
            FROM   tCsClientesAhorrosFecha with(nolock)  
            WHERE  CodCuenta = @CodCuenta AND Fecha = @Fecha AND CodUsCuenta <> CodUsuario AND FraccionCta = @FraccionCta AND Renovado = @Renovado  
             
            If @Contador Is Null   
               Set @Contador = 0  
                 
            If @Contador >= 1  
            Begin  

                print 'AQUI 1: ' + @CodCuenta + ',' + @FraccionCta +',' + convert(varchar, @Renovado)
                Insert Into tCsClientesAhorrosFecha   
                               (Fecha, CodOficina, CodCuenta, FraccionCta, Renovado, CodUsCuenta, Coordinador, idEstado, FormaManejo, CodUsuario, Observacion)  
                SELECT DISTINCT Fecha, CodOficina, CodCuenta, FraccionCta, Renovado, CodUsuario as CodUsCuenta, Coordinador, idEstado, FormaManejo, CodUsuario,   
                                'Cuenta de Ahorro: ' +  CodCuenta + ', Inconsistente en la relacion con los titulares' AS Observacion  
                FROM  tCsClientesAhorrosFecha with(nolock)  
                WHERE CodCuenta = @CodCuenta AND Fecha = @Fecha AND CodUsCuenta <> CodUsuario AND FraccionCta = @FraccionCta AND Renovado = @Renovado  
                print 'AQUI 2: ' + @CodCuenta + ',' + @FraccionCta +',' + convert(varchar, @Renovado)      
                
                SELECT @Contador = Count(*)  
                FROM   tCsClientesAhorrosFecha CAF with(nolock)   
                INNER JOIN tCsAhorros A with(nolock) ON CAF.CodCuenta = A.CodCuenta AND CAF.Fecha = A.Fecha AND CAF.FraccionCta = A.FraccionCta AND CAF.Renovado = A.Renovado   
                INNER JOIN tCsPadronClientes PC with(nolock) ON CAF.CodUsCuenta = PC.CodUsuario  
                WHERE CAF.CodCuenta = @CodCuenta AND CAF.Fecha = @Fecha   
                AND CAF.FraccionCta = @FraccionCta AND CAF.Renovado = @Renovado   
                AND DIFFERENCE(rtrim(ltrim(PC.NombreCompleto)), ltrim(rtrim(A.NomCuenta))) = 4
          
                If @Contador Is null Begin Set @Contador = 0 End  
                  
                If @Contador = 1   
   Begin 
                    SELECT @CodUsuario = CodUsCuenta  
                    FROM tCsClientesAhorrosFecha CAF with(nolock)   
                    INNER JOIN tCsAhorros A with(nolock) ON CAF.CodCuenta = A.CodCuenta AND CAF.Fecha = A.Fecha AND CAF.FraccionCta = A.FraccionCta AND CAF.Renovado = A.Renovado
                    INNER JOIN tCsPadronClientes PC with(nolock) ON CAF.CodUsCuenta = PC.CodUsuario
                    WHERE CAF.CodCuenta = @CodCuenta AND CAF.Fecha = @Fecha
                    AND CAF.FraccionCta = @FraccionCta AND CAF.Renovado = @Renovado
                    AND DIFFERENCE(rtrim(ltrim(PC.NombreCompleto)), ltrim(rtrim(A.NomCuenta))) = 4

                    Update tCsClientesAhorrosFecha  
                    Set CodUsuario = @CodUsuario   
                    WHERE Fecha = @Fecha AND CodCuenta = @CodCuenta AND FraccionCta = @FraccionCta AND Renovado = @Renovado  
                End  
                Else  
                Begin  
                    SELECT @Contador = Count(*)
                    FROM tCsClientesAhorrosFecha CAF with(nolock)   
                    INNER JOIN tCsAhorros A with(nolock) ON CAF.CodCuenta = A.CodCuenta AND CAF.Fecha = A.Fecha AND CAF.FraccionCta = A.FraccionCta AND CAF.Renovado = A.Renovado   
                    INNER JOIN tCsPadronClientes PC with(nolock) ON CAF.CodUsCuenta = PC.CodUsuario AND Ltrim(Rtrim(A.NomCuenta)) = Ltrim(Rtrim(PC.NombreCompleto))  
                    WHERE CAF.CodCuenta = @CodCuenta AND CAF.Fecha = @Fecha AND CAF.FraccionCta = @FraccionCta AND CAF.Renovado = @Renovado  

                    If @Contador Is null Begin Set @Contador = 0 End  

                    If @Contador = 1   
                    Begin  
                        SELECT @CodUsuario = CodUsCuenta  
                        FROM tCsClientesAhorrosFecha CAF with(nolock)   
                        INNER JOIN tCsAhorros A with(nolock) ON CAF.CodCuenta = A.CodCuenta AND CAF.Fecha = A.Fecha AND CAF.FraccionCta = A.FraccionCta AND CAF.Renovado = A.Renovado   
                        INNER JOIN tCsPadronClientes PC with(nolock) ON CAF.CodUsCuenta = PC.CodUsuario AND A.NomCuenta = PC.NombreCompleto  
                        WHERE CAF.CodCuenta = @CodCuenta AND CAF.Fecha = @Fecha AND CAF.FraccionCta = @FraccionCta AND CAF.Renovado = @Renovado  

                        Update tCsClientesAhorrosFecha  
                        Set CodUsuario = @CodUsuario   
                        WHERE Fecha = @Fecha AND CodCuenta = @CodCuenta AND FraccionCta = @FraccionCta AND Renovado = @Renovado  
                    End  
                End  
            End  
        End  
        
        SELECT @Suma = SUM(CAST(Coordinador AS int))  
        FROM   tCsClientesAhorrosFecha with(nolock)  
        WHERE Fecha = @Fecha And idEstado = 'AC' And CodCuenta = @CodCuenta AND Fecha = @Fecha AND FraccionCta = @FraccionCta AND Renovado = @Renovado  
        GROUP BY CodCuenta, FraccionCta, Renovado  
         
        If @Suma Is null Begin Set @Suma = 0 End  

        If @Suma <> 0  
        Begin  
            Select @Contador = FormaManejo    
            From   tCsClientesAhorrosFecha with(nolock)  
            WHERE  CodCuenta = @CodCuenta AND Fecha = @Fecha AND FraccionCta = @FraccionCta AND Renovado = @Renovado  
             
            If @Contador = 1  
            Begin  
                Delete From tCsClientesAhorrosFecha  
                WHERE CodCuenta = @CodCuenta AND Fecha = @Fecha AND FraccionCta = @FraccionCta AND Renovado = @Renovado And CodUsCuenta <> CodUsuario  
            End  
        End  
        Fetch Next From curFragmento1 Into @CodCuenta, @FraccionCta, @Renovado, @Suma  
    End 
    Close   curFragmento1  
    Deallocate  curFragmento1  


    ------------------------------------------------------------------------------------------


    UPDATE    tCsClientesAhorrosFecha  
    SET       Coordinador = 0  
   WHERE   Fecha = @Fecha  

    UPDATE    tCsClientesAhorrosFecha  
    SET       Coordinador = 1  
    WHERE     FormaManejo = 1 AND Fecha = @Fecha  

    UPDATE    tCsClientesAhorrosFecha  
    SET       Coordinador = 1  
    WHERE     Fecha = @Fecha AND FormaManejo <> 1 AND CodUsCuenta = CodUsuario  

    UPDATE tCsClientesAhorrosFecha  
    SET    Capital = A.SaldoCuenta / Cast(F.Factor as Decimal(13,8)), Interes = A.IntAcumulado / Cast(F.Factor as Decimal(13,8)), InteresDia  = A.MontoInteres / Cast(F.Factor as Decimal(13,8))  
    FROM (  
        SELECT Fecha, CodOficina, CodCuenta, FraccionCta, Renovado, idestado, COUNT(*) AS Factor
        FROM tCsClientesAhorrosFecha with(nolock)
        WHERE Fecha = @Fecha AND idEstado = 'AC'
        GROUP BY Fecha, CodOficina, CodCuenta, FraccionCta, Renovado, idestado
    ) F  
    INNER JOIN tCsClientesAhorrosFecha CAF ON F.Fecha = CAF.Fecha AND F.CodOficina = CAF.CodOficina AND F.CodCuenta = CAF.CodCuenta   
           AND F.FraccionCta = CAF.FraccionCta AND F.Renovado = CAF.Renovado AND F.idestado = CAF.idEstado   
    INNER JOIN tCsAhorros A ON CAF.Fecha = A.Fecha AND CAF.CodCuenta = A.CodCuenta   
           AND CAF.FraccionCta = A.FraccionCta AND CAF.Renovado = A.Renovado  
    WHERE CAF.Fecha = @Fecha AND A.Fecha = @Fecha  

    UPDATE tCsAhorros  
    SET    Codusuario = Z.coduscuenta  
    FROM   tCsClientesAhorrosFecha Z with(nolock)   
    WHERE LTRIM(RTRIM(ISNULL(tCsAhorros.CodUsuario, ''))) = '' AND z.coordinador = 1 and tCsAhorros.Fecha = @Fecha  
    AND Z.Fecha = tCsAhorros.Fecha AND Z.CodCuenta = tCsAhorros.CodCuenta   
    AND Z.FraccionCta = tCsAhorros.FraccionCta AND Z.Renovado = tCsAhorros.Renovado


End
GO