SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fduCuentasActuales] (@Sistema Varchar(2), @CodUsuario Varchar(15))  
RETURNS Varchar(4000)
AS  
BEGIN

--Set @Sistema	= 'AH'
--Set @CodUsuario	= 'RON1603641'

Declare @Resultado	Varchar(4000)
Declare @Cuenta		Varchar(50)

Set @Resultado = ''

If @Sistema = 'AH'
Begin
	Declare CurCarta Cursor For 
		SELECT        tCsClientesAhorros.CodCuenta
		FROM            tCsClientesAhorros INNER JOIN
								 tCsPadronAhorros ON tCsClientesAhorros.CodCuenta = tCsPadronAhorros.CodCuenta AND tCsClientesAhorros.FraccionCta = tCsPadronAhorros.FraccionCta AND 
								 tCsClientesAhorros.Renovado = tCsPadronAhorros.Renovado
		WHERE        (tCsClientesAhorros.CodUsCuenta = @CodUsuario) And EstadoCalculado not in ('CC')
	Open CurCarta
	Fetch Next From CurCarta Into @Cuenta
	While @@Fetch_Status = 0
	Begin
		Set @Resultado = @Resultado + @Cuenta + Char(10)
	Fetch Next From CurCarta Into  @Cuenta
	End 
	Close 		CurCarta
	Deallocate 	CurCarta
End
If @Sistema = 'CA'
Begin
	Declare CurCarta Cursor For 
		SELECT        CodPrestamo
		FROM            tCsPadronCarteraDet
		WHERE        (EstadoCalculado NOT IN ('CANCELADO')) AND (CodUsuario = @CodUsuario)
	Open CurCarta
	Fetch Next From CurCarta Into @Cuenta
	While @@Fetch_Status = 0
	Begin
		Set @Resultado = @Resultado + @Cuenta + Char(10)
	Fetch Next From CurCarta Into  @Cuenta
	End 
	Close 		CurCarta
	Deallocate 	CurCarta
End

RETURN (@Resultado)
END


GO