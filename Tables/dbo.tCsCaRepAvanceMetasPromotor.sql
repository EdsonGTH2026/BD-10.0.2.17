CREATE TABLE [dbo].[tCsCaRepAvanceMetasPromotor] (
  [Id] [int] IDENTITY,
  [Fecha] [smalldatetime] NULL,
  [Region] [varchar](30) NULL,
  [CodOficina] [varchar](3) NULL,
  [Sucursal] [varchar](50) NULL,
  [CodPromotor] [varchar](20) NULL,
  [Promotor] [varchar](50) NULL,
  [CarteraVigIni] [money] NULL,
  [CarteraVigAlDia] [money] NULL,
  [Crecimiento] [money] NULL,
  [MetaCrecimiento] [money] NULL,
  [CobranzaProg] [money] NULL,
  [ColocadoHoy] [money] NULL,
  [EnPanel] [money] NULL,
  [FaltaParaMeta] [money] NULL,
  [EnRiesgoVencida] [money] NULL
)
ON [PRIMARY]
GO