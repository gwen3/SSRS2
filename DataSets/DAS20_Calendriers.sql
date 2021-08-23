----------------------
-- DAS20_Calendriers
----------------------

select t_ccal as Code, 
t_dsca as Description, 
concat(t_ccal, ' ', t_dsca) as Affichage 
from ttcccp010500