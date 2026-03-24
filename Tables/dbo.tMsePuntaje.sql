CREATE TABLE [dbo].[tMsePuntaje] (
  [Ubicacion] [varchar](50) NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [Fin] [smalldatetime] NOT NULL,
  [F] [int] NOT NULL,
  [Grupo] [varchar](100) NOT NULL,
  [P1] [decimal](38, 6) NULL,
  [P2] [decimal](38, 6) NULL,
  [PT] [decimal](38, 6) NULL,
  [Descripcion] [varchar](100) NULL,
  [CodOficina] [varchar](4) NULL,
  [Visible] [bit] NULL,
  [PSC] [decimal](18, 4) NULL,
  [PMV] [decimal](18, 4) NULL,
  [PMR] [decimal](18, 4) NULL,
  [PEP] [decimal](18, 4) NULL,
  [NSC] [decimal](18, 4) NULL,
  [NMV] [decimal](18, 4) NULL,
  [NMR] [decimal](18, 4) NULL,
  [NEP] [decimal](18, 4) NULL,
  [CSC] [decimal](18, 4) NULL,
  [CMV] [decimal](18, 4) NULL,
  [CMR] [decimal](18, 4) NULL,
  [CEP] [decimal](18, 4) NULL,
  CONSTRAINT [PK_tMsePuntaje] PRIMARY KEY CLUSTERED ([Ubicacion], [Inicio], [Fin], [F], [Grupo])
)
ON [PRIMARY]
GO