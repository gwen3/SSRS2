--------------------------------------
-- VER05_Formats d'Unités Génériques
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Vérifier l'existence des devises dans les formats par unité générique
(select 'Code 001' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '001'))
union all 
(select 'Code 002' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '002'))
union all 
(select 'Code 003' as Source, 
t_ccur as Devise   
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '003'))
union all 
(select 'Code 004' as Source, 
t_ccur as Devise  
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '004'))
union all 
(select 'Code 005' as Source, 
t_ccur as Devise  
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '005'))
union all 
(select 'Code 006' as Source, 
t_ccur as Devise  
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '006'))
union all 
(select 'Code 007' as Source, 
t_ccur as Devise  
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '007'))
union all 
(select 'Code 008' as Source, 
t_ccur as Devise  
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '008'))
union all 
(select 'Code 009' as Source, 
t_ccur as Devise  
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '009'))
union all 
(select 'Code 010' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '010'))
union all 
(select 'Code 011' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '011'))
union all  
(select 'Code 020' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '020'))
union all 
(select 'Code 021' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '021'))
union all
(select 'Code 095' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '095'))
union all
(select 'Code 096' as Source, 
t_ccur as Devise 
from tttaad106000 
where t_ccur not in (select t_ccur from tttaad107000 where t_curf = '096'))
