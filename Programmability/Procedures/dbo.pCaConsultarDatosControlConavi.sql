SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCaConsultarDatosControlConavi] @fecha smalldatetime, @codoficina varchar(300)
as 
begin

SELECT 
TCAP.CodOficina,
TCAP.CodProducto,
TCAP.CodPrestamo,
TCAP.CodSolicitud,
TUSUCLIE.NombreCompleto as Cliente,  
TUSUASE.NOMASESOR as Asesor,
TCAP.Montodesembolso ,
(select top 1 ca.CodCuenta from [10.0.2.14].finmas.dbo.tahcuenta as ca where ca.CodUsTitular = TCAP.CodUsuario and ca.idEstadoCta = 'CA') as CuentaAhorro,
(select top 1 cc.FechaInicio from [10.0.2.14].finmas.dbo.tCaCuotas as cc where cc.CodPrestamo = TCAP.CODPRESTAMO order by cc.SecCuota) as PrimerCuota,
isnull(TCAPV.CUV,'') as CUV,
ISNULL(CertificadoFechaImp,'') as CertificadoFechaImp,                                    
ISNULL(SolicitudConaviFecha,'') as SolicitudConaviFecha,                                   
ISNULL(AcuseFecha,'') as AcuseFecha                                               
FROM [10.0.2.14].finmas.dbo.TCAPRESTAMOS TCAP  
left outer JOIN [10.0.2.14].finmas.dbo.TCAPRESTAMOVIVIENDA TCAPV ON TCAP.CODPRESTAMO=TCAPV.CODPRESTAMO  
INNER JOIN [10.0.2.14].finmas.dbo.tCaClAsesores TUSUASE ON TUSUASE.CODASESOR=TCAP.CODASESOR  
INNER JOIN [10.0.2.14].finmas.dbo.TUSUSUARIOS TUSUCLIE ON TUSUCLIE.CODUSUARIO=TCAP.CODUSUARIO  
WHERE  codproducto='168'  
ORDER BY TCAPV.CODPRESTAMO DESC 

end

GO