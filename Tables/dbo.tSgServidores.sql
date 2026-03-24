CREATE TABLE [dbo].[tSgServidores] (
  [Servidor] [char](3) NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [ServidorBD] [varchar](20) NULL,
  [BaseDatos] [varchar](20) NULL,
  [Usuario] [varchar](20) NULL,
  [Password] [varchar](20) NULL,
  CONSTRAINT [PK_tSgServidores] PRIMARY KEY CLUSTERED ([Servidor])
)
ON [PRIMARY]
GO