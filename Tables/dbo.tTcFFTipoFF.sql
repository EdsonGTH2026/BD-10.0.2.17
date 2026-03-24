CREATE TABLE [dbo].[tTcFFTipoFF] (
  [CodTipoFF] [char](3) NOT NULL,
  [TipoFF] [varchar](30) NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL,
  [ContaCodigo] [varchar](25) NOT NULL
)
ON [PRIMARY]
GO