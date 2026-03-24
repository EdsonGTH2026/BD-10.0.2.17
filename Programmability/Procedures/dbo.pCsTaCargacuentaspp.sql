SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsTaCargacuentaspp] @archivo varchar(20), @fecha smalldatetime, @hora varchar(8)
AS
BEGIN

SET NOCOUNT ON

--declare @archivo varchar(20)
--declare @fecha smalldatetime
--declare @hora datetime

--set @archivo = '01-PRN198A614741.txt'
--set @fecha = '20110719'
--set @hora ='15:21:50'

--declare @nroreg int
--declare @nrocuenta varchar(25)

--DECLARE genxcta CURSOR FOR 
--  SELECT nrotarjeta FROM tTaCuentasArch
--  where nomarchivo=@archivo and fecha=@fecha and hora=@hora
--OPEN genxcta

--FETCH NEXT FROM genxcta
--INTO @nrocuenta

--WHILE @@FETCH_STATUS = 0
--BEGIN
--    select @nroreg=count(nrotarjeta) FROM tTaCuentas where nrotarjeta=@nrocuenta
-- 		if(@nroreg=0)
--      begin
--        print @nrocuenta
        
--        insert into tTaCuentas (nrotarjeta,nrocuenta,nombrecliente,fecemision,fecexpira,fecativa
--        ,hechopor,estado,fechproceso)
--        select nrotarjeta,nrocuenta,ltrim(rtrim(nombrecliente)),fecemision,fecexpira,fecativa,hechopor,estado,getdate()
--        from tTaCuentasArch
--        where nomarchivo=@archivo and fecha=@fecha and hora=@hora and nrotarjeta=@nrocuenta
        
--        update tTaCuentasArch
--        set procesado='1'
--        where nomarchivo=@archivo and fecha=@fecha and hora=@hora and nrotarjeta=@nrocuenta
        
--      end
--	-----------------------------------------------
--	FETCH NEXT FROM genxcta 
--  INTO @nrocuenta
--END

--CLOSE genxcta
--DEALLOCATE genxcta

declare @c varchar(2000)

set @c = 'declare @nroreg int '
set @c = @c + 'declare @nrocuenta varchar(25) '
set @c = @c + 'DECLARE genxcta CURSOR FOR '
set @c = @c + 'SELECT nrotarjeta FROM tTaCuentasArch '
set @c = @c + 'where nomarchivo='''+@archivo+''' and fecha='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and hora='''+@hora+''' '
set @c = @c + 'OPEN genxcta '

set @c = @c + 'FETCH NEXT FROM genxcta '
set @c = @c + 'INTO @nrocuenta '
set @c = @c + 'WHILE @@FETCH_STATUS = 0 '
set @c = @c + 'BEGIN '
set @c = @c + 'select @nroreg=count(nrotarjeta) FROM tTaCuentas where nrotarjeta=@nrocuenta '
set @c = @c + 'if(@nroreg=0) '
set @c = @c + 'begin '
--print @nrocuenta
set @c = @c + 'insert into tTaCuentas (nrotarjeta,nrocuenta,nombrecliente,fecemision,fecexpira,fecativa,hechopor,estado,fechproceso) '
set @c = @c + 'select nrotarjeta,nrocuenta,ltrim(rtrim(nombrecliente)),fecemision,fecexpira,fecativa,hechopor,estado,getdate() '
set @c = @c + 'from tTaCuentasArch '
set @c = @c + 'where nomarchivo='''+@archivo+''' and fecha='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and hora='''+@hora+''' and nrotarjeta=@nrocuenta '
set @c = @c + 'update tTaCuentasArch '
set @c = @c + 'set procesado=''1'' '
set @c = @c + 'where nomarchivo='''+@archivo+''' and fecha='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and hora='''+@hora+''' and nrotarjeta=@nrocuenta '
set @c = @c + 'end '
set @c = @c + 'FETCH NEXT FROM genxcta '
set @c = @c + 'INTO @nrocuenta '
set @c = @c + 'END '
set @c = @c + 'CLOSE genxcta '
set @c = @c + 'DEALLOCATE genxcta '

exec (@c)

END
GO