SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRieTransacionesAHFechaProd] @fecfin smalldatetime,  @codproducto varchar(3)
as
--declare @fecfin smalldatetime
--set @fecfin='20220126'
set nocount on
declare @fecini smalldatetime
set @fecini=dateadd(day,-7,@fecfin)
--declare @codproducto varchar(3)
--set @codproducto='111'

select fecha
,replicate('0',2-len(rtrim(tranhora)))+rtrim(tranhora)+':'+
 replicate('0',2-len(rtrim(tranminuto)))+rtrim(tranminuto)+':'+
 replicate('0',2-len(rtrim(transegundo)))+rtrim(transegundo)+'.'+cast(tranmicrosegundo as varchar(5)) hora
,codigocuenta codcuenta,fraccioncta,renovado,codoficina,tipotransacnivel1,tipotransacnivel2,tipotransacnivel3
,nombrecliente,descripciontran,montototaltran
from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='AH'
and substring(codigocuenta,5,3)=@codproducto
and extornado=0
GO

GRANT EXECUTE ON [dbo].[pRieTransacionesAHFechaProd] TO [rie_jaguilar]
GO

GRANT EXECUTE ON [dbo].[pRieTransacionesAHFechaProd] TO [ayescasc]
GO