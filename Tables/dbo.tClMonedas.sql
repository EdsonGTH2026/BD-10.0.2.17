CREATE TABLE [dbo].[tClMonedas] (
  [CodMoneda] [varchar](2) NOT NULL,
  [DescMoneda] [varchar](50) NULL,
  [INTF] [varchar](2) NULL,
  [DescAbreviada] [varchar](10) NULL,
  [Activa] [bit] NOT NULL,
  [Orden] [char](10) NULL,
  [CodMonedaConta] [varchar](3) NULL,
  [EsMonedaBase] [bit] NOT NULL,
  [EsNacional] [bit] NOT NULL,
  [ConAjustes] [bit] NOT NULL,
  [DescAbrevCta] [varchar](10) NULL,
  [EsExtranjeroPrin] [bit] NOT NULL,
  [ActivoConta] [bit] NOT NULL,
  [MargenCambio] [money] NULL,
  [ParaInflacion] [bit] NOT NULL,
  [MantValor] [bit] NULL,
  [ConBilletajeCMoneda] [bit] NOT NULL,
  [SHF] [int] NULL,
  [SITI] [int] NULL,
  CONSTRAINT [PK_tClMonedas] PRIMARY KEY CLUSTERED ([CodMoneda])
)
ON [PRIMARY]
GO