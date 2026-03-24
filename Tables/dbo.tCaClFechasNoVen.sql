CREATE TABLE [dbo].[tCaClFechasNoVen] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechaNoVen] [smalldatetime] NOT NULL,
  [NemFechaNoVen] [varchar](20) NOT NULL,
  [DescFechaNoVen] [varchar](50) NOT NULL,
  [FechaCreacion] [smalldatetime] NULL,
  [FechaUltActualizacion] [smalldatetime] NULL,
  CONSTRAINT [PK_tCaClFechasNoVen] PRIMARY KEY CLUSTERED ([CodOficina], [FechaNoVen])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaClFechasNoVen] TO [mchavezs2]
GO