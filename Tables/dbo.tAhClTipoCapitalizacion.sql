CREATE TABLE [dbo].[tAhClTipoCapitalizacion] (
  [idTipoCapi] [smallint] NOT NULL,
  [IdTipoProd] [smallint] NULL,
  [DesTipoCapi] [varchar](150) NULL,
  [NroDias] [int] NOT NULL,
  [idEstado] [char](2) NULL,
  CONSTRAINT [PK_tAhClTipoCapitalizacion] PRIMARY KEY CLUSTERED ([idTipoCapi])
)
ON [PRIMARY]
GO