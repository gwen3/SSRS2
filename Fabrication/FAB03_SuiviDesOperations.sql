---------------------------------
-- FAB03 - Suivi des Opérations
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select opefab.t_pdno as OrdreFabrication, 
ofab.t_prcd as Priorite, 
opefab.t_cwoc as CentreCharge, 
left(opefab.t_item, 9) as Projet, 
substring(opefab.t_item, 10, len(opefab.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
opefab.t_cmdt as DateDeclaration, 
opefab.t_lfdt as DateLivraisonPlanifie, 
opefab.t_qplo as CumulQtePlanifiee, 
opefab.t_qcmp as CumulQteRealisee, 
opefab.t_qrjc as Rejete, 
opefab.t_prtm as TempsAlloues, 
opefab.t_sptm as TempsPasses 
from ttisfc010500 opefab --Opérations des Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = opefab.t_item --Articles
inner join ttisfc001500 ofab on ofab.t_pdno = opefab.t_pdno --Ordre de Fabrication
where opefab.t_cmdt between @date_f and @date_t --Bornage sur la Date de Déclaration
and opefab.t_cwoc between @cc_f and @cc_t --Bornage sur le Centre de Charge
and left(opefab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication