------------------------------------------------------------
-- Gaëtan Travail sur les articles DON
------------------------------------------------------------

select ligcde.t_orno as CommandeClient, 
ligcde.t_pono as LigneCommandeClient, 
ligcde.t_corn as NumeroMarquage, 
left(ligcde.t_item, 9) as Projet, 
substring(ligcde.t_item, 10, len(ligcde.t_item)) as Article, 
ligcde.t_serl as NumeroChassis, 
ligcde.t_odat as DateCommande, 
ligcde.t_dapc as DateArriveePrevueChassis, 
ligcde.t_dtaf as DateAffectationChassis, 
serie.t_rdat as DateArriveeChassis, 
ligcde.t_dmad as DateMADC, 
ligcde.t_ddta as DateProductionGruau, 
cde.t_txtb as TextePiedPageCommande, 
art.t_citg as Publicite, --Lorsque l'article que l'on test existe, on récupère une donnée que l'on ne récupère pas si l'article n'existe pas. Traitement ensuite via SSRS
numparc.t_rdat as DateReceptionNumeroParc, 
pub.t_rdat as DateReceptionPublicite, 
groupe.t_rdat as DateReceptionGroupe 
from ttdsls401500 ligcde --Lignes de Commandes Clients
inner join twhltc500500 serie on serie.t_item = ligcde.t_item and serie.t_serl = ligcde.t_serl --Articles série pas magasin
inner join ttdsls400500 cde on cde.t_orno = ligcde.t_orno --Commandes Clients
left outer join ttcibd001500 art on art.t_item = concat(left(ligcde.t_item, 9), 'DON1') --Articles
left outer join twhltc500500 numparc on numparc.t_item = concat(left(ligcde.t_item, 9), 'DON1') and numparc.t_serl = ligcde.t_corn --On va chercher le chassis de l'article créé spécifiquement
left outer join twhltc500500 pub on pub.t_item = concat(left(ligcde.t_item, 9), 'DON2') and pub.t_serl = ligcde.t_corn --On va chercher le chassis de l'article créé spécifiquement
left outer join twhltc500500 groupe on groupe.t_item = concat(left(ligcde.t_item, 9), 'DON3') and groupe.t_serl = ligcde.t_corn --On va chercher le chassis de l'article créé spécifiquement
where ligcde.t_ofbp in ('100003963', '100003964', '100003965', '100003966', '100003967', '100004001', '100004025', '100004029', '100004030', '100004031', '100004047', '100004049', '100009140', '100009339', '100009550', '100017394', '100017466', '100017543', '100017565', '100017849', '100017850', '100017852', '100017854', '100028942', '100029081', '100029630', '100029631', '100029657', '100029743', '100029761') --On prend tous les comptes de Petit Forestier
and left(ligcde.t_item, 9) != '' --On ne prend pas les articles sans projet de manière à enlever par exemple les articles CHASSIS