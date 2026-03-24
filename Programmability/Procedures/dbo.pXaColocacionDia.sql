SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [FinamigoConsolidado]
--GO
--/****** Object:  StoredProcedure [dbo].[pCsSMSColocacion]    Script Date: 18/12/2017 04:39:52 pm ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
----drop procedure pXaColocacionDia
CREATE procedure [dbo].[pXaColocacionDia]
as
Declare @FechaT 		SmallDateTime
Select @FechaT = FechaConsolidacion From vCsFechaConsolidacion
--set @FechaT='20170629'

declare @ncli int
declare @mdia decimal(16,2)
declare @macu decimal(16,2)

select @ncli=count(codprestamo),@mdia=sum(montodesembolso)
--select '@ncli'=count(codprestamo),'@mdia'=sum(montodesembolso)
from [10.0.2.14].finmas.dbo.tcaprestamos
where fechadesembolso=@FechaT+1 and estado='VIGENTE'
--select @ncli
SELECT @macu=sum(monto)+@mdia
--select '@macu'=sum(monto)
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] with(nolock)
where desembolso>=dbo.fdufechaatexto(@FechaT+1,'AAAAMM')+'01' and codoficina<>'97'
and estadocalculado<>'ANULADO' and desembolso<=@FechaT

declare @m1 smalldatetime
declare @m2 smalldatetime
declare @m3 smalldatetime
set @m1=dateadd(month,-1,@FechaT+1)
set @m2=dateadd(month,-2,@FechaT+1)
set @m3=dateadd(month,-3,@FechaT+1)

--print @m1
--print @m2
--print @m3

declare @macu1 decimal(16,2)
declare @macu2 decimal(16,2)
declare @macu3 decimal(16,2)

SELECT @macu1=sum(monto) FROM tCsPadronCarteraDet with(nolock)
where desembolso>=dbo.fdufechaatexto(@m1,'AAAAMM')+'01' and codoficina<>'97' and estadocalculado<>'ANULADO' and desembolso<=@m1

SELECT @macu2=sum(monto) FROM tCsPadronCarteraDet with(nolock)
where desembolso>=dbo.fdufechaatexto(@m2,'AAAAMM')+'01' and codoficina<>'97' and estadocalculado<>'ANULADO' and desembolso<=@m2

SELECT @macu3=sum(monto) FROM tCsPadronCarteraDet with(nolock)
where desembolso>=dbo.fdufechaatexto(@m3,'AAAAMM')+'01' and codoficina<>'97' and estadocalculado<>'ANULADO' and desembolso<=@m3

--11106
if (@ncli>0)
begin
	declare @cad varchar(2000)
	select 'Colocación al día:'+ dbo.fdufechaatexto(@FechaT+1,'DD/MM/AAAA')+' #' + rtrim(ltrim(str(@ncli))) + ' y $'+ CONVERT(VarChar(50), cast( @mdia as money ), 1) item
	union
	select 'Cololacion acumulada al día: '+ dbo.fdufechaatexto(@FechaT+1,'DD/MM/AAAA')+' y $' + CONVERT(VarChar(50), cast( @macu as money ), 1) + '.' item
	union
	select 'Cololacion acumulada al:'+ dbo.fdufechaatexto(@m1,'DD/MM/AAAA')+' y $' + CONVERT(VarChar(50), cast( @macu1 as money ), 1) + '.' item
	union 
	select 'Cololacion acumulada al:'+ dbo.fdufechaatexto(@m2,'DD/MM/AAAA')+' y $' + CONVERT(VarChar(50), cast( @macu2 as money ), 1) + '.' item
	union 
	select 'Cololacion acumulada al:'+ dbo.fdufechaatexto(@m3,'DD/MM/AAAA')+' y $' + CONVERT(VarChar(50), cast( @macu3 as money ), 1) + '.' item

end
GO