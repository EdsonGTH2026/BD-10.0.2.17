CREATE TABLE [dev_cchavezd].[tCsRptCHAsistenciaDiaria] (
  [dia] [smalldatetime] NULL,
  [codempleado] [varchar](50) NULL,
  [nombre] [varchar](300) NULL,
  [nomoficina] [varchar](30) NULL,
  [entrada] [datetime] NULL,
  [salida] [datetime] NULL,
  [tatrazo] [float] NULL,
  [puesto] [varchar](200) NULL,
  [TipoDia] [varchar](7) NULL,
  [Falta] [varchar](1) NULL
)
ON [PRIMARY]
GO