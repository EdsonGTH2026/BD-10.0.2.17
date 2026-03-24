SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAAdmPagosSaldos] @fecha smalldatetime
as
----declare @fecha smalldatetime
----set @fecha='20170105'

--create table #tca(
--	codprestamo varchar(25),
--	prestamoid varchar(25),
--	codserviciop varchar(25)
--)
--insert into #tca (codprestamo,prestamoid,codserviciop)
--select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100

--select @fecha fecha ,Descripcion,Sucursales
--,sum(D0saldo) D0saldo --1000000
--,(sum(D0saldo)/sum(t_saldo))*100 Mora0
--,sum(D1a30saldo) D1a30saldo--/1000000
--,(sum(D1a30saldo)/sum(t_saldo))*100 Mora30
--,sum(D31a60saldo) D31a60saldo--/1000000
--,(sum(D31a60saldo)/sum(t_saldo))*100 Mora60
--,sum(D61a89saldo) D61a89saldo--/1000000
--,(sum(D61a89saldo)/sum(t_saldo))*100 Mora89
--,sum(Dm90saldo) Dm90saldo--/1000000
--,sum(t_saldo) saldocartera--/1000000
--,(sum(Dm90saldo)/sum(t_saldo))*100 IMOR


--,sum(totalreserva) totalreserva
----,sum(colocacion) colocacion

--,sum(D0Reserva) D0Reserva
--,sum(D1a30Reserva) D1a30Reserva
--,sum(D31a60Reserva) D31a60Reserva
--,sum(D61a89Reserva) D61a89Reserva
--,sum(Dm90Reserva) Dm90Reserva
--,sum(Dm90Reserva_239) Dm90Reserva_239
--,sum(Dm90Reserva_m240) Dm90Reserva_m240

--into #saldos
--from (
--  SELECT c.codprestamo
--  ,case when c.codoficina<100 then 'FinAmigo' else 'Alta' end Sucursales
--  ,case when c.codproducto in(169,170) then 'FinAmigo Productivo' 
--				else pc.Nombreprod end Descripcion
--  ,cd.codusuario
--  ,case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end t_saldo

--	,case when c.NroDiasAtraso>0
--    then 
--		case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end
--    else 0 end DM1saldo

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso=0 then cd.codusuario else null end
--   else null end D0nroclie
--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso=0
--    then --cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
--		case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end
--    else 0 end
--   else 0 end D0saldo

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=30 then cd.codusuario else null end
--   else null end D1a30nroclie
--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=30
--    then --cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
--		case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end
--    else 0 end 
--   else 0 end D1a30saldo

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codusuario else null end
--   else null end D31a60nroclie
--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60
--    then --cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
--		case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end
--    else 0 end
--   else 0 end D31a60saldo

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codusuario else null end
--   else null end D61a89nroclie
--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90
--    then --cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
--		case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end
--    else 0 end 
--   else 0 end D61a89saldo

--  ,case when c.Estado='VENCIDO' then cd.codusuario else null end Dm90nroclie
--  ,case when c.Estado='VENCIDO' then --cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
--			case when c.codfondo=20 
--			 then (cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido)*0.3
--			 else cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido end
--    else 0 end Dm90saldo

-- ,EPRC_TOTAL totalreserva

--  ,case when c.fechadesembolso>='20160901' and c.fechadesembolso<='20160930' 
--  then 
--	case when c.codfondo=20 
--	then (cd.montodesembolso)*0.3
--	else cd.montodesembolso end
--  else 0 end colocacion

--/*CUBETAS POR RESERVAS*/

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso=0
--    then EPRC_TOTAL else 0 end
--   else 0 end D0Reserva

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=30
--    then EPRC_TOTAL else 0 end 
--   else 0 end D1a30Reserva

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60
--    then EPRC_TOTAL   else 0 end
--   else 0 end D31a60Reserva

--  ,case when c.Estado<>'VENCIDO' then
--    case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90
--    then EPRC_TOTAL else 0 end 
--   else 0 end D61a89Reserva

--  ,case when c.Estado='VENCIDO' then
--		EPRC_TOTAL
--    else 0 end Dm90Reserva
  
--  ,--case when c.Estado='VENCIDO' then
--		case when c.NroDiasAtraso<=239 then  
--				EPRC_TOTAL
--	    else 0 end
--    --else 0 end 
--	Dm90Reserva_239
--  ,case when c.Estado='VENCIDO' then
--		case when c.NroDiasAtraso>=240 then  
--				EPRC_TOTAL
--	    else 0 end
--    else 0 end Dm90Reserva_m240

--  FROM tCsCartera c with(nolock) 
--  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--  left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
--  inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
--  inner join tCsCarteraReserva r with(nolock) on r.codprestamo=cd.codprestamo and r.fecha=cd.fecha and r.codusuario=cd.codusuario
--  where c.cartera='ACTIVA' and c.fecha=@fecha and c.codoficina<>'97'
--  --c.fecha=@fecha and c.codoficina>100
--  and c.codprestamo not in (select codprestamo from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100 and estado='ANULADO')
--  and c.codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
--  --and c.codprestamo='133-169-06-06-00770'
--) a
--group by descripcion,Sucursales
--order by descripcion

--delete from tCsASaldosEstima where fecha=@fecha

--insert into tCsASaldosEstima
--values(@fecha,'Descripcion','Origen','D0saldo','Mora0','D1a30saldo','Mora30','D31a60saldo','Mora60','D61a89saldo','Mora89','Dm90saldo','saldocartera','IMOR','totalreserva','D0Reserva','D1a30Reserva','D31a60Reserva','D61a89Reserva','Dm90Reserva','Dm90Reser
--va_239','Dm90Reserva_m240')

--insert into tCsASaldosEstima
--select fecha,descripcion,sucursales
--,rtrim(ltrim(str(D0saldo,20,2))) D0saldo,rtrim(ltrim(str(Mora0,20,2))) Mora0,rtrim(ltrim(str(D1a30saldo,20,2))) D1a30saldo,rtrim(ltrim(str(Mora30,20,2))) Mora30,rtrim(ltrim(str(D31a60saldo,20,2))) D31a60saldo
--,rtrim(ltrim(str(Mora60,20,2))) Mora60,rtrim(ltrim(str(D61a89saldo,20,2))) D61a89saldo,rtrim(ltrim(str(Mora89,20,2))) Mora89,rtrim(ltrim(str(Dm90saldo,20,2))) Dm90saldo
--,rtrim(ltrim(str(saldocartera,20,2))) saldocartera,rtrim(ltrim(str(IMOR,20,2))) IMOR,rtrim(ltrim(str(totalreserva,20,2))) totalreserva,rtrim(ltrim(str(D0Reserva,20,2))) D0Reserva
--,rtrim(ltrim(str(D1a30Reserva,20,2))) D1a30Reserva,rtrim(ltrim(str(D31a60Reserva,20,2))) D31a60Reserva,rtrim(ltrim(str(D61a89Reserva,20,2))) D61a89Reserva
--,rtrim(ltrim(str(Dm90Reserva,20,2))) Dm90Reserva,rtrim(ltrim(str(Dm90Reserva_239,20,2))) Dm90Reserva_239,rtrim(ltrim(str(Dm90Reserva_m240,20,2))) Dm90Reserva_m240
--from #saldos

--drop table #tca
--drop table #saldos

--insert into tCsASaldosEstima values(@fecha,'','','','','','','','','','','','','','','','','','','','','')
--insert into tCsASaldosEstima values(@fecha,'','','','','','','','','','','','','','','','','','','','','')

--create table #t (fechapago smalldatetime, montototal money,capital money,interes money,iva money,seguro money, seguro2 money,pagta money,moratorio money, ivamoratorio money, cargoxmora money,ivacargoxmora money, otros money)
--insert into #t execute [10.0.2.14].finmas.dbo.pCaPagosFechasRes @fecha,@fecha--'20170105','20170105'--

--insert into tCsASaldosEstima (fecha,A,B,C,D,E,F,G,H,I,J,K,L) values(@fecha,'montototal','capital','interes','iva','seguro','seguro2','PAGTA','Moratorio','IVAMoratorio','CargoxMora','IVACargoxMora','Otros')

--insert into tCsASaldosEstima (fecha,A,B,C,D,E,F,G,H,I,J,K,L)
--select fechapago,ltrim(rtrim(str(montototal,20,2))) montototal
--,ltrim(rtrim(str(capital,20,2))) capital,ltrim(rtrim(str(interes,20,2))) interes,ltrim(rtrim(str(iva,20,2))) iva,ltrim(rtrim(str(seguro,20,2))) seguro
--,ltrim(rtrim(str(seguro2,20,2))) seguro2,ltrim(rtrim(str(pagta,20,2))) pagta,ltrim(rtrim(str(moratorio,20,2))) moratorio,ltrim(rtrim(str(ivamoratorio,20,2))) ivamoratorio
--,ltrim(rtrim(str(cargoxmora,20,2))) cargoxmora,ltrim(rtrim(str(ivacargoxmora,20,2))) ivacargoxmora,ltrim(rtrim(str(otros,20,2))) otros
--from #t

--drop table #t

GO