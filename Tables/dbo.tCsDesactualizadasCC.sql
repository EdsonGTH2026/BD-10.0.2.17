CREATE TABLE [dbo].[tCsDesactualizadasCC] (
  [Fecha_CC] [smalldatetime] NOT NULL,
  [MesesDesactualizada] [int] NULL,
  [UltimaActualización] [smalldatetime] NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [TipoResponsabilidad] [varchar](2) NULL,
  [TipoCuenta] [varchar](2) NULL,
  [TipoContrato] [varchar](5) NULL,
  [FrecuenciaPagos] [varchar](2) NULL,
  [FechaAperturaCuenta] [smalldatetime] NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [ApellidoAdicional] [varchar](50) NULL,
  [Nombres] [varchar](100) NULL,
  [FechaNacimiento] [smalldatetime] NULL
)
ON [PRIMARY]
GO