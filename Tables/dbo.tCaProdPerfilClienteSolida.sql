CREATE TABLE [dbo].[tCaProdPerfilClienteSolida] (
  [CodProducto] [char](3) NOT NULL,
  [NumParticipMIN] [varchar](10) NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_NumParticipMIN] DEFAULT (0),
  [NumParticipMAX] [varchar](10) NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_NumParticipMAX] DEFAULT (0),
  [MaxIntegrantes] [varchar](10) NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_MaxIntegrantes] DEFAULT (0),
  [MinIntegrantes] [varchar](10) NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_MinIntegrantes] DEFAULT (0),
  [MinMonto] [int] NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_MinMonto] DEFAULT (0),
  [MaxMonto] [int] NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_MaxMonto] DEFAULT (0),
  [Concentracion] [varchar](10) NULL,
  [NumPrimerMin] [int] NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_NumPrimerMin] DEFAULT (0),
  [NumPrimerMax] [int] NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_NumPrimerMax] DEFAULT (0),
  [NumSegundoMin] [int] NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_NumSegundoMin] DEFAULT (0),
  [NumSegundoMax] [int] NULL CONSTRAINT [DF_tCaProdPerfilClienteSolida_NumSegundoMax] DEFAULT (0),
  CONSTRAINT [PK_tCaProdPerfilClienteSolida] PRIMARY KEY CLUSTERED ([CodProducto])
)
ON [PRIMARY]
GO