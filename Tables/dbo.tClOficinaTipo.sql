CREATE TABLE [dbo].[tClOficinaTipo] (
  [CodOficinaTipo] [varchar](5) NOT NULL,
  [DescOficinaTipo] [varchar](20) NULL,
  [Orden] [smallint] NULL,
  [Activa] [bit] NOT NULL,
  [ContaCodigo] [varchar](50) NOT NULL,
  [EsMaestraReplicaClasif] [bit] NOT NULL
)
ON [PRIMARY]
GO