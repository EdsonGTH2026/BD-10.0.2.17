SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsPLD_DictamenOperPerfilDetalle] (@IdOperacion int)
AS
BEGIN

	select 
	IdOperacion,
	NroTransaccion, 
	Tipo ,      
	Fecha,                                                  
	CodigoCuenta,              
	MontoTotalTran ,       
	NomOficina,                                                                                          
	DescripcionTran                                                                                                                                                                                                                                                  
	from tCsPLD_OperacionesInusualesdetalle
	where 
	Activo = 1
	and IdOperacion = @IdOperacion
	order by tipo , Fecha

END
GO