-------------------------------------------
-- VER14 - V�rification OP Suivante Gamme
-------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 02/06/2017 probl�me de calcul des prix de revient suite � des op�rations suivantes dans la gamme incoh�rentes
-- 02/06/2017 soit toutes les op�rations suivantes sont � 0, soit il n'y en a qu'une seule
use ln6prddb
select distinct t_mitm
-- t_mitm
from ttirou102500
where
t_nopr>0 -- s'il y a une autre op�ration suivante que 0 cela pose probl�me
-- and t_mitm='         LBT105196'
-- on r�cup�re tous les articles ayant plus d'une opr�ration suivante =0
and t_mitm in (select t_mitm from ttirou102500 where t_mitm like '         %' and t_mitm <> '' and t_nopr=0 group by t_mitm,t_nopr having count(*)>1)
order by t_mitm