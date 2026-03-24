CREATE TABLE [dbo].[_AltaOPRs] (
  [Fondeo] [smalldatetime] NULL,
  [solicitudid] [varchar](25) NULL,
  [Cliente] [varchar](250) NULL,
  [Monto] [money] NULL,
  [Referencia] [varchar](100) NULL,
  [Sucursal] [varchar](250) NULL,
  [FechaCobro] [smalldatetime] NULL,
  [Estado] [varchar](15) NULL
)
ON [PRIMARY]
GO