SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobanteGenCad] @idfactura numeric(10,0),@CodTipoFactura varchar(5),@codoficina varchar(4),@Fecha as SmallDateTime
AS
BEGIN
	SET NOCOUNT ON;

SET NOCOUNT ON;
	
--declare @idfactura numeric(10,0)
--declare @CodTipoFactura varchar(5)
--declare @codoficina varchar(4)
--Declare @Fecha as SmallDateTime

--set @idfactura = 13
--set @CodTipoFactura = '01'
--set @codoficina = 4
--set @Fecha = '20100906'

declare @version varchar(5)
set @version = '2.0'

declare @razonsocial varchar(200)
set @razonsocial='|Financiera Mexicana para el Desarrollo Rural, S.A. de C.V., SFP.'

declare @rfc varchar(20)
set @rfc='|FMD030602PJ4'

declare @cadori varchar(2000)
declare @matriz varchar(2000)
declare @datcomp varchar(2000) --datos del comprobante
declare @sucursal varchar(2000) --datos exp. comprob.
declare @direcclie varchar(2000) --datos exp. comprob.
declare @datrecep varchar(2000) --datos receptor
declare @concomprob varchar(2000) -- conceptos del comprobantes
declare @concomprobiva varchar(2000) -- conceptos del comprobantes IVA

create table #toficina (
  desofi      varchar(200),
  direccion   varchar(200),
  colonia   varchar(200),
  municipio   varchar(200),
  estado   varchar(200),
  codpostal   varchar(10),
  telefono   varchar(20)
)

insert into #toficina (desofi,direccion,colonia,municipio,estado,codpostal,telefono)
exec pCldatosoficinamatriz

select  @matriz = '|'+direccion+'|'+dbo.fducambiarformato(colonia)+'|'+dbo.fducambiarformato(municipio)
+'|'+dbo.fducambiarformato(estado)+'|'+codpostal from #toficina

declare @serie varchar(10)
declare @folio varchar(10)
declare @nroaprobacion varchar(20)
declare @añoaprobacion varchar(4)
declare @nroseriecerti varchar(5)
declare @rfccli varchar(20)
declare @nombrecli varchar(50)
declare @IVA	decimal(10, 2)
declare @subtotal	decimal(10, 2)
declare @total	decimal(10, 2)
declare @fechacomp smalldatetime
declare @concepto varchar(200)
declare @conceptotal	decimal(10, 2)
declare @conceptoiva	decimal(10, 2)
declare @codusuario varchar(20)

  --domicilio emisor del comprobante
  truncate table #toficina
  
  insert into #toficina (desofi,direccion,colonia,municipio,estado,codpostal,telefono)
  exec pClDatosOficina @codoficina
  
  select @sucursal = '|'+direccion+'|'+dbo.fducambiarformato(colonia)+'|'+dbo.fducambiarformato(municipio)
  +'|'+dbo.fducambiarformato(estado)+'|'+codpostal from #toficina

  
  SELECT @serie=serie,@folio=folio,@nroaprobacion=nroaprobacion,@añoaprobacion=añoaprobacion,@nroseriecerti=nroseriecerti
  ,@rfccli=RFC,@nombrecli=nombrefactura,@IVA=IVA,@subtotal=subtotal,@total=total,@fechacomp=fecha,@codusuario=codusuario
  FROM tCsTcFactura
  where idfactura=@idfactura and estado=1 and codoficina=@codoficina and CodTipoFactura=@CodTipoFactura

  set @datcomp = '|'+@version+'|'+@serie+'|'+@folio+'|'+dbo.fduFechaATexto(@fechacomp,'DDMMAAAA')+'|'+@nroaprobacion+'|'+@añoaprobacion+'|INGRESO|UNA SOLA EXHIBICION|EFECTIVO|'+cast(@subtotal as varchar(10))+'|'+cast(@total as varchar(10))
    
  set @datrecep = '|'+@rfccli+'|'+@nombrecli
  
  --direccion cliente  
  truncate table #toficina
  
  insert into #toficina (desofi,direccion,colonia,municipio,estado,codpostal,telefono)
  exec pClDatosOficinacli @codusuario
  
  select @direcclie = '|'+direccion+'|'+dbo.fducambiarformato(colonia)+'|'+dbo.fducambiarformato(municipio)
  +'|'+dbo.fducambiarformato(estado)+'|'+codpostal from #toficina
  
  --fin direccion cliente
  
  set @concomprob = ''
  set @concomprobiva = ''
    
  -- POR DETALLE DEL COMPROBANTE
  DECLARE xfacdet CURSOR FOR
    SELECT desconcepto,monto,case desconcepto when 'CAPITAL' THEN 0 ELSE impuesto END FROM tCsTCFacturaDet
    where codoficina=@codoficina and codtipofactura=@CodTipoFactura AND idfactura=@idfactura
  OPEN xfacdet
  
  FETCH NEXT FROM xfacdet 
  INTO @concepto,@conceptotal,@conceptoiva
  WHILE @@FETCH_STATUS = 0
  BEGIN
    
    set @concomprob = @concomprob + '|' + @concepto + '|' + cast(@conceptotal as varchar(10))
    set @concomprobiva = @concomprobiva + '|IVA|16.00|' + cast(@conceptoiva as varchar(10))
    
    FETCH NEXT FROM xfacdet
    INTO @concepto,@conceptotal,@conceptoiva
  END

  CLOSE xfacdet
  DEALLOCATE xfacdet
    
 set @cadori = replace('|'+@datcomp+@rfc+@razonsocial+@matriz+@sucursal+@datrecep+@direcclie+@concomprob+@concomprobiva+'||','  ',' ')
 
 --print @cadori
 update tCsTcFactura
 set cadoriginal = @cadori
 where idFactura=@idfactura and CodTipoFactura=@CodTipoFactura and codoficina=@codoficina

drop table #toficina

END
GO