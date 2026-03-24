SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCRAdministraEstado]
@Empresa	Varchar(2),
@Actual		Varchar(15), 
@Estado	Varchar(50)
As
--Set @Empresa	= 'BC'
--Set @Actual	= 'MI25571009'		
--Set @Estado	= 'Cancelado'		-- 'Cancelado',  'Todo Bien', 'Bloqueado'
Declare @Reporte Varchar(100)
Set @Reporte = 'CONSULTA DE ESTADO'
If @Estado <> 'Consulta' 
Begin		       
	Set @Reporte = 'CAMBIO DE ESTADO  '
	Declare @CodOficina 	Varchar(4)	
	SELECT   @CodOficina = CodOficina
	FROM         tCREmpresaUsuarios
	WHERE     (ClaveOtorgante = @Actual) AND (Empresa = Empresa)

	Exec pCRAdministraClaves
	@CodOficina 	,  
	'CE', 
	@Empresa	,
	@Actual		, 
	''		, 
	@Estado		 
End 
SELECT   Reporte = @Reporte,  tCREmpresaUsuarios.Empresa, tCREmpresas.Nombre AS NEmpresa, tCREmpresaUsuarios.ClaveOtorgante, 
                      ISNULL(tCsPadronClientes.NombreCompleto, 'Nombre No Identificado') AS UsuarioFinamigo, tCREmpresaUsuarios.Contraseña, 
                      tCREmpresaUsuarios.Expira, tCREmpresaUsuarios.Consulta, tCREmpresaUsuarios.Estado, tCREmpresaUsuarios.CodUsuario, 
                      tCREmpresaUsuarios.CodOficina
FROM         tCREmpresaUsuarios INNER JOIN
                      tCREmpresas ON tCREmpresaUsuarios.Empresa = tCREmpresas.Empresa LEFT OUTER JOIN
                      tCsPadronClientes ON tCREmpresaUsuarios.CodUsuario = tCsPadronClientes.CodUsuario
WHERE     (tCREmpresaUsuarios.ClaveOtorgante = @Actual) AND (tCREmpresaUsuarios.Empresa = @Empresa)
GO