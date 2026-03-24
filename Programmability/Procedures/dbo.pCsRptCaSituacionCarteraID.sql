SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsRptCaSituacionCarteraID]
@ID		Varchar(50),
@IFecha	Int,
@NameNew	Varchar(50)
As
--Set @ID = 'DOOTTRCU-0'

Declare @Fecha 		SmallDateTime
Declare @Ubicacion	Varchar(100)
Declare @Nivel1		Varchar(50)
Declare @Nivel2		Varchar(50)
Declare @ClaseCartera	Varchar(100)	
Declare @TipoSaldo	Varchar(1000)
Declare @Reporte 	Varchar(50)

If @IFecha = 2
Begin
	UPDATE    tCsPrID
	SET              Valor = dbo.fduFechaATexto(vCsFechaConsolidacion.FechaConsolidacion, 'AAAAMMDD')
	FROM         tCsPrID CROSS JOIN
	                      vCsFechaConsolidacion
	WHERE     (tCsPrID.Id = @ID) AND (tCsPrID.Parametro = '@Fecha')
End 

Set @NameNew = ltrim(rtrim(@NameNew))
If @NameNew <> ''
Begin
	Select @IFecha = Count(*)
	From tCsPrID
	Where tCsPrID.Id = ltrim(rtrim(@NameNew))
	
	If @IFecha = 0 
	Begin
		UPDATE    tCsPrID
		Set [ID] = @NameNew
		WHERE     (tCsPrID.Id = @ID)
		
		Set @ID = @NameNew
	End
End

Exec pRptParametrosID @ID, 
@Fecha 		Out,
@Ubicacion		Out,
@Nivel1		Out,
@Nivel2		Out,
@ClaseCartera		Out,
@TipoSaldo		Out,
@Reporte 		Out

Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Nivel1, @Nivel2, @ClaseCartera, @TipoSaldo, @Reporte
GO