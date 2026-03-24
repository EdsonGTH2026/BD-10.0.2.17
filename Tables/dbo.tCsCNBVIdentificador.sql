CREATE TABLE [dbo].[tCsCNBVIdentificador] (
  [periodo] [int] NOT NULL,
  [codsistema] [char](2) NOT NULL,
  [codprestamo] [varchar](20) NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [identificador] [varchar](50) NULL,
  [RFC] [varchar](13) NULL,
  CONSTRAINT [PK_tCsCNBVIdentificador] PRIMARY KEY CLUSTERED ([periodo], [codsistema], [codprestamo], [codusuario]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT
  DELETE,
  INSERT,
  SELECT
ON [dbo].[tCsCNBVIdentificador] TO [rie_sbravoa]
GO

GRANT
  DELETE,
  INSERT,
  SELECT
ON [dbo].[tCsCNBVIdentificador] TO [rie_ldomingueze]
GO

GRANT
  DELETE,
  INSERT,
  SELECT
ON [dbo].[tCsCNBVIdentificador] TO [rie_jalvarezc]
GO

GRANT
  DELETE,
  INSERT,
  SELECT
ON [dbo].[tCsCNBVIdentificador] TO [rie_blozanob]
GO