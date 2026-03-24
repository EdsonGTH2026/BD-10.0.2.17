CREATE TABLE [dbo].[tCoTraspasoDiario] (
  [item] [int] IDENTITY,
  [fecha] [smalldatetime] NULL,
  [codoficina] [varchar](4) NULL,
  [codprestamo] [varchar](25) NULL,
  [codcta] [varchar](15) NULL,
  [debe] [money] NULL,
  [haber] [money] NULL,
  [glosagral] [varchar](200) NULL
)
ON [PRIMARY]
GO