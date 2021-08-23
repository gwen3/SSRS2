-------------------------------------------------------
-- FIN05 - CA Facturé et à Facturer - Appel de la vue
-------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @ue_f nvarchar(2) = 'LV'
declare @ue_t nvarchar(2) = 'LV'
declare @dtefac_f date = DATEADD(DD, -20, CAST(CURRENT_TIMESTAMP AS DATE));
declare @dtefac_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @dtecde_f date = DATEADD(DD, -20, CAST(CURRENT_TIMESTAMP AS DATE));
declare @dtecde_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @ta_f nvarchar(9) = ' '
declare @ta_t nvarchar(9) = 'ZZZZZZZZZ'
declare @ri_f nvarchar(9) = ' '
declare @ri_t nvarchar(9) = 'ZZZZZZZZZ'
declare @re_f nvarchar(9) = ' '
declare @re_t nvarchar(9) = 'ZZZZZZZZZ'
declare @citg nvarchar(9) = 'BAT001'
declare @cofc nvarchar(9) = 'LVV001'
declare @corg nvarchar(9) = ' '
declare @zon nvarchar(9) = 'FRA'
declare @cs int = 13
*/
select Source
,CodeSource
,DateFacture
,SemaineDateFacture
,MoisDateFacture
,AnneeDateFacture
,AnneeMoisDateFacture
,AnneeSemaineDateFacture
,TypeEcritureFinanciere
,NumeroFacture
,Service
,RepresentantInterne
,NomRepresentantInterne
,DateCommande
,SemaineDateCommande
,MoisDateCommande
,AnneeDateCommande
,AnneeMoisDateCommande
,AnneeSemaineDateCommande
,CommandeClient
,Position
,Sequence
,TypeCommandeClient
,DescriptionTypeCommandeClient
,Projet
,Article
,DescriptionArticle
,CodeTypeArticle
,TypeArticle
,NumeroSerie
,GroupeArticle
,DescriptionGroupeArticle
,Activite
,LibelleActivite
,GroupeStatistiqueVente
,ClasseProduit
,TiersAcheteur
,NomTiersAcheteur
,CommandeDuClient
,QuantiteCommandee
,QuantiteALivrer
,QuantiteLivreeNonFacturee
,QuantiteLivree
,DateLivraisonPlanifiee
,DateMADCPrevue
,SemaineDateMADCPrevue
,MoisDateMADCPrevue
,AnneeDateMADCPrevue
,DateLivraisonReelle
,RepresentantExterne
,NomRepresentantExterne
,AdresseCommande
,NomVille
,CodePostalCommande
,Departement
,Zone
,DescriptionCanauxDistribution
,NomContremarque
,ClientIndirect
,NomClientIndirect
,ClientFinal
,NomClientFinal
,MontantFacture
,Montant
,MontantAFacturer
,DeviseCommande
,UE
,Site
,AdresseLivree
,NomVilleLivree
,CodePostalLivre
,DepartementLivre
,CodeOrigineOrdre
,OrigineOrdre
,CodeBloquee
,Bloquee
,CodeSignal
,TiersFacture
,NomTiersFacture
,GroupeFinancierTiersFacture
,Motif
,DescriptionMotif
,StTransfo
from FIN05_VIEW
where 
--Commandes Clients
(((CodeSource = '1' or CodeSource = '2')
and (((@choixdate = 1 or @choixdate = 2 or @choixdate = 3) and DateCommande between @dtecde_f and @dtecde_t) or (@choixdate = 4)) --Bornage sur la Date de Commande
and GroupeArticle in (@citg) --Bornage sur le Groupe Article
and CodeOrigineOrdre in (@corg) -- Origine de l'ordre
and Service in (@cofc) -- Services
and RepresentantInterne between @ri_f and @ri_t --Représentant interne
and RepresentantExterne between @re_f and @re_t --Représentant Externe
and Zone in (@zon) --Bornage sur la Zone
)
--Programme de vente
or ((CodeSource = '3' or CodeSource = '4')
and GroupeArticle in (@citg) --Bornage sur le Groupe Article
and (((@choixdate = 1 or @choixdate = 2 or @choixdate = 3) and DateCommande between @dtecde_f and @dtecde_t) or (@choixdate = 4)) --Bornage sur la Date de Commande
)
--Facturé
or ((CodeSource = '5')
and ((@choixdate = 1 and DateCommande between @dtecde_f and @dtecde_t) or (@choixdate = 2 and DateFacture between @dtefac_f and @dtefac_t) or ((@choixdate = 3 or @choixdate = 4) and ((DateFacture between @dtefac_f and @dtefac_t) or (DateCommande between @dtecde_f and @dtecde_t))))
and GroupeArticle in (@citg) --Bornage sur le Groupe Article
and CodeOrigineOrdre in (@corg) -- Origine de l'ordre
and Service in (@cofc) -- Services
and RepresentantInterne between @ri_f and @ri_t --Représentant interne
and RepresentantExterne between @re_f and @re_t --Représentant Externe
and Zone in (@zon) --Bornage sur la Zone
)
--Programme de vente Facturé
or ((CodeSource = '6')
and DateFacture between @dtefac_f and @dtefac_t --Bornage sur la date de facture
)
--Autres
or ((CodeSource = '6' or CodeSource = '7' or CodeSource = '8' or CodeSource = '9' or CodeSource = '10' or CodeSource = '11' or CodeSource = '12')
and DateFacture between @dtefac_f and @dtefac_t --Bornage sur la date de facture
and Service in (@cofc) -- Services
and RepresentantInterne between @ri_f and @ri_t --Représentant interne
and RepresentantExterne between @re_f and @re_t --Représentant Externe
and Zone in (@zon) --Bornage sur la Zone
)
--Factures Manuelles
or ((CodeSource = '13')
and DateFacture between @dtefac_f and @dtefac_t --Bornage sur la date de facture
and Service in (@cofc) -- Services
)
--Commandes Clients Annulées
or ((CodeSource = '14')
and DateCommande between @dtecde_f and @dtecde_t --Bornage sur la Date de Commande
and GroupeArticle in (@citg) --Bornage sur le Groupe Article
and CodeOrigineOrdre in (@corg) -- Origine de l'ordre
and Service in (@cofc) -- Services
and RepresentantInterne between @ri_f and @ri_t --Représentant interne
and RepresentantExterne between @re_f and @re_t --Représentant Externe
and Zone in (@zon) --Bornage sur la Zone
)
)
and UE between @ue_f and @ue_t --Bornage sur l'UE
and TiersAcheteur between @ta_f and @ta_t --Bornage sur le Tiers Acheteur
and CodeSource in (@cs) --On borne sur le Code Source
order by CodeSource