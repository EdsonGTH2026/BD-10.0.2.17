CREATE TABLE [dbo].[tClRegionales] (
  [CodRegional] [varchar](4) NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [CodUsuarioResp] [varchar](20) NULL,
  [CorreoRegional] [varchar](50) NULL,
  [Activa] [bit] NULL,
  CONSTRAINT [PK_tClRegionales] PRIMARY KEY CLUSTERED ([CodRegional])
)
ON [PRIMARY]
GO