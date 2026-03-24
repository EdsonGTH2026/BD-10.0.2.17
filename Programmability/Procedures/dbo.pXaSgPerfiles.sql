SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaSgPerfiles]
as
SELECT g.codgrupo,g.grupo
FROM tSgGrupos g with(nolock) 
inner join tSgUsSistema s with(nolock) on g.codgrupo=s.codgrupo
where s.codsistema='MB' and g.codgrupo<>'ADM01'
group by g.codgrupo,g.grupo
GO