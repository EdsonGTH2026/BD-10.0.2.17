SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsLavadoDineroOperacionesDetalle] (@FechaIni smalldatetime, @FechaFin smalldatetime, @MontoPeriodo Money, @PersonaFisica bit, @Sistema varchar(2))
AS
BEGIN

select 
td.NroTransaccion,  
(case td.CodSistema 
when 'CA' then 'CREDITO'
when 'AH' then 'AHORRO'
else 'OTRO'
end ) as Tipo,
td.Fecha, 
td.CodigoCuenta, 
td.codusuario,
u.nombrecompleto,
--td.CodOficina, td.NroTransaccion, 
td.DescripcionTran, 
td.MontoTotalTran,
o.NomOficina,
tot.TotalPeriodo
from tcstransacciondiaria as td WITH (NOLOCK)
inner join tcloficinas as o WITH (NOLOCK) on o.codoficina = td.codoficina
inner join tCsPadronClientes as u WITH (NOLOCK) on u.codusuario = td.codusuario 
inner join (  --en esta tabla se obtiene la suma total de operaciones x usuario
		select CodUsuario, TotalPeriodo 
	        from (
			select CodUsuario, sum(MontoTotalTran) as TotalPeriodo from tCsTransaccionDiaria WITH (NOLOCK)
			where
			--CodSistema in ('AH') --('AH','CA')
			((CodSistema in ('AH') and @Sistema = 'AH') or
             (CodSistema in ('CA') and @Sistema = 'CA') or
			 (CodSistema in ('AH', 'CA') and @Sistema = ''))

			--and TipoTransacNivel2 = 'EFEC'
			and (DescripcionTran like '%deposito%' or DescripcionTran like '%recupera%' or DescripcionTran like '%EFEC%')
			and Fecha >= @FechaIni
			and Fecha <= @FechaFin
			group by CodUsuario
		     ) as t  
		where t.TotalPeriodo >= @MontoPeriodo
	   ) as tot on tot.CodUsuario = td.codusuario
where 
--td.CodSistema in ('AH') --('AH','CA')
((td.CodSistema in ('AH') and @Sistema = 'AH') or
 (td.CodSistema in ('CA') and @Sistema = 'CA') or
 (td.CodSistema in ('AH', 'CA') and @Sistema = ''))
--and td.TipoTransacNivel2 = 'EFEC'
and (td.DescripcionTran like '%deposito%' or DescripcionTran like '%recupera%' or DescripcionTran like '%EFEC%')
and td.Fecha >= @FechaIni
and td.Fecha <= @FechaFin
--and u.CodTPersona = '01'
and ((@PersonaFisica = 1 and u.CodTPersona = '01')
     or
     (@PersonaFisica = 0 and u.CodTPersona <> '01'))
order by u.nombrecompleto

END





GO