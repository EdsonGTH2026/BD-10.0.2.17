SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsTaCalculasaldospp] @fechaproceso datetime
AS
BEGIN
	SET NOCOUNT ON;


DECLARE @nrotarjeta varchar(25)
DECLARE @saldoactual decimal(16,2)
DECLARE @saldoamovim decimal(16,2)
DECLARE @saldonuevo decimal(16,2)
DECLARE @fecutlmov datetime
DECLARE @fecutlmovnuevo datetime
declare @CodUsuario varchar(25)
DECLARE @nombre varchar(250)

--DECLARE @fechaproceso datetime
--SET @fechaproceso = '20110812 16:36'

DECLARE gensaldos CURSOR FOR 
  SELECT nrotarjeta,isnull(saldo,0) saldo,fecultmvo FROM tTaCuentas with(nolock)
  where fechproceso<>@fechaproceso or saldo is null
OPEN gensaldos

FETCH NEXT FROM gensaldos
INTO @nrotarjeta,@saldoactual,@fecutlmov

WHILE @@FETCH_STATUS = 0
BEGIN

  print '----------'
  print @nrotarjeta

  select @saldoamovim = isnull(sum (monto),0), @fecutlmovnuevo=max(fecha) from (
  SELECT case when t.operacion='-' then (-1)*Monto else Monto end monto,m.fecha
  FROM tTaMovimientos m with(nolock) inner join tTaTipoMovimientos t with(nolock) on t.codtipomov=m.codtipomov
  where nrotarjeta=@nrotarjeta and (fecha>@fecutlmov or @fecutlmov is null)
  ) a
  
  if(not (@fecutlmovnuevo is null))
    begin
      print @saldoactual
      print @saldoamovim
      
      update tTaCuentas
      set saldo = @saldoactual + @saldoamovim, fecultmvo=@fecutlmovnuevo, fechproceso=@fechaproceso
      where nrotarjeta=@nrotarjeta
    end
  
  FETCH NEXT FROM gensaldos 
  INTO @nrotarjeta,@saldoactual,@fecutlmov
END

CLOSE gensaldos
DEALLOCATE gensaldos


DECLARE colocacodigocliente CURSOR FOR 
  SELECT nrotarjeta,nombrecliente FROM tTaCuentas with(nolock)
  where codusuario is null
OPEN colocacodigocliente

FETCH NEXT FROM colocacodigocliente
INTO @nrotarjeta,@nombre

WHILE @@FETCH_STATUS = 0
BEGIN
  
  Exec pCsNombreACodigo @nombre, @CodUsuario Out
  print @CodUsuario

  if(not(@CodUsuario is null) and ltrim(rtrim(@CodUsuario))<>'')
    update tTaCuentas set codusuario=ltrim(rtrim(@CodUsuario))
    where nrotarjeta=@nrotarjeta
    
  FETCH NEXT FROM colocacodigocliente
  INTO @nrotarjeta,@nombre
END

CLOSE colocacodigocliente
DEALLOCATE colocacodigocliente

END
GO