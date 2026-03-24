SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCoConReGeneraPolizaProgre
create procedure [dbo].[pCoConReGeneraPolizaProgre]
as
--declare @fecha smalldatetime
--set @fecha='20161231'
--print @fecha
create table #PD(
	i int identity(1,1),
	codprestamo varchar(25),
	secpago int,
	fecha smalldatetime,
	monto money,
	nombrecompleto varchar(250),
	capital money,
	interes money,
	iva money,
	sdv money,
	PAGTA money,
	codregistro int,
	origenpago varchar(10),
	tipopago varchar(2),
	codoficinapago varchar(4),
	codfondo varchar(5)
)

insert into #PD (codprestamo,secpago,fecha,monto,nombrecompleto,capital,interes,iva,sdv,PAGTA,origenpago,tipopago,codoficinapago,codfondo,codregistro)
SELECT c.codprestamo,pr.secpago,pr.fechapago,pr.montopago,u.nombrecompleto
,Sum(case when pd.codconcepto='CAPI' then pd.montopagado else 0 end) Capital
,Sum(case when pd.codconcepto='INTE' then pd.montopagado else 0 end) Interes
,Sum(case when pd.codconcepto='IVAIT' then pd.montopagado else 0 end) IVA--,sum(pd.montopagado) total
,Sum(case when pd.codconcepto='SDV' then pd.montopagado else 0 end) SDV
,Sum(case when pd.codconcepto='PAGTA' then pd.montopagado else 0 end) PAGTA
,pr.origenpago,pr.tipopago,pr.codoficina,c.codfondo
,pp.codregistro
FROM [10.0.2.14].finmas.dbo.[tCaPrestamos] c
inner join [10.0.2.14].finmas.dbo.[tcapagoreg] pr on pr.codprestamo=c.codprestamo
inner join [10.0.2.14].finmas.dbo.[tcapagodet] pd on pd.secpago=pr.secpago and pd.codoficina=pr.codoficina
inner join [10.0.2.14].finmas.dbo.[tususuarios] u on c.codusuario=u.codusuario
inner join [10.0.2.14].finmas.dbo.[APagosContaProgre] pp on pp.codprestamo=pr.codprestamo and pp.fechapago=pr.fechapago and pp.MontoPago=pr.MontoPago and pp.SecPago=pr.SecPago
where --c.codfondo=20 and 
pr.extornado=0 and pd.codconcepto in('CAPI','INTE','IVAIT','SDV','PAGTA')
and c.codoficina not in (230,231)
group by c.codprestamo,pr.secpago,pr.fechapago,pr.montopago,u.nombrecompleto,pr.origenpago,pr.tipopago,pr.codoficina,c.codfondo,pp.codregistro
order by c.codprestamo,pr.fechapago,pr.montopago

declare @i int
set @i=1

--select * from [10.0.2.14].finmas.dbo.[APagosContaProgre] 

declare @codprestamo varchar(25)
declare @secpago int
declare @fechaD smalldatetime
declare @monto money
declare @nombrecompleto varchar(250)
declare @capital money
declare @interes money
declare @iva money
declare @sdv money
declare @PAGTA money
declare @codregistro int
declare @OrigenPago varchar(5)
declare @codoficina int
declare @codoficinaAlta int
declare @tipopago varchar(2)
declare @codoficinapago varchar(4)
declare @codctaingreso varchar(15)
declare @codfondo varchar(2)

while(@i<=(select count(i) from #PD))
begin

	select @codprestamo=codprestamo,@fechaD=fecha,@monto=monto,@nombrecompleto=nombrecompleto,@capital=capital,@interes=interes,@iva=iva
	,@sdv=sdv,@PAGTA=PAGTA,@codregistro=codregistro,@OrigenPago=OrigenPago,@tipopago=tipopago,@codoficinapago=codoficinapago,@codfondo=codfondo from #PD where i=@i
	print str(@i)	+' '+ @codprestamo

	set @codctaingreso = case @OrigenPago
							  when '1' then '110110101'
							  when '5' then '110210101'

							  when 'DB' then '110210101'
							  when 'DC' then '110110102'
							  when 'DE' then '110110102'
							  when 'DI' then '110110102'
							  when 'DN' then '110110102'
							  when 'DO' then '140111707'
							  when 'DR' then '110110102'

							  when 'VB' then '110210101'
							  when 'VE' then '140111701'
							  when 'VI' then '140111701'
							  when 'VN' then '140110501'
							  when 'VO' then '140111707'
							  when 'VR' then '140111707'
							  when '4'  then '140111707'
							  else '' end
	set @codctaingreso = case when @tipopago='G' then '230210204' else @codctaingreso end
	set @codoficina=cast(substring(@codprestamo,1,3) as int)
	
	set @codoficinaAlta=(case when @codoficina>=100 and @codoficina<=229 then @codoficina + 200 else @codoficina end)
	
	select @codoficinaAlta=
			isnull((
			SELECT codoficina
			FROM tClOficinas with(nolock)
			where codoficina=@codoficinaAlta
			) ,@codoficinapago)

	if (@codregistro is not null)
	begin
	----Aqui comentar para no grabar
	delete from tcotradiadetalle where codregistro=@codregistro 
	if(@codfondo='20')
		begin
			insert into tcotradiadetalle (codregistro,item,codcta,codoficina,codfondo,tipLaux1,CodLAux1,tipLaux2,CodLAux2,tipLaux3,CodLAux3,debe,haber,glosa,tcambio,codmoneda,debesec,habersec,tcambiosec,debeori,haberori)
			select @codregistro codregistro,1 item
			,@codctaingreso codcta
			,case when @codctaingreso='110210101' then @codoficina else @codoficinaAlta end codoficina,'01' codfondo
			,case when @codctaingreso='110210101' then 16 else 0 end tipLaux1
			,case when @codctaingreso='110210101' then (case when @codoficina>=100 or @codoficina<300 then '7101219' else '1448746' end) else '' end CodLAux1
			,case when @codctaingreso='110210101' then 11 else 0 end tipLaux2,case when @codctaingreso='110210101' then 'transferencia' else '' end CodLAux2,0 tipLaux3,'' CodLAux3
			,@monto debe,0 haber
			,'COBRANZAS DEL PRESTAMO: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,@monto debesec,0 habersec,1,@monto debeori,0 haberori
			union
			select @codregistro codregistro,2 item,'130110101' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@capital*0.3 haber
			,'COBRANZA CAPI: '+@codprestamo+' P0r Recuperación de Credito' glosa,1 tcambio,6 codmoneda,0 debesec,@capital*0.3 habersec,1 tcambiosec,0 debeori,@capital*0.3 haberori
			union
			select @codregistro codregistro,3 item,'139110101' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@interes*0.3 haber
			,'COBRANZA INTE: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@interes*0.3 habersec,1,0 debeori,@interes*0.3 haberori
			union
			select @codregistro codregistro,4 item,'140110403' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@iva*0.3 haber
			,'COBRANZA IVAIT: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@iva*0.3 habersec,1,0 debeori,@iva*0.3 haberori
			union
			select @codregistro codregistro,5 item,'230310110' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@sdv haber
			,'COBRANZA SDV: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@sdv habersec,1,0 debeori,@sdv haberori
			union
			select @codregistro codregistro,6 item,'650111701' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@PAGTA haber
			,'COBRANZA PAGTA: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@PAGTA habersec,1,0 debeori,@PAGTA haberori
			union
			select @codregistro codregistro,7 item,'230310117' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,(@monto-@sdv-@PAGTA)*0.7 haber
			,'COBRANZA: '+@codprestamo+' Cuenta por pagar Progresemos' glosa,1,6,0 debesec,(@monto-@sdv-@PAGTA)*0.7 habersec,1,0 debeori,(@monto-@sdv-@PAGTA)*0.7 haberori
		end
	else
		begin
			insert into tcotradiadetalle (codregistro,item,codcta,codoficina,codfondo,tipLaux1,CodLAux1,tipLaux2,CodLAux2,tipLaux3,CodLAux3,debe,haber,glosa,tcambio,codmoneda,debesec,habersec,tcambiosec,debeori,haberori)
			select @codregistro codregistro,1 item
			,@codctaingreso codcta
			,case when @codctaingreso='110210101' then @codoficina else @codoficinaAlta end codoficina,'01' codfondo
			,case when @codctaingreso='110210101' then 16 else 0 end tipLaux1
			,case when @codctaingreso='110210101' then (case when @codoficina>=100 or @codoficina<300 then '7101219' else '1448746' end) else '' end CodLAux1
			,case when @codctaingreso='110210101' then 11 else 0 end tipLaux2,case when @codctaingreso='110210101' then 'transferencia' else '' end CodLAux2,0 tipLaux3,'' CodLAux3
			,@monto debe,0 haber
			,'COBRANZAS DEL PRESTAMO: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,@monto debesec,0 habersec,1,@monto debeori,0 haberori
			union
			select @codregistro codregistro,2 item,'130110101' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@capital haber
			,'COBRANZA CAPI: '+@codprestamo+' P0r Recuperación de Credito' glosa,1 tcambio,6 codmoneda,0 debesec,@capital habersec,1 tcambiosec,0 debeori,@capital haberori
			union
			select @codregistro codregistro,3 item,'139110101' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@interes haber
			,'COBRANZA INTE: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@interes habersec,1,0 debeori,@interes haberori
			union
			select @codregistro codregistro,4 item,'140110403' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@iva haber
			,'COBRANZA IVAIT: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@iva habersec,1,0 debeori,@iva haberori
			union
			select @codregistro codregistro,5 item,'230310110' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@sdv haber
			,'COBRANZA SDV: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@sdv habersec,1,0 debeori,@sdv haberori
			union
			select @codregistro codregistro,6 item,'650111701' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@PAGTA haber
			,'COBRANZA PAGTA: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@PAGTA habersec,1,0 debeori,@PAGTA haberori
		end
	end

	declare @d money
	declare @h money
	set @d=0
	set @h=0

	select @d=sum(debe), @h=sum(haber) from tcotradiadetalle with(nolock) where codregistro=@codregistro
	if(@d<>@h) print '@d:' + str(@d) + ' - @h:' + str(@h)

	print '---------------------------------'
	set @i=@i+1
end
--declare @i int
--set @i=1

--declare @codprestamo varchar(25)
--declare @secpago int
--declare @fechaD smalldatetime
--declare @monto money
--declare @nombrecompleto varchar(250)
--declare @capital money
--declare @interes money
--declare @iva money
--declare @sdv money
--declare @PAGTA money
--declare @codregistro int
--declare @OrigenPago varchar(5)
--declare @codoficina int
--declare @codoficinaAlta int
--declare @tipopago varchar(2)
--declare @codoficinapago varchar(4)
--declare @codctaingreso varchar(15)

--while(@i<=(select count(i) from #PD))
--begin

--	select @codprestamo=codprestamo,@fechaD=fecha,@monto=monto,@nombrecompleto=nombrecompleto,@capital=capital,@interes=interes,@iva=iva
--	,@sdv=sdv,@PAGTA=PAGTA,@codregistro=codregistro,@OrigenPago=OrigenPago,@tipopago=tipopago,@codoficinapago=codoficinapago from #PD where i=@i
--	print str(@i)	+' '+ @codprestamo

--	set @codctaingreso = case @OrigenPago
--							  when '1' then '110110101'
--							  when '5' then '110210101'

--							  when 'DB' then '110210101'
--							  when 'DC' then '110110102'
--							  when 'DE' then '110110102'
--							  when 'DI' then '110110102'
--							  when 'DN' then '110110102'
--							  when 'DO' then '140111707'
--							  when 'DR' then '110110102'

--							  when 'VB' then '110210101'
--							  when 'VE' then '140111701'
--							  when 'VI' then '140111701'
--							  when 'VN' then '140110501'
--							  when 'VO' then '140111707'
--							  when 'VR' then '140111707'
--							  when '4'  then '140111707'
--							  else '' end
--	set @codctaingreso = case when @tipopago='G' then '230210204' else @codctaingreso end
--	set @codoficina=cast(substring(@codprestamo,1,3) as int)
--	--print @codoficina
--	set @codoficinaAlta=(case when @codoficina>=100 and @codoficina<=229 then @codoficina + 200 else @codoficina end)
--	--print @codoficinaAlta
--	delete from tcotradiadetalle where codregistro=@codregistro
	
--	select @codoficinaAlta=
--			isnull((
--			SELECT codoficina
--			FROM tClOficinas with(nolock)
--			where codoficina=@codoficinaAlta
--			) ,@codoficinapago)

--	insert into tcotradiadetalle (codregistro,item,codcta,codoficina,codfondo,tipLaux1,CodLAux1,tipLaux2,CodLAux2,tipLaux3,CodLAux3,debe,haber,glosa,tcambio,codmoneda,debesec,habersec,tcambiosec,debeori,haberori)
--	----'110110102'
--	--select @codoficinapago
--	select @codregistro codregistro,1 item
--	,@codctaingreso codcta
--	,case when @codctaingreso='110210101' then @codoficina else @codoficinaAlta end codoficina,'01' codfondo
--	,case when @codctaingreso='110210101' then 16 else 0 end tipLaux1
--	,case when @codctaingreso='110210101' then (case when @codoficina>=100 or @codoficina<300 then '7101219' else '1448746' end) else '' end CodLAux1
--	,case when @codctaingreso='110210101' then 11 else 0 end tipLaux2,case when @codctaingreso='110210101' then 'transferencia' else '' end CodLAux2,0 tipLaux3,'' CodLAux3
--	,@monto debe,0 haber
--	,'COBRANZAS DEL PRESTAMO: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,@monto debesec,0 habersec,1,@monto debeori,0 haberori
--	union
--	select @codregistro codregistro,2 item,'130110101' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@capital*0.3 haber
--	,'COBRANZA CAPI: '+@codprestamo+' P0r Recuperación de Credito' glosa,1 tcambio,6 codmoneda,0 debesec,@capital*0.3 habersec,1 tcambiosec,0 debeori,@capital*0.3 haberori
--	union
--	select @codregistro codregistro,3 item,'139110101' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@interes*0.3 haber
--	,'COBRANZA INTE: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@interes*0.3 habersec,1,0 debeori,@interes*0.3 haberori
--	union
--	select @codregistro codregistro,4 item,'140110403' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@iva*0.3 haber
--	,'COBRANZA IVAIT: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@iva*0.3 habersec,1,0 debeori,@iva*0.3 haberori
--	union
--	select @codregistro codregistro,5 item,'230310110' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@sdv haber
--	,'COBRANZA SDV: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@sdv habersec,1,0 debeori,@sdv haberori
--	union
--	select @codregistro codregistro,6 item,'650111701' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,@PAGTA haber
--	,'COBRANZA PAGTA: '+@codprestamo+' P0r Recuperación de Credito' glosa,1,6,0 debesec,@PAGTA habersec,1,0 debeori,@PAGTA haberori
--	union
--	select @codregistro codregistro,7 item,'230310117' codcta,@codoficina codoficina,'01',0,'',0,'',0,'',0 debe,(@monto-@sdv-@PAGTA)*0.7 haber
--	,'COBRANZA: '+@codprestamo+' Cuenta por pagar Progresemos' glosa,1,6,0 debesec,(@monto-@sdv-@PAGTA)*0.7 habersec,1,0 debeori,(@monto-@sdv-@PAGTA)*0.7 haberori

--	declare @d money
--	declare @h money
--	set @d=0
--	set @h=0

--	select @d=sum(debe), @h=sum(haber) from tcotradiadetalle with(nolock) where codregistro=@codregistro
--	if(@d<>@h) print '@d:' + str(@d) + ' - @h:' + str(@h)

--	print '---------------------------------'
--	set @i=@i+1
--end

print 'Termino'
drop table #PD

--3.-Pago de credito  		
--110210101		Bancos 							100.00	
--130110101		Cartera de credito Finamigo				20.00
--139110101		Interes Credito Finamigo				5.87
--140110403		iva  credito finamigo					4.13
--230310117		Cuenta por pagar  Progresemos			70.00
GO