CREATE TABLE [dbo].[tCsRptEMIPC_DetalleRiesgo] (
  [Fecha] [smalldatetime] NULL,
  [CodPromotor] [varchar](20) NULL,
  [CodOficina] [varchar](3) NULL,
  [Tipo] [varchar](20) NULL,
  [item] [tinyint] NULL,
  [Descripcion] [varchar](25) NULL,
  [Prestamos] [varchar](1000) NULL
)
ON [PRIMARY]
GO