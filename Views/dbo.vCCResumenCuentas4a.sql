SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vCCResumenCuentas4a    Script Date: 08/03/2023 09:14:53 pm ******/
create view [dbo].[vCCResumenCuentas4a] as

select vrc.*,
ccd.item, ccd.Direccion, ccd.ColoniaPoblacion, ccd.DelegacionMunicipio, ccd.Ciudad, ccd.Estado, ccd.CP, ccd.NumeroTelefono 
from vCCResumenCuentas4 as vrc, tCCDomicilios as ccd
where vrc.rfc = ccd.rfc

GO