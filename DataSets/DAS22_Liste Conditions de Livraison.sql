------------------------------------
-- DAS22 - Conditions de Livraison
------------------------------------

select ' ' as Code, 
' ' as Description, 
' ' as Affichage 
union all 
select t_cdec as Code, 
t_dsca as Description, 
concat(t_cdec, ' ', t_dsca) as Affichage 
from ttcmcs041500