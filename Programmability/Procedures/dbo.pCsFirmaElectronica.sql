SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROCEDURE pCsFirmaElectronica
CREATE Procedure [dbo].[pCsFirmaElectronica]
@Usuario 	Varchar(50),
@Sistema	Varchar(2),
@Dato		Varchar(100),
@Firma		Varchar(100) Output,
@Motivo		Varchar(500) = ''	
As
set nocount on
--Print @Usuario 	
--Print @Sistema	
--Print @Dato	

Set @Motivo = Ltrim(Rtrim(@Motivo))

--Declare @Usuario	Varchar(50), @Sistema Varchar(2), @Dato Varchar(100)

--Set @Usuario		= 'KVALERA'
--Set @Sistema		= 'CA'
--Set @Dato		= '005-116-06-09-02160'

-----------------------------------
Declare @FechaLetras 	Varchar(6)
Declare @FechaNumeros 	Varchar(12)
Declare @Contador	Int
Declare @TempoINT1	Int
Declare @TempoINT2	Int
Declare @TempoVCH1	Varchar(100)
Declare @C1		Varchar(6)
Declare @C2		Varchar(6)
--Declare @Firma	Varchar(100)
Declare @Version	Int

Set @Version		= 1
Set @C1 		= 'DMAHNS'
Set @C2 		= 'IEORTG'
Set @Contador 		= 6
Set @FechaLetras	= ''
Set @FechaNumeros	= ''

SELECT  @Firma = UPPER(SUBSTRING(LTRIM(RTRIM(Usuario)), 1, 1) + SUBSTRING(LTRIM(RTRIM(Usuario)), LEN(LTRIM(RTRIM(Usuario))) / 2, 1) + RIGHT(LTRIM(RTRIM(Usuario)), 1)) 
FROM  	tSgUsuarios
WHERE 	Usuario = @Usuario

SELECT @TempoINT1 = Cast(RAND(datepart(ms, getdate())) * 1000000000 as int) % 2 

While @Contador >= 1
Begin
	If @TempoINT1 = 0 
	Begin 
		Set @TempoINT1 = 1 
	End
	Else
	Begin 
		Set @TempoINT1 = 0 
	End
	
	SELECT @TempoINT2 = (Cast(RAND(datepart(ms, getdate())) * 1000000000 as int) % @Contador)  +  1 

	If @TempoINT1 = 1
	Begin
		Set @FechaLetras = @FechaLetras + Substring(@C1, @TempoINT2, 1)
	End
	If @TempoINT1 = 0
	Begin
		Set @FechaLetras = @FechaLetras + Substring(@C2, @TempoINT2, 1)
	End
	
	Set @TempoVCH1 = Right(@FechaLetras, 1)

	If CharIndex(@TempoVCH1, 'DI') <> 0 Begin Set @FechaNumeros = @FechaNumeros + dbo.fduRellena('0', DatePart(dd,GetDate()), 2, 'D') End
	If CharIndex(@TempoVCH1, 'ME') <> 0 Begin Set @FechaNumeros = @FechaNumeros + dbo.fduRellena('0', DatePart(mm,GetDate()), 2, 'D') End
	If CharIndex(@TempoVCH1, 'AO') <> 0 Begin Set @FechaNumeros = @FechaNumeros + dbo.fduFechaATexto(GetDate(), 'AA') End
	If CharIndex(@TempoVCH1, 'HR') <> 0 Begin Set @FechaNumeros = @FechaNumeros + dbo.fduRellena('0', DatePart(hh,GetDate()), 2, 'D') End
	If CharIndex(@TempoVCH1, 'NT') <> 0 Begin Set @FechaNumeros = @FechaNumeros + dbo.fduRellena('0', DatePart(mi,GetDate()), 2, 'D') End
	If CharIndex(@TempoVCH1, 'SG') <> 0 Begin Set @FechaNumeros = @FechaNumeros + dbo.fduRellena('0', DatePart(ss,GetDate()), 2, 'D') End

	Set @C1		= Substring(@C1, 1, @TempoINT2 - 1) + Substring(@C1, @TempoINT2 + 1, 6)
	Set @C2		= Substring(@C2, 1, @TempoINT2 - 1) + Substring(@C2, @TempoINT2 + 1, 6)
	Set @Contador  	= @Contador - 1			
End

Set @TempoVCH1 = @Dato

If @Sistema In ('AH','CA')
Begin
	Set @Dato = Right(Rtrim(Ltrim(Replace(@Dato, '-', ''))),5)
End

Set @Firma = 'V' + dbo.fduRellena('0', @Version, 2, 'D') + @Firma + @FechaLetras + @FechaNumeros + @Sistema + @Dato

Set @Contador = 0

Select @Contador = Max(Secuencia) From tCsFirmaElectronica
Where Version = @Version And Usuario = @Usuario And Sistema = @Sistema And Dato = @TempoVCH1

If @Contador Is null Begin Set @Contador = 0 End

Set @Contador = @Contador + 1

Set @Firma = @Firma + dbo.fduRellena('0', @Contador, 3, 'D')

Delete From tCsFirmaReporteClausula Where Firma In (Select Firma From tCsFirmaElectronica Where Version = @Version And Usuario = @Usuario And Sistema = @Sistema And Dato = @TempoVCH1 And Firma <> @Firma)
Delete From tCsFirmaReporteDetalle Where Firma In (Select Firma From tCsFirmaElectronica Where Version = @Version And Usuario = @Usuario And Sistema = @Sistema And Dato = @TempoVCH1 And Firma <> @Firma)
Delete From tCsFirmaReporte Where Firma In (Select Firma From tCsFirmaElectronica Where Version = @Version And Usuario = @Usuario And Sistema = @Sistema And Dato = @TempoVCH1 And Firma <> @Firma)

Update tCsFirmaElectronica Set Activo = 0 Where Usuario = @Usuario and Dato = @TempoVCH1

Insert Into tCsFirmaElectronica (Firma, Version, Usuario, Registro, Sistema, Dato, Secuencia, Activo, Motivo)
Values(@Firma, @Version, @Usuario, GetDate(), @Sistema, @TempoVCH1, @Contador, 1, @Motivo)

GO