--------------------------------
-- DAS26_Groupes Articles en T
--------------------------------

select t_citg as Code, 
t_dsca as Description, 
concat(t_citg, ' ', t_dsca) as Affichage 
from ttcmcs023500
where t_citg like '%T%'