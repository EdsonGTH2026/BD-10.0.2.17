SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptCaCosechasPorOficinaEnColumnas] (@codoficina varchar(3))
as

	select 
	t3.CodOficina,
	t3.sucursal,
	t3.PromotorReporteNombre as PromotorReporte,

	isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '1T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '1T - 2014 Saldo',
	isnull((   select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '2T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '2T - 2014 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '3T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '3T - 2014 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '4T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '4T - 2014 Saldo',

	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '1T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '1T - 2015 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '2T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '2T - 2015 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '3T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '3T - 2015 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '4T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '4T - 2015 Saldo',

	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '1T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '1T - 2016 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '2T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '2T - 2016 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '3T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '3T - 2016 Saldo',
	isnull((	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '4T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '4T - 2016 Saldo',

-----------------------
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '1T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '1T - 2014 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '2T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '2T - 2014 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '3T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '3T - 2014 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '4T - 2014'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '4T - 2014 Numero',

	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '1T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '1T - 2015 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '2T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '2T - 2015 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '3T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '3T - 2015 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '4T - 2015'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '4T - 2015 Numero',

	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '1T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '1T - 2016 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '2T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '2T - 2016 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '3T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '3T - 2016 Numero',
	isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where CodOficina =t3.CodOficina and PromotorReporte =t3.PromotorReporte and Trimestre = '4T - 2016'
        group by  CodOficina,sucursal,PromotorReporte
    ),-0.01) as '4T - 2016 Numero'

	from 	
	tCsCaCosechasBase  as t3
	where t3.CodOficina =@codoficina
and t3.PromotorReporteNombre <> 'HUERFANO'
    group by t3.CodOficina,t3.sucursal, t3.PromotorReporte, t3.PromotorReporteNombre

GO