CREATE TABLE [dbo].[tCsRptCHAsistenciaDiaria] (
  [dia] [smalldatetime] NULL,
  [codempleado] [varchar](50) NULL,
  [nombre] [varchar](300) NULL,
  [nomoficina] [varchar](30) NULL,
  [entrada] [datetime] NULL,
  [salida] [datetime] NULL,
  [tatrazo] [float] NULL,
  [puesto] [varchar](200) NULL,
  [TipoDia] [varchar](7) NOT NULL,
  [Falta] [varchar](1) NOT NULL
)
ON [PRIMARY]
GO