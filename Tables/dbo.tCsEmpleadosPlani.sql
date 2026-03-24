CREATE TABLE [dbo].[tCsEmpleadosPlani] (
  [FechaIni] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](5) NOT NULL,
  [FechaFin] [smalldatetime] NULL,
  [NroPromotor] [int] NULL,
  CONSTRAINT [PK_tCsEmpleadosPlani] PRIMARY KEY CLUSTERED ([FechaIni], [CodOficina]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO