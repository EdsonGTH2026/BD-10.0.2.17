CREATE TABLE [dbo].[tCsCboCA] (
  [Sistema] [varchar](2) NOT NULL,
  [CodUsuario] [char](15) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NombreCompleto] [varchar](120) NULL,
  [FechaDesembolso] [smalldatetime] NULL
)
ON [PRIMARY]
GO