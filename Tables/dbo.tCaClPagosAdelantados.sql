CREATE TABLE [dbo].[tCaClPagosAdelantados] (
  [CodPagoAdelantado] [int] NOT NULL,
  [DescPagoAdelantado] [varchar](100) NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL
)
ON [PRIMARY]
GO