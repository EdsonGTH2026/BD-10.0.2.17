CREATE TABLE [dbo].[tCsCALIQRRVisitasDet] (
  [codusuario] [varchar](15) NOT NULL,
  [item] [int] NOT NULL,
  [fecha] [datetime] NULL,
  [clasificacion] [tinyint] NULL,
  [observacion] [varchar](250) NULL,
  [fechareactivacion] [smalldatetime] NULL,
  [estado] [tinyint] NULL,
  CONSTRAINT [PK_tCsCALIQRRVisitasDet] PRIMARY KEY CLUSTERED ([codusuario], [item])
)
ON [PRIMARY]
GO