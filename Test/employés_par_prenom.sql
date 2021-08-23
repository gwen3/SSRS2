-- 05/02/2020 requête test pour démo Bernard


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @prenom_f varchar(20) = 'Bernard';
declare @prenom_t varchar(20) = 'DAMIEN';


select
ttccom001500.t_namb, -- prénom
ttccom001500.t_nama, -- nom complet
ttccom001500.t_emno  -- code employé
-- tests
-- , *
from ttccom001500 -- Employés - Caractéristiques générale
where
ttccom001500.t_namb between @prenom_f and @prenom_t -- plage de prénoms
order by ttccom001500.t_namb asc