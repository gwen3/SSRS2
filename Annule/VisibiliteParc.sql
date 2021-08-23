----------
-- Parc --
----------

--Visibilite_Parc
select left(t_item, 9) as Projet, 
substring(t_item, 10, len(t_item)) as Article, 
t_serl as Chassis, 
t_cwar as Magasin, 
t_rdat as DateReception, 
t_cdf_coul as CodeCouleur, 
dbo.convertlistcdf('wh','B61C','a9','grup','cou',t_cdf_coul,'4') as NomCouleur, 
t_cdf_marq as CodeMarque, 
dbo.convertlistcdf('wh','B61C','a9','grup','mar',t_cdf_marq,'4') as NomMarque, 
t_cdf_type as Type, 
dbo.convertlistcdf('wh','B61C','a9','grup','typ',t_cdf_type,'4') as NomType 
from twhltc500500 
where t_isdt < '1980-01-01' 
and t_cwar = @mag;
