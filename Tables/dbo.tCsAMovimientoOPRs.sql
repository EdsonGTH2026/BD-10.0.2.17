CREATE TABLE [dbo].[tCsAMovimientoOPRs] (
  [operacion] [varchar](10) NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](200) NULL,
  [numeroref] [varchar](25) NULL,
  [fechatrans] [smalldatetime] NULL,
  [monto] [money] NULL,
  [cliente] [varchar](300) NULL,
  [codprestamo] [varchar](25) NULL,
  [estado] [varchar](25) NULL,
  [obsreferencia] [varchar](200) NULL
)
ON [PRIMARY]
GO