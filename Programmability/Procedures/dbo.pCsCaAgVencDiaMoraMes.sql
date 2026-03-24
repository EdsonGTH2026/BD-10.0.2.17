SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaAgVencDiaMoraMes]
  @codoficina varchar(5),
  @codasesor varchar(25),
  @fecha smalldatetime,
  @tipo char(1),
  @codusuario varchar(25)
AS
BEGIN
SET NOCOUNT ON

--declare @codoficina varchar(5)
--declare @codasesor varchar(25)
--declare @fecha smalldatetime
--declare @tipo char(1)
--declare @codusuario varchar(25)

--set @codoficina = '6'
--set @codasesor = 'MMM1504841'
--set @fecha ='20141208'
--set @tipo = '2'
--set @codusuario = @codasesor

CREATE TABLE #registros(
	codprestamo varchar(25) NOT NULL,
	monto decimal(25, 4) NULL,
	nombrecompleto varchar(300) NULL,
	saldooriginal decimal(25, 4) NULL,
	telefono varchar(20) NULL,
	TelefonoMovil varchar(50) NULL,
	direccion varchar(3000) NULL,
	NombreGrupo varchar(50) NULL,
	asesor varchar(300) NULL,
	tipo varchar(200),
	colaborador varchar(300),
	nrodiasatraso int
)

declare @sql varchar(2000)

if (@tipo<>'3')
  begin
    set @sql= 'insert #registros (codprestamo,monto,nombrecompleto,saldooriginal,telefono,TelefonoMovil,direccion,NombreGrupo,asesor,tipo,nrodiasatraso) '
    set @sql= @sql+'select cd.codprestamo,pl.monto,cl.nombrecompleto '
    --set @sql= @sql+',det.saldocapital+InteresVigente+InteresVencido+InteresCtaOrden+MoratorioVigente+MoratorioVencido+MoratorioCtaOrden saldooriginal '
    set @sql= @sql+',deu.monto saldooriginal '
    set @sql= @sql+',isnull(cl.TelefonoDirFamPri,cl.TelefonoDirNegPri) telefono,cl.TelefonoMovil '
    set @sql= @sql+',isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri) +'' ''+ ubi.direccion direccion, g.NombreGrupo,ase.nombrecompleto asesor, ''1.-SEGUIMIENTO PROGRAMADOS A LA FECHA (<150)'' tipo, c.nrodiasatraso '
    set @sql= @sql+'from tCsPadronCarteraDet cd inner join tcscarteradet det on det.fecha=cd.fechacorte and det.codprestamo=cd.codprestamo '
    set @sql= @sql+'and det.codusuario=cd.codusuario inner join tcscartera c on c.fecha=det.fecha and c.codprestamo=det.codprestamo '
    
    set @sql= @sql+'inner join (SELECT codoficina, codprestamo, codusuario, monto from ( '
    set @sql= @sql+'SELECT codoficina, codprestamo, codusuario, sum(MontoDevengado-MontoPagado-MontoCondonado) monto '
    set @sql= @sql+'FROM tCsPadronPlanCuotas p with(nolock) where p.fechavencimiento<='''+dbo.fduFechaATexto(@Fecha,'aaaaMMdd')+''' '
    set @sql= @sql+'group by codoficina, codprestamo, codusuario) a '
    set @sql= @sql+'where monto<>0) pl on pl.codoficina=cd.codoficina and pl.codprestamo=cd.codprestamo and pl.codusuario=cd.codusuario '
    
    set @sql= @sql+'inner join (SELECT codoficina, codprestamo, codusuario, monto from ( '
    set @sql= @sql+'SELECT codoficina, codprestamo, codusuario, sum(MontoDevengado-MontoPagado-MontoCondonado) monto '
    set @sql= @sql+'FROM tCsPadronPlanCuotas p with(nolock) ' --where p.fechavencimiento<='''+dbo.fduFechaATexto(@Fecha,'aaaaMMdd')+''' 
    set @sql= @sql+'group by codoficina, codprestamo, codusuario) a '
    set @sql= @sql+'where monto<>0) deu on deu.codoficina=cd.codoficina and deu.codprestamo=cd.codprestamo and deu.codusuario=cd.codusuario '
    
    set @sql= @sql+'inner join tcspadronclientes cl on cl.codusuario=cd.codusuario '
    set @sql= @sql+'left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri) '
    set @sql= @sql+'left outer join tCsCarteraGrupos g on g.CodGrupo=cd.codgrupo and g.codoficina=cd.codoficina '
    set @sql= @sql+'left outer join tcspadronclientes ase on ase.codusuario=cd.ultimoasesor '
    set @sql= @sql+'where cd.codoficina='''+@codoficina+''' '
    set @sql= @sql+'and c.fecha='''+dbo.fduFechaATexto(dateadd(day,-1,@Fecha),'aaaaMMdd')+''' and c.nrodiasatraso<150 '
    --if (@tipo='1') set @sql= @sql+'and cd.ultimoasesor='''+@codasesor+''' '
    --if (@tipo='1') set @sql= @sql+'and c.nrodiasatraso=0 '
    exec (@sql)
end

if (@tipo='1' or @tipo='3')
  begin
    set @sql= 'insert #registros (codprestamo,nombrecompleto,monto,saldooriginal,telefono,TelefonoMovil,direccion,NombreGrupo,asesor,tipo,nrodiasatraso) '
    set @sql= @sql+'select cd.codprestamo,cl.nombrecompleto,det.saldocapital + det.interesvigente+det.interesvencido+interesctaorden '
    set @sql= @sql+'+ det.moratoriovigente+det.moratoriovencido+moratorioctaorden saldocapital ,det.capitalatrasado+'
    set @sql= @sql+'det.capitalvencido deudaactual,isnull(cl.TelefonoDirFamPri,cl.TelefonoDirNegPri) telefono,cl.TelefonoMovil '
    set @sql= @sql+',isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri) +'' ''+ ubi.direccion direccion,g.NombreGrupo '
    set @sql= @sql+',ase.nombrecompleto ase,''2.- ATRASOS DEL MES'' tipo,c.nrodiasatraso '
    set @sql= @sql+'from tCsPadronCarteraDet cd inner join tcscarteradet det '
    set @sql= @sql+'on det.fecha=cd.fechacorte and det.codprestamo=cd.codprestamo '
    set @sql= @sql+'and det.codusuario=cd.codusuario inner join tcscartera c on c.fecha=det.fecha and c.codprestamo=det.codprestamo '
    set @sql= @sql+'inner join tcspadronclientes cl on cl.codusuario=cd.codusuario '
    set @sql= @sql+'left outer join tcspadronclientes ase on ase.codusuario=cd.ultimoasesor '
    set @sql= @sql+'left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri) '
    set @sql= @sql+'left outer join tCsCarteraGrupos g on g.CodGrupo=cd.codgrupo and g.codoficina=cd.codoficina '
    set @sql= @sql+'where cd.estadocalculado not in (''CANCELADO'') and cd.codoficina='''+@codoficina+''' '
    if (@tipo='1') set @sql= @sql+'and cd.ultimoasesor='''+@codasesor+''' '    
    if (@tipo='1') set @sql= @sql+'and c.nrodiasatraso>0 '
    if (@tipo='3') set @sql= @sql+'and c.nrodiasatraso>30 '
    if (@tipo='1') set @sql= @sql+'and c.nrodiasatraso<='+str(day(@fecha))+' '
    
    set @sql= @sql+' and cd.ultimoasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in (26,15,37,50)) '
  
    exec (@sql)    
  end

declare @colaborador varchar(200)
select @colaborador=nombrecompleto from tcspadronclientes where codusuario=@codusuario

update #registros
set colaborador = @colaborador

select * from #registros

drop table #registros

END
GO