SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pAhInsertaTransaccionRetiro_Faltante](  
 @CodCuenta  VARCHAR(25),   
 @Renovado int,
 @Monto      MONEY,   
 @CodUsuario VARCHAR(20),
 @folioOrigen varchar(30) 
)  
AS  
BEGIN   
  --03022021 OSC se agrega parametro de renovacion
  
  if exists(select * from tahtransaccionmaestra where codcuenta = @CodCuenta and Renovado = @Renovado
  and CodTipoTrans = 3 and Fecha >= '20210101' and Fecha <= '20210131')
  begin
	print 'ya existe transaccion Retiro'
	return 0
  end
  print 'no ya existe transaccion Retiro, continua'
  
        DECLARE @idProducto INT;  
        DECLARE @Nombre VARCHAR(50);  
        DECLARE @idManejo SMALLINT;  
        DECLARE @NomCuenta VARCHAR(80);  
        DECLARE @CuentaPreferencial BIT;  
        DECLARE @CodUsTitular CHAR(15);  
        DECLARE @codOficina VARCHAR(10);  
        DECLARE @CodOfiUltTrans VARCHAR(5);  
        DECLARE @IdTipoCta CHAR(2);  
        DECLARE @AplicaITF BIT;  
        DECLARE @DescManejo VARCHAR(30);  
        DECLARE @CodMoneda CHAR(1);  
        DECLARE @DescMoneda VARCHAR(50);  
        DECLARE @DescAbreviada VARCHAR(10);  
        DECLARE @idDocResp SMALLINT;  
        DECLARE @DescDocResp VARCHAR(150);  
        DECLARE @idestadocta VARCHAR(5);  
        DECLARE @Descripcion VARCHAR(50);  
        DECLARE @FechaUltProceso DATETIME;  
  
        --optine todos los datos de la cuenta que se ocuparan  
        SELECT @idProducto = TAhProductos.idProducto,   
               @CodCuenta = tAhCuenta.CodCuenta,   
               @Nombre = TAhProductos.Nombre,   
               @idManejo = tAhCuenta.idManejo,   
               @NomCuenta = tAhCuenta.NomCuenta,   
               @CuentaPreferencial = tAhCuenta.CuentaPreferencial,   
               @CodUsTitular = tAhCuenta.CodUsTitular,   
               @codOficina = tAhCuenta.codOficina,   
               @FechaUltProceso = tAhCuenta.FechaUltProceso,   
               @CodOfiUltTrans = tAhCuenta.CodOfiUltTrans,   
               @IdTipoCta = tAhCuenta.IdTipoCta,   
               @AplicaITF = tAhCuenta.AplicaITF,   
               @DescManejo = tAhClFormaManejo.DescManejo,   
               @CodMoneda = tClMonedas.CodMoneda,   
               @DescMoneda = tClMonedas.DescMoneda,   
               @DescAbreviada = tClMonedas.DescAbreviada,   
               @idDocResp = tAhClDocRespaldo.idDocResp,   
               @DescDocResp = tAhClDocRespaldo.DescDocResp,   
               @idestadocta = tAhClEstadoCuenta.idestadocta,   
               @Descripcion = tAhClEstadoCuenta.Descripcion  
        FROM tAhCuenta  
             INNER JOIN TAhProductos ON tAhCuenta.idProducto = TAhProductos.idProducto  
             INNER JOIN tClMonedas ON tAhCuenta.CodMoneda = tClMonedas.CodMoneda  
             INNER JOIN tAhClDocRespaldo ON tAhCuenta.idDocResp = tAhClDocRespaldo.idDocResp  
             INNER JOIN tAhClFormaManejo ON tAhCuenta.idManejo = tAhClFormaManejo.idManejo  
             INNER JOIN tAhClEstadoCuenta ON tAhCuenta.idEstadoCta = tAhClEstadoCuenta.idEstadoCta  
        WHERE tAhCuenta.CodCuenta = @CodCuenta --'003-105-06-2-9-02748'  
        and tAhCuenta.Renovado = @Renovado  --OSC, 
              --AND SUBSTRING(CAST(tAhCuenta.IDProducto AS VARCHAR(10)), 1, 1) <> '2'  
              --AND SUBSTRING(CAST(tAhCuenta.IDProducto AS VARCHAR(10)), 1, 1) <> '4';  
        
		DECLARE @NroSecuencial AS NUMERIC;  
		SET @NroSecuencial = 0;  
		EXEC pAhObtieneSecuencial   
		@codOficina,   
		@NroSecuencial OUTPUT;  


		DECLARE @TipoTrans SMALLINT;  
		SET @TipoTrans = 3;  
		DECLARE @CodFormaTrans SMALLINT;  
		SET @CodFormaTrans = 1;  
		DECLARE @TipoCambio MONEY;  
		SET @TipoCambio = 0;  
		DECLARE @Obs VARCHAR(100);  
		SET @Obs = 'RETIRO CUENTA SPEI ' + ' CLAVE RASTREO: ' + @folioOrigen;  
		DECLARE @CodSistema VARCHAR(3);  
		SET @CodSistema = 'AH';  
		DECLARE @Operacion MONEY;  
		SET @Operacion = 1;  
		DECLARE @Param1 VARCHAR(30);   
		SET @Param1 = '';  
		DECLARE @Param2 VARCHAR(30);   
		SET @Param2 = '';  
		DECLARE @Param3 VARCHAR(30);   
		SET @Param3 = '';  
		DECLARE @Param4 VARCHAR(30);  
		SET @Param4 = '';  
		DECLARE @Motivo INTEGER;  
		SET @Motivo = 0; -- 142;  ---INDICA EN LA TABLA tahtransaccion QUE NUMERO DE OPERACION CORRESPONDE A RETIRO STP VER CATALOGO EN tAhClMotivosEstado
		DECLARE @NumTransRef INT;  
		DECLARE @Param5 VarChar(30);  
		SET @Param5= '';  
		DECLARE @CtaAhES VARCHAR(25);  
		SET @CtaAhES= '';  
		DECLARE @FraccRenov VARCHAR (8) ;  
		SET @FraccRenov = '0';  
		DECLARE @RenovRenov TINYINT;  
		SET @RenovRenov= @Renovado;  --OSC, 31-01-2021 0;  
		DECLARE @NomMaquina VARCHAR(50) ;  
		SET @NomMaquina= '';  
		DECLARE @CodCajero VARCHAR(15);  

		SELECT @CodCajero = CodUsuario  FROM tUsUsuarios  WHERE CodUsuario = @CodUsuario;  

		DECLARE @NumTrans INT;  
		DECLARE @NroSecuencial3 NUMERIC;  
		SET @NroSecuencial3 = 0;  
  
  
  set @FechaUltProceso = '20210131'
  
 EXEC PAHCreaTransaccion   
   @CodOficina,  
   @CodCajero,  
   @CodCuenta,  
   @TipoTrans,  
   @CodFormaTrans,  
   @Monto,  
   @TipoCambio,  
   @Obs,  
   @FechaUltProceso,  
   @CodSistema,  
   @Operacion,  
   @Param1,   
   @Param2,   
   @Param3,   
   @Param4,  
   @NroSecuencial,  
   @Motivo,  
   @NumTrans OUTPUT,  
   @Param5 ,  
   @CtaAhES ,   
   @FraccRenov ,   
   @RenovRenov ,  
   @NomMaquina   
  
  select @NumTrans as '@NumTrans'
  
  -- DECLARE @NumCajaAbierta TINYINT;  
  --      SELECT top 1 @NumCajaAbierta = T1.NumCaja  
  --      FROM ttcCajas AS T1  
  --           INNER JOIN tUsUsuarios AS T2 ON T1.CodOficina = T2.CodOficina  
  --                                           AND CodUsuario = @CodUsuario;  
      
        
  --      DECLARE @fecha2 VARCHAR(10);  
  --      SET @fecha2 = CONVERT(VARCHAR(10), @FechaUltProceso, 111);  
  --set @fecha2= replace(@fecha2,'/','-')  
    
  --DECLARE @EsEntrada BIT;  
  --       SET @EsEntrada = 1;  
  --       --DECLARE @NumCajaAbierta TINYINT;  
  --       --SELECT @NumCajaAbierta = T1.NumCaja  
  -- DECLARE @PQueIdFac INT;  
  --       SET @PQueIdFac = 0;  
  -- DECLARE @Observaciones VARCHAR(200);  
  --       SET @Observaciones = 'RETIRO SPEI';  
  -- DECLARE @Observaciones2 VARCHAR(200);  
  --       SET @Observaciones2 = @Observaciones + '-' + @CodCuenta;  
  -- --DECLARE @CodSistema VARCHAR(3);  
  -- --      SET @CodSistema = 'AH';  
  --       DECLARE  @CodTipoTrans char(3);   
  -- SET @CodTipoTrans='AHR';  
  -- DECLARE @NumCajaTransRet varchar(10) ;   
  -- DECLARE @pEscheque bit ;  
  -- SET @pEscheque= 0 ;  
  --       DECLARE @CodEntidadTipo as varchar(2);  
  -- SET @CodEntidadTipo= '' ;  
  -- DECLARE @CodEntidad as varchar(2);   
  -- SET @CodEntidad= '';  
  --    DECLARE @NroCuenta as varchar(30);  
  -- SET @NroCuenta= '';   
  --    DECLARE @NumCheque as varchar(25);   
  -- SET @NumCheque= '' ;   
  
     
        --DECLARE @vVchQSistema VARCHAR(5);  
        --SET @vVchQSistema = 'SAHAH';  
        --DECLARE @vVchQproceso VARCHAR(2);  
        --SET @vVchQproceso = 05;  
        --DECLARE @vBitSeConta BIT ;  
        --SET @vBitSeConta = '';  
        --DECLARE @vVchTipoOpera VARCHAR(3)  ;   
        --SET @vVchTipoOpera = '';  
        --DECLARE @vIntNroAsi SMALLINT ;  
        --SET @vIntNroAsi = 0;  
        --DECLARE @vVchqSp VARCHAR(30) ;  
        --SET @vVchqSp = '';  
  
  
  --      DECLARE @odCtbleNew VARCHAR(25);  
  --      SELECT @odCtbleNew = ContaCodigo  
  --      FROM tAhCuenta  
  --      WHERE CodCuenta = @CodCuenta;  
  --DECLARE @NumOperacion  INTEGER;  
  --set @NumOperacion=0;  
  --DECLARE @CodTipoOpera VARCHAR(3);  
  --      SET @CodTipoOpera = 'H20';    
  --   DECLARE @TipoCambio2 NUMERIC(19,7);  
  --      SET @TipoCambio2 = 0;  
  --   DECLARE @OficinaDestino VARCHAR(5);  
  --      SET @OficinaDestino = '';  
  --   DECLARE @MontoDevengado MONEY;  
  --      SET @MontoDevengado = 0;  
  --   DECLARE @TransaccionAH VARCHAR(10);  
  --      SET @TransaccionAH = '1';  
  --   DECLARE @hora DATETIME;  
  --      SET @hora = GETDATE();  
  --   DECLARE @NroOperacionAnt VARCHAR(25);  
  --      SET @NroOperacionAnt = 0;  
  
  /*
 EXEC pAhContaAhorros  
@NumOperacion,  
     @FechaUltProceso,  
     @codOficina,  
     @CodTipoOpera,  
     @NroSecuencial,  
     @CodCuenta,  
     @CodUsuario,  
     @TipoCambio2,  
     @odCtbleNew,  
     @odCtbleNew,  
     @idestadocta,  
     @idestadocta,  
     @OficinaDestino,  
     @MontoDevengado,  
     @TransaccionAH,  
     @hora,  
     @NroOperacionAnt   
     */
 
END; 




GO