SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pRptCoGastosEIngresosPorSemana] (
    @Fecha    SmallDateTime,
    @CodRegional varchar(4)  = '0',
    @CodOficina  varchar(4)  = '0',
    @Tipo        char(1)     = 'R'    -- G=Gerente, R=Lider Regional, S=Lider Sucursal
)
As
set nocount on

--declare @Fecha datetime
--declare @Tipo char(1) -- R=Lider Regional, S=Lider Sucursal
--declare @CodRegional varchar(4)
--declare @CodOficina  varchar(4)

--set @Fecha = '20150527'
--set @Tipo = 'S'
--set @CodRegional = 'z01'
--set @CodOficina  = '5'


declare @Mes tinyint
set @Mes = month(@Fecha)

declare @Semana tinyint
set @Semana = datepart(wk, DATEADD(mm, DATEDIFF(mm, 0, @Fecha), 0))

declare @Maestro table (
    Mes    tinyint, --char(6),
    Semana tinyint,
    CodOficina varchar(5),
    CodCta char(2),
    --Debe   money,
    --Haber  money,
    Saldo  money
)

insert into @Maestro
SELECT Mes = month(T.FechCbte), 
       Semana = datepart(wk, T.FechCbte),
       D.CodOficina,
       CodCta = substring(D.codcta, 1, 2),
       --Debe  = sum(D.debe),
       --Haber = sum(D.haber),
       Saldo = round(sum(D.haber) - sum(D.debe), 0)
FROM [10.0.1.15].Finamigo_Conta_PRO.dbo.tCoTraDia T
inner join [10.0.1.15].Finamigo_Conta_PRO.dbo.tCoTraDiadetalle D on T.codregistro = D.codregistro
where T.EsAnulado = 0
and   (D.CodCta like '61%' or D.CodCta like '62%' or D.CodCta like '65%' or D.CodCta like '66%')
and T.FechCbte <= @Fecha
Group By  month(T.FechCbte), datepart(wk, T.FechCbte), /*T.FechCbte,*/ D.CodOficina, substring(D.codcta, 1, 2)

--------------------------------------------------------------------------------------------------------------
declare @Columnas table (
    CodCta char(2),
    CodOficina varchar(5),
    S1  money,
    S2  money,
    S3  money,
    S4  money,
    S5  money,
    M01 money,
    M02 money,
    M03 money,
    M04 money,
    M05 money,
    M06 money,
    M07 money,
    M08 money,
    M09 money,
    M10 money,
    M11 money,
    M12 money,
    Total money
)

insert into @Columnas
select A.CodCta, A.CodOficina,
       S1 = S1.Saldo, S2 = S2.Saldo, S3 = S3.Saldo, S4 = S4.Saldo, S5 = S5.Saldo,
       M01 = M01.Saldo, M02 = M02.Saldo, M03 = M03.Saldo, M04 = M04.Saldo, M05 = M05.Saldo, M06 = M06.Saldo,
       M07 = M07.Saldo, M08 = M08.Saldo, M09 = M09.Saldo, M10 = M10.Saldo, M11 = M11.Saldo, M12 = M12.Saldo,
       Total = isnull(M01.Saldo, 0) + isnull(M02.Saldo, 0) + isnull(M03.Saldo, 0) + isnull(M04.Saldo, 0) + isnull(M05.Saldo, 0) + isnull(M06.Saldo, 0) + isnull(M07.Saldo, 0) + isnull(M08.Saldo, 0) + isnull(M09.Saldo, 0) + isnull(M10.Saldo, 0) + isnull(M11.Saldo, 0) + isnull(M12.Saldo, 0)
from (
    select distinct CodCta, CodOficina from @Maestro
) A
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 1 group by CodCta, CodOficina
) M01 on A.CodCta = M01.CodCta and A.CodOficina = M01.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 2 group by CodCta, CodOficina
) M02 on A.CodCta = M02.CodCta and A.CodOficina = M02.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 3 group by CodCta, CodOficina
) M03 on A.CodCta = M03.CodCta and A.CodOficina = M03.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 4 group by CodCta, CodOficina
) M04 on A.CodCta = M04.CodCta and A.CodOficina = M04.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 5 group by CodCta, CodOficina
) M05 on A.CodCta = M05.CodCta and A.CodOficina = M05.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 6 group by CodCta, CodOficina
) M06 on A.CodCta = M06.CodCta and A.CodOficina = M06.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 7 group by CodCta, CodOficina
) M07 on A.CodCta = M07.CodCta and A.CodOficina = M07.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 8 group by CodCta, CodOficina
) M08 on A.CodCta = M08.CodCta and A.CodOficina = M08.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 9 group by CodCta, CodOficina
) M09 on A.CodCta = M09.CodCta and A.CodOficina = M09.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 9 group by CodCta, CodOficina
) M10 on A.CodCta = M10.CodCta and A.CodOficina = M10.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 9 group by CodCta, CodOficina
) M11 on A.CodCta = M11.CodCta and A.CodOficina = M11.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = 9 group by CodCta, CodOficina
) M12 on A.CodCta = M12.CodCta and A.CodOficina = M12.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = @Mes and Semana = @Semana group by CodCta, CodOficina
) S1 on A.CodCta = S1.CodCta and A.CodOficina = S1.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = @Mes and Semana = @Semana+1 group by CodCta, CodOficina
) S2 on A.CodCta = S2.CodCta and A.CodOficina = S2.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = @Mes and Semana = @Semana+2 group by CodCta, CodOficina
) S3 on A.CodCta = S3.CodCta and A.CodOficina = S3.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = @Mes and Semana = @Semana+3 group by CodCta, CodOficina
) S4 on A.CodCta = S4.CodCta and A.CodOficina = S4.CodOficina
left join ( 
    select CodCta, CodOficina, Saldo = sum(Saldo) from @Maestro where Mes = @Mes and Semana = @Semana+4 group by CodCta, CodOficina
) S5 on A.CodCta = S5.CodCta and A.CodOficina = S5.CodOficina
order by 1, 2, 3

if @Tipo = 'G'
    select Cuenta = dbo.Proper(C.DescCta), Regional = Z.Nombre, Sucursal = '',
           S1 = sum(S1), S2 = sum(S2), S3 = sum(S3), S4 = sum(S4), S5 = sum(S5),
           M01 = sum(M01), M02 = sum(M02), M03 = sum(M03), M04 = sum(M04), M05 = sum(M05), M06 = sum(M06),
           M07 = sum(M07), M08 = sum(M08), M09 = sum(M09), M10 = sum(M10), M11 = sum(M11), M12 = sum(M12), Total = sum(Total)
    from @Columnas A
    inner join [10.0.1.15].Finamigo_Conta_PRO.dbo.tCoCuentas C on C.codcta = A.codcta
    inner join tcloficinas O on A.codoficina = O.codoficina
    inner join tclzona Z on Z.zona = O.zona
    group by C.DescCta, Z.Nombre
    order by Cuenta, Regional

if @Tipo = 'R'
    select Cuenta = dbo.Proper(C.DescCta), Regional = Z.Nombre, Sucursal = dbo.Proper(O.NomOficina),
           S1, S2, S3, S4, S5, M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, Total
    from @Columnas A
    inner join [10.0.1.15].Finamigo_Conta_PRO.dbo.tCoCuentas C on C.codcta = A.codcta
    inner join tcloficinas O on A.codoficina = O.codoficina
    inner join tclzona Z on Z.zona = O.zona
    where @CodRegional = '0' or (@CodRegional <> '0' and O.Zona = @CodRegional)
    order by Cuenta, Regional

if @Tipo = 'S'
    select Cuenta = dbo.Proper(C.DescCta), Regional = Z.Nombre, Sucursal = dbo.Proper(O.NomOficina),
           S1, S2, S3, S4, S5, M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, Total
    from @Columnas A
    inner join [10.0.1.15].Finamigo_Conta_PRO.dbo.tCoCuentas C on C.codcta = A.codcta
    inner join tcloficinas O on A.codoficina = O.codoficina
    inner join tclzona Z on Z.zona = O.zona
    where @CodOficina  = '0' or (@CodOficina  <> '0' and O.CodOficina = @CodOficina)
    order by Cuenta, Regional
GO