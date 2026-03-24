SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*ORIGINADA*/
CREATE procedure [dbo].[pCsRptCAProOriginado60] @fecha smalldatetime,@codasesor varchar(15)
as
SELECT c.codprestamo,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldoneto
FROM tCsCartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=d.codprestamo and pd.codusuario=d.codusuario
where c.fecha=@fecha and fechadesembolso>='20140101' --and c.codasesor=pd.primerasesor
and c.codproducto<>167
and c.codoficina<100
--and pd.primerasesor='GCS1409891'
and pd.primerasesor=@codasesor
and c.nrodiasatraso>=60
group by c.codprestamo
GO