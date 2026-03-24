CREATE TABLE [dbo].[tCsSegurosProd] (
  [codaseguradora] [char](2) NOT NULL CONSTRAINT [DF_tCsSegurosProd_codaseguradora] DEFAULT (1),
  [codprodseguro] [int] NOT NULL,
  [CodExterno] [varchar](10) NULL,
  [Descripcion] [varchar](200) NULL,
  [primaanual] [decimal](10, 2) NULL,
  [tipodeducible] [char](1) NULL,
  [sumaasegurada] [decimal](18, 2) NULL,
  [deducible] [decimal](10, 2) NULL,
  [coberturas] [char](1) NULL,
  [comision] [decimal](10, 2) NULL,
  [estado] [char](1) NULL,
  [codreporte] [varchar](15) NULL,
  [variasprimas] [char](1) NULL CONSTRAINT [DF_tCsSegurosProd_variasprimas] DEFAULT (0),
  [DireccionAseguradora] [bit] NULL,
  [Nota] [varchar](4000) NULL,
  [codservicio] [int] NULL,
  CONSTRAINT [PK_tCsSegurosProd] PRIMARY KEY CLUSTERED ([codprodseguro], [codaseguradora])
)
ON [PRIMARY]
GO