--------------------------------------------------
-- VER07 - Impression des factures hors lasernet
--------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select fai.t_user as Utilisateur, 
fai.t_cdev as Imprimante, 
fai.t_date as DateImpression, 
fai.t_time as HeureImpression, 
right(fai.t_tmpf, 12) as FichierTemporaire, 
fai.t_seqn as NumeroSequence,
concat(fai.t_spac,fai.t_smod,fai.t_sses) as Nom_Session
from tttaad320000 fai --File d'Attente de l'Imprimante
where fai.t_rpac = 'ci' --Paramètre pour récupérer les factures
and fai.t_rmod = 'sli' --Paramètre pour récupérer les factures
and fai.t_repc = '120011000' --Paramètre pour récupérer les factures
and fai.t_cdev not like '%LAS%' --On exclu les imprimantes laser
and fai.t_cdev != 'LASER%' --On exclu les imprimantes lasernet
--and fai.t_sses != '8110m000' --Exclusion réedition de factures
and fai.t_date = datediff(day, 1, getdate()); --On prend les impressions de la veille