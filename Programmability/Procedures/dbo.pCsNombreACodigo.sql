SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsNombreACodigo 
CREATE Procedure [dbo].[pCsNombreACodigo] 
@Nombre 	Varchar(100),
@CodUsuario  	Varchar(15) output
AS  
BEGIN 	

Set @Nombre		= Ltrim(Rtrim(@Nombre))
Set @Nombre 	= Replace(@Nombre, ',', ' ')
Set @Nombre 	= Replace(@Nombre, '.', ' ')
Set @Nombre 	= Replace(@Nombre, '  ', ' ')

Declare @P1 	Varchar(50)
Declare @P2 	Varchar(50)
Declare @P3 	Varchar(50)
Declare @P4 	Varchar(50)

Declare @P5 	Varchar(50)
Declare @P6 	Varchar(50)
Declare @P7 	Varchar(50)
Declare @P8 	Varchar(50)

Declare @POS	Int

Set @P1 = ''
Set @P2 = ''
Set @P3 = ''
Set @P4 = ''

Set @POS 	= 1
If CharIndex(' ', @Nombre, @POS) <> 0
Begin
	Set @P1 	= Substring(@Nombre, @POS, CharIndex(' ', @Nombre, @POS) - @POS) 
End
Else 
Begin
	Set @P1 	= Substring(@Nombre, @POS, Len(@Nombre) + 1) 	
End

Set @POS 	= CharIndex(' ', @Nombre, @POS) + 1
If CharIndex(' ', @Nombre, @POS) <> 0
Begin
	Set @P2 	= Substring(@Nombre, @POS, CharIndex(' ', @Nombre, @POS) - @POS)
End
Else 
Begin
	Set @P2 	= Substring(@Nombre, @POS, Len(@Nombre) - @POS + 1) 	
End

Set @POS 	= CharIndex(' ', @Nombre, @POS) + 1
If CharIndex(' ', @Nombre, @POS) <> 0
Begin
	Set @P3 	= Substring(@Nombre, @POS, CharIndex(' ', @Nombre, @POS) - @POS)
End
Else 
Begin
	Set @P3 	= Substring(@Nombre, @POS, Len(@Nombre) - @POS +  1) 	
End

Set @POS 	= CharIndex(' ', @Nombre, @POS) + 1
If CharIndex(' ', @Nombre, @POS) <> 0
Begin
	Set @P4 	= Substring(@Nombre, @POS, CharIndex(' ', @Nombre, @POS) - @POS)
End
Else 
Begin
	Set @P4 	= Substring(@Nombre, @POS, Len(@Nombre) - @POS +  1) 	
End

Set @P1	= Ltrim(Rtrim(@P1)) 	
Set @P2 = Ltrim(Rtrim(@P2))	
Set @P3 = Ltrim(Rtrim(@P3))	
Set @P4 = Ltrim(Rtrim(@P4))

Set @P5 = Replace(@P1, 'Z', '_')
Set @P5 = Replace(@P1, 'S', '_')
Set @P5 = Replace(@P1, 'LL', '_')
Set @P5 = Replace(@P1, 'Y', '_')
Set @P5 = Replace(@P1, 'V', '_')
Set @P5 = Replace(@P1, 'B', '_')
Set @P5 = Replace(@P1, 'C', '_')
Set @P5 = Replace(@P1, 'RR', '_')
Set @P5 = Replace(@P1, 'K', '_')
Set @P5 = Replace(@P1, 'Ñ', '_')
	
Set @P6 = Replace(@P2, 'Z', '_')
Set @P6 = Replace(@P2, 'S', '_')
Set @P6 = Replace(@P2, 'LL', '_')
Set @P6 = Replace(@P2, 'Y', '_')
Set @P6 = Replace(@P2, 'V', '_')
Set @P6 = Replace(@P2, 'B', '_')
Set @P6 = Replace(@P2, 'C', '_')
Set @P6 = Replace(@P2, 'RR', '_')
Set @P6 = Replace(@P2, 'K', '_')
Set @P6 = Replace(@P2, 'Ñ', '_')

Set @P7 = Replace(@P3, 'Z', '_')
Set @P7 = Replace(@P3, 'S', '_')
Set @P7 = Replace(@P3, 'LL', '_')
Set @P7 = Replace(@P3, 'Y', '_')
Set @P7 = Replace(@P3, 'V', '_')
Set @P7 = Replace(@P3, 'B', '_')
Set @P7 = Replace(@P3, 'C', '_')
Set @P7 = Replace(@P3, 'RR', '_')
Set @P7 = Replace(@P3, 'K', '_')
Set @P7 = Replace(@P3, 'Ñ', '_')

Set @P8 = Replace(@P4, 'Z', '_')
Set @P8 = Replace(@P4, 'S', '_')
Set @P8 = Replace(@P4, 'LL', '_')
Set @P8 = Replace(@P4, 'Y', '_')
Set @P8 = Replace(@P4, 'V', '_')
Set @P8 = Replace(@P4, 'B', '_')
Set @P8 = Replace(@P4, 'C', '_')
Set @P8 = Replace(@P4, 'RR', '_')
Set @P8 = Replace(@P4, 'K', '_')
Set @P8 = Replace(@P4, 'Ñ', '_')

Print @P1 	
Print @P2 	
Print @P3 	
Print @P4
Print @P5 	
Print @P6 	
Print @P7 	
Print @P8

--Declare @CodUsuario	Varchar(15)

Delete From tCsfduNombreACodigo
Where Parametro = @Nombre

Insert Into tCsfduNombreACodigo
Select Top 10 Parametro = @Nombre, CodUsuario, 1, getdate(), NombreCompleto
From tCspadronClientes with(nolock)
Where 	NombreCompleto like '%'+ @P1 + ' ' + @P2 + ' ' + @P3  +'%'
AND	NombreCompleto like '%'+ @P4 +'%'

Insert Into tCsfduNombreACodigo
Select Top 10 Parametro = @Nombre, CodUsuario, 2, getdate(), NombreCompleto
From tCspadronClientes with(nolock)
Where 	NombreCompleto like '%'+ @P2 + ' ' + @P3 + ' ' + @P1  +'%' 
AND	NombreCompleto like '%'+ @P4 +'%'

Insert Into tCsfduNombreACodigo
Select Top 10 Parametro = @Nombre, CodUsuario, 2, getdate(), NombreCompleto
From tCspadronClientes with(nolock)
Where 	NombreCompleto like '%'+ @P3 + ' ' + @P4 + ' ' + @P1  +'%' 
AND	NombreCompleto like '%'+ @P2 +'%'

Insert Into tCsfduNombreACodigo
Select Top 10 Parametro = @Nombre, CodUsuario, 3, getdate(), NombreCompleto
From tCspadronClientes with(nolock)
Where 	NombreCompleto like '%'+ @P1 +'%'
AND	NombreCompleto like '%'+ @P2 +'%'
AND	NombreCompleto like '%'+ @P3 +'%'
AND	NombreCompleto like '%'+ @P4 +'%'

Insert Into tCsfduNombreACodigo
Select Top 10 Parametro = @Nombre, CodUsuario, 4, getdate(), NombreCompleto
From tCspadronClientes with(nolock)
Where 	NombreCompleto like '%'+ @P5 + ' ' + @P6 + ' ' + @P7  +'%'
AND	NombreCompleto like '%'+ @P8 +'%'

Insert Into tCsfduNombreACodigo
Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
From tCspadronClientes with(nolock)
Where 	NombreCompleto like '%'+ @P5 +'%'
AND	NombreCompleto like '%'+ @P6 +'%'
AND	NombreCompleto like '%'+ @P7 +'%'
AND	NombreCompleto like '%'+ @P8 +'%'

If @@Rowcount = 0 
Begin 
	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 4 , getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P1 +'%'
	AND	NombreCompleto like '%'+ @P2 +'%'
	AND	NombreCompleto like '%'+ @P3 +'%'
 
	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 4, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P1 +'%'
	AND	NombreCompleto like '%'+ @P2 +'%'
	AND	NombreCompleto like '%'+ @P4 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 4, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P2 +'%'
	AND	NombreCompleto like '%'+ @P3 +'%'
	AND	NombreCompleto like '%'+ @P4 +'%'
End

If @@Rowcount = 0 
Begin 
	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P1 +'%'
	AND	NombreCompleto like '%'+ @P2 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P1 +'%'
	AND	NombreCompleto like '%'+ @P3 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P1 +'%'
	AND	NombreCompleto like '%'+ @P4 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P2 +'%'
	AND	NombreCompleto like '%'+ @P3 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P2 +'%'
	AND	NombreCompleto like '%'+ @P4 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 5, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P3 +'%'
	AND	NombreCompleto like '%'+ @P4 +'%'
End 

If @@Rowcount = 0 
Begin 
	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 6, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P1 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 6, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P2 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 6, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P3 +'%'

	Insert Into tCsfduNombreACodigo
	Select Top 10 Parametro = @Nombre, CodUsuario, 6, getdate(), NombreCompleto
	From tCspadronClientes with(nolock)
	Where 	NombreCompleto like '%'+ @P4 +'%'
End 

---Select *  From tCsfduNombreACodigo where combinacion not in (Select min(Combinacion) From tCsfduNombreACodigo) and Parametro  = @Nombre

Delete From tCsfduNombreACodigo where combinacion not in (
Select min(Combinacion) From tCsfduNombreACodigo Where Parametro  = @Nombre) and Parametro  = @Nombre

SELECT     TOP 1 @Codusuario = M.CodUsuario
FROM         (SELECT     MAX(Maximo) AS Maximo
                       FROM          (SELECT     CodUsuario, COUNT(*) AS Maximo
                                               FROM          tCsfduNombreACodigo
						Where Parametro = @Nombre
                                               GROUP BY CodUsuario) datos) Datos INNER JOIN
                          (SELECT     CodUsuario, COUNT(*) AS Maximo
                            FROM          tCsfduNombreACodigo
			    Where Parametro = @Nombre			    
                            GROUP BY CodUsuario) M ON Datos.Maximo = M.Maximo
ORDER BY NEWID()                            
End
GO