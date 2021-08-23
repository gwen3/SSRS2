-- 05/02/2020 requ�te test pour d�mo Bernard


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @prenom_f varchar(20) = 'Bernard';
declare @prenom_t varchar(20) = 'DAMIEN';


select
ttccom001500.t_namb, -- pr�nom
ttccom001500.t_nama, -- nom complet
ttccom001500.t_emno  -- code employ�
-- tests
-- , *
from ttccom001500 -- Employ�s - Caract�ristiques g�n�rale
where
ttccom001500.t_namb between @prenom_f and @prenom_t -- plage de pr�noms
order by ttccom001500.t_namb asc