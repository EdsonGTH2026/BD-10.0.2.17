SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCaDatosDelPrestamo]
@P varchar(25)
--with encryption
as
set nocount on -- <-- Noel. Optimizacion

declare @tCaPrestamos table (
CodPrestamo     varchar(25),
FechaDesembolso datetime,
MontoDesembolso money,
CodUsuario      varchar(15),
CodGrupo        varchar(15),
CodAsesor       varchar(15),
CodCuenta       varchar(25),
Fechaproceso    datetime,
CodTipoPlan     tinyint,
CodTipoPlaz     char(1),
CodTipoCredito  tinyint,
Plazo           int,
Cuotas          int,
Estado          varchar(10),
Calificacion    varchar(3),
MontoPrevision  money,
TipoReprog      char(5),
FechaReprog     datetime,
Numreprog       smallint,
codMoneda       varchar(2),
CodProducto     char(3),
CodFondo        char(2),
CodActividadDes varchar(6),
TipoEstado			CHAR(1)
)

declare @DiasMora int
select @DiasMora = DiasMora from tCaPrestamos where CodPrestamo = @P --and FechaPago is Null

insert into @tCaPrestamos
      (CodPrestamo, FechaDesembolso, MontoDesembolso, CodUsuario, CodGrupo, CodAsesor, CodCuenta, Fechaproceso, CodTipoPlan, CodTipoPlaz, CodTipoCredito, Plazo, Cuotas, Estado, Calificacion, MontoPrevision, TipoReprog, FechaReprog, Numreprog, codMoneda, CodProducto, CodFondo, CodActividadDes, TipoEstado)
select CodPrestamo, FechaDesembolso, MontoDesembolso, CodUsuario, CodGrupo, CodAsesor, CodCuenta, Fechaproceso, CodTipoPlan, CodTipoPlaz, CodTipoCredito, Plazo, Cuotas, Estado, Calificacion, MontoPrevision, TipoReprog, FechaReprog, Numreprog, codMoneda, CodProducto, CodFondo, CodActividadDes, TipoEstado
from tCaPrestamos
where CodPrestamo = @P

select 'A' CodGrupo, 'Datos del Prestamo     ' NombreGrupo, ' 1 - Codigo de Prestamo' Descripcion, @P Valor
union all select 'A', 'Datos del Prestamo     ', ' 2 - Grupo', NombreGrupo from tCaGrupos where CodGrupo = (select CodGrupo from @tCaPrestamos where CodPrestamo = @P)
union all select 'A', 'Datos del Prestamo     ', ' 3 - Nombre (Coordinador)', NombreCompleto from tUsUsuarios where CodUsuario = (select CodUsuario from @tCaPrestamos where CodPrestamo = @P)
union all select 'A', 'Datos del Prestamo     ', ' 4 - Documento de Identificacion', rtrim(di) + ' (' + DI.CodDocIden + '-' + DocIdentidad + ')' from tUsUsuarios U
                                                                                 inner join tUsClDocIdentidad DI on U.CodDocIden = DI.CodDocIden
                                                                                 where CodUsuario = (select CodUsuario from @tCaPrestamos where CodPrestamo = @P)
union all select 'A', 'Datos del Prestamo     ', ' 5 - Fecha de Desembolso', convert(varchar(20), FechaDesembolso, 103) from @tCaPrestamos where CodPrestamo = @P
union all select 'A', 'Datos del Prestamo     ', ' 6 - Monto Desembolsado', dbo.fGrFormatoMiles(cast(MontoDesembolso as varchar(30))) from @tCaPrestamos where CodPrestamo = @P
union all select 'A', 'Datos del Prestamo     ', ' 7 - Moneda', DescMoneda + ' (' + DescAbreviada + ')' from tClMonedas where CodMoneda = (select CodMoneda from @tCaPrestamos where CodPrestamo = @P)
union all select 'A', 'Datos del Prestamo     ', ' 8 - Cuenta de Ahorro', CodCuenta from @tCaPrestamos where CodPrestamo = @P
union all select 'A', 'Datos del Prestamo     ', ' 9 - Fecha Proceso del Prestamo', convert(varchar(20), FechaProceso, 103) from @tCaPrestamos where CodPrestamo = @P
union all select 'A', 'Datos del Prestamo     ', '10 - Nivel de Aprobación', case when au.nivelautoriza = 'P' then 'Usuario: ' + au.CodUsAutoriza
                                                                                  when au.nivelautoriza = 'C' then 'Comite: ' + au.CodComite 
                                                                                  when au.nivelautoriza = 'E' then 'Encargado de Agencia'	
                                                                             end nivelaprobacion
                                                                             from tSgAutorizaciones Au 
                                                                             inner join tCaProdMontosAprobacion Pm on pm.codautoriza=au.codautoriza
                                                                             inner join @tCaPrestamos P on pm.codproducto = P.codproducto and pm.codmoneda = P.codmoneda 
                                                                             and p.montodesembolso >= pm.montominimo and p.montodesembolso <= pm.montomaximo
                                                                             where CodPrestamo = @P

union all select 'A', 'Datos del Prestamo     ', '11 - Ciclo', cast(case when P.CodGrupo is null then SecPrestCliente else SecPrestGrupo end as varchar(5))
                                                               from @tCaPrestamos P
                                                               inner join (select top 1 CodPrestamo, SecPrestCliente, SecPrestGrupo from tCaPrCliente where CodPrestamo = @P) C
                                                               on P.CodPrestamo = C.CodPrestamo
                                                               where P.CodPrestamo = @P

union all select 'A', 'Datos del Prestamo     ', '12 - Fondo', CodFondo + ' - ' + DescFondo from tClFondos where CodFondo = (select CodFondo from @tCaPrestamos where CodPrestamo = @P)
union all select 'A', 'Datos del Prestamo     ', '13 - Destino', CodDestino + ' - ' + DescDestino from tCaClDestino where CodDestino = (select CodActividadDes from @tCaPrestamos where CodPrestamo = @P)


union all select 'B', 'Condiciones Crediticias', '14 - Producto de Credito', CodProducto + ' - ' + NombreProd from tCaProducto where CodProducto = (select CodProducto from @tCaPrestamos where CodPrestamo = @P)
union all select 'B', 'Condiciones Crediticias', '15 - Tipo de Plan', DescTipoPlan from tCaClTipoPlan TP inner join @tCaPrestamos P on P.CodTipoPlan = TP.CodTipoPlan and P.CodTipoCredito = TP.CodTipoCredito and P.CodPrestamo = @P
union all select 'B', 'Condiciones Crediticias', '16 - Tipo de Plazo', DescTipoPlaz from tCaClTipoPlaz where CodTipoPlaz = (select CodTipoPlaz from @tCaPrestamos where CodPrestamo = @P)
union all select 'B', 'Condiciones Crediticias', '17 - Plazo', cast(Plazo as varchar(10)) from @tCaPrestamos where CodPrestamo = @P
union all select 'B', 'Condiciones Crediticias', '18 - Numero de Cuotas (Docs.)', cast(Cuotas as varchar(10)) from @tCaPrestamos where CodPrestamo = @P
union all select 'B', 'Condiciones Crediticias', '19 - Tasa de Interes Anual', cast(CAST(ValorConcepto AS DEC(25,4)) as varchar(10)) + '%'  from tCaConcPre where CodPrestamo = @P and CodConcepto = 'INTE'
union all select 'B', 'Condiciones Crediticias', '20 - Tasa de Interes Mensual', cast(( CAST(ValorConcepto AS DEC(25,4)) / 12) as varchar(10)) + '%' from tCaConcPre where CodPrestamo = @P and CodConcepto = 'INTE'
union all select 'B', 'Condiciones Crediticias', '21 - ' + DescConcepto + ' Anual', cast(P.Valor as varchar(20)) + '%' from tcaclconcepto C inner join tCaPrestamoConceptoAplica P on C.CodConcepto = P.CodConcepto where C.CodConcepto = 'INVE' and codPrestamo = @P
union all select 'B', 'Condiciones Crediticias', '22 - ' + DescConcepto + ' Anual', cast(P.Valor as varchar(20)) + '%' from tcaclconcepto C inner join tCaPrestamoConceptoAplica P on C.CodConcepto = P.CodConcepto where C.CodConcepto = 'INPE' and codPrestamo = @P
union all select 'C', 'Calificacion           ', '23 - Estado del Prestamo', case	when TipoEstado = 'A' 
																												THEN CASE when P.Estado in ('CASTIGADO', 'EJECUCION', 'CANCELADO', 'ANULADO') then P.Estado else CL.Descripcion end
																												else P.Estado end
                                                                             from @tCaPrestamos P inner join
                                                                             tCAClasificacion CL on P.CodTipoCredito = CL.CodTipoCredito and @Diasmora between CL.IniEstado and CL.FinEstado
union all select 'C', 'Calificacion           ', '24 - Dias de Atraso', cast(@DiasMora as varchar(10))
union all select 'C', 'Calificacion           ', '25 - Tipo Crédito', cast(CodTipoCredito as varchar(2)) + ' - ' + Descripcion from tCaProdPerTipoCredito where CodTipoCredito = (select CodTipoCredito from @tCaPrestamos where CodPrestamo = @P)
union all select 'C', 'Calificacion           ', '26 - Calificación', NemCalificacion + ' - ' + DescCalificacion from tCaClCalificacion where CodCalificacion = (select Calificacion from @tCaPrestamos where CodPrestamo = @P)
union all select 'C', 'Calificacion           ', '27 - Provisión', cast(MontoPrevision as varchar(15)) from @tCaPrestamos where CodPrestamo = @P
union all select 'C', 'Calificacion           ', '28 - Renegociación:', TipoReprog from @tCaPrestamos where CodPrestamo = @P
union all select 'C', 'Calificacion           ', '29 - Fecha Ult. Renegoc.:', convert(varchar(20), FechaReprog, 103) from @tCaPrestamos where CodPrestamo = @P
union all select 'C', 'Calificacion           ', '30 - # Renegociaciones:', cast(NumReprog as varchar(15)) from @tCaPrestamos where CodPrestamo = @P
union all select 'D', 'Garantias              ', '31 - Garantias', rtrim(G.DocPropiedad) + ' / ' + cast(G.MoAFavor as varchar(20)) + ' ' + M.DescAbreviada + ' / ' + TG.DescGarantia
                                                              FROM tGaClTipoGarantias TG
                                                              INNER JOIN tGaGarantias G ON TG.TipoGarantia = G.TipoGarantia 
                                                              Inner Join tClMonedas M ON G.CodMoneda = M.CodMoneda 
                                                              WHERE G.Codigo = @P AND G.Activo = 1
union all select 'E', 'Datos del Asesor       ', '32 - Asesor/Sectorista', NombreCompleto from tUsUsuarios where CodUsuario = (select CodAsesor from @tCaPrestamos where CodPrestamo = @P)
union all select 'E', 'Datos del Asesor       ', '33 - % de Mora del Asesor:', CAST(ISNULL(ISNULL((SELECT SUM(CLI.MontoDevengado - CLI.MontoPagado - CLI.MontoCondonado)
                                                                              FROM tCaCuotasCli CLI
                                                                              WHERE
                                                                                 CLI.CodPrestamo = PR.CodPrestamo
                                                                              AND CLI.CodConcepto IN ('INVE','INPE')),0)
                                                                        / 
                                                                         (select sum(cc.montodevengado - cc.montopagado - cc.montocondonado) as MoraTotal
                                                                              from
                                                                                 tcaprestamos pp
                                                                              inner join tcacuotascli cc on pp.codprestamo = cc.codprestamo
                                                                              where
                                                                                  pp.Estado NOT IN ('TRAMITE','APROBADO')
                                                                              and cc.numeroplan = 0
                                                                              and cc.codconcepto IN ('INVE','INPE')
                                                                              and cc.montodevengado > cc.montopagado + cc.montocondonado
                                                                              and pp.CodAsesor = PR.CodAsesor)
                                                                        * 100, 0) AS VARCHAR(15)) + '%'
                                                                     FROM
                                                                        tCaPrestamos PR
                                                                      WHERE
                                                                         PR.CodPrestamo = @P

-----------------------------------------------------------------------
-- Se incorpora esta linea para las cuentas que existen en la tabla TCACTASLIQPAGO RPP 29.04.2014

union all 
select 'F', 'Credito cedido,comunicarse a gerencia de cobranza        ', '34 - CREDITO EN VENTA:', codprestamo --34
          from TCACTASLIQPAGO 
          WHERE CODPRESTAMO = @P
--union all 
-----------------------------------------------------------------------


order by 3


--------------------------------------------------------------------------------
GO