CREATE TABLE [dbo].[tCCConsultas] (
  [RFC] [varchar](13) NOT NULL,
  [Item] [int] NOT NULL,
  [FechaConsulta] [smalldatetime] NULL,
  [ClaveOtorgante] [varchar](10) NULL,
  [NombreOtorgante] [varchar](40) NULL,
  [DireccionOtorgante] [varchar](80) NULL,
  [TelefonoOtorgante] [varchar](20) NULL,
  [TipoCredito] [varchar](2) NULL,
  [ImporteCredito] [int] NULL,
  [TipoResponsabilidad] [char](1) NULL
)
ON [PRIMARY]
GO