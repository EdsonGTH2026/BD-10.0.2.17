CREATE TABLE [dbo].[tCsACaIncentivosCortes] (
  [Fecha] [smalldatetime] NOT NULL,
  [Fechacorte] [smalldatetime] NULL,
  CONSTRAINT [PK_tCsACaIncentivosCortes] PRIMARY KEY CLUSTERED ([Fecha])
)
ON [PRIMARY]
GO

GRANT
  DELETE,
  INSERT,
  SELECT,
  UPDATE
ON [dbo].[tCsACaIncentivosCortes] TO [mchavezs2]
GO