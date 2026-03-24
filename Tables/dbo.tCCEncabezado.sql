CREATE TABLE [dbo].[tCCEncabezado] (
  [RFC] [varchar](13) NOT NULL,
  [FolioConsultaOtorgante] [varchar](25) NULL,
  [ClaveOtorgante] [varchar](10) NULL,
  [ExpedienteEncontrado] [char](1) NULL,
  [FolioConsulta] [varchar](10) NOT NULL
)
ON [PRIMARY]
GO