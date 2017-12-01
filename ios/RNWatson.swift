//
//  Created by Patrick cremin on 8/2/17.
//

import Foundation
import ToneAnalyzerV3
import TextToSpeechV1
import SpeechToTextV1
import VisualRecognitionV3
import AVFoundation
import AlchemyDataNewsV1
import NaturalLanguageUnderstandingV1
import ConversationV1
import RestKit

// TextToSpeech
@objc(RNTextToSpeech)
class RNTextToSpeech: NSObject {
  
  var textToSpeech: TextToSpeech?
  var audioPlayer = AVAudioPlayer()
  
  static let sharedInstance = RNTextToSpeech()
  private override init() {}
  
  @objc func initialize(_ username: String, password: String) -> Void {
    textToSpeech = TextToSpeech(username: username, password: password)
  }
  
  @objc func synthesize(_ text: String, voice: String,
                        resolver resolve: RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    
    var synthesizeVoice = voice
    
    if synthesizeVoice.isEmpty {
      synthesizeVoice = "en-GB_KateVoice"
    }
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    textToSpeech?.synthesize(text, voice: synthesizeVoice, failure: failure) { data in
      self.audioPlayer = try! AVAudioPlayer(data: data)
      self.audioPlayer.prepareToPlay()
      self.audioPlayer.play()
    }
  }
  
  @objc func getVoices(_ resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    let success = { (voices: [Voice]) -> Void in
      var voicesArray = [[String: String]]()
      
      for voice in voices {
        voicesArray.append([
          "name": voice.name,
          "url": voice.url,
          "description": voice.description,
          "gender": voice.gender,
          "language": voice.language
          ])
      }
      
      resolve(voicesArray)
    }
    
    textToSpeech?.getVoices(failure: failure, success: success )
  }
}

// SpeechToText
@objc(RNSpeechToText)
class RNSpeechToText: RCTEventEmitter {
  
  var speechToText: SpeechToText?
  var audioPlayer = AVAudioPlayer()
  var callback: RCTResponseSenderBlock?
  var hasListeners = false
  
  static let sharedInstance = RNSpeechToText()
  
  private override init() {}
  
  override func supportedEvents() -> [String]! {
    return ["StreamingText"]
  }
  
  @objc func initialize(_ username: String, password: String) -> Void {
    speechToText = SpeechToText(username: username, password: password)
  }
  
  @objc func startStreaming(_ errorCallback: @escaping RCTResponseSenderBlock) {
    
    var settings = RecognitionSettings(contentType: .opus)
    settings.interimResults = true
    
    let failure = { (error: Error) in errorCallback([error]) }
    
    speechToText?.recognizeMicrophone(settings: settings, failure: failure) { results in
      if(self.hasListeners)
      {
        self.sendEvent(withName: "StreamingText", body: results.bestTranscript)
      }
    }
  }
  
  @objc func stopStreaming() {
    speechToText?.stopRecognizeMicrophone()
  }
  
  override func startObserving()
  {
    hasListeners = true
  }
  
  override func stopObserving()
  {
    hasListeners = false
  }
}

// ToneAnalyzer
@objc(RNToneAnalyzer)
class RNToneAnalyzer: NSObject {
  
  var toneAnalyzer: ToneAnalyzer?
  
  static let sharedInstance = RNToneAnalyzer()
  
  private override init() {}
  
  @objc func initialize(_ username: String, password: String) -> Void {
    toneAnalyzer = ToneAnalyzer(username: username, password: password, version: "2017-08-22")
  }
  
  @objc func getTone(_ ofText: String,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    toneAnalyzer?.getTone(ofText: ofText, failure: failure){ tones in
      
      resolve(tones.toDictionary())
    }
  }
}


@objc(RNNaturalLanguageUnderstanding)
class RNNaturalLanguageUnderstanding: NSObject {
  
  var naturalLanguageUnderstanding: NaturalLanguageUnderstanding?
  
  static let sharedInstance = RNNaturalLanguageUnderstanding()
  
  private override init() {}
  
  @objc func initialize(_ username: String, password: String) -> Void {
    naturalLanguageUnderstanding = NaturalLanguageUnderstanding(username: username, password: password, version: "2017-08-22")
  }
  
  @objc func analyzeContent(_ contentToAnalyze: [String : Any], featuresDict: [String : Any],
                            resolver resolve: @escaping RCTPromiseResolveBlock,
                            rejecter reject: @escaping RCTPromiseRejectBlock
    ) -> Void
  {
    var conceptsOptions: ConceptsOptions?
    var emotionOptions: EmotionOptions?
    var entitiesOptions: EntitiesOptions?
    var keywordsOptions: KeywordsOptions?
    var metadataOptions: MetadataOptions?
    var relationsOptions: RelationsOptions?
    var semanticRolesOptions: SemanticRolesOptions?
    var sentimentOptions: SentimentOptions?
    var categoriesOptions: CategoriesOptions?
    
    if let concepts = featuresDict["concepts"] as? [String: Any] {
      conceptsOptions = ConceptsOptions( limit: concepts["limit"] as? Int, linkedData: concepts["linkedData"] as? Bool)
    }
    
    if let emotion = featuresDict["emotion"] as? [String: Any] {
      emotionOptions = EmotionOptions(document: emotion["document"] as? Bool, targets: emotion["targets"] as? [String])
    }
    
    if let entities = featuresDict["entities"] as? [String: Any] {
      entitiesOptions = EntitiesOptions(limit: entities["limit"] as? Int, model: entities["model"] as? String, disambiguation: entities["disambiguation"] as? Bool, sentiment: entities["sentiment"] as? Bool)
    }
    
    if let keywords = featuresDict["keywords"] as? [String: Any] {
      keywordsOptions = KeywordsOptions(limit: keywords["limit"] as? Int, sentiment: keywords["sentiment"] as? Bool)
    }
    
    if (featuresDict["metadata"] as? Bool) != nil {
      metadataOptions = MetadataOptions()
    }
    
    if let relations = featuresDict["relations"] as? [String: Any] {
      relationsOptions = RelationsOptions(model: relations["model"] as? String)
    }
    
    if let semanticRoles = featuresDict["semanticRoles"] as? [String: Any] {
      semanticRolesOptions = SemanticRolesOptions(limit: semanticRoles["limit"] as? Int, keywords: semanticRoles["keywords"] as? Bool, entities: semanticRoles["entities"] as? Bool, requireEntities: semanticRoles["requireEntities"] as? Bool, disambiguate: semanticRoles["disambiguate"] as? Bool)
    }
    
    if let sentiment = featuresDict["sentiment"] as? [String: Any] {
      sentimentOptions = SentimentOptions(document: sentiment["document"] as? Bool, targets: sentiment["targets"] as? [String])
    }
    
    if (featuresDict["categories"] as? Bool) != nil {
      categoriesOptions = CategoriesOptions()
    }
    
    let features = Features(concepts: conceptsOptions, emotion: emotionOptions, entities: entitiesOptions, keywords: keywordsOptions, metadata: metadataOptions, relations: relationsOptions, semanticRoles: semanticRolesOptions, sentiment: sentimentOptions, categories: categoriesOptions)
    
    
    let html = URL(string: contentToAnalyze["html"] as? String ?? "" )
    let parameters = Parameters(features: features, text: contentToAnalyze["text"] as? String, html: html, url: contentToAnalyze["url"] as? String)
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    naturalLanguageUnderstanding?.analyzeContent(withParameters: parameters, failure: failure) { results in
      resolve(results.toDictionary())
    }
    
  }
}


// Conversation
@objc(RNConversation)
class RNConversation: NSObject {
  
  var conversation: Conversation?
  
  static let sharedInstance = RNConversation()
  
  private override init() {}
  
  @objc func initialize(_ username: String, password: String) -> Void {
    conversation = Conversation(username: username, password: password, version: "2017-08-22")
  }
  
  @objc func message(_ workspaceID: String,
                     inputDict: [String : Any]?,                     
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    let failure = { (error: Error) in reject(nil, nil, error) }
    
    var input: Input?
    var context: Context?
    
    if let text = inputDict?["text"] as? String {
      input = Input(text: text)
    }
    
    if let contextDict = inputDict?["context"] as? [String : Any] {
      let json = RestKit.JSON(dictionary: contextDict)
      do{
        context = try Context(json: json)
      }
      catch {
        reject(nil, nil, error)
        return
      }
    }
    
    let request = MessageRequest(input: input, context: context)
    
    conversation?.message(withWorkspace: workspaceID, request: request, failure: failure ) { response in
      resolve(response.toDictionary())
    }
  }
}


// Mappings

/////////////////////////////////////////////////////////////////////////////////
// ConversationV1
/////////////////////////////////////////////////////////////////////////////////

extension ConversationV1.MessageResponse : Serializable {
  var properties: Array<String> {
    return ["input", "alternateIntents", "context", "entities", "intents", "output"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "input":
      return input
    case "alternateIntents":
      return alternateIntents
    case "context":
      return context
    case "entities":
      return entities
    case "intents":
      return intents
    case "output":
      return output
    default:
      return nil
    }
  }
}

extension ConversationV1.Input : Serializable {
  var properties: Array<String> {
    return ["text"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    default:
      return nil
    }
  }
}

extension ConversationV1.Context : Serializable {
  var properties: Array<String> {
    return ["conversationID", "system", ]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "conversationID":
      return conversationID
    case "system":
      return system
    default:
      return nil
    }
  }
}

extension ConversationV1.System : Serializable {
  var properties: Array<String> {
    return ["dialogStack", "dialogTurnCounter", "dialogRequestCounter"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "dialogStack":
      return dialogStack
    case "dialogTurnCounter":
      return dialogTurnCounter
    case "dialogRequestCounter":
      return dialogRequestCounter
    default:
      return nil
    }
  }
}

extension ConversationV1.Entity : Serializable {
  var properties: Array<String> {
    return ["entity", "startIndex", "endIndex", "value"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "entity":
      return entity
    case "startIndex":
      return startIndex
    case "endIndex":
      return endIndex
    case "value":
      return value
    default:
      return nil
    }
  }
}

extension ConversationV1.Intent : Serializable {
  var properties: Array<String> {
    return ["intent", "confidence"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "intent":
      return intent
    case "confidence":
      return confidence
    default:
      return nil
    }
  }
}

extension ConversationV1.Output : Serializable {
  var properties: Array<String> {
    return ["logMessages", "text", "nodesVisited"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "logMessages":
      return logMessages
    case "text":
      return text
    case "nodesVisited":
      return nodesVisited
    default:
      return nil
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// NaturalLanguageUnderstandingV1
/////////////////////////////////////////////////////////////////////////////////
extension NaturalLanguageUnderstandingV1.AnalysisResults : Serializable {
  var properties: Array<String> {
    return ["language", "analyzedText", "retrievedUrl", "concepts", "entities", "keywords", "categories", "emotion", "metadata", "relations", "semanticRoles", "sentiment"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "language":
      return language
    case "analyzedText":
      return analyzedText
    case "retrievedUrl":
      return retrievedUrl
    case "concepts":
      return concepts
    case "entities":
      return entities
    case "keywords":
      return keywords
    case "categories":
      return categories
    case "emotion":
      return emotion
    case "metadata":
      return metadata
    case "relations":
      return relations
    case "semanticRoles":
      return semanticRoles
    case "sentiment":
      return sentiment
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.Author : Serializable {
  var properties: Array<String> {
    return ["name"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "name":
      return name
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.CategoriesOptions : Serializable {
  var properties: Array<String> {
    return ["json"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "json":
      return json
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.CategoriesResult : Serializable {
  var properties: Array<String> {
    return ["label", "score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "label":
      return label
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.ConceptsOptions : Serializable {
  var properties: Array<String> {
    return ["limit", "linkedData"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "limit":
      return limit
    case "linkedData":
      return linkedData
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.ConceptsResult : Serializable {
  var properties: Array<String> {
    return ["name", "relevance", "dbpediaResource"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "name":
      return name
    case "relevance":
      return relevance
    case "dbpediaResource":
      return dbpediaResource
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.DocumentEmotionResults : Serializable {
  var properties: Array<String> {
    return ["emotion"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "emotion":
      return emotion
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.DocumentSentimentResults : Serializable {
  var properties: Array<String> {
    return ["score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.EmotionOptions : Serializable {
  var properties: Array<String> {
    return ["document", "targets"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "document":
      return document
    case "targets":
      return targets
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.EmotionResult : Serializable {
  var properties: Array<String> {
    return ["document", "targets"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "document":
      return document
    case "targets":
      return targets
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.EmotionScores : Serializable {
  var properties: Array<String> {
    return ["anger", "disgust", "fear", "joy", "sadness"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "anger":
      return anger
    case "disgust":
      return disgust
    case "fear":
      return fear
    case "joy":
      return joy
    case "sadness":
      return sadness
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.EntitiesOptions : Serializable {
  var properties: Array<String> {
    return ["limit", "model", "disambiguation", "sentiment"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "limit":
      return limit
    case "model":
      return model
    case "disambiguation":
      return disambiguation
    case "sentiment":
      return sentiment
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.EntitiesResult : Serializable {
  var properties: Array<String> {
    return ["type", "relevance", "count", "text", "sentiment"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "type":
      return type
    case "relevance":
      return relevance
    case "count":
      return count
    case "text":
      return text
    case "sentiment":
      return sentiment
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.EntitiesResult.EntitySentiment : Serializable {
  var properties: Array<String> {
    return ["score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.Features : Serializable {
  var properties: Array<String> {
    return ["concepts", "emotion", "entities", "keywords", "metadata", "relations", "semanticRoles", "sentiment", "categories"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "concepts":
      return concepts
    case "emotion":
      return emotion
    case "entities":
      return entities
    case "keywords":
      return keywords
    case "metadata":
      return metadata
    case "relations":
      return relations
    case "semanticRoles":
      return semanticRoles
    case "sentiment":
      return sentiment
    case "categories":
      return categories
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.KeywordsOptions : Serializable {
  var properties: Array<String> {
    return ["limit", "sentiment"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "limit":
      return limit
    case "sentiment":
      return sentiment
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.KeywordsResult : Serializable {
  var properties: Array<String> {
    return ["relevance", "text", "sentiment"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "relevance":
      return relevance
    case "text":
      return text
    case "sentiment":
      return sentiment
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.KeywordsResult.KeywordSentiment : Serializable {
  var properties: Array<String> {
    return ["score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.MetadataOptions : Serializable {
  var properties: Array<String> {
    return ["json"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "json":
      return json
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.MetadataResult : Serializable {
  var properties: Array<String> {
    return ["authors", "publicationDate", "title"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "authors":
      return authors
    case "publicationDate":
      return publicationDate
    case "title":
      return title
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.NaturalLanguageUnderstanding : Serializable {
  var properties: Array<String> {
    return ["serviceURL", "defaultHeaders"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "serviceURL":
      return serviceURL
    case "defaultHeaders":
      return defaultHeaders
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.Parameters : Serializable {
  var properties: Array<String> {
    return ["text", "html", "features", "clean", "xpath", "fallbackToRaw", "returnAnalyzedText", "language"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "html":
      return html
    case "features":
      return features
    case "clean":
      return clean
    case "xpath":
      return xpath
    case "fallbackToRaw":
      return fallbackToRaw
    case "returnAnalyzedText":
      return returnAnalyzedText
    case "language":
      return language
      
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.RelationArgument : Serializable {
  var properties: Array<String> {
    return ["entities", "text"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "entities":
      return entities
    case "text":
      return text
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.RelationEntity : Serializable {
  var properties: Array<String> {
    return ["text", "type"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "type":
      return type
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.RelationsOptions : Serializable {
  var properties: Array<String> {
    return ["model"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "model":
      return model
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.RelationsResult : Serializable {
  var properties: Array<String> {
    return ["score", "sentence", "type", "arguments"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "score":
      return score
    case "sentence":
      return sentence
    case "type":
      return type
    case "arguments":
      return arguments
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesAction : Serializable {
  var properties: Array<String> {
    return ["text", "normalized", "verb"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "normalized":
      return normalized
    case "verb":
      return verb
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesAction.SemanticRolesVerb : Serializable {
  var properties: Array<String> {
    return ["text", "tense"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "tense":
      return tense
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesKeyword : Serializable {
  var properties: Array<String> {
    return ["text"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesObject : Serializable {
  var properties: Array<String> {
    return ["text", "keywords"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "keywords":
      return keywords
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesOptions : Serializable {
  var properties: Array<String> {
    return ["limit", "keywords", "entities", "requireEntities", "disambiguate"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "limit":
      return limit
    case "keywords":
      return keywords
    case "entities":
      return entities
    case "requireEntities":
      return requireEntities
    case "disambiguate":
      return disambiguate
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesResult : Serializable {
  var properties: Array<String> {
    return ["sentence", "subject", "action", "object"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "sentence":
      return sentence
    case "subject":
      return subject
    case "action":
      return action
    case "object":
      return object
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesSubject : Serializable {
  var properties: Array<String> {
    return ["text", "entities", "keywords"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "entities":
      return entities
    case "keywords":
      return keywords
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SemanticRolesSubject.SemanticRolesEntity : Serializable {
  var properties: Array<String> {
    return ["type", "text"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "type":
      return type
    case "text":
      return text
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SentimentOptions : Serializable {
  var properties: Array<String> {
    return ["document", "targets"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "document":
      return document
    case "targets":
      return targets
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.SentimentResult : Serializable {
  var properties: Array<String> {
    return ["document", "targets"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "document":
      return document
    case "targets":
      return targets
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.TargetedEmotionResults : Serializable {
  var properties: Array<String> {
    return ["text", "emotion"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "emotion":
      return emotion
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.TargetedSentimentResults : Serializable {
  var properties: Array<String> {
    return ["text", "score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension NaturalLanguageUnderstandingV1.Usage : Serializable {
  var properties: Array<String> {
    return ["features"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "features":
      return features
    default:
      return nil
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// AlchemyDataNewsV1
/////////////////////////////////////////////////////////////////////////////////

extension AlchemyDataNewsV1.Action : Serializable {
  var properties: Array<String> {
    return ["text", "lemmatized", "verb", "object"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "lemmatized":
      return lemmatized
    case "verb":
      return verb
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Action.Verb : Serializable {
  var properties: Array<String> {
    return ["text", "tense", "negated"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "tense":
      return tense
    case "negated":
      return negated
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Concept : Serializable {
  var properties: Array<String> {
    return ["text", "relevance", "knowledgeGraph", "website", "geo", "dbpedia", "yago", "opencyc", "freebase", "ciaFactbook", "census", "geonames", "musicBrainz", "crunchbase"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "relevance":
      return relevance
    case "knowledgeGraph":
      return knowledgeGraph
    case "website":
      return website
    case "geo":
      return geo
    case "dbpedia":
      return dbpedia
    case "yago":
      return yago
    case "opencyc":
      return opencyc
    case "freebase":
      return freebase
    case "ciaFactbook":
      return ciaFactbook
    case "census":
      return census
    case "geonames":
      return geonames
    case "musicBrainz":
      return musicBrainz
    case "crunchbase":
      return crunchbase
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.DisambiguatedLinks : Serializable {
  var properties: Array<String> {
    return ["language", "url", "census", "ciaFactbook", "crunchbase", "dbpedia", "freebase", "geo", "geonames", "musicBrainz", "name", "opencyc", "subType", "umbel", "website", "yago"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "language":
      return language
    case "url":
      return url
    case "census":
      return census
    case "ciaFactbook":
      return ciaFactbook
    case "crunchbase":
      return crunchbase
    case "dbpedia":
      return dbpedia
    case "freebase":
      return freebase
    case "geo":
      return geo
    case "geonames":
      return geonames
    case "musicBrainz":
      return musicBrainz
    case "name":
      return name
    case "opencyc":
      return opencyc
    case "subType":
      return subType
    case "umbel":
      return umbel
    case "website":
      return website
    case "yago":
      return yago
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Document : Serializable {
  var properties: Array<String> {
    return ["id", "source", "timestamp"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "id":
      return id
    case "source":
      return source
    case "timestamp":
      return timestamp
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.DocumentEnriched : Serializable {
  var properties: Array<String> {
    return ["url"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "url":
      return url
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.DocumentSource : Serializable {
  var properties: Array<String> {
    return ["enriched"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "enriched":
      return enriched
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.DocumentUrl : Serializable {
  var properties: Array<String> {
    return ["title", "url", "author", "entities", "relations", "taxonomy", "sentiment", "keywords", "concepts", "enrichedTitle", "image", "imageKeywords", "feeds", "cleanedTitle", "publicationDate", "text"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "title":
      return title
    case "url":
      return url
    case "author":
      return author
    case "entities":
      return entities
    case "relations":
      return relations
    case "taxonomy":
      return taxonomy
    case "sentiment":
      return sentiment
    case "keywords":
      return keywords
    case "concepts":
      return concepts
    case "enrichedTitle":
      return enrichedTitle
    case "image":
      return image
    case "imageKeywords":
      return imageKeywords
    case "feeds":
      return feeds
    case "cleanedTitle":
      return cleanedTitle
    case "publicationDate":
      return publicationDate
    case "text":
      return text
    default:
      return nil
    }
  }
}


extension AlchemyDataNewsV1.EnrichedTitle : Serializable {
  var properties: Array<String> {
    return ["entities", "relations", "taxonomy", "sentiment", "keywords", "concepts"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "entities":
      return entities
    case "relations":
      return relations
    case "taxonomy":
      return taxonomy
    case "sentiment":
      return sentiment
    case "keywords":
      return keywords
    case "concepts":
      return concepts
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Entity : Serializable {
  var properties: Array<String> {
    return ["count", "disambiguated", "knowledgeGraph", "quotations", "relevance", "sentiment", "text", "type"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "count":
      return count
    case "disambiguated":
      return disambiguated
    case "knowledgeGraph":
      return knowledgeGraph
    case "quotations":
      return quotations
    case "relevance":
      return relevance
    case "sentiment":
      return sentiment
    case "text":
      return text
    case "type":
      return type
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Feed : Serializable {
  var properties: Array<String> {
    return ["feed"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "feed":
      return feed
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.ImageKeyword : Serializable {
  var properties: Array<String> {
    return ["text", "score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Keyword : Serializable {
  var properties: Array<String> {
    return ["knowledgeGraph", "relevance", "sentiment", "text"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "knowledgeGraph":
      return knowledgeGraph
    case "relevance":
      return relevance
    case "sentiment":
      return sentiment
    case "text":
      return text
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.KnowledgeGraph : Serializable {
  var properties: Array<String> {
    return ["typeHierarchy"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "typeHierarchy":
      return typeHierarchy
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.NewsResponse : Serializable {
  var properties: Array<String> {
    return ["totalTransactions", "result"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "totalTransactions":
      return totalTransactions
    case "result":
      return result
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.NewsResult : Serializable {
  var properties: Array<String> {
    return ["docs", "next", "count", "slices"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "docs":
      return docs
    case "next":
      return next
    case "count":
      return count
    case "slices":
      return slices
    default:
      return nil
    }
  }
}


extension AlchemyDataNewsV1.PublicationDate : Serializable {
  var properties: Array<String> {
    return ["confident", "date"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "confident":
      return confident
    case "date":
      return date
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Quotation : Serializable {
  var properties: Array<String> {
    return ["quotation",]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "quotation":
      return quotation
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.RelationObject : Serializable {
  var properties: Array<String> {
    return ["text", "sentiment", "sentimentFromSubject", "entity"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "sentiment":
      return sentiment
    case "sentimentFromSubject":
      return sentimentFromSubject
    case "entity":
      return entity
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.SAORelation : Serializable {
  var properties: Array<String> {
    return ["action", "sentence", "subject", "object"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "action":
      return action
    case "sentence":
      return sentence
    case "subject":
      return subject
    case "object":
      return object
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Sentiment : Serializable {
  var properties: Array<String> {
    return ["mixed", "score", "type"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "mixed":
      return mixed
    case "score":
      return score
    case "type":
      return type
    default:
      return nil
    }
  }
}

extension AlchemyDataNewsV1.Subject : Serializable {
  var properties: Array<String> {
    return ["text", "sentiment", "verb"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "text":
      return text
    case "sentiment":
      return sentiment
    case "verb":
      return entity
    default:
      return nil
    }
  }
}



extension AlchemyDataNewsV1.Taxonomy : Serializable {
  var properties: Array<String> {
    return ["confident", "label", "score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "confident":
      return confident
    case "label":
      return label
    case "score":
      return score
    default:
      return nil
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// !AlchemyDataNewsV1
/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////
// VisualRecognitionV3
/////////////////////////////////////////////////////////////////////////////////

extension VisualRecognitionV3.ClassifiedImages : Serializable {
  var properties: Array<String> {
    return ["images", "warnings"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "images":
      return images
    case "warnings":
      return warnings
    default:
      return nil
    }
  }
}

extension VisualRecognitionV3.ClassifiedImage : Serializable {
  var properties: Array<String> {
    return ["sourceURL", "resolvedURL", "image", "error", "classifiers"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "sourceURL":
      return sourceURL
    case "resolvedURL":
      return resolvedURL
    case "image":
      return image
    case "error":
      return error
    case "classifiers":
      return classifiers
    default:
      return nil
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// !VisualRecognitionV3
/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////
// ToneAnalyzerV3
/////////////////////////////////////////////////////////////////////////////////

extension ToneAnalyzerV3.ToneAnalysis : Serializable {
  var properties: Array<String> {
    return ["documentTone", "sentencesTones"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "documentTone":
      return documentTone
    case "sentencesTones":
      return sentencesTones
    default:
      return nil
    }
  }
}

extension ToneAnalyzerV3.ToneCategory : Serializable {
  var properties: Array<String> {
    return ["name", "categoryID", "tones"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "name":
      return name
    case "categoryID":
      return categoryID
    case "tones":
      return tones
    default:
      return nil
    }
  }
}

extension ToneAnalyzerV3.ToneScore : Serializable {
  var properties: Array<String> {
    return ["id", "name", "score"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "id":
      return id
    case "name":
      return name
    case "score":
      return score
    default:
      return nil
    }
  }
}

extension ToneAnalyzerV3.SentenceAnalysis : Serializable {
  var properties: Array<String> {
    return ["sentenceID", "inputFrom", "inputTo", "text", "toneCategories"]
  }
  
  func valueForKey(key: String) -> Any? {
    switch key {
    case "sentenceID":
      return sentenceID
    case "inputFrom":
      return inputFrom
    case "inputTo":
      return inputTo
    case "text":
      return text
    case "toneCategories":
      return toneCategories
    default:
      return nil
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// !ToneAnalyzerV3
/////////////////////////////////////////////////////////////////////////////////

protocol Serializable {
  var properties:Array<String> { get }
  func valueForKey(key: String) -> Any?
  func toDictionary() -> [String:Any]
}

extension Serializable {
  func toDictionary() -> [String:Any] {
    var dict:[String:Any] = [:]
    
    for prop in self.properties {
      if let val = self.valueForKey(key: prop) as? String {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Int {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Double {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Array<String> {
        dict[prop] = val
      } else if let val = self.valueForKey(key: prop) as? Serializable {
        dict[prop] = val.toDictionary()
      } else if let val = self.valueForKey(key: prop) as? Array<Serializable> {
        var arr = Array<[String:Any]>()
        
        for item in (val as Array<Serializable>) {
          arr.append(item.toDictionary())
        }
        
        dict[prop] = arr
      }
    }
    
    return dict
  }
}




