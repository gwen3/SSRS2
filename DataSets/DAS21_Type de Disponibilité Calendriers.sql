--------------------------------------------
-- DAS21_Type de Disponibilité Calendriers
--------------------------------------------

select t_ract as Code, 
t_ract as Affichage 
from ttcccp050500 
where t_ccal = @cal