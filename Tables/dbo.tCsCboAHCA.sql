CREATE TABLE [dbo].[tCsCboAHCA] (
  [CodOficina] [varchar](4) NULL,
  [CodOrigen] [varchar](15) NULL,
  [CodCuenta] [varchar](25) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [FormaManejo] [smallint] NULL,
  [NombreCompleto] [varchar](300) NULL,
  [FechaApertura] [smalldatetime] NULL,
  [FechaDesembolso] [smalldatetime] NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCboAHCA]
  ON [dbo].[tCsCboAHCA] ([CodCuenta])
  ON [PRIMARY]
GO