CREATE TABLE [dbo].[Intervinientes] (
  [CodPrestamo] [varchar](25) NULL,
  [NoInternoPersona] [char](15) NULL,
  [FormaInterVencion] [varchar](8) NOT NULL,
  [FechaReferencia] [smalldatetime] NULL,
  [FechaSolicitud] [smalldatetime] NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [UltimoBuro] [smalldatetime] NULL,
  [RegistroCliente] [smalldatetime] NULL
)
ON [PRIMARY]
GO