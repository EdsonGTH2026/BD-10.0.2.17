CREATE TABLE [dbo].[tCsSegurosProdCob] (
  [codaseguradora] [char](2) NOT NULL CONSTRAINT [DF_tCsSegurosProdCob_codaseguradora] DEFAULT (1),
  [codprodseguro] [int] NOT NULL,
  [item] [int] NOT NULL,
  [descripcion] [varchar](200) NULL,
  [sumaaseg] [decimal](18, 2) NULL,
  CONSTRAINT [PK_tCsSegurosProdCob] PRIMARY KEY CLUSTERED ([codprodseguro], [item], [codaseguradora])
)
ON [PRIMARY]
GO