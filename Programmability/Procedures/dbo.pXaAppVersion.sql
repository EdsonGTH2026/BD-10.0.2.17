SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAppVersion] 
as  

select s.ultvermayor vma,s.ultvermenor vme,s.ultverrevision vre
from tSgSistemas s  
where s.codsistema='MO' 
GO