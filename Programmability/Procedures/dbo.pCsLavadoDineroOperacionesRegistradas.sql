SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsLavadoDineroOperacionesRegistradas] (@FechaIni smalldatetime, @FechaFin smalldatetime, @PersonaFisica bit, @TipoOperacion int)
AS
BEGIN

	select
	o.FechaIni,                                               
	o.FechaFin,                                               
	(case o.TipoPersona 
	when 'F' then 'FISICA'
	else 'MORAL'
	end) as TipoPersona, 
	o.CodCliente,
	pc.NombreCompleto, 
	o.MontoLimite,           
	o.OperacionesLimite,  
	(case 
	when (o.MontoTotalPeriodo > 0 and o.OperacionesPeriodo = 0) then 'OPERACIONES X MONTO'
	else 'PERFIL TRANSACCIONAL'
	end )  as TipoOperacion,
	o.MontoTotalPeriodo,     
	o.OperacionesPeriodo,  
	(case 
	when len(isnull(d.Dictamen,'')) > 0 then 'SI'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	else 'NO'
	end) Dictaminado                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
	
	from tCsLavadoDineroOperaciones as o
	inner join tcspadronclientes as pc on pc.CodUsuario = o.CodCliente
	left join tCsLavadoDineroOperacionesDictamen as d on d.FechaIni = o.FechaIni and d.FechaFin = o.FechaFin and d.TipoPersona = o.TipoPersona and d.MontoLimite = o.MontoLimite and d.OperacionesLimite = o.OperacionesLimite and d.CodCliente = o.CodCliente
	where 
	o.Activo = 1
	and o.FechaIni >= @FechaIni
	and o.FechaFin <= @Fechafin
	
	and ((@PersonaFisica = 1 and o.TipoPersona = 'F') or 
	     (@PersonaFisica = 0 and o.TipoPersona = 'M')) 
	
	and ((@TipoOperacion=1 and o.MontoTotalPeriodo > 0 and o.OperacionesPeriodo = 0) or
	     (@TipoOperacion=2 and o.MontoTotalPeriodo = 0 and o.OperacionesPeriodo > 0) )
END 


GO