CREATE TABLE [dbo].[tCaASolicitudesCredito] (
  [codsolicitud] [varchar](15) NOT NULL,
  [codoficina] [varchar](4) NOT NULL,
  [codestadoactual] [int] NULL,
  [estadoactual] [varchar](30) NULL,
  [Menor15] [int] NOT NULL,
  [Mayor15] [int] NOT NULL,
  [montoaprobado] [money] NULL,
  [codusuario] [varchar](20) NOT NULL,
  [fechadesembolso] [smalldatetime] NULL,
  [codproducto] [char](3) NOT NULL,
  [fechasolicitud] [smalldatetime] NULL,
  [codasesor] [varchar](15) NULL,
  [promotor] [varchar](200) NULL,
  [tipoRegistro] [varchar](6) NULL,
  [codestado] [varchar](10) NULL,
  [codpromotor] [varchar](15) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaASolicitudesCredito] TO [marista]
GO