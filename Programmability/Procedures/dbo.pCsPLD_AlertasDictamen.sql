SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsPLD_AlertasDictamen] (@IdAlerta int)
AS
BEGIN

	select 
	a.IdAlerta,    
	a.Tipo,
	case a.Tipo
	when 'Es PPE' then 'AHORRO'
	when 'Es Familiar PPE' then 'AHORRO'
	when 'QeQ Ahorro' then 'AHORRO'
	when 'QeQ Credito' then 'CREDITO'
	else ''
	end as TipoOperacion, 
	a.CodOficina,
	o.NomOficina as Oficina,
	a.CodUsuario,
	cli.NombreCompleto,
	a.FechaDictamen,
	a.Coincidencia,
	a.ProcedeOperacionInusual,
	a.Dictamen,
	isnull(u.NombreCompleto,'ALVARADO ROSAS MARLEN SOFIA') as Dictaminador
	from tCsPLD_Alertas as a
	inner join tCsPadronClientes as cli on cli.CodOrigen = a.CodUsuario
	left join tsgusuarios as u on u.CodUsuario = a.CodUsuarioAlta
	left join tcloficinas as o on o.CodOficina = a.CodOficina
	where 
	a.IdAlerta = @IdAlerta

END
GO