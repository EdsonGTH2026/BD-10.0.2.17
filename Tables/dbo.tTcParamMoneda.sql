CREATE TABLE [dbo].[tTcParamMoneda] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [CajaMontoMin] [money] NOT NULL,
  [CajaMontoMax] [money] NOT NULL,
  [FFMontoMin] [money] NOT NULL,
  [FFMontoMax] [money] NOT NULL,
  [FFMontoMaxTran] [money] NOT NULL,
  [FFDiasReposicion] [tinyint] NOT NULL,
  [FFDiasCierre] [tinyint] NOT NULL,
  [CMPlusMinVta] [money] NOT NULL,
  [CMPlusMinCpa] [money] NOT NULL,
  [CMPlusMaxVta] [money] NOT NULL,
  [CMPlusMaxCpa] [money] NOT NULL
)
ON [PRIMARY]
GO