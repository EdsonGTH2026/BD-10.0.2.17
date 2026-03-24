SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop function fduCamino
CREATE FUNCTION [dbo].[fduCamino] (@Dato Int, @Opcion Varchar(5))  
RETURNS Varchar(8000)
AS  
BEGIN
	Declare @CCodigo 	Varchar(500)
	Declare @CEtiqueta 	Varchar(500)
	Declare @Temporal	Varchar(500)
	
	Set @CCodigo 	= ''
	Set @CEtiqueta 	= ''
	set @Temporal	= @Opcion
	While Ltrim(Rtrim(@Temporal)) <> '' 
	Begin
		If @Dato In (1,2)
		Begin
			SELECT  @CCodigo 	= tSgOptions.Opcion + Case When Ltrim(Rtrim(@CCodigo)) = '' Then @CCodigo Else '/' + @CCodigo End,  
				@Opcion 	= tSgOptions.OpcionPare, 
				@CEtiqueta 	= tSgOptions.Nombre + Case When Ltrim(Rtrim(@CEtiqueta)) = '' Then @CEtiqueta Else '/' + @CEtiqueta End 	 
			FROM         tSgOptions INNER JOIN
			                      tSgOptions tSgOptions_1 ON tSgOptions.OpcionPare = tSgOptions_1.Opcion AND tSgOptions.CodSistema = tSgOptions_1.CodSistema
			WHERE     (tSgOptions.Opcion = @Opcion) AND (tSgOptions.CodSistema = 'DC')
			If @@RowCount = 0 Begin Set @Temporal = '' End
		End
		If @Dato In (3)
		Begin
			Declare CurParametros Cursor For 
				SELECT     tSgReportesParametros.Etiqueta + ' [' + tSgReportesParametros.Nombre + ']: ' + tSgTipoDato.Nombre COLLATE Modern_Spanish_CI_AS AS Parametros
				FROM         (SELECT     Objeto
				                       FROM          tSgOptions
				                       WHERE      (Opcion = @Opcion) AND (CodSistema = 'DC')) Datos INNER JOIN
				                      tSgReportesParametros ON Datos.Objeto = tSgReportesParametros.CodReporte INNER JOIN
				                      tSgTipoDato ON tSgReportesParametros.TipoDato = tSgTipoDato.TipoDato			
			Open CurParametros
			Fetch Next From CurParametros Into @Temporal
			While @@Fetch_Status = 0
			Begin
				Set @CCodigo = @CCodigo + @Temporal + Char(13)
			Fetch Next From CurParametros Into  @Temporal
			End 
			Close 		CurParametros
			Deallocate 	CurParametros			
			Set @Temporal = ''
		End
		If @Dato In (4)
		Begin
			Declare CurParametros Cursor For 
				--SELECT     '[' + CAST(tSgAcciones.Acceder AS varchar(1)) + CAST(tSgAcciones.Anadir AS varchar(1)) + CAST(tSgAcciones.Editar AS varchar(1)) 
				--                      + CAST(tSgAcciones.Grabar AS varchar(1)) + CAST(tSgAcciones.Cancelar AS varchar(1)) + CAST(tSgAcciones.Eliminar AS Varchar(1)) 
				--                      + CAST(tSgAcciones.Imprimir AS varchar(1)) + CAST(tSgAcciones.Cerrar AS varchar(1)) + '] ' + UPPER(tSgGrupos.Descripcion) AS Descripcion

				SELECT      UPPER(tSgGrupos.Descripcion) AS Descripcion
				FROM         tSgGrupos INNER JOIN
				                      tSgAcciones ON tSgGrupos.CodGrupo = tSgAcciones.CodGrupo INNER JOIN
				                      tSgOptions ON tSgAcciones.Opcion = tSgOptions.Opcion AND tSgAcciones.CodSistema = tSgOptions.CodSistema
				WHERE     (tSgOptions.Opcion = @Opcion) AND (tSgOptions.CodSistema = 'DC') And Acceder = 1			
			Open CurParametros
			Fetch Next From CurParametros Into @Temporal
			While @@Fetch_Status = 0
			Begin
				Set @CCodigo = @CCodigo + @Temporal + Char(13)
			Fetch Next From CurParametros Into  @Temporal
			End 
			Close 		CurParametros
			Deallocate 	CurParametros			
			Set @Temporal = ''
		End
	End
	
	If @Dato In (1,2)
	Begin
		SELECT  @CCodigo 	= tSgOptions.Opcion + '/' + @CCodigo, 	
			@CEtiqueta 	= tSgOptions.Nombre + '/' + @CEtiqueta 	 
		From tSgOptions
		WHERE     (Opcion = @Opcion) AND (CodSistema = 'DC')
	End
	If @Dato In (1,3,4) Begin Set @Temporal = @CCodigo End	
	If @Dato = 2 Begin Set @Temporal = @CEtiqueta End	

RETURN (@Temporal)
END
GO