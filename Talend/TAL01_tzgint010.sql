------------------------------------------------------------
-- Requête pour extraction des enregistrements RECPT_CHASSIS 
------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select enr.t_enrg as Enregistrement
,enr.t_code as Code_Interface
,enr.t_seqn as Sequence
,enr.t_cle1 as Cle1
,enr.t_cle2 as Cle2
,enr.t_cle3 as Cle3
,enr.t_cle4 as Cle4
,enr.t_refe as Reference
,enr.t_dtin as Date_Entree
,enr.t_dttr as Date_Traitement
,dbo.convertenum('zg','B61C','a9','bull','int.status',enr.t_stat,'4') as Statut
--
-- Recherche des Arguments dans la table arguments par enregistrement
--
-- (1) Utilisateur
,isnull((select arg.t_vale from tzgint011500 arg where arg.t_enrg = enr.t_enrg and arg.t_pono = '1'),'') as Utilisateur
-- (2) Article
,isnull((select arg.t_vale from tzgint011500 arg where arg.t_enrg = enr.t_enrg and arg.t_pono = '2'),'') as Article
-- (3) Magasin
,isnull((select arg.t_vale from tzgint011500 arg where arg.t_enrg = enr.t_enrg and arg.t_pono = '3'),'') as Magasin
-- (4) Motif
,isnull((select arg.t_vale from tzgint011500 arg where arg.t_enrg = enr.t_enrg and arg.t_pono = '4'),'') as Motif
-- (5) N° de Serie
,isnull((select arg.t_vale from tzgint011500 arg where arg.t_enrg = enr.t_enrg and arg.t_pono = '5'),'') as NumSerie
--
,erreur.t_merr as Message_Erreur
,isnull(dpers.t_mail,'') as Email
from tzgint010500 enr -- Enregistrements
inner join tzgint012500 erreur on erreur.t_enrg = enr.t_enrg and erreur.t_nerr = '1' -- Message d'erreur (uniquement le premier)
left outer join ttccom001500 emp on emp.t_loco = (select arg.t_vale from tzgint011500 arg where arg.t_enrg = enr.t_enrg and arg.t_pono = '1')
left outer join tbpmdm001500 dpers on dpers.t_emno = emp.t_emno
where t_code = 'RECPT_CHASSIS'
and t_stat = '15'