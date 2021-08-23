---------------------------------
-- DAS27 - Liste Services Vente
---------------------------------

select serv.t_cwoc as Code
,serv.t_dsca as Description
,concat(serv.t_cwoc, ' ', serv.t_dsca) as Affichage
from ttcmcs065500 serv
where serv.t_typd = 1 --Type service de vente
