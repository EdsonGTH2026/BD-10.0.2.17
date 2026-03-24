SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobanteOfiAdd] @nroopera varchar(10),@nroreferencia varchar(50),@codsistema varchar(5),
@Fecha SmallDateTime,@codoficina varchar(4),@idfactura varchar(30) output
AS
BEGIN
	
SET NOCOUNT ON;

--declare @nroopera varchar(10)
--declare @nroreferencia varchar(50)
--declare @codsistema varchar(5)
--Declare @Fecha SmallDateTime
--declare @codoficina varchar(4)

--set @nroopera = '12980'
--set @nroreferencia = '004-122-06-00-03207'

--set @codsistema='CA'
--set @Fecha = '20100906'
--set @codoficina = 4

declare @impuesto decimal(16,2)
declare @imp decimal(16,2)

set @impuesto = 1.16
set @imp = 0.16

declare @serie varchar(5)
declare @folio varchar(10)
declare @foliocrtl int

declare @añoapro int
declare @nroapro varchar(20)
declare @nrosericer varchar(50)

  CREATE TABLE #Operaciones (
  id            int  identity,
  fecha         smalldatetime,
  CodSistema    varchar(5),
  codoperacion  varchar(15),
  coddato1      varchar(50),
  coddato2      varchar(50),
	Operacion 	  varchar(200),
  monto         decimal(16,2),
  impuesto      decimal(16,2),
  total         decimal(16,2)
  )
  
  --AHORROS
  if(@codsistema='AH')
  begin
    insert into #Operaciones (fecha,CodSistema,codoperacion,coddato1,coddato2,Operacion,monto,impuesto,total)
    SELECT @fecha,'AH' Codsistema,a.nrotrans,c.codustitular,a.codcuenta,t.descripcion Operacion, a.MontoTotal/@impuesto as monto,
    a.MontoTotal - (a.MontoTotal/@impuesto) as Imp, a.MontoTotal total
    FROM [10.0.2.14].finmas.dbo.tAhTransaccionMaestra a
    inner join [10.0.2.14].finmas.dbo.tAhClTipoTrans t on t.idtipotrans=a.codtipotrans
    inner join [10.0.2.14].finmas.dbo.tahcuenta c 
    on c.codcuenta=a.codcuenta and c.fraccioncta=a.fraccioncta and c.renovado=a.renovado
    where dbo.fduFechaAAAAMMDD(a.fecha)= @fecha and a.codoficina=@codoficina
    and a.codtipotrans in (21,22,23,24,25,26,16) 
    --and a.IdFactura = 0 
    and a.nrotrans=@nroopera and a.codcuenta=@nroreferencia--aqui
  end 
  
  --CARTERA
  if(@codsistema='CA')
  begin
    insert into #Operaciones (fecha,CodSistema,codoperacion,coddato1,coddato2,Operacion,monto,impuesto,total)
    SELECT @fecha fecha, 'CA' codsistema,p.secpago,d.codusuario,p.codprestamo,d.DescConcepto,d.monto,d.impuesto,d.total
    FROM [10.0.2.14].finmas.dbo.tCaPagoReg p
    inner join (SELECT pd.CodOficina,pd.SecPago,pd.codusuario,con.DescConcepto, sum(pd.MontoPagado) monto, 
    sum(pd.MontoPagado)*0.16 as impuesto,sum(pd.MontoPagado) + sum(pd.MontoPagado)*0.16 total
    FROM [10.0.2.14].finmas.dbo.tCaPagoDet pd
    inner join [10.0.2.14].finmas.dbo.tCaClConcepto con on con.codconcepto=pd.codconcepto
    where pd.codconcepto not in ('IVAMO','IVAIT','IVACM')
    group by pd.SecPago,con.DescConcepto,pd.CodOficina,pd.codusuario) d on d.codoficina=p.codoficina and d.secpago=p.secpago
    where p.fechapago=@fecha and p.codoficina=@codoficina and p.extornado=0
    --and (p.Factura = '0' or p.Factura = '') 
    and p.secpago=@nroopera and p.codprestamo=@nroreferencia--aqui
    --comision apertura
    insert into #Operaciones (fecha,CodSistema,codoperacion,coddato1,coddato2,Operacion,monto,impuesto,total)
    select @fecha fecha, 'CA' Codsistema,t.secpagoparcial,p.codusuario,t.codprestamo,'PAGO ANTICIPADO CREDITO' descconcepto, t.MontoPago/@impuesto monto, 
    t.MontoPago - (t.MontoPago/@impuesto) impuesto,t.MontoPago total
    from [10.0.2.14].finmas.dbo.tCaPagoParcialAnticipado t
    inner join [10.0.2.14].finmas.dbo.tcaprestamos p on t.codprestamo=p.codprestamo
    where t.fechapago=@fecha and t.codoficina=@codoficina and t.extornado=0 
    --and t.idfactura is null
    and t.secpagoparcial=@nroopera and t.codprestamo=@nroreferencia--aqui
  end
  
  --TESORERIA
  if(@codsistema='TC')
  begin
    insert into #Operaciones (fecha,CodSistema,codoperacion,coddato1,coddato2,Operacion,monto,impuesto,total)
    SELECT @fecha fecha,'TC' codsistema,s.nrotrans,s.codusuario,s.codservicio,t.nombre,s.MontoTotal monto ,s.Itf impuesto , s.MontoTotal + s.Itf total
    FROM [10.0.2.14].finmas.dbo.tTcServiciosTrans s
    inner join [10.0.2.14].finmas.dbo.tTcClServicios t on t.codoficina=s.codoficina and t.codservicio=s.codservicio
    where s.fecha=@fecha and s.codoficina=@codoficina and s.estado='CANCELADO' and s.tiposervicio=1
    and s.codservicio in('7','12','8') and montocomision = 0 
    --and IdFactura=-1 
    and s.nrotrans=@nroopera and s.codservicio=@nroreferencia--aqui
    --comisiones
    insert into #Operaciones (fecha,CodSistema,codoperacion,coddato1,coddato2,Operacion,monto,impuesto,total)
    SELECT @fecha fecha,'TC' codsistema,s.nrotrans,s.codusuario,s.codservicio,t.nombre,s.montocomision monto ,s.Itf impuesto , s.montocomision + s.Itf total
    FROM [10.0.2.14].finmas.dbo.tTcServiciosTrans s
    inner join [10.0.2.14].finmas.dbo.tTcClServicios t on t.codoficina=s.codoficina and t.codservicio=s.codservicio
    where s.fecha=@fecha and s.codoficina=@codoficina and s.estado='CANCELADO' and s.tiposervicio=1
    and s.codservicio in('18') and s.montocomision <> 0 
    --and IdFacturaComision=-1
    and s.nrotrans=@nroopera and s.codservicio=@nroreferencia--aqui
  end
  
  declare @nro int 
  select @nro = count(*) from #Operaciones

  if(@nro>0)
  begin
    declare @codusuario varchar(20)
    declare @nombrecliente varchar(200)
    declare @rfccliente varchar(200)
    --XAXX010101000
    select @codusuario = coddato1 from #Operaciones
  
    SELECT @nombrecliente=u.NombreCompleto,@rfccliente=case when isnull(s.usruc,'')='' 
    then (case u.DI when 'RFC' then u.CodDocIden else '' end) else s.usruc end
    FROM [10.0.2.14].finmas.dbo.tUsUsuarios u
    inner join [10.0.2.14].finmas.dbo.tUsUsuarioSecundarios s on s.codusuario=u.codusuario
    where u.codusuario=@codusuario
  
    print @codoficina
    print getdate()
    --print 'si'

    --OBTENER EL NUMERO DE FACTURA CORRESPONDIENTE
    select @serie=serie,@folio=num,@foliocrtl=idcontrol,@nroapro=nroaprobacion,@añoapro=añoaprobacion,@nrosericer=nroseriecerti from (
    SELECT top 1 serie, replicate('0',digitosformato) + cast((case when folioact=0 then folioini else folioact+1 end) as varchar(10)) num,idcontrol
    ,nroaprobacion,añoaprobacion,nroseriecerti
    FROM tCsTCFacFolios
    where codoficina=@codoficina and estado=1 and codtipofactura='01') a

    --GENERAR LA FACTURA EN BASE A DATOS
    --FACTURA
    declare @nrofactura numeric(10,0)
    select @nrofactura = dbo.fduFacturaTrans(@codoficina,'01')
    set @idfactura = cast(@nrofactura as varchar(30))
    insert into tCsTcFactura 
    (idFactura,codoficina,CodTipoFactura,serie,folio,estado,esautomatica,fecha,rfc,nroaprobacion,añoaprobacion,nroseriecerti,nombrefactura,codusuario)
    select @nrofactura,@codoficina,'01',@serie,@folio,'1','0',@fecha,@rfccliente,@nroapro,@añoapro,@nrosericer,@nombrecliente,@codusuario
    --XEXX010101000 extranjeros
    --OPERACIONES QUE INTEGRAN LA FACTURA
    insert into tCsTCFacturaIntegra 
    (idFactura,codoficina,CodTipoFactura,item,codsistema,codtipoopera,descripconcepto,fechaoriginal
    ,monto,impuesto,total,coddato1,coddato2)       
    select @nrofactura,@codoficina,'01',id,CodSistema,codoperacion,
    Operacion,fecha,monto,impuesto,total,coddato1,coddato2 
    from #Operaciones
    
    --DETALLE DE LA FACTURA  
    
    CREATE TABLE #detalle(
	  idFactura numeric(10, 0) NOT NULL,
	  codoficina varchar(4) NOT NULL,
	  CodTipoFactura varchar(5) NOT NULL,
	  item int identity,
	  codsistema varchar(5) NULL,
	  desconcepto varchar(200) NULL,
	  monto decimal(10, 2) NULL,
	  impuesto decimal(10, 2) NULL,
	  total decimal(10, 2) NULL,
    cantidad int
    )
      
    insert into #detalle (idFactura,codoficina,CodTipoFactura,codsistema,desconcepto,monto,impuesto,total,cantidad)  
    select @nrofactura,@codoficina,'01',CodSistema,Operacion,monto,impuesto,total,cantidad from (
    select CodSistema,Operacion,sum(monto) monto,sum(impuesto) impuesto,sum(total) total, count(coddato1) cantidad from (
    select CodSistema,Operacion,fecha,monto,impuesto,total,coddato1 from #Operaciones)xop
    group by CodSistema,Operacion) xtot
      
    insert into [10.0.1.17].finamigoconsolidado.dbo.tCsTCFacturaDet 
    (idFactura,codoficina,CodTipoFactura,item,codsistema,desconcepto,monto,impuesto,total,cantidad)
    select idFactura,codoficina,CodTipoFactura,item,codsistema,desconcepto,monto,impuesto,total,cantidad from #detalle 
    
    drop table #detalle
    
    --ACTUALIZAMOS CONSECUTIVO DE COMPROBANTES
    update tCsTCFacFolios
    set folioact= cast(@nrofactura as numeric(10,0))
    where codoficina=@codoficina and codtipofactura='01' and idcontrol=@foliocrtl

    declare @m decimal(10,2)
    declare @i decimal(10,2)
    declare @t decimal(10,2)

    select @m=sum(monto), @i=sum(impuesto), @t=sum(total) from (
    SELECT monto, (case when desconcepto='CAPITAL' then 0 else impuesto end) impuesto,
    (case when desconcepto='CAPITAL' then monto else total end) total  
    FROM tCsTCFacturaDet where codoficina=@codoficina and codtipofactura='01' and idFactura=@nrofactura) a

    update tCsTCFactura
    set iva=@i ,subtotal=@m ,total=@t
    where idFactura=@nrofactura and codoficina=@codoficina and codtipofactura='01'

    --ACTUALIZAMOS A LAS TRANSACCIONES DE LA OPERATIVA SU FACTURA

    --cartera
    if(@codsistema='CA')
    begin
      update [10.0.2.14].finmas.dbo.tCaPagoReg
      set factura = @nrofactura
      from [10.0.2.14].finmas.dbo.tCaPagoReg pr
      inner join (SELECT codtipoopera,fechaoriginal,coddato1,coddato2 FROM tCsTCFacturaIntegra
      where idfactura=@nrofactura and codoficina=@codoficina and codtipofactura='01' and codsistema='CA'
      and descripconcepto <> 'PAGO ANTICIPADO CREDITO') f on pr.codprestamo=f.coddato2
      and pr.fechapago=f.fechaoriginal and pr.secpago=f.codtipoopera
      --cartera comisiones apertura
      update [10.0.2.14].finmas.dbo.tCaPagoParcialAnticipado
      set idfactura = @nrofactura
      from [10.0.2.14].finmas.dbo.tCaPagoParcialAnticipado pa
      inner join (SELECT codtipoopera,fechaoriginal,coddato1,coddato2 FROM tCsTCFacturaIntegra
      where idfactura=@nrofactura and codoficina=@codoficina and codtipofactura='01' and codsistema='CA'
      and descripconcepto = 'PAGO ANTICIPADO CREDITO') f on pa.codprestamo=f.coddato2 
      and pa.fechapago=f.fechaoriginal and pa.secpagoparcial=f.codtipoopera
    end
    --ahorros
    if(@codsistema='AH')
    begin
      update [10.0.2.14].finmas.dbo.tAhTransaccionMaestra
      set idfactura = @nrofactura
      from [10.0.2.14].finmas.dbo.tAhTransaccionMaestra pa
      inner join (SELECT codtipoopera,fechaoriginal,coddato1,coddato2 FROM tCsTCFacturaIntegra
      where idfactura=@nrofactura and codoficina=@codoficina and codtipofactura='01' and codsistema='AH') f 
      on pa.codcuenta=f.coddato2 and pa.nrotrans=f.codtipoopera
    end
    --tesoreria
    if(@codsistema='TC')
    begin
      update [10.0.2.14].finmas.dbo.tTcServiciosTrans
      set idfactura = @nrofactura
      from [10.0.2.14].finmas.dbo.tTcServiciosTrans pa
      inner join (SELECT codtipoopera,fechaoriginal,coddato1,coddato2 FROM tCsTCFacturaIntegra
      where idfactura=@nrofactura and codoficina=@codoficina and codtipofactura='01' and codsistema='TC') f 
      on pa.codservicio=f.coddato2 and pa.nrotrans=f.codtipoopera
      where pa.estado='CANCELADO' and pa.tiposervicio=1 and pa.codservicio in('7','12','8') 
      and pa.fecha=@fecha 
      --and pa.IdFactura=-1 
      and pa.codoficina=@codoficina
      --tesoreria comisiones
      update [10.0.2.14].finmas.dbo.tTcServiciosTrans
      set IdFacturaComision = @nrofactura
      from [10.0.2.14].finmas.dbo.tTcServiciosTrans pa
      inner join (SELECT codtipoopera,fechaoriginal,coddato1,coddato2 FROM tCsTCFacturaIntegra
      where idfactura=@nrofactura and codoficina=@codoficina and codtipofactura='01' and codsistema='TC') f 
      on pa.codservicio=f.coddato2 and pa.nrotrans=f.codtipoopera
      where pa.estado='CANCELADO' and pa.tiposervicio=1 and pa.codservicio in('18') 
      and pa.fecha=@fecha 
      --and pa.IdFacturaComision=-1 
      and pa.codoficina=@codoficina
    end
    
    print getdate()
    print '---------'
  end
  
  drop table #Operaciones

  --exec pCsTCComprobanteGenCad @nrofactura,'01',@codoficina,@Fecha

--print 'termino'



END
GO