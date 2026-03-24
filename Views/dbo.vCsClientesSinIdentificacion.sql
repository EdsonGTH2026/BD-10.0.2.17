SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create View [dbo].[vCsClientesSinIdentificacion]
As
Select * from [BD-FINAMIGO-DC].Finmas.dbo.vUsIdentificacion vUsIdentificacion                  
where coddociden = 'XX'  
GO