SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaAplicarPagosTransaccionUnicaAhProgresemos2](@fecha smalldatetime)
as
BEGIN
--Ver. 31-10-2020: SP para insertar transaccion ahorro a cuenta PROGRESEMOS
	set nocount on
/*
	--<<<<<<<<<<< COMENTAR
	declare @fecha smalldatetime
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion
	--select @fecha=fechaproceso from dbo.tClParametros where codoficina = '98'
	set @fecha='20201031'
	-->>>>>>>>>>> COMENTAR
	*/

	--<<<<<<<<<<<<<<<<<<<<<<<<<<<< Tabla Temporal PAGOS	Finmas
	declare    @TCMes      Decimal(18,7)
	declare    @MantValor	Decimal(18,7)
	set @TCMes = 0.0
	set @MantValor = 0.0

	declare @Conceptos table (
		CodConcepto varchar(5),
		TipoTransacNivel3 tinyint,
		DescripcionTran varchar(50)
	)

	insert into @Conceptos values('CLC'  , 97 , 'Comision Lineas de Credito')
	insert into @Conceptos values('CPI'  , 98 , 'Comision Por Investigacion')
	insert into @Conceptos values('IVCPI', 98 , 'Comision Por Investigacion')
	insert into @Conceptos values('CMC'  , 99 , 'Comision Manejo de Cuenta')
	insert into @Conceptos values('IVAMC', 99 , 'Comision Manejo de Cuenta')
	insert into @Conceptos values('SDC'  , 100, 'Seguro de Credito')
	insert into @Conceptos values('IVASC', 100, 'Seguro de Credito')
	insert into @Conceptos values('COM'  , 101, 'Comision Apertura de Credito')
	insert into @Conceptos values('IVACO', 101, 'Comision Apertura de Credito')

	--*******************   4. RECUPERACION, PAGOS DE RENEGOCIACION  ********************--
	SELECT 4 as Sistemas, dbo.fduFechaAAAAMMDD(R.FechaPago) As Fecha, R.CodPrestamo as CodigoCuenta, 'CA' as CodSistema, 
		   datepart(hh,FechaHoraReal) Hora, 
		   datepart(mi,FechaHoraReal) Minuto, 
		   datepart(ss,FechaHoraReal) Segundo, 
		   datepart(ms, FechaHoraReal) Milisegundo, 
		   R.CodOficina, P.CodOficina CodOFicinaCuenta, R.SecPago,
		   TipoTransacNivel1 = 'I',
		   TipoTransacNivel2 = IsNull(D.CodServicio, 'OTRO'),
		   TipoTransacNivel3 = --case when R.TipoPago = ''
							   --     then 
										   case when P.Estado = 'CANCELADO' then 105 else 104 end,
							   --     else 106 end,
		   R.Extornado,
		   TipoCambio = case P.CodMoneda when '2' then isnull(@TCMes,0) when '3' then isnull(@MantValor,0) else 1 end,
		   Us.NombreCompleto,
		   DescripcionTran = --case when R.TipoPago = ''
							 --     then 
										 case when P.Estado = 'CANCELADO' then 'Cancelación'  else 'Recuperación' end
							 --     else R.TipoPago
							 --end 
							 + ' ' + isnull(D.CodServicio, 'N.E.'),
		   CodCajero = IsNull(dbo.fGeneraCodUsuarioConso(R.CodCajero), 'No Registra'),
		   P.CodMoneda,
		   MontoCapitalTran = isnull(G.CAPI, 0),
		   MontoInteresTran = isnull(G.INTE, 0),
		   MontoINVETran    = isnull(G.INVE, 0),
		   MontoINPETran    = isnull(G.INPE, 0),
		   MontoCargos      = ISNULL(G.CARG, 0),
		   MontoOtrosTran   = isnull(G.OTRO, 0),
		   MontoImpuestos   = isnull(G.IMPU, 0),
		   R.MontoPago MontoTotalTran, ISNULL(D.CodEntidad,'') CodBanco, ISNULL(D.NumCuenta,'') NroCuenta, ISNULL(NumCheque,'') NroCheque,
		   CodUsuario = isnull(dbo.fGeneraCodUsuarioConso(Us.CodUsuario),'98UMC1809791'), 
		   CodAsesor  = isnull(dbo.fGeneraCodUsuarioConso(P.CodAsesor),'98UMC1809791'),
		   P.FechaDesembolso, P.FechaVencimiento, P.CodProducto
		, R.origenpago as CodDestino --P.CodActividadDes
		, P.CodTipoCredito, S.TasaInteres, Isnull(D.NroSecuencial, 0) as NroSecuencial,
		   CodMotivo = Isnull(D.CodMotivo, 0), MontoDescontado = 0, R.SecPago as nrotransaccion --SecPago
		   
	into #tmpPagosFinmas
	FROM   [10.0.2.14].finmas.dbo.tCaPagoReg R 
	LEFT   JOIN [10.0.2.14].finmas.dbo.tCaPrestamos P  ON R.CodPrestamo = P.CodPrestamo
	LEFT   JOIN [10.0.2.14].finmas.dbo.tCaSolicitud S  ON S.CodSolicitud= P.CodSolicitud And S.CodOficina = P.CodOficina And S.CodProducto = P.CodProducto
	LEFT   JOIN [10.0.2.14].finmas.dbo.tCaDetPago   D  ON D.SecPago     = R.SecPago and R.CodOficina = D.CodOficina
	left join
	(  select SecPago, CodOficina, capi = sum(capi), inte = sum(inte), inve = sum(inve), inpe = sum(inpe), CARG = sum(CARG), otro = sum(otro), IMPU = sum(IMPU)
	   from
	   (  select SecPago, CodOficina,
				 CAPI = case when CodConcepto = 'CAPI' then MontoPagado else 0 end,
				 INTE = case when CodConcepto = 'INTE' then MontoPagado else 0 end,
				 INVE = case when CodConcepto in('INVE','RST') then MontoPagado else 0 end,
				 INPE = case when CodConcepto = 'INPE' then MontoPagado else 0 end,
				 CARG = case when CodConcepto in('MORA','PAGTA') then MontoPagado else 0 end,
				 IMPU = case when CodConcepto like 'IV%' then MontoPagado else 0 end,
				 OTRO = case when CodConcepto not in ('CAPI', 'INTE', 'INVE','RST', 'INPE', 'MORA','PAGTA') AND CodConcepto Not like 'IV%'
							 then MontoPagado else 0 end
		  from
		  (  select SecPago, CodOficina, CodConcepto, sum(MontoPagado) MontoPagado
			 from [10.0.2.14].finmas.dbo.tCaPagoDet 
			 group by SecPago, CodOficina, CodConcepto
		  ) G1
	   ) G2
	   group by SecPago, CodOficina
	) G on R.CodOficina = G.CodOficina and R.SecPago = G.SecPago
	INNER  JOIN [10.0.2.14].finmas.dbo.tClMonedas   M  ON M.CodMoneda   = P.CodMoneda
	INNER  JOIN [10.0.2.14].finmas.dbo.tUsUsuarios Us  ON Us.CodUsuario = P.CodUsuario
	Where R.FechaPago >= @fecha AND R.FechaPago <= @fecha -- R.CodOficina = @CodOficina AND 

	--select * from #tmpPagosFinmas
	-->>>>>>>>>>>>>>>>>>>>>>>>>>>> Tabla Temporal PAGOS	



	create table #rst(
		codprestamo varchar(25),
		fecha smalldatetime,
		secpago int,
		rst money,
		ivarst money
	)

	insert into #rst
	select p.codprestamo,p.fechapago,p.secpago,co.rst,co.ivarst
	from [10.0.2.14].finmas.dbo.tcapagoreg p --with(nolock)
	inner join (
		select secpago,codoficina
		--,sum(case when codconcepto='CAPI'  then montopagado else 0 end) capital
		--,sum(case when codconcepto='INTE'  then montopagado else 0 end) interes
		--,sum(case when codconcepto='IVAIT'  then montopagado else 0 end) ivainteres
		,sum(case when codconcepto='RST'  then montopagado else 0 end) rst
		,sum(case when codconcepto='IVART'  then montopagado else 0 end) ivarst
		--,sum(case when codconcepto='MORA'  then montopagado else 0 end) cargomora
		--,sum(case when codconcepto='IVAMO'  then montopagado else 0 end) ivacargomora
		--,sum(case when codconcepto='SVD'  then montopagado else 0 end)  seguro
		--,sum(case when codconcepto='SDD'  then montopagado else 0 end)  segurodeu
		from [10.0.2.14].finmas.dbo.tcapagodet d --with(nolock)
		group by secpago,codoficina
	) co on co.secpago=p.secpago and co.codoficina=p.codoficina
	where p.fechapago=@fecha
	and co.rst<>0

	--select * from #rst --COMENTAR
	--132 pagos prueba

	create table #Pagos(
		codprestamo varchar(25),
		fechapago smalldatetime,
		pagototal money,
		capitaltotal money,
		interestotal money,
		ivatotal money,
		origenpago varchar(5),
		tipopago varchar(15),
		rst money
	)

	insert into #Pagos
	select 
	t.codigocuenta codprestamo,	
	t.fecha fechapago
	,t.montocapitaltran+t.montointerestran+t.montointerestran*0.16 
		+ (case when t.montoinvetran<>0 then t.montoinvetran else (case when t.montootrostran<>0 then isnull(r.rst,0) else 0 end) end)
		+ (case when t.montoinvetran<>0 then 0 else (case when t.montootrostran<>0 then isnull(r.ivarst,0) else 0 end) end) pagototal
	,t.montocapitaltran capitatotal,t.montointerestran interestotal
	,t.montointerestran*0.16 + (case when t.montoinvetran<>0 then 0 else (case when t.montootrostran<>0 then isnull(r.ivarst,0) else 0 end) end) ivatotal
	,t.coddestino
	,case when t.tipotransacnivel3 in(104,105) then 'Pago' else 'Condonación' end tipopago
	,case when t.montoinvetran<>0 then t.montoinvetran else (case when t.montootrostran<>0 then isnull(r.rst,0) else 0 end) end montorst
	from 
	--FinamigoConsolidado.dbo.tcstransacciondiaria t with(nolock)
	#tmpPagosFinmas as t with(nolock)
	left outer join #rst r with(nolock) 
	on r.fecha=t.fecha and r.codprestamo=t.codigocuenta and r.secpago= t.nrotransaccion
	where t.fecha= @fecha 
	and t.codsistema='CA' and t.extornado=0 and t.tipotransacnivel3 in(104,105,2) --not in(102,3,0,2)
	and t.tipotransacnivel1<>'E'
	--2683 reg prueba

	--select * from #Pagos  --comentar

	--2764
	select p.codprestamo,cl.nombrecompleto cliente,pd.desembolso fechaotorgamiento
	,c.fechavencimiento,p.fechapago,p.pagototal,p.capitaltotal,p.interestotal,p.ivatotal
	,p.pagototal*0.7 pagoprogresemos
	,p.capitaltotal*0.7 capitalprogresemos,p.interestotal*0.7 interesprogresemos,p.ivatotal*0.7 ivaprogresemos
	,case when p.tipopago='Condonacion' then '' else (case when p.origenpago in('3','4','5','DB','VB','7') then 'Bancos' else 'Efectivo' end) end procedenciapago
	,c.tiporeprog
	,p.tipopago
	,p.rst
	,p.rst*0.7 rstprogresemos
	into #Final
	from #Pagos p with(nolock)
	inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=p.codprestamo
	inner join tcscartera c with(nolock) on c.codprestamo=pd.codprestamo and c.fecha=pd.fechacorte
	inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
	where c.codfondo=20

	--select * from #Final where tipopago = 'PAGO' compute sum(pagoprogresemos)
	select sum(pagoprogresemos) as 'TotalPagoProgresemos' from #Final where tipopago = 'PAGO' 


	--<<<<<<< Inserta el pago en finmas
		declare @CodCuentaAh varchar(20)
		declare @MontoDeposito money
		declare @Observaciones varchar(200)
		declare @Cajero varchar(20)
		declare @CodOfi varchar(3)
		declare @Maquina varchar(20)
		declare @cliente varchar(50)
		declare @codprestamo varchar(20)
		declare @fechapago smalldatetime
		declare @procedenciapago varchar(20)

		declare @NroTrans float                          --Número de transacción
		declare @Secuencial NUMERIC

		--declare @SumatoriaMonto money
		declare @MontoGlobal money

		--set @CodCuentaAh = '098-105-06-2-7-00192'  --Cuenta miriam prueba
		set @CodCuentaAh = '098-105-06-2-5-00199' --cuenta progresemos
		set @Cajero = '98CSM1803891' --Usuario Miriam
		set @CodOfi = '98'
		set @Maquina = 'Servidor'
		--set @SumatoriaMonto = 0
		declare @TotReg int
		
		select @TotReg = count(*) from #Final where tipopago = 'PAGO' 

		select @MontoGlobal = sum(pagoprogresemos) from #Final where tipopago = 'PAGO' 
		set @MontoGlobal = isnull(@MontoGlobal,0)

		if @MontoGlobal > 0 
		begin
			--realiza el abono a la cuenta       
			--<<<<<<<<< secuencial  
			set @Secuencial = 0
			exec [10.0.2.14].Finmas.dbo.pAhObtieneSecuencial @CodOfi, @Secuencial OUTPUT
			--select @Secuencial as '@Secuencial'
			-->>>>>>>>>
		    
			set @Observaciones = 'Cobranza Progresemos, FechaPago[' + convert(varchar,@fecha,112) +'], MontoGlobal[' + convert(varchar,@MontoGlobal) + '], TotalCreditos['+ convert(varchar,@TotReg) +']'
		    
			--select @fechaProceso, @MontoGlobal, @TotReg
			--select @Observaciones

			--exec finmas_20200615ini.dbo.PAHCreaTransaccion
			exec [10.0.2.14].finmas.dbo.PAHCreaTransaccion
			@CodOficina = @CodOfi,
			@CodCajero 	= @Cajero,
			@CodCta  = @CodCuentaAh,  --cuenta desposito
			@TipoTrans 	= 4, --> Nota de abono
			@CodFormaTrans	= 5,
			@Monto 	=	@MontoGlobal,
			@TipoCambio  = 0,
			@Obs 	= @Observaciones,	
			@Fecha 	= @fecha,
			@CodSistema	= 'AH',
			@Operacion	= 0,		--0=credito y 1=Debito --- NO SE USA LA VARIABLE OPERACION SE VALIDA CON LA TRANSACCION Y SE REUTILIZA PARA EL MONTO DE LA CUENTA 16/12/2004 SAC
			@Param1 = '',	--Para Cheque:NumCheque
			@Param2 = '',	--Para Cheque:CodTipoEntidad
			@Param3 = '',	--Para Cheque:CodEntidad
			@Param4 = '',	--Para Cheque:NroCuentaInt	
			@NroSecuencial = @Secuencial, 
			@Motivo = 0,
			@NumTrans = @NroTrans OUTPUT, -- 	float OUTPUT,
			@NomMaquina = @Maquina		

		end
		
		select @Secuencial as '@Secuencial', @NroTrans as '@NroTrans'
		select @MontoGlobal as 'MontoGlobal'
		
		print '@Secuencial [' + convert(varchar,@Secuencial) + '], @NroTrans [' + convert(varchar,@NroTrans) + ']'
		print 'total Prestamos[' + convert(varchar,@TotReg) + ']  ,@MontoGlobal [' + convert(varchar,@MontoGlobal) + ']'
	-->>>>>>> Inserta el pago en finmas


	drop table #Pagos
	drop table #rst
	drop table #Final
	drop table #tmpPagosFinmas

END
GO