SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRegCreditoxMunSiti] @fec smalldatetime        
as        
declare @fecha smalldatetime        
set @fecha=@fec--'20231231'--        
        
select @fecha Fecha,'Financiera Mexicana Para el Desarrollo Rural S.A. de C.V. SFP' Entidad,Municipio,Estado,codmunicipio        
,count(b.codprestamo) NroCreditos, sum(b.saldocartera) saldocartera,b.descripcion        
from(        
        
  SELECT cd.codprestamo,cd.codusuario        
  ,isnull(isnull(c.codubigeodirfampri,c.codubigeodirnegpri),o.codubigeo) codubigeo        
  ,case when ca.codfondo=20 then (cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido)*0.3         
    when ca.codfondo=21 then (cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido)*0.25        
    else cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido end saldocartera        
  ,t.Descripcion        
  ,o.codubigeo codubigeoofi        
  ,cl.municipio,cl.estado        
  ,replicate('0',2-len(cl.codestado))+cl.codestado+replicate('0',3-len(cl.codmunicipio))+cl.codmunicipio codmunicipio        
  FROM tCsCartera ca with(nolock)        
  inner join tCsCarteraDet cd with(nolock) on cd.fecha=ca.fecha and cd.codprestamo=ca.codprestamo        
  left outer join tcspadronclientes c with(nolock) on c.codusuario=cd.codusuario        
  inner join tCaProdPerTipoCredito t with(nolock) on t.codtipocredito=ca.codtipocredito        
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina        
  left outer join tClUbigeoCNBVEqui ce with(nolock) on ce.codubigeo=isnull(isnull(c.codubigeodirfampri,c.codubigeodirnegpri),o.codubigeo)        
  left outer join tClUbigeoCNBVLocalidades cl with(nolock) on cl.codlocalidadlargo=ce.codlocalidadsiti        
  where ca.fecha=@fecha and ca.cartera='ACTIVA' and ca.codoficina not in('97','230','231','999')       
  and ca.codproducto not in ('174') ---productos pepsico de prueba     
  and ca.codprestamo not in ('098-170-06-00-00006','098-170-06-01-00007','098-170-06-02-00008')  --- prestamo de pruebas Recicladores    
  and ca.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))        
) b        
group by municipio,estado,b.descripcion,codmunicipio        
        
------------- CONSOLIDADO SITI        
--select * from tClUbigeoCNBVEqui        
--select * from tClUbigeoCNBVEstMuni        
--select * from tClUbigeoCNBVLocalidades        
        
----SELECT  * FROM tclubigeo        
----  --where codubigeo='302560'        
----  where codarbolconta = 'R000001000030000109002560'        
----  or codarbolconta = 'R000001000030000109'        
----  or codarbolconta = 'R000001000030'        
          
----  SELECT  * FROM tclubigeo        
----  where codubigeotipo='ESTA' and codestado='30' 
GO

GRANT EXECUTE ON [dbo].[pCsRegCreditoxMunSiti] TO [rie_sbravoa]
GO

GRANT EXECUTE ON [dbo].[pCsRegCreditoxMunSiti] TO [rie_ldomingueze]
GO

GRANT EXECUTE ON [dbo].[pCsRegCreditoxMunSiti] TO [rie_jalvarezc]
GO