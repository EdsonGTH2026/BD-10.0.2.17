SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsAhRptLocalidadesPatmir
--exec pCsAhRptLocalidadesPatmir '2'
CREATE PROCEDURE [dbo].[pCsAhRptLocalidadesPatmir]
               ( @CodOficina VARCHAR(10) )
AS
               
SELECT DISTINCT case when len(o.codoficina) = 1 then '0'+o.codoficina else o.codoficina end as CodOficina, o.NomOficina, 
       d.ESTADO_DSC    AS Estado,   d.ESTADO_ID AS EdoID,
       d.MUNICIPIO_DSC AS Municipio,d.MUNICIPIO_ID AS MunID,
       d.LOCALIDAD_DSC AS Localidad,d.LOCALIDAD_ID as LocID,
       'SI' as PATMIR
  FROM tcloficinas o
  inner join tclubigeo     u on o.codubigeo    = u.codubigeo
  inner join tclUbigeoDGRV d on u.CodEstado    = d.ESTADO_ID AND 
                                u.CodMunicipio = right(rtrim(d.MUNICIPIO_ID),3)
--                              --u.NomUbiGeo    = d.LOCALIDAD_DSC
  WHERE o.CodOficina not in (1,13,97,98,99)  --in (17,32,7,3,78,19,79,24,29,23,16,20)
    AND Elegible = '1' 
    AND o.CodOficina = @CodOficina
  ORDER BY d.LOCALIDAD_DSC--case when len(o.codoficina) = 1 then '0'+o.codoficina else o.codoficina end--o.CodOficina
GO