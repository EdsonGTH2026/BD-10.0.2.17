CREATE TABLE [dbo].[tCaClRecuperablesNivelAprob] (
  [TipoOp] [varchar](5) NOT NULL,
  [Secuencial] [tinyint] NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [MontoMinimo] [money] NULL,
  [MontoMaximo] [money] NULL,
  [CodAutoriza] [char](6) NULL,
  [CodAutorizaEx] [char](6) NULL
)
ON [PRIMARY]
GO