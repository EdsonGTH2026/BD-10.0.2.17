CREATE TABLE [dbo].[tSHFPeriodo] (
  [Periodo] [varchar](6) NOT NULL,
  [ReporteInicio] [smalldatetime] NULL,
  [ReporteFin] [smalldatetime] NULL,
  [Registro] [datetime] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tSHFPeriodo] PRIMARY KEY CLUSTERED ([Periodo])
)
ON [PRIMARY]
GO