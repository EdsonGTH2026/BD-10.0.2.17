CREATE TABLE [dbo].[tCsSegurosBene] (
  [CodAseguradora] [char](2) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NumPoliza] [varchar](20) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [orden] [int] NULL,
  [porcentaje] [int] NULL,
  [nombrecompleto] [varchar](200) NULL,
  [codparentesco] [int] NULL,
  CONSTRAINT [PK_tCsSegurosBene] PRIMARY KEY CLUSTERED ([CodAseguradora], [CodOficina], [NumPoliza], [CodUsuario])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsSegurosBene] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsSegurosBene_tCsSeguros] FOREIGN KEY ([CodAseguradora], [CodOficina], [NumPoliza]) REFERENCES [dbo].[tCsSeguros] ([CodAseguradora], [CodOficina], [NumPoliza])
GO