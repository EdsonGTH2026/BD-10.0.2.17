CREATE TABLE [dbo].[_AltaPtmos] (
  [solicitudId] [varchar](8000) NULL,
  [prestamoID] [varchar](8000) NULL,
  [tipo] [varchar](100) NULL,
  [montoPrestamo] [money] NULL,
  [fechaOtorga] [varchar](8000) NULL,
  [status] [varchar](100) NULL,
  [codprestamo] [varchar](25) NULL,
  [fechadesembolso] [smalldatetime] NULL
)
ON [PRIMARY]
GO