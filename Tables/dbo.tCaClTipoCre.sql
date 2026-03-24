CREATE TABLE [dbo].[tCaClTipoCre] (
  [CodTipoCre] [char](2) NOT NULL,
  [NemTipoCre] [char](15) NOT NULL,
  [DescTipoCre] [char](50) NOT NULL,
  CONSTRAINT [PK_tCaClTipoCre] PRIMARY KEY CLUSTERED ([CodTipoCre])
)
ON [PRIMARY]
GO