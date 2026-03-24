SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsRptCaDesembolsosPorSemana] (
    @Fecha    SmallDateTime,
    @CodRegional varchar(4)  = '0',
    @CodOficina  varchar(4)  = '0',
    @CodAsesor   varchar(15) = '0',
    @Tipo        char(1)     = 'G'    -- G=Gerente, R=Lider Regional, S=Lider Sucursal, P=Promotor
)
As
set nocount on

--set @CodRegional = 'Z01'
--set @CodOficina = '5'
--set @CodAsesor = 'HDM2001821'
--declare @Fecha datetime
declare @periodo varchar(6)
declare @Semana  tinyint
declare @AnioInicio datetime
declare @AnioFinal  datetime
declare @MesInicio datetime
declare @MesFinal  datetime

--set @Fecha = '20150604'
set @periodo = cast(year(@Fecha) * 100 + month(@Fecha) as char(6))

set @AnioInicio = DATEADD(yy, DATEDIFF(yy,0, @Fecha), 0)
set @AnioFinal  = DATEADD(yy, DATEDIFF(yy,0, @Fecha) + 1, -1)
set @MesInicio  = DATEADD(mm, DATEDIFF(mm, 0, @Fecha), 0)
set @MesFinal   = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @Fecha) + 1, 0))

--select @AnioInicio, @AnioFinal, @MesInicio, @MesFinal

select @Semana = NroSemana
from fduTablaSemanaPeriodosFC(@periodo) S
where @Fecha between S.FechaIni and S.FechaFin

--select * from fduTablaSemanaPeriodosFC(@periodo)

declare @Tabla table (
    Zona              varchar(20),
    Regional          varchar(100),
    NomOficina        varchar(100),    
    Asesor            varchar(100),    
    CodOficina        varchar(5),
    CodAsesor         varchar(15),
    DiaNuevosCant     smallint,
    DiaNuevosMonto    money,
    DiaReprestCant    smallint,
    DiaReprestMont    money,
    SemanaNuevosCant  smallint,
    SemanaNuevosMonto money,                
    SemanaReprestCant smallint,
    SemanaReprestMont money,
    MesNuevosCant     smallint,
    MesNuevosMonto    money,
    MesReprestCant    smallint,
    MesReprestMont    money,
    AnualNuevosCant   smallint,
    AnualNuevosMonto  money,
    AnualReprestCant  smallint,
    AnualReprestMont  money
)

insert into @Tabla
select Z.Zona, Regional = Z.Zona + ' - ' + Z.Nombre, O.NomOficina, Asesor = dbo.proper(U.nombreCompleto), R.*
from (
    select A.CodOficina, CodAsesor = A.UltimoAsesor,
              DiaNuevosCant,    DiaNuevosMonto,    DiaReprestCant,    DiaReprestMont,
           SemanaNuevosCant, SemanaNuevosMonto, SemanaReprestCant, SemanaReprestMont,
              MesNuevosCant,    MesNuevosMonto,    MesReprestCant,    MesReprestMont,
            AnualNuevosCant,  AnualNuevosMonto,  AnualReprestCant,  AnualReprestMont
    from (
        select CodOficina, UltimoAsesor,
               AnualNuevosCant  = sum(case when secuenciacliente = 1 then 1     else 0 end),
               AnualNuevosMonto = sum(case when secuenciacliente = 1 then Monto else 0 end),
               AnualReprestCant = sum(case when secuenciacliente > 1 then 1     else 0 end),
               AnualReprestMont = sum(case when secuenciacliente > 1 then Monto else 0 end)
        from tCsPadronCarteraDet
        where TipoReprog = 'SINRE' and Desembolso between @AnioInicio and @AnioFinal
        group by CodOficina, UltimoAsesor
    ) A
    left join (
        select CodOficina, UltimoAsesor,
               MesNuevosCant  = sum(case when secuenciacliente = 1 then 1     else 0 end),
               MesNuevosMonto = sum(case when secuenciacliente = 1 then Monto else 0 end),
               MesReprestCant = sum(case when secuenciacliente > 1 then 1     else 0 end),
               MesReprestMont = sum(case when secuenciacliente > 1 then Monto else 0 end)
        from tCsPadronCarteraDet
        where TipoReprog = 'SINRE' and Desembolso between @MesInicio and @MesFinal
        group by CodOficina, UltimoAsesor
    ) M on A.CodOficina = M.CodOficina and A.UltimoAsesor = M.UltimoAsesor
    left join (
        select CodOficina, UltimoAsesor,
               SemanaNuevosCant  = sum(case when secuenciacliente = 1 then 1     else 0 end),
               SemanaNuevosMonto = sum(case when secuenciacliente = 1 then Monto else 0 end),
               SemanaReprestCant = sum(case when secuenciacliente > 1 then 1     else 0 end),
               SemanaReprestMont = sum(case when secuenciacliente > 1 then Monto else 0 end)
        from tCsPadronCarteraDet C
        inner join dbo.fduTablaSemanaPeriodos(@periodo) S on Desembolso between FechaIni and FechaFin
        where TipoReprog = 'SINRE' and S.NroSemana = @Semana
        group by CodOficina, UltimoAsesor
    ) S on A.CodOficina = S.CodOficina and A.UltimoAsesor = S.UltimoAsesor
    left join (
        select CodOficina, UltimoAsesor,
               DiaNuevosCant  = sum(case when secuenciacliente = 1 then 1     else 0 end),
               DiaNuevosMonto = sum(case when secuenciacliente = 1 then Monto else 0 end),
               DiaReprestCant = sum(case when secuenciacliente > 1 then 1     else 0 end),
               DiaReprestMont = sum(case when secuenciacliente > 1 then Monto else 0 end)
        from tCsPadronCarteraDet
        where TipoReprog = 'SINRE' and Desembolso = @Fecha
        group by CodOficina, UltimoAsesor
    ) D on A.CodOficina = D.CodOficina and A.UltimoAsesor = D.UltimoAsesor
) R
inner join tcloficinas O on R.codoficina = O.codoficina
inner join tClZona Z on O.ZOna = Z.Zona
inner join tCsPadronClientes U on R.CodAsesor = U.CodUsuario
where (@CodRegional = '0' or (@CodRegional <> '0' and O.Zona       = @CodRegional))
and   (@CodOficina  = '0' or (@CodOficina  <> '0' and O.CodOficina = @CodOficina)) 
and   (@CodAsesor   = '0' or (@CodAsesor   <> '0' and R.CodAsesor  = @CodAsesor))

if @Tipo = 'G'
    select Zona, Regional, NomOficina, Asesor = '', CodOficina, CodAsesor = '', Semana = @Semana,
              DiaNuevosCant = sum(   DiaNuevosCant),    DiaNuevosMonto = sum(   DiaNuevosMonto),    DiaReprestCant = sum(   DiaReprestCant),    DiaReprestMont = sum(   DiaReprestMont),
           SemanaNuevosCant = sum(SemanaNuevosCant), SemanaNuevosMonto = sum(SemanaNuevosMonto), SemanaReprestCant = sum(SemanaReprestCant), SemanaReprestMont = sum(SemanaReprestMont),
              MesNuevosCant = sum(   MesNuevosCant),    MesNuevosMonto = sum(   MesNuevosMonto),    MesReprestCant = sum(   MesReprestCant),    MesReprestMont = sum(   MesReprestMont),
            AnualNuevosCant = sum( AnualNuevosCant),  AnualNuevosMonto = sum( AnualNuevosMonto),  AnualReprestCant = sum( AnualReprestCant),  AnualReprestMont = sum( AnualReprestMont)
    from @Tabla
    group by Zona, Regional, NomOficina, CodOficina
    order by Zona, NomOficina

if @Tipo = 'R'
    select Zona, Regional, NomOficina, Asesor = '', CodOficina, CodAsesor = '', Semana = @Semana,
              DiaNuevosCant = sum(   DiaNuevosCant),    DiaNuevosMonto = sum(   DiaNuevosMonto),    DiaReprestCant = sum(   DiaReprestCant),    DiaReprestMont = sum(   DiaReprestMont),
           SemanaNuevosCant = sum(SemanaNuevosCant), SemanaNuevosMonto = sum(SemanaNuevosMonto), SemanaReprestCant = sum(SemanaReprestCant), SemanaReprestMont = sum(SemanaReprestMont),
              MesNuevosCant = sum(   MesNuevosCant),    MesNuevosMonto = sum(   MesNuevosMonto),    MesReprestCant = sum(   MesReprestCant),    MesReprestMont = sum(   MesReprestMont),
            AnualNuevosCant = sum( AnualNuevosCant),  AnualNuevosMonto = sum( AnualNuevosMonto),  AnualReprestCant = sum( AnualReprestCant),  AnualReprestMont = sum( AnualReprestMont)
    from @Tabla
    group by Zona, Regional, NomOficina, CodOficina
    order by Zona, NomOficina

if @Tipo = 'S'
    select Zona = '', Regional = '', NomOficina, Asesor, CodOficina, CodAsesor, Semana = @Semana,
              DiaNuevosCant = sum(   DiaNuevosCant),    DiaNuevosMonto = sum(   DiaNuevosMonto),    DiaReprestCant = sum(   DiaReprestCant),    DiaReprestMont = sum(   DiaReprestMont),
           SemanaNuevosCant = sum(SemanaNuevosCant), SemanaNuevosMonto = sum(SemanaNuevosMonto), SemanaReprestCant = sum(SemanaReprestCant), SemanaReprestMont = sum(SemanaReprestMont),
              MesNuevosCant = sum(   MesNuevosCant),    MesNuevosMonto = sum(   MesNuevosMonto),    MesReprestCant = sum(   MesReprestCant),    MesReprestMont = sum(   MesReprestMont),
            AnualNuevosCant = sum( AnualNuevosCant),  AnualNuevosMonto = sum( AnualNuevosMonto),  AnualReprestCant = sum( AnualReprestCant),  AnualReprestMont = sum( AnualReprestMont)
    from @Tabla
    group by NomOficina, Asesor, CodOficina, CodAsesor
    order by NomOficina, Asesor

if @Tipo = 'P'
    select Zona = '', Regional = '', NomOficina= '', Asesor, CodOficina= '', CodAsesor, Semana = @Semana,
              DiaNuevosCant = sum(   DiaNuevosCant),    DiaNuevosMonto = sum(   DiaNuevosMonto),    DiaReprestCant = sum(   DiaReprestCant),    DiaReprestMont = sum(   DiaReprestMont),
           SemanaNuevosCant = sum(SemanaNuevosCant), SemanaNuevosMonto = sum(SemanaNuevosMonto), SemanaReprestCant = sum(SemanaReprestCant), SemanaReprestMont = sum(SemanaReprestMont),
              MesNuevosCant = sum(   MesNuevosCant),    MesNuevosMonto = sum(   MesNuevosMonto),    MesReprestCant = sum(   MesReprestCant),    MesReprestMont = sum(   MesReprestMont),
            AnualNuevosCant = sum( AnualNuevosCant),  AnualNuevosMonto = sum( AnualNuevosMonto),  AnualReprestCant = sum( AnualReprestCant),  AnualReprestMont = sum( AnualReprestMont)
    from @Tabla
    group by Asesor, CodAsesor
    order by NomOficina, Asesor
GO