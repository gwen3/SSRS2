------------------------------------------------------------
-- Requête pour extraction des classes de produit 
------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select t_cpcl as Classe_Produit
,t_dsca as Description_Classe_Produit
from ttcmcs062500