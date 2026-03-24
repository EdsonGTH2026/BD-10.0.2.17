SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE function  [dbo].[fdu_CAT](@codprestamo varchar(25))  
 returns float  
as   
begin  
  
 --declare @codprestamo varchar(25)  
 --set  @codprestamo='037-170-06-01-02743'  
  
 declare @garantia money  
 select @garantia=g.garantia  
 from tcsdiagarantias g with(nolock)  
 inner join (  
  select min(fecha) fecha from tcsdiagarantias with(nolock) where tipogarantia in ('EFECT','GARAH') and codigo=@codprestamo--'144-169-06-00-00268'  
 ) d on g.fecha=d.fecha  
 where g.tipogarantia in ('EFECT', 'GARAH') and g.codigo=@codprestamo--'144-169-06-00-00268'  
  
 set @garantia = isnull(@garantia,0.00)  
  
 --select @garantia '@garantia'  
 declare @cuota int  
 set @cuota=0  
  
 --declare @porcen money  
 --select @porcen=isnull(garantiaporcen,10) --x  
 --from [10.0.2.14].finmas.dbo.tcaprestamos ca   
 --inner join [10.0.2.14].finmas.dbo.tcasolicitud s on ca.codsolicitud=s.codsolicitud and ca.codoficina=s.codoficina  
 --where ca.codprestamo=@codprestamo  
  
 select @cuota=max(seccuota)  
 from tcspadronplancuotas with(nolock)  
 where codprestamo=@codprestamo--'144-169-06-00-00268'--  
 and codconcepto IN('INTE')  
  
 declare @monto money  
 declare @periodicidad float  
  
 select @monto=p.monto,@periodicidad=m.plazo  
 from tcspadroncarteradet p with(nolock)  
 inner join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha  
 inner join tCaClModalidadPlazo m with(nolock) on c.modalidadplazo=m.modalidadplazo  
 where p.codprestamo=@codprestamo--'144-169-06-00-00268'--  
   
 --declare @valgar money  
 --set @valgar=@monto*@porcen/100  
  
 --if(@garantia>@valgar)  
 --begin  
 -- set @garantia=@valgar  
 --end  
 --select @valgar '@valgar'  
 --select @garantia '@garantia2'  
  
 declare @pagos varchar(8000)  
 select @pagos = coalesce(@pagos+',','') + cast(  
        case when @cuota=seccuota then  
         -@garantia+(sum(case when codconcepto='CAPI' then montocuota else 0 end) + sum(case when codconcepto='INTE' then montocuota else 0 end))  
        else   
         sum(case when codconcepto='CAPI' then montocuota else 0 end) + sum(case when codconcepto='INTE' then montocuota else 0 end)  
         end  
        as varchar(20)) --pago  
 --,sum(case when codconcepto='IVAIT' then montocuota else 0 end) iva  
 from tcspadronplancuotas with(nolock)  
 where codprestamo=@codprestamo--'144-169-06-00-00268'--  
 and codconcepto IN('CAPI','INTE')--,'IVAIT'  
 group by seccuota  
 order by seccuota  
    
 --select @monto '@monto'  
 --set @pagos = '-'+cast(@monto as varchar(20)) + ',' + @pagos HASTA 06.10.2017  
 --set @pagos = '-'+cast((@monto-isnull(@garantia,0)) as varchar(20)) + ',' +cast(@garantia as varchar(20))+ ',' + @pagos --+',-'+cast(@garantia as varchar(20))  
 set @pagos = '-'+cast((@monto-isnull(@garantia,0)) as varchar(20)) + ',' + @pagos --+',-'+cast(@garantia as varchar(20))  
 --select @pagos  
  
 declare @tir float  
 set @tir = (dbo.[fn_CAT_TIR](@pagos,0.0000000001) * 100)  
  
 declare @CAT float  
 set @CAT = dbo.fn_CAT(@tir,@periodicidad)  
 --select @cat  
  
 return @cat  
end  
  
--select dbo.fdu_CAT('144-169-06-00-00268') --212.6976691887 --sin garantia  
--select dbo.fdu_CAT('144-169-06-00-00268') --231.6875850959 --con garantia  
--select dbo.fdu_CAT('006-170-06-04-00309')  
---10000.00,1000.00,734.78,736.60,738.47,740.38,742.35,744.36,746.43,748.55,750.72,752.95,755.24,757.58,759.99,762.46,764.99,767.60,-1000.00  
--231.6481307711  
  
  
GO