CREATE TABLE [dbo].[tCsRptEMIPC_ColocacionMes] (
  [Fecha] [smalldatetime] NULL,
  [CodPromotor] [varchar](20) NULL,
  [CodOficina] [varchar](3) NULL,
  [Tipo] [varchar](20) NULL,
  [Tnro] [int] NULL,
  [Tmonto] [decimal](8, 2) NULL,
  [Rnro] [int] NULL,
  [Rmonto] [decimal](8, 2) NULL,
  [Nnro] [int] NULL,
  [Nmonto] [decimal](8, 2) NULL,
  [Hnro] [int] NULL,
  [Hmonto] [decimal](8, 2) NULL,
  [meta] [varchar](20) NULL,
  [pormeta] [decimal](8, 2) NULL
)
ON [PRIMARY]
GO