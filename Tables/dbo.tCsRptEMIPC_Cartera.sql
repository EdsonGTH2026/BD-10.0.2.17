CREATE TABLE [dbo].[tCsRptEMIPC_Cartera] (
  [Fecha] [smalldatetime] NULL,
  [CodPromotor] [varchar](20) NULL,
  [CodOficina] [varchar](3) NULL,
  [Tipo] [varchar](20) NULL,
  [item] [int] NULL,
  [etiqueta] [varchar](20) NULL,
  [InicioMes] [money] NULL,
  [Hoy] [money] NULL,
  [CreSalMay500] [money] NULL,
  [CrePropio] [money] NULL,
  [CreHuefan] [money] NULL,
  [MetaCre] [varchar](100) NULL,
  [PorBono] [money] NULL,
  [NumPasoAM] [int] NULL
)
ON [PRIMARY]
GO