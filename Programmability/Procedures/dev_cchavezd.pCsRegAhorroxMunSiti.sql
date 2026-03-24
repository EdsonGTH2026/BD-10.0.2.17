SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pCsRegAhorroxMunSiti '20220630'      
CREATE procedure [dev_cchavezd].[pCsRegAhorroxMunSiti] @fec smalldatetime      
as      
declare @fecha smalldatetime      
set @fecha=@fec--'20220630'--      
      
select @fecha Fecha,'Financiera Mexicana Para el Desarrollo Rural S.A. de C.V. SFP' Entidad      
,Municipio      
,Estado      
,codmunicipio      
,count(b.codcuenta) NroCuentas, sum(b.saldocuenta) saldocuenta, b.tipo       
from(      
  SELECT ah.codcuenta,ah.renovado--,ah.codusuario      
  ,case when substring(ah.codcuenta,5,3)='209' then c2.saldofinal else ah.saldocuenta + ah.intacumulado end saldocuenta      
  --,case when idTipoProd=1 then 'A LA VISTA' else 'DPF' end Tipo      
  ,case when substring(ah.codcuenta,5,1)='1' then 'A LA VISTA' else 'DPF' end Tipo      
  ,o.codubigeo codubigeoofi      
  ,cl.municipio,cl.estado      
  ,replicate('0',2-len(cl.codestado))+cl.codestado+replicate('0',3-len(cl.codmunicipio))+cl.codmunicipio codmunicipio      
  FROM tCsAhorros ah with(nolock)       
  left outer join tcspadronclientes c with(nolock) on c.codusuario=ah.codusuario      
  inner join tcloficinas o with(nolock) on o.codoficina=ah.codoficina      
  --inner join tAhProductos p with(nolock) on p.idproducto=ah.codproducto         
  --left outer join tClUbigeoCNBVEqui ce with(nolock) on ce.codubigeo=isnull(isnull(c.codubigeodirfampri,c.codubigeodirnegpri),o.codubigeo)      
  left outer join tClUbigeoCNBVEqui ce with(nolock) on ce.codubigeo=(case when ah.codcuenta in('098-105-06-2-3-00244'---- 2024      
              ) then o.codubigeo else isnull(isnull(c.codubigeodirfampri,c.codubigeodirnegpri),o.codubigeo)end)          
  left outer join tClUbigeoCNBVLocalidades cl with(nolock) on cl.codlocalidadlargo=ce.codlocalidadsiti      
  left outer join       
  --(      
  -- select '098-209-06-2-9-00009' codcuenta,0 renovado,197728.07 saldofinal union      
  -- select '098-209-06-2-2-00004' codcuenta,0 renovado,64711.55 saldofinal union      
  -- select '098-209-06-2-6-00006' codcuenta,0 renovado,103318.77 saldofinal union      
  -- select '098-209-06-2-7-00007' codcuenta,0 renovado,103318.77 saldofinal union      
  -- select '098-209-06-2-0-00010' codcuenta,0 renovado,99127.76 saldofinal union      
  -- select '098-209-06-2-8-00008' codcuenta,0 renovado,103318.77 saldofinal      
  --)       
  tCsAhorros209 c2 on ah.codcuenta=c2.codcuenta and c2.renovado=ah.renovado and c2.fecha=@fecha      
  where ah.fecha=@fecha      
 and ah.codcuenta not in(  -->ctas pepsico  
	'098-105-06-2-9-00239',
	'098-105-06-2-0-00241',
	'098-105-06-2-6-00238',
	'098-105-06-2-7-00248',--cuenta de prueba
	'098-111-06-2-0-00001',--cuenta de prueba
	'098-105-06-2-0-00249'--cuenta de prueba 
)) b   
     
group by municipio,estado,b.tipo,codmunicipio      
      
--insert into tCsAhorros209      
--select '20220630' fecha,'098-209-06-2-9-00009' codcuenta,0 renovado,197728.07 saldofinal union      
--select '20220630' fecha,'098-209-06-2-2-00004' codcuenta,0 renovado,64711.55 saldofinal union      
--select '20220630' fecha,'098-209-06-2-6-00006' codcuenta,0 renovado,103318.77 saldofinal union      
--select '20220630' fecha,'098-209-06-2-7-00007' codcuenta,0 renovado,103318.77 saldofinal union      
--select '20220630' fecha,'098-209-06-2-0-00010' codcuenta,0 renovado,99127.76 saldofinal union      
--select '20220630' fecha,'098-209-06-2-8-00008' codcuenta,0 renovado,103318.77 saldofinal 
GO