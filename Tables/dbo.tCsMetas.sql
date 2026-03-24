CREATE TABLE [dbo].[tCsMetas] (
  [CodOficina] [varchar](4) NOT NULL,
  [Sistema] [varchar](2) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Referencia] [nvarchar](255) NULL,
  [Capital] [decimal](38, 4) NULL,
  CONSTRAINT [PK_tCsMetas] PRIMARY KEY CLUSTERED ([CodOficina], [Sistema], [CodUsuario], [Fecha])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsMetas] TO [int_mmartinezp]
GO