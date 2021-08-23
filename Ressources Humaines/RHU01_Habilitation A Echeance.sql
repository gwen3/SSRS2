------------------------------------
-- RHU01 - Habilitation A Echeance
------------------------------------

select empl.t_emno as CodeEmploye, 
empl.t_nama as NomEmploye, 
cert.t_cert as Certificat, 
cert.t_dscb as Description, 
cert.t_numb as Numero, 
cert.t_ecdt as DateApplication, 
cert.t_xcdt as DateExpiration, 
cdef.t_dsca as DescriptionCertificat 
from ttccom001500 empl --Employés
left outer join tbpmdm001500 bp on bp.t_emno = empl.t_emno --Données Employés - Données du Personnel
left outer join tbpmdm090500 cert on cert.t_emno = empl.t_emno --Certificats d'Employés
left outer join tbpmdm085500 cdef on cdef.t_cert = cert.t_cert --Certificats
where empl.t_emno between @emno_f and @emno_t --Bornage sur l'Employé
and bp.t_sdte <= getutcdate() --Bornage sur la Date d'Embauche qui doit être Inférieure à la Date du Jour
and (bp.t_edte >= getutcdate() or bp.t_edte = '01-01-1753 00:00:00.000') --Bornage sur la Date de Départ qui doit être Supérieure à la Date du Jour ou Vide
and cert.t_xcdt between @xcdt_utc_f and @xcdt_utc_t --Bornage sur la Date d'Expiration du Certificat
and left(empl.t_emno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'employé
order by empl.t_emno