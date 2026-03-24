SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[pTcValidaLavado]
 @usuario	varchar(20),
 @fecha		varchar(6)

as

SELECT SUM(X.TOTALAHORRO) AS Total  FROM (
select  ISNULL(sum(tm.montototal),0) as totalahorro
 from tahtransaccionmaestra tm  with(nolock) 
inner join tahcuenta c with(nolock) on c.codcuenta=tm.codcuenta and c.fraccioncta=tm.fraccioncta and c.renovado=tm.renovado
where c.codustitular=@usuario and tm.codtipotrans='2' and dbo.fduFechaATexto(tm.fecha,'AAAAMM')=@fecha
group by c.codustitular,tm.codtipotrans
UNION ALL
select isnull(sum(y.montopagado),0) as totalcredito from (
select distinct  z.codusuario,z.montopagado,z.secpago from (
select pd.secpago,pd.montopagado,pd.codusuario,pd.codconcepto from tcapagodet pd with(nolock) where pd.codusuario=@usuario
) z
inner join tcapagoreg pr with(nolock) on pr.secpago=z.secpago
where dbo.fduFechaATexto(pr.fechapago,'AAAAMM')=@fecha 
) y
)X 
GO