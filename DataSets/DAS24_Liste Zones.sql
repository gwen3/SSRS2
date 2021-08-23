------------------------
-- DAS24 - Liste Zones
------------------------

select '' as Code
,'' as Description
,'' as Affichage
union
select distinct zon.t_creg as Code
,zon.t_dsca as Description
,concat(zon.t_creg, ' - ', zon.t_dsca) as Affichage
from ttcmcs045500 zon 
where zon.t_dsca != 'NE PLUS UTILISER' --On ne prend pas les vieux codes