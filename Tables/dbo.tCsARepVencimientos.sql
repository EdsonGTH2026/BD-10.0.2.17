CREATE TABLE [dbo].[tCsARepVencimientos] (
  [fecha] [smalldatetime] NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [sucursal] [varchar](30) NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [cliente] [varchar](300) NULL,
  [telefonomovil] [varchar](50) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [cuotaactual] [int] NULL,
  [MontoCuota] [money] NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [promotor] [varchar](300) NULL,
  [rangoMora] [varchar](4) NOT NULL,
  [SaldoPonerCorriente] [money] NOT NULL
)
ON [PRIMARY]
GO