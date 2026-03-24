CREATE TABLE [dbo].[HHHH] (
  [Cadena] [varchar](8000) NULL,
  [TipoRegistro] [varchar](1) NOT NULL,
  [FolioPoliza] [varchar](2004) NULL,
  [NoSocio] [varchar](25) NULL,
  [NombreAsegurado] [varchar](80) NULL,
  [PaternoAsegurado] [varchar](50) NULL,
  [MaternoAsegurado] [varchar](50) NULL,
  [Genero] [varchar](1) NULL,
  [RFC] [varchar](20) NULL,
  [IngresoSeguro] [varchar](50) NULL,
  [FechaRegistro] [varchar](50) NOT NULL,
  [MontoCredito] [decimal](38, 6) NULL,
  [PlazoCredito] [varchar](3) NULL,
  [ClaveSucursal] [varchar](4) NULL,
  [NombreBeneficiario] [varchar](80) NOT NULL,
  [PaternoBeneficiario] [varchar](50) NOT NULL,
  [MaternoBeneficiario] [varchar](50) NOT NULL,
  [Parentesco] [varchar](2) NULL,
  [Porcentaje] [varchar](3) NOT NULL
)
ON [PRIMARY]
GO