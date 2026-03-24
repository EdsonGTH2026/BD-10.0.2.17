CREATE TABLE [dbo].[tCaClSubEstado] (
  [CodTipoCredito] [tinyint] NOT NULL,
  [CodEstado] [varchar](10) NOT NULL,
  [CodSubEstado] [varchar](15) NOT NULL,
  [Orden] [smallint] NULL,
  [Descripcion] [varchar](25) NULL,
  [IniEstado] [int] NULL,
  [FinEstado] [int] NULL,
  [Contaminada] [bit] NULL,
  [idConta] [varchar](30) NOT NULL,
  [ContaCodigo] [varchar](25) NOT NULL,
  [AplicaA] [char](1) NULL,
  [SeContabiliza] [bit] NULL
)
ON [PRIMARY]
GO