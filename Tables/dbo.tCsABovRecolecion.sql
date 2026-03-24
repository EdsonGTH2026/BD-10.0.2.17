CREATE TABLE [dbo].[tCsABovRecolecion] (
  [codoficina] [varchar](4) NOT NULL,
  [fecharec] [smalldatetime] NOT NULL,
  [montorec] [money] NULL,
  [fechaanterior] [smalldatetime] NULL,
  [Capital] [money] NULL,
  [Interes] [money] NULL,
  [Moratorio] [money] NULL,
  [CargoxAtraso] [money] NULL,
  [Seguro] [money] NULL,
  [Impuestos] [money] NULL,
  [TotalCA] [money] NULL,
  [CA_garantias] [money] NOT NULL,
  [TC_Seguros] [money] NOT NULL,
  [CA_desembolsos] [money] NOT NULL,
  [Ah_depositos] [money] NOT NULL,
  [Ah_retiros] [money] NOT NULL,
  [CJ_sobrante] [money] NOT NULL,
  [CJ_faltante] [money] NOT NULL,
  [TOTAL] [money] NULL,
  [Diferencia] [money] NULL,
  CONSTRAINT [PK_tCsABovRecolecion] PRIMARY KEY CLUSTERED ([codoficina], [fecharec]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsABovRecolecion] TO [marista]
GO