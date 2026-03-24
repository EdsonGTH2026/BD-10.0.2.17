CREATE TABLE [dbo].[tCsRptAnalisisxReg] (
  [Fecha] [smalldatetime] NULL,
  [Region] [varchar](56) NULL,
  [CarteraVigente] [numeric](16, 2) NULL,
  [EstimacionRecuperacion] [numeric](16, 2) NULL,
  [RecuperacionEjecutada] [numeric](16, 2) NULL,
  [EstimacionDesembolso] [numeric](16, 2) NULL,
  [DesembolsoEjecutado] [numeric](16, 2) NULL
)
ON [PRIMARY]
GO