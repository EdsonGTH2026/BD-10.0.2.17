CREATE TABLE [dbo].[tCsRptEMI_LS_Metas] (
  [Fecha] [smalldatetime] NULL,
  [CodOficina] [varchar](3) NULL,
  [item] [int] NULL,
  [Indicador] [varchar](30) NULL,
  [Meta] [varchar](100) NULL,
  [BonoAlcanzable] [varchar](20) NULL,
  [PorcBonoAlcanzado] [varchar](20) NULL,
  [BonoFinal] [varchar](20) NULL
)
ON [PRIMARY]
GO