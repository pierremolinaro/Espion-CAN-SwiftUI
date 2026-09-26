//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI

//--------------------------------------------------------------------------------------------------

func ajouterFiltresTrains (_ inFilterSetArrayBinding : Binding <[FilterSet]>) {
  var extendedFilters : [ExtendedFilterDefinition] = []
  _ = extendedFilters.append (base: 0x0100_0000, mask: 0xFF_FFFF, name: "cumul intégral")
  _ = extendedFilters.append (base: 0x1800_0000, mask: 0x00FF, name: "valeur capteur")
  _ = extendedFilters.append (base: 0x1EDF_0000, mask: 0xFFFF, name: "requête de version")
  _ = extendedFilters.append (base: 0x1E5F_0000, mask: 0xFFFF, name: "réponse de version")
  _ = extendedFilters.append (base: 0x1EFF_0000, mask: 0xFFFF, name: "requête de flashage")
  _ = extendedFilters.append (base: 0x1E7F_0000, mask: 0xFFFF, name: "réponse de flashage")
  _ = extendedFilters.append (base: 0x1EBF_0000, mask: 0xFFFF, name: "requête de lecture")
  _ = extendedFilters.append (base: 0x1E3F_0000, mask: 0xFFFF, name: "réponse de lecture")
  _ = extendedFilters.append (base: 0x1E9F_0000, mask: 0xFFFF, name: "requête d'écriture")
  _ = extendedFilters.append (base: 0x1E1F_0000, mask: 0xFFFF, name: "réponse d'écriture")
  _ = extendedFilters.append (base: 0x1EEF_0000, mask: 0xFFFF, name: "requête de transfert")
  _ = extendedFilters.append (base: 0x1E6F_0000, mask: 0xFFFF, name: "réponse de transfert")
  _ = extendedFilters.append (base: 0x1CFF_FFFF, mask: 0, name: "réponse lecture source en EEPROM")
  _ = extendedFilters.append (base: 0x1CFF_FFFE, mask: 0, name: "signalement TCO")
  _ = extendedFilters.append (base: 0x1CFF_FFFD, mask: 0, name: "signalement motrice sur tablette")
  _ = extendedFilters.append (base: 0x1CFF_FFFC, mask: 0, name: "nom motrice")
  _ = extendedFilters.append (base: 0x1CEF_FFE0, mask: 7, name: "demande d'envoi des noms de motrice")
  _ = extendedFilters.append (base: 0x1CEF_FFE8, mask: 7, name: "demande d'accès paramètres motrice en EEPROM")
  _ = extendedFilters.append (base: 0x1CEF_FFFC, mask: 0, name: "démarrage / arrêt général des motrices")
  _ = extendedFilters.append (base: 0x1CEF_FFF0, mask: 7, name: "souhait TCO")

  var standardFilters : [StandardFilterDefinition] = []
  _ = standardFilters.append (base: 0, mask: 0, name: "arrêt Urgence")
  _ = standardFilters.append (base: 1, mask: 0, name: "reprise")
  _ = standardFilters.append (base: 2, mask: 0, name: "suppression incident")
  _ = standardFilters.append (base: 0x080, mask: 0x3F, name: "évènement alim")
  _ = standardFilters.append (base: 0x0D1, mask: 0, name: "paramètres sources traction")
  _ = standardFilters.append (base: 0x100, mask: 7, name: "position aiguilles")
  _ = standardFilters.append (base: 0x108, mask: 0, name: "commande aiguilles")
  _ = standardFilters.append (base: 0x109, mask: 0, name: "demande position aiguilles")
  _ = standardFilters.append (base: 0x10A, mask: 0, name: "commande dételeurs")
  _ = standardFilters.append (base: 0x10B, mask: 0, name: "commande tout-ou-rien")
  _ = standardFilters.append (base: 0x10C, mask: 0, name: "notification affectation convoi à alim")
  _ = standardFilters.append (base: 0x10D, mask: 0, name: "notification signaux de voie")
  _ = standardFilters.append (base: 0x110, mask: 7, name: "souhait aiguilles")
  _ = standardFilters.append (base: 0x12F, mask: 0, name: "état aiguilles par Caniche")
  _ = standardFilters.append (base: 0x340, mask: 7, name: "évènement du TCO")
  _ = standardFilters.append (base: 0x348, mask: 7, name: "souhait arrêt sur canton")
  _ = standardFilters.append (base: 0x740, mask: 15, name: "acquittement effacement secteur Flash SPI carte son")
  _ = standardFilters.append (base: 0x750, mask: 15, name: "acquittement écriture secteur Flash SPI carte son")
  _ = standardFilters.append (base: 0x760, mask: 15, name: "écriture page Flash SPI carte son")
  _ = standardFilters.append (base: 0x770, mask: 0, name: "jouer un son")
  _ = standardFilters.append (base: 0x771, mask: 0, name: "notification occupation alimentation")
  _ = standardFilters.append (base: 0x772, mask: 0, name: "commande effacement secteur Flash SPI carte son")
  _ = standardFilters.append (base: 0x773, mask: 0, name: "commande signaux de voie Philippe")
  _ = standardFilters.append (base: 0x774, mask: 0, name: "notification état arrêt sur canton")
  _ = standardFilters.append (base: 0x775, mask: 0, name: "commande signaux de voie Pierre")
  _ = standardFilters.append (base: 0x776, mask: 0, name: "présence Caniche")
  _ = standardFilters.append (base: 0x777, mask: 0, name: "commande éclairage Philippe")
  _ = standardFilters.append (base: 0x780, mask: 0, name: "date courante")
  _ = standardFilters.append (base: 0x781, mask: 0, name: "commande réglage général son")
  _ = standardFilters.append (base: 0x782, mask: 0, name: "commande de service")
  _ = standardFilters.append (base: 0x783, mask: 0, name: "trame périodique")
  _ = standardFilters.append (base: 0x786, mask: 0, name: "notification jour/nuit")
  _ = standardFilters.append (base: 0x787, mask: 0, name: "commande passage à niveau Philippe")

  inFilterSetArrayBinding.wrappedValue.append (
    name: "Train",
    débitBusAlimentations: .bps800k,
    débitBusAccessoires: .bps125k,
    standardFilters: standardFilters,
    extendedFilters: extendedFilters
  )
}

//--------------------------------------------------------------------------------------------------
