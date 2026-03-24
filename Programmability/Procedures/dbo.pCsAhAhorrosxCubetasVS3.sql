SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAhAhorrosxCubetasVS3] @fecha smalldatetime
as

--declare @fecha smalldatetime
--set @fecha='20200805'

select 
--replicate('0',2-len(a.codoficina)) + a.codoficina +' '+o.nomoficina sucursal
case when substring(codcuenta,5,1)='1' then 'Vista' else 'Inversiones' end tipo
,case when substring(codcuenta,5,1)='1' then
		case when codproducto='111' then 'Vista - Garantias'
			 when codproducto in('112','113','114') then 'Vista - Cuentas Digitales'
			 else 'Vista - Basica' end
	 else 
		case when a.codoficina='98' then 'Inversiones - Corporativo'
			 else 'Inversiones - Sucursales' end
	 end categoria
,case when substring(codcuenta,5,1)='1' then 
		case codproducto when '112' then 'Miio'
						 when '113' then 'DbMenos'
						 when '114' then 'Taurus'
						 else '' end
	else '' end subtipo
,count(distinct(a.codusuario)) Tnrocli
,count(distinct(a.codcuenta)) Tnrocta
,sum(a.saldocuenta + a.intacumulado) TSaldoCuenta

,count(distinct(case when substring(a.codcuenta,5,1)=1 then a.codusuario else null end)) spnrocli
,count(distinct(case when substring(a.codcuenta,5,1)=1 then a.codcuenta else null end)) spnrocta
,sum(case when substring(a.codcuenta,5,1)=1 then a.saldocuenta + a.intacumulado else 0 end) spsaldocuenta

,count(distinct(case when substring(a.codcuenta,5,1)=2 then a.codusuario else null end)) cpnrocli
,count(distinct(case when substring(a.codcuenta,5,1)=2 then a.codcuenta else null end)) cpnrocta
,sum(case when substring(a.codcuenta,5,1)=2 then a.saldocuenta + a.intacumulado else 0 end) cpsaldocuenta

,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=1 and a.plazo<=30 then a.codusuario else null end) else null end)) cpnrocli1a30
,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=1 and a.plazo<=30 then a.codcuenta else null end) else null end)) cpnrocta1a30
,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=1 and a.plazo<=30 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta1a30

,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=31 and a.plazo<=60 then a.codusuario else null end) else null end)) cpnrocli30a60
,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=31 and a.plazo<=60 then a.codcuenta else null end) else null end)) cpnrocta30a60
,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=31 and a.plazo<=60 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta30a60

,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=61 and a.plazo<=120 then a.codusuario else null end) else null end)) cpnrocli60a120
,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=61 and a.plazo<=120 then a.codcuenta else null end) else null end)) cpnrocta60a120
,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=61 and a.plazo<=120 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta60a120

,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=121 and a.plazo<=180 then a.codusuario else null end) else null end)) cpnrocli120a180
,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=121 and a.plazo<=180 then a.codcuenta else null end) else null end)) cpnrocta120a180
,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=121 and a.plazo<=180 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta120a180

,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=181 and a.plazo<=365 then a.codusuario else null end) else null end)) cpnroclim180a365
,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=181 and a.plazo<=365 then a.codcuenta else null end) else null end)) cpnroctam180a365
,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=181 and a.plazo<=365 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuentam180a365

,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=366 then a.codusuario else null end) else null end)) cpnroclim365
,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=366 then a.codcuenta else null end) else null end)) cpnroctam365
,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=366 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuentam365

from tcsahorros a with(nolock)
inner join tcloficinas o with(nolock) on a.codoficina=o.codoficina
where fecha=@fecha--'20151025'
group by --replicate('0',2-len(a.codoficina)) + a.codoficina +' '+o.nomoficina
case when substring(codcuenta,5,1)='1' then
		case when codproducto='111' then 'Vista - Garantias'
			 when codproducto in('112','113','114') then 'Vista - Cuentas Digitales'
			 else 'Vista - Basica' end
	 else 
		case when a.codoficina='98' then 'Inversiones - Corporativo'
			 else 'Inversiones - Sucursales' end
	 end
,case when substring(codcuenta,5,1)='1' then 'Vista' else 'Inversiones' end 
,case when substring(codcuenta,5,1)='1' then 
		case codproducto when '112' then 'Miio'
						 when '113' then 'DbMenos'
						 when '114' then 'Taurus'
						 else '' end
	else '' end
GO