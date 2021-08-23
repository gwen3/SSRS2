select top 10000
 tbrgru901500.t_ntra, -- N° de traçabilité
 tbrgru901500.t_mitm, -- Article composé
 tbrgru902500.t_nosl_m, -- N° de série composé
 tbrgru902500.t_sitm, -- Article composant
 tbrgru902500.t_nosl_c, -- N° de série composant
 *
from tbrgru902500 -- lien composé - composants
left join tbrgru901500 -- lien composé - N° de traçabilité
	on tbrgru901500.t_nosl_m = tbrgru902500.t_nosl_m -- N° de série composé
-- where tbrgru902500.t_sitm='         100036700'
order by tbrgru902500.t_nosl_c
-- group by tbrgru902500.t_sitm, tbrgru902500.t_nosl_c
-- having count(*) > 1
;