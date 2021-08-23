-- 03/03/2021 création pour changement 215, recherche des VIN affectés récemment pour création du dossier d'homologation

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
set nocount on
declare @date_historique date = DATEADD(DD, -5, CAST(CURRENT_TIMESTAMP AS DATE))
select
distinct lcde.t_serl -- numéro de série
-- tests
-- *
from ttdsls401500 lcde -- Lignes de commande client
inner join ttdsls411500 artlcde on artlcde.t_orno = lcde.t_orno and artlcde.t_pono = lcde.t_pono and artlcde.t_sqnb = lcde.t_sqnb -- Données articles lignes de commandes
where
lcde.t_dtaf > @date_historique -- date d'affectation
and lcde.t_orno like 'LV%' -- commandes commençant par LV uniquement pour l'instant pour exclure les numéros de série de caisses Labbé
and (lcde.t_orno not like 'LV9%' or lcde.t_orno like 'LV9%' and artlcde.t_citg = 'CBS003') -- exclusion de tous les produits constructeur pour exclure les cabines ACI mais garder les Bennes (CBS003)
-- tests
-- and ttdsls401500.t_serl in ('AC0010010XA027154','V00002110XA027155')
order by lcde.t_serl asc