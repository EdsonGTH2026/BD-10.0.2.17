SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsRptCAProAsignado1a6] @fecha smalldatetime,@codasesor varchar(15)
as
SELECT c.codprestamo,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldoneto
FROM tCsCartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=d.codprestamo and pd.codusuario=d.codusuario
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codasesor<>pd.primerasesor
and c.codproducto<>167
and c.codoficina<100
--and c.codasesor='GCS1409891'
and c.codasesor=@codasesor
and c.nrodiasatraso>=1 and c.nrodiasatraso<=6
group by c.codprestamo

GO