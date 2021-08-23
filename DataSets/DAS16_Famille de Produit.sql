-----------------------------
-- DAS16_Famille de Produit
-----------------------------

select t_nctp as Code, 
t_dsca as Description, 
concat(t_nctp, ' ', t_dsca) as Affichage 
from tqmncm001500
