CREATE TABLE [dbo].[tCsRptCHCarteraSanaXPro] (
  [region] [varchar](50) NULL,
  [sucursal] [varchar](30) NULL,
  [codasesor] [varchar](15) NULL,
  [nombrecompleto] [varchar](300) NULL,
  [codpuesto] [int] NULL,
  [codempleado] [varchar](50) NULL,
  [ingreso] [smalldatetime] NULL,
  [nroprestamos] [int] NULL,
  [nroclientes] [int] NULL,
  [saldocarterasana] [money] NULL,
  [individual] [money] NULL,
  [solidaria] [money] NULL,
  [grupal] [money] NULL
)
ON [PRIMARY]
GO