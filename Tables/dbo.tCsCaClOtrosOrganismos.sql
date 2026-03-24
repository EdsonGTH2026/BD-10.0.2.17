CREATE TABLE [dbo].[tCsCaClOtrosOrganismos] (
  [Tipo] [varchar](2) NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [CtaCapital] [varchar](50) NULL,
  [CtaInteres] [varchar](50) NULL,
  [PComodin] [char](1) NULL,
  [PCComodin] [char](1) NULL,
  [PDiasCI] [int] NULL,
  [PDiasCF] [int] NULL,
  [PLComodin] [char](1) NULL,
  [PDiasLI] [int] NULL,
  [PDiasLF] [int] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsCaClOtrosOrganismos] PRIMARY KEY CLUSTERED ([Tipo])
)
ON [PRIMARY]
GO