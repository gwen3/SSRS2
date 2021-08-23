-----------------------------------------
-- ACH09 - Suivi Contrats Achats
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select
 cont.t_cono as Contrat
,cont.t_otbp as TiersVendeur
,tiers.t_nama as NomTiersVendeur
,cont.t_cdes as DescriptionContrat
,cont.t_cdat as DateContrat
,cont.t_sdat as DateApplicationContrat
,cont.t_edat as DateExpirationContrat
,dbo.convertenum('tc','B61C','a9','bull','icap',cont.t_icap,'4') as StatutContrat
,dbo.convertenum('tc','B61C','a9','bull','icyp',cont.t_icyp,'4') as TypeContrat
,ligcont.t_pono as PosLigneCont
,left(ligcont.t_item, 9) as ProjetArticle
,substring(ligcont.t_item, 10, len(ligcont.t_item)) as Article
,art.t_dsca as DescriptionArticle
,ligcont.t_crit as ArtRefCroisee
,ligcont.t_cdat as DateLigneContrat
,ligcont.t_sdat as DateApplicationLigneContrat
,ligcont.t_edat as DateExpirationLigneContrat
,dbo.convertenum('tc','B61C','a9','bull','icap',ligcont.t_icap,'4') as StatutLigneContrat
--,ligcont.t_ccon as CodeAcheteur
,employe.t_nama as NomAcheteur
,dbo.convertenum('tc','B61C','a9','bull','yesno',ligcont.t_scus,'4') as ProgAchatUtilise
,ligcont.t_qoor as QteConvenue
,ligcont.t_cuqp as UniteAchat
,art.t_cuni as UniteStock
,dbo.convertenum('tc','B61C','a9','bull','yesno',ligcont.t_iqab,'4') as QteObligatoire
,ligcont.t_qimi as QteCdeMini
,ligcont.t_qima as QteCdeMaxi
,ligcont.t_qifi as QteCdeFixe
,ligcont.t_qiap as QteProposee
,ligcont.t_qicl as QteAppelee
,ligcont.t_qiiv as QteFacturee
,ligcont.t_bamt as MtFact
-- % Qté Utilisée
,(case ligcont.t_qoor
	when 0 then 0
	else 
		case 
			when ((ligcont.t_qiiv*100)/ligcont.t_qoor) < 0.09
				then 0
				else ROUND(((ligcont.t_qiiv*100)/ligcont.t_qoor),0,0)
		end
end) as PCUtilisation
-- % Temps Ecoulé
,(case
	when datediff(day,ligcont.t_sdat,ligcont.t_edat) = 0
	then 100
	else 
		case 
			when ((datediff(day,ligcont.t_sdat,getdate())*100)/datediff(day,ligcont.t_sdat,ligcont.t_edat)) < 0.09
				then 0
				else ((datediff(day,ligcont.t_sdat,getdate())*100)/datediff(day,ligcont.t_sdat,ligcont.t_edat))
		end
end) as PCTempsEcoule
--
from ttdpur300500 cont --Entête contrat
inner join ttccom100500 tiers on tiers.t_bpid = cont.t_otbp -- Tiers
inner join ttdpur301500 ligcont on ligcont.t_cono = cont.t_cono --Lignes de contrat
inner join ttcibd001500 art on art.t_item = ligcont.t_item --Articles
left outer join ttccom001500 employe on employe.t_emno = ligcont.t_ccon --Employés (recherche acheteur)
where cont.t_cono between @cono_f and @cono_t
and left(cont.t_cono,2) between @ue_f and @ue_t
and cont.t_icap in (@icap_f)-- Statut du contrat
--and (cont.t_edat is null or cont.t_edat = '01/01/1970' or cont.t_edat >= CONVERT(date,GETDATE())) --Contrat non expiré
and cont.t_otbp in (@otbp)
and ligcont.t_cdat between @cdat_f and @cdat_t
and ligcont.t_edat between @edat_f and @edat_t
--and ligcont.t_icap < '3' -- La ligne ne doit pas être au statut "terminé"
order by cont.t_cono --Contrat
