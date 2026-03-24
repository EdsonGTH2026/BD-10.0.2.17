CREATE TABLE [dbo].[tCsClientesCriterio] (
  [Criterio] [varchar](2) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [ICantidad] [decimal](18, 4) NULL,
  [Fin] [smalldatetime] NOT NULL,
  [FCantidad] [decimal](18, 4) NULL,
  [PCantidad] [int] NULL,
  [PC] [varchar](5) NULL,
  [PCP] [decimal](18, 4) NULL,
  [Diferencia] [decimal](18, 4) NULL,
  [PDiferencia] [int] NULL,
  [PD] [varchar](5) NULL,
  [PDP] [decimal](18, 4) NULL,
  [Porcentaje] [decimal](10, 4) NULL,
  [PPorcentaje] [int] NULL,
  [PA] [varchar](5) NULL,
  [PAP] [decimal](18, 4) NULL,
  [Final] [decimal](18, 4) NULL,
  CONSTRAINT [PK_ClientesObservaciones] PRIMARY KEY CLUSTERED ([Criterio], [CodOficina], [Inicio], [Fin])
)
ON [PRIMARY]
GO