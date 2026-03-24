CREATE TABLE [dbo].[tClFeriados] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechFeriado] [smalldatetime] NOT NULL,
  [NemFeriado] [varchar](20) NOT NULL,
  [DescFeriado] [varchar](50) NOT NULL,
  [AplicaPersonal] [bit] NULL,
  [FechaCreacion] [smalldatetime] NULL,
  [FechaUltActualizacion] [smalldatetime] NULL
)
ON [PRIMARY]
GO