SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboArchConsolEXCEL]
As 
Declare @Cadena Varchar(4000)
CREATE TABLE #A ([Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL ) ON [PRIMARY] 
Exec(@Cadena)

Set @Cadena = 'Dir "D:\finmas\Kemy\' + '*.xls"'
Insert Into #A
Exec master..xp_cmdshell @Cadena

Delete from #A
Where Cadena not like  '%.xls%' or cadena is null

Select Archivo = substring(Cadena, 42, 100) 
from #A
Union
Select Archivo = 'Ninguno'

Drop Table #A
GO