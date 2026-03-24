SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACAReestructurasCCE]
as 
declare @fecini smalldatetime
declare @fecfin smalldatetime
--set @fecini='20200501'
--set @fecfin='20200520'

select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

truncate table tCsACAReestructurasCCE

insert into tCsACAReestructurasCCE
exec [10.0.2.14].finmas.dbo.pCsACAReestructurasCCE @fecini,@fecfin

update tCsACAReestructurasCCE
set fechavencimiento_anterior=c.fechavencimiento
from tCsACAReestructurasCCE r with(nolock)
inner join tcscartera c with(nolock) on r.codprestamo=c.codprestamo and r.fechadesembolso=c.fecha

--select * from tCsACAReestructurasCCE
GO