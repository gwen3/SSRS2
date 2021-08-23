------------------------------
-- VER04 - Unités Génériques
------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Vérifier que l'unité générique existe bien dans la devise et inversement. Retourne les NOK
(select 'Unites Generiques' as Source, 
t_ccur as Devise, 
t_desc as DescriptionDevise, 
'' as DescriptionAbregee, 
t_symb as CodeISO  
from tttaad106000 
where t_ccur not in (select t_ccur from ttcmcs002500))
union all
(select 'Devises' as Source, 
t_ccur as Devise, 
t_dsca as DescriptionDevise, 
t_dscb as DescriptionAbregee, 
t_iccc as CodeISO  
from ttcmcs002500  
where t_ccur not in (select t_ccur from tttaad106000))


--Vérifier que le symbole et la devise soient bien les mêmes
(select 'Unite Generiques' as Source, 
t_ccur as Devise, 
t_symb as CodeISO 
from tttaad106000 
where t_ccur != t_symb) 
union all 
(select 'Devises' as Source, 
t_ccur as Devise, 
t_iccc as CodeISO 
from ttcmcs002500 
where t_ccur != t_iccc)