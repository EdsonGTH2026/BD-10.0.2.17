CREATE TABLE [dbo].[tCaClProvisionSimulado] (
  [CodTipoCredito] [tinyint] NOT NULL,
  [TipoReprog] [varchar](6) NOT NULL,
  [VigenciaInicio] [smalldatetime] NOT NULL,
  [VigenciaFin] [smalldatetime] NOT NULL,
  [Estado] [varchar](50) NOT NULL,
  [DiasMinimo] [smallint] NOT NULL,
  [DiasMaximo] [int] NOT NULL,
  [Capital] [smallmoney] NULL,
  [Interes] [smallmoney] NULL,
  [Identificador] [varchar](10) NULL
)
ON [PRIMARY]
GO