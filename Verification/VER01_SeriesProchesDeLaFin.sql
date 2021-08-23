-------------------------------------
-- VER01 - Séries Proches de la Fin
-------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- dboivin 21/05/2018, passage de 15 à 5% sur les séries avec préfix 4 caractères

(select t_nrgr as GroupeSerie, 
t_seri as Serie, 
t_dsca as DescriptionSerie, 
t_ffno as PremierNumeroDispo, 
dbo.convertenum('tc','B61C','a9','bull','yesno',t_blck,'4') as SerieBloquee
from ttcmcs050500 
where t_ffno between 900000 and 999999 
and t_blck = 2 --On ne prend que ceux qui ne sont pas bloqués
and len(t_seri) = 3) --On regarde les séries à 3 caractères
union all
(select t_nrgr as GroupeSerie, 
t_seri as Serie, 
t_dsca as DescriptionSerie, 
t_ffno as PremierNumeroDispo, 
dbo.convertenum('tc','B61C','a9','bull','yesno',t_blck,'4') as SerieBloquee
from ttcmcs050500 
where t_ffno between 95000 and 99999 -- alerte à 5%
and t_blck = 2 --On ne prend que ceux qui ne sont pas bloqués
and len(t_seri) = 4) --On regarde les séries à 4 caractères
