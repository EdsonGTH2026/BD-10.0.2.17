SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pMseMensaje

Create Procedure [dbo].[pMseMensaje]
@Dato 		Int,
@Saldo 		Decimal(18,4),
@aSaldo		Decimal(18,4),
@Mora		Decimal(18,4),
@aMora		Decimal(18,4),
@Real		Decimal(18,4),
@aReal		Decimal(18,4),
@Estimacion	Decimal(18,4),
@aEstimacion	Decimal(18,4),
@Mensaje 	Varchar(500) OutPut
As

Print '@Dato 		: ' +  CAST(@Dato AS Varchar(15)) 	
Print '@Saldo 		: ' +  CAST(@Saldo AS Varchar(15)) 	
Print '@aSaldo		: ' +  CAST(@aSaldo AS Varchar(15)) 	
Print '@Mora		: ' +  CAST(@Mora AS Varchar(15)) 	
Print '@aMora		: ' +  CAST(@aMora AS Varchar(15)) 	
Print '@Real		: ' +  CAST(@Real AS Varchar(15)) 	
Print '@aReal		: ' +  CAST(@aReal AS Varchar(15)) 	
Print '@Estimacion	: ' +  CAST(@Estimacion AS Varchar(15)) 	
Print '@aEstimacion	: ' +  CAST(@aEstimacion AS Varchar(15)) 	

If @Dato = 1	-- DIARIO
Begin
	Set @Mensaje = Case
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion And @Mora = 0
				Then  '01En pleno crecimiento, indicadores estables (EXITOS)'
				When  @Saldo > @aSaldo And @Mora < @aMora And @Real < @aReal And @Estimacion <= @aEstimacion 
				Then  '02Un día Excelente, superamos los indicadores de ayer'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '03Un día Bueno, superamos los indicadores de ayer'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion = @aEstimacion And @Mora = 0
				Then  '04Un día Bueno, superamos los indicadores de ayer'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '05Un día regular un poco más de colocación y superamos los objetivos'
				When  @Saldo = @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '06Poca variación en los indicadores, poco dinamismo en la operativa'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,2) = Round(@aEstimacion,2) And @Mora = 0
				Then  '07La cartera atrasada esta creciendo y puede perjudicar los indicadores'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,1) = Round(@aEstimacion,1) And @Mora = 0
				Then  '08La cartera atrasada esta creciendo y puede perjudicar los indicadores'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,0) = Round(@aEstimacion,0) And @Mora = 0
				Then  '09La cartera atrasada esta creciendo y puede perjudicar los indicadores'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '10La cartera atrasada esta creciendo y puede perjudicar los indicadores'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '11La cartera atrasada esta creciendo y puede perjudicar los indicadores'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion <= @aEstimacion And @Mora > 0
				Then  '12Casi lo logras el Indicador de Mora se mantiene igual q ue ayer'
				When  @Saldo > @aSaldo And @Mora <= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '13Existe creditos vencidos con saldos altos que hacen subir la Estimación P.'
				When  @Saldo >= @aSaldo And @Mora < @aMora And @Real = @aReal And @Estimacion < @aEstimacion 
				Then  '14Se observa buenas colocaciones, pero hay que fijarse en los atrasados'
				When  @Saldo > @aSaldo And @Mora <= @aMora And @Real > @aReal And @Estimacion <= @aEstimacion 
				Then  '15Índice moratorio podría empeorar, recuperar creditos >= 1 día'
				When  @Saldo >= @aSaldo And @Mora <= @aMora And @Real > @aReal And @Estimacion >= @aEstimacion 
				Then  '16Van a pasar a Cartera Vencida Créditos Altos, la Mora subirá'		
				When  @Saldo = @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '17No hay dinamismo en la operativa, hay que colocar más'	
				When  @Saldo >= @aSaldo And @Mora >= @aMora And @Real <= @aReal And @Estimacion < @aEstimacion 
				Then  '18La colocación sigue bien, pero se descuida la Cartera Vencida'			
				When  @Saldo >= @aSaldo And @Mora >= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '19La Cartera Vencida sube, tomar medidas'
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 >= 1 And @Mora > @aMora And @Real > @aReal And @Estimacion < @aEstimacion
				Then  '20Nos concentramos en colocar y ¿Qué paso con las recuperaciones?'				
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 >= 1 And @Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion
				Then  '21Nos concentramos en colocar y ¿Qué paso con las recuperaciones?'	
				When  ABS(Round(@Saldo,0) - Round(@aSaldo,0)) <= 1 And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion
				Then  '22No se observa cambio alguno en la cartera analizada'				
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 < 1 And
				      (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 > 0 And
					@Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion
				Then  '23Mínimo Crecimiento de Cartera, y los Indicadores empeoraron'	
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion
				Then  '24Falta Colocar, debemos ir en busqueda de nuevos clientes'							
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '25Un día malo en las colocaciones, las recuperaciones fueron altas'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '26Un día malo en las colocaciones, las recuperaciones fueron altas'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion <= @aEstimacion And @Mora = 0
				Then  '27Falta Colocar y se esta decuidando la cartera atrasada'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '28Falta Colocar y se esta decuidando la cartera atrasada'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real <= @aReal And @Estimacion < @aEstimacion 
				Then  '29Recuerden que la idea no solo es recuperar, tambien se debe colocar'
				When  @Saldo < @aSaldo And @Mora <= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '30Recuerden que la idea no solo es recuperar, tambien se debe colocar'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real > @aReal And @Estimacion < @aEstimacion 
				Then  '31Se recuperó cartera vencida, se descuido la atrasada y falta colocar'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '32Se recuperó cartera vencida, se descuido la atrasada y falta colocar'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion < @aEstimacion
				Then  '33Falta Colocar, debemos ir en busqueda de nuevos clientes'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real >= @aReal And @Estimacion > @aEstimacion
				Then  '34Falta Colocar, debemos ir en busqueda de nuevos clientes'				
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real <= @aReal And @Estimacion <= @aEstimacion 		
				Then  '35Se recuperó y no se coloco, ir en búsqueda de nuevos clientes'
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '36Enfocarse en la colocación y recuperación de créditos >= a 90 días'	
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real > @aReal And @Estimacion < @aEstimacion 
				Then  '37Se observa que se  esta descuidando la cartera, se necesita colocar más'				
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '38Día malo, tenemos que enfocarnos en la colocación y recuperación'							
		       End
End 
If @Dato = 2	-- MENSUAL
Begin
	Set @Mensaje = Case
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion And @Mora = 0
				Then  '01En pleno crecimiento, indicadores estables (EXITOS)'
				When  @Saldo > @aSaldo And @Mora < @aMora And @Real < @aReal And @Estimacion <= @aEstimacion  
				Then  '02Felicidades, excelente mes mejoramos nuestros indicadores'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '03Felicidades, mejoramos los Indicadores respecto al mes pasado'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion = @aEstimacion And @Mora = 0
				Then  '04Felicidades, mejoramos los Indicadores respecto al mes pasado'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '05Un Mes regular un poco más de colocación y superamos los objetivos'
				When  @Saldo = @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '06Poca variación en mes de los indicadores, poco dinamismo en la operativa'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,2) = Round(@aEstimacion,2) And @Mora = 0
				Then  '07Este mes la cartera atrasada crece respecto al mes pasado y perjudica'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,1) = Round(@aEstimacion,1) And @Mora = 0
				Then  '08Este mes la cartera atrasada crece respecto al mes pasado y perjudica'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,0) = Round(@aEstimacion,0) And @Mora = 0
				Then  '09Este mes la cartera atrasada crece respecto al mes pasado y perjudica'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '10Este mes la cartera atrasada crece respecto al mes pasado y perjudica'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '11Este mes la cartera atrasada crece respecto al mes pasado y perjudica'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion <= @aEstimacion And @Mora > 0
				Then  '12Casi todo bien en este mes aunque la mora lo mantuviste igual'
				When  @Saldo > @aSaldo And @Mora <= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '13Este mes dejamos creditos vencidos altos que nos perjudican la Estimación'
				When  @Saldo >= @aSaldo And @Mora < @aMora And @Real = @aReal And @Estimacion < @aEstimacion 
				Then  '14En el mes buenas colocaciones, pero hay que fijarse en los atrasados'
				When  @Saldo > @aSaldo And @Mora <= @aMora And @Real > @aReal And @Estimacion <= @aEstimacion 
				Then  '15Este mes la cartera atrasada sube, el indicador de mora podría dispararse'
				When  @Saldo >= @aSaldo And @Mora <= @aMora And @Real > @aReal And @Estimacion >= @aEstimacion 
				Then  '16Este mes tenemos créditos altos que elevaran la mora si no los recuperamos'	
				When  @Saldo = @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '17Poco dinamismo en el mes, hay que salir a colocar'		
				When  @Saldo >= @aSaldo And @Mora >= @aMora And @Real <= @aReal And @Estimacion < @aEstimacion 
				Then  '18Este mes la colocación sigue bien, pero se descuida la Cartera Vencida'			
				When  @Saldo >= @aSaldo And @Mora >= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion				
				Then  '19Respecto al mes anterior esta creciendo la Cartera Vencida'		
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 >= 1 And @Mora > @aMora And @Real > @aReal And @Estimacion < @aEstimacion
				Then  '20Este mes nos concentramos en colocar sin administrar bien la cartera'		
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 >= 1 And @Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '21Este mes nos concentramos en colocar sin administrar bien la cartera'	
				When  ABS(Round(@Saldo,0) - Round(@aSaldo,0)) <= 1 And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion
				Then  '22No se observa cambio alguno en la cartera analizada'	
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 < 1 And
				      (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 > 0 And
					@Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion
				Then  '23Este mes mínimo Crecimiento de Cartera, y los Indicadores empeoraron'	
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion
				Then  '24Este Mes faltó Colocar, debemos ir en busqueda de nuevos clientes'					
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '25Un mes malo en las colocaciones, las recuperaciones fueron altas'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '26Un mes malo en las colocaciones, las recuperaciones fueron altas'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion <= @aEstimacion And @Mora = 0
				Then  '27Este mes faltó Colocar y se descuidó la cartera atrasada'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '28Este mes faltó Colocar y se descuidó la cartera atrasada'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real <= @aReal And @Estimacion < @aEstimacion 
				Then  '29Este mes recuperamos y nos olvidamos de colocar'
				When  @Saldo < @aSaldo And @Mora <= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '30Este mes recuperamos y nos olvidamos de colocar'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real > @aReal And @Estimacion < @aEstimacion 
				Then  '31Este mes se recuperó cartera vencida, se descuido la atrasada y falta colocar'			
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '32Este mes se recuperó cartera vencida, se descuido la atrasada y faltó colocar'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion < @aEstimacion
				Then  '33Este Mes faltó Colocar, debemos ir en busqueda de nuevos clientes'	
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real >= @aReal And @Estimacion > @aEstimacion
				Then  '34Este Mes faltó Colocar, debemos ir en busqueda de nuevos clientes'	
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real <= @aReal And @Estimacion <= @aEstimacion 	
				Then  '35En este mes nos dormimos tenemos que buscar nuevos clientes'		
				When   @Saldo < @aSaldo And @Mora > @aMora And @Real <= @aReal And @Estimacion > @aEstimacion
				Then  '36Si comparamos con mes anterior; faltó colocar y recuperar Cartera Vencida'	
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real > @aReal And @Estimacion < @aEstimacion 
				Then  '37Este mes se observa cartera descuidada, se necesita colocar más'				
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '38Los indicadores reflejan poco trabajo en el mes'						
		       End
End
If @Dato = 3	--ANUAL
Begin
	Set @Mensaje = Case
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion And @Mora = 0
				Then  '01En pleno crecimiento, indicadores estables (EXITOS)'
				When  @Saldo > @aSaldo And @Mora < @aMora And @Real < @aReal And @Estimacion <= @aEstimacion 
				Then  '02Felicidades excelente año por que mejoramos respecto al año anterior'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '03Felicidades cerramos el año con indicadores mejores al año anterior'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion = @aEstimacion And @Mora = 0
				Then  '04Felicidades cerramos el año con indicadores mejores al año anterior'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '05Un Año regular un poco más de colocación y superamos los objetivos'
				When  @Saldo = @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '06Poca variación en el año de los indicadores, poco dinamismo en la operativa'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,2) = Round(@aEstimacion,2) And @Mora = 0
				Then  '07Este año nos decuidamos en la cartera atrasada, debemos recuperarla'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,1) = Round(@aEstimacion,1) And @Mora = 0
				Then  '08Este año nos decuidamos en la cartera atrasada, debemos recuperarla'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And Round(@Estimacion,0) = Round(@aEstimacion,0) And @Mora = 0
				Then  '09Este año nos decuidamos en la cartera atrasada, debemos recuperarla'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '10Este año nos decuidamos en la cartera atrasada, debemos recuperarla'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '11Este año nos decuidamos en la cartera atrasada, debemos recuperarla'
				When  @Saldo > @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion <= @aEstimacion And @Mora > 0
				Then  '12Casi todo bien exepto la mora que esta igual que el año anterior'
				When  @Saldo > @aSaldo And @Mora <= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '13Este Año mal en la Estimación a pesar de algunos indicadores buenos'
				When  @Saldo >= @aSaldo And @Mora < @aMora And @Real = @aReal And @Estimacion < @aEstimacion 
				Then  '14Año regular buenas colocaciones, pero hay que fijarse en los atrasados'
				When  @Saldo > @aSaldo And @Mora <= @aMora And @Real > @aReal And @Estimacion <= @aEstimacion 
				Then  '15Cerramos el año con muchos creditos atrasados, la Mora podría crecer'
				When  @Saldo >= @aSaldo And @Mora <= @aMora And @Real > @aReal And @Estimacion >= @aEstimacion 
				Then  '16Año regular, tenemos créditos que descuidamos y la Mora subirá'				
				When  @Saldo = @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '17Poco dinamismo en el año empeoramos un poco, busquemos nuevos clientes'	
				When  @Saldo >= @aSaldo And @Mora >= @aMora And @Real <= @aReal And @Estimacion < @aEstimacion 
				Then  '18Año regular la colocación sigue bien, pero se descuida la Cartera Vencida'	
				When  @Saldo >= @aSaldo And @Mora >= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '19Nuestra cartera vencida subió, no nos fue bien en el año'
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 >= 1 And @Mora > @aMora And @Real > @aReal And @Estimacion < @aEstimacion
				Then  '20Este Año nos concentramos en colocar sin administrar bien la cartera'	
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 >= 1 And @Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '21Este año nos concentramos en colocar sin administrar bien la cartera'	
				When  ABS(Round(@Saldo,0) - Round(@aSaldo,0)) <= 1 And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion
				Then  '22No se observa cambio alguno en la cartera analizada'
				When  (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 < 1 And
				      (@Saldo/(Case @aSaldo When 0 Then (Case @Saldo When 0 Then 1 Else @Saldo End) Else @aSaldo End) *100) - 100 > 0 And
					@Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion
				Then  '23Este año mínimo Crecimiento de Cartera, y los Indicadores empeoraron'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real = @aReal And @Estimacion = @aEstimacion
				Then  '24Año regular faltó Colocar, debemos ir en busqueda de nuevos clientes'					
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion < @aEstimacion And @Mora = 0
				Then  '25Un año malo en las colocaciones, las recuperaciones fueron altas'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real < @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '26Un año malo en las colocaciones, las recuperaciones fueron altas'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion <= @aEstimacion And @Mora = 0
				Then  '27Año regular faltó Colocar y se decuidó la cartera atrasada'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real > @aReal And @Estimacion > @aEstimacion And @Mora = 0
				Then  '28Año regular faltó Colocar y se decuidó la cartera atrasada'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real <= @aReal And @Estimacion < @aEstimacion 
				Then  '29Año regular recuperamos y nos olvidamos de colocar'	
				When  @Saldo < @aSaldo And @Mora <= @aMora And @Real <= @aReal And @Estimacion > @aEstimacion 
				Then  '30Año regular recuperamos y nos olvidamos de colocar'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real > @aReal And @Estimacion < @aEstimacion 
				Then  '31Año malo recupero cartera vencida mas no la atrasada y faltó colocar'
				When  @Saldo < @aSaldo And @Mora < @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '32Año malo recupero cartera vencida mas no la atrasada y faltó colocar'
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real <= @aReal And @Estimacion < @aEstimacion
				Then  '33Año regular faltó Colocar, debemos ir en busqueda de nuevos clientes'	
				When  @Saldo < @aSaldo And @Mora = @aMora And @Real >= @aReal And @Estimacion > @aEstimacion
				Then  '34Año regular faltó Colocar, debemos ir en busqueda de nuevos clientes'	
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real <= @aReal And @Estimacion <= @aEstimacion 	
				Then  '35Este año nos falto conquistar nuevos mercados'		
				When   @Saldo < @aSaldo And @Mora > @aMora And @Real <= @aReal And @Estimacion > @aEstimacion
				Then  '36Nos quedamos en la colocación y recuperación, año regular'	
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real > @aReal And @Estimacion < @aEstimacion 
				Then  '37Año malo; se observa cartera descuidada, se necesita colocar más'				
				When  @Saldo < @aSaldo And @Mora > @aMora And @Real > @aReal And @Estimacion > @aEstimacion 
				Then  '38Trabajo básico en el presente año, nos falta más dinamismo'						
		       End
End




GO