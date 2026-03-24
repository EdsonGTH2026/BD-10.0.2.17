CREATE TABLE [dbo].[Users] (
  [Usuario] [nvarchar](128) NOT NULL,
  [Password] [nvarchar](4000) NULL,
  CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED ([Usuario])
)
ON [PRIMARY]
GO