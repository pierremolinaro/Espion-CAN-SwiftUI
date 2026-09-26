//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 22/05/2026.
//--------------------------------------------------------------------------------------------------

import SwiftUI
import UniformTypeIdentifiers

//--------------------------------------------------------------------------------------------------

struct FilterSetArrayEditor : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @Binding var mFilterSetArray : [FilterSet]
  @Binding var mUsedFilterSetID : FilterSetID
  @Binding var mPresentingFilterManagerDialog : Bool

  @State var mSelectedFilterSetID : FilterSetID? = nil
  @State var mPresentingFilterSetExporterDialog = false
  @State var mPresentingFilterSetImporterDialog = false

  @State var mEditingFilterName = ""

  @State var mPresentingStandardFilterEditor = false
  @State var mCurrentlySelectedStandardFilterID : StandardFilterID? = nil
  @State var mCurrentlyEditedStandardFilterID : StandardFilterID? = nil
  @State var mEditingStandardFilterBaseValue : UInt16 = 0
  @State var mEditingStandardFilterMaskValue : UInt16 = 0

  @State var mPresentingExtendedFilterEditor = false
  @State var mCurrentlySelectedExtendedFilterID : ExtendedFilterID? = nil
  @State var mCurrentlyEditedExtendedFilterID : ExtendedFilterID? = nil
  @State var mEditingExtendedFilterBaseValue : UInt32 = 0
  @State var mEditingExtendedFilterMaskValue : UInt32 = 0

  @AppStorage("presenting.standard.filters") var mPresentingStandardFilters = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (filterSetArray : Binding <[FilterSet]>,
        usedFilterSetID : Binding <FilterSetID>,
        presentingFilterManagerDialog : Binding <Bool>) {
    self._mFilterSetArray = filterSetArray
    self._mUsedFilterSetID = usedFilterSetID
    self._mPresentingFilterManagerDialog = presentingFilterManagerDialog
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder var body : some View {
    VStack (spacing: 10.0) {
      AppIconView (title: "Gestion des paramètres")
      HStack {
        self.leftColumn ()
        Divider ()
        self.rightColumn ()
      }
      HStack {
        Spacer ()
        Button ("Fermer") { self.mPresentingFilterManagerDialog = false }
        .keyboardShortcut (.defaultAction)
        Spacer ()
      }
    }
    .padding ()
    .frame (minHeight: 500, maxHeight: .infinity)
    .fileExporter (
      isPresented: self.$mPresentingFilterSetExporterDialog,
      document: self.exporterJeuDeFiltres (),
      contentType: UTType.filterSetDocument,
      defaultFilename: self.mFilterSetArray.first { $0.id == self.mSelectedFilterSetID }?.name ?? "",
      onCompletion: { result in }
    )
    .sheet (isPresented: self.$mPresentingStandardFilterEditor) {
      self.standardFilterEditor ()
    }
    .sheet (isPresented: self.$mPresentingExtendedFilterEditor) {
      self.extendedFilterEditor ()
    }
    .fileImporter (
      isPresented: self.$mPresentingFilterSetImporterDialog,
      allowedContentTypes: [UTType.filterSetDocument],
      onCompletion: { self.importerJeuDeFiltres (result: $0) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder func leftColumn () -> some View {
    VStack {
      HStack {
        Text ("Jeu de paramètres utilisé")
        Picker ("", selection: self.$mUsedFilterSetID) {
          Text ("Aucun").italic().tag (FilterSetID ())
          ForEach (self.mFilterSetArray) { filter in
            Text (filter.name).tag (filter.id)
          }
        }
      }
      Table (self.mFilterSetArray, selection: self.$mSelectedFilterSetID) {
        TableColumn ("Utilisé") {filterSet in Text ((filterSet.id == self.mUsedFilterSetID) ? "✓" : "") } .width (40)
        TableColumn ("Nom", value: \.name).width (min: 150)
        TableColumn ("Standard") { filterSet in Text ("\(filterSet.standardFilters.count)") }.width (64)
        TableColumn ("Étendus") { filterSet in Text ("\(filterSet.extendedFilters.count)") }.width (50)
      }.frame (minWidth: 400, maxWidth: 400, maxHeight: .infinity)
      HStack {
        Button ("+") {
          self.mFilterSetArray.append (
            name: "??",
            débitBusAlimentations: .bps125k,
            débitBusAccessoires: .bps125k,
            standardFilters: [],
            extendedFilters: []
          )
          self.mSelectedFilterSetID = self.mFilterSetArray.last!.id
        }
        Button ("Ajouter paramètres train") { ajouterFiltresTrains (self.$mFilterSetArray) }
        Button ("-") {
          if self.mUsedFilterSetID == self.mSelectedFilterSetID {
            self.mUsedFilterSetID = FilterSetID ()
          }
          self.mFilterSetArray.removeAll { $0.id == self.mSelectedFilterSetID }
          self.mSelectedFilterSetID = nil
        }
        .disabled (self.mSelectedFilterSetID == nil)
        Spacer ()
        Button ("Duplicate") {
          if let filterSetID = self.mSelectedFilterSetID,
             let filter = self.mFilterSetArray.first (where: { $0.id == filterSetID }) {
            self.mFilterSetArray.append (
              name: filter.name + "-copie",
              débitBusAlimentations: filter.débitBusAlimentations,
              débitBusAccessoires: filter.débitBusAccessoires,
              standardFilters: filter.standardFilters,
              extendedFilters: filter.extendedFilters
            )
          }
        }
        .disabled (self.mSelectedFilterSetID == nil)
      }
      HStack {
        Button ("Exporter…") { self.mPresentingFilterSetExporterDialog = true }
        .disabled (self.mSelectedFilterSetID == nil)
        Spacer ()
        Button ("Importer…") { self.mPresentingFilterSetImporterDialog = true }
      }
      Spacer ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder func rightColumn () -> some View {
    if let filterSetID = self.mSelectedFilterSetID,
       let filterIndex = self.mFilterSetArray.firstIndex (where: { $0.id == filterSetID }) {
      VStack {
        Text ("Jeu de paramètres « \(self.mFilterSetArray [filterIndex].name) »").bold ()
        Spacer ()
        Grid {
          GridRow {
            Text ("Nom")
            TextField ("", text: self.$mFilterSetArray [filterIndex].name)
          }
          GridRow {
            Text ("Débit")
            HStack {
              Text ("Bus Alimentation")
              Picker ("", selection: self.$mFilterSetArray [filterIndex].débitBusAlimentations) {
                ForEach (CanBusSpeed.allCases, id: \.self) {
                  Text ($0.string).tag ($0)
                }
              }.labelsHidden()
              Spacer ()
              Text ("Bus Accessoires")
              Picker ("", selection: self.$mFilterSetArray [filterIndex].débitBusAccessoires) {
                ForEach (CanBusSpeed.allCases, id: \.self) {
                  Text ($0.string).tag ($0)
                }
              }.labelsHidden()
            }
          }
        }
        Picker ("", selection: self.$mPresentingStandardFilters) {
          Text ("Filtres standards").tag (true)
          Text ("Filtres étendus").tag (false)
        }.pickerStyle (.segmented)
        if self.mPresentingStandardFilters {
          HStack {
            Button ("+") {
              self.mCurrentlyEditedStandardFilterID = nil
              self.mPresentingStandardFilterEditor = true
            }
            Button ("-") { self.removeSelectedStandardFilter () }
            .disabled (self.mCurrentlySelectedStandardFilterID == nil)
//                Text ("Filtres standards")
            Spacer ()
          }
          Table (self.mFilterSetArray [filterIndex].standardFilters,
                 selection: self.$mCurrentlySelectedStandardFilterID) {
            TableColumn ("Edit") { filter in
              Button ("", systemImage: "pencil") { self.startStandardFilterEditing (filter) }.labelsHidden()
            }.width (25)
            TableColumn ("Nom", value: \.name).width (min: 125)
            TableColumn ("Base") { filter in Text ("0x\(filter.base.hex4String)") }.width (90)
            TableColumn ("Masque") { filter in Text ("0x\(filter.mask.hex4String)") }.width (90)
         }
        }else{
          HStack {
            Button ("+") { self.mCurrentlyEditedExtendedFilterID = nil ; self.mPresentingExtendedFilterEditor = true }
            Button ("-") { self.removeSelectedExtendedFilter () }
            .disabled (self.mCurrentlySelectedExtendedFilterID == nil)
//                Text ("Filtres étendus")
            Spacer ()
          }
          Table (self.mFilterSetArray [filterIndex].extendedFilters, selection: self.$mCurrentlySelectedExtendedFilterID) {
            TableColumn ("Edit") { filter in
              Button ("", systemImage: "pencil") { self.startExtendedFilterEditing (filter) }
            }.width (25)
            TableColumn ("Nom", value: \.name).width (min: 125)
            TableColumn ("Base") { filter in
              Text ("0x\(filter.base.hex8SepString)")
             }.width (90)
            TableColumn ("Masque") { filter in
              Text ("0x\(filter.mask.hex8SepString)")
             }.width (90)
          }
        }
      }.frame (minWidth: 600, maxHeight: .infinity).controlSize (.small)
    }else{
      Text ("Aucun jeu de paramètres sélectionné").frame (minWidth: 600)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func startExtendedFilterEditing (_ inFilter : ExtendedFilterDefinition) {
    self.mCurrentlySelectedExtendedFilterID = inFilter.id
    self.mCurrentlyEditedExtendedFilterID = inFilter.id
    self.mEditingExtendedFilterBaseValue = inFilter.base
    self.mEditingExtendedFilterMaskValue = inFilter.mask
    self.mEditingFilterName = inFilter.name
    Task { @MainActor in
      self.mPresentingExtendedFilterEditor = true
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func startStandardFilterEditing (_ inFilter : StandardFilterDefinition) {
    self.mCurrentlySelectedStandardFilterID = inFilter.id
    self.mCurrentlyEditedStandardFilterID = inFilter.id
    self.mEditingStandardFilterBaseValue = inFilter.base
    self.mEditingStandardFilterMaskValue = inFilter.mask
    self.mEditingFilterName = inFilter.name
    Task { @MainActor in
      self.mPresentingStandardFilterEditor = true
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func importerJeuDeFiltres (result inResult : Result <URL, any Error>) {
    switch inResult {
    case .success (let url) :
      if url.startAccessingSecurityScopedResource (),
         let data = try? Data (contentsOf: url),
         let str = String (data: data, encoding: .utf8) {
        url.stopAccessingSecurityScopedResource ()
        var components = str.components (separatedBy: "\n")
        var standardFilters = [StandardFilterDefinition] ()
        var extendedFilters = [ExtendedFilterDefinition] ()
        if let lastLine = components.last, lastLine.isEmpty {
          components.removeLast ()
        }
        var ok = true
      //--- Filter name
        var filterSetName = ""
        if let firstLine = components.first {
          filterSetName = firstLine
          components.removeFirst ()
        }else{
          ok = false
        }
      //--- Vitesse bus alimentation
        var vitesseBusAlimentations = CanBusSpeed.bps800k
        if let firstLine = components.first, let u = Int (firstLine), let v = CanBusSpeed (rawValue: u) {
          vitesseBusAlimentations = v
          components.removeFirst ()
        }else{
          ok = false
        }
      //--- Vitesse bus accessoires
        var débitBusAccessoires = CanBusSpeed.bps125k
        if let firstLine = components.first, let u = Int (firstLine), let v = CanBusSpeed (rawValue: u) {
          débitBusAccessoires = v
          components.removeFirst ()
        }else{
          ok = false
        }
      //---
        for line in components {
          let scanner = Scanner (string: line)
          if scanner.scanString ("S") != nil {
            var base : Int64 = -1
            var mask : Int64 = -1
            var name : String = ""
            if unsafe scanner.scanHexInt64 (&base),
                base >= 0, base <= 0x7FF,
                unsafe scanner.scanHexInt64 (&mask),
                mask >= 0, mask <= 0x7FF {
              let index = scanner.currentIndex
              name = String (line[index...]).trimmingCharacters (in: .whitespaces)
              _ = standardFilters.append(base: UInt16 (base), mask: UInt16 (mask), name: name)
            }else{
              ok = false
            }
          }else if scanner.scanString ("E") != nil {
            var base : Int64 = -1
            var mask : Int64 = -1
            var name : String = ""
            if unsafe scanner.scanHexInt64 (&base),
                base >= 0, base <= 0x1FFF_FFFF,
                unsafe scanner.scanHexInt64 (&mask),
                mask >= 0, mask <= 0x1FFF_FFFF {
               let index = scanner.currentIndex
               name = String (line[index...]).trimmingCharacters (in: .whitespaces)
               _ = extendedFilters.append(base: UInt32 (base), mask: UInt32 (mask), name: name)
            }else{
              ok = false
            }
          }else{
            ok = false
          }
        }
        if ok {
          self.mFilterSetArray.append (
            name: filterSetName,
            débitBusAlimentations: vitesseBusAlimentations,
            débitBusAccessoires: débitBusAccessoires,
            standardFilters: standardFilters,
            extendedFilters: extendedFilters
          )
        }
      }
    case .failure (let error):
      print (error)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func exporterJeuDeFiltres () -> FilterSetDocument {
    let filterSet = self.mFilterSetArray.first { $0.id == self.mSelectedFilterSetID }
    let doc = FilterSetDocument (filterSet)
    return doc
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func removeSelectedStandardFilter () {
    if let idx = self.mFilterSetArray.firstIndex (where: { $0.id == self.mSelectedFilterSetID }),
       let idf = self.mFilterSetArray [idx].standardFilters.firstIndex (where: { $0.id == self.mCurrentlySelectedStandardFilterID } ) {
      self.mFilterSetArray [idx].standardFilters.remove (at: idf)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func removeSelectedExtendedFilter () {
    if let idx = self.mFilterSetArray.firstIndex (where: { $0.id == self.mSelectedFilterSetID }),
       let idf = self.mFilterSetArray [idx].extendedFilters.firstIndex (where: { $0.id == self.mCurrentlySelectedExtendedFilterID } ) {
      self.mFilterSetArray [idx].extendedFilters.remove (at: idf)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func standardFilterEditor () -> some View {
    VStack (spacing: 10.0) {
      AppIconView (title: (self.mCurrentlyEditedStandardFilterID != nil) ? "Édition d'un filtre standard" : "Ajout d'un filtre standard")
      HStack {
        Text ("Nom")
        TextField ("", text: self.$mEditingFilterName)
      }
      Grid {
        GridRow {
          Text ("Base")
          Text ("0x\(self.mEditingStandardFilterBaseValue.hex3String)")
        }
        GridRow {
          Text ("Masque")
          Text ("0x\(self.mEditingStandardFilterMaskValue.hex3String)")
        }
      }
      BaseMask11BitsEditor (base: self.$mEditingStandardFilterBaseValue, mask: self.$mEditingStandardFilterMaskValue)
      HStack {
        Button ("Annuler") {
          self.mPresentingStandardFilterEditor = false
        }
        .myCancelConfiguration (disabled: false)
        Spacer ()
        Button ((self.mCurrentlyEditedStandardFilterID != nil) ? "Enregistrer" : "Ajouter") {
          self.mPresentingStandardFilterEditor = false
          let idx = self.mFilterSetArray.firstIndex { $0.id == self.mSelectedFilterSetID }!
          if let editedStandardFilterID = self.mCurrentlyEditedStandardFilterID {
            let idy = self.mFilterSetArray [idx].standardFilters.firstIndex { $0.id == editedStandardFilterID }!
            self.mFilterSetArray [idx].standardFilters [idy].base = self.mEditingStandardFilterBaseValue
            self.mFilterSetArray [idx].standardFilters [idy].mask = self.mEditingStandardFilterMaskValue
            self.mFilterSetArray [idx].standardFilters [idy].name = self.mEditingFilterName
          }else{
            let id = self.mFilterSetArray [idx].standardFilters.append (
              base: self.mEditingStandardFilterBaseValue,
              mask: self.mEditingStandardFilterMaskValue,
              name: self.mEditingFilterName
            )
            Task { @MainActor in
              self.mCurrentlyEditedStandardFilterID = id
            }
          }
        }
        .keyboardShortcut (.defaultAction)
      }
    }.padding ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func extendedFilterEditor () -> some View {
    VStack (spacing: 10) {
      AppIconView (title: (self.mCurrentlyEditedExtendedFilterID != nil) ? "Édition d'un filtre étendu" : "Ajout d'un filtre étendu")
      HStack {
        Text ("Nom")
        TextField ("", text: self.$mEditingFilterName)
      }
      Grid {
        GridRow {
          Text ("Base")
          Text ("0x\(self.mEditingExtendedFilterBaseValue.hex8SepString)")
        }
        GridRow {
          Text ("Masque")
          Text ("0x\(self.mEditingExtendedFilterMaskValue.hex8SepString)")
        }
      }
      BaseMask29BitsEditor (base: self.$mEditingExtendedFilterBaseValue, mask: self.$mEditingExtendedFilterMaskValue)
      HStack {
        Button ("Annuler") {
          self.mPresentingExtendedFilterEditor = false
        }
        .myCancelConfiguration (disabled: false)
        Spacer ()
        Button ((self.mCurrentlyEditedExtendedFilterID != nil) ? "Enregistrer" : "Ajouter") {
          self.mPresentingExtendedFilterEditor = false
          let idx = self.mFilterSetArray.firstIndex { $0.id == self.mSelectedFilterSetID }!
          if let editedExtendedFilterID = self.mCurrentlyEditedExtendedFilterID {
            let idy = self.mFilterSetArray [idx].extendedFilters.firstIndex { $0.id == editedExtendedFilterID }!
            self.mFilterSetArray [idx].extendedFilters [idy].base = self.mEditingExtendedFilterBaseValue
            self.mFilterSetArray [idx].extendedFilters [idy].mask = self.mEditingExtendedFilterMaskValue
            self.mFilterSetArray [idx].extendedFilters [idy].name = self.mEditingFilterName
          }else{
            let id = self.mFilterSetArray [idx].extendedFilters.append (
              base: self.mEditingExtendedFilterBaseValue,
              mask: self.mEditingExtendedFilterMaskValue,
              name: self.mEditingFilterName
            )
            Task { @MainActor in
              self.mCurrentlyEditedExtendedFilterID = id
            }
          }
        }
        .keyboardShortcut (.defaultAction)
      }
    }.padding ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func filterSetIDSet () -> Set <FilterSetID> {
    var result = Set <FilterSetID> ()
    for filterSet in self.mFilterSetArray {
      result.insert (filterSet.id)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
