CREATE TABLE [dbo].[tClEntidad] (
  [CodEntidadTipo] [varchar](3) NOT NULL,
  [CodEntidad] [varchar](3) NOT NULL,
  [Nombre] [varchar](25) NOT NULL,
  [Descripcion] [varchar](80) NOT NULL,
  [Sigla] [varchar](20) NOT NULL,
  [Activa] [bit] NOT NULL,
  [RUC] [varchar](15) NULL,
  [ContaCodigo] [varchar](25) NOT NULL,
  [ContaRef] [varchar](8) NOT NULL,
  [ContaCodigo1] [varchar](25) NOT NULL
)
ON [PRIMARY]
GO