-------------------------------------------
-- VER14 - Vérification OP Suivante Gamme
-------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 02/06/2017 problème de calcul des prix de revient suite à des opérations suivantes dans la gamme incohérentes
-- 02/06/2017 soit toutes les opérations suivantes sont à 0, soit il n'y en a qu'une seule
use ln6prddb
select distinct t_mitm
-- t_mitm
from ttirou102500
where
t_nopr>0 -- s'il y a une autre opération suivante que 0 cela pose problème
-- and t_mitm='         LBT105196'
-- on récupère tous les articles ayant plus d'une oprération suivante =0
and t_mitm in (select t_mitm from ttirou102500 where t_mitm like '         %' and t_mitm <> '' and t_nopr=0 group by t_mitm,t_nopr having count(*)>1)
order by t_mitm