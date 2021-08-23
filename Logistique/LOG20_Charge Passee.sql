--------------------------
-- LOG20 - Charge Passee 
--------------------------

if (@emp_f != ' ')
(select donof.t_trdt as DateTransaction, 
donof.t_emno as CodeEmploye, 
empe.t_nama as NomEmploye, 
donof.t_hrea as TempsMainOeuvre, 
(select sum(opt2.t_prtm) from ttisfc010500 opt2 where opt2.t_pdno = opt.t_pdno) as HeureMainOeuvreAlloueesOF, 
opt.t_cwoc as CentreCharge, 
rou.t_dsca as DescriptionCentreCharge, 
opt.t_mcho as HeuresMachines, 
year(opt.t_trno) as AnneeFabrication, 
datepart(isowk,opt.t_trno) as SemaineFabrication, 
opt.t_prdt as DateDebutPreparationExecution, 
opt.t_trno as DateFinPreparationExecution, --Champ Transport A (Opération Suivante)
opt.t_pdno as OrdreFabrication, 
opt.t_opno as OperationOF, 
opt.t_opst as CodeStatutOperation, 
dbo.convertenum('ti','B61C','a9','bull','sfc.opst',opt.t_opst,'4') as StatutOperation, 
donof.t_tano as Tache, 
tac.t_dsca as DescriptionTache, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
emp.t_namd as FamillePlanificateur, 
ofab.t_prcd as Priorite, 
opt.t_mcno as Machine, 
opt.t_prtm as HeureMainOeuvreAllouees, 
opt.t_sptm as HeureMainOeuvrePassees, 
opt.t_retm as TempsRestant, 
(case
when opt.t_qplo != 0
	then ((opt.t_prtm/opt.t_qplo) * (opt.t_qplo - opt.t_qcmp)) 
else 0
end) as TempsRestantCalcule, 
opt.t_qplo as QuantitePlanifiee, 
ofab.t_grid as GroupeOrdreSFC, 
opt.t_sutm as TempsPreparationMoyen, 
ofab.t_qdlv as QuantiteLivree, 
(opt.t_qplo - opt.t_qcmp) as QuantiteResteALivrer, 
opt.t_qcmp as QuantiteCumuleeAchevee, 
opt.t_qrjc as QuantiteCumuleeRejetee, 
art.t_ctyp as TypeProduit, 
(case 
when opt.t_prdt < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateDebutPreparation, 
(case 
when opt.t_trno < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateFinPreparation, 
ofab.t_rdld as DateLivraisonRequise, 
ofab.t_pldt as DateLivraisonPlanifiee, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
(case 
when ofab.t_rdld < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateLivraisonRequise, 
ofab.t_cmdt as DateAchevementOF, 
opt.t_cmdt as DateAchevementOperation, 
--rajout par rbesnier le 25/01/2019
art.t_citg as GroupeArticle, 
dim3.t_desc as Activite 
from ttisfc010500 opt --Opération des Ordres de Fabrication
inner join ttisfc001500 ofab on ofab.t_pdno = opt.t_pdno --Ordre de Fabrication
left outer join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttirou001500 rou on rou.t_cwoc = opt.t_cwoc --Centre de Charge
left outer join ttccom001500 emp on emp.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttirou003500 tac on tac.t_tano = opt.t_tano --Tâches
left outer join tbptmm120500 donof on donof.t_orno = opt.t_pdno and donof.t_opno = opt.t_opno -- and donof.t_tano = opt.t_tano --Données Ordre Fabrication
left outer join ttccom001500 empe on empe.t_emno = donof.t_emno --Employés - Ordre Fab
--rajout par rbesnier le 25/01/2019
left outer join ttfgld010500 dim3 on dim3.t_dtyp = 3 and dim3.t_dimx = left(art.t_citg, 2) --Dimensions - Activités
where left(opt.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and opt.t_cwoc between @cwoc_f and @cwoc_t --Bornage sur le Centre de Charge
and ofab.t_cmdt between @dateachof_f and @dateachof_t --Bornage sur la Date d'Achevement de l'OF
and opt.t_cmdt between @dateachop_f and @dateachop_t --Bornage sur la Date d'Achevement de l'Operation
and donof.t_emno between @emp_f and @emp_t --Bornage sur les Employés
and empe.t_cwoc between @cc_f and @cc_t --Bornage sur le Département de l'Employé Ordre de Fab
)
else
(select donof.t_trdt as DateTransaction, 
donof.t_emno as CodeEmploye, 
empe.t_nama as NomEmploye, 
donof.t_hrea as TempsMainOeuvre, 
(select sum(opt2.t_prtm) from ttisfc010500 opt2 where opt2.t_pdno = opt.t_pdno) as HeureMainOeuvreAlloueesOF, 
opt.t_cwoc as CentreCharge, 
rou.t_dsca as DescriptionCentreCharge, 
opt.t_mcho as HeuresMachines, 
year(opt.t_trno) as AnneeFabrication, 
datepart(isowk,opt.t_trno) as SemaineFabrication, 
opt.t_prdt as DateDebutPreparationExecution, 
opt.t_trno as DateFinPreparationExecution, --Champ Transport A (Opération Suivante)
opt.t_pdno as OrdreFabrication, 
opt.t_opno as OperationOF, 
opt.t_opst as CodeStatutOperation, 
dbo.convertenum('ti','B61C','a9','bull','sfc.opst',opt.t_opst,'4') as StatutOperation, 
donof.t_tano as Tache, 
tac.t_dsca as DescriptionTache, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
emp.t_namd as FamillePlanificateur, 
ofab.t_prcd as Priorite, 
opt.t_mcno as Machine, 
opt.t_prtm as HeureMainOeuvreAllouees, 
opt.t_sptm as HeureMainOeuvrePassees, 
opt.t_retm as TempsRestant, 
(case
when opt.t_qplo != 0
	then ((opt.t_prtm/opt.t_qplo) * (opt.t_qplo - opt.t_qcmp)) 
else 0
end) as TempsRestantCalcule, 
opt.t_qplo as QuantitePlanifiee, 
ofab.t_grid as GroupeOrdreSFC, 
opt.t_sutm as TempsPreparationMoyen, 
ofab.t_qdlv as QuantiteLivree, 
(opt.t_qplo - opt.t_qcmp) as QuantiteResteALivrer, 
opt.t_qcmp as QuantiteCumuleeAchevee, 
opt.t_qrjc as QuantiteCumuleeRejetee, 
art.t_ctyp as TypeProduit, 
(case 
when opt.t_prdt < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateDebutPreparation, 
(case 
when opt.t_trno < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateFinPreparation, 
ofab.t_rdld as DateLivraisonRequise, 
ofab.t_pldt as DateLivraisonPlanifiee, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
(case 
when ofab.t_rdld < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateLivraisonRequise, 
ofab.t_cmdt as DateAchevementOF, 
opt.t_cmdt as DateAchevementOperation, 
--rajout par rbesnier le 25/01/2019
art.t_citg as GroupeArticle, 
dim3.t_desc as Activite 
from ttisfc010500 opt --Opération des Ordres de Fabrication
inner join ttisfc001500 ofab on ofab.t_pdno = opt.t_pdno --Ordre de Fabrication
left outer join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttirou001500 rou on rou.t_cwoc = opt.t_cwoc --Centre de Charge
left outer join ttccom001500 emp on emp.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttirou003500 tac on tac.t_tano = opt.t_tano --Tâches
left outer join tbptmm120500 donof on donof.t_orno = opt.t_pdno and donof.t_opno = opt.t_opno --and donof.t_tano = opt.t_tano --Données Ordre Fabrication
left outer join ttccom001500 empe on empe.t_emno = donof.t_emno --Employés - Ordre Fab
--rajout par rbesnier le 25/01/2019
left outer join ttfgld010500 dim3 on dim3.t_dtyp = 3 and dim3.t_dimx = left(art.t_citg, 2) --Dimensions - Activités
where left(opt.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and opt.t_cwoc between @cwoc_f and @cwoc_t --Bornage sur le Centre de Charge
and ofab.t_cmdt between @dateachof_f and @dateachof_t --Bornage sur la Date d'Achevement de l'OF
and opt.t_cmdt between @dateachop_f and @dateachop_t --Bornage sur la Date d'Achevement de l'Operation
)