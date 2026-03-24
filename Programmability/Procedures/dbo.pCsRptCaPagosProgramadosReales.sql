SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsRptCaPagosProgramadosReales] (
    @Fecha    SmallDateTime,
    @CodRegional varchar(4)  = '0',
    @CodOficina  varchar(4)  = '0',
    @CodAsesor   varchar(15) = '0',
    @Tipo        char(1)     = 'G'    -- G=Gerente, R=Lider Regional, S=Lider Sucursal, P=Promotor
)
As
set nocount on

--declare @Fecha datetime
--set @Fecha = '20150608'
--set @CodRegional = 'Z01'
--set @CodOficina = '5'
--set @CodAsesor = '5ODE0104912'

declare @MesInicio datetime
declare @MesFinal  datetime
set @MesInicio  = DATEADD(mm, DATEDIFF(mm, 0, @Fecha), 0)
set @MesFinal   = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @Fecha) + 1, 0))

declare @Base table (
    Fecha datetime,
    CodOficina varchar(4), 
    CodAsesor varchar(15),
    MontoDevengado money, 
    MontoPagado    money
)

insert into @Base
select C.Fechavencimiento, C.CodOficina, C.CodAsesor, MontoDevengado = sum(C.MontoDevengado), MontoPagado = sum(G.MontoPagado)
from (
    select C.Fechavencimiento, C.CodOficina, P.CodAsesor, P.CodPrestamo, MontoDevengado = sum(C.MontoDevengado)
    from tCsPadronPlanCuotas C
    inner join tCsPrestamos P on C.CodPrestamo = P.CodPrestamo
    where C.Fechavencimiento between @MesInicio and @MesFinal
    group by C.Fechavencimiento, C.CodOficina, P.CodAsesor, P.CodPrestamo
) C
left join (
    select Fecha, CodPrestamo, MontoPagado = sum(MontoPagado)
    from tCsPagoDet
    where Fecha between @MesInicio and @MesFinal
    group by Fecha, CodPrestamo
) G on C.Fechavencimiento = G.Fecha and C.CodPrestamo = G.CodPrestamo
group by C.Fechavencimiento, C.CodOficina, C.CodAsesor
--order by 1, 2, 3

declare @Resul table (
    Zona varchar(10),
    Regional varchar(100),
    NomOficina varchar(100),
    Asesor varchar(100),
    CodOficina varchar(4), 
    CodAsesor varchar(15),
    D01Deve money, 
    D01Pago money,
    D02Deve money, 
    D02Pago money,
    D03Deve money, 
    D03Pago money,
    D04Deve money, 
    D04Pago money,
    D05Deve money, 
    D05Pago money,
    D06Deve money, 
    D06Pago money,
    D07Deve money, 
    D07Pago money,
    D08Deve money, 
    D08Pago money,
    D09Deve money, 
    D09Pago money,
    D10Deve money, 
    D10Pago money,
    D11Deve money, 
    D11Pago money,
    D12Deve money, 
    D12Pago money,
    D13Deve money, 
    D13Pago money,
    D14Deve money, 
    D14Pago money,
    D15Deve money, 
    D15Pago money,
    D16Deve money, 
    D16Pago money,
    D17Deve money, 
    D17Pago money,
    D18Deve money, 
    D18Pago money,
    D19Deve money, 
    D19Pago money,
    D20Deve money, 
    D20Pago money,
    D21Deve money, 
    D21Pago money,
    D22Deve money, 
    D22Pago money,
    D23Deve money, 
    D23Pago money,
    D24Deve money, 
    D24Pago money,
    D25Deve money, 
    D25Pago money,
    D26Deve money, 
    D26Pago money,
    D27Deve money, 
    D27Pago money,
    D28Deve money, 
    D28Pago money,
    D29Deve money, 
    D29Pago money,
    D30Deve money, 
    D30Pago money,
    D31Deve money, 
    D31Pago money
)

insert into @Resul
select Z.Zona, Regional = Z.Zona + ' - ' + Z.Nombre, O.NomOficina, Asesor = dbo.proper(U.nombreCompleto), R.*
from (
    select A.CodOficina, A.CodAsesor, 
           D01.D01Deve, D01.D01Pago, D02.D02Deve, D02.D02Pago, D03.D03Deve, D03.D03Pago, D04.D04Deve, D04.D04Pago, D05.D05Deve, D05.D05Pago,
           D06.D06Deve, D06.D06Pago, D07.D07Deve, D07.D07Pago, D08.D08Deve, D08.D08Pago, D09.D09Deve, D09.D09Pago, D10.D10Deve, D10.D10Pago,
           D11.D11Deve, D11.D11Pago, D12.D12Deve, D12.D12Pago, D13.D13Deve, D13.D13Pago, D14.D14Deve, D14.D14Pago, D15.D15Deve, D15.D15Pago,
           D16.D16Deve, D16.D16Pago, D17.D17Deve, D17.D17Pago, D18.D18Deve, D18.D18Pago, D19.D19Deve, D19.D19Pago, D20.D20Deve, D20.D20Pago,
           D21.D21Deve, D21.D21Pago, D22.D22Deve, D22.D22Pago, D23.D23Deve, D23.D23Pago, D24.D24Deve, D24.D24Pago, D25.D25Deve, D25.D25Pago,
           D26.D26Deve, D26.D26Pago, D27.D27Deve, D27.D27Pago, D28.D28Deve, D28.D28Pago, D29.D29Deve, D29.D29Pago, D30.D30Deve, D30.D30Pago, 
           D31.D31Deve, D31.D31Pago
    from (
        select distinct CodOficina, CodAsesor from @Base
    ) A
    left join (
        select CodOficina, CodAsesor, D01Deve = MontoDevengado, D01Pago = MontoPagado
        from @Base where day(Fecha) = 1
    ) D01 on A.CodOficina = D01.CodOficina and A.CodAsesor = D01.CodAsesor
    left join (
        select CodOficina, CodAsesor, D02Deve = MontoDevengado, D02Pago = MontoPagado
        from @Base where day(Fecha) = 2
    ) D02 on A.CodOficina = D02.CodOficina and A.CodAsesor = D02.CodAsesor
    left join (
        select CodOficina, CodAsesor, D03Deve = MontoDevengado, D03Pago = MontoPagado
        from @Base where day(Fecha) = 3
    ) D03 on A.CodOficina = D03.CodOficina and A.CodAsesor = D03.CodAsesor
    left join (
        select CodOficina, CodAsesor, D04Deve = MontoDevengado, D04Pago = MontoPagado
        from @Base where day(Fecha) = 4
    ) D04 on A.CodOficina = D04.CodOficina and A.CodAsesor = D04.CodAsesor
    left join (
        select CodOficina, CodAsesor, D05Deve = MontoDevengado, D05Pago = MontoPagado
        from @Base where day(Fecha) = 5
    ) D05 on A.CodOficina = D05.CodOficina and A.CodAsesor = D05.CodAsesor
    left join (
        select CodOficina, CodAsesor, D06Deve = MontoDevengado, D06Pago = MontoPagado
        from @Base where day(Fecha) = 6
    ) D06 on A.CodOficina = D06.CodOficina and A.CodAsesor = D06.CodAsesor
    left join (
        select CodOficina, CodAsesor, D07Deve = MontoDevengado, D07Pago = MontoPagado
        from @Base where day(Fecha) = 7
    ) D07 on A.CodOficina = D07.CodOficina and A.CodAsesor = D07.CodAsesor
    left join (
        select CodOficina, CodAsesor, D08Deve = MontoDevengado, D08Pago = MontoPagado
        from @Base where day(Fecha) = 8
    ) D08 on A.CodOficina = D08.CodOficina and A.CodAsesor = D08.CodAsesor
    left join (
        select CodOficina, CodAsesor, D09Deve = MontoDevengado, D09Pago = MontoPagado
        from @Base where day(Fecha) = 9
    ) D09 on A.CodOficina = D09.CodOficina and A.CodAsesor = D09.CodAsesor
    left join (
        select CodOficina, CodAsesor, D10Deve = MontoDevengado, D10Pago = MontoPagado
        from @Base where day(Fecha) = 10
    ) D10 on A.CodOficina = D10.CodOficina and A.CodAsesor = D10.CodAsesor

    --- 11 - 20
    left join (
        select CodOficina, CodAsesor, D11Deve = MontoDevengado, D11Pago = MontoPagado
        from @Base where day(Fecha) = 11
    ) D11 on A.CodOficina = D11.CodOficina and A.CodAsesor = D11.CodAsesor
    left join (
        select CodOficina, CodAsesor, D12Deve = MontoDevengado, D12Pago = MontoPagado
        from @Base where day(Fecha) = 12
    ) D12 on A.CodOficina = D12.CodOficina and A.CodAsesor = D12.CodAsesor
    left join (
        select CodOficina, CodAsesor, D13Deve = MontoDevengado, D13Pago = MontoPagado
        from @Base where day(Fecha) = 13
    ) D13 on A.CodOficina = D13.CodOficina and A.CodAsesor = D13.CodAsesor
    left join (
        select CodOficina, CodAsesor, D14Deve = MontoDevengado, D14Pago = MontoPagado
        from @Base where day(Fecha) = 14
    ) D14 on A.CodOficina = D14.CodOficina and A.CodAsesor = D14.CodAsesor
    left join (
        select CodOficina, CodAsesor, D15Deve = MontoDevengado, D15Pago = MontoPagado
        from @Base where day(Fecha) = 15
    ) D15 on A.CodOficina = D15.CodOficina and A.CodAsesor = D15.CodAsesor
    left join (
        select CodOficina, CodAsesor, D16Deve = MontoDevengado, D16Pago = MontoPagado
        from @Base where day(Fecha) = 16
    ) D16 on A.CodOficina = D16.CodOficina and A.CodAsesor = D16.CodAsesor
    left join (
        select CodOficina, CodAsesor, D17Deve = MontoDevengado, D17Pago = MontoPagado
        from @Base where day(Fecha) = 17
    ) D17 on A.CodOficina = D17.CodOficina and A.CodAsesor = D17.CodAsesor
    left join (
        select CodOficina, CodAsesor, D18Deve = MontoDevengado, D18Pago = MontoPagado
        from @Base where day(Fecha) = 18
    ) D18 on A.CodOficina = D18.CodOficina and A.CodAsesor = D18.CodAsesor
    left join (
        select CodOficina, CodAsesor, D19Deve = MontoDevengado, D19Pago = MontoPagado
        from @Base where day(Fecha) = 19
    ) D19 on A.CodOficina = D19.CodOficina and A.CodAsesor = D19.CodAsesor
    left join (
        select CodOficina, CodAsesor, D20Deve = MontoDevengado, D20Pago = MontoPagado
        from @Base where day(Fecha) = 20
    ) D20 on A.CodOficina = D20.CodOficina and A.CodAsesor = D20.CodAsesor

    --- 21 - 30
    left join (
        select CodOficina, CodAsesor, D21Deve = MontoDevengado, D21Pago = MontoPagado
        from @Base where day(Fecha) = 21
    ) D21 on A.CodOficina = D21.CodOficina and A.CodAsesor = D21.CodAsesor
    left join (
        select CodOficina, CodAsesor, D22Deve = MontoDevengado, D22Pago = MontoPagado
        from @Base where day(Fecha) = 22
    ) D22 on A.CodOficina = D22.CodOficina and A.CodAsesor = D22.CodAsesor
    left join (
        select CodOficina, CodAsesor, D23Deve = MontoDevengado, D23Pago = MontoPagado
        from @Base where day(Fecha) = 23
    ) D23 on A.CodOficina = D23.CodOficina and A.CodAsesor = D23.CodAsesor
    left join (
        select CodOficina, CodAsesor, D24Deve = MontoDevengado, D24Pago = MontoPagado
        from @Base where day(Fecha) = 24
    ) D24 on A.CodOficina = D24.CodOficina and A.CodAsesor = D24.CodAsesor
    left join (
        select CodOficina, CodAsesor, D25Deve = MontoDevengado, D25Pago = MontoPagado
        from @Base where day(Fecha) = 25
    ) D25 on A.CodOficina = D25.CodOficina and A.CodAsesor = D25.CodAsesor
    left join (
        select CodOficina, CodAsesor, D26Deve = MontoDevengado, D26Pago = MontoPagado
        from @Base where day(Fecha) = 26
    ) D26 on A.CodOficina = D26.CodOficina and A.CodAsesor = D26.CodAsesor
    left join (
        select CodOficina, CodAsesor, D27Deve = MontoDevengado, D27Pago = MontoPagado
        from @Base where day(Fecha) = 27
    ) D27 on A.CodOficina = D27.CodOficina and A.CodAsesor = D27.CodAsesor
    left join (
        select CodOficina, CodAsesor, D28Deve = MontoDevengado, D28Pago = MontoPagado
        from @Base where day(Fecha) = 28
    ) D28 on A.CodOficina = D28.CodOficina and A.CodAsesor = D28.CodAsesor
    left join (
        select CodOficina, CodAsesor, D29Deve = MontoDevengado, D29Pago = MontoPagado
        from @Base where day(Fecha) = 29
    ) D29 on A.CodOficina = D29.CodOficina and A.CodAsesor = D29.CodAsesor
    left join (
        select CodOficina, CodAsesor, D30Deve = MontoDevengado, D30Pago = MontoPagado
        from @Base where day(Fecha) = 30
    ) D30 on A.CodOficina = D30.CodOficina and A.CodAsesor = D30.CodAsesor
    left join (
        select CodOficina, CodAsesor, D31Deve = MontoDevengado, D31Pago = MontoPagado
        from @Base where day(Fecha) = 31
    ) D31 on A.CodOficina = D31.CodOficina and A.CodAsesor = D31.CodAsesor
) R
inner join tcloficinas O on R.codoficina = O.codoficina
inner join tClZona Z on O.ZOna = Z.Zona
inner join tCsPadronClientes U on R.CodAsesor = U.CodOrigen
where (@CodRegional = '0' or (@CodRegional <> '0' and O.Zona       = @CodRegional))
and   (@CodOficina  = '0' or (@CodOficina  <> '0' and O.CodOficina = @CodOficina)) 
and   (@CodAsesor   = '0' or (@CodAsesor   <> '0' and U.CodOrigen  = @CodAsesor))

if @Tipo = 'G'
    select Zona, Regional, NomOficina, Asesor = '', CodOficina, CodAsesor = '',
           D01Deve = sum(D01Deve), D01Pago = sum(D01Pago), D02Deve = sum(D02Deve), D02Pago = sum(D02Pago),
           D03Deve = sum(D03Deve), D03Pago = sum(D03Pago), D04Deve = sum(D04Deve), D04Pago = sum(D04Pago),
           D05Deve = sum(D05Deve), D05Pago = sum(D05Pago), D06Deve = sum(D06Deve), D06Pago = sum(D06Pago),
           D07Deve = sum(D07Deve), D07Pago = sum(D07Pago), D08Deve = sum(D08Deve), D08Pago = sum(D08Pago),
           D09Deve = sum(D09Deve), D09Pago = sum(D09Pago), D10Deve = sum(D10Deve), D10Pago = sum(D10Pago),
           D11Deve = sum(D11Deve), D11Pago = sum(D11Pago), D12Deve = sum(D12Deve), D12Pago = sum(D12Pago),
           D13Deve = sum(D13Deve), D13Pago = sum(D13Pago), D14Deve = sum(D14Deve), D14Pago = sum(D14Pago),
           D15Deve = sum(D15Deve), D15Pago = sum(D15Pago), D16Deve = sum(D16Deve), D16Pago = sum(D16Pago),
           D17Deve = sum(D17Deve), D17Pago = sum(D17Pago), D18Deve = sum(D18Deve), D18Pago = sum(D18Pago),
           D19Deve = sum(D19Deve), D19Pago = sum(D19Pago), D20Deve = sum(D20Deve), D20Pago = sum(D20Pago),
           D21Deve = sum(D21Deve), D21Pago = sum(D21Pago), D22Deve = sum(D22Deve), D22Pago = sum(D22Pago),
           D23Deve = sum(D23Deve), D23Pago = sum(D23Pago), D24Deve = sum(D24Deve), D24Pago = sum(D24Pago),
           D25Deve = sum(D25Deve), D25Pago = sum(D25Pago), D26Deve = sum(D26Deve), D26Pago = sum(D26Pago),
           D27Deve = sum(D27Deve), D27Pago = sum(D27Pago), D28Deve = sum(D28Deve), D28Pago = sum(D28Pago),
           D29Deve = sum(D29Deve), D29Pago = sum(D29Pago), D30Deve = sum(D30Deve), D30Pago = sum(D30Pago),
           D31Deve = sum(D31Deve), D31Pago = sum(D31Pago)
    from @Resul
    group by Zona, Regional, NomOficina, CodOficina
    order by Zona, NomOficina

if @Tipo = 'R'
    select Zona, Regional, NomOficina, Asesor = '', CodOficina, CodAsesor = '',
           D01Deve = sum(D01Deve), D01Pago = sum(D01Pago), D02Deve = sum(D02Deve), D02Pago = sum(D02Pago),
           D03Deve = sum(D03Deve), D03Pago = sum(D03Pago), D04Deve = sum(D04Deve), D04Pago = sum(D04Pago),
           D05Deve = sum(D05Deve), D05Pago = sum(D05Pago), D06Deve = sum(D06Deve), D06Pago = sum(D06Pago),
           D07Deve = sum(D07Deve), D07Pago = sum(D07Pago), D08Deve = sum(D08Deve), D08Pago = sum(D08Pago),
           D09Deve = sum(D09Deve), D09Pago = sum(D09Pago), D10Deve = sum(D10Deve), D10Pago = sum(D10Pago),
           D11Deve = sum(D11Deve), D11Pago = sum(D11Pago), D12Deve = sum(D12Deve), D12Pago = sum(D12Pago),
           D13Deve = sum(D13Deve), D13Pago = sum(D13Pago), D14Deve = sum(D14Deve), D14Pago = sum(D14Pago),
           D15Deve = sum(D15Deve), D15Pago = sum(D15Pago), D16Deve = sum(D16Deve), D16Pago = sum(D16Pago),
           D17Deve = sum(D17Deve), D17Pago = sum(D17Pago), D18Deve = sum(D18Deve), D18Pago = sum(D18Pago),
           D19Deve = sum(D19Deve), D19Pago = sum(D19Pago), D20Deve = sum(D20Deve), D20Pago = sum(D20Pago),
           D21Deve = sum(D21Deve), D21Pago = sum(D21Pago), D22Deve = sum(D22Deve), D22Pago = sum(D22Pago),
           D23Deve = sum(D23Deve), D23Pago = sum(D23Pago), D24Deve = sum(D24Deve), D24Pago = sum(D24Pago),
           D25Deve = sum(D25Deve), D25Pago = sum(D25Pago), D26Deve = sum(D26Deve), D26Pago = sum(D26Pago),
           D27Deve = sum(D27Deve), D27Pago = sum(D27Pago), D28Deve = sum(D28Deve), D28Pago = sum(D28Pago),
           D29Deve = sum(D29Deve), D29Pago = sum(D29Pago), D30Deve = sum(D30Deve), D30Pago = sum(D30Pago),
           D31Deve = sum(D31Deve), D31Pago = sum(D31Pago)
    from @Resul
    group by Zona, Regional, NomOficina, CodOficina
    order by Zona, NomOficina

if @Tipo = 'S'
    select Zona = '', Regional = '', NomOficina, Asesor, CodOficina, CodAsesor,
           D01Deve = sum(D01Deve), D01Pago = sum(D01Pago), D02Deve = sum(D02Deve), D02Pago = sum(D02Pago),
           D03Deve = sum(D03Deve), D03Pago = sum(D03Pago), D04Deve = sum(D04Deve), D04Pago = sum(D04Pago),
           D05Deve = sum(D05Deve), D05Pago = sum(D05Pago), D06Deve = sum(D06Deve), D06Pago = sum(D06Pago),
           D07Deve = sum(D07Deve), D07Pago = sum(D07Pago), D08Deve = sum(D08Deve), D08Pago = sum(D08Pago),
           D09Deve = sum(D09Deve), D09Pago = sum(D09Pago), D10Deve = sum(D10Deve), D10Pago = sum(D10Pago),
           D11Deve = sum(D11Deve), D11Pago = sum(D11Pago), D12Deve = sum(D12Deve), D12Pago = sum(D12Pago),
           D13Deve = sum(D13Deve), D13Pago = sum(D13Pago), D14Deve = sum(D14Deve), D14Pago = sum(D14Pago),
           D15Deve = sum(D15Deve), D15Pago = sum(D15Pago), D16Deve = sum(D16Deve), D16Pago = sum(D16Pago),
           D17Deve = sum(D17Deve), D17Pago = sum(D17Pago), D18Deve = sum(D18Deve), D18Pago = sum(D18Pago),
           D19Deve = sum(D19Deve), D19Pago = sum(D19Pago), D20Deve = sum(D20Deve), D20Pago = sum(D20Pago),
           D21Deve = sum(D21Deve), D21Pago = sum(D21Pago), D22Deve = sum(D22Deve), D22Pago = sum(D22Pago),
           D23Deve = sum(D23Deve), D23Pago = sum(D23Pago), D24Deve = sum(D24Deve), D24Pago = sum(D24Pago),
           D25Deve = sum(D25Deve), D25Pago = sum(D25Pago), D26Deve = sum(D26Deve), D26Pago = sum(D26Pago),
           D27Deve = sum(D27Deve), D27Pago = sum(D27Pago), D28Deve = sum(D28Deve), D28Pago = sum(D28Pago),
           D29Deve = sum(D29Deve), D29Pago = sum(D29Pago), D30Deve = sum(D30Deve), D30Pago = sum(D30Pago),
           D31Deve = sum(D31Deve), D31Pago = sum(D31Pago)
    from @Resul
    group by NomOficina, Asesor, CodOficina, CodAsesor
    order by NomOficina, Asesor

if @Tipo = 'P'
    select Zona = '', Regional = '', NomOficina= '', Asesor, CodOficina= '', CodAsesor, 
           D01Deve = sum(D01Deve), D01Pago = sum(D01Pago), D02Deve = sum(D02Deve), D02Pago = sum(D02Pago),
           D03Deve = sum(D03Deve), D03Pago = sum(D03Pago), D04Deve = sum(D04Deve), D04Pago = sum(D04Pago),
           D05Deve = sum(D05Deve), D05Pago = sum(D05Pago), D06Deve = sum(D06Deve), D06Pago = sum(D06Pago),
           D07Deve = sum(D07Deve), D07Pago = sum(D07Pago), D08Deve = sum(D08Deve), D08Pago = sum(D08Pago),
           D09Deve = sum(D09Deve), D09Pago = sum(D09Pago), D10Deve = sum(D10Deve), D10Pago = sum(D10Pago),
           D11Deve = sum(D11Deve), D11Pago = sum(D11Pago), D12Deve = sum(D12Deve), D12Pago = sum(D12Pago),
           D13Deve = sum(D13Deve), D13Pago = sum(D13Pago), D14Deve = sum(D14Deve), D14Pago = sum(D14Pago),
           D15Deve = sum(D15Deve), D15Pago = sum(D15Pago), D16Deve = sum(D16Deve), D16Pago = sum(D16Pago),
           D17Deve = sum(D17Deve), D17Pago = sum(D17Pago), D18Deve = sum(D18Deve), D18Pago = sum(D18Pago),
           D19Deve = sum(D19Deve), D19Pago = sum(D19Pago), D20Deve = sum(D20Deve), D20Pago = sum(D20Pago),
           D21Deve = sum(D21Deve), D21Pago = sum(D21Pago), D22Deve = sum(D22Deve), D22Pago = sum(D22Pago),
           D23Deve = sum(D23Deve), D23Pago = sum(D23Pago), D24Deve = sum(D24Deve), D24Pago = sum(D24Pago),
           D25Deve = sum(D25Deve), D25Pago = sum(D25Pago), D26Deve = sum(D26Deve), D26Pago = sum(D26Pago),
           D27Deve = sum(D27Deve), D27Pago = sum(D27Pago), D28Deve = sum(D28Deve), D28Pago = sum(D28Pago),
           D29Deve = sum(D29Deve), D29Pago = sum(D29Pago), D30Deve = sum(D30Deve), D30Pago = sum(D30Pago),
           D31Deve = sum(D31Deve), D31Pago = sum(D31Pago)
    from @Resul
    group by Asesor, CodAsesor
    order by NomOficina, Asesor
    
GO