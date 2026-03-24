SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsTcTransCaja] (@CodOficina varchar(4),      -- Oficina para la cual se hace la transacción
  @FechaProceso varchar(10),   -- Fecha de proceso de la oficina que realiza la transacción
  @NumCajaAbierta tinyint,     -- Caja para la cual se realiza la transacción
  @CodMoneda varchar(2),       -- Código de moneda
  @EsEntrada bit,			   -- Si es entrada o salida de dinero	
  @Monto money,				   -- Monto de la transacción (efectivo)	
  @IdFactura int,			   -- IdFactura utilizada
  @Observaciones varchar(200), -- Observaciones de la transacción
  @CodSistema char(2),         -- Que sistema hizo la transacción
  @CodTipoTrans char(3),       -- Código válido de tipo de transacción
  @NumTransRef int,		       -- Número de transacción de referencia en el sistema implicado
  @NumCajaTransRet varchar(10) OUTPUT , -- Devuelve el número de transacción de caja
  @pEscheque bit = 0 ,
  @CodEntidadTipo as varchar(2)= '' ,
  @CodEntidad as varchar(2) = '',
  @NroCuenta as varchar(30)= '' ,
  @NumCheque as varchar(25) = '' )
AS
BEGIN
	SET NOCOUNT ON;

  exec [10.0.1.12].finamigo_conta_aas.dbo.pTcTransCaja @CodOficina,@FechaProceso,@NumCajaAbierta,
  @CodMoneda,@EsEntrada,@Monto,@IdFactura,@Observaciones,@CodSistema,@CodTipoTrans,@NumTransRef,@NumCajaTransRet out,
  @pEscheque,@CodEntidadTipo,@CodEntidad,@NroCuenta,@NumCheque
 
END
GO