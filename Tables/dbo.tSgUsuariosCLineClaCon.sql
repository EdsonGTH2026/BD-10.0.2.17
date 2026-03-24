CREATE TABLE [dbo].[tSgUsuariosCLineClaCon] (
  [sec] [int] NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [FechaHora] [datetime] NULL,
  [Clave] [varchar](10) NULL,
  [Estado] [tinyint] NULL CONSTRAINT [DF_tSgUsuariosCLineClaCon_Estado] DEFAULT (1),
  [NumCelular] [varchar](10) NULL,
  [NumReenvios] [int] NULL,
  [FechaHoraReenvio] [datetime] NULL,
  CONSTRAINT [PK_tSgUsuariosCLineClaCon] PRIMARY KEY CLUSTERED ([sec], [codusuario])
)
ON [PRIMARY]
GO