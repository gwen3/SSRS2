select top 10000
 tbrgru901500.t_ntra, -- N� de tra�abilit�
 tbrgru901500.t_mitm, -- Article compos�
 tbrgru902500.t_nosl_m, -- N� de s�rie compos�
 tbrgru902500.t_sitm, -- Article composant
 tbrgru902500.t_nosl_c, -- N� de s�rie composant
 *
from tbrgru902500 -- lien compos� - composants
left join tbrgru901500 -- lien compos� - N� de tra�abilit�
	on tbrgru901500.t_nosl_m = tbrgru902500.t_nosl_m -- N� de s�rie compos�
-- where tbrgru902500.t_sitm='         100036700'
order by tbrgru902500.t_nosl_c
-- group by tbrgru902500.t_sitm, tbrgru902500.t_nosl_c
-- having count(*) > 1
;