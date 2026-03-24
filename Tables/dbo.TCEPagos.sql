CREATE TABLE [dbo].[TCEPagos] (
  [Periodo] [varchar](30) NULL,
  [FechaInicio] [smalldatetime] NULL,
  [FechaFinal] [smalldatetime] NULL,
  [NroContrato] [varchar](30) NULL,
  [Grupo] [varchar](30) NULL,
  [Contrato] [varchar](30) NULL,
  [Nombre] [varchar](300) NULL,
  [FechaPago] [smalldatetime] NULL,
  [FechaAplicacion] [smalldatetime] NULL,
  [Monto] [money] NULL,
  [SaldoInsoluto] [money] NULL
)
ON [PRIMARY]
GO