SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCARptCartaCERSucursalDet
create procedure [dbo].[pCsCARptCartaCERSucursalDet] @fecha smalldatetime,@codoficina varchar(4)
as
--declare @fecha smalldatetime
--declare @codoficina varchar(4)
--set @fecha='20160430'
--set @codoficina=31

CREATE TABLE #CER4(
	[codoficina] [varchar](4) NULL,
	[promotor] [varchar](15) NULL,
	[coordinador] [varchar](300) NOT NULL,
	[SC0114] [decimal](16, 4) NULL,
	[De0114] [decimal](16, 4) NULL,
	[Nc0114] [int] NULL,
	[SC0214] [decimal](16, 4) NULL,
	[De0214] [decimal](16, 4) NULL,
	[Nc0214] [int] NULL,
	[SC0314] [decimal](16, 4) NULL,
	[De0314] [decimal](16, 4) NULL,
	[Nc0314] [int] NULL,
	[SC0414] [decimal](16, 4) NULL,
	[De0414] [decimal](16, 4) NULL,
	[Nc0414] [int] NULL,
	[SC0514] [decimal](16, 4) NULL,
	[De0514] [decimal](16, 4) NULL,
	[Nc0514] [int] NULL,
	[SC0614] [decimal](16, 4) NULL,
	[De0614] [decimal](16, 4) NULL,
	[Nc0614] [int] NULL,
	[SC0714] [decimal](16, 4) NULL,
	[De0714] [decimal](16, 4) NULL,
	[Nc0714] [int] NULL,
	[SC0814] [decimal](16, 4) NULL,
	[De0814] [decimal](16, 4) NULL,
	[Nc0814] [int] NULL,
	[SC0914] [decimal](16, 4) NULL,
	[De0914] [decimal](16, 4) NULL,
	[Nc0914] [int] NULL,
	[SC1014] [decimal](16, 4) NULL,
	[De1014] [decimal](16, 4) NULL,
	[Nc1014] [int] NULL,
	[SC1114] [decimal](16, 4) NULL,
	[De1114] [decimal](16, 4) NULL,
	[Nc1114] [int] NULL,
	[SC1214] [decimal](16, 4) NULL,
	[De1214] [decimal](16, 4) NULL,
	[Nc1214] [int] NULL,
	[SC0115] [decimal](16, 4) NULL,
	[De0115] [decimal](16, 4) NULL,
	[Nc0115] [int] NULL,
	[SC0215] [decimal](16, 4) NULL,
	[De0215] [decimal](16, 4) NULL,
	[Nc0215] [int] NULL,
	[SC0315] [decimal](16, 4) NULL,
	[De0315] [decimal](16, 4) NULL,
	[Nc0315] [int] NULL,
	[SC0415] [decimal](16, 4) NULL,
	[De0415] [decimal](16, 4) NULL,
	[Nc0415] [int] NULL,
	[SC0515] [decimal](16, 4) NULL,
	[De0515] [decimal](16, 4) NULL,
	[Nc0515] [int] NULL,
	[SC0615] [decimal](16, 4) NULL,
	[De0615] [decimal](16, 4) NULL,
	[Nc0615] [int] NULL,
	[SC0715] [decimal](16, 4) NULL,
	[De0715] [decimal](16, 4) NULL,
	[Nc0715] [int] NULL,
	[SC0815] [decimal](16, 4) NULL,
	[De0815] [decimal](16, 4) NULL,
	[Nc0815] [int] NULL,
	[SC0915] [decimal](16, 4) NULL,
	[De0915] [decimal](16, 4) NULL,
	[Nc0915] [int] NULL,
	[SC1015] [decimal](16, 4) NULL,
	[De1015] [decimal](16, 4) NULL,
	[Nc1015] [int] NULL,
	[SC1115] [decimal](16, 4) NULL,
	[De1115] [decimal](16, 4) NULL,
	[Nc1115] [int] NULL,
	[SC1215] [decimal](16, 4) NULL,
	[De1215] [decimal](16, 4) NULL,
	[Nc1215] [int] NULL,
	[SC0116] [decimal](16, 4) NULL,
	[De0116] [decimal](16, 4) NULL,
	[Nc0116] [int] NULL,
	[SC0216] [decimal](16, 4) NULL,
	[De0216] [decimal](16, 4) NULL,
	[Nc0216] [int] NULL,
	[SC0316] [decimal](16, 4) NULL,
	[De0316] [decimal](16, 4) NULL,
	[Nc0316] [int] NULL,
	[SC0416] [decimal](16, 4) NULL,
	[De0416] [decimal](16, 4) NULL,
	[Nc0416] [int] NULL,
	[SC0516] [decimal](16, 4) NULL,
	[De0516] [decimal](16, 4) NULL,
	[Nc0516] [int] NULL,
	[SC0616] [decimal](16, 4) NULL,
	[De0616] [decimal](16, 4) NULL,
	[Nc0616] [int] NULL,
	[SC0716] [decimal](16, 4) NULL,
	[De0716] [decimal](16, 4) NULL,
	[Nc0716] [int] NULL,
	[SC0816] [decimal](16, 4) NULL,
	[De0816] [decimal](16, 4) NULL,
	[Nc0816] [int] NULL,
	[SC0916] [decimal](16, 4) NULL,
	[De0916] [decimal](16, 4) NULL,
	[Nc0916] [int] NULL,
	[SC1016] [decimal](16, 4) NULL,
	[De1016] [decimal](16, 4) NULL,
	[Nc1016] [int] NULL,
	[SC1116] [decimal](16, 4) NULL,
	[De1116] [decimal](16, 4) NULL,
	[Nc1116] [int] NULL,
	[SC1216] [decimal](16, 4) NULL,
	[De1216] [decimal](16, 4) NULL,
	[Nc1216] [int] NULL
) 
insert into #CER4
select a.codoficina,promotor,isnull(pr.nombrecompleto,'HUERFANO') coordinador
,sum(SC0114) SC0114,sum(De0114) De0114,count(Nc0114) Nc0114,sum(SC0214) SC0214,sum(De0214) De0214,count(Nc0214) Nc0214
,sum(SC0314) SC0314,sum(De0314) De0314,count(Nc0314) Nc0314,sum(SC0414) SC0414,sum(De0414) De0414,count(Nc0414) Nc0414
,sum(SC0514) SC0514,sum(De0514) De0514,count(Nc0514) Nc0514,sum(SC0614) SC0614,sum(De0614) De0614,count(Nc0614) Nc0614
,sum(SC0714) SC0714,sum(De0714) De0714,count(Nc0714) Nc0714,sum(SC0814) SC0814,sum(De0814) De0814,count(Nc0814) Nc0814
,sum(SC0914) SC0914,sum(De0914) De0914,count(Nc0914) Nc0914,sum(SC1014) SC1014,sum(De1014) De1014,count(Nc1014) Nc1014
,sum(SC1114) SC1114,sum(De1114) De1114,count(Nc1114) Nc1114,sum(SC1214) SC1214,sum(De1214) De1214,count(Nc1214) Nc1214

,sum(SC0115) SC0115,sum(De0115) De0115,count(Nc0115) Nc0115,sum(SC0215) SC0215,sum(De0215) De0215,count(Nc0215) Nc0215
,sum(SC0315) SC0315,sum(De0315) De0315,count(Nc0315) Nc0315,sum(SC0415) SC0415,sum(De0415) De0415,count(Nc0415) Nc0415
,sum(SC0515) SC0515,sum(De0515) De0515,count(Nc0515) Nc0515,sum(SC0615) SC0615,sum(De0615) De0615,count(Nc0615) Nc0615
,sum(SC0715) SC0715,sum(De0715) De0715,count(Nc0715) Nc0715,sum(SC0815) SC0815,sum(De0815) De0815,count(Nc0815) Nc0815
,sum(SC0915) SC0915,sum(De0915) De0915,count(Nc0915) Nc0915,sum(SC1015) SC1015,sum(De1015) De1015,count(Nc1015) Nc1015
,sum(SC1115) SC1115,sum(De1115) De1115,count(Nc1115) Nc1115,sum(SC1215) SC1215,sum(De1215) De1215,count(Nc1215) Nc1215

,sum(SC0116) SC0116,sum(De0116) De0116,count(Nc0116) Nc0116,sum(SC0216) SC0216,sum(De0216) De0216,count(Nc0216) Nc0216
,sum(SC0316) SC0316,sum(De0316) De0316,count(Nc0316) Nc0316,sum(SC0416) SC0416,sum(De0416) De0416,count(Nc0416) Nc0416
,sum(SC0516) SC0516,sum(De0516) De0516,count(Nc0516) Nc0516,sum(SC0616) SC0616,sum(De0616) De0616,count(Nc0616) Nc0616
,sum(SC0716) SC0716,sum(De0716) De0716,count(Nc0716) Nc0716,sum(SC0816) SC0816,sum(De0816) De0816,count(Nc0816) Nc0816
,sum(SC0916) SC0916,sum(De0916) De0916,count(Nc0916) Nc0916,sum(SC1016) SC1016,sum(De1016) De1016,count(Nc1016) Nc1016
,sum(SC1116) SC1116,sum(De1116) De1116,count(Nc1116) Nc1116,sum(SC1216) SC1216,sum(De1216) De1216,count(Nc1216) Nc1216
--into _CER4tmp
from (
SELECT 
case when epd.estado=1 then
			case when c.codoficina=(case when epd.codoficinanom=98 then 42 else epd.codoficinanom end) then pd.primerasesor
			else 
				case when c.codoficina<>(case when e.codoficinanom=98 then 42 else e.codoficinanom end) then 'HUERFANO'
					 else case when e.estado=1 then c.codasesor else 'HUERFANO' end
					 end
			end
	else
		case when c.codoficina<>(case when e.codoficinanom=98 then 42 else e.codoficinanom end) then 'HUERFANO'
			 else case when e.estado=1 then c.codasesor else 'HUERFANO' end
			 end
	end  promotor
,c.codoficina
,case when c.fechadesembolso>='20140101' and c.fechadesembolso<='20140131' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0114
,case when c.fechadesembolso>='20140101' and c.fechadesembolso<='20140131' then d.montodesembolso else 0 end De0114
,case when c.fechadesembolso>='20140101' and c.fechadesembolso<='20140131' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0114

,case when c.fechadesembolso>='20140201' and c.fechadesembolso<='20140228' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0214
,case when c.fechadesembolso>='20140201' and c.fechadesembolso<='20140228' then d.montodesembolso else 0 end De0214
,case when c.fechadesembolso>='20140201' and c.fechadesembolso<='20140228' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0214

,case when c.fechadesembolso>='20140301' and c.fechadesembolso<='20140331' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0314
,case when c.fechadesembolso>='20140301' and c.fechadesembolso<='20140331' then d.montodesembolso else 0 end De0314
,case when c.fechadesembolso>='20140301' and c.fechadesembolso<='20140331' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0314

,case when c.fechadesembolso>='20140401' and c.fechadesembolso<='20140430' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0414
,case when c.fechadesembolso>='20140401' and c.fechadesembolso<='20140430' then d.montodesembolso else 0 end De0414
,case when c.fechadesembolso>='20140401' and c.fechadesembolso<='20140430' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0414

,case when c.fechadesembolso>='20140501' and c.fechadesembolso<='20140531' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0514
,case when c.fechadesembolso>='20140501' and c.fechadesembolso<='20140531' then d.montodesembolso else 0 end De0514
,case when c.fechadesembolso>='20140501' and c.fechadesembolso<='20140531' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0514

,case when c.fechadesembolso>='20140601' and c.fechadesembolso<='20140630' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0614
,case when c.fechadesembolso>='20140601' and c.fechadesembolso<='20140630' then d.montodesembolso else 0 end De0614
,case when c.fechadesembolso>='20140601' and c.fechadesembolso<='20140630' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0614

,case when c.fechadesembolso>='20140701' and c.fechadesembolso<='20140731' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0714
,case when c.fechadesembolso>='20140701' and c.fechadesembolso<='20140731' then d.montodesembolso else 0 end De0714
,case when c.fechadesembolso>='20140701' and c.fechadesembolso<='20140731' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0714

,case when c.fechadesembolso>='20140801' and c.fechadesembolso<='20140831' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0814
,case when c.fechadesembolso>='20140801' and c.fechadesembolso<='20140831' then d.montodesembolso else 0 end De0814
,case when c.fechadesembolso>='20140801' and c.fechadesembolso<='20140831' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0814

,case when c.fechadesembolso>='20140901' and c.fechadesembolso<='20140930' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0914
,case when c.fechadesembolso>='20140901' and c.fechadesembolso<='20140930' then d.montodesembolso else 0 end De0914
,case when c.fechadesembolso>='20140901' and c.fechadesembolso<='20140930' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0914

,case when c.fechadesembolso>='20141001' and c.fechadesembolso<='20141031' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1014
,case when c.fechadesembolso>='20141001' and c.fechadesembolso<='20141031' then d.montodesembolso else 0 end De1014
,case when c.fechadesembolso>='20141001' and c.fechadesembolso<='20141031' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1014

,case when c.fechadesembolso>='20141101' and c.fechadesembolso<='20141130' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1114
,case when c.fechadesembolso>='20141101' and c.fechadesembolso<='20141130' then d.montodesembolso else 0 end De1114
,case when c.fechadesembolso>='20141101' and c.fechadesembolso<='20141130' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1114

,case when c.fechadesembolso>='20141201' and c.fechadesembolso<='20141231' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1214
,case when c.fechadesembolso>='20141201' and c.fechadesembolso<='20141231' then d.montodesembolso else 0 end De1214
,case when c.fechadesembolso>='20141201' and c.fechadesembolso<='20141231' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1214
/*2015*/
,case when c.fechadesembolso>='20150101' and c.fechadesembolso<='20150131' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0115
,case when c.fechadesembolso>='20150101' and c.fechadesembolso<='20150131' then d.montodesembolso else 0 end De0115
,case when c.fechadesembolso>='20150101' and c.fechadesembolso<='20150131' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0115

,case when c.fechadesembolso>='20150201' and c.fechadesembolso<='20150228' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0215
,case when c.fechadesembolso>='20150201' and c.fechadesembolso<='20150228' then d.montodesembolso else 0 end De0215
,case when c.fechadesembolso>='20150201' and c.fechadesembolso<='20150228' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0215

,case when c.fechadesembolso>='20150301' and c.fechadesembolso<='20150331' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0315
,case when c.fechadesembolso>='20150301' and c.fechadesembolso<='20150331' then d.montodesembolso else 0 end De0315
,case when c.fechadesembolso>='20150301' and c.fechadesembolso<='20150331' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0315

,case when c.fechadesembolso>='20150401' and c.fechadesembolso<='20150430' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0415
,case when c.fechadesembolso>='20150401' and c.fechadesembolso<='20150430' then d.montodesembolso else 0 end De0415
,case when c.fechadesembolso>='20150401' and c.fechadesembolso<='20150430' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0415

,case when c.fechadesembolso>='20150501' and c.fechadesembolso<='20150531' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0515
,case when c.fechadesembolso>='20150501' and c.fechadesembolso<='20150531' then d.montodesembolso else 0 end De0515
,case when c.fechadesembolso>='20150501' and c.fechadesembolso<='20150531' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0515

,case when c.fechadesembolso>='20150601' and c.fechadesembolso<='20150630' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0615
,case when c.fechadesembolso>='20150601' and c.fechadesembolso<='20150630' then d.montodesembolso else 0 end De0615
,case when c.fechadesembolso>='20150601' and c.fechadesembolso<='20150630' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0615

,case when c.fechadesembolso>='20150701' and c.fechadesembolso<='20150731' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0715
,case when c.fechadesembolso>='20150701' and c.fechadesembolso<='20150731' then d.montodesembolso else 0 end De0715
,case when c.fechadesembolso>='20150701' and c.fechadesembolso<='20150731' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0715

,case when c.fechadesembolso>='20150801' and c.fechadesembolso<='20150831' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0815
,case when c.fechadesembolso>='20150801' and c.fechadesembolso<='20150831' then d.montodesembolso else 0 end De0815
,case when c.fechadesembolso>='20150801' and c.fechadesembolso<='20150831' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0815

,case when c.fechadesembolso>='20150901' and c.fechadesembolso<='20150930' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0915
,case when c.fechadesembolso>='20150901' and c.fechadesembolso<='20150930' then d.montodesembolso else 0 end De0915
,case when c.fechadesembolso>='20150901' and c.fechadesembolso<='20150930' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0915

,case when c.fechadesembolso>='20151001' and c.fechadesembolso<='20151031' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1015
,case when c.fechadesembolso>='20151001' and c.fechadesembolso<='20151031' then d.montodesembolso else 0 end De1015
,case when c.fechadesembolso>='20151001' and c.fechadesembolso<='20151031' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1015

,case when c.fechadesembolso>='20151101' and c.fechadesembolso<='20151130' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1115
,case when c.fechadesembolso>='20151101' and c.fechadesembolso<='20151130' then d.montodesembolso else 0 end De1115
,case when c.fechadesembolso>='20151101' and c.fechadesembolso<='20151130' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1115

,case when c.fechadesembolso>='20151201' and c.fechadesembolso<='20151231' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1215
,case when c.fechadesembolso>='20151201' and c.fechadesembolso<='20151231' then d.montodesembolso else 0 end De1215
,case when c.fechadesembolso>='20151201' and c.fechadesembolso<='20151231' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1215

/*2016*/
,case when c.fechadesembolso>='20160101' and c.fechadesembolso<='20160131' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0116
,case when c.fechadesembolso>='20160101' and c.fechadesembolso<='20160131' then d.montodesembolso else 0 end De0116
,case when c.fechadesembolso>='20160101' and c.fechadesembolso<='20160131' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0116

,case when c.fechadesembolso>='20160201' and c.fechadesembolso<='20160229' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0216
,case when c.fechadesembolso>='20160201' and c.fechadesembolso<='20160229' then d.montodesembolso else 0 end De0216
,case when c.fechadesembolso>='20160201' and c.fechadesembolso<='20160229' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0216

,case when c.fechadesembolso>='20160301' and c.fechadesembolso<='20160331' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0316
,case when c.fechadesembolso>='20160301' and c.fechadesembolso<='20160331' then d.montodesembolso else 0 end De0316
,case when c.fechadesembolso>='20160301' and c.fechadesembolso<='20160331' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0316

,case when c.fechadesembolso>='20160401' and c.fechadesembolso<='20160430' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0416
,case when c.fechadesembolso>='20160401' and c.fechadesembolso<='20160430' then d.montodesembolso else 0 end De0416
,case when c.fechadesembolso>='20160401' and c.fechadesembolso<='20160430' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0416

,case when c.fechadesembolso>='20160501' and c.fechadesembolso<='20160531' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0516
,case when c.fechadesembolso>='20160501' and c.fechadesembolso<='20160531' then d.montodesembolso else 0 end De0516
,case when c.fechadesembolso>='20160501' and c.fechadesembolso<='20160531' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0516

,case when c.fechadesembolso>='20160601' and c.fechadesembolso<='20160630' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0616
,case when c.fechadesembolso>='20160601' and c.fechadesembolso<='20160630' then d.montodesembolso else 0 end De0616
,case when c.fechadesembolso>='20160601' and c.fechadesembolso<='20160630' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0616

,case when c.fechadesembolso>='20160701' and c.fechadesembolso<='20160731' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0716
,case when c.fechadesembolso>='20160701' and c.fechadesembolso<='20160731' then d.montodesembolso else 0 end De0716
,case when c.fechadesembolso>='20160701' and c.fechadesembolso<='20160731' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0716

,case when c.fechadesembolso>='20160801' and c.fechadesembolso<='20160831' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0816
,case when c.fechadesembolso>='20160801' and c.fechadesembolso<='20160831' then d.montodesembolso else 0 end De0816
,case when c.fechadesembolso>='20160801' and c.fechadesembolso<='20160831' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0816

,case when c.fechadesembolso>='20160901' and c.fechadesembolso<='20160930' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC0916
,case when c.fechadesembolso>='20160901' and c.fechadesembolso<='20160930' then d.montodesembolso else 0 end De0916
,case when c.fechadesembolso>='20160901' and c.fechadesembolso<='20160930' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc0916

,case when c.fechadesembolso>='20161001' and c.fechadesembolso<='20161031' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1016
,case when c.fechadesembolso>='20161001' and c.fechadesembolso<='20161031' then d.montodesembolso else 0 end De1016
,case when c.fechadesembolso>='20161001' and c.fechadesembolso<='20161031' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1016

,case when c.fechadesembolso>='20161101' and c.fechadesembolso<='20161130' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1116
,case when c.fechadesembolso>='20161101' and c.fechadesembolso<='20161130' then d.montodesembolso else 0 end De1116
,case when c.fechadesembolso>='20161101' and c.fechadesembolso<='20161130' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1116

,case when c.fechadesembolso>='20161201' and c.fechadesembolso<='20161231' then d.saldocapital+d.interesvigente+d.interesvencido else 0 end SC1216
,case when c.fechadesembolso>='20161201' and c.fechadesembolso<='20161231' then d.montodesembolso else 0 end De1216
,case when c.fechadesembolso>='20161201' and c.fechadesembolso<='20161231' then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end Nc1216

FROM tCsCartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=d.codprestamo and pd.codusuario=d.codusuario
left outer join tcsempleados e with(nolock) on e.codusuario=c.codasesor
left outer join tcsempleados epd with(nolock) on epd.codusuario=pd.primerasesor
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=4 and c.codoficina=@codoficina
and c.codoficina<100

) a left outer join tcspadronclientes pr on pr.codusuario=a.promotor
group by promotor,a.codoficina,isnull(pr.nombrecompleto,'HUERFANO')

--select * from #CER4

CREATE TABLE #CerDesem(
	[codasesor] [varchar](15) NULL,
	codoficina varchar(4),
	[oDe0114] [decimal](16, 4) NULL,
	[oDe0214] [decimal](16, 4) NULL,
	[oDe0314] [decimal](16, 4) NULL,
	[oDe0414] [decimal](16, 4) NULL,
	[oDe0514] [decimal](16, 4) NULL,
	[oDe0614] [decimal](16, 4) NULL,
	[oDe0714] [decimal](16, 4) NULL,
	[oDe0814] [decimal](16, 4) NULL,
	[oDe0914] [decimal](16, 4) NULL,
	[oDe1014] [decimal](16, 4) NULL,
	[oDe1114] [decimal](16, 4) NULL,
	[oDe1214] [decimal](16, 4) NULL,
	[oDe0115] [decimal](16, 4) NULL,
	[oDe0215] [decimal](16, 4) NULL,
	[oDe0315] [decimal](16, 4) NULL,
	[oDe0415] [decimal](16, 4) NULL,
	[oDe0515] [decimal](16, 4) NULL,
	[oDe0615] [decimal](16, 4) NULL,
	[oDe0715] [decimal](16, 4) NULL,
	[oDe0815] [decimal](16, 4) NULL,
	[oDe0915] [decimal](16, 4) NULL,
	[oDe1015] [decimal](16, 4) NULL,
	[oDe1115] [decimal](16, 4) NULL,
	[oDe1215] [decimal](16, 4) NULL,
	[oDe0116] [decimal](16, 4) NULL,
	[oDe0216] [decimal](16, 4) NULL,
	[oDe0316] [decimal](16, 4) NULL,
	[oDe0416] [decimal](16, 4) NULL,
	[oDe0516] [decimal](16, 4) NULL,
	[oDe0616] [decimal](16, 4) NULL,
	[oDe0716] [decimal](16, 4) NULL,
	[oDe0816] [decimal](16, 4) NULL,
	[oDe0916] [decimal](16, 4) NULL,
	[oDe1016] [decimal](16, 4) NULL,
	[oDe1116] [decimal](16, 4) NULL,
	[oDe1216] [decimal](16, 4) NULL,

	[oNc0114] [int] NULL,
	[oNc0214] [int] NULL,
	[oNc0314] [int] NULL,
	[oNc0414] [int] NULL,
	[oNc0514] [int] NULL,
	[oNc0614] [int] NULL,
	[oNc0714] [int] NULL,
	[oNc0814] [int] NULL,
	[oNc0914] [int] NULL,
	[oNc1014] [int] NULL,
	[oNc1114] [int] NULL,
	[oNc1214] [int] NULL,
	[oNc0115] [int] NULL,
	[oNc0215] [int] NULL,
	[oNc0315] [int] NULL,
	[oNc0415] [int] NULL,
	[oNc0515] [int] NULL,
	[oNc0615] [int] NULL,
	[oNc0715] [int] NULL,
	[oNc0815] [int] NULL,
	[oNc0915] [int] NULL,
	[oNc1015] [int] NULL,
	[oNc1115] [int] NULL,
	[oNc1215] [int] NULL,
	[oNc0116] [int] NULL,
	[oNc0216] [int] NULL,
	[oNc0316] [int] NULL,
	[oNc0416] [int] NULL,
	[oNc0516] [int] NULL,
	[oNc0616] [int] NULL,
	[oNc0716] [int] NULL,
	[oNc0816] [int] NULL,
	[oNc0916] [int] NULL,
	[oNc1016] [int] NULL,
	[oNc1116] [int] NULL,
	[oNc1216] [int] NULL
)
insert into #CerDesem
select primerasesor,codoficina
,sum(De0114) De0114,sum(De0214) De0214,sum(De0314) De0314,sum(De0414) De0414,sum(De0514) De0514,sum(De0614) De0614
,sum(De0714) De0714,sum(De0814) De0814,sum(De0914) De0914,sum(De1014) De1014,sum(De1114) De1114,sum(De1214) De1214
,sum(De0115) De0115,sum(De0215) De0215,sum(De0315) De0315,sum(De0415) De0415,sum(De0515) De0515,sum(De0615) De0615
,sum(De0715) De0715,sum(De0815) De0815,sum(De0915) De0915,sum(De1015) De1015,sum(De1115) De1115,sum(De1215) De1215
,sum(De0116) De0116,sum(De0216) De0216,sum(De0316) De0316,sum(De0416) De0416,sum(De0516) De0516,sum(De0616) De0616
,sum(De0716) De0716,sum(De0816) De0816,sum(De0916) De0916,sum(De1016) De1016,sum(De1116) De1116,sum(De1216) De1216

,sum(Nc0114) Nc0114,sum(Nc0214) Nc0214,sum(Nc0314) Nc0314,sum(Nc0414) Nc0414,sum(Nc0514) Nc0514,sum(Nc0614) Nc0614
,sum(Nc0714) Nc0714,sum(Nc0814) Nc0814,sum(Nc0914) Nc0914,sum(Nc1014) Nc1014,sum(Nc1114) Nc1114,sum(Nc1214) Nc1214
,sum(Nc0115) Nc0115,sum(Nc0215) Nc0215,sum(Nc0315) Nc0315,sum(Nc0415) Nc0415,sum(Nc0515) Nc0515,sum(Nc0615) Nc0615
,sum(Nc0715) Nc0715,sum(Nc0815) Nc0815,sum(Nc0915) Nc0915,sum(Nc1015) Nc1015,sum(Nc1115) Nc1115,sum(Nc1215) Nc1215
,sum(Nc0116) Nc0116,sum(Nc0216) Nc0216,sum(Nc0316) Nc0316,sum(Nc0416) Nc0416,sum(Nc0516) Nc0516,sum(Nc0616) Nc0616
,sum(Nc0716) Nc0716,sum(Nc0816) Nc0816,sum(Nc0916) Nc0916,sum(Nc1016) Nc1016,sum(Nc1116) Nc1116,sum(Nc1216) Nc1216
from (
	Select primerasesor,codoficina
	,sum(De0114) De0114,sum(De0214) De0214,sum(De0314) De0314,sum(De0414) De0414,sum(De0514) De0514,sum(De0614) De0614,sum(De0714) De0714,sum(De0814) De0814,sum(De0914) De0914,sum(De1014) De1014,sum(De1114) De1114,sum(De1214) De1214
	,sum(De0115) De0115,sum(De0215) De0215,sum(De0315) De0315,sum(De0415) De0415,sum(De0515) De0515,sum(De0615) De0615,sum(De0715) De0715,sum(De0815) De0815,sum(De0915) De0915,sum(De1015) De1015,sum(De1115) De1115,sum(De1215) De1215
	,sum(De0116) De0116,sum(De0216) De0216,sum(De0316) De0316,sum(De0416) De0416,sum(De0516) De0516,sum(De0616) De0616,sum(De0716) De0716,sum(De0816) De0816,sum(De0916) De0916,sum(De1016) De1016,sum(De1116) De1116,sum(De1216) De1216
	,count(Nc0114) Nc0114,count(Nc0214) Nc0214,count(Nc0314) Nc0314,count(Nc0414) Nc0414,count(Nc0514) Nc0514,count(Nc0614) Nc0614,count(Nc0714) Nc0714,count(Nc0814) Nc0814,count(Nc0914) Nc0914,count(Nc1014) Nc1014,count(Nc1114) Nc1114,count(Nc1214) Nc1214
	,count(Nc0115) Nc0115,count(Nc0215) Nc0215,count(Nc0315) Nc0315,count(Nc0415) Nc0415,count(Nc0515) Nc0515,count(Nc0615) Nc0615,count(Nc0715) Nc0715,count(Nc0815) Nc0815,count(Nc0915) Nc0915,count(Nc1015) Nc1015,count(Nc1115) Nc1115,count(Nc1215) Nc1215
	,count(Nc0116) Nc0116,count(Nc0216) Nc0216,count(Nc0316) Nc0316,count(Nc0416) Nc0416,count(Nc0516) Nc0516,count(Nc0616) Nc0616,count(Nc0716) Nc0716,count(Nc0816) Nc0816,count(Nc0916) Nc0916,count(Nc1016) Nc1016,count(Nc1116) Nc1116,count(Nc1216) Nc1216
	from (
		select --case when cer.promotor is null then 'HUERFANO' else pd.primerasesor end primerasesor
		case when epd.estado=1 then
				case when c.codoficina=(case when epd.codoficinanom=98 then 42 else epd.codoficinanom end) then pd.primerasesor
				else 
					case when c.codoficina<>(case when e.codoficinanom=98 then 42 else e.codoficinanom end) then 'HUERFANO'
						 else case when e.estado=1 then c.codasesor else 'HUERFANO' end
						 end
				end
		else
			case when c.codoficina<>(case when e.codoficinanom=98 then 42 else e.codoficinanom end) then 'HUERFANO'
				 else case when e.estado=1 then c.codasesor else 'HUERFANO' end
				 end
		end  primerasesor
		,pd.codoficina
		,case when pd.desembolso>='20140101' and pd.desembolso<='20140131' then pd.monto else 0 end De0114
		,case when pd.desembolso>='20140201' and pd.desembolso<='20140228' then pd.monto else 0 end De0214
		,case when pd.desembolso>='20140301' and pd.desembolso<='20140331' then pd.monto else 0 end De0314
		,case when pd.desembolso>='20140401' and pd.desembolso<='20140430' then pd.monto else 0 end De0414
		,case when pd.desembolso>='20140501' and pd.desembolso<='20140531' then pd.monto else 0 end De0514
		,case when pd.desembolso>='20140601' and pd.desembolso<='20140630' then pd.monto else 0 end De0614
		,case when pd.desembolso>='20140701' and pd.desembolso<='20140731' then pd.monto else 0 end De0714
		,case when pd.desembolso>='20140801' and pd.desembolso<='20140831' then pd.monto else 0 end De0814
		,case when pd.desembolso>='20140901' and pd.desembolso<='20140930' then pd.monto else 0 end De0914
		,case when pd.desembolso>='20141001' and pd.desembolso<='20141031' then pd.monto else 0 end De1014
		,case when pd.desembolso>='20141101' and pd.desembolso<='20141130' then pd.monto else 0 end De1114
		,case when pd.desembolso>='20141201' and pd.desembolso<='20141231' then pd.monto else 0 end De1214
		/*2015*/
		,case when pd.desembolso>='20150101' and pd.desembolso<='20150131' then pd.monto else 0 end De0115
		,case when pd.desembolso>='20150201' and pd.desembolso<='20150228' then pd.monto else 0 end De0215
		,case when pd.desembolso>='20150301' and pd.desembolso<='20150331' then pd.monto else 0 end De0315
		,case when pd.desembolso>='20150401' and pd.desembolso<='20150430' then pd.monto else 0 end De0415
		,case when pd.desembolso>='20150501' and pd.desembolso<='20150531' then pd.monto else 0 end De0515
		,case when pd.desembolso>='20150601' and pd.desembolso<='20150630' then pd.monto else 0 end De0615
		,case when pd.desembolso>='20150701' and pd.desembolso<='20150731' then pd.monto else 0 end De0715
		,case when pd.desembolso>='20150801' and pd.desembolso<='20150831' then pd.monto else 0 end De0815
		,case when pd.desembolso>='20150901' and pd.desembolso<='20150930' then pd.monto else 0 end De0915
		,case when pd.desembolso>='20151001' and pd.desembolso<='20151031' then pd.monto else 0 end De1015
		,case when pd.desembolso>='20151101' and pd.desembolso<='20151130' then pd.monto else 0 end De1115
		,case when pd.desembolso>='20151201' and pd.desembolso<='20151231' then pd.monto else 0 end De1215
		/*2016*/
		,case when pd.desembolso>='20160101' and pd.desembolso<='20160131' then pd.monto else 0 end De0116
		,case when pd.desembolso>='20160201' and pd.desembolso<='20160229' then pd.monto else 0 end De0216
		,case when pd.desembolso>='20160301' and pd.desembolso<='20160331' then pd.monto else 0 end De0316
		,case when pd.desembolso>='20160401' and pd.desembolso<='20160430' then pd.monto else 0 end De0416
		,case when pd.desembolso>='20160501' and pd.desembolso<='20160531' then pd.monto else 0 end De0516
		,case when pd.desembolso>='20160601' and pd.desembolso<='20160630' then pd.monto else 0 end De0616
		,case when pd.desembolso>='20160701' and pd.desembolso<='20160731' then pd.monto else 0 end De0716
		,case when pd.desembolso>='20160801' and pd.desembolso<='20160831' then pd.monto else 0 end De0816
		,case when pd.desembolso>='20160901' and pd.desembolso<='20160930' then pd.monto else 0 end De0916
		,case when pd.desembolso>='20161001' and pd.desembolso<='20161031' then pd.monto else 0 end De1016
		,case when pd.desembolso>='20161101' and pd.desembolso<='20161130' then pd.monto else 0 end De1116
		,case when pd.desembolso>='20161201' and pd.desembolso<='20161231' then pd.monto else 0 end De1216

			/*2014 Numeros*/
			,case when pd.desembolso>='20140101' and pd.desembolso<='20140131' then pd.codusuario else null end Nc0114
			,case when pd.desembolso>='20140201' and pd.desembolso<='20140228' then pd.codusuario else null end Nc0214
			,case when pd.desembolso>='20140301' and pd.desembolso<='20140331' then pd.codusuario else null end Nc0314
			,case when pd.desembolso>='20140401' and pd.desembolso<='20140430' then pd.codusuario else null end Nc0414
			,case when pd.desembolso>='20140501' and pd.desembolso<='20140531' then pd.codusuario else null end Nc0514
			,case when pd.desembolso>='20140601' and pd.desembolso<='20140630' then pd.codusuario else null end Nc0614
			,case when pd.desembolso>='20140701' and pd.desembolso<='20140731' then pd.codusuario else null end Nc0714
			,case when pd.desembolso>='20140801' and pd.desembolso<='20140831' then pd.codusuario else null end Nc0814
			,case when pd.desembolso>='20140901' and pd.desembolso<='20140930' then pd.codusuario else null end Nc0914
			,case when pd.desembolso>='20141001' and pd.desembolso<='20141031' then pd.codusuario else null end Nc1014
			,case when pd.desembolso>='20141101' and pd.desembolso<='20141130' then pd.codusuario else null end Nc1114
			,case when pd.desembolso>='20141201' and pd.desembolso<='20141231' then pd.codusuario else null end Nc1214
			/*2015*/
			,case when pd.desembolso>='20150101' and pd.desembolso<='20150131' then pd.codusuario else null end Nc0115
			,case when pd.desembolso>='20150201' and pd.desembolso<='20150228' then pd.codusuario else null end Nc0215
			,case when pd.desembolso>='20150301' and pd.desembolso<='20150331' then pd.codusuario else null end Nc0315
			,case when pd.desembolso>='20150401' and pd.desembolso<='20150430' then pd.codusuario else null end Nc0415
			,case when pd.desembolso>='20150501' and pd.desembolso<='20150531' then pd.codusuario else null end Nc0515
			,case when pd.desembolso>='20150601' and pd.desembolso<='20150630' then pd.codusuario else null end Nc0615
			,case when pd.desembolso>='20150701' and pd.desembolso<='20150731' then pd.codusuario else null end Nc0715
			,case when pd.desembolso>='20150801' and pd.desembolso<='20150831' then pd.codusuario else null end Nc0815
			,case when pd.desembolso>='20150901' and pd.desembolso<='20150930' then pd.codusuario else null end Nc0915
			,case when pd.desembolso>='20151001' and pd.desembolso<='20151031' then pd.codusuario else null end Nc1015
			,case when pd.desembolso>='20151101' and pd.desembolso<='20151130' then pd.codusuario else null end Nc1115
			,case when pd.desembolso>='20151201' and pd.desembolso<='20151231' then pd.codusuario else null end Nc1215
			/*2016*/
			,case when pd.desembolso>='20160101' and pd.desembolso<='20160131' then pd.codusuario else null end Nc0116
			,case when pd.desembolso>='20160201' and pd.desembolso<='20160229' then pd.codusuario else null end Nc0216
			,case when pd.desembolso>='20160301' and pd.desembolso<='20160331' then pd.codusuario else null end Nc0316
			,case when pd.desembolso>='20160401' and pd.desembolso<='20160430' then pd.codusuario else null end Nc0416
			,case when pd.desembolso>='20160501' and pd.desembolso<='20160531' then pd.codusuario else null end Nc0516
			,case when pd.desembolso>='20160601' and pd.desembolso<='20160630' then pd.codusuario else null end Nc0616
			,case when pd.desembolso>='20160701' and pd.desembolso<='20160731' then pd.codusuario else null end Nc0716
			,case when pd.desembolso>='20160801' and pd.desembolso<='20160831' then pd.codusuario else null end Nc0816
			,case when pd.desembolso>='20160901' and pd.desembolso<='20160930' then pd.codusuario else null end Nc0916
			,case when pd.desembolso>='20161001' and pd.desembolso<='20161031' then pd.codusuario else null end Nc1016
			,case when pd.desembolso>='20161101' and pd.desembolso<='20161130' then pd.codusuario else null end Nc1116
			,case when pd.desembolso>='20161201' and pd.desembolso<='20161231' then pd.codusuario else null end Nc1216

		from tCsCartera c with(nolock)
		--left outer join #CER4 cer on cer.promotor=pd.primerasesor
		inner join tcspadroncarteradet pd with(nolock) on c.codprestamo=pd.codprestamo
		left outer join tcsempleados e with(nolock) on e.codusuario=c.codasesor
		left outer join tcsempleados epd with(nolock) on epd.codusuario=pd.primerasesor
		where c.fecha=@fecha--'20160430'
		and pd.desembolso>='20140101' --pd.primerasesor in(select promotor from #CER4) and 
		and pd.desembolso<=@fecha
		and pd.codproducto not in(167,168)
		and pd.codoficina=@codoficina
		--and pd.estadocalculado<>'CANCELADO'
	) b
	group by primerasesor,codoficina
	union all
	Select promotor,codoficina
	,sum(De0114) De0114,sum(De0214) De0214,sum(De0314) De0314,sum(De0414) De0414,sum(De0514) De0514,sum(De0614) De0614,sum(De0714) De0714,sum(De0814) De0814,sum(De0914) De0914,sum(De1014) De1014,sum(De1114) De1114,sum(De1214) De1214
	,sum(De0115) De0115,sum(De0215) De0215,sum(De0315) De0315,sum(De0415) De0415,sum(De0515) De0515,sum(De0615) De0615,sum(De0715) De0715,sum(De0815) De0815,sum(De0915) De0915,sum(De1015) De1015,sum(De1115) De1115,sum(De1215) De1215
	,sum(De0116) De0116,sum(De0216) De0216,sum(De0316) De0316,sum(De0416) De0416,sum(De0516) De0516,sum(De0616) De0616,sum(De0716) De0716,sum(De0816) De0816,sum(De0916) De0916,sum(De1016) De1016,sum(De1116) De1116,sum(De1216) De1216
	,count(Nc0114) Nc0114,count(Nc0214) Nc0214,count(Nc0314) Nc0314,count(Nc0414) Nc0414,count(Nc0514) Nc0514,count(Nc0614) Nc0614,count(Nc0714) Nc0714,count(Nc0814) Nc0814,count(Nc0914) Nc0914,count(Nc1014) Nc1014,count(Nc1114) Nc1114,count(Nc1214) Nc1214
	,count(Nc0115) Nc0115,count(Nc0215) Nc0215,count(Nc0315) Nc0315,count(Nc0415) Nc0415,count(Nc0515) Nc0515,count(Nc0615) Nc0615,count(Nc0715) Nc0715,count(Nc0815) Nc0815,count(Nc0915) Nc0915,count(Nc1015) Nc1015,count(Nc1115) Nc1115,count(Nc1215) Nc1215
	,count(Nc0116) Nc0116,count(Nc0216) Nc0216,count(Nc0316) Nc0316,count(Nc0416) Nc0416,count(Nc0516) Nc0516,count(Nc0616) Nc0616,count(Nc0716) Nc0716,count(Nc0816) Nc0816,count(Nc0916) Nc0916,count(Nc1016) Nc1016,count(Nc1116) Nc1116,count(Nc1216) Nc1216
	from (
		SELECT case when epd.estado=1 then
					case when pd.codoficina<>epd.codoficinanom then 'HUERFANO'
					else pd.primerasesor end
				else
					'HUERFANO'
				end promotor
		,pd.codoficina
		,case when pd.desembolso>='20140101' and pd.desembolso<='20140131' then pd.monto else 0 end De0114
		,case when pd.desembolso>='20140201' and pd.desembolso<='20140228' then pd.monto else 0 end De0214
		,case when pd.desembolso>='20140301' and pd.desembolso<='20140331' then pd.monto else 0 end De0314
		,case when pd.desembolso>='20140401' and pd.desembolso<='20140430' then pd.monto else 0 end De0414
		,case when pd.desembolso>='20140501' and pd.desembolso<='20140531' then pd.monto else 0 end De0514
		,case when pd.desembolso>='20140601' and pd.desembolso<='20140630' then pd.monto else 0 end De0614
		,case when pd.desembolso>='20140701' and pd.desembolso<='20140731' then pd.monto else 0 end De0714
		,case when pd.desembolso>='20140801' and pd.desembolso<='20140831' then pd.monto else 0 end De0814
		,case when pd.desembolso>='20140901' and pd.desembolso<='20140930' then pd.monto else 0 end De0914
		,case when pd.desembolso>='20141001' and pd.desembolso<='20141031' then pd.monto else 0 end De1014
		,case when pd.desembolso>='20141101' and pd.desembolso<='20141130' then pd.monto else 0 end De1114
		,case when pd.desembolso>='20141201' and pd.desembolso<='20141231' then pd.monto else 0 end De1214
		/*2015*/
		,case when pd.desembolso>='20150101' and pd.desembolso<='20150131' then pd.monto else 0 end De0115
		,case when pd.desembolso>='20150201' and pd.desembolso<='20150228' then pd.monto else 0 end De0215
		,case when pd.desembolso>='20150301' and pd.desembolso<='20150331' then pd.monto else 0 end De0315
		,case when pd.desembolso>='20150401' and pd.desembolso<='20150430' then pd.monto else 0 end De0415
		,case when pd.desembolso>='20150501' and pd.desembolso<='20150531' then pd.monto else 0 end De0515
		,case when pd.desembolso>='20150601' and pd.desembolso<='20150630' then pd.monto else 0 end De0615
		,case when pd.desembolso>='20150701' and pd.desembolso<='20150731' then pd.monto else 0 end De0715
		,case when pd.desembolso>='20150801' and pd.desembolso<='20150831' then pd.monto else 0 end De0815
		,case when pd.desembolso>='20150901' and pd.desembolso<='20150930' then pd.monto else 0 end De0915
		,case when pd.desembolso>='20151001' and pd.desembolso<='20151031' then pd.monto else 0 end De1015
		,case when pd.desembolso>='20151101' and pd.desembolso<='20151130' then pd.monto else 0 end De1115
		,case when pd.desembolso>='20151201' and pd.desembolso<='20151231' then pd.monto else 0 end De1215
		/*2016*/
		,case when pd.desembolso>='20160101' and pd.desembolso<='20160131' then pd.monto else 0 end De0116
		,case when pd.desembolso>='20160201' and pd.desembolso<='20160229' then pd.monto else 0 end De0216
		,case when pd.desembolso>='20160301' and pd.desembolso<='20160331' then pd.monto else 0 end De0316
		,case when pd.desembolso>='20160401' and pd.desembolso<='20160430' then pd.monto else 0 end De0416
		,case when pd.desembolso>='20160501' and pd.desembolso<='20160531' then pd.monto else 0 end De0516
		,case when pd.desembolso>='20160601' and pd.desembolso<='20160630' then pd.monto else 0 end De0616
		,case when pd.desembolso>='20160701' and pd.desembolso<='20160731' then pd.monto else 0 end De0716
		,case when pd.desembolso>='20160801' and pd.desembolso<='20160831' then pd.monto else 0 end De0816
		,case when pd.desembolso>='20160901' and pd.desembolso<='20160930' then pd.monto else 0 end De0916
		,case when pd.desembolso>='20161001' and pd.desembolso<='20161031' then pd.monto else 0 end De1016
		,case when pd.desembolso>='20161101' and pd.desembolso<='20161130' then pd.monto else 0 end De1116
		,case when pd.desembolso>='20161201' and pd.desembolso<='20161231' then pd.monto else 0 end De1216

		/*2014 Numeros*/
		,case when 1=1 then null else '' end Nc0114,case when 1=1 then null else '' end Nc0214
		,case when 1=1 then null else '' end Nc0314,case when 1=1 then null else '' end Nc0414
		,case when 1=1 then null else '' end Nc0514,case when 1=1 then null else '' end Nc0614
		,case when 1=1 then null else '' end Nc0714,case when 1=1 then null else '' end Nc0814
		,case when 1=1 then null else '' end Nc0914,case when 1=1 then null else '' end Nc1014
		,case when 1=1 then null else '' end Nc1114,case when 1=1 then null else '' end Nc1214
		/*2015*/
		,case when 1=1 then null else '' end Nc0115,case when 1=1 then null else '' end Nc0215
		,case when 1=1 then null else '' end Nc0315,case when 1=1 then null else '' end Nc0415
		,case when 1=1 then null else '' end Nc0515,case when 1=1 then null else '' end Nc0615
		,case when 1=1 then null else '' end Nc0715,case when 1=1 then null else '' end Nc0815
		,case when 1=1 then null else '' end Nc0915,case when 1=1 then null else '' end Nc1015
		,case when 1=1 then null else '' end Nc1115,case when 1=1 then null else '' end Nc1215
		/*2016*/
		,case when 1=1 then null else '' end Nc0116,case when 1=1 then null else '' end Nc0216
		,case when 1=1 then null else '' end Nc0316,case when 1=1 then null else '' end Nc0416
		,case when 1=1 then null else '' end Nc0516,case when 1=1 then null else '' end Nc0616
		,case when 1=1 then null else '' end Nc0716,case when 1=1 then null else '' end Nc0816
		,case when 1=1 then null else '' end Nc0916,case when 1=1 then null else '' end Nc1016
		,case when 1=1 then null else '' end Nc1116,case when 1=1 then null else '' end Nc1216
	
		--/*2014 Numeros*/
		--,case when pd.desembolso>='20140101' and pd.desembolso<='20140131' then pd.codusuario else null end Nc0114
		--,case when pd.desembolso>='20140201' and pd.desembolso<='20140228' then pd.codusuario else null end Nc0214
		--,case when pd.desembolso>='20140301' and pd.desembolso<='20140331' then pd.codusuario else null end Nc0314
		--,case when pd.desembolso>='20140401' and pd.desembolso<='20140430' then pd.codusuario else null end Nc0414
		--,case when pd.desembolso>='20140501' and pd.desembolso<='20140531' then pd.codusuario else null end Nc0514
		--,case when pd.desembolso>='20140601' and pd.desembolso<='20140630' then pd.codusuario else null end Nc0614
		--,case when pd.desembolso>='20140701' and pd.desembolso<='20140731' then pd.codusuario else null end Nc0714
		--,case when pd.desembolso>='20140801' and pd.desembolso<='20140831' then pd.codusuario else null end Nc0814
		--,case when pd.desembolso>='20140901' and pd.desembolso<='20140930' then pd.codusuario else null end Nc0914
		--,case when pd.desembolso>='20141001' and pd.desembolso<='20141031' then pd.codusuario else null end Nc1014
		--,case when pd.desembolso>='20141101' and pd.desembolso<='20141130' then pd.codusuario else null end Nc1114
		--,case when pd.desembolso>='20141201' and pd.desembolso<='20141231' then pd.codusuario else null end Nc1214
		--/*2015*/
		--,case when pd.desembolso>='20150101' and pd.desembolso<='20150131' then pd.codusuario else null end Nc0115
		--,case when pd.desembolso>='20150201' and pd.desembolso<='20150228' then pd.codusuario else null end Nc0215
		--,case when pd.desembolso>='20150301' and pd.desembolso<='20150331' then pd.codusuario else null end Nc0315
		--,case when pd.desembolso>='20150401' and pd.desembolso<='20150430' then pd.codusuario else null end Nc0415
		--,case when pd.desembolso>='20150501' and pd.desembolso<='20150531' then pd.codusuario else null end Nc0515
		--,case when pd.desembolso>='20150601' and pd.desembolso<='20150630' then pd.codusuario else null end Nc0615
		--,case when pd.desembolso>='20150701' and pd.desembolso<='20150731' then pd.codusuario else null end Nc0715
		--,case when pd.desembolso>='20150801' and pd.desembolso<='20150831' then pd.codusuario else null end Nc0815
		--,case when pd.desembolso>='20150901' and pd.desembolso<='20150930' then pd.codusuario else null end Nc0915
		--,case when pd.desembolso>='20151001' and pd.desembolso<='20151031' then pd.codusuario else null end Nc1015
		--,case when pd.desembolso>='20151101' and pd.desembolso<='20151130' then pd.codusuario else null end Nc1115
		--,case when pd.desembolso>='20151201' and pd.desembolso<='20151231' then pd.codusuario else null end Nc1215
		--/*2016*/
		--,case when pd.desembolso>='20160101' and pd.desembolso<='20160131' then pd.codusuario else null end Nc0116
		--,case when pd.desembolso>='20160201' and pd.desembolso<='20160228' then pd.codusuario else null end Nc0216
		--,case when pd.desembolso>='20160301' and pd.desembolso<='20160331' then pd.codusuario else null end Nc0316
		--,case when pd.desembolso>='20160401' and pd.desembolso<='20160430' then pd.codusuario else null end Nc0416
		--,case when pd.desembolso>='20160501' and pd.desembolso<='20160531' then pd.codusuario else null end Nc0516
		--,case when pd.desembolso>='20160601' and pd.desembolso<='20160630' then pd.codusuario else null end Nc0616
		--,case when pd.desembolso>='20160701' and pd.desembolso<='20160731' then pd.codusuario else null end Nc0716
		--,case when pd.desembolso>='20160801' and pd.desembolso<='20160831' then pd.codusuario else null end Nc0816
		--,case when pd.desembolso>='20160901' and pd.desembolso<='20160930' then pd.codusuario else null end Nc0916
		--,case when pd.desembolso>='20161001' and pd.desembolso<='20161031' then pd.codusuario else null end Nc1016
		--,case when pd.desembolso>='20161101' and pd.desembolso<='20161130' then pd.codusuario else null end Nc1116
		--,case when pd.desembolso>='20161201' and pd.desembolso<='20161231' then pd.codusuario else null end Nc1216

		FROM tcspadroncarteradet pd with(nolock)
		left outer join tcsempleados e with(nolock) on e.codusuario=pd.ultimoasesor
		left outer join tcsempleados epd with(nolock) on epd.codusuario=pd.primerasesor
		where pd.desembolso>='20140101' and pd.codproducto not in(167,168)
		and pd.codoficina<100
		and pd.cancelacion<=@fecha
		and pd.codoficina=@codoficina	
	) b
	group by promotor,codoficina
) a
group by primerasesor,codoficina

--select * from #CER4 --where promotor='CRM0605911'
--select '#CerDesem',* from #CerDesem --where codasesor='CRM0605911'

select 	c.codoficina,c.promotor,c.coordinador
,case when c.promotor='HUERFANO' or oDe0114 is null then (case when De0114=0 then 0 else SC0114/De0114 end)*100 else (case when oDe0114=0 then 0 else SC0114/oDe0114 end)*100 end De0114,Nc0114
,case when c.promotor='HUERFANO' or oDe0214 is null then (case when De0214=0 then 0 else SC0214/De0214 end)*100 else (case when oDe0214=0 then 0 else SC0214/oDe0214 end)*100 end De0214,Nc0214
,case when c.promotor='HUERFANO' or oDe0314 is null then (case when De0314=0 then 0 else SC0314/De0314 end)*100 else (case when oDe0314=0 then 0 else SC0314/oDe0314 end)*100 end De0314,Nc0314
,case when c.promotor='HUERFANO' or oDe0414 is null then (case when De0414=0 then 0 else SC0414/De0414 end)*100 else (case when oDe0414=0 then 0 else SC0414/oDe0414 end)*100 end De0414,Nc0414
,case when c.promotor='HUERFANO' or oDe0514 is null then (case when De0514=0 then 0 else SC0514/De0514 end)*100 else (case when oDe0514=0 then 0 else SC0514/oDe0514 end)*100 end De0514,Nc0514
,case when c.promotor='HUERFANO' or oDe0614 is null then (case when De0614=0 then 0 else SC0614/De0614 end)*100 else (case when oDe0614=0 then 0 else SC0614/oDe0614 end)*100 end De0614,Nc0614
,case when c.promotor='HUERFANO' or oDe0714 is null then (case when De0714=0 then 0 else SC0714/De0714 end)*100 else (case when oDe0714=0 then 0 else SC0714/oDe0714 end)*100 end De0714,Nc0714
,case when c.promotor='HUERFANO' or oDe0814 is null then (case when De0814=0 then 0 else SC0814/De0814 end)*100 else (case when oDe0814=0 then 0 else SC0814/oDe0814 end)*100 end De0814,Nc0814
,case when c.promotor='HUERFANO' or oDe0914 is null then (case when De0914=0 then 0 else SC0914/De0914 end)*100 else (case when oDe0914=0 then 0 else SC0914/oDe0914 end)*100 end De0914,Nc0914
,case when c.promotor='HUERFANO' or oDe1014 is null then (case when De1014=0 then 0 else SC1014/De1014 end)*100 else (case when oDe1014=0 then 0 else SC1014/oDe1014 end)*100 end De1014,Nc1014
,case when c.promotor='HUERFANO' or oDe1114 is null then (case when De1114=0 then 0 else SC1114/De1114 end)*100 else (case when oDe1114=0 then 0 else SC1114/oDe1114 end)*100 end De1114,Nc1114
,case when c.promotor='HUERFANO' or oDe1214 is null then (case when De1214=0 then 0 else SC1214/De1214 end)*100 else (case when oDe1214=0 then 0 else SC1214/oDe1214 end)*100 end De1214,Nc1214

,case when c.promotor='HUERFANO' or oDe0115 is null then (case when De0115=0 then 0 else SC0115/De0115 end)*100 else (case when oDe0115=0 then 0 else SC0115/oDe0115 end)*100 end De0115,Nc0115
,case when c.promotor='HUERFANO' or oDe0215 is null then (case when De0215=0 then 0 else SC0215/De0215 end)*100 else (case when oDe0215=0 then 0 else SC0215/oDe0215 end)*100 end De0215,Nc0215
,case when c.promotor='HUERFANO' or oDe0315 is null then (case when De0315=0 then 0 else SC0315/De0315 end)*100 else (case when oDe0315=0 then 0 else SC0315/oDe0315 end)*100 end De0315,Nc0315
,case when c.promotor='HUERFANO' or oDe0415 is null then (case when De0415=0 then 0 else SC0415/De0415 end)*100 else (case when oDe0415=0 then 0 else SC0415/oDe0415 end)*100 end De0415,Nc0415
,case when c.promotor='HUERFANO' or oDe0515 is null then (case when De0515=0 then 0 else SC0515/De0515 end)*100 else (case when oDe0515=0 then 0 else SC0515/oDe0515 end)*100 end De0515,Nc0515
,case when c.promotor='HUERFANO' or oDe0615 is null then (case when De0615=0 then 0 else SC0615/De0615 end)*100 else (case when oDe0615=0 then 0 else SC0615/oDe0615 end)*100 end De0615,Nc0615
,case when c.promotor='HUERFANO' or oDe0715 is null then (case when De0715=0 then 0 else SC0715/De0715 end)*100 else (case when oDe0715=0 then 0 else SC0715/oDe0715 end)*100 end De0715,Nc0715
,case when c.promotor='HUERFANO' or oDe0815 is null then (case when De0815=0 then 0 else SC0815/De0815 end)*100 else (case when oDe0815=0 then 0 else SC0815/oDe0815 end)*100 end De0815,Nc0815
,case when c.promotor='HUERFANO' or oDe0915 is null then (case when De0915=0 then 0 else SC0915/De0915 end)*100 else (case when oDe0915=0 then 0 else SC0915/oDe0915 end)*100 end De0915,Nc0915
,case when c.promotor='HUERFANO' or oDe1015 is null then (case when De1015=0 then 0 else SC1015/De1015 end)*100 else (case when oDe1015=0 then 0 else SC1015/oDe1015 end)*100 end De1015,Nc1015
,case when c.promotor='HUERFANO' or oDe1115 is null then (case when De1115=0 then 0 else SC1115/De1115 end)*100 else (case when oDe1115=0 then 0 else SC1115/oDe1115 end)*100 end De1115,Nc1115
,case when c.promotor='HUERFANO' or oDe1215 is null then (case when De1215=0 then 0 else SC1215/De1215 end)*100 else (case when oDe1215=0 then 0 else SC1215/oDe1215 end)*100 end De1215,Nc1215

,case when c.promotor='HUERFANO' or oDe0116 is null then (case when De0116=0 then 0 else SC0116/De0116 end)*100 else (case when oDe0116=0 then 0 else SC0116/oDe0116 end)*100 end De0116,Nc0116
,case when c.promotor='HUERFANO' or oDe0216 is null then (case when De0216=0 then 0 else SC0216/De0216 end)*100 else (case when oDe0216=0 then 0 else SC0216/oDe0216 end)*100 end De0216,Nc0216
,case when c.promotor='HUERFANO' or oDe0316 is null then (case when De0316=0 then 0 else SC0316/De0316 end)*100 else (case when oDe0316=0 then 0 else SC0316/oDe0316 end)*100 end De0316,Nc0316
,case when c.promotor='HUERFANO' or oDe0416 is null then (case when De0416=0 then 0 else SC0416/De0416 end)*100 else (case when oDe0416=0 then 0 else SC0416/oDe0416 end)*100 end De0416,Nc0416
,case when c.promotor='HUERFANO' or oDe0516 is null then (case when De0516=0 then 0 else SC0516/De0516 end)*100 else (case when oDe0516=0 then 0 else SC0516/oDe0516 end)*100 end De0516,Nc0516
,case when c.promotor='HUERFANO' or oDe0616 is null then (case when De0616=0 then 0 else SC0616/De0616 end)*100 else (case when oDe0616=0 then 0 else SC0616/oDe0616 end)*100 end De0616,Nc0616
,case when c.promotor='HUERFANO' or oDe0716 is null then (case when De0716=0 then 0 else SC0716/De0716 end)*100 else (case when oDe0716=0 then 0 else SC0716/oDe0716 end)*100 end De0716,Nc0716
,case when c.promotor='HUERFANO' or oDe0816 is null then (case when De0816=0 then 0 else SC0816/De0816 end)*100 else (case when oDe0816=0 then 0 else SC0816/oDe0816 end)*100 end De0816,Nc0816
,case when c.promotor='HUERFANO' or oDe0916 is null then (case when De0916=0 then 0 else SC0916/De0916 end)*100 else (case when oDe0916=0 then 0 else SC0916/oDe0916 end)*100 end De0916,Nc0916
,case when c.promotor='HUERFANO' or oDe1016 is null then (case when De1016=0 then 0 else SC1016/De1016 end)*100 else (case when oDe1016=0 then 0 else SC1016/oDe1016 end)*100 end De1016,Nc1016
,case when c.promotor='HUERFANO' or oDe1116 is null then (case when De1116=0 then 0 else SC1116/De1116 end)*100 else (case when oDe1116=0 then 0 else SC1116/oDe1116 end)*100 end De1116,Nc1116
,case when c.promotor='HUERFANO' or oDe1216 is null then (case when De1216=0 then 0 else SC1216/De1216 end)*100 else (case when oDe1216=0 then 0 else SC1216/oDe1216 end)*100 end De1216,Nc1216
into #SelectCER
from #CER4 c left outer join #CerDesem d
on c.promotor=d.codasesor and c.codoficina=d.codoficina

select c.codoficina
,case when oDe0114 is null then De0114 else oDe0114 end De0114
,case when oDe0214 is null then De0214 else oDe0214 end De0214
,case when oDe0314 is null then De0314 else oDe0314 end De0314
,case when oDe0414 is null then De0414 else oDe0414 end De0414
,case when oDe0514 is null then De0514 else oDe0514 end De0514
,case when oDe0614 is null then De0614 else oDe0614 end De0614
,case when oDe0714 is null then De0714 else oDe0714 end De0714
,case when oDe0814 is null then De0814 else oDe0814 end De0814
,case when oDe0914 is null then De0914 else oDe0914 end De0914
,case when oDe1014 is null then De1014 else oDe1014 end De1014
,case when oDe1114 is null then De1114 else oDe1114 end De1114
,case when oDe1214 is null then De1214 else oDe1214 end De1214
,SC0114,SC0214,SC0314,SC0414,SC0514,SC0614,SC0714,SC0814,SC0914,SC1014,SC1114,SC1214
,Nc0114,Nc0214,Nc0314,Nc0414,Nc0514,Nc0614,Nc0714,Nc0814,Nc0914,Nc1014,Nc1114,Nc1214

,case when oDe0115 is null then De0115 else oDe0115 end De0115
,case when oDe0215 is null then De0215 else oDe0215 end De0215
,case when oDe0315 is null then De0315 else oDe0315 end De0315
,case when oDe0415 is null then De0415 else oDe0415 end De0415
,case when oDe0515 is null then De0515 else oDe0515 end De0515
,case when oDe0615 is null then De0615 else oDe0615 end De0615
,case when oDe0715 is null then De0715 else oDe0715 end De0715
,case when oDe0815 is null then De0815 else oDe0815 end De0815
,case when oDe0915 is null then De0915 else oDe0915 end De0915
,case when oDe1015 is null then De1015 else oDe1015 end De1015
,case when oDe1115 is null then De1115 else oDe1115 end De1115
,case when oDe1215 is null then De1215 else oDe1215 end De1215
,SC0115,SC0215,SC0315,SC0415,SC0515,SC0615,SC0715,SC0815,SC0915,SC1015,SC1115,SC1215
,Nc0115,Nc0215,Nc0315,Nc0415,Nc0515,Nc0615,Nc0715,Nc0815,Nc0915,Nc1015,Nc1115,Nc1215

,case when oDe0116 is null then De0116 else oDe0116 end De0116
,case when oDe0216 is null then De0216 else oDe0216 end De0216
,case when oDe0316 is null then De0316 else oDe0316 end De0316
,case when oDe0416 is null then De0416 else oDe0416 end De0416
,case when oDe0516 is null then De0516 else oDe0516 end De0516
,case when oDe0616 is null then De0616 else oDe0616 end De0616
,case when oDe0716 is null then De0716 else oDe0716 end De0716
,case when oDe0816 is null then De0816 else oDe0816 end De0816
,case when oDe0916 is null then De0916 else oDe0916 end De0916
,case when oDe1016 is null then De1016 else oDe1016 end De1016
,case when oDe1116 is null then De1116 else oDe1116 end De1116
,case when oDe1216 is null then De1216 else oDe1216 end De1216
,SC0116,SC0216,SC0316,SC0416,SC0516,SC0616,SC0716,SC0816,SC0916,SC1016,SC1116,SC1216
,Nc0116,Nc0216,Nc0316,Nc0416,Nc0516,Nc0616,Nc0716,Nc0816,Nc0916,Nc1016,Nc1116,Nc1216
into #sumcer
from --#CER4 
(
	select codoficina
	,sum(SC0114) SC0114,sum(De0114) De0114,sum(Nc0114) Nc0114,sum(SC0214) SC0214,sum(De0214) De0214,sum(Nc0214) Nc0214
	,sum(SC0314) SC0314,sum(De0314) De0314,sum(Nc0314) Nc0314,sum(SC0414) SC0414,sum(De0414) De0414,sum(Nc0414) Nc0414
	,sum(SC0514) SC0514,sum(De0514) De0514,sum(Nc0514) Nc0514,sum(SC0614) SC0614,sum(De0614) De0614,sum(Nc0614) Nc0614
	,sum(SC0714) SC0714,sum(De0714) De0714,sum(Nc0714) Nc0714,sum(SC0814) SC0814,sum(De0814) De0814,sum(Nc0814) Nc0814
	,sum(SC0914) SC0914,sum(De0914) De0914,sum(Nc0914) Nc0914,sum(SC1014) SC1014,sum(De1014) De1014,sum(Nc1014) Nc1014
	,sum(SC1114) SC1114,sum(De1114) De1114,sum(Nc1114) Nc1114,sum(SC1214) SC1214,sum(De1214) De1214,sum(Nc1214) Nc1214

	,sum(SC0115) SC0115,sum(De0115) De0115,sum(Nc0115) Nc0115,sum(SC0215) SC0215,sum(De0215) De0215,sum(Nc0215) Nc0215
	,sum(SC0315) SC0315,sum(De0315) De0315,sum(Nc0315) Nc0315,sum(SC0415) SC0415,sum(De0415) De0415,sum(Nc0415) Nc0415
	,sum(SC0515) SC0515,sum(De0515) De0515,sum(Nc0515) Nc0515,sum(SC0615) SC0615,sum(De0615) De0615,sum(Nc0615) Nc0615
	,sum(SC0715) SC0715,sum(De0715) De0715,sum(Nc0715) Nc0715,sum(SC0815) SC0815,sum(De0815) De0815,sum(Nc0815) Nc0815
	,sum(SC0915) SC0915,sum(De0915) De0915,sum(Nc0915) Nc0915,sum(SC1015) SC1015,sum(De1015) De1015,sum(Nc1015) Nc1015
	,sum(SC1115) SC1115,sum(De1115) De1115,sum(Nc1115) Nc1115,sum(SC1215) SC1215,sum(De1215) De1215,sum(Nc1215) Nc1215

	,sum(SC0116) SC0116,sum(De0116) De0116,sum(Nc0116) Nc0116,sum(SC0216) SC0216,sum(De0216) De0216,sum(Nc0216) Nc0216
	,sum(SC0316) SC0316,sum(De0316) De0316,sum(Nc0316) Nc0316,sum(SC0416) SC0416,sum(De0416) De0416,sum(Nc0416) Nc0416
	,sum(SC0516) SC0516,sum(De0516) De0516,sum(Nc0516) Nc0516,sum(SC0616) SC0616,sum(De0616) De0616,sum(Nc0616) Nc0616
	,sum(SC0716) SC0716,sum(De0716) De0716,sum(Nc0716) Nc0716,sum(SC0816) SC0816,sum(De0816) De0816,sum(Nc0816) Nc0816
	,sum(SC0916) SC0916,sum(De0916) De0916,sum(Nc0916) Nc0916,sum(SC1016) SC1016,sum(De1016) De1016,sum(Nc1016) Nc1016
	,sum(SC1116) SC1116,sum(De1116) De1116,sum(Nc1116) Nc1116,sum(SC1216) SC1216,sum(De1216) De1216,sum(Nc1216) Nc1216
	from #CER4
	group by codoficina
) c 
left outer join --#CerDesem 
(
	select codoficina
	,sum(oDe0114) oDe0114,sum(oDe0214) oDe0214,sum(oDe0314) oDe0314,sum(oDe0414) oDe0414,sum(oDe0514) oDe0514,sum(oDe0614) oDe0614
	,sum(oDe0714) oDe0714,sum(oDe0814) oDe0814,sum(oDe0914) oDe0914,sum(oDe1014) oDe1014,sum(oDe1114) oDe1114,sum(oDe1214) oDe1214
	,sum(oDe0115) oDe0115,sum(oDe0215) oDe0215,sum(oDe0315) oDe0315,sum(oDe0415) oDe0415,sum(oDe0515) oDe0515,sum(oDe0615) oDe0615
	,sum(oDe0715) oDe0715,sum(oDe0815) oDe0815,sum(oDe0915) oDe0915,sum(oDe1015) oDe1015,sum(oDe1115) oDe1115,sum(oDe1215) oDe1215
	,sum(oDe0116) oDe0116,sum(oDe0216) oDe0216,sum(oDe0316) oDe0316,sum(oDe0416) oDe0416,sum(oDe0516) oDe0516,sum(oDe0616) oDe0616
	,sum(oDe0716) oDe0716,sum(oDe0816) oDe0816,sum(oDe0916) oDe0916,sum(oDe1016) oDe1016,sum(oDe1116) oDe1116,sum(oDe1216) oDe1216

	,sum(oNc0114) oNc0114,sum(oNc0214) oNc0214,sum(oNc0314) oNc0314,sum(oNc0414) oNc0414,sum(oNc0514) oNc0514,sum(oNc0614) oNc0614
	,sum(oNc0714) oNc0714,sum(oNc0814) oNc0814,sum(oNc0914) oNc0914,sum(oNc1014) oNc1014,sum(oNc1114) oNc1114,sum(oNc1214) oNc1214
	,sum(oNc0115) oNc0115,sum(oNc0215) oNc0215,sum(oNc0315) oNc0315,sum(oNc0415) oNc0415,sum(oNc0515) oNc0515,sum(oNc0615) oNc0615
	,sum(oNc0715) oNc0715,sum(oNc0815) oNc0815,sum(oNc0915) oNc0915,sum(oNc1015) oNc1015,sum(oNc1115) oNc1115,sum(oNc1215) oNc1215
	,sum(oNc0116) oNc0116,sum(oNc0216) oNc0216,sum(oNc0316) oNc0316,sum(oNc0416) oNc0416,sum(oNc0516) oNc0516,sum(oNc0616) oNc0616
	,sum(oNc0716) oNc0716,sum(oNc0816) oNc0816,sum(oNc0916) oNc0916,sum(oNc1016) oNc1016,sum(oNc1116) oNc1116,sum(oNc1216) oNc1216
	from #CerDesem
	group by codoficina
)d
on c.codoficina=d.codoficina
--group by c.codoficina

--select * from #sumcer

select *
from (
select codoficina,2 it,'TOTAL' 'promotor', 'TOTAL' 'Coordinador'
,(case when De0114=0 then 0 else SC0114/De0114 end)*100 De0114,Nc0114
,(case when De0214=0 then 0 else SC0214/De0214 end)*100 De0214,Nc0214
,(case when De0314=0 then 0 else SC0314/De0314 end)*100 De0314,Nc0314
,(case when De0414=0 then 0 else SC0414/De0414 end)*100 De0414,Nc0414
,(case when De0514=0 then 0 else SC0514/De0514 end)*100 De0514,Nc0514
,(case when De0614=0 then 0 else SC0614/De0614 end)*100 De0614,Nc0614
,(case when De0714=0 then 0 else SC0714/De0714 end)*100 De0714,Nc0714
,(case when De0814=0 then 0 else SC0814/De0814 end)*100 De0814,Nc0814
,(case when De0914=0 then 0 else SC0914/De0914 end)*100 De0914,Nc0914
,(case when De1014=0 then 0 else SC1014/De1014 end)*100 De1014,Nc1014
,(case when De1114=0 then 0 else SC1114/De1114 end)*100 De1114,Nc1114
,(case when De1214=0 then 0 else SC1214/De1214 end)*100 De1214,Nc1214

,(case when De0115=0 then 0 else SC0115/De0115 end)*100 De0115,Nc0115
,(case when De0215=0 then 0 else SC0215/De0215 end)*100 De0215,Nc0215
,(case when De0315=0 then 0 else SC0315/De0315 end)*100 De0315,Nc0315
,(case when De0415=0 then 0 else SC0415/De0415 end)*100 De0415,Nc0415
,(case when De0515=0 then 0 else SC0515/De0515 end)*100 De0515,Nc0515
,(case when De0615=0 then 0 else SC0615/De0615 end)*100 De0615,Nc0615
,(case when De0715=0 then 0 else SC0715/De0715 end)*100 De0715,Nc0715
,(case when De0815=0 then 0 else SC0815/De0815 end)*100 De0815,Nc0815
,(case when De0915=0 then 0 else SC0915/De0915 end)*100 De0915,Nc0915
,(case when De1015=0 then 0 else SC1015/De1015 end)*100 De1015,Nc1015
,(case when De1115=0 then 0 else SC1115/De1115 end)*100 De1115,Nc1115
,(case when De1215=0 then 0 else SC1215/De1215 end)*100 De1215,Nc1215

,(case when De0116=0 then 0 else SC0116/De0116 end)*100 De0116,Nc0116
,(case when De0216=0 then 0 else SC0216/De0216 end)*100 De0216,Nc0216
,(case when De0316=0 then 0 else SC0316/De0316 end)*100 De0316,Nc0316
,(case when De0416=0 then 0 else SC0416/De0416 end)*100 De0416,Nc0416
,(case when De0516=0 then 0 else SC0516/De0516 end)*100 De0516,Nc0516
,(case when De0616=0 then 0 else SC0616/De0616 end)*100 De0616,Nc0616
,(case when De0716=0 then 0 else SC0716/De0716 end)*100 De0716,Nc0716
,(case when De0816=0 then 0 else SC0816/De0816 end)*100 De0816,Nc0816
,(case when De0916=0 then 0 else SC0916/De0916 end)*100 De0916,Nc0916
,(case when De1016=0 then 0 else SC1016/De1016 end)*100 De1016,Nc1016
,(case when De1116=0 then 0 else SC1116/De1116 end)*100 De1116,Nc1116
,(case when De1216=0 then 0 else SC1216/De1216 end)*100 De1216,Nc1216
from #sumcer
union
select codoficina, case when promotor='HUERFANO' then 1 else 0 end it,promotor,coordinador
,De0114,Nc0114,De0214,Nc0214,De0314,Nc0314,De0414,Nc0414,De0514,Nc0514,De0614,Nc0614
,De0714,Nc0714,De0814,Nc0814,De0914,Nc0914,De1014,Nc1014,De1114,Nc1114,De1214,Nc1214

,De0115,Nc0115,De0215,Nc0215,De0315,Nc0315,De0415,Nc0415,De0515,Nc0515,De0615,Nc0615
,De0715,Nc0715,De0815,Nc0815,De0915,Nc0915,De1015,Nc1015,De1115,Nc1115,De1215,Nc1215

,De0116,Nc0116,De0216,Nc0216,De0316,Nc0316,De0416,Nc0416,De0516,Nc0516,De0616,Nc0616
,De0716,Nc0716,De0816,Nc0816,De0916,Nc0916,De1016,Nc1016,De1116,Nc1116,De1216,Nc1216
from #SelectCER --where promotor='MCA2007851'
) a
where promotor<>'HUERFANO'

drop table #CER4
drop table #CerDesem
drop table #SelectCER
drop table #sumcer
GO