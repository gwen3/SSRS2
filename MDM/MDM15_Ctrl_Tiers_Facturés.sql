-----------------------------------------
-- MDM15 Ctrl tiers facturés
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
tiersf.t_itbp as Tiers_Facture
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,tiersf.t_crdt as Date_Creation
,tiersf.t_user as Cree_Par
,util.t_name as Nom_Createur
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.itst',tiersf.t_itst,'4') as Statut_Tiers_Fact
,tiersf.t_cidm as Mode_Env_Fact
,isnull(modenv.t_dsca,'') as Lib_Mode_Envoi_Fact
--
--Recherche Informations d'un contact "Tiers facturé général"
-- Code du contact
,(case
	when (exists (select contacttiers.t_ccnt as Contact_Tiers
					from ttccom145500 contacttiers 
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
	then	(select contacttiers.t_ccnt
					from ttccom145500 contacttiers 
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1')
		
	else ''
end) as Contact_Tiers
-- Nom du contact
,(case
	when (exists (select contacts.t_fuln 
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
	then	(select contacts.t_fuln
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1')
		
	else ''
end) as Nom_Contact
--
-- Mail du contact
,(case
	when (exists (select contacts.t_info 
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
	then	(select contacts.t_info
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1')
		
	else ''
end) as  Contact_Email
--
-- Recherche des Pièces Jointes pour le tiers (jusqu'à 9) et de la taille des PJ
--
,(case
	when (exists (select count(*)				
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')))
		then (select count(*)				
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%'))
		else '0'
	end
) as Nbr_PJ -- Nbr de pièces jointes
--
,(case
	when  @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 1))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 1)
		else ''
	end
) as Piece_Jointe_1
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 1))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 1)
		else ''
	end
) as Taille_pj_1
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 2))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 2)
		else ''
	end
) as Piece_Jointe_2
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 2))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 2)
		else ''
	end
) as Taille_pj_2
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 3))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 3)
		else ''
	end
) as Piece_Jointe_3
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 3))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 3)
		else ''
	end
) as Taille_pj_3
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 4))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 4)
		else ''
	end
) as Piece_Jointe_4
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 4))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 4)
		else ''
	end
) as Taille_pj_4
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 5))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 5)
		else ''
	end
) as Piece_Jointe_5
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 5))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 5)
		else ''
	end
) as Taille_pj_5
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 6))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 6)
		else ''
	end
) as Piece_Jointe_6
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 6))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 6)
		else ''
	end
) as Taille_pj_6
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 7))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 7)
		else ''
	end
) as Piece_Jointe_7
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 7))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 7)
		else ''
	end
) as Taille_pj_7
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 8))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 8)
		else ''
	end
) as Piece_Jointe_8
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 8))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 8)
		else ''
	end
) as Taille_pj_8
--
--
,(case
	when @repj_f = '1' and (exists (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 9))
		then (select pj.t_flna
				from 
					(select row_number() over (order by verfic.t_flid) as rn, nomfic.t_flna					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 9)
		else ''
	end
) as Piece_Jointe_9
--
,(case
	when  @repj_f = '1' and @rtpj_f = '1' and (exists (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 9))
		then (select pj.t_sizr
				from 
					(select row_number() over (order by verfic.t_flid) as rn, verficr.t_sizr					
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc440500 verficr on verficr.t_flid = verfic.t_flid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')) pj
				where rn = 9)
		else ''
	end
) as Taille_pj_9
--
--
--
from ttccom112500 tiersf -- Tiers facturé
inner join ttccom100500 tiers on tiers.t_bpid = tiersf.t_itbp --Tiers 
inner join tttaad200000 util on util.t_user = tiersf.t_user --Utilisateurs
left outer join ttcmcs056500 modenv on modenv.t_cidm = tiersf.t_cidm --Mode Envoi Facture
where
tiersf.t_crdt between @crdt_f and @crdt_t
and tiers.t_bprl in ('2','4') -- Tiers Client ou Client et Fournisseur
and tiers.t_prst in (@prst_f) -- Statut Tiers
-- Mode d'envoi de facture
and tiersf.t_cidm in (@cidm)
--
-- Contacts tiers facturé général avec/sans mail
and (('1' in (@info_f) and 
		(case
			when (exists (select contacts.t_info 
							from ttccom145500 contacttiers 
									left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
							where contacttiers.t_bpid = tiersf.t_itbp
								and contacttiers.t_cmsk_3 = '1'
								and contacttiers.t_ctpr_3 = '1'))
			then	(select contacts.t_info
							from ttccom145500 contacttiers 
									left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
							where contacttiers.t_bpid = tiersf.t_itbp
								and contacttiers.t_cmsk_3 = '1'
								and contacttiers.t_ctpr_3 = '1')
		
			else ''
		end) != '')
		or ('2' in (@info_f) and 
		(case
			when (exists (select contacts.t_info 
							from ttccom145500 contacttiers 
									left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
							where contacttiers.t_bpid = tiersf.t_itbp
								and contacttiers.t_cmsk_3 = '1'
								and contacttiers.t_ctpr_3 = '1'))
			then	(select contacts.t_info
							from ttccom145500 contacttiers 
									left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
							where contacttiers.t_bpid = tiersf.t_itbp
								and contacttiers.t_cmsk_3 = '1'
								and contacttiers.t_ctpr_3 = '1')
		
			else ''
		end) = '')
-- Tiers avec/sans PJ
and (
	( '1' in (@tfpj_f) and 
		(case
		when (exists (select count(*)				
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')))
		then (select count(*)				
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%'))
		else '0'
		end) > 0) 
		or ('2' in (@tfpj_f) and
		(case
		when (exists (select count(*)				
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%')))
		then (select count(*)				
					from tdmcom010500 lienobj
					left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
					inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
					inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
					where t_trtp like 'BUSINESS PARTNER' and t_trid like concat('%',tiersf.t_itbp,'%'))
		else '0'
	end) = 0)))
order by 1