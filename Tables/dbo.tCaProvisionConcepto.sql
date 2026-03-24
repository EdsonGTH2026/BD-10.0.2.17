CREATE TABLE [dbo].[tCaProvisionConcepto] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechaProceso] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [MontoProvision] [money] NOT NULL,
  [MontoNoCubierto] [money] NULL,
  [MontoGarReales] [smallmoney] NULL,
  [MontoGarNoReales] [smallmoney] NULL
)
ON [PRIMARY]
GO