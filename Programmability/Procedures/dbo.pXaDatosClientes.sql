SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaDatosClientes 'IME950621F1KBA1'
CREATE procedure [dbo].[pXaDatosClientes] @codusuario varchar(15)
as
select codusuario,isnull(uscurp,uscurpbd) curp,isnull(usrfc,usrfcbd) RFC,convert(varchar,FechaNacimiento,103) as FechaNacimiento
,(case cl.Sexo when 1 then 'MASCULINO' else 'FEMENINO' end) as Sexo
,(case CodEstadoCivil 
 when 'C' then 'CASADO' 
 when 'S' then 'SOLTERO' 
 when 'U' then 'UNION LIBRE' 
 else 'DESCONOCIDO' end) as EstadoCivil
,direcciondirfampri+' '+ numextfam+' '+numintfam+', Col. '+ul.DescUbiGeo+' Mun. '+ um.DescUbiGeo + ' Edo. ' + ue.DescUbiGeo direccion
,isnull(telefonodirfampri,telefonodirnegpri) Telefono
,cl.telefonomovil
from tcspadronclientes cl
left outer join tclubigeo uL with(nolock) on uL.codubigeo=cl.CodUbiGeodirfampri
left outer join tclubigeo uM with(nolock) on uM.codubigeotipo='MUNI' and uM.codarbolconta=substring(uL.codarbolconta,1,19) 
left outer join tclubigeo uE with(nolock) on uE.codubigeotipo='ESTA' and uE.codarbolconta=substring(uL.codarbolconta,1,13) 
where codusuario=@codusuario
GO