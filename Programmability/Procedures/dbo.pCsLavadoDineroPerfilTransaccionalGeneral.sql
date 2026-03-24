SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsLavadoDineroPerfilTransaccionalGeneral] (@FechaIni smalldatetime, @FechaFin smalldatetime, @NumOperaciones int, @PersonaFisica bit)
AS
BEGIN
	select t.CodUsuario,u.nombrecompleto, t.TotalTransacciones 
	from (
		select 
	    CodUsuario, count(NroTransaccion) as TotalTransacciones
		from tcstransacciondiaria as td
		where 
		td.CodSistema = 'CA' --in ('CA','AH')
		and td.TipoTransacNivel2 = 'EFEC'
		and td.Fecha >= @FechaIni
		and td.Fecha <= @FechaFin
		and (td.DescripcionTran like '%deposito%' or DescripcionTran like '%recupera%')
		group by CodUsuario
	) as t
	inner join tCsPadronClientes as u on u.codusuario = t.codusuario 
	where t.TotalTransacciones >= @NumOperaciones
	and ((@PersonaFisica = 1 and u.CodTPersona = '01')
          or
         (@PersonaFisica = 0 and u.CodTPersona <> '01'))
END
GO