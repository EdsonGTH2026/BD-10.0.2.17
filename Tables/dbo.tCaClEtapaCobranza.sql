CREATE TABLE [dbo].[tCaClEtapaCobranza] (
  [CodEtapa] [varchar](3) NOT NULL,
  [DescEtapa] [varchar](50) NULL,
  [EsPreventiva] [bit] NULL,
  [Orden] [tinyint] NULL,
  [Activa] [bit] NOT NULL,
  CONSTRAINT [PK_tCaClEtapaCobranza] PRIMARY KEY CLUSTERED ([CodEtapa])
)
ON [PRIMARY]
GO