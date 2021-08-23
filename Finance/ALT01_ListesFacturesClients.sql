------------------------------------
-- ALT01 - Listes Factures Clients
------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select npiece as NumeroFacture, 
date_comptable as DateComptable, 
date_echeance as DateEcheance, 
montant as Montant, 
mtsolde as MontantSolde, 
ref_client as ReferenceClient 
from i_factures 
where numcomptable = @tiers