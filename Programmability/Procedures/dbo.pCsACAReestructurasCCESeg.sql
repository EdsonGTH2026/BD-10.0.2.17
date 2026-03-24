SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACAReestructurasCCESeg]
as 
declare @fecini smalldatetime
declare @fecfin smalldatetime
--set @fecini='20200501'
--set @fecfin='20200520'

select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

truncate table tCsACAReestructurasCCESeg

insert into tCsACAReestructurasCCESeg
exec [10.0.2.14].finmas.dbo.pCsACAReestructurasCCESeg

--select * from tCsACAReestructurasCCESeg
--update tCsACAReestructurasCCE
--set fechavencimiento_anterior=c.fechavencimiento
--from tCsACAReestructurasCCE r with(nolock)
--inner join tcscartera c with(nolock) on r.codprestamo=c.codprestamo and r.fechadesembolso=c.fecha

--select * from tCsACAReestructurasCCESeg
--drop table tCsACAReestructurasCCESeg
--create table tCsACAReestructurasCCESeg(
--	codprestamo varchar(19),
--	cliente varchar(200),
--	fechareprog smalldatetime,
--	fechavencimiento smalldatetime,
--	cuotas int,
--	codtipoplaz char(1),
--	codoficina varchar(3),
--	sucursal varchar(100),
--	region varchar(30),
--	conpagosostenido tinyint,
--	fechapagosostenido smalldatetime,
--	nropagosacum tinyint
--)
GO