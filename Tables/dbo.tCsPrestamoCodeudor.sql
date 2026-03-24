CREATE TABLE [dbo].[tCsPrestamoCodeudor] (
  [Registro] [datetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodUsuario] [char](15) NOT NULL,
  [CodSolicitud] [varchar](15) NOT NULL,
  [CodPrestamo] [varchar](25) NULL,
  [Usuario] [varchar](50) NULL,
  [Observacion] [varchar](500) NULL,
  CONSTRAINT [PK_tCaPrestamoCodeudor] PRIMARY KEY CLUSTERED ([CodOficina], [CodUsuario], [CodSolicitud])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPrestamoCodeudor_CodUsuario]
  ON [dbo].[tCsPrestamoCodeudor] ([CodUsuario])
  ON [PRIMARY]
GO