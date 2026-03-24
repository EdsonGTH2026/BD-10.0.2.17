SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Exec pCsCboSecuenciaCliente '3'
CREATE Procedure [dbo].[pCsCboSecuenciaCliente]
@CodOficina As Varchar(4)
As
Select * From (
Select Distinct  S= Secuencia, ' = ' +  CAst(Secuencia as Varchar(10)) as Codigo, 
CAst(Secuencia as Varchar(10)) as Secuencia From (
Select CodUsuario, Max(SecuenciaCliente) as Secuencia from tCsPadronCarteraDet
Where Codoficina = @CodOficina
group by codusuario) Datos
UNION
Select S = 99, Codigo = ' >= 1 ', Secuencia = 'TODAS' ) Datos
Order by S

GO