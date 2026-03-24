CREATE TABLE [dbo].[tCsRptEMIPC_Bono] (
  [Fecha] [smalldatetime] NULL,
  [CodPromotor] [varchar](20) NULL,
  [CodOficina] [varchar](3) NULL,
  [Tipo] [varchar](20) NULL,
  [item] [tinyint] NULL,
  [Tipo2] [char](1) NULL,
  [valor] [varchar](50) NULL,
  [descripcion] [varchar](200) NULL,
  [monto] [decimal](8, 2) NULL
)
ON [PRIMARY]
GO