CREATE TABLE [dbo].[tCsCaRepAvanMetPromDesembolsosTemp] (
  [Id] [int] IDENTITY,
  [CodAsesor] [varchar](20) NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [nroprestamos] [int] NULL,
  [monto] [money] NULL
)
ON [PRIMARY]
GO