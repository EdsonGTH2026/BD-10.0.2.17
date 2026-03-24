SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[pCsPLD_DictamenOperPerfil] (@IdOperacion int)
AS
BEGIN

	select 
	oi.IdOperacion,
	dic.IdOperacionDictamen, 
	oi.FechaIni,                                               
	oi.FechaFin ,                                              
	oi.TipoPersona ,
	oi.MontoLimite,           
	oi.OperacionesLimite, 
	oi.MontoTotalPeriodo,     
	oi.OperacionesPeriodo,
	oi.CodCliente,    
	cli.NombreCompleto,  
	dic.FechaDictamen,                                          
	dic.EsInusual, 
	dic.Dictamen ,                                                                                                                                                                                                                                                        
	dic.Estatus,    
	dic.CodUsuarioAlta, 
	isnull(u.NombreCompleto,'FALTA') as Dictaminador,      
	dic.FechaAlta                                              
	from
	tCsPLD_OperacionesInusuales as oi
	inner join tCsPLD_OperacionesDictamen as dic on dic.IdOperacion = oi.IdOperacion
	inner join tCsPadronClientes as cli on cli.CodUsuario = oi.CodCliente
	left join tsgusuarios as u on u.CodUsuario = dic.CodUsuarioAlta
	where
	--dic.IdOperacionDictamen = 1
	oi.IdOperacion = @IdOperacion

END

GO