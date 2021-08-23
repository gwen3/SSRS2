----------------
-- QUA04 - NQI
----------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select opof.t_opno as OperationOrdreFabrication, 
cout.t_pono as PositionMatiere, 
opof.t_pdno as OrdreFabrication, 
left(opof.t_item, 9) as Projet, 
substring(opof.t_item, 10, len(opof.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
trans.t_lgdt as DateTransaction, 
--left(trans.t_item, 9) as ProjetArticleTransaction, 
--substring(trans.t_item, 10, len(trans.t_item)) as ArticleTransaction, 
left(cout.t_sitm, 9) as ProjetArticleTransaction, 
substring(cout.t_sitm, 10, len(cout.t_sitm)) as ArticleTransaction, 
arttran.t_dsca as DescriptionArticleTransaction, 
cout.t_qucs as Quantite, 
cout.t_aamt_1 as PrixRevientReel, 
'' as Employe, 
'' as NomEmploye, 
'' as NombreHeures 
from ttisfc010500 opof --Opérations des Ordres de Fabrication
left outer join tticst001500 cout on cout.t_pdno = opof.t_pdno and cout.t_opno = opof.t_opno --Couts Matières Estimées et Réels
left outer join ttcibd001500 art on art.t_item = opof.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupes Articles
left outer join twhinr110500 trans on trans.t_koor = 1 and trans.t_orno = opof.t_pdno and trans.t_pono = cout.t_pono and trans.t_item = cout.t_sitm --Transactions de Stock par Articles et par Magasin
left outer join ttcibd001500 arttran on arttran.t_item = cout.t_sitm --Articles des Transactions de Stocks
--left outer join ttcibd001500 arttran on arttran.t_item = trans.t_item --Articles des Transactions de Stocks
where left(opof.t_pdno,2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par l'OF
and opof.t_tano = 'LVT203' --On ne prend que les tâches LVT203 (commune à toutes les sociétés)
and trans.t_lgdt between @date_f and @date_t --Bornage sur la Date de Transaction
and opof.t_pdno between @ofab_f and @ofab_t --Bornage sur le numéro d'OF
) union
(select donof.t_opno as OperationOrdreFabrication, 
'' as PositionMatiere, 
donof.t_orno as OrdreFabrication, 
left(opof.t_item, 9) as Projet, 
substring(opof.t_item, 10, len(opof.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
donof.t_trdt as DateTransaction, 
'' as ProjetArticleTransaction, 
'' as ArticleTransaction, 
'' as DescriptionArticleTransaction, 
'' as Quantite, 
'' as PrixRevientReel, 
donof.t_emno as Employe, 
emp.t_nama as NomEmploye, 
donof.t_hrea as NombreHeures 
from tbptmm120500 donof --Données d'Ordres de Fabrication
left outer join ttisfc010500 opof on opof.t_pdno = donof.t_orno and opof.t_opno = donof.t_opno --Opérations des Ordres de Fabrication
left outer join ttcibd001500 art on art.t_item = opof.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupes Articles
left outer join ttccom001500 emp on emp.t_emno = donof.t_emno --Employés
where left(donof.t_orno,2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par l'OF
and donof.t_tano = 'LVT203' --On ne prend que les tâches LVT203 (commune à toutes les sociétés)
and donof.t_trdt between @date_f and @date_t --Bornage sur la Date de Transaction
and donof.t_orno between @ofab_f and @ofab_t --Bornage sur le numéro d'OF
)