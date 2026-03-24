CREATE TABLE [dbo].[tCsCaRptCartaBonosFechas] (
  [Periodo] [varchar](6) NOT NULL,
  [FecIniSem1] [smalldatetime] NULL,
  [FecFinSem1] [smalldatetime] NULL,
  [FecIniSem2] [smalldatetime] NULL,
  [FecFinSem2] [smalldatetime] NULL,
  [FecIniSem3] [smalldatetime] NULL,
  [FecFinSem3] [smalldatetime] NULL,
  [FecIniSem4] [smalldatetime] NULL,
  [FecFinSem4] [smalldatetime] NULL,
  CONSTRAINT [PK_tCsCaRptCartaBonosFechas] PRIMARY KEY CLUSTERED ([Periodo])
)
ON [PRIMARY]
GO