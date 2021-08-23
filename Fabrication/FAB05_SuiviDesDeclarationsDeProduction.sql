-------------------------------------------------
-- FAB05 - Suivi des Déclarations de Production
-------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select trans.t_trdt as DateTransaction, 
trans.t_cwar as Magasin, 
trans.t_loca as Emplacement, 
left(trans.t_item, 9) as Projet, 
substring(trans.t_item, 10, len(trans.t_item)) as Article, 
art.t_dsca as Designation, 
trans.t_serl as NumeroSerie, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
trans.t_orno as Ordre, 
trans.t_pono as Position, 
trans.t_qstk as QuantitéRecue, 
art.t_cuni as UniteStock, 
trans.t_koor as CodeTypeOrdre, 
dbo.convertenum('tc','B61C','a9','bull','koor',trans.t_koor,'4') as TypeOrdre, 
trans.t_kost as CodeTypeTransaction, 
dbo.convertenum('tc','B61C','a9','bull','kost',trans.t_kost,'4') as TypeTransaction, 
trans.t_logn as CodeEmploye, 
emp.t_name as NomEmploye 
from twhinr100500 trans --Transactions de Stock par point de Stockage
inner join ttcibd001500 art on art.t_item = trans.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
inner join ttgbrg835500 emp on emp.t_user = trans.t_logn --Employés
where trans.t_koor between @koor_f and @koor_t --Bornage sur le Type d'Ordre
and trans.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre
and trans.t_trdt between @trdt_f and dateadd(day, 1, @trdt_t) --Bornage sur la Date de Transaction
and left(trans.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre