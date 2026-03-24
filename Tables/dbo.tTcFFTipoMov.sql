CREATE TABLE [dbo].[tTcFFTipoMov] (
  [CodTipoMov] [char](3) NOT NULL,
  [TipoMovimiento] [varchar](25) NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL
)
ON [PRIMARY]
GO