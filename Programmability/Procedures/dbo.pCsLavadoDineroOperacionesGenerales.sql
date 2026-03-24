SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsLavadoDineroOperacionesGenerales] (@FechaIni smalldatetime, @FechaFin smalldatetime, @MontoPeriodo Money, @PersonaFisica bit, @Sistema varchar(2))
AS
BEGIN
--comentar
/*
declare @FechaIni smalldatetime
declare @FechaFin smalldatetime 
declare @MontoPeriodo Money
declare @PersonaFisica bit
declare @Sistema varchar(2)

set @FechaIni = '20180101'
set @FechaFin = '20180131'
set @MontoPeriodo = 10000
set @PersonaFisica = 1
set @Sistema = ''
*/
	select x.codusuario, x.nombrecompleto, x.MontoTotalPeriodo  
	from 
	(
		select   
		td.codusuario,
		u.nombrecompleto,
		sum(td.MontoTotalTran) as MontoTotalPeriodo
		from tcstransacciondiaria  as td WITH (NOLOCK)
		inner join tcloficinas as o WITH (NOLOCK) on o.codoficina = td.codoficina
		inner join tCsPadronClientes as u WITH (NOLOCK) on u.codusuario = td.codusuario 
		where 
		1=1
		--and CodSistema in ('CA', 'AH') --('AH','CA')
		and ((CodSistema in ('AH') and @Sistema = 'AH') or
            (CodSistema in ('CA') and @Sistema = 'CA') or
			(CodSistema in ('AH', 'CA') and @Sistema = ''))
		--and td.TipoTransacNivel2 = 'EFEC'
		and td.Fecha >= @FechaIni
		and td.Fecha <= @FechaFin
		and (DescripcionTran like '%deposito%' or DescripcionTran like '%recupera%' or DescripcionTran like '%EFEC%')
		and ((@PersonaFisica = 1 and u.CodTPersona = '01')
                     or
                     (@PersonaFisica = 0 and u.CodTPersona <> '01'))
		group by td.codusuario, u.nombrecompleto
	) as x
	where x.MontoTotalPeriodo >= @MontoPeriodo

END
GO