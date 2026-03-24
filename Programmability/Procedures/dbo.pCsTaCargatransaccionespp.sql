SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsTaCargatransaccionespp] @reprocesa char(1), @archivo varchar(20), @fecha smalldatetime, @hora varchar(8)
AS
BEGIN

SET NOCOUNT ON

--declare @reprocesa char(1)
--declare @archivo varchar(20)
--declare @fecha smalldatetime
--declare @hora datetime

--set @archivo = '02-PRN198608861.txt'
--set @fecha = '20110721'
--set @hora ='15:45:45'
--set @reprocesa = '1'

--delete ttalog

--insert ttalog  (fecha, hora, archivo) values (@fecha,@hora,@archivo)
--insert ttalog  (archivo) values (@reprocesa)

--declare @nroreg int

--declare @nrocuenta varchar(25)
--declare @codtipomov varchar(3)
--declare @fec smalldatetime
--declare @hor datetime
--declare @consecutivo varchar(15)

----insert ttalog  (archivo)
----SELECT cast(count(nrotarjeta) as varchar(20)) FROM tTaMovimientosArch
----where nomarchivo=@archivo and Fecha_sub=@fecha and Hora_sub=@hora

--DECLARE genxcta CURSOR FOR 
--  SELECT nrotarjeta,codtipomov,fecha,hora,documento1 FROM tTaMovimientosArch
--  where nomarchivo=@archivo and Fecha_sub=@fecha and Hora_sub=@hora
--OPEN genxcta

--FETCH NEXT FROM genxcta
--INTO @nrocuenta,@codtipomov,@fec,@hor,@consecutivo

--WHILE @@FETCH_STATUS = 0
--BEGIN
--    print @nrocuenta
    
--    if(@reprocesa='1')
--      begin
--        delete FROM tTaMovimientos 
--        where nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo
--      end
    
--    --insert ttalog  (archivo) values ('@nroreg:'+CAST(@fec AS VARCHAR(50)))
--    --insert ttalog  (archivo) values ('@nroreg:'+CAST(@hor AS VARCHAR(50)))
--    --insert ttalog  (archivo) values ('@nroreg:'+CAST(@consecutivo AS VARCHAR(30)))
    
--    select @nroreg=count(nrotarjeta) FROM tTaMovimientos 
--    where nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo
    
--    --insert ttalog  (archivo) values ('@nroreg:'+CAST(@nroreg AS VARCHAR(15)))
    
-- 		if(@nroreg=0)
--      begin

--        insert into tTaMovimientos (nrotarjeta,codtipomov,fecha,hora,consecutivo,documento1,documento2
--        ,F,E,consumo,tarjeta,nombre,comercio,comision,MO,Monto,usuario,fechaproceso)
--        select nrotarjeta,codtipomov,fecha,hora,documento1,documento1,documento2
--        ,F,E,consumo,tarjeta,nombre,comercio,comision,MO,Monto,usuario,getdate()
--        from tTaMovimientosArch
--        where nomarchivo=@archivo and Fecha_sub=@fecha and Hora_sub=@hora
--        and nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo

--        --insert ttalog  (archivo) values ('@@ROWCOUNT:'+cast(@@ROWCOUNT as varchar(10)))
        
--        update tTaMovimientosArch
--        set procesado='1'
--        where nomarchivo=@archivo and Fecha_sub=@fecha and Hora_sub=@hora
--        and nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo
        
--      end
--	-----------------------------------------------
--	FETCH NEXT FROM genxcta 
--  INTO @nrocuenta,@codtipomov,@fec,@hor,@consecutivo
--END

--CLOSE genxcta
--DEALLOCATE genxcta

declare @c varchar(3000)

set @c = 'declare @nroreg int '
set @c = @c + 'declare @nrocuenta varchar(25) '
set @c = @c + 'declare @codtipomov varchar(3) '
set @c = @c + 'declare @fec smalldatetime '
set @c = @c + 'declare @hor datetime '
set @c = @c + 'declare @consecutivo varchar(15) '
set @c = @c + 'DECLARE genxcta CURSOR FOR '
set @c = @c + 'SELECT nrotarjeta,codtipomov,fecha,hora,documento1 FROM tTaMovimientosArch '
set @c = @c + 'where nomarchivo='''+@archivo+''' and Fecha_sub='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and Hora_sub='''+@hora+''' '
set @c = @c + 'OPEN genxcta '
set @c = @c + 'FETCH NEXT FROM genxcta '
set @c = @c + 'INTO @nrocuenta,@codtipomov,@fec,@hor,@consecutivo '
set @c = @c + 'WHILE @@FETCH_STATUS = 0 '
set @c = @c + 'BEGIN '
--print @nrocuenta
set @c = @c + 'if('''+@reprocesa+'''=''1'') '
set @c = @c + 'begin '
set @c = @c + 'delete FROM tTaMovimientos '
set @c = @c + 'where nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo '
set @c = @c + 'end '
set @c = @c + 'select @nroreg=count(nrotarjeta) FROM tTaMovimientos '
set @c = @c + 'where nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo '
set @c = @c + 'if(@nroreg=0) '
set @c = @c + 'begin '
set @c = @c + 'insert into tTaMovimientos (nrotarjeta,codtipomov,fecha,hora,consecutivo,documento1,documento2 '
set @c = @c + ',F,E,consumo,tarjeta,nombre,comercio,comision,MO,Monto,usuario,fechaproceso) '
set @c = @c + 'select nrotarjeta,codtipomov,fecha,hora,documento1,documento1,documento2 '
set @c = @c + ',F,E,consumo,tarjeta,nombre,comercio,comision,MO,Monto,usuario,getdate() '
set @c = @c + 'from tTaMovimientosArch '
set @c = @c + 'where nomarchivo='''+@archivo+''' and Fecha_sub='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and Hora_sub='''+@hora+''' '
set @c = @c + 'and nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo '
set @c = @c + 'update tTaMovimientosArch '
set @c = @c + 'set procesado=''1'' '
set @c = @c + 'where nomarchivo='''+@archivo+''' and Fecha_sub='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and Hora_sub='''+@hora+''' '
set @c = @c + 'and nrotarjeta=@nrocuenta and codtipomov=@codtipomov and fecha=@fec and hora=@hor and documento1=@consecutivo '
set @c = @c + 'end '
set @c = @c + 'FETCH NEXT FROM genxcta '
set @c = @c + 'INTO @nrocuenta,@codtipomov,@fec,@hor,@consecutivo '
set @c = @c + 'END '
set @c = @c + 'CLOSE genxcta '
set @c = @c + 'DEALLOCATE genxcta '
set @c = @c + ''
print @c
exec (@c)

END
GO