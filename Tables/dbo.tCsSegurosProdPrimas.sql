CREATE TABLE [dbo].[tCsSegurosProdPrimas] (
  [codaseguradora] [char](2) NOT NULL CONSTRAINT [DF_tCsSegurosProdPrimas_codaseguradora] DEFAULT (1),
  [codprodseguro] [int] NOT NULL,
  [item] [int] NOT NULL,
  [sumaasegurada] [decimal](18, 2) NULL,
  [prima] [decimal](18, 2) NULL,
  CONSTRAINT [PK_tCsSegurosProdPrimas] PRIMARY KEY CLUSTERED ([codaseguradora], [codprodseguro], [item])
)
ON [PRIMARY]
GO