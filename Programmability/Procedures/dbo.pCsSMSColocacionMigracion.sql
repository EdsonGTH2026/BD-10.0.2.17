SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [FinamigoConsolidado]
--GO
--/****** Object:  StoredProcedure [dbo].[pCsSMSColocacionMigracion]    Script Date: 08/08/2016 06:56:38 pm ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
----drop procedure pCsSMSColocacionMigracion
CREATE procedure [dbo].[pCsSMSColocacionMigracion]
as
Declare @FechaT 		SmallDateTime
Select @FechaT = dateadd(d,-1, FechaConsolidacion) From vCsFechaConsolidacion
--set @FechaT='20160611'
--select @FechaT
declare @ncli int
declare @mdia decimal(16,2)
declare @macu decimal(16,2)

--SELECT @ncli=count(codusuario),@mdia=sum(monto)
----select *
--FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet]
--where desembolso=@FechaT
--and codoficina<>'97'

select @ncli=count(codprestamo),@mdia=sum(montodesembolso)
--select '@ncli'=count(codprestamo),'@mdia'=sum(montodesembolso)
from [10.0.2.14].finmas.dbo.tcaprestamos
where fechadesembolso=@FechaT+1
and estado='VIGENTE'

SELECT @macu=sum(monto)+isnull(@mdia,0)
--select '@macu'=sum(monto)
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] with(nolock)
where desembolso>= dbo.fdufechaatexto(@FechaT,'AAAAMM')+'01' and codoficina<>'97'
and estadocalculado<>'ANULADO' and desembolso<=@FechaT
--11106

--select @ncli, @mdia, @macu

--if (@ncli>0)
--begin
	declare @cad varchar(200)
	set @cad='Colocación al día:'+ dbo.fdufechaatexto(@FechaT+1,'DD/MM/AAAA')+' #' + rtrim(ltrim(str(isnull(@ncli,0)))) + ' y $'+ CONVERT(VarChar(50), cast(isnull(@mdia,0) as money ), 1) + '; Cololacion acumulada: $' + CONVERT(VarChar(50), cast( @macu as money ), 1)
	print @cad

	Declare @Sistema 		Varchar(2)
	Declare @Celular		Varchar(50)
	Declare @Fecha			Varchar(15)
	Declare @Hora			Varchar(15)

	Set @Fecha 	= dbo.FduFechaATexto(GetDate(), 'AAAA')+ dbo.FduFechaATexto(GetDate(), 'MM') + dbo.FduFechaATexto(GetDate(), 'DD')
	Set @Hora	= CONVERT(VARCHAR(20), GETDATE(), 114)

	Set @Celular 	= '5515325837'--'5538774833'--
	Set @Sistema 	= 'CI'

	--Exec pSgInsertaEnColaSMS @Sistema, @Celular, @Fecha, @Hora, @cad
--end
--Colocación al día:13/06/16 #14 y $132,000.00; Cololacion acumulada: $7,629,272.00
--Colocación al día:11/06/16 #30 y $158,500.00; Cololacion acumulada: $7,497,272.00
--Colocación al día:10/06/16 #139 y $874,100.00; Cololacion acumulada: $7,357,272.00

--6,685,172.00
--select len('Colocación al día: #3 y $40000; Cololacion acumulada: $89417903') 63 caracteres 87 libres de 150
--select CONVERT(VarChar(50), cast( 89417903.1 as money ), 1)
GO