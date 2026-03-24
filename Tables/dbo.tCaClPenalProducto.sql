CREATE TABLE [dbo].[tCaClPenalProducto] (
  [CodProducto] [char](3) NOT NULL,
  [CodIntPenal] [int] NOT NULL,
  [DescIntPenal] [varchar](20) NOT NULL,
  [IniIntPenal] [int] NOT NULL,
  [FinIntPenal] [int] NOT NULL,
  [ValIntPenal] [money] NOT NULL
)
ON [PRIMARY]
GO