SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pAhGruposFamiliares] (
    @Fecha datetime
)
As
-- Noel - 2015 05 19
-- Kris - 2015 05 26 - se agrego un grupo y se mejoro el tiempo de respuesta
--declare  @Fecha datetime
--set @Fecha='20150525'

set nocount on

declare @tAhGruposFamiliares table (
	idgrupofamiliar int,
	nombregrupo varchar(200)
)
insert into @tAhGruposFamiliares
select * from [10.0.2.14].Finmas.dbo.tAhGruposFamiliares

declare @tAhGruposFamiliaresDetalle table (
	idgrupofamiliar int,
	codusuario varchar(15)
)
insert into @tAhGruposFamiliaresDetalle
select * from [10.0.2.14].Finmas.dbo.tAhGruposFamiliaresDetalle

declare @tAhCuenta table(
	CodCuenta varchar(25),
	FraccionCta varchar(8),
	Renovado tinyint,
	ReferidoPor varchar(80)
)
insert into @tAhCuenta
select CodCuenta,FraccionCta,Renovado,ReferidoPor from [10.0.2.14].Finmas.dbo.tAhCuenta where ReferidoPor is not null and ReferidoPor<>'' and idProducto like '2%'

select case when pa.codoficina='98' then 'OCSS' else 'SUCURSALES' end grupo
,isnull(GF.NombreGrupo,'Sin Grupo') NombreGrupo, NombreCompleto = dbo.proper(replace(PC.NombreCompleto, 'Ñ', 'ñ')), PA.FecApertura, A.FechaVencimiento, A.TasaInteres, A.SaldoCuenta
,Accionista = case PC.UsEsAccionista when 1 then 'SI' else 'NO' end, C.ReferidoPor, PA.CodCuenta + '-' + PA.FraccionCta + '-' + cast(PA.Renovado as varchar(2)) CodCuenta
, PA.FraccionCta, PA.Renovado, A.Plazo,  A.IntAcumulado InteresDevengado --A.InteresCalculado
,case when a.idtiporenova=1 then 'Manual' else 'Automatica' end tiporenovacion
from tCsPadronAhorros PA with(nolock)
inner join tCsPadronClientes PC with(nolock) on PA.CodUsuario = PC.CodUsuario
inner join tCsAhorros A with(nolock) on PA.CodCuenta = A.CodCuenta and PA.FraccionCta = A.FraccionCta and PA.Renovado = A.Renovado
--inner  join [10.0.2.14].Finmas.dbo.tAhCuenta C on PA.CodCuenta = C.CodCuenta and PA.FraccionCta = C.FraccionCta and PA.Renovado = C.Renovado
--left  join [10.0.2.14].Finmas.dbo.tAhGruposFamiliaresDetalle GFD on PC.CodOrigen = GFD.CodUsuario
--left  join [10.0.2.14].Finmas.dbo.tAhGruposFamiliares GF on GFD.IdGrupoFamiliar  = GF.IdGrupoFamiliar
left join @tAhCuenta C on PA.CodCuenta = C.CodCuenta and PA.FraccionCta = C.FraccionCta and PA.Renovado = C.Renovado
left  join @tAhGruposFamiliaresDetalle GFD on PC.CodOrigen = GFD.CodUsuario
left  join @tAhGruposFamiliares GF on GFD.IdGrupoFamiliar  = GF.IdGrupoFamiliar
where PA.CodProducto like '2%'
and   A.Fecha = @Fecha
order by NombreGrupo, NombreCompleto
--488
--39seg
--22seg con inner
--13seg con tabla variable en grupos familiares
--2seg con tabla variable en grupos familiares y tahcuenta

/*select * from tcspadronahorros
select top 1000 * from tcsahorros

*/
GO