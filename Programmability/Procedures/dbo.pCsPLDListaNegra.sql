SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsPLDListaNegra](@FechaIni smalldatetime, @FechaFin smalldatetime, @ConIncidencia bit)
as
BEGIN

select  
x.IdListaNegra, x.FolioOficio, x.DescTipoPersona, x.Nombre1, x.Nombre2,
x.ApellidoPaterno, x.ApellidoMaterno, x.NombreCompleto, x.RFC, x.CURP,   x.FechaNacimiento, 
x.Domicilio, x.DatosComplementarios, x.FechaCreacion,   x.NumCoincidencias   
from (
      select      ln.IdListaNegra,ln.FolioOficio,
       (case ln.TipoPersona      when 'F' then 'FISICA'      else 'MORAL'      end) as DescTipoPersona,
       ln.Nombre1,  ln.Nombre2, ln.ApellidoPaterno,
       ln.ApellidoMaterno,
       (ltrim(rtrim(ln.ApellidoPaterno + ' '+ ln.ApellidoMaterno + ' ' + ln.Nombre1 + ' ' + ln.Nombre2))) as NombreCompleto,
       ln.RFC, ln.CURP,
       ln.FechaNacimiento, ln.Domicilio,       ln.DatosComplementarios,
       ln.FechaCreacion,
       (  select       count(pc.codusuario) as coincidencias   
          from tcspadronclientes as pc  
          where
          pc.CodTPersona = (case ln.TipoPersona      
                         when 'F' then '01'      
                         else pc.CodTPersona
                         end)
          and isnull(pc.Nombre1,'') = ln.Nombre1
          and ((isnull(pc.Nombre2,'') = ln.Nombre2 and len(ln.Nombre2) > 0) or (isnull(pc.Nombre2,'') = isnull(pc.Nombre2,'') and len(ln.Nombre2) = 0))
          and isnull(pc.Paterno,'') = ln.ApellidoPaterno
          and isnull(pc.Materno,'') = ln.ApellidoMaterno
      ) as NumCoincidencias
      from tCsLavadoDineroListaNegra as ln
      where Activo = 1
      and convert(varchar,FechaCreacion,112) >= convert(varchar,@FechaIni,112)
      and convert(varchar,FechaCreacion,112) <= convert(varchar,@FechaFin,112)
) as x  
where 1=1
and ((@ConIncidencia = 1 and x.NumCoincidencias > 0)
 or (@ConIncidencia = 0 and x.NumCoincidencias >= 0)
)
--and x.NumCoincidencias > 0
order by x.ApellidoPaterno, x.ApellidoMaterno, x.Nombre1, x.Nombre2 


END



GO