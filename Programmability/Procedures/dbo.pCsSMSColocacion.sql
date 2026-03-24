SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsSMSColocacion
CREATE procedure [dbo].[pCsSMSColocacion]
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
	set @cad='<ul><li>Colocación al día:'+ dbo.fdufechaatexto(@FechaT+1,'DD/MM/AAAA')+' #' + rtrim(ltrim(str(@ncli))) + ' y $'+ CONVERT(VarChar(50), cast( @mdia as money ), 1) 
	set @cad=@cad+'; Cololacion acumulada: $' + CONVERT(VarChar(50), cast( @macu as money ), 1) + '.<p>'
	--print @cad
	set @cad=@cad+'<li>Cololacion acumulada al:'+ dbo.fdufechaatexto(@m1,'DD/MM/AAAA')+': $' + CONVERT(VarChar(50), cast( @macu1 as money ), 1) + '.<p>'
	--print @cad
	set @cad=@cad+'<li>Cololacion acumulada al:'+ dbo.fdufechaatexto(@m2,'DD/MM/AAAA')+': $' + CONVERT(VarChar(50), cast( @macu2 as money ), 1) + '.<p>'
	--print @cad
	set @cad=@cad+'<li>Cololacion acumulada al:'+ dbo.fdufechaatexto(@m3,'DD/MM/AAAA')+': $' + CONVERT(VarChar(50), cast( @macu3 as money ), 1) + '.<p></ul>'

	--print @cad

	Declare @Sistema 		Varchar(2)
	Declare @Celular		Varchar(50)
	Declare @Fecha			Varchar(15)
	Declare @Hora			Varchar(15)

	Set @Fecha 	= dbo.FduFechaATexto(GetDate(), 'AAAA')+ dbo.FduFechaATexto(GetDate(), 'MM') + dbo.FduFechaATexto(GetDate(), 'DD')
	Set @Hora	= CONVERT(VARCHAR(20), GETDATE(), 114)

	Set @Celular 	= '5515325837'--'5538774833'
	Set @Sistema 	= 'CI'

	set @cad='Colocación al día:'+dbo.fdufechaatexto(@FechaT+1,'DD/MM/AAAA')+'|'+@cad	
	--Exec pSgInsertaEnColaSMS @Sistema, @Celular, @Fecha, @Hora, @cad
	--exec pSgInsertaEnColaServicio @Sistema,3,'lsanchez@finamigo.com.mx',@Fecha,@Hora,@cad
	exec pSgInsertaEnColaServicio @Sistema,3,'maristav@finamigo.com.mx;grazoc@finamigo.com.mx,curbizagastegui@finamigo.com.mx',@Fecha,@Hora,@cad
	--exec pSgInsertaEnColaServicio @Sistema,3,'curbizagastegui@finamigo.com.mx',@Fecha,@Hora,@cad
end
--Colocación al día:13/06/16 #14 y $132,000.00; Cololacion acumulada: $7,629,272.00
--Colocación al día:11/06/16 #30 y $158,500.00; Cololacion acumulada: $7,497,272.00
--Colocación al día:10/06/16 #139 y $874,100.00; Cololacion acumulada: $7,357,272.00

--6,685,172.00
--select len('Colocación al día: #3 y $40000; Cololacion acumulada: $89417903') 63 caracteres 87 libres de 150
--select CONVERT(VarChar(50), cast( 89417903.1 as money ), 1)

--exec pCsSMSColocacion
GO

GRANT EXECUTE ON [dbo].[pCsSMSColocacion] TO [marista]
GO