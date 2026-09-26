//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 07/10/2025.
//--------------------------------------------------------------------------------------------------

import SwiftUI
import UniformTypeIdentifiers
import PicoConnection

//--------------------------------------------------------------------------------------------------

fileprivate let ACQUISITION_REFRESH_FREQUENCY_HERZ : Int = 2

//--------------------------------------------------------------------------------------------------

enum WiFiSendCode : UInt8, WiFiSendCodeProtocol {
  case startWithoutFilter = 0x01
  case startWithFilter = 0x02
  case queryWifiParameters = 0x06
  case registerWifiParameters = 0x07
  case stopImmediatly = 0x3F
}

//--------------------------------------------------------------------------------------------------

enum WiFiReceiveCode : UInt8, WiFiReceiveCodeProtocol {
  case triggerHasBeenReceived = 0x00
  case frameReceived = 0x01
  case wiFiParametersReceived = 0x06
  case endOfAcquisition = 0x3F
}

//--------------------------------------------------------------------------------------------------

struct MainView : View {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mConnection = PicoConnection <WiFiSendCode, WiFiReceiveCode> (
    serviceTypeName: "_espion-can-service._tcp",
    serviceName: "espion-can-pico-host",
    trace: false
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mOperationEnCours = false
  @State private var mTriggerHasBeenReceived = false
  @State private var mOperationStartDate = Date ()
  @State private var mOperationCurrentTickCount = 0
  @State private var mAfficherIdentificateursDécodés = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mReceivedFramesBuffer = ReceivedFramesBuffer ()
  @State private var mFilteredFrameArray = [CANFrame] ()
  @State private var mReceivedFrameArray = [CANFrame] ()
  @State private var mDébitAlimentations = CanBusSpeed.bps500k
  @State private var mDébitAccessoires = CanBusSpeed.bps250k
  @State private var mStandardFilters = [StandardFilterDefinition] ()
  @State private var mExtendedFilters = [ExtendedFilterDefinition] ()
  @State private var mFilterArray = [FilterIndex] ()
  @State private var mUnmatchedStandardFiltersCount = 0
  @State private var mUnmatchedExtendedFiltersCount = 0
  @State private var mDisplayStandardFilterUnmatchedFrames = true
  @State private var mDisplayExtendedFilterUnmatchedFrames = true

  @AppStorage("display.all.standard.filters") private var mDisplayAllStandardFilters = true
  @AppStorage("display.all.extended.filters") private var mDisplayAllExtendedFilters = true
  @AppStorage("display.standard.frames") private var mDisplayStandardFrames = true
  @AppStorage("display.extended.frames") private var mDisplayExtendedFrames = true
  @AppStorage("display.accessoires.frames") private var mDisplayFramesFrom_Accessoires = true
  @AppStorage("display.alimentations.frames") private var mDisplayFramesFrom_Alimentations = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mPresentingFileExporterDialog = false
  @State private var mPresentingFileImporterDialog = false
  @State private var mPresentingWifiConnectionLostView = false

  @State private var mPresentingAcquisitionConfigurationSheet = false
  @State private var mAcquisitionSheetMessage = ""
  @State private var mAcquisitionProgressString = ""

  @State private var mShowInterfaceUpdatingMessage = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @AppStorage("filter.set.array.json.data") private var mFilterSetArrayJSONData = Data ()
  @AppStorage("used.filter.set.id") private var mUsedFilterSetID = FilterSetID ()

  @State private var mFilterSetArray = [FilterSet] ()

  @State private var mPresentingFilterManagerDialog = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @AppStorage("acquisition.duration") private var mAcquisitionDurationInSeconds = 1
  @State private var mTemporaryAcquisitionDurationInSeconds = 1

  @AppStorage("acquisition.filter.index") private var mAcquisitionTriggerIndex = 0
  @State private var mTemporaryAcquisitionTriggerIndex = 0

  @AppStorage("acquisition.network") private var mAcquisitionNetwork = 3
  @State private var mTemporaryAcquisitionNetwork = 3

  @AppStorage("accessoires.en.mode.loop.back") private var mModeLoopBack_Accessoires = false
  @State private var mTemporaryModeLoopBack_Accessoires = false

  @AppStorage("alimentations.en.mode.loop.back") private var mModeLoopBack_Alimentations = false
  @State private var mTemporaryModeLoopBack_Alimentations = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func computeFilteredFrameArray () {
    Task { @MainActor in
      var array = [CANFrame] ()
      let receivedFrameArray = self.mReceivedFrameArray
      let displayFramesFrom_Accessoires = self.mDisplayFramesFrom_Accessoires
      let displayFramesFrom_Alimentations = self.mDisplayFramesFrom_Alimentations
      let displayExtendedFrames = self.mDisplayExtendedFrames
      let displayExtendedFilterUnmatchedFrames = self.mDisplayExtendedFilterUnmatchedFrames
      let extendedFilters = self.mExtendedFilters
      let displayStandardFrames = self.mDisplayStandardFrames
      let displayStandardFilterUnmatchedFrames = self.mDisplayStandardFilterUnmatchedFrames
      let standardFilters = self.mStandardFilters
      for frame in receivedFrameArray {
        var display : Bool
        switch frame.network {
        case .accessoires :
          display = displayFramesFrom_Accessoires
        case .alimentations :
          display = displayFramesFrom_Alimentations
        }
        if display {
          if frame.extended {
            if displayExtendedFrames {
              if let filterIndex = frame.filterIndex {
                if extendedFilters [filterIndex].isDisplayed {
                  array.append (frame)
                }
              }else if displayExtendedFilterUnmatchedFrames {
                array.append (frame)
              }
            }
          }else{
            if displayStandardFrames {
              if let filterIndex = frame.filterIndex {
                if standardFilters [filterIndex].isDisplayed {
                  array.append (frame)
                }
              }else if displayStandardFilterUnmatchedFrames {
                array.append (frame)
              }
            }
          }
        }
      }
      self.mShowInterfaceUpdatingMessage = (array.count > 60_000) || (self.mFilteredFrameArray.count > 60_000)
      Task { @MainActor in
        self.mFilteredFrameArray = array
        self.mShowInterfaceUpdatingMessage = false
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var body : some View {
    VStack (spacing: 0) {
      HStack {
        Text ("S").foregroundStyle (Color.red)
        .isHidden (!self.mConnection.mSendingPublishedState)
        Text ("R").foregroundStyle (Color.green.mix (with: .black, by: 0.25))
        .isHidden (!self.mConnection.mReceivingPublishedState)
        Text ("Connexion : ")
        Text (self.mConnection.mConnectionState.message)
        Spacer ()
        Button ("Paramètres Wifi…") { self.mPresentingWifiParametersSettingsView = true }
        .disabled (!self.mConnection.isConnected)
        Button ("Acquisition…") { self.mPresentingAcquisitionConfigurationSheet = true }
      }.padding (6).controlSize (.small)
      Divider ()
      HSplitView {
        self.leftView ().frame (minWidth: 200, idealWidth: 250, maxWidth: 300)
        self.centerView ().frame (minWidth: 280, idealWidth: 400)
      }
    }
    .sheet (isPresented: self.$mPresentingAcquisitionConfigurationSheet) { self.acquisitionConfigurationSheet () }
    .sheet (isPresented: self.$mPresentingWifiParametersSettingsView) { self.wifiParametersSettingsSheet () }
    .sheet (isPresented: self.$mPresentingWifiConnectionLostView) { self.wifiConnectionLostSheet () }
    .sheet (isPresented: self.$mPresentingFilterManagerDialog) {
      FilterSetArrayEditor (
        filterSetArray: self.$mFilterSetArray,
        usedFilterSetID: self.$mUsedFilterSetID,
        presentingFilterManagerDialog: self.$mPresentingFilterManagerDialog
      )
    }
    .onChange (of: self.mFilterSetArrayJSONData, initial: true) { (old, newData) in
      if let array = try? JSONDecoder ().decode ([FilterSet].self, from: newData) {
        if self.mFilterSetArray != array {
          self.mFilterSetArray = array
        }
      }else{
        ajouterFiltresTrains (self.$mFilterSetArray)
      }

    }
    .onChange (of: self.mFilterSetArray, initial: true) { (old, new) in
      self.buildFilterArray ()
      self.computeFilteredFrameArray ()
    }
    .onChange (of: self.mUsedFilterSetID) { (old, new) in
      self.buildFilterArray ()
      self.computeFilteredFrameArray ()
    }
    .onChange (of: self.mConnection.isConnected, initial: true) { (old, new) in
       if new {
         self.mPresentingWifiConnectionLostView = false
       }
    }
    .onChange (of: self.mConnection.mConnectionLost, initial: true) { (old, new) in
       if new {
         self.mPresentingWifiConnectionLostView = true
       }
    }
    .onAppear () {
      self.mConnection.setCompletionCallBack { self.retrieveWifiCommandCallBack ($0) }
//      if let data = UserDefaults.standard.data (forKey: "filter.set.array.json.data"),
//         let array = try? JSONDecoder ().decode ([FilterSet].self, from: data) {
//        self.mFilterSetArray = array
//      }else{
//        ajouterFiltresTrains (self.$mFilterSetArray)
//      }
    }
    .fileExporter (
      isPresented: self.$mPresentingFileExporterDialog,
      document: self.documentForSavingOperation (),
      contentType: UTType.captureDocument,
      defaultFilename: self.defaultFileNameForSavingOperation (),
      onCompletion: { result in }
    )
    .fileImporter (
      isPresented: self.$mPresentingFileImporterDialog,
      allowedContentTypes: [UTType.captureDocument],
      onCompletion: { self.importOperation (result: $0) }
    )
    .onChange (of: self.mReceivedFrameArray) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayFramesFrom_Accessoires) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayFramesFrom_Alimentations) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayExtendedFrames) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayExtendedFilterUnmatchedFrames) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayStandardFrames) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayStandardFilterUnmatchedFrames) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayAllStandardFilters, initial: true) { self.computeFilteredFrameArray() }
    .onChange (of: self.mDisplayAllExtendedFilters, initial: true) { self.computeFilteredFrameArray() }
    .onChange (of: self.mStandardFilters, initial: true) { self.computeFilteredFrameArray () }
    .onChange (of: self.mExtendedFilters, initial: true) { self.computeFilteredFrameArray () }
    .onChange (of: self.mFilterSetArray) {
      let encoder = JSONEncoder ()
      encoder.outputFormatting = .sortedKeys
      let data = (try? encoder.encode (self.mFilterSetArray)) ?? Data ()
      if self.mFilterSetArrayJSONData != data {
        self.mFilterSetArrayJSONData = data
//        UserDefaults.standard.set (data, forKey: "filter.set.array.json.data")
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildFilterArray () {
    if let filterSet : FilterSet = self.mFilterSetArray.first (where: { $0.id == self.mUsedFilterSetID }) {
      self.mDébitAlimentations = filterSet.débitBusAlimentations
      self.mDébitAccessoires = filterSet.débitBusAccessoires
      self.mStandardFilters = filterSet.standardFilters
      self.mExtendedFilters = filterSet.extendedFilters
      let count = 1 + self.mStandardFilters.count + self.mExtendedFilters.count
      if self.mTemporaryAcquisitionTriggerIndex >= count {
        self.mTemporaryAcquisitionTriggerIndex = count - 1
      }
      var array = [FilterIndex] ()
      array.append (FilterIndex (filter: "« Aucune attente »", index: 0))
      var n = 1
      for filter in self.mStandardFilters {
        array.append (FilterIndex (filter: "Standard: \(filter.displayString)", index: n))
        n += 1
      }
      for filter in self.mExtendedFilters {
        array.append (FilterIndex (filter: "Étendue: \(filter.displayString)", index: n))
        n += 1
      }
      self.mFilterArray = array
    }else{
      self.mFilterArray.removeAll ()
    }
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

  private func wifiConnectionLostSheet () -> some View {
    VStack {
      AppIconView (title: "Perte de la connexion")
      Spacer ()
      Button ("Fermer") { self.mPresentingWifiConnectionLostView = false }
      .keyboardShortcut (.defaultAction)
    }.padding ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder private func centerView () -> some View {
    VStack (spacing: 0) {
      HStack {
        Menu ("", systemImage: "gearshape.fill") {
          Button ("Exporter acquisition…") { self.mPresentingFileExporterDialog = true }
          Button ("Importer acquisition…") { self.mPresentingFileImporterDialog = true }
          Divider ()
          Button ("Gestion des paramètres…") { self.mPresentingFilterManagerDialog = true }
        }
        Text ("Jeu de paramètres utilisé")
        Picker ("", selection: self.$mUsedFilterSetID) {
          Text ("Aucun").tag (FilterSetID ())
          ForEach (self.mFilterSetArray) { filter in
            Text (filter.name).tag (filter.id)
          }
        }
        Toggle ("Décoder les identificateurs", isOn: self.$mAfficherIdentificateursDécodés)
        .disabled (self.mFilterSetArray.firstIndex { $0.id == self.mUsedFilterSetID } == nil)
        Spacer ()
        if !self.mOperationEnCours {
          Text (self.acquisitionStateString ())
        }
      }.padding (12)
      if self.mShowInterfaceUpdatingMessage {
        VStack {
          Spacer ()
          HStack { Spacer () ; Text ("Mise à jour de l'interface…") ; Spacer () }
          Spacer ()
        }
      }else{
        Table (self.mFilteredFrameArray) {
          TableColumn ("Date", value: \.dateString).width (112)
          TableColumn ("Réseau", value: \.networkString).width (48)
          TableColumn ("Identificateur") { frame in
            HStack {
              Text (frame.identifierString (self.mStandardFilters, self.mExtendedFilters, self.mAfficherIdentificateursDécodés))
              Spacer ()
            }
            .frame (width: 200)
          }
          TableColumn ("Données de la trame", value: \.dataString)
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func acquisitionStateString () -> String {
    var s = (self.mFilteredFrameArray.count > 1)
      ? "\(self.mFilteredFrameArray.count) trames affichées"
      : "\(self.mFilteredFrameArray.count) trame affichée"
    if self.mConnection.rawReceivedByteCount > 0 {
      s += ", \(UInt64 (self.mReceivedFramesBuffer.mFrameArray.count).displayString) trames"
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder private func leftView () -> some View {
    if self.mReceivedFrameArray.isEmpty {
      Spacer ()
    }else{
      VStack (alignment: .leading) {
        VStack (alignment: .leading) {
          Text ("Afficher").bold ()
          Toggle ("Trames du réseau Accessoires", isOn: self.$mDisplayFramesFrom_Accessoires)
          Toggle ("Trames du réseau Alimentations", isOn: self.$mDisplayFramesFrom_Alimentations)
          Toggle ("Trames standard", isOn: self.$mDisplayStandardFrames)
          HStack {
            Spacer ().frame (width: 30)
            Toggle ("Tous les filtres standard", isOn: self.$mDisplayAllStandardFilters)
            .disabled (!self.mDisplayStandardFrames)
          }
          Toggle ("Trames étendues", isOn: self.$mDisplayExtendedFrames)
          HStack {
            Spacer ().frame (width: 30)
            Toggle ("Tous les filtres étendus", isOn: self.$mDisplayAllExtendedFilters)
            .disabled (!self.mDisplayExtendedFrames)
          }
        }.padding (12)
        if self.mDisplayStandardFrames {
          Divider ()
          VStack (alignment: .leading) {
            Text ("Filtres standard").bold ()
            ScrollView {
              if self.mDisplayAllStandardFilters || (self.mUnmatchedStandardFiltersCount > 0) {
                HStack {
                  Toggle ("\(self.mUnmatchedStandardFiltersCount) : trame ne répondant à aucun filtre", isOn: self.$mDisplayStandardFilterUnmatchedFrames)
                  .disabled (self.mUnmatchedStandardFiltersCount == 0)
                  Spacer ()
                }
              }
              ForEach (self.$mStandardFilters) { $filter in
                if self.mDisplayAllStandardFilters || (filter.count > 0) {
                  $filter.standardFilterView ()
                }
              }
            }
          }.padding ([.top, .leading, .bottom], 12)
        }
        if self.mDisplayExtendedFrames {
          Divider ()
          VStack (alignment: .leading) {
            Text ("Filtres étendus").bold ()
            ScrollView {
              if self.mDisplayAllExtendedFilters || (self.mUnmatchedExtendedFiltersCount > 0) {
                HStack {
                  Toggle ("\(self.mUnmatchedExtendedFiltersCount) : trame ne répondant à aucun filtre", isOn: self.$mDisplayExtendedFilterUnmatchedFrames)
                  .disabled (self.mUnmatchedExtendedFiltersCount == 0)
                  Spacer ()
                }
              }
              ForEach (self.$mExtendedFilters) { $filter in
                if self.mDisplayAllExtendedFilters || (filter.count > 0) {
                  $filter.extendedFilterView ()
                }
              }
            }
          }.padding ([.top, .leading, .bottom], 12)
        }
        Spacer ()
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func setReceivedFrameArray (_ inArray : [CANFrame]) {
    var array = inArray
    var standardFilters = self.mStandardFilters
    var extendedFilters = self.mExtendedFilters
    for idx in 0 ..< standardFilters.count {
      standardFilters [idx].count = 0
    }
    for idx in 0 ..< extendedFilters.count {
      extendedFilters [idx].count = 0
    }
    var unmatchedStandardFiltersCount = 0
    var unmatchedExtendedFiltersCount = 0
    var frameIndex = 0
    while frameIndex < array.count {
      let frame = array [frameIndex]
      var idx = 0
      var found = false
      if frame.extended {
        while idx < extendedFilters.count, !found {
          if extendedFilters [idx].accept (identifier: frame.identifier) {
            extendedFilters [idx].count += 1
            array [frameIndex].filterIndex = idx
            found = true
          }
          idx += 1
        }
        if !found {
          unmatchedExtendedFiltersCount += 1
        }
      }else{
        while idx < standardFilters.count, !found {
          if standardFilters [idx].accept (identifier: UInt16 (frame.identifier)) {
            standardFilters [idx].count += 1
            array [frameIndex].filterIndex = idx
            found = true
          }
          idx += 1
        }
        if !found {
          unmatchedStandardFiltersCount += 1
        }
      }
      frameIndex += 1
    }
    self.mUnmatchedStandardFiltersCount = unmatchedStandardFiltersCount
    self.mUnmatchedExtendedFiltersCount = unmatchedExtendedFiltersCount
    self.mReceivedFrameArray = array
    self.mExtendedFilters = extendedFilters
    self.mStandardFilters = standardFilters
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Acquisition
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @ViewBuilder private func acquisitionConfigurationSheet () -> some View {
    VStack (spacing: 12) {
      AppIconView (title: "Acquisition")
      Form {
        LabeledContent ("Débit du bus \(Text ("Alimentations").italic ())") {
          Text (self.mDébitAlimentations.string)
        }
        LabeledContent ("Débit du bus \(Text ("Accessoires").italic ())") {
          Text (self.mDébitAccessoires.string)
        }
        Toggle ("Interface CAN \(Text ("Alimentations").italic ()) en mode loop back", isOn: self.$mTemporaryModeLoopBack_Alimentations)
        .disabled (self.mOperationEnCours)
        Toggle ("Interface CAN \(Text ("Accessoires").italic ()) en mode loop back", isOn: self.$mTemporaryModeLoopBack_Accessoires)
        .disabled (self.mOperationEnCours)
        Picker ("Attendre l'occurrence d'une trame", selection: self.$mTemporaryAcquisitionTriggerIndex) {
          ForEach (self.mFilterArray, id: \.id) { filterIndex in
            Text (filterIndex.filter).tag (filterIndex.index)
          }
        }.disabled (self.mOperationEnCours)
        Picker ("Sur le réseau ", selection: self.$mTemporaryAcquisitionNetwork) {
          Text ("Alimentations").tag (2)
          Text ("Accessoires").tag (1)
          Text ("Alimentations ou Accessoires").tag (3)
        }.disabled (self.mOperationEnCours || (self.mTemporaryAcquisitionTriggerIndex == 0))
        Picker ((self.mTemporaryAcquisitionTriggerIndex > 0) ? "Puis acquérir pendant" :  "Acquérir immédiatement pendant",
                selection: self.$mTemporaryAcquisitionDurationInSeconds) {
          Text("1 seconde").tag (1)
          Text("2 secondes").tag (2)
          Text("3 secondes").tag (3)
          Text("5 secondes").tag (5)
          Text("7 secondes").tag (7)
          Text("10 secondes").tag (10)
          Text("15 secondes").tag (15)
          Text("20 secondes").tag (20)
          Text("30 secondes").tag (30)
          Text("35 secondes").tag (45)
          Text("60 secondes").tag (60)
        }.disabled (self.mOperationEnCours)
      }
      Spacer ().frame (height: 20)
      if self.mOperationEnCours {
        let progressViewValue = min (
          1.0,
          Double (self.mOperationCurrentTickCount) / Double (self.mAcquisitionDurationInSeconds * ACQUISITION_REFRESH_FREQUENCY_HERZ)
        )
        ProgressView ("Progression de l'acquisition", value: progressViewValue)
        TimelineView (.periodic (from: .now, by: 1.0 / Double (ACQUISITION_REFRESH_FREQUENCY_HERZ))) { timeline in
        //--- Astuce : observer les changements de « seconds » pour éviter le message
        //    « onChange(of: Date) action tried to update multiple times per frame »
          let tick : Int = (ACQUISITION_REFRESH_FREQUENCY_HERZ * Calendar.current.component (.nanosecond, from: timeline.date)) / 1_000_000_000
          Text (self.mAcquisitionSheetMessage)
          Text (self.mAcquisitionProgressString)
          .onChange (of: tick) {
            if self.mTriggerHasBeenReceived {
              self.mOperationCurrentTickCount += 1
              self.mAcquisitionSheetMessage = "Reçu \(UInt64 (self.mConnection.rawReceivedByteCount).displayString) octets, \(UInt64 (self.mReceivedFramesBuffer.mFrameArray.count).displayString) trames"
              self.mAcquisitionProgressString = "\(self.mOperationCurrentTickCount / ACQUISITION_REFRESH_FREQUENCY_HERZ) s sur \(self.mTemporaryAcquisitionDurationInSeconds) s"
            }else{
            self.mAcquisitionSheetMessage = ""
            self.mAcquisitionProgressString = "Waiting for trigger…"
            }
          }
        }
        Button ("Interrompre l'acquisition") {
          self.stopAcquisitionImmediately ()
        }.myCancelConfiguration (disabled: false)
      }else{
        HStack {
          Button ("Annuler") {
            self.mPresentingAcquisitionConfigurationSheet = false
          }.myCancelConfiguration (disabled: false)
          Spacer ()
          if self.acquisitionConfigurationChanges {
            Button ("Enregistrer sans acquérir") {
              self.mPresentingAcquisitionConfigurationSheet = false
              self.validateAcquisitionConfigurationChanges ()
            }
            .conditionalKeyboardShortcut (!self.mConnection.isConnected, shortcut: .defaultAction)
          }
          Button (self.acquisitionConfigurationChanges ? "Enregistrer et acquérir" : "Acquérir") {
            self.validateAcquisitionConfigurationChanges ()
            self.performAcquisition ()
          }
          .conditionalKeyboardShortcut (self.mConnection.isConnected, shortcut: .defaultAction)
          .disabled (!self.mConnection.isConnected)
        }
      }
    }
    .padding ()
    .frame (width: 600)
    .onAppear {
      self.mTemporaryAcquisitionDurationInSeconds = self.mAcquisitionDurationInSeconds
      self.mTemporaryAcquisitionTriggerIndex = self.mAcquisitionTriggerIndex
      self.mTemporaryAcquisitionNetwork = self.mAcquisitionNetwork
      self.mTemporaryModeLoopBack_Accessoires = self.mModeLoopBack_Accessoires
      self.mTemporaryModeLoopBack_Alimentations = self.mModeLoopBack_Alimentations
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var acquisitionConfigurationChanges : Bool {
    (self.mAcquisitionDurationInSeconds != self.mTemporaryAcquisitionDurationInSeconds)
    || (self.mAcquisitionTriggerIndex != self.mTemporaryAcquisitionTriggerIndex)
    || (self.mAcquisitionNetwork != self.mTemporaryAcquisitionNetwork)
    || (self.mModeLoopBack_Accessoires != self.mTemporaryModeLoopBack_Accessoires)
    || (self.mModeLoopBack_Alimentations != self.mTemporaryModeLoopBack_Alimentations)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func validateAcquisitionConfigurationChanges () {
    self.mAcquisitionDurationInSeconds = self.mTemporaryAcquisitionDurationInSeconds
    self.mAcquisitionTriggerIndex = self.mTemporaryAcquisitionTriggerIndex
    self.mAcquisitionNetwork = self.mTemporaryAcquisitionNetwork
    self.mModeLoopBack_Accessoires = self.mTemporaryModeLoopBack_Accessoires
    self.mModeLoopBack_Alimentations = self.mTemporaryModeLoopBack_Alimentations
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct FilterIndex : Identifiable {
    let id = UUID ()
    let filter : String
    let index : Int
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func filterFor (index inIndex : Int) -> (UInt32, UInt32, Bool) {
    if inIndex < self.mStandardFilters.count {
      let filter = self.mStandardFilters [inIndex]
      return (UInt32 (filter.base), UInt32 (filter.mask), false)
    }else{
      let filter = self.mExtendedFilters [inIndex - self.mStandardFilters.count]
      return (filter.base, filter.mask, true)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func stopAcquisitionImmediately () {
    self.mConnection.send (command: .stopImmediatly)
    self.mOperationEnCours = false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func performAcquisition () {
    self.mOperationEnCours = true
    self.mTriggerHasBeenReceived = false
    self.mReceivedFramesBuffer.mFrameArray.removeAll ()
    self.mConnection.removeAllReceivedData ()
    self.mAcquisitionSheetMessage = "En attente…"
    self.mAcquisitionProgressString = ""
    self.mOperationCurrentTickCount = 0
    self.mOperationStartDate = .now
    var modes : UInt64 = 0
    if self.mModeLoopBack_Alimentations { modes |= 1 }
    if self.mModeLoopBack_Accessoires { modes |= 2 }
    if self.mAcquisitionTriggerIndex > 0 {
      let (base, mask, extended) = self.filterFor (index: self.mAcquisitionTriggerIndex - 1)
      self.mConnection.send (encodedU64: UInt64 (base))
      self.mConnection.send (encodedU64: UInt64 (mask))
      var flags : UInt64 = 0
      if extended {
        flags |= 1
      }
      flags |= UInt64 (self.mAcquisitionNetwork) << 1
      self.mConnection.send (encodedU64: flags)
      self.mConnection.send (encodedU64: UInt64 (self.mAcquisitionDurationInSeconds))
      self.mConnection.send (encodedU64: modes)
      self.mConnection.send (encodedU64: UInt64 (self.mDébitAlimentations.rawValue))
      self.mConnection.send (encodedU64: UInt64 (self.mDébitAccessoires.rawValue))
      self.mConnection.send (command: .startWithFilter) // Start with filter
    }else{
      self.mConnection.send (encodedU64: UInt64 (self.mAcquisitionDurationInSeconds))
      self.mConnection.send (encodedU64: modes)
      self.mConnection.send (encodedU64: UInt64 (self.mDébitAlimentations.rawValue))
      self.mConnection.send (encodedU64: UInt64 (self.mDébitAccessoires.rawValue))
      self.mConnection.send (command: .startWithoutFilter) // Start without filter
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func retrieveWifiCommandCallBack (_ inCommand : PicoConnection <WiFiSendCode, WiFiReceiveCode>.Command) {
    switch inCommand.code {
    case .triggerHasBeenReceived :
      self.mTriggerHasBeenReceived = true
      self.mConnection.removeAllReceivedData ()
    case .frameReceived :
      self.mReceivedFramesBuffer.mFrameArray.append (CANFrame (inCommand))
    case .endOfAcquisition :
      self.mPresentingAcquisitionConfigurationSheet = false
      self.mOperationEnCours = false
      DispatchQueue.main.asyncAfter (deadline: .now () + 0.1) {
        self.setReceivedFrameArray (self.mReceivedFramesBuffer.mFrameArray)
      }
    case .wiFiParametersReceived :
      if !self.mGotWifiParameters,
         inCommand.parameters.count == 4,
         let nomRéseauPourStation0 = inCommand.parameters [0].str,
         let motDePasseRéseauPourStation0 = inCommand.parameters [1].str,
         let nomRéseauPourStation1 = inCommand.parameters [2].str,
         let motDePasseRéseauPourStation1 = inCommand.parameters [3].str {
        self.mStationNetworkName0 = nomRéseauPourStation0
        self.mStationPasswordName0 = motDePasseRéseauPourStation0
        self.mStationNetworkName1 = nomRéseauPourStation1
        self.mStationPasswordName1 = motDePasseRéseauPourStation1
        self.mGotWifiParameters = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func defaultFileNameForSavingOperation () -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy'-'MM'-'dd'-'HH'h-'mm'min-'ss's"
    return df.string (from: Date ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func documentForSavingOperation () -> CaptureDocument {
    let doc = CaptureDocument (self.mReceivedFrameArray)
    return doc
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func importOperation (result inResult : Result <URL, any Error>) {
    switch inResult {
    case .success (let url) :
      if url.startAccessingSecurityScopedResource (),
         let data = try? Data (contentsOf: url),
         let str = String (data: data, encoding: .utf8) {
        url.stopAccessingSecurityScopedResource ()
        var components = str.components (separatedBy: "\n")
      //--- Supprimer la dernière ligne si elle est vide
        if let lastLine = components.last, lastLine.isEmpty {
          components.removeLast ()
        }
        var array = [CANFrame] ()
        for line in components {
          if let canFrame = CANFrame (stringSavedInDocument: line) {
            array.append (canFrame)
          }
        }
        self.setReceivedFrameArray (array)
      }
    case .failure (let error):
      print(error)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: WiFi Parameter settings View
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @State private var mPresentingWifiParametersSettingsView = false
  @State private var mStationNetworkName0 = ""
  @State private var mStationPasswordName0 = ""
  @State private var mStationNetworkName1 = ""
  @State private var mStationPasswordName1 = ""
  @State private var mGotWifiParameters = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func wifiParametersSettingsSheet () -> some View {
    VStack {
      AppIconView (title: "Paramètres de la connexion WiFi")
      Form {
        Section ("Paramètres Station (OFF-OFF)") {
          TextField ("Nom du réseau", text: self.$mStationNetworkName0).disabled (!self.mGotWifiParameters)
          TextField ("Mot de passe", text: self.$mStationPasswordName0).disabled (!self.mGotWifiParameters)
        }
        Section ("Paramètres Station (OFF-ON)") {
          TextField ("Nom du réseau", text: self.$mStationNetworkName1).disabled (!self.mGotWifiParameters)
          TextField ("Mot de passe", text: self.$mStationPasswordName1).disabled (!self.mGotWifiParameters)
        }
      }
      Spacer ()
      HStack {
        Button ("Fermer") { self.mPresentingWifiParametersSettingsView = false }
        .myCancelConfiguration (disabled: false)
        Spacer ()
        Button ("Enregistrer") { self.enregistrerParametresWifi () }
        .keyboardShortcut (.defaultAction)
        .disabled (!self.mGotWifiParameters)
      }
    }.padding ()
    .onAppear() { self.retrieveWifiParameters () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func retrieveWifiParameters () {
    self.mGotWifiParameters = false
    self.mConnection.send (command: .queryWifiParameters)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func enregistrerParametresWifi () {
    self.mConnection.send (encodedString: self.mStationNetworkName0)
    self.mConnection.send (encodedString: self.mStationPasswordName0)
    self.mConnection.send (encodedString: self.mStationNetworkName1)
    self.mConnection.send (encodedString: self.mStationPasswordName1)
    self.mConnection.send (command: .registerWifiParameters)
    self.mPresentingWifiParametersSettingsView = false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension PicoConnection.ConnectionState {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var message : String {
    switch self {
    case .disconnected :
      return "déconnecté"
    case .searching :
      return "recherche en cours…"
    case .connecting  :
      return "connexion en cours…"
    case .preparing  :
      return "préparation de la connexion…"
    case .connected (let str) :
      return "connecté à \(str)"
    case .connectionLost (let erreur) :
      return "connexion perdue : \(erreur)"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class ReceivedFramesBuffer { // NO OBSERVATION
  var mFrameArray = [CANFrame] ()
}

//--------------------------------------------------------------------------------------------------
