---------------------------------------------
-- LOG39_Anomalies Expéditions Automatiques
---------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select expe.t_shpm as Expedition
,lexpe.t_pono as LigneExpedition
,dbo.convertenum('wh','B61C','a9','bull','inh.shst',expe.t_shst,'4') as StatutExpedition
,expe.t_ispr as ProcedureMagasin
,dbo.convertenum('tc','B61C','a9','bull','typs',expe.t_sfty,'4') as TypeExpediteur
,expe.t_sfco as Expediteur
,dbo.convertenum('tc','B61C','a9','bull','typs',expe.t_stty,'4') as TypeDestinataire
,expe.t_stco as Destinataire
,dbo.convertenum('wh','B61C','a9','bull','inh.oorg',lexpe.t_worg,'4') as OrigineOrdreMagasin
,lexpe.t_worn as OrdreMagasin
,lexpe.t_wpon as LigneOrdreMagasin
,left(lexpe.t_item, 9) as Projet
,substring(lexpe.t_item, 10, len(lexpe.t_item)) as Article
,art.t_dsca as DescriptionArticle
,lexpe.t_qpic as QuantiteReserveeOrdre
,lexpe.t_cwar as MagasinExpedition
,mag.t_cdf_resp as Responsable
,emp.t_nama as NomResponsable
,donemp.t_mail as MailResponsable
from twhinh430500 expe --Expeditions
inner join twhinh431500 lexpe on lexpe.t_shpm = expe.t_shpm --Lignes d'Expéditions
left outer join ttcmcs003500 mag on mag.t_cwar = lexpe.t_cwar --Magasins
left outer join ttccom001500 emp on emp.t_emno = mag.t_cdf_resp --Employé - Responsable
left outer join tbpmdm001500 donemp on donemp.t_emno = mag.t_cdf_resp --Données du personnel - Responsable
inner join ttcibd001500 art on art.t_item = lexpe.t_item --Articles
where 
lexpe.t_shst = 1 --Statut Ouvert de la ligne
and expe.t_ispr in ('401', '403', '405')