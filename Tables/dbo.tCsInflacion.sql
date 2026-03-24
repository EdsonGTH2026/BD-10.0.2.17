CREATE TABLE [dbo].[tCsInflacion] (
  [tCsInflacion] [int] IDENTITY,
  [Periodo] [varchar](6) NOT NULL,
  [Valor] [money] NULL,
  CONSTRAINT [PK_tAhSolicitudRenovacionProceDet] PRIMARY KEY CLUSTERED ([tCsInflacion])
)
ON [PRIMARY]
GO