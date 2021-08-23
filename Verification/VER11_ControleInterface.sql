-------------------------------
-- VER11 - Controle Interface
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select enreg.t_enrg as Enregistrement, 
enreg.t_code as CodeInterface, 
enreg.t_seqn as SequenceEnregistrement, 
enreg.t_cle1 as Cle1, 
enreg.t_cle2 as Cle2, 
enreg.t_cle3 as Cle3, 
enreg.t_cle4 as Cle4, 
enreg.t_refe as ReferenceEnregistrement, 
enreg.t_dtin as DateEntree, 
enreg.t_dttr as DateTraitement, 
dbo.convertenum('zg','B61C','a9','bull','int.status',enreg.t_stat,'4') as StatutEnregistrement 
from tzgint010500 enreg --Enregistrement
where enreg.t_stat = 12 or enreg.t_stat = 15 --On prend les enregistrements en Erreurs ou Traités