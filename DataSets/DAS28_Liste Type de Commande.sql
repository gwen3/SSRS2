-----------------------------------
-- DAS28 - Liste Type de Commande
-----------------------------------

select typco.t_sotp as Code
,typco.t_dsca as Description
,concat(typco.t_sotp, ' ', typco.t_dsca) as Affichage
from ttdsls094500 typco