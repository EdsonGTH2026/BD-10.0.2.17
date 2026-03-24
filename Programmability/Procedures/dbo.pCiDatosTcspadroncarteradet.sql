SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCiDatosTcspadroncarteradet]  
as  
Declare @Fecha SmallDateTime  
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion  
  
Delete From tCsPadronCarteraDet Where FechaCorte = @Fecha and codoficina not in('230','231')  
  
Insert Into tCsPadronCarteraDet  
       (CodPrestamo, CodUsuario, CodOficina, FechaCorte, CodGrupo, Coordinador, CodProducto, SecuenciaPrestamo, SecuenciaGrupo,   
        SecuenciaCliente, SaldoOriginal, SaldoCalculado, EstadoOriginal, EstadoCalculado, PaseVencido, PaseCastigado, Desembolso,   
        Cancelacion, TipoReprog, Renegociaciones, PeriodoAnterior, SaldoAnterior)  
SELECT CD.CodPrestamo,  CD.CodUsuario, CD.CodOficina, CD.Fecha AS FechaCorte, C.CodGrupo,   
       CASE WHEN CD.codusuario = C.codusuario THEN 1 ELSE 0 END AS Coordinador, C.CodProducto, PCD.SecuenciaPrestamo,   
       PCD.SecuenciaGrupo, PCD.SecuenciaCliente, CD.SaldoCapital, PCD.SaldoCalculado, C.Estado, PCD.EstadoCalculado,   
       PCD.PaseVencido, PCD.PaseCastigado, C.FechaDesembolso, PCD.Cancelacion, C.TipoReprog, C.NumReprog,   
       dbo.fduFechaAPeriodo(CAST(dbo.fduFechaAPeriodo(CD.Fecha) + '01' AS smalldatetime) - 1) AS PeriodoAnterior, PCD.SaldoAnterior  
FROM tCsCarteraDet CD with(nolock)  
LEFT JOIN tCsCartera C with(nolock) ON CD.CodPrestamo = C.CodPrestamo AND CD.Fecha = C.Fecha   
LEFT JOIN tCsPadronCarteraDet PCD with(nolock) ON CD.CodPrestamo = PCD.CodPrestamo AND CD.CodUsuario = PCD.CodUsuario  
WHERE CD.Fecha = @Fecha  
AND PCD.CodPrestamo IS NULL  
and cd.codoficina not in('230','231')  
  
select *   
into #tCsCarteraDet  
from tCsCarteraDet with(nolock)  
Where Fecha = @Fecha  
  
select *   
into #tCsCartera  
from tCsCartera with(nolock)  
Where Fecha = @Fecha  


CREATE NONCLUSTERED INDEX [IX_temp] ON #tCsCarteraDet ([Fecha])
INCLUDE ([CodPrestamo],[CodUsuario]);

  
--DATOS PARA ACTUALIZACION DE INFORMACION  
UPDATE tcspadroncarteradet  
SET fechacorte = D.FechaCorte, coordinador = D.Coordinador, saldooriginal = D.SaldoOriginal, estadooriginal = D.EstadoOriginal,   
    Desembolso = D.Desembolso, Tiporeprog = D.TipoReprog, Renegociaciones = D.numreprog  
FROM (  
    SELECT C.CodPrestamo, C.CodUsuario, C.FechaCorte,   
           CASE WHEN C.CodUsuario = CR.CodUsuario THEN 1 ELSE 0 END AS Coordinador, CD.SaldoCapital AS SaldoOriginal,   
           CR.Estado AS EstadoOriginal, CR.FechaDesembolso AS Desembolso, CR.TipoReprog, CR.numreprog  
    FROM (  
        SELECT CodPrestamo, CodUsuario, MAX(Fecha) AS FechaCorte  
        FROM   #tCsCarteraDet with(nolock)  
    Where Fecha = @Fecha  
        GROUP BY CodPrestamo, CodUsuario  
    ) C  
    INNER JOIN #tCsCartera CR ON C.CodPrestamo = CR.CodPrestamo AND C.FechaCorte = CR.Fecha   
    INNER JOIN #tCsCarteraDet CD ON C.CodPrestamo = CD.CodPrestamo AND C.FechaCorte = CD.Fecha AND C.CodUsuario = CD.CodUsuario  
) D  
WHERE D.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND D.CodUsuario = tCsPadronCarteraDet.CodUsuario  
and tCsPadronCarteraDet.codoficina not in('230','231')  
  
UPDATE tCsPadronCarteraDet  
SET    SaldoCalculado = 0, EstadoCalculado = 'CANCELADO', Cancelacion = FechaCorte + 1  
WHERE  FechaCorte = @Fecha - 1  
and tCsPadronCarteraDet.codoficina not in('230','231')  
  
UPDATE tCsPadronCarteraDet  
SET    SaldoCalculado = SaldoOriginal, EstadoCalculado = EstadoOriginal  
WHERE  FechaCorte = @Fecha and Cancelacion IS NULL  
and tCsPadronCarteraDet.codoficina not in('230','231')  


  
/*CUM 2023.01.02 se cambia x el de abajo*/  
--UPDATE tcspadroncarteradet  
--SET    pasevencido = D.pasevencido  
--FROM (  
--    SELECT CodPrestamo, MAX(Fecha) AS PaseVencido  
--    FROM (  
--        SELECT T.CodPrestamo, T.Estado, MIN(C.Fecha) AS Fecha  
--        FROM (SELECT DISTINCT CodPrestamo, Estado  
--              FROM tCsCartera with(nolock)  
--       WHERE Estado = 'VENCIDO'  
--        ) T   
--        INNER JOIN tCsCartera C with(nolock) ON T.CodPrestamo = C.CodPrestamo  
--        WHERE C.Estado = 'VENCIDO'  
--        GROUP BY T.CodPrestamo, T.Estado  
--    ) Datos  
--    GROUP BY CodPrestamo  
--) D   
--WHERE tCsPadronCarteraDet.CodPrestamo = D.CodPrestamo and FechaCorte = @Fecha  
--and tCsPadronCarteraDet.codoficina not in('230','231')  
  
--select x.codprestamo,x.fecha,d.pasevencido  
update tcspadroncarteradet  
set pasevencido=x.fecha  
from tcscartera x with(nolock)  
inner join tcscartera y with(nolock) on x.fecha-1=y.fecha and x.codprestamo=y.codprestamo  
inner join tcspadroncarteradet d with(nolock) on d.codprestamo=x.codprestamo  
where x.Fecha = @Fecha and x.estado='VENCIDO' and y.estado='VIGENTE'  
  
  
 
/*CUM 2023.01.02 se cambia x el de abajo*/  
--UPDATE tcspadroncarteradet  
--SET    paseCastigado = Z.pasevencido  
--FROM (  
--    SELECT CodPrestamo, MAX(Fecha) AS PaseVencido  
--    FROM (  
--        SELECT D.CodPrestamo, D.Estado, MIN(C.Fecha) AS Fecha  
--        FROM (  
--            SELECT DISTINCT CodPrestamo, Estado  
--            FROM tCsCartera with(nolock)  
--            WHERE Estado = 'CASTIGADO'--> aqui agregue  
--        ) D   
--        INNER JOIN tCsCartera C with(nolock) ON D.CodPrestamo = C.CodPrestamo  
--        WHERE C.Estado = 'CASTIGADO'  
--        GROUP BY D.CodPrestamo, D.Estado  
--    ) T  
--    GROUP BY CodPrestamo  
--) Z   
--where Z.CodPrestamo = tCsPadronCarteraDet.CodPrestamo and FechaCorte = @Fecha  
--and tCsPadronCarteraDet.codoficina not in('230','231')  
  
--select x.codprestamo,x.fecha,d.paseCastigado  


update tcspadroncarteradet  
set paseCastigado=x.fecha  
from tcscartera x with(nolock)  
inner join tcscartera y with(nolock) on x.fecha-1=y.fecha and x.codprestamo=y.codprestamo  
inner join tcspadroncarteradet d with(nolock) on d.codprestamo=x.codprestamo  
where x.Fecha = @Fecha and x.estado='CASTIGADO' and y.estado<>'CASTIGADO'  


  
/*aqui agregue*/  
declare @periodoanterior smalldatetime  
set  @periodoanterior=dateadd(day,-1,CAST(dbo.fduFechaAPeriodo(@Fecha) + '01' AS smalldatetime))  
  
UPDATE tcspadroncarteradet  
SET    Saldoanterior = D.saldocapital, periodoanterior = D.periodo  
FROM (  
    SELECT P.Periodo, C.CodPrestamo, C.CodUsuario, C.SaldoCapital  
    FROM tCsCarteraDet C with(nolock)   
    INNER JOIN tClPeriodo P ON C.Fecha = P.UltimoDia  
 where C.Fecha=@periodoanterior  
) D   
INNER JOIN tCsPadronCarteraDet DD  
ON D.CodPrestamo = DD.CodPrestamo AND D.CodUsuario = DD.CodUsuario   
--AND D.Periodo = dbo.fduFechaAPeriodo(CAST(dbo.fduFechaAPeriodo(tCsPadronCarteraDet.FechaCorte) + '01' AS smalldatetime) - 1)  
WHERE FechaCorte = @Fecha  
and DD.codoficina not in('230','231')  


  
--PARA PONER LAS SECUENCIAS DE CARTERA  
UPDATE tCsPadronCarteraDet  
SET    SecuenciaCliente = NULL  
WHERE CodUsuario IN (  
    SELECT CodUsuario  
    FROM (  
        SELECT CodUsuario, SecuenciaCliente, COUNT(*) AS C  
        FROM (  
            SELECT DISTINCT CodUsuario, CodPrestamo, SecuenciaCliente  
            FROM tCsPadronCarteraDet with(nolock)  
        ) AS Datos_1  
        GROUP BY CodUsuario, SecuenciaCliente  
        HAVING COUNT(*) > 1  
    ) AS Datos  
)  
and codoficina not in('230','231')  



  
UPDATE tcspadroncarteradet  
SET  secuenciaCliente = datos.secuencia  
FROM (  
    SELECT CodPrestamo, CodUsuario, CodGrupo, Desembolso, dbo.fduSecuenciaCartera(3, CodPrestamo, CodGrupo, CodUsuario, Desembolso, CodOficina) AS Secuencia  
    FROM tCsPadronCarteraDet  
    Where SecuenciaCliente Is null  
) Datos   
INNER JOIN tCsPadronCarteraDet D ON Datos.CodPrestamo = D.CodPrestamo AND Datos.CodUsuario = D.CodUsuario  
Where SecuenciaCliente Is null  
and D.codoficina not in('230','231')  
  
--UPDATE tcspadroncarteradet  
--SET  cancelacionanterior = filtro.cancelacionanterior  
--FROM (  
--    SELECT CodPrestamo, codusuario, SecuenciaCliente, CancelacionAnterior = dbo.fducancelacionAnterior(CodUsuario, desembolso)  
--    FROM tCsPadronCarteraDet  
--    WHERE SecuenciaCliente <> 1 AND CancelacionAnterior IS NULL  
--) Filtro   
--INNER JOIN tCsPadronCarteraDet D ON Filtro.codusuario = D.CodUsuario AND Filtro.CodPrestamo = D.CodPrestamo  
--where D.codoficina not in('230','231')


  
UPDATE tcspadroncarteradet  
SET  carteraorigen = Cartera  
FROM (  
    SELECT CodPrestamo, MIN(Fecha) AS Fecha  
    FROM tCsCartera with(nolock)  
    GROUP BY CodPrestamo  
) corte   
INNER JOIN tCsCartera C ON corte.Fecha = C.Fecha AND corte.CodPrestamo = C.CodPrestamo   
INNER JOIN tCsPadronCarteraDet D ON C.CodPrestamo = D.CodPrestamo  
WHERE D.CarteraOrigen IS NULL  
and D.codoficina not in('230','231')  
  
  
  
UPDATE tCsPadronCarteraDet  
SET   CarteraOrigen = 'ACTIVA'  
WHERE CarteraOrigen = 'CASTIGADA' Or tCsPadronCarteraDet.CarteraOrigen IS NULL  
and codoficina not in('230','231')  


  
UPDATE tcspadroncarteradet  
SET  carteraActual = Cartera  
FROM tCsCartera C with(nolock)   
INNER JOIN tCsPadronCarteraDet D ON C.CodPrestamo = D.CodPrestamo AND C.Fecha = D.FechaCorte  
WHERE (D.CarteraActual IS NULL Or Cartera = 'CASTIGADA') And EstadoCalculado <> 'CANCELADO'  
and D.codoficina not in('230','231')  


  
UPDATE tCsPadronCarteraDet  
SET   CarteraActual = 'ACTIVA'  
WHERE tCsPadronCarteraDet.CarteraActual IS NULL  
and codoficina not in('230','231')  
  
UPDATE tCsPadronCarteraDet  
SET  Monto = montodesembolso  
FROM tCsPadronCarteraDet P  
INNER JOIN tCsCarteraDet D with(nolock) ON P.CodPrestamo = D.CodPrestamo   
       AND P.CodUsuario = D.CodUsuario AND P.FechaCorte = D.Fecha  
where monto is null  
and P.codoficina not in('230','231')  
  
UPDATE tCsPadronCarteraDet  
SET  Ultimoasesor = Datos.codasesor,  
     NroCuotas = Datos.NroCuotas  
--select Datos.CodPrestamo, Datos.CodAsesor, Datos.NroCuotas  
FROM (  
    --SELECT C.CodPrestamo, C.CodAsesor, C.NroCuotas  
    --FROM (  
    --    SELECT CodPrestamo, Fecha  
    --    FROM tCsCartera with(nolock)  
    --    Where Fecha = @Fecha  
    --) Datos   
    --INNER JOIN tCsCartera C with(nolock) ON Datos.CodPrestamo = C.CodPrestamo AND Datos.Fecha = C.Fecha  
  SELECT CodPrestamo, Fecha, CodAsesor, NroCuotas  
    FROM #tCsCartera with(nolock)  
    Where Fecha = @Fecha  
) Datos   
INNER JOIN tCsPadronCarteraDet D ON Datos.CodPrestamo = D.CodPrestamo  
and D.codoficina not in('230','231')  
--and d.ultimoasesor<>datos.CodAsesor 
and isnull(d.ultimoasesor,'')<>datos.CodAsesor 
 

  
UPDATE tCsPadronCarteraDet   
Set PrimerAsesor = C.CodAsesor  
FROM tCsPadronCarteraDet D  
INNER JOIN #tCsCartera C with(nolock) ON D.Desembolso = C.Fecha AND D.CodPrestamo = C.CodPrestamo  
WHERE D.PrimerAsesor IS NULL And FechaCorte = @Fecha  
and D.codoficina not in('230','231')  
  
Update tCsPadronCarteraDet   
Set   PrimerAsesor = UltimoAsesor  
WHERE PrimerAsesor IS NULL And FechaCorte = @Fecha  
and codoficina not in('230','231')  
  
--CUM 21.05.2018 -- 02.01.2022  
UPDATE tCsPadronCarteraDet   
Set codverificador = C.codverificador  
FROM tCsPadronCarteraDet D  
INNER JOIN (select codprestamo, codverificador   
   from tCsCartera01 with(nolock)   
   where codverificador is not null  
   group by codprestamo, codverificador) c ON D.CodPrestamo = C.CodPrestamo  
WHERE D.FechaCorte = @Fecha  
and D.codoficina not in('230','231')  
and d.codverificador is null  

update tCsPadronCarteraDet  
set codverificador=c.codusuario  
from tCsPadronCarteraDet p  
inner join tcspadronclientes c on c.codorigen=p.codverificador  
where codverificador is not null  
and p.FechaCorte = @Fecha  
and p.codoficina not in('230','231')  
  
--insert into tcspadroncarterasecuen (codprestamo,secuenciaproductivo,secuenciaconsumo)  
--SELECT CodPrestamo--,CodUsuario, Desembolso  
--,dbo.fduSecuenciaCAProductivo(codprestamo,codusuario,desembolso,'170,169') secprodu  
--,dbo.fduSecuenciaCAProductivo(codprestamo,codusuario,desembolso,'370') secconsu  
--FROM tCsPadronCarteraDet with(nolock)  
--where codproducto in('169','170','370') and codprestamo not in(  
-- select codprestamo from tcspadroncarterasecuen with(nolock)  
--)  
----and codusuario='CFL820119F0455 '  
----order by Desembolso  
--and desembolso=@Fecha ---'20180831'  
----and desembolso>='20180701' and desembolso<='20180930'  
--and codoficina not in('230','231')  

drop table #tCsCarteraDet  
drop table #tCsCartera  
GO