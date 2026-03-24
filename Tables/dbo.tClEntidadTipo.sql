CREATE TABLE [dbo].[tClEntidadTipo] (
  [CodEntidadTipo] [varchar](3) NOT NULL,
  [Nombre] [varchar](25) NOT NULL,
  [Descripcion] [varchar](50) NOT NULL,
  [IdOperSospechosa] [int] NOT NULL,
  [ContaCodigo] [varchar](25) NULL,
  [EsEntidadFinanciera] [bit] NULL,
  [ContaCodigo1] [varchar](25) NOT NULL
)
ON [PRIMARY]
GO