CREATE TABLE [dbo].[tCsRptEMIPC_LiquidadosMes] (
  [Fecha] [smalldatetime] NULL,
  [CodPromotor] [varchar](20) NULL,
  [CodOficina] [varchar](3) NULL,
  [Tipo] [varchar](20) NULL,
  [nroliqui] [int] NULL,
  [nroreno] [int] NULL,
  [PorReno] [decimal](8, 2) NULL
)
ON [PRIMARY]
GO