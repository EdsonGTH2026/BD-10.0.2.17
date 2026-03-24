CREATE TABLE [dbo].[tAhClEstadoCuenta] (
  [idEstadoCta] [char](2) NOT NULL,
  [Descripcion] [varchar](50) NULL,
  [NemEstadoCta] [varchar](20) NULL,
  [Vigente] [bit] NULL,
  [SeContabiliza] [bit] NOT NULL,
  [ContaCodigo] [varchar](25) NOT NULL,
  CONSTRAINT [PK_tAhClEstadoCuenta] PRIMARY KEY CLUSTERED ([idEstadoCta])
)
ON [PRIMARY]
GO