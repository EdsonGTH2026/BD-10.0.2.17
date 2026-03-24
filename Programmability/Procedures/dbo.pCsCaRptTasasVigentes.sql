SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCaRptTasasVigentes
create procedure [dbo].[pCsCaRptTasasVigentes]
as
SELECT p.NombreProdCorto,t.INTEAnual
FROM [10.0.2.14].finmas.dbo.tCaProdInteresRelacion t inner join [10.0.2.14].finmas.dbo.tcaproducto p on p.codproducto=t.codproducto
where p.estado='VIGENTE' and p.codproducto not in ('303','304')
GO