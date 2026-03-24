SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaClientesxCorte] @fecha smalldatetime,@fecini smalldatetime,@fecfin smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20180731'

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20180701'
--set @fecfin='20180731'

--drop table #tca
create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where (codoficina>100 and codoficina<300) and codoficina not in('97','230','231')

--drop table #ptmos
create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
and fechadesembolso>=@fecini and fechadesembolso<=@fecfin

select c.fecha,c.codprestamo,cl.nombrecompleto
,case when isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri) is null then ''--o.direccion 
		else isnull(cl.direcciondirfampri,cl.direcciondirnegpri)
+' ' +case when NumExtFam is null or rtrim(ltrim(NumExtFam))=''
	  then (case when NumExtNeg is null or ltrim(rtrim(NumExtNeg))='' 
										or rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtNeg,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'
EDIF',''),'*',''),'|',''),'#','')))='sn'
				 then 'S/N' 
				 else 
					case when substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtNeg,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),
'LOTE',''),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5) ='' then
						'S/N' 
					else
						substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtNeg,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''
),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5)
					end 
				 end)
	  when rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF'
,''),'*',''),'|',''),'#','')))='sn' 
			or rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE',''),'EDIF','
'),'*',''),'|',''),'#','')))='SINNUMERO' 
			then 'S/N'
	  else 
		case when substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LO
TE',''),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5)=''
		then 'S/N'
		else substring(rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(NumExtFam,'_',''),'-',''),'MZ',''),'.',''),':',''),' ',''),'INT',''),'BIS',''),'DEP',''),'LT',''),'LOTE','
'),'EDIF',''),'*',''),'|',''),'#',''))) ,1,5) end 
	  end
+ ',CP ' + isnull(u.campo1,'') --codpostal --19--,o.codpostal
+ ', ' + isnull(u.descubigeo,'') --'Colonia' --18
+ ', ' + isnull(mu.descubigeo,'') --'Municipio' --22
+ ', ' + isnull(es.descubigeo,'') --'Estado' --21
end
as domicilio
,isnull(isnull(cl.telefonodirfampri,cl.telefonodirnegpri),'') telefono
--,c.fechadesembolso
,cl.fechanacimiento
,cl.usRFC RFC_capturado
,cl.usrfcbd RFC_calculado
,cl.uscurp CURP_capturado
,cl.uscurpbd CURP_calculado
from tcscartera c with(nolock)
inner join tcspadronclientes cl with(nolock) on c.codusuario=cl.codusuario
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)--isnull(,o.codubigeo)
left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
where c.fecha=@fecha--'20180630'
and c.cartera='ACTIVA'
and c.codprestamo in(select codprestamo from #ptmos)

drop table #ptmos
drop table #tca
--23211
GO