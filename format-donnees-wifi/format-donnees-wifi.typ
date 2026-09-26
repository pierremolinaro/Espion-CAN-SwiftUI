//-----------------------------------------------------------------------------
// Les paramètres du texte
//-----------------------------------------------------------------------------

//--- La police de caractères par défaut du document
// et la langue pour faire des césures françaises
#set text(font: "Titillium", size: 12pt, lang: "fr")

//--- Justification des paragraphes
#set par(justify: true)

//--- Indentation de la première ligne des paragraphes
// Si le paramètre « all » est à false, le 1er paragraphe d'une section
// n'est pas indenté
//#set par(first-line-indent: (amount: 1em, all: true))

//--- Polices des listings
#show raw: set text(font: "Menlo", 8pt)

//-----------------------------------------------------------------------------
// La numérotation des chapitres et sections
//-----------------------------------------------------------------------------

//--- La numérotation des pages
// #set page(numbering: "1")

//--- La numérotation des chapitres, sections, sous-sections
#set heading(numbering: "1.1.1")

//-----------------------------------------------------------------------------
// EN-TÊTE DE PAGE
//-----------------------------------------------------------------------------

#set page(
  header-ascent: 5mm,
  header: rect(
    width: 100%,
    stroke: none
  )[
    Format des échanges WiFi #h(1fr) 3 mai 2026 \
    #line(length: 100%, stroke: 0.25mm)
  ]
)

//-----------------------------------------------------------------------------
// PIED DE PAGE
//-----------------------------------------------------------------------------

#set page(
  footer-descent: 5mm,
  footer: rect(
    width: 100%,
    stroke: none
  )[
    #line(length: 100%, stroke: 0.25mm)
    #h(1fr) Page #context counter(page).display("1/1", both: true) #h(1fr)
  ]
)

//-----------------------------------------------------------------------------
// La page de titre
//-----------------------------------------------------------------------------

#align(center, text(22pt, weight: "bold")[Format des échanges WiFi])

//-----------------------------------------------------------------------------

= Généralités
\
Le format est conçu de façon à pouvoir transmettre des séquences de _commandes_, à chacune d'elle sont associés zéro, un ou plusieurs _paramètres_ qui peuvent être des entiers non signés, des entiers signés et des chaînes de caractères Unicode.

C'est un format _binaire_ de type _autosynchronisant_, qui contient des séquences de _commandes_ précédées par des _paramètres_. Les paramètres sont placés avant la commande à laquelle ils sont associés (notation _polonaise inverse_).

Le format est une chaîne d'octets. Chaque octet transmis obéit à ce format :
  - $0x x x "_" x x x x$ : extension de valeur ;
  - $1000 "_" x x x x$ : entier positif ou nul ;
  - $1001 "_" x x x x$ : entier négatif ;
  - $1010 "_" 0000$ : chaîne de caractères Unicode ;
  - $1010 "_" 0001$ : message de vie de la liaison, envoyé toutes les secondes ;
  - $101x "_" x x x x$, avec $x != 0$ et $x != 1$ : réservés à des extensions futures ;
  - $11 x x "_" x x x x$ : commande.

= Les commandes
\
Il y a 64 commandes possibles codées $11 c_5 c_4 c_3 c_2 c_1 c_0$. La signification d'une commande est différente selon le sens (Mac -> Pico) ou (Pico -> Mac).

= Les entiers posififs ou nuls
\
Un entier non signé est défini par un octet $10 0 0 "_" b_3 b_2 b_1 b_0$ qui contient les quatre bits de poids faible de la valeur à coder. Si cette valeur est supérieure à 15, une ou plusieurs _extensions de valeur_ sont ajoutées. Chacune d'elles contient sept bits qui, décalés, contiennent les bits supplémentaires. Ce format favorise le codage compacte des faibles valeurs.

Une valeur sur 11 bits est codée sur deux octets :

$ 1000 space b_3 b_2 b_1 b_0 space space 0 b_10 b_9 b_8 b_7 space b_6 b_5 b_4 $

Une valeur sur 18 bits est codée sur trois octets :

$ 1000 space b_3 b_2 b_1 b_0 space space 0 b_10 b_9 b_8 space b_7 b_6 b_5 b_4 space space 0 b_17 b_16 b_15 space b_14 b_13 b_12 b_11 $

Une valeur sur 25 bits est codée sur quatre octets :

$ 1000 space b_3 b_2 b_1 b_0 space space 0 b_10 b_9 b_8 space b_7 b_6 b_5 b_4 $
                                                                                
$ 0 b_17 b_16 b_15 space b_14 b_13 b_12 b_11 space space 0  b_24 b_23 b_22 space b_21 b_20 b_19 b_18 $

Une valeur sur 32 bits est codée sur cinq octets :

$ 1000 space b_3 b_2 b_1 b_0 space space 0 b_10 b_9 b_8 space b_7 b_6 b_5 b_4 $
                                                                                
$ 0 b_17 b_16 b_15 space b_14 b_13 b_12 b_11 space space 0  b_24 b_23 b_22 space b_21 b_20 b_19 b_18 $

$ 0  b_31 b_30 b_29 space b_28 b_27 b_26 b_25 $


L'encodage des valeurs entières peut être réalisé par la fonction C++ suivante :
```Cpp
void encodeU32 (std::vector <uint8_t> & ioBuffer,
                const uint32_t inValue) {
  ioBuffer.push_back (uint8_t ((inValue & 0x0F) | 0x80)) ;
  uint32_t v = inValue >> 4 ;
  while (v > 0) {
    ioBuffer.push_back (uint8_t (v & 0x7F)) ;
    v >>= 7 ;
  }
}
```

Voici quelques exemples d'encodage :
#text(size: 11pt)[
#table(
  stroke: none,
  columns: (auto, auto, auto),
  inset: 5pt,
  align: (right, right, left),
  table.header(
    [*Décimal*], [*Hex*], [*Code*],
  ),
  $0$, $0$, $80$,
  $100$, $64$, $84 space 06$,
  $1023$, $"3FF"$, $"8F" "3F"$,
  $60000000$, $"393_8700"$, $"80" space "70" space "70" space "64" space "01"$,
  $536870911$, $"1FFF_FFFF"$, $"8F" "7F" "7F" "7F" "0F"$,
  $4294967295$, $"FFFF_FFFF"$, $"8F" "7F" "7F" "7F" "7F"$,
  $18446744073709551615$, $"FFFF_FFFF_FFFF_FFFF"$, $"8F" "7F" "7F" "7F" "7F" "7F" "7F" "7F" "7F" "0F"$,
)
]

= Les entiers négatifs
\
C'est leur complément à 1 qui est codé comme un entier positif ou nul, l'octet initial étant $1001 "_" x x x x$.

Ansi, pour la valeur -1 : le complément à 1 est 0, son codage est $1001 space 0000$.

L'encodage des valeurs signées peut être réalisé par la fonction C++ suivante :
```Cpp
void encodeS32 (std::vector <uint8_t> & ioBuffer,
                const int32_t inValue) {
  if (inValue >= 0) {
    encodeU32 (ioBuffer, uint32_t (inValue)) ;
  }else{
    uint32_t v = ~ uint32_t (inValue) ;
    ioBuffer.push_back (uint8_t ((v & 0x0F) | 0x90)) ;
    v >>= 4 ;
    while (v > 0) {
      ioBuffer.push_back (uint8_t (v & 0x7F)) ;
      v >>= 7 ;
    }
  }
}
```


= Les chaînes de caractères Unicode
\
Le codage d'une chaîne de caractères commence par l'octet $1010 "_" 0000$. Tel que, ceci code la chaîne vide. Les octets _extensions de valeur_ qui suivent fournissent les caractères de la chaîne.

Un point de code Unicode est une valeur sur 21 bits que l'on note
 $ u_20 space  u_19 u_18 u_17 u_16 space space  u_15 u_14 u_13 u_12  space u_11 u_10 u_9 u_8 space space u_7 u_6 u_5 u_4 space u_3 u_2 u_1 u_0 $

== Codage des caractères ASCII
\
Un caractère ASCII est codé directement par $0 u_6 u_5 u_4 space u_3 u_2 u_1 u_0$, avec une exception : les valeurs entre $0 x 10$ et $0 x 1F$ forment le premier octet du codage des caractères Unicode autres que ASCII et de ceux compris entre $0 x 10$ et $0 x 1F$.

== Codage des points de code jusqu'à 10 bits
\
$ 0001 space u_3 u_2 u_1 u_0 $ 
$ 01u_9 u_8 space u_7 u_6 u_5 u_4 $ 

Ce codage est aussi utilisé pour les caractères entre $0 x 10$ et $0 x 1F$.
  - $0 x 10$ est codé $0001 space 0000 space space 0100 space 0001$ ;
  - $0 x 1F$ est codé $0001 space 1111 space space 0100 space 0001$.

Il permet aussi de représenter tous les caractères latins accentués :
  - "à", point de code 0xE0, codé par $0001 space 0000 space space 0100 space 1110$ ;
  - "œ", point de code 0x153, codé par $0001 space 0011 space space 0101 space 0101$ ;

== Codage des points de code jusqu'à 16 bits
\
$ 0001 space u_3 u_2 u_1 u_0 $ 
$ 00u_9 u_8 space u_7 u_6 u_5 u_4 $ 
$ 01u_15 u_14 u_13 u_12 space u_11 u_10 $ 



== Codage des points de code jusqu'à 22 bits
\
Soit un bit de plus que nécessaire.

$ 0001 space u_3 u_2 u_1 u_0 $
$ 00u_9 u_8 space u_7 u_6 u_5 u_4 $
$ 00u_15 u_14 space u_13 u_12  u_11 u_10 $ 
$ 01 u_21 u_20 space u_19 u_18 u_17 u_16 $ 

Ensuite, on encode la chaîne de caractères :



== Encodage d'une chaîne de caractères
\
Comme la chaîne est encodée en UTF-8, il faut d'abord extraire les points de code. La fonction suivante fait cette extraction :

```Cpp
uint32_t utf32CharacterForPointer (const uint8_t * inDataString,
                                   size_t & ioIndex,
                                   const size_t inLength,
                                   bool & ioOK) {
  uint32_t result = 0 ;
  uint32_t c = inDataString [ioIndex] ;
  ioIndex += 1 ;
  ioOK = true ;
  if ((c & 0x80) == 0) {
    result = c ;
  }else if ((c & 0xE0) == 0xC0) {
    result = c & 0x1F ;
    result <<= 6 ;
    c = inDataString [ioIndex] ;
    ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
    if (ioOK) {
      ioIndex += 1 ;
      result |= c & 0x3F ;
    }
  }else if ((c & 0xF0) == 0xE0) {
    result = c & 0x0F ;
    result <<= 12 ;
    c = inDataString [ioIndex] ;
    ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
    if (ioOK) {
      ioIndex += 1 ;
      result |= (c & 0x3F) << 6 ;
      c = inDataString [ioIndex] ;
      if (ioOK) {
        ioOK &= ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
        ioIndex += 1 ;
        result |= c & 0x3F ;
      }
    }
  }else if ((c & 0xF8) == 0xF0) {
    result = (c & 0x07) << 18 ;
    c = inDataString [ioIndex] ;
    ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
    if (ioOK) {
      ioIndex += 1 ;
      result |= (c & 0x3F) << 12 ;
      c = inDataString [ioIndex] ;
      ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
      if (ioOK) {
        ioIndex += 1 ;
        result |= (c & 0x3F) << 6 ;
        c = inDataString [ioIndex] ;
        ioOK = ((c & 0xC0) == 0x80) && (ioIndex < inLength) ;
        if (ioOK) {
          ioIndex += 1 ;
          result |= c & 0x3F ;
        }
      }
    }
  }else{
    ioOK = false ;
  }
  if (!ioOK) {
    result = 0x0000FFFD ; // UNICODE_REPLACEMENT_CHARACTER
  }
  return result ;
}
```

Rappel du codage UTF-8 :
#text(size: 11pt)[
#table(
  stroke: none,
  columns: (auto, auto),
  inset: 5pt,
  align: (left, left),
  table.header(
    [*Point de code*], [*UTF-8*],
  ),
  $0 space 0000 space space 0000 space 0000 space space 0 u_6 u_5 u_4 space u_3 u_2 u_1 u_0$, $0 u_6 u_5 u_4 space space u_3 u_2 u_1 u_0$,

  $0 space 0000 space space 0000 space 0 u_10 u_9 u_8 space space u_7 u_6 u_5 u_4 space u_3 u_2 u_1 u_0$, $110u_10 space u_9 u_8 u_7 u_6$,
  [], $10 u_5 u_4 space space u_3 u_2 u_1 u_0$,

  $0 space 0000 space space u_15 u_14 u_13 u_12 space u_11 u_10 u_9 u_8 space space u_7 u_6 u_5 u_4 space u_3 u_2 u_1 u_0$, $1110 space u_15 u_14 u_13 u_12$,
  [], $10 u_11 u_10 space space u_9 u_8 u_7 u_6$,
  [], $10 u_5 u_4 space space u_3 u_2 u_1 u_0$,

  $u_20 space u_19 u_18 u_17 u_16 space space u_15 u_14 u_13 u_12 space u_11 u_10 u_9 u_8 space space u_7 u_6 u_5 u_4 space u_3 u_2 u_1 u_0$, $1111 space space 0 u_20 u_19 u_18$,
  [], $10 u_17 u_16 space space u_15 u_14 u_13 u_12$,
  [], $10 u_11 u_10 space space u_9 u_8 u_7 u_6$,
  [], $10 u_5 u_4 space space u_3 u_2 u_1 u_0$
)
]

Le codage d'une chaîne UTF-8 est réalisé par la fonction :

```Cpp
void encodeStr (std::vector <uint8_t> & ioBuffer,
                const std::string inUTF8String) {
  ioBuffer.push_back (0xA0) ;
  const uint8_t * cString = (const uint8_t *) inUTF8String.c_str () ;
  const size_t utf8ByteCount = strlen ((const char *) cString) ;
  size_t utf8Index = 0 ;
  bool ok = true ;
  while ((utf8Index < utf8ByteCount) && ok) {
    const uint32_t unicodeChar = utf32CharacterForPointer (cString, utf8Index, utf8ByteCount, ok) ;
    std::cout << "    encoded utf32 : 0x" << std::hex << unicodeChar << std::dec << "\n" ;
    if (ok) {
      if ((unicodeChar >= 0x10) && (unicodeChar <= 0x1F)) { // control 0001 xxxx
        ioBuffer.push_back (uint8_t (unicodeChar)) ;
        ioBuffer.push_back (0x41) ;
      }else if (unicodeChar <= 0x7F) { // ASCII
        ioBuffer.push_back (uint8_t (unicodeChar)) ;
      }else if (unicodeChar <= 0x3FF) {
        ioBuffer.push_back (uint8_t (unicodeChar & 0x0F) | 0x10) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 4) | 0x40) ;
      }else if (unicodeChar <= 0xFFFF) {
        ioBuffer.push_back (uint8_t (unicodeChar & 0x0F) | 0x10) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 4) & 0x3F) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 10) | 0x40) ;
      }else{
        ioBuffer.push_back (uint8_t (unicodeChar & 0x0F) | 0x10) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 4) & 0x3F) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 10) & 0x3F) ;
        ioBuffer.push_back (uint8_t (unicodeChar >> 16) | 0x40) ;
      }
    }
  }
}
```


= Données Mac -> Pico

== Commande « acquisition sans trigger »
\
Argument : durée de l'acquisition en secondes \
Code de la commande : 0x01

== Commande « acquisition avec trigger »
\
Premier argument : identificateur, valeur de base \
Deuxième argument : identificateur, masque \
Troisième argument : indicateurs
  - bit 0 : 0 --> le trigger est une trame standard, 1 --> une trame étendue
  - bit 1 : 0 --> réseau _Accessoires_ ignoré pour le trigger, 1 --> pris en compte
  - bit 2 : 0 --> réseau _Alimentations_ ignoré pour le trigger, 1 --> pris en compte
Quatrième argument : durée de l'acquisition en secondes \
Code de la commande : 0x02

== Commande « arrêt immédiat »
\
Pas d'argument \
Code de la commande : 0x3F



== Commande « demande paramètres WiFi »
\
Aucun argument \
Code de la commande : 0x06 \
Le Pico répond en renvoyant les paramètres WiFi dans la commande 0xC6.


== Commande « écriture paramètres WiFi »
\
Premier argument : le nom du réseau local, pour configuration comme _station_ \
Deuxième argument : le mot de passe du réseau local, pour configuration comme _station_ \
Troisième argument : le nom du réseau, pour configuration comme _point d'accès_ \
Quatrième argument : le mot de passe du réseau, pour configuration comme _point d'accès_ \
Cinquième argument : le canal du réseau (entre 1 et 13), pour configuration comme _point d'accès_ \

Code de la commande : 0x07
\
Lorsque le Pico reçoit cette commande, il écrit en EEPROM la valeur des paramètres, qui seront disponibles à partir du prochain démarrage.



= Données Pico -> Mac

== Commande « début d'acquisition »
\
Pas d'argument \
Code de la commande : 0x00

L'occurrence de cette commande marque le début de la liste des trames acquises.


== Commande « trame »
\
Premier argument : date de la réception, en µs, à partir du début de l'acquisition. \
Deuxième argument : descripteur \
  - bits 0 à 3 : nombre d'octets de données ;
  - bit 4 : 0 --> trame _standard_, 1 --> trame _étendue_ ;
  - bit 5 : 0 --> réseau CAN _Accessoires_, 1 --> réseau CAN _Alimentations_ ; 
  - bit 6 : 0 --> trame de données, 1 --> trame de requête.
\
Troisième argument : identificateur.
\
Quatrième argument : (si nombre d'octets de données > 0) et trame de données, les octets de données :
  - bit  0 à  7 : data 0
  - bit  8 à 15 : data 1
  - bit 16 à 23 : data 2
  - bit 24 à 31 : data 3
  - bit 32 à 39 : data 4
  - bit 40 à 47 : data 5
  - bit 48 à 55 : data 6
  - bit 56 à 63 : data 7
\
Code de la commande : 0x01


== Commande « fin d'acquisition »
\
Pas d'argument \
Code de la commande : 0x3F

L'occurrence de cette commande marque la fin de la liste des trames acquises. Recevoir cette commande indique que toutes les trames ont été reçues.


== Commande « réponse demande paramètres WiFi »
\
Premier argument : le nom du réseau local, pour configuration comme _station_ \
Deuxième argument : le mot de passe du réseau local, pour configuration comme _station_ \
Troisième argument : le nom du réseau, pour configuration comme _point d'accès_ \
Quatrième argument : le mot de passe du réseau, pour configuration comme _point d'accès_ \
Cinquième argument : le canal du réseau (entre 1 et 13), pour configuration comme _point d'accès_ \

Code de la commande : 0x06 \

Le Pico envoie cette commande suite à la réception de la commande « demande paramètres WiFi ».
