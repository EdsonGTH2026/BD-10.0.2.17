SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptCaCosechasPorVerificadorTrimestreEnColumnas] (@CodPromotor as varchar(250))
as
--declare @CodPromotor as varchar(20)
--set @CodPromotor ='GAY1503851'

select 
	t3.PromotorReporte,
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '1T - 2015'
        group by  codverificadorData
    ),-0.01) as '1T 2015 Saldo',
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '2T - 2015'
        group by  codverificadorData
    ),-0.01) as '2T 2015 Saldo',
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '3T - 2015'
        group by  codverificadorData
    ),-0.01) as '3T 2015 Saldo',
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '4T - 2015'
        group by  codverificadorData
    ),-0.01) as '4T 2015 Saldo',

isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '1T - 2016'
        group by codverificadorData
    ),-0.01) as '1T 2016 Saldo',
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '2T - 2016'
        group by  codverificadorData
    ),-0.01) as '2T 2016 Saldo',
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '3T - 2016'
        group by  codverificadorData
    ),-0.01) as '3T 2016 Saldo',
isnull((  	select ((sum(Saldo2)/ sum(Monto)) * 100 ) as CER@4_Saldo
        from tCsCaCosechasBase 
        where codverificadorData = t3.PromotorReporte and Trimestre = '4T - 2016'
        group by  codverificadorData
    ),-0.01) as '4T 2016 Saldo',
-----------------------------------------

isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where  codverificadorData =t3.PromotorReporte and Trimestre = '1T - 2015'
        group by  codverificadorData
    ),-0.01) as '1T 2015 Numero',
isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData =t3.PromotorReporte and Trimestre = '2T - 2015'
        group by  codverificadorData
    ),-0.01) as '2T 2015 Numero',
isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData =t3.PromotorReporte and Trimestre = '3T - 2015'
        group by  codverificadorData
    ),-0.01) as '3T 2015 Numero',
isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData =t3.PromotorReporte and Trimestre = '4T - 2015'
        group by  codverificadorData
    ),-0.01) as '4T 2015 Numero',

isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData=t3.PromotorReporte 
		and Trimestre = '1T - 2016'
        group by  codverificadorData
    ),-0.01) as '1T 2016 Numero',
isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData =t3.PromotorReporte and Trimestre = '2T - 2016'
        group by  codverificadorData
    ),-0.01) as '2T 2016 Numero',
isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData =t3.PromotorReporte and Trimestre = '3T - 2016'
        group by  codverificadorData
    ),-0.01) as '3T 2016 Numero',
isnull((  	select ((convert(money,sum(ContarSaldo2)) / convert(money,count(CodUsuario))) * 100)  as 'CER@4 Numero'
        from tCsCaCosechasBase 
        where codverificadorData =t3.PromotorReporte and Trimestre = '4T - 2016'
        group by codverificadorData
    ),-0.01) as '4T 2016 Numero'
		
	from 
	
	tCsCaCosechasBase  as t3
	
	where t3.PromotorReporte = @CodPromotor
	
	group by t3.PromotorReporte, t3.PromotorReporteNombre

GO