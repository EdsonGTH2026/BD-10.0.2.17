CREATE TABLE [dbo].[tCsPLD_OperacionesDictamen] (
  [IdOperacionDictamen] [int] IDENTITY,
  [IdOperacion] [int] NOT NULL,
  [FechaDictamen] [datetime] NOT NULL,
  [EsInusual] [varchar](2) NOT NULL,
  [Estatus] [varchar](10) NOT NULL,
  [Dictamen] [varchar](1000) NOT NULL,
  [CodUsuarioAlta] [varchar](20) NULL,
  [FechaAlta] [datetime] NULL,
  CONSTRAINT [PK_tCsPLD_OperacionesDictamen] PRIMARY KEY CLUSTERED ([IdOperacionDictamen])
)
ON [PRIMARY]
GO