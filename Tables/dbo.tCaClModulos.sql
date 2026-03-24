CREATE TABLE [dbo].[tCaClModulos] (
  [CodModulo] [varchar](15) NOT NULL,
  [DescModulo] [varchar](50) NOT NULL,
  [EsAnulacion] [bit] NULL,
  [EsRechazo] [bit] NOT NULL,
  [Orden] [smallint] NULL
)
ON [PRIMARY]
GO