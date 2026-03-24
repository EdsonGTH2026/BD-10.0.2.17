CREATE TABLE [dbo].[tCaClTipoPlan] (
  [CodTipoPlan] [tinyint] NOT NULL,
  [DescTipoPlan] [varchar](50) NULL,
  [ContratoS] [varchar](50) NULL,
  [ContratoP] [varchar](50) NULL,
  CONSTRAINT [PK_tCaClTipoPlan] PRIMARY KEY CLUSTERED ([CodTipoPlan])
)
ON [PRIMARY]
GO