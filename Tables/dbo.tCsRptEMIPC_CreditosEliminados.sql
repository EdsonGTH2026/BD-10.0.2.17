CREATE TABLE [dbo].[tCsRptEMIPC_CreditosEliminados] (
  [CodPrestamo] [varchar](20) NOT NULL,
  [CodUsuario] [varchar](20) NOT NULL,
  [FechaInicial] [smalldatetime] NOT NULL,
  [FechaFinal] [smalldatetime] NOT NULL,
  [Activo] [bit] NOT NULL,
  CONSTRAINT [PK_tCsRptEMIPC_CreditosEliminados] PRIMARY KEY CLUSTERED ([CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO