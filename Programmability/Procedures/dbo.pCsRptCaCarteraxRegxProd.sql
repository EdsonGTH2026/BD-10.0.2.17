SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE procedure [dbo].[pCsRptCaCarteraxRegxProd] @fecha smalldatetime
as

--declare @fecha as smalldatetime
--set @fecha ='20140723'


select porproductozonas.tipo, 
           porproductozonas.nombrezona,
		   porproductozonas.codproducto,
		   porproductozonas.nombreprod,
		   sum(porproductozonas.#clientes)#clientes,
		   sum(porproductozonas.#prestamos)#prestamos,
           sum(montodesembolsado)montodesembolsado,
           sum(saldocartera)saldocartera,
            sum(porproductozonas.#clientessana)#clientessana,
		   sum(porproductozonas.#prestamossana)#prestamossana,
           sum(porproductozonas.saldocarterasana)saldocarterasana,
           sum(porproductozonas.porcentaje_sana)porcentaje_sana,
            sum(porproductozonas.#clientes1a7)#clientes1a7,
           sum(porproductozonas.#prestamos1a7)#prestamos1a7,
           sum(porproductozonas.saldocartera1a7)saldocartera1a7,
           sum(porproductozonas.porcentaje_de1a7)porcentaje_de1a7,
           sum(porproductozonas.#clientes8a15)#clientes8a15,
           sum(porproductozonas.#prestamos8a15)#prestamos8a15,
           sum(porproductozonas.saldocartera8a15)saldocartera8a15,
           sum(porproductozonas.porcentaje_de8a15)porcentaje_de8a15,
           sum(porproductozonas.#clientes16a30)#clientes16a30,
           sum(porproductozonas.#prestamos16a30)#prestamos16a30,
           sum(porproductozonas.saldocartera16a30)saldocartera16a30,
           sum(porproductozonas.porcentaje_de16a30)porcentaje_de16a30,
           sum(porproductozonas.#clientes31a60)#clientes31a60,
           sum(porproductozonas.#prestamos31a60)#prestamos31a60,
           sum(porproductozonas.saldocartera31a60)saldocartera31a60,
           sum(porproductozonas.porcentaje_de31a60)porcentaje_de31a60,
           sum(porproductozonas.#clientes61a89)#clientes61a89,
           sum(porproductozonas.#prestamos61a89)#prestamos61a89,
           sum(porproductozonas.saldocartera61a89)saldocartera61a89,
           sum(porproductozonas.porcentaje_de61a89)porcentaje_de61a89,
           sum(porproductozonas.#clientesmayor90)#clientesmayor90,
           sum(porproductozonas.#prestamosmayor90)#prestamosmayor90,
           sum(porproductozonas.saldocarteramayor90)saldocarteramayor90,		
           sum(porproductozonas.porcentaje_mayor90)porcentaje_mayor9 	

 from (
select   tipo,
			porproducto.codoficina,
			porproducto.zona,
			porproducto.nombrezona,
			porproducto.nomoficina,
			porproducto.codproducto,
			porproducto.nombreprod,
			count(distinct porproducto.codusuario)#clientes,
			count(distinct porproducto.codprestamo)#prestamos,
			sum(porproducto.montodesembolso) montodesembolsado,
			sum(porproducto.saldocartera) saldocartera,
			count(distinct porproducto.clientessana) #clientessana,
			count(distinct porproducto.prestamossana)  #prestamossana,
			sum(porproducto.saldocarterasana) saldocarterasana,
			case when sum(porproducto.saldocarterasana)=0 then (sum(porproducto.saldocarterasana)/1)*100 else (sum(porproducto.saldocarterasana)/sum(porproducto.saldocartera))*100 end  porcentaje_sana,
			count(distinct porproducto.clientesde1a7) #clientes1a7,
			count(distinct prestamosde1a7) #prestamos1a7,
			sum(porproducto.saldocarterade1a7) saldocartera1a7,
			case when sum(porproducto.saldocarterade1a7)=0 then (sum(porproducto.saldocarterade1a7)/1)*100 else (sum(porproducto.saldocarterade1a7)/sum(porproducto.saldocartera))*100 end  porcentaje_de1a7,
			(sum(porproducto.saldocarterasana)/1)*100 porcentajesana,
			count(distinct porproducto.clientesde8a15) #clientes8a15,
			count(distinct prestamosde8a15) #prestamos8a15,
			sum(porproducto.saldocarterade8a15) saldocartera8a15,
			case when sum(porproducto.saldocarterade8a15)=0 then (sum(porproducto.saldocarterade8a15)/1)*100 else (sum(porproducto.saldocarterade8a15)/sum(porproducto.saldocartera))*100 end  porcentaje_de8a15,
			count(distinct porproducto.clientesde16a30) #clientes16a30,
			count(distinct prestamosde16a30) #prestamos16a30,
			sum(porproducto.saldocarterade16a30) saldocartera16a30,
			case when sum(porproducto.saldocarterade16a30)=0 then (sum(porproducto.saldocarterade16a30)/1)*100 else (sum(porproducto.saldocarterade16a30)/sum(porproducto.saldocartera))*100 end  porcentaje_de16a30,
			count(distinct porproducto.clientesde31a60) #clientes31a60,
			count(distinct prestamosde31a60) #prestamos31a60,
			sum(porproducto.saldocarterade31a60) saldocartera31a60,
			case when sum(porproducto.saldocarterade31a60)=0 then (sum(porproducto.saldocarterade31a60)/1)*100 else (sum(porproducto.saldocarterade31a60)/sum(porproducto.saldocartera))*100 end  porcentaje_de31a60,
			count(distinct porproducto.clientesde61a89) #clientes61a89,
			count(distinct prestamosde61a89) #prestamos61a89,
			sum(porproducto.saldocarterade61a89) saldocartera61a89,
			case when sum(porproducto.saldocarterade61a89)=0 then (sum(porproducto.saldocarterade61a89)/1)*100 else (sum(porproducto.saldocarterade61a89)/sum(porproducto.saldocartera))*100 end  porcentaje_de61a89,
			count(distinct porproducto.clientesmayor90) #clientesmayor90,
			count(distinct prestamosmayor90) #prestamosmayor90,
			sum(porproducto.saldocarteramayor90) saldocarteramayor90,
			case when sum(porproducto.saldocarteramayor90)=0 then (sum(porproducto.saldocarteramayor90)/1)*100 else (sum(porproducto.saldocarteramayor90)/sum(porproducto.saldocartera))*100 end  porcentaje_mayor90
				
			
 from (
select case when ofi.tipo='Cerrada' then 'CERRADAS' ELSE 'ACTIVAS' END tipo,
cd.codoficina,z.zona,z.nombre nombrezona,ofi.nomoficina,c.codproducto,prod.nombreprod,cd.codusuario,cd.codprestamo,cd.montodesembolso,
cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera,
case when c.nrodiasatraso=0 and c.Estado<>'VENCIDO' then cd.codusuario else null end clientessana,
case when c.nrodiasatraso=0 and c.Estado<>'VENCIDO' then cd.codprestamo else null end prestamossana,
case when c.nrodiasatraso=0 and c.Estado<>'VENCIDO' then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarterasana,
case when c.nrodiasatraso >=1  and c.nrodiasatraso <=7 and c.Estado<> 'VENCIDO' then  cd.codusuario  else null end clientesde1a7,
case when c.nrodiasatraso >=1 and c.nrodiasatraso <=7 and c.Estado<>'VENCIDO' then c.codprestamo else null end prestamosde1a7,
case when c.nrodiasatraso >=1  and c.nrodiasatraso <=7 and c.Estado<>'VENCIDO' then  cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarterade1a7,
case when c.nrodiasatraso >=8  and c.nrodiasatraso <=15 and c.Estado<>'VENCIDO' then  cd.codusuario  else null end clientesde8a15,
case when c.nrodiasatraso >=8 and c.nrodiasatraso <=15 and c.Estado<>'VENCIDO' then c.codprestamo else null end prestamosde8a15,
case when c.nrodiasatraso >=8  and c.nrodiasatraso <=15 and c.Estado<>'VENCIDO' then  cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarterade8a15,
case when c.nrodiasatraso >=16  and c.nrodiasatraso <=30 and  c.Estado<>'VENCIDO' then  cd.codusuario  else null end clientesde16a30,
case when c.nrodiasatraso >=16 and c.nrodiasatraso <=30 and c.Estado<>'VENCIDO' then c.codprestamo else null end prestamosde16a30,
case when c.nrodiasatraso >=16  and c.nrodiasatraso <=30 and c.Estado<>'VENCIDO' then  cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarterade16a30,
case when c.nrodiasatraso >=31  and c.nrodiasatraso <=60 and c.Estado<>'VENCIDO' then  cd.codusuario  else null end clientesde31a60,
case when c.nrodiasatraso >=31 and c.nrodiasatraso <=60 and c.Estado<>'VENCIDO' then c.codprestamo else null end prestamosde31a60,
case when c.nrodiasatraso >=31  and c.nrodiasatraso <=60 and c.Estado<>'VENCIDO' then  cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarterade31a60,
case when c.nrodiasatraso >=61  and c.nrodiasatraso <=89 and c.Estado<>'VENCIDO' then  cd.codusuario  else null end clientesde61a89,
case when c.nrodiasatraso >=61 and c.nrodiasatraso <=89 and c.Estado<>'VENCIDO' then c.codprestamo else null end prestamosde61a89,
case when c.nrodiasatraso >=61  and c.nrodiasatraso <=89 and c.Estado<>'VENCIDO' then  cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarterade61a89,
case when c.nrodiasatraso > 90 and c.Estado='VENCIDO' then  cd.codusuario  else null end clientesmayor90,
case when c.nrodiasatraso > 90 and c.Estado='VENCIDO' then c.codprestamo else null end prestamosmayor90,
case when c.nrodiasatraso > 90 and c.Estado='VENCIDO' then  cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldocarteramayor90
from  tcscartera c with(nolock)
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
left  join tcloficinas ofi with(nolock) on ofi.codoficina=c.codoficina and ofi.tipo<>'Cerrada'
left join tcaproducto prod with(nolock) on prod.codproducto=c.codproducto
left join  tclzona z  with(nolock) on z.zona=ofi.zona
where c.fecha=@fecha and c.cartera='ACTIVA' and c.codoficina<99
) porproducto
group by porproducto.codproducto,porproducto.codoficina,porproducto.nomoficina,porproducto.nombreprod,porproducto.zona,porproducto.nombrezona,porproducto.tipo
) porproductozonas
group by porproductozonas.nombrezona,porproductozonas.codproducto,porproductozonas.nombreprod,porproductozonas.tipo







GO