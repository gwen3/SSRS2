---------------------------------
-- DAS33_Liste Groupes Articles
---------------------------------

select t_citg as Code, 
t_dsca as Description, 
concat(t_citg, ' ', t_dsca) as Affichage 
from ttcmcs023500