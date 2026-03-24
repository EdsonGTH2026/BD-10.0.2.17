CREATE TABLE [dbo].[tCaClProvisionIFRS9] (
  [CodTipoCredito] [tinyint] NOT NULL,
  [TipoReprog] [varchar](6) NOT NULL,
  [VigenciaInicio] [smalldatetime] NOT NULL,
  [VigenciaFin] [smalldatetime] NOT NULL,
  [Estado] [varchar](50) NOT NULL,
  [DiasMinimo] [smallint] NOT NULL,
  [DiasMaximo] [int] NOT NULL,
  [Capital] [money] NULL,
  [Interes] [money] NULL,
  [Identificador] [varchar](10) NULL,
  [Orden] [smallint] NULL,
  CONSTRAINT [PK_tCaClProvisionIFRS9] PRIMARY KEY CLUSTERED ([CodTipoCredito], [TipoReprog], [VigenciaInicio], [VigenciaFin], [Estado], [DiasMinimo], [DiasMaximo])
)
ON [PRIMARY]
GO