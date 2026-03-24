SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsDetalleProximosVencimientos] @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(2000) ,@Agrupar varchar(1000) AS
--DECLARE @Fecha smalldatetime
--DECLARE @FecIni smalldatetime 
--DECLARE @FecFin smalldatetime
--DECLARE @CodOficina varchar(100)
--DECLARE @Agrupar varchar(1000)

--SET @Fecha = '20090527'
--SET @FecIni = '20090601'
--SET @FecFin = '20090630'
--SET @CodOficina = '2,3,4,5'
--SET @Agrupar = ''--'oficina,sum(capital) capital,sum(montocuota) Monto'--' oficina,nombretec,asesor,sum(capital) capital '
--oficina, fechavencimiento, sum(capital) capital, sum(montocuota) Monto

DECLARE @Fecha smalldatetime

select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

--select @Fecha = '20100731'

DECLARE @csql varchar(8000)
SET @csql = ''
if(len(@Agrupar)<>0)
	begin
		SET @csql = @csql + 'SELECT ' + @Agrupar
		SET @csql = @csql + ' FROM ( '
	end
--Oficina, NombreTec,Asesor,CodPrestamo,NomCliente,FechaVencimiento,Capital,Interes,Moratorio,MontoCuota
--SET @csql = @csql + 'SELECT ''1'' + REPLICATE(''0'', 2 - LEN(CAST(tClOficinas.CodOficina AS int))) + tClOficinas.CodOficina + ''  '' + tClOficinas.NomOficina AS Oficina, '
SET @csql = @csql + 'SELECT tClOficinas.CodOficina + ''  '' + tClOficinas.NomOficina AS Oficina, '
SET @csql = @csql + 'tCaClTecnologia.NombreTec, tCsPadronClientes.NombreCompleto AS Asesor, tCsCartera.CodPrestamo, Cliente.NomCliente, dbo.fduFechaATexto(CuotasVenc.FechaVencimiento,''dd/mm/aaaa'') FechaVencimiento , '
SET @csql = @csql + 'CuotasVenc.CAPI Capital, '
SET @csql = @csql + 'CuotasVenc.INTE Interes, '
SET @csql = @csql + 'CuotasVenc.INPE Moratorio, '
SET @csql = @csql + ' + CuotasVenc.CAPI + CuotasVenc.INTE + CuotasVenc.INPE MontoCuota '
SET @csql = @csql + ',tCsCartera.nrodiasatraso,  cliente.telefono,cliente.direccion, cliente.colonia, cliente.codpostal ' -- agregada el 22.05.13
--tCsCartera.fechavencimiento,
SET @csql = @csql + 'FROM tCsCarteraDet INNER JOIN tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo INNER JOIN '
SET @csql = @csql + 'tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina INNER JOIN tCsPadronCarteraDet ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND '
SET @csql = @csql + 'tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario INNER JOIN tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN '
SET @csql = @csql + 'tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia INNER JOIN (SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento, '
SET @csql = @csql + 'SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE FROM (SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario, '
SET @csql = @csql + 'CASE CodConcepto WHEN ''capi'' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS CAPI, CASE CodConcepto WHEN ''inte'' '
SET @csql = @csql + 'THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INTE, CASE CodConcepto WHEN ''inpe'' THEN MontoDevengado - '
SET @csql = @csql + 'ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INPE, CASE CodConcepto WHEN ''inve'' THEN MontoDevengado - ISNULL(MontoPagado, 0) '
SET @csql = @csql + '- ISNULL(MontoCondonado, 0) ELSE 0 END AS INVE FROM tCsPadronPlanCuotas WHERE (EstadoCuota <> ''cancelado'') AND '
SET @csql = @csql + ' (FechaVencimiento >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND (FechaVencimiento <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''')) A '
SET @csql = @csql + 'GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario) CuotasVenc ON tCsCarteraDet.Fecha = CuotasVenc.Fecha AND '
SET @csql = @csql + 'tCsCarteraDet.CodPrestamo = CuotasVenc.CodPrestamo COLLATE Modern_Spanish_CI_AI AND tCsCarteraDet.CodUsuario = CuotasVenc.CodUsuario '
SET @csql = @csql + 'COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN tCsPadronClientes ON tCsCartera.CodAsesor = tCsPadronClientes.CodUsuario '
SET @csql = @csql + ' COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN '

SET @csql = @csql + ' ('
--SET @csql = @csql + ' SELECT codusuario,nombrecompleto nomcliente FROM tcspadronclientes'
SET @csql = @csql + 'SELECT codusuario,nombrecompleto nomcliente,isnull(telefonodirfampri,telefonodirnegpri) telefono '
SET @csql = @csql + ',isnull(direcciondirfampri,direcciondirnegpri) direccion,u.DescUbiGeo colonia,isnull(c.codpostalfam,c.codpostalneg) codpostal '
SET @csql = @csql + 'FROM tcspadronclientes c with(nolock) left outer join tClUbigeo u on isnull(c.codubigeodirfampri,c.codubigeodirfampri)=u.codubigeo '
SET @csql = @csql + ' ) Cliente ON tCsCarteradet.CodUsuario = Cliente.CodUsuario '

SET @csql = @csql + 'WHERE (tCsCarteraDet.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecha)+''') '
SET @csql = @csql + ' AND (tCsCartera.CodOficina IN('+@CodOficina+'))   '
--and ( tCsCartera.cartera in (''ACTIVA''))

if(len(@Agrupar)<>0)
	begin
		SET @csql = @csql + ' )  A  '

		if(CHARINDEX('sum', @Agrupar)>1) 
			begin
				SET @Agrupar = substring(@Agrupar,1,CHARINDEX('sum', @Agrupar)-2)
				SET @csql = @csql + ' GROUP BY ' + @Agrupar
			end
		else
			begin
				SET @csql = @csql + ' GROUP BY ' + @Agrupar
			end
	end
print @csql
exec (@csql)


GO