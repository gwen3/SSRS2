-------------------------------------------------------------------
-- MDM08 - Contrôle OV restés au Statut Génération de Projet
-------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_orno as CommandeClient
,lcde.t_pono as PositionCommandeClient
,lcde.t_ofbp as TiersAcheteur
,tiersa.t_nama as NomTiersAcheteur
,cde.t_cofc as ServiceVente
,cde.t_crep as RepresentantInterne
,emp.t_nama as NomRepresentantInterne
,donpers.t_mail as MailRepresentantInterne
,lcde.t_odat as DateSaisieCommande
,lcde.t_prdt as 'Date MADC Prévue'
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
from ttdsls401500 lcde --Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Lignes de Commande Client
left outer join ttccom100500 tiersa on tiersa.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employé - Représentant Interne
left outer join tbpmdm001500 donpers on donpers.t_emno = cde.t_crep --Employés - Données du Personnel - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
where left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le numéro d'OV
and lcde.t_orno between @ov_f and @ov_t --Bornage sur le numéro d'OV
and lcde.t_clyn = 2 --Bornage sur le champ annulé de la commande qui est à NON
and lcde.t_opol = 1 --Bornage sur le champ rendre spécifique qui doit être à OUI
and lcde.t_ofbp != '100005506' --On exclu le tiers avance client
and lcde.t_odat < dateadd("d", -2, getdate()) --On ne prend que les commandes saisies il y a plus de 2 jours