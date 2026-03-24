CREATE TABLE [dbo].[tCsCierresLog] (
  [SelloElectronico] [varchar](50) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Identificador] [int] NOT NULL,
  [Inicio] [datetime] NOT NULL,
  [Fin] [datetime] NULL,
  [Descripcion] [varchar](1000) NULL,
  [Observacion] [varchar](1000) NULL,
  CONSTRAINT [PK_tCsCierresLog] PRIMARY KEY CLUSTERED ([SelloElectronico], [Fecha], [Identificador], [Inicio])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCierresLog_Fecha]
  ON [dbo].[tCsCierresLog] ([Fecha])
  ON [PRIMARY]
GO