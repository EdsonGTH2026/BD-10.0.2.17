CREATE TABLE [dbo].[tCsPadronCarteraDetCli] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [codusuariounico] [varchar](15) NULL,
  CONSTRAINT [PK_tCsPadronCarteraDetCli] PRIMARY KEY CLUSTERED ([CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO