SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[RptCaPrestamosTasaCambiada]
@fecha smalldatetime
as
--declare @fecha as smalldatetime
--set @fecha='20140915'
select distinct c.codprestamo,/*c.codusuario,d.codusuario,*/tcsclientes.codorigen,/*tcsclientes.codusuario,*/tcaproducto.nombreprodcorto,
						 tcsclientes.nombrecompleto,c.montodesembolso,tcaprodinteresrelacion.inteanual tasaproducto,c.tasaintcorriente tasaprestamo,
						 /*tcstransacciondiaria.codusuario,tcstransacciondiaria.tipotransacnivel3,*/c.nrocuotas,d.secuenciacliente,
						 case when tcscltipotransacnivel3.tipotransacnivel3='23' then 'SI' ELSE 'NO' END OPORTUNIDADES
from  tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcsclientes with(nolock) on tcsclientes.codusuario=d.codusuario
inner join tcaproducto with(nolock) on tcaproducto.codproducto=c.codproducto
inner join [10.0.2.14].Finmas.dbo.tcaprodinteresrelacion AS tcaprodinteresrelacion on tcaprodinteresrelacion.codproducto=c.codproducto
left join tcstransacciondiaria with(nolock) on tcstransacciondiaria.codusuario=d.codusuario 
			 and tcstransacciondiaria.tipotransacnivel3 = '23' and tcstransacciondiaria.fecha between dateadd(year,-1, @fecha) and @fecha
			 and tcstransacciondiaria.codsistema = 'TC'
left join tcscltipotransacnivel3 with(nolock) on tcscltipotransacnivel3.tipotransacnivel3=tcstransacciondiaria.tipotransacnivel3
			 and tcscltipotransacnivel3.codsistema='TC'
where c.fechadesembolso=@fecha and c.cartera='ACTIVA' and tcaprodinteresrelacion.inteanual <> c.tasaintcorriente 
order by c.codprestamo



GO