/*
 * CaptureOne.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class CaptureOneApplication, CaptureOneWindow, CaptureOneApplication, CaptureOneDocument, CaptureOneToolbarItem, CaptureOneToolTab, CaptureOneTool, CaptureOneCamera, CaptureOneControlDevice, CaptureOneFocusMeter, CaptureOneAttribute, CaptureOneCollection, CaptureOneRecipe, CaptureOneWatermark, CaptureOneJob, CaptureOneKeywordLibrary, CaptureOneKeyword, CaptureOneUserCropAspectRatio, CaptureOneReadout, CaptureOneLayer, CaptureOneLumaRangeSettings, CaptureOneVariant, CaptureOneLensCorrectionSettings, CaptureOneCurve, CaptureOneCurvePoint, CaptureOneAdjustmentSettings, CaptureOneColorEditorOptions, CaptureOneToolsConfiguration, CaptureOneViewerConfiguration, CaptureOneBrowserConfiguration, CaptureOneImportOptions, CaptureOneExportOriginalOptions, CaptureOneOutputEvent, CaptureOneImage, CaptureOneBatchRenameOptions, CaptureOneNextCaptureOptions, CaptureOneServerOptions, CaptureOneOverlayOptions, CaptureOneClientViewer, CaptureOneGridOptions, CaptureOneGuideOptions, CaptureOneGuide;

enum CaptureOneNextcaptureadjustments {
	CaptureOneNextcaptureadjustmentsDefault = 'NCda',
	CaptureOneNextcaptureadjustmentsLast = 'NCla',
	CaptureOneNextcaptureadjustmentsPrimary = 'NCpa',
	CaptureOneNextcaptureadjustmentsUsingClipboard = 'NCuc',
	CaptureOneNextcaptureadjustmentsLastWithVariants = 'Nlwv',
	CaptureOneNextcaptureadjustmentsPrimaryWithVariants = 'Npwv'
};
typedef enum CaptureOneNextcaptureadjustments CaptureOneNextcaptureadjustments;

enum CaptureOneShutterlatency {
	CaptureOneShutterlatencyNormalLatency = 'SLNo' /* Normal(Long) Shutter Latency */,
	CaptureOneShutterlatencyZeroLatency = 'SLZe' /* Zero(Short) Shutter Latency */,
	CaptureOneShutterlatencyUnknownLatency = 'SLUn' /* Unknown Shutter Latency - may not be supported */
};
typedef enum CaptureOneShutterlatency CaptureOneShutterlatency;

enum CaptureOneCompareModes {
	CaptureOneCompareModesDisplayBefore = 'COaf' /* Display the image without adjustments (Full View) */,
	CaptureOneCompareModesDisplaySplit = 'CObf' /* Display the image without adjustments (Split View Slider) */
};
typedef enum CaptureOneCompareModes CaptureOneCompareModes;

enum CaptureOneDocumentType {
	CaptureOneDocumentTypeSession = 'COsd' /* Session document. */,
	CaptureOneDocumentTypeCatalog = 'COct' /* Catalog document. */
};
typedef enum CaptureOneDocumentType CaptureOneDocumentType;

enum CaptureOneToolbarDisplayMode {
	CaptureOneToolbarDisplayModeOff = 'CTdo',
	CaptureOneToolbarDisplayModeIconAndText = 'CTit',
	CaptureOneToolbarDisplayModeIconOnly = 'CTio'
};
typedef enum CaptureOneToolbarDisplayMode CaptureOneToolbarDisplayMode;

enum CaptureOneAutoSelectMode {
	CaptureOneAutoSelectModeDisabled = 'CSnv',
	CaptureOneAutoSelectModeImmediately = 'CSim',
	CaptureOneAutoSelectModeWhenReady = 'CSwr'
};
typedef enum CaptureOneAutoSelectMode CaptureOneAutoSelectMode;

enum CaptureOneAttributeUserLevel {
	CaptureOneAttributeUserLevelBasic = 'alba',
	CaptureOneAttributeUserLevelAdvanced = 'alad',
	CaptureOneAttributeUserLevelDeveloper = 'alde'
};
typedef enum CaptureOneAttributeUserLevel CaptureOneAttributeUserLevel;

enum CaptureOneOpenCLStatus {
	CaptureOneOpenCLStatusNever = 'COpn',
	CaptureOneOpenCLStatusAuto = 'COpa'
};
typedef enum CaptureOneOpenCLStatus CaptureOneOpenCLStatus;

// Status for the currently selected camera.
enum CaptureOneLiveViewStatus {
	CaptureOneLiveViewStatusClosed = 'CLof',
	CaptureOneLiveViewStatusRunning = 'CLon',
	CaptureOneLiveViewStatusPaused = 'CLpa'
};
typedef enum CaptureOneLiveViewStatus CaptureOneLiveViewStatus;

enum CaptureOneCollectionType {
	CaptureOneCollectionTypeFavorite = 'CCfv',
	CaptureOneCollectionTypeCatalogFolder = 'CCff',
	CaptureOneCollectionTypeAlbum = 'CCal',
	CaptureOneCollectionTypeGroup = 'CCgp',
	CaptureOneCollectionTypeProject = 'CCpj',
	CaptureOneCollectionTypeSmartAlbum = 'CCsm'
};
typedef enum CaptureOneCollectionType CaptureOneCollectionType;

enum CaptureOneSortOrder {
	CaptureOneSortOrderByName = 'CEnm',
	CaptureOneSortOrderByDate = 'CEdt',
	CaptureOneSortOrderByRating = 'CErt',
	CaptureOneSortOrderByColorTag = 'CEtg',
	CaptureOneSortOrderByCameraLens = 'CEln',
	CaptureOneSortOrderByISO = 'CEis',
	CaptureOneSortOrderByFocalLength = 'CEfl',
	CaptureOneSortOrderByWidth = 'CEwi',
	CaptureOneSortOrderByHeight = 'CEht',
	CaptureOneSortOrderByFileSize = 'CEfs',
	CaptureOneSortOrderByProcessedState = 'CEps',
	CaptureOneSortOrderByAperture = 'CEap',
	CaptureOneSortOrderByShutterSpeed = 'CEss',
	CaptureOneSortOrderByExtension = 'CEex',
	CaptureOneSortOrderBySequenceID = 'CEsi',
	CaptureOneSortOrderByManual = 'CEmn'
};
typedef enum CaptureOneSortOrder CaptureOneSortOrder;

enum CaptureOneRecipeFileFormat {
	CaptureOneRecipeFileFormatJPEG = 'Rjpg',
	CaptureOneRecipeFileFormatJPEG_QuickProof = 'Rjqp',
	CaptureOneRecipeFileFormatJPEG_XR = 'Rjxr',
	CaptureOneRecipeFileFormatJPEG_2000 = 'Rj2K',
	CaptureOneRecipeFileFormatTIFF = 'Rtif',
	CaptureOneRecipeFileFormatDNG = 'Rdng',
	CaptureOneRecipeFileFormatPNG = 'Rpng',
	CaptureOneRecipeFileFormatPSD = 'Rpsd',
	CaptureOneRecipeFileFormatPSB = 'Rpsb',
	CaptureOneRecipeFileFormatAffinity = 'Raff',
	CaptureOneRecipeFileFormatOriginal = 'Rorg'
};
typedef enum CaptureOneRecipeFileFormat CaptureOneRecipeFileFormat;

enum CaptureOneTiffCompress {
	CaptureOneTiffCompressUncompressed = 'Rtno',
	CaptureOneTiffCompressLZW = 'Rtlz',
	CaptureOneTiffCompressZIP = 'Rtzp'
};
typedef enum CaptureOneTiffCompress CaptureOneTiffCompress;

enum CaptureOneScalingType {
	CaptureOneScalingTypeFixed = 'Rsfx',
	CaptureOneScalingTypeWidth_Scaling = 'Rswd',
	CaptureOneScalingTypeHeight_Scaling = 'Rsht',
	CaptureOneScalingTypeBoundingDimensions = 'Rsdm',
	CaptureOneScalingTypeWidth_by_Height = 'Rswh',
	CaptureOneScalingTypeLong_Edge = 'Rsle',
	CaptureOneScalingTypeShort_Edge = 'Rsse'
};
typedef enum CaptureOneScalingType CaptureOneScalingType;

enum CaptureOneMeasurementUnit {
	CaptureOneMeasurementUnitPixels = 'MUpx',
	CaptureOneMeasurementUnitInches = 'MUin',
	CaptureOneMeasurementUnitMillimeters = 'MUmm',
	CaptureOneMeasurementUnitCentimeters = 'MUcm',
	CaptureOneMeasurementUnitPercent = 'MUpr'
};
typedef enum CaptureOneMeasurementUnit CaptureOneMeasurementUnit;

enum CaptureOneRecipeRootType {
	CaptureOneRecipeRootTypeOutputLocation = 'Rrof',
	CaptureOneRecipeRootTypeImageFolder = 'Rrif',
	CaptureOneRecipeRootTypeCustomLocation = 'Rrcu'
};
typedef enum CaptureOneRecipeRootType CaptureOneRecipeRootType;

enum CaptureOneExportCropMethod {
	CaptureOneExportCropMethodRespect = 'Rxcd',
	CaptureOneExportCropMethodIgnore = 'Rxci',
	CaptureOneExportCropMethodCropToPath = 'Rxcp'
};
typedef enum CaptureOneExportCropMethod CaptureOneExportCropMethod;

enum CaptureOneSharpeningType {
	CaptureOneSharpeningTypeNoOutputSharpening = 'Rsno',
	CaptureOneSharpeningTypeForScreen = 'Rssc',
	CaptureOneSharpeningTypeForPrint = 'Rspr',
	CaptureOneSharpeningTypeDisableAll = 'Rsda'
};
typedef enum CaptureOneSharpeningType CaptureOneSharpeningType;

enum CaptureOneDistanceType {
	CaptureOneDistanceTypePercentOfDiagonal = 'Rdpd',
	CaptureOneDistanceTypeInches = 'Rdin',
	CaptureOneDistanceTypeCentimeters = 'Rdcm'
};
typedef enum CaptureOneDistanceType CaptureOneDistanceType;

enum CaptureOneExistingFilesBehavior {
	CaptureOneExistingFilesBehaviorAddSuffix = 'Rxsu',
	CaptureOneExistingFilesBehaviorOverwrite = 'Rxow',
	CaptureOneExistingFilesBehaviorSkip = 'Rxsk'
};
typedef enum CaptureOneExistingFilesBehavior CaptureOneExistingFilesBehavior;

enum CaptureOneWatermarkKind {
	CaptureOneWatermarkKindTextual = 'CRWt',
	CaptureOneWatermarkKindImagery = 'CRWi',
	CaptureOneWatermarkKindNone = 'CRWn'
};
typedef enum CaptureOneWatermarkKind CaptureOneWatermarkKind;

enum CaptureOneLayerType {
	CaptureOneLayerTypeAdjustment = 'CLnm',
	CaptureOneLayerTypeClone = 'CLcl',
	CaptureOneLayerTypeHeal = 'CLhl',
	CaptureOneLayerTypeBackground = 'CLbg'
};
typedef enum CaptureOneLayerType CaptureOneLayerType;

enum CaptureOneCropAspectRatioOrientation {
	CaptureOneCropAspectRatioOrientationLandscape = 'CVol',
	CaptureOneCropAspectRatioOrientationPortrait = 'CVop',
	CaptureOneCropAspectRatioOrientationSquare = 'CVos'
};
typedef enum CaptureOneCropAspectRatioOrientation CaptureOneCropAspectRatioOrientation;

enum CaptureOneTechnicalProcessingMode {
	CaptureOneTechnicalProcessingModePhotography = 'Pmph',
	CaptureOneTechnicalProcessingModeFilmNegative = 'Pmfm',
	CaptureOneTechnicalProcessingModeReproNegative = 'Pmrn',
	CaptureOneTechnicalProcessingModeReproPositive = 'Pmrp'
};
typedef enum CaptureOneTechnicalProcessingMode CaptureOneTechnicalProcessingMode;

enum CaptureOneFlipType {
	CaptureOneFlipTypeNone = 'Cfln',
	CaptureOneFlipTypeHorizontal = 'Cflh',
	CaptureOneFlipTypeVertical = 'Cflv'
};
typedef enum CaptureOneFlipType CaptureOneFlipType;

enum CaptureOneClarityMethod {
	CaptureOneClarityMethodNatural = 'Ccln',
	CaptureOneClarityMethodPunch = 'Cclp',
	CaptureOneClarityMethodNeutral = 'Cclt',
	CaptureOneClarityMethodClassic = 'Cclc'
};
typedef enum CaptureOneClarityMethod CaptureOneClarityMethod;

enum CaptureOneGrainType {
	CaptureOneGrainTypeFine = 'Cgtf',
	CaptureOneGrainTypeSilverRich = 'Cgts',
	CaptureOneGrainTypeSoft = 'Cgto',
	CaptureOneGrainTypeCubic = 'Cgtc',
	CaptureOneGrainTypeTabular = 'Cgtt',
	CaptureOneGrainTypeHarsh = 'Cgth'
};
typedef enum CaptureOneGrainType CaptureOneGrainType;

enum CaptureOneVignetteMethod {
	CaptureOneVignetteMethodEllipticOnCrop = 'Cvml',
	CaptureOneVignetteMethodCircularOnCrop = 'CvmO',
	CaptureOneVignetteMethodCircular = 'Cvmc'
};
typedef enum CaptureOneVignetteMethod CaptureOneVignetteMethod;

enum CaptureOneToolPlacement {
	CaptureOneToolPlacementLeft = 'CElt',
	CaptureOneToolPlacementRight = 'CErg'
};
typedef enum CaptureOneToolPlacement CaptureOneToolPlacement;

enum CaptureOneBrowserMode {
	CaptureOneBrowserModeGrid = 'Cbeg',
	CaptureOneBrowserModeList = 'Cbel',
	CaptureOneBrowserModeFilmstrip = 'Cbef'
};
typedef enum CaptureOneBrowserMode CaptureOneBrowserMode;

enum CaptureOneBrowserPlacement {
	CaptureOneBrowserPlacementLeft = 'CElt',
	CaptureOneBrowserPlacementRight = 'CErg',
	CaptureOneBrowserPlacementBottom = 'CEbt'
};
typedef enum CaptureOneBrowserPlacement CaptureOneBrowserPlacement;

enum CaptureOneBrowserLabel {
	CaptureOneBrowserLabelOff = 'Coff',
	CaptureOneBrowserLabelEdit = 'Cedt',
	CaptureOneBrowserLabelStatus = 'Cstt'
};
typedef enum CaptureOneBrowserLabel CaptureOneBrowserLabel;

enum CaptureOneImportDestinationType {
	CaptureOneImportDestinationTypeCaptureFolder = 'Cicf',
	CaptureOneImportDestinationTypeSessionFolder = 'Cisf',
	CaptureOneImportDestinationTypeSelectedFolder = 'Cise',
	CaptureOneImportDestinationTypeCurrentLocation = 'Cicl',
	CaptureOneImportDestinationTypeInsideCatalog = 'Ciic',
	CaptureOneImportDestinationTypeCustom = 'Cicu'
};
typedef enum CaptureOneImportDestinationType CaptureOneImportDestinationType;

enum CaptureOneImportDestinationCollection {
	CaptureOneImportDestinationCollectionRecent = 'Cicr',
	CaptureOneImportDestinationCollectionCaptureCollection = 'Cicc',
	CaptureOneImportDestinationCollectionSelectedAlbum = 'Cica'
};
typedef enum CaptureOneImportDestinationCollection CaptureOneImportDestinationCollection;

enum CaptureOneImportCollectionAction {
	CaptureOneImportCollectionActionNoAction = 'Cian',
	CaptureOneImportCollectionActionNotifyWhenDone = 'Ciad',
	CaptureOneImportCollectionActionOpenCollection = 'Cioc'
};
typedef enum CaptureOneImportCollectionAction CaptureOneImportCollectionAction;

enum CaptureOneNamingMethod {
	CaptureOneNamingMethodTextAndTokens = 'Crtt',
	CaptureOneNamingMethodFindAndReplace = 'Crfr'
};
typedef enum CaptureOneNamingMethod CaptureOneNamingMethod;

enum CaptureOneAdjustmentsSource {
	CaptureOneAdjustmentsSourceDefault = 'CNmd',
	CaptureOneAdjustmentsSourceCopyFromLast = 'CNcl',
	CaptureOneAdjustmentsSourceCopyFromPrimary = 'CNcp',
	CaptureOneAdjustmentsSourceCopyFromClipboard = 'CNcc',
	CaptureOneAdjustmentsSourceCopySpecificFromLast = 'CNsl',
	CaptureOneAdjustmentsSourceCopySpecificFromPrimary = 'CNsp',
	CaptureOneAdjustmentsSourceCopyVariantsFromLast = 'CNvl',
	CaptureOneAdjustmentsSourceCopyVariantsFromPrimary = 'CNvp',
	CaptureOneAdjustmentsSourceDocumentValues = 'CNdv'
};
typedef enum CaptureOneAdjustmentsSource CaptureOneAdjustmentsSource;

enum CaptureOneClientViewerMode {
	CaptureOneClientViewerModePin = 'CVpi',
	CaptureOneClientViewerModeSelection = 'CVse',
	CaptureOneClientViewerModeLastCapture = 'CVca',
	CaptureOneClientViewerModeInactive = 'CVno'
};
typedef enum CaptureOneClientViewerMode CaptureOneClientViewerMode;

enum CaptureOneGridType {
	CaptureOneGridTypeRectangular = 'CGre',
	CaptureOneGridTypeGoldenRatio = 'CGgr',
	CaptureOneGridTypeFibonacciSpiral = 'CGfs'
};
typedef enum CaptureOneGridType CaptureOneGridType;

enum CaptureOneEdgeType {
	CaptureOneEdgeTypeTop = 'CEtp',
	CaptureOneEdgeTypeLeft = 'CElt',
	CaptureOneEdgeTypeRight = 'CErg',
	CaptureOneEdgeTypeBottom = 'CEbt'
};
typedef enum CaptureOneEdgeType CaptureOneEdgeType;

enum CaptureOneSelectType {
	CaptureOneSelectTypeNextCollection = 'SNCo',
	CaptureOneSelectTypePreviousCollection = 'SPCo',
	CaptureOneSelectTypeNextSet = 'SNSe',
	CaptureOneSelectTypePreviousSet = 'SPSe',
	CaptureOneSelectTypeNextVariant = 'SNVa',
	CaptureOneSelectTypePreviousVariant = 'SPVa'
};
typedef enum CaptureOneSelectType CaptureOneSelectType;

@protocol CaptureOneGenericMethods

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface CaptureOneApplication : SBApplication

- (SBElementArray<CaptureOneWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (void) open:(NSArray<NSURL *> *)x;  // Open a document.
- (void) quit;  // Quit the application.
- (void) beginLiveView;  // Open Live View for the currently selected camera.
- (void) endLiveView;  // Close Live View for the currently selected camera.
- (void) migrate:(id)x;  // Migrate a Capture One document (if necessary) to the current format.
- (NSString *) process:(id)x recipe:(NSString *)recipe;  // (PRO Only) Process a variant, or the variants of a RAW file
- (void) capture;  // (PRO Only) Try to start capturing with the currently selected camera into the foreground document.  Follow with a delay command in order to allow the image to be fully captured before continuing in the same script.
- (void) applyWorkspace:(NSString *)x;  // Load and apply a workspace.
- (void) silentlyQuit;  // Quit silently by automatically terminating any current activities (e.g. importing, exporting, Live View) and skipping any backup prompts that would normally appear.
- (void) reset:(id)x;  // Reset settings to defaults.
- (void) show:(id)x;  // Show this on any attached Live for Studio.

@end

// A window.
@interface CaptureOneWindow : SBObject <CaptureOneGenericMethods>

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) CaptureOneDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Capture One Suite
 */

// Capture One application class.  Directly contained image and variant elements are for the current collection of the current document.
@interface CaptureOneApplication (CaptureOneSuite)

- (SBElementArray<CaptureOneDocument *> *) documents;
- (SBElementArray<CaptureOneImage *> *) images;
- (SBElementArray<CaptureOneVariant *> *) variants;
- (SBElementArray<CaptureOneKeywordLibrary *> *) keywordLibraries;

@property (copy) CaptureOneDocument *currentDocument;  // (PRO Only) The currently frontmost document.
@property (copy) CaptureOneViewerConfiguration *viewer;  // The Viewer window's viewer settings.
@property NSInteger progressTotalUnits;  // Set this property to the total number of units of work your script will be performing. While this property is greater than the 'progress completed units' property, Capture One will display a progress window.
@property NSInteger progressCompletedUnits;  // Set this property to the number of units of work your script has performed.
@property (copy) NSString *progressText;  // Set this to a simple explanation of the work being performed. (optional)
@property (copy) NSString *progressAdditionalText;  // Set this to additional specifics of the work being performed. (optional)
@property (copy) id captureDoneScript;  // (PRO Only) The AppleScript that gets called when an image has completed being captured.
@property (copy) id processingDoneScript;  // (PRO Only) The AppleScript that gets called when a file is finished processing. The script is passed the identifier string of the finished batch job in argv 1, the original RAW file path in argv 2, and a list of the output file paths in argv 3.
@property (copy) id batchDoneScript;  // (PRO Only) The AppleScript that gets called when the batch process queue completes. The script is passed the list of output paths in argv.
@property (copy) id liveViewBecameReadyScript;  // (PRO Only) The AppleScript that gets called when Live View has become ready.
@property (copy) id liveViewWillCloseScript;  // (PRO Only) The AppleScript that gets called when Live View is about to close.
@property (copy) id liveViewDoneScript;  // (PRO Only) The AppleScript that gets called when Live View is closed.
@property (copy) id importingDoneScript;  // (PRO Only) The AppleScript that gets called when the importing queue completes.
@property (copy) id barcodeScannedScript;  // (Enterprise Only) The AppleScript that gets called when a barcode has been scanned.
@property (copy) id primaryVariantAdjustedScript;  // The AppleScript that gets called when the primary variant's adjustment settings have changed.
@property (copy) id selectionChangedScript;  // The AppleScript that gets called when the selected variants have changed.
@property BOOL rateAutoAdvance;  // If Capture One should automatically select the next image after an image's rating has been changed from the user interface.
@property BOOL tagAutoAdvance;  // If Capture One should automatically select the next image after an image's color tag has been changed from the user interface.
@property (copy, readonly) NSString *appVersion;  // The version of Capture One
@property (copy, readonly) CaptureOneVariant *primaryVariant;  // The primary selected variant
@property CaptureOneShutterlatency shutterLatency;  // (PRO Only) Choose the Shutter Latency Mode used when capturing. Only has an effect when a camera is connected.
@property CaptureOneOpenCLStatus processingAcceleration;  // When should hardware acceleration be used.
@property BOOL editAllSelectedVariants;  // Whether or not some UI actions (applying a style or preset, rating, color tagging, etc) are to be applied to all selected variants or only to the primary variant.  Note that this property has no effect on AppleScript, where variants must always be explicitly specified in all contexts.
@property CaptureOneLiveViewStatus liveViewStatus;  // Changing the status may require a delay before reading this property again to reflect the new status.
@property (copy, readonly) NSArray<NSString *> *availableStyles;  // The names of all styles and presets currently available.
@property BOOL compareEnabled;  // Enable/disable the Before/After.
@property CaptureOneCompareModes compareMode;  // Set/get the Before/After mode.

@end

// A Capture One document.  Directly contained image and variant elements are for the current collection.
@interface CaptureOneDocument : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneImage *> *) images;
- (SBElementArray<CaptureOneRecipe *> *) recipes;
- (SBElementArray<CaptureOneJob *> *) jobs;
- (SBElementArray<CaptureOneCollection *> *) collections;
- (SBElementArray<CaptureOneVariant *> *) variants;
- (SBElementArray<CaptureOneKeyword *> *) keywords;
- (SBElementArray<CaptureOneToolTab *> *) toolTabs;
- (SBElementArray<CaptureOneToolbarItem *> *) toolbarItems;
- (SBElementArray<CaptureOneClientViewer *> *) clientViewers;
- (SBElementArray<CaptureOneUserCropAspectRatio *> *) userCropAspectRatios;

@property (copy, readonly) NSString *name;  // The name of the document.
- (NSString *) id;  // The unique identifier of the document.
@property CaptureOneToolbarDisplayMode windowToolbarMode;
@property (copy) CaptureOneCollection *currentCollection;  // The current collection.
@property (copy) CaptureOneRecipe *currentRecipe;  // The currently selected recipe.
@property BOOL showEnabledRecipesOnly;  // If the document's 'Process Recipes' tool should only be showing recipes that are enabled.  This property does *not* affect the availability of recipe elements via AppleScript.
- (NSString *) template;  // The template name to use (during 'make new' only)
@property (copy, readonly) id path;  // The folder item containing the document.
@property (copy, readonly) NSURL *folder;  // The folder item of the document.
@property (readonly) CaptureOneDocumentType kind;  // The kind of document.
@property (copy) NSArray<NSString *> *filters;  // The current filters being used.  Set to an empty list {} to clear the filters.
@property (copy, readonly) NSArray<NSString *> *availableFilters;  // The filters currently available to be used in this document.
@property (copy) id output;  // The Output folder item.
@property (copy) NSString *outputJobNameToken;  // The Cross Recipe Job Name token contents - with inner tokens in brackets e.g. [Rating].
@property (copy) NSString *outputSubfolderToken;  // The Cross Recipe Job Name token contents - with inner tokens in brackets e.g. [Rating].
@property NSInteger outputCounter;
@property NSInteger outputCounterIncrement;
@property (copy) id captures;  // The Capture folder item.
@property (copy) id selects;  // The Selects folder item (Session only).
@property (copy) id trash;  // The Trash folder item (Session only).
@property (copy) NSString *barcode;  // (Enterprise Only) The current scanned barcode value.
@property (copy) NSString *cropAspectRatio;  // The current general crop aspect ratio.  To access all available crop aspect ratios or to affect a specific variant, see variant properties.
@property BOOL processingQueueEnabled;  // Whether or not the output processing batch job queue is running.  Can be changed.
@property (copy) CaptureOneWindow *documentWindow;  // The document's associated window.
@property (copy) CaptureOneToolsConfiguration *toolSettings;  // The document's tool settings.  See also the document's “tool tab” elements for specific tab and tool configuration.
@property (copy) CaptureOneViewerConfiguration *viewer;  // The document's viewer settings.  Note that any changes to one document's viewer will affect all document viewers.
@property (copy) CaptureOneBrowserConfiguration *browser;  // The document's browser settings.
@property NSInteger captureCounter;
@property NSInteger captureCounterIncrement;
@property (copy) NSString *captureNameFormat;  // The current next capture naming format, with tokens in brackets e.g. [Rating].
@property (copy) NSString *captureName;  // The current next capture name.
@property (copy, readonly) NSURL *lastCapturedFile;  // The last captured image file.
@property (copy) NSColor *normalizeTargetColor;  // The target color for applying normalizations, using the Generic RGB profile.
@property (copy, readonly) CaptureOneCamera *camera;  // The selected camera.
@property (copy, readonly) NSArray<NSString *> *availableCameraIdentifiers;  // The identifiers of all tethered cameras, for use with the 'select camera' command.
@property CaptureOneAutoSelectMode autoSelectNewCapture;
@property BOOL autoSelectNewCapturePause;
@property (copy) NSString *workspaceLockPIN;  // (Studio Only)
@property (copy, readonly) CaptureOneControlDevice *copyStand NS_RETURNS_NOT_RETAINED;  // (CH Only) The attached column control copy stand device.
@property (copy) CaptureOneBatchRenameOptions *batchRenameSettings;  // The document's batch rename settings.
@property (copy) CaptureOneImportOptions *importSettings;  // The document's import settings.
@property (copy) CaptureOneExportOriginalOptions *exportOriginalSettings;  // The document's export original settings.
@property (copy) CaptureOneNextCaptureOptions *nextCaptureSettings;  // What settings and adjustments are applied when an image is captured from a tethered camera.
@property (copy) CaptureOneOverlayOptions *overlaySettings;  // The document's overlay settings.
@property (copy) CaptureOneServerOptions *serverSettings;  // The document's Capture Pilot server settings.
@property (copy, readonly) CaptureOneVariant *servedVariant;  // (Studio Only) The variant most recently viewed from Capture Pilot.
@property (copy) CaptureOneGridOptions *gridSettings;  // The document's grid settings.
@property (copy) CaptureOneGuideOptions *guideSettings;  // (Studio Only) The document's guide settings.

- (void) refresh;  // Refresh the document's display.
- (void) selectCameraName:(NSString *)name;  // Select a tethered camera to use by name or identifier.  Follow with a delay command in order to use the chosen camera immediately afterward in the same script.  Use an empty name ("") in order to select no camera.
- (void) browseToPath:(NSString *)toPath;  // Change the folder being browsed.
- (void) selectVariant:(CaptureOneVariant *)variant variants:(NSArray<CaptureOneVariant *> *)variants;  // Add one or more variants to the current collection's selection.
- (void) deselectVariant:(CaptureOneVariant *)variant variants:(NSArray<CaptureOneVariant *> *)variants;  // Remove one or more variants from the current collection's selection.
- (void) importSource:(id)source;  // Perform an import. If importing into a document, imports images according to what is defined in the document's import settings.
- (void) exportOriginalsVariants:(NSArray<CaptureOneVariant *> *)variants;  // Perform an image export according to what is defined in the document's export originals settings.
- (void) backupNowLocation:(id)location testIntegrity:(BOOL)testIntegrity optimize:(BOOL)optimize;  // Perform an immediate document backup (catalogs only). The default functionality is as defined in the user interface, but may be overridden using the below optional parameters.
- (void) createTemplateNamed:(NSString *)named;  // Create a named template using this document. Will quietly overwrite an existing template of the same name.
- (void) batchRenameVariants:(NSArray<CaptureOneVariant *> *)variants;  // Perform a batch rename according to what is defined in the document's batch rename settings.
- (void) changeSelectionTo:(CaptureOneSelectType)to;  // Change the document's selection by the specified type.

@end

// A Capture One window toolbar item.
@interface CaptureOneToolbarItem : SBObject <CaptureOneGenericMethods>

@property (copy, readonly) NSString *name;
- (NSString *) id;  // The unique identifier of the item.


@end

// A Capture One tool tab. Newly created tool tabs must have either a standard id, or a name and valid icon number (1-18).
@interface CaptureOneToolTab : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneTool *> *) tools;

@property (copy, readonly) NSString *name;
- (NSString *) id;  // The unique identifier of the tab.
@property (readonly) NSInteger iconNumber;
@property BOOL selected;  // Is this tool tab selected in the UI.


@end

// A Capture One tool.
@interface CaptureOneTool : SBObject <CaptureOneGenericMethods>

@property (copy, readonly) NSString *name;
- (NSString *) id;  // The unique identifier of the tool.
@property BOOL expanded;  // Is this tool expanded in the UI.
@property BOOL pinned;  // Is this tool pinned in the UI. An unpinned tool appears in the scrollable tools area.
@property BOOL locked;  // (Studio Only) Is this tool locked.


@end

// A camera. Not all properties are supported by all cameras.
@interface CaptureOneCamera : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneAttribute *> *) attributes;
- (SBElementArray<CaptureOneFocusMeter *> *) focusMeters;

@property (copy, readonly) NSString *name;  // The name of the camera.
@property (copy, readonly) NSString *identifier;  // The camera's unique identifier.
@property (copy) NSString *format;  // Current image format.
@property (copy) NSString *sensorPlus;  // Current Sensor+ setting.
@property (copy) NSString *imageArea;  // Current image area format.
@property (readonly) NSInteger liveWidth;  // Current live view capture width in pixels.
@property (readonly) NSInteger liveHeight;  // Current live view capture height in pixels.
@property (copy) NSString *ISO;  // Current ISO setting.
@property (copy) NSString *whiteBalance;  // Current white balance setting.
@property (copy) NSString *program;  // Current exposure program mode.
@property (copy) NSString *exposureStep;  // Current exposure step.
@property (copy) NSString *shutterSpeed;  // Current shutter speed.
@property (copy) NSString *aperture;  // Current aperture setting.
@property (copy) NSString *EVAdjustment;  // Current exposure value adjustment.
@property (copy) NSString *flashMode;  // Current flash mode.
@property (copy) NSString *meteringMode;  // Current metering mode.
@property (copy, readonly) NSString *meterValue;  // Current meter value.
@property BOOL autofocusing;  // Whether or not this camera is currently autofocusing. Start autofocusing by setting this property to true.
@property (copy, readonly) NSString *availableFormats;  // The camera's possible image formats (delimited by |'s).
@property (copy, readonly) NSString *availableSensorPlusSettings;  // The camera's possible Sensor+ settings (delimited by |'s).
@property (copy, readonly) NSString *availableImageAreaSettings;  // The camera's possible image area settings (delimited by |'s).
@property (copy, readonly) NSString *availableISOSettings;  // The camera's possible ISO settings (delimited by |'s).
@property (copy, readonly) NSString *availableWhiteBalanceSettings;  // The camera's possible white balance settings (delimited by |'s).
@property (copy, readonly) NSString *availablePrograms;  // The camera's possible programs (delimited by |'s).
@property (copy, readonly) NSString *availableExposureSteps;  // The camera's possible exposure steps (delimited by |'s).
@property (copy, readonly) NSString *availableShutterSpeeds;  // The camera's possible shutter speeds (delimited by |'s).
@property (copy, readonly) NSString *availableApertureSettings;  // The camera's possible aperture settings (delimited by |'s).
@property (copy, readonly) NSString *availableEVAdjustments;  // The camera's possible exposure value adjustments (delimited by |'s).
@property (copy, readonly) NSString *availableFlashModes;  // The camera's possible flash modes (delimited by |'s).
@property (copy, readonly) NSString *availableMeteringModes;  // The camera's possible metering modes (delimited by |'s).

- (void) adjustFocusByAmount:(NSInteger)byAmount sync:(BOOL)sync;  // Adjust the camera focus.

@end

// A motorized device under the control of Capture One.
@interface CaptureOneControlDevice : SBObject <CaptureOneGenericMethods>

@property (readonly) BOOL calibrated;  // If the device has been calibrated.
@property BOOL calibrating;  // If the device is currently being calibrated.  Can be set to true to begin calibration, or set to false to cancel a calibration in progress.
@property (copy) NSArray<NSNumber *> *resolutionSettings;  // In the form of {position #1, PPI #1, position #2, PPI #2}, with positions in millimeters.
@property double resolution;  // The device's current pixels-per-inch value.  Can be set in order to automatically adjust position appropriately.
@property double position;  // The device's current position in millimeters.  Can be set in order to adjust to a new position.


@end

// A Live View focus meter. Requires the camera to be in Live View.
@interface CaptureOneFocusMeter : SBObject <CaptureOneGenericMethods>

@property NSInteger width;  // The focus meter width in pixels.
@property NSInteger height;  // The focus meter height in pixels.
@property NSInteger horizontalPosition;  // The horizontal position in pixels.
@property NSInteger verticalPosition;  // The vertical position in pixels.
@property (readonly) double amount;  // The current focus amount.
@property (readonly) double peakAmount;  // The maximum focus amount this meter has experienced.


@end

// An attribute of a camera, e.g. Battery level.
@interface CaptureOneAttribute : SBObject <CaptureOneGenericMethods>

@property (copy, readonly) NSString *name;
@property (readonly) BOOL readOnly;  // Whether or not this attribute's value may be changed via script.
@property (readonly) CaptureOneAttributeUserLevel userLevel;
@property (copy, readonly) NSString *availableValues;  // Possible values for this camera attribute (delimited by |'s).
@property (copy) NSString *value;  // The current value of this attribute. May be changed if the attribute is not 'read only'.

- (void) increment;  // Increment the value of the camera attribute.
- (void) decrement;  // Increment the value of the camera attribute.

@end

// An organizational collection.
@interface CaptureOneCollection : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneCollection *> *) collections;
- (SBElementArray<CaptureOneImage *> *) images;
- (SBElementArray<CaptureOneVariant *> *) variants;

@property (copy, readonly) NSString *name;
- (NSString *) id;  // The unique identifier of the collection.
@property (readonly) CaptureOneCollectionType kind;
@property (readonly) BOOL user;  // Indicates if this is a user created collection.
@property BOOL synchronizing;  // Indicates if this collection is currently in the process of adding or removing images to match what is in the filesystem.  Can be set to true for a session folder collection in order to initiate background synchronization.  For catalog folder collections, use the `synchronize` command instead.
@property (copy, readonly) id folder;  // The folder location referred to by the collection, if appropriate.
@property (copy, readonly) NSString *rules;  // The rules used by the collection, if appropriate.
@property CaptureOneSortOrder sortingOrder;
@property BOOL sortingReversed;
@property (copy) CaptureOneVariant *compareVariant;  // The pinned variant for comparison.  Use the 'clear compare' command to unpin.
@property (copy) NSArray<CaptureOneVariant *> *compareVariants;  // Multiple pinned variants for comparison. Use the 'clear compare' command to unpin all of them.

- (void) addInsideVariants:(NSArray<CaptureOneVariant *> *)variants;  // Add one or more variants to an album collection.
- (void) moveInsideVariants:(NSArray<CaptureOneVariant *> *)variants;  // Move one or more variants into a collection (favorite or folder).
- (void) clearCompare;  // Clear a collection's compare variant.
- (void) synchronizeSubfolders:(BOOL)subfolders onlyIncludePreviouslyAddedSubfolders:(BOOL)onlyIncludePreviouslyAddedSubfolders importing:(BOOL)importing removing:(BOOL)removing;  // Perform imports and/or deletes in a folder collection to reflect the contents of the actual folder on disk.  All parameters below are optional.

@end

// A Capture One process recipe.
@interface CaptureOneRecipe : SBObject <CaptureOneGenericMethods>

@property (copy) NSString *name;  // The name of the recipe.
@property BOOL enabled;  // Whether or not the recipe is enabled.
@property CaptureOneRecipeFileFormat outputFormat;  // The output file format of the recipe.
@property NSInteger bits;  // The bit depth of the output file.
@property NSInteger JPEGQuality;  // The JPEG quality of the output file.
@property CaptureOneTiffCompress TIFFCompression;  // The TIFF compression type of the output file.
@property BOOL TIFFThumbnail;  // Whether or not the output TIFF should have a thumbnail.
@property NSInteger TIFFTileDimension;  // Valid values are 0 (no tiling), 128, 256, 512, 1024, or 2048.
@property (copy) NSString *colorProfile;  // The name of the ICC color profile to be applied.
@property (copy) NSNumber *pixelsPerInch;  // The resolution of the output file.
@property CaptureOneScalingType scalingMethod;  // The scaling method for the output file.
@property CaptureOneMeasurementUnit scalingUnit;  // The scaling units used by current scaling method.
@property (copy) NSNumber *primaryScalingValue;  // Primary value used by current scaling method.
@property (copy) NSNumber *secondaryScalingValue;  // Secondary value used by current scaling method (BoundingDimensions and Width_by_Height methods only).
@property BOOL upscale;  // Whether or not output can be upscaled beyond the original size.
@property BOOL packed;  // If exported images should be packed into EIP files.
@property BOOL includeAdjustments;  // If image adjustments should be also exported.
@property (copy) id app;  // Output file's 'Open With' application.
@property CaptureOneRecipeRootType rootFolderType;  // The recipe's type of root folder.
@property (copy) NSURL *rootFolderLocation;  // The output root folder location.
@property (copy) NSString *outputNameFormat;  // The output name format of the recipe, with tokens in brackets e.g. [Rating].
@property (copy) NSString *outputSubFolder;  // The output sub folder, with tokens in brackets e.g. [Rating].
@property CaptureOneExistingFilesBehavior existingFiles;  // What to do when a file already exists at the output path.
@property CaptureOneSharpeningType sharpening;  // The type of sharpening applied to output.
@property double sharpeningAmount;
@property double sharpeningRadius;  // Only applies to type 'for screen'.
@property double sharpeningThreshold;
@property double sharpeningDistance;  // Only applies to type 'for print'.
@property CaptureOneDistanceType sharpeningDistanceType;  // Only applies to type 'for print'.
@property CaptureOneExportCropMethod exportCropMethod;  // How the crop should be used during output.
@property (copy) NSArray<NSString *> *includeKeywords;  // The names of keyword libraries to include, or 'All'.
@property BOOL includeRatings;  // Whether or not rating and color tags should be included.
@property BOOL includeCopyright;  // Whether or not copyright metadata should be included.
@property BOOL includeGPS;  // Whether or not GPS metadata should be included.
@property BOOL includeCameraMetadata;  // Whether or not camera metadata should be included.
@property BOOL includeOtherMetadata;  // Whether or not other metadata should be included.
@property BOOL includeAnnotations;  // Whether or not annotations should be included.
@property BOOL includeOverlay;  // Whether or not the overlay should be included.
@property BOOL includeGuides;  // (Studio Only) Whether or not the guides should be included.
@property (copy) CaptureOneWatermark *watermark;  // The watermark of the recipe.


@end

// A recipe watermark.  Properties are specific to the kind of watermark, so ensure that the kind is what you want before accessing a watermark's properties.
@interface CaptureOneWatermark : SBObject <CaptureOneGenericMethods>

@property CaptureOneWatermarkKind kind;  // The kind of watermark.
@property (copy) NSString *image;  // The image path.
@property (copy) NSString *label;  // The text, with tokens in brackets e.g. [Rating].
@property (copy) NSColor *color;  // The text color.
@property NSInteger size;  // The text size in points.
@property (copy) NSString *font;  // The text font name.
@property NSInteger opacity;  // The opacity (1 to 100).
@property NSInteger scale;  // The scale (25 to 400).
@property (copy) NSNumber *x;  // The horizontal position (-55 to 55).
@property (copy) NSNumber *y;  // The vertical position (-55 to 55).


@end

// A pending job from a Capture One document's batch processing queue.
@interface CaptureOneJob : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneRecipe *> *) recipes;

- (NSString *) id;  // The unique identifier of the job.
@property (copy, readonly) NSString *imageName;  // The filename of the original image to be processed.
@property (copy, readonly) NSString *imagePath;  // The full path to the original image to be processed.


@end

@interface CaptureOneKeywordLibrary : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneKeyword *> *) keywords;

- (NSString *) id;
@property (copy, readonly) NSString *name;

- (void) importSource:(id)source;  // Perform an import. If importing into a document, imports images according to what is defined in the document's import settings.

@end

@interface CaptureOneKeyword : SBObject <CaptureOneGenericMethods>

- (NSString *) id;  // The unique identifier of the keyword.
@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *parent;

- (void) applyKeywordTo:(NSArray<CaptureOneVariant *> *)to;  // Apply an existing keyword to one or more variants.

@end

@interface CaptureOneUserCropAspectRatio : SBObject <CaptureOneGenericMethods>

@property (copy, readonly) NSString *name;
@property (readonly) double ratio;  // Equivalent to width / height, e.g. a 16:9 ratio = 16.0/9.0


@end

// A viewer color readout. Color property values and availability are dependent upon the current output recipe profile and Lab color mode. Inappropriate properties will return 'missing value'.
@interface CaptureOneReadout : SBObject <CaptureOneGenericMethods>

@property (readonly) double horizontalPosition;  // The horizontal position (must be greater than 0 and less than 100).
@property (readonly) double verticalPosition;  // The vertical position (must be greater than 0 and less than 100).
@property (readonly) NSInteger red;
@property (readonly) NSInteger green;
@property (readonly) NSInteger blue;
@property (readonly) NSInteger lightness;
@property (readonly) NSInteger cyan;
@property (readonly) NSInteger magenta;
@property (readonly) NSInteger yellow;
@property (readonly) NSInteger black;
@property (readonly) NSInteger gray;
@property (readonly) double LabL;  // Lab lightness
@property (readonly) double LabA;  // Lab red to green
@property (readonly) double LabB;  // Lab blue to yellow


@end

// A variant adjustments layer.  Note that for backward compatibility reasons, an Image Layer's name and kind are 'background'.
@interface CaptureOneLayer : SBObject <CaptureOneGenericMethods>

@property (copy) NSString *name;
@property (readonly) CaptureOneLayerType kind;
@property BOOL enabled;
@property NSInteger opacity;  // The opacity (1 to 100).
@property (copy) CaptureOneAdjustmentSettings *adjustments;  // The layer's adjustment settings.
@property (copy) CaptureOneLumaRangeSettings *lumaRange;  // The layer mask's luma range settings.

- (void) clearMask;  // Clear the mask of a layer.
- (void) invertMask;  // Invert the mask of a layer.
- (void) fillMask;  // Fill the mask of a layer.
- (void) rasterizeMask;  // Rasterize the mask of a layer.
- (void) featherMaskAmount:(double)amount;  // Feather the mask of a layer.
- (void) refineMaskAmount:(double)amount;  // Refine the mask of a layer.
- (void) copyMaskToLayer:(CaptureOneLayer *)toLayer NS_RETURNS_NOT_RETAINED;  // Copy the mask of a layer.
- (void) applyStyleNamed:(NSString *)named;  // Apply a style or preset to a layer.
- (void) clearLumaRange;  // Clear the luma range from a layer.

@end

@interface CaptureOneLumaRangeSettings : SBObject <CaptureOneGenericMethods>

@property double rangeLow;
@property double rangeHigh;
@property double falloffLow;
@property double falloffHigh;
@property BOOL invert;
@property double radius;
@property double sensitivity;


@end

// An Image Variant.
@interface CaptureOneVariant : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneKeyword *> *) keywords;
- (SBElementArray<CaptureOneLayer *> *) layers;
- (SBElementArray<CaptureOneReadout *> *) readouts;
- (SBElementArray<CaptureOneOutputEvent *> *) outputEvents;

@property (copy, readonly) NSString *name;  // The name of the parent image
- (NSString *) id;  // The unique identifier of the variant
@property (copy, readonly) CaptureOneImage *parentImage;  // The parent image of the variant
@property (copy) CaptureOneLayer *currentLayer;  // The currently selected layer.
@property BOOL pick;  // Is this the picked variant
@property (readonly) NSInteger position;  // The index of this variant relative to all of the parent image's variants, e.g. the 'picked' is the variant at first position.
@property (readonly) BOOL selected;  // Is this variant selected in the collection containing it.
@property (readonly) BOOL visible;  // Is this variant among the filtered variants visible in the parent document's current collection.
@property (readonly) BOOL queued;  // Is this variant currently queued for processing.
@property CaptureOneTechnicalProcessingMode processingMode;  // Corresponds to Mode in Base Characteristics.
@property (readonly) NSInteger engine;  // The processing engine version in use for this variant.  Generally corresponds to the version of Capture One under which the image was originally edited, multiplied by 100.
@property (copy) CaptureOneAdjustmentSettings *adjustments;  // The variant's Image Layer adjustment settings.
@property (copy) NSArray<NSString *> *styles;  // The name(s) of styles and/or presets that have been applied to this variant's Image Layer.
@property (readonly) double exposureMeter;  // Center-weighted measure of exposure in the original capture, denoted on a ±2 EV scale.
@property NSInteger colorTag;
@property NSInteger rating;
@property (copy) NSString *contactCreator;
@property (copy) NSString *contactCreatorJobTitle;
@property (copy) NSString *contactAddress;
@property (copy) NSString *contactCity;
@property (copy) NSString *contactState;
@property (copy) NSString *contactPostalCode;
@property (copy) NSString *contactCountry;
@property (copy) NSString *contactPhone;
@property (copy) NSString *contactEmail;
@property (copy) NSString *contactWebsite;
@property (copy) NSString *contentHeadline;
@property (copy) NSString *contentDescription;
@property (copy) NSString *contentCategory;
@property (copy) NSString *contentSupplementalCategories;
@property (copy) NSString *contentSubjectCodes;
@property (copy) NSString *contentDescriptionWriter;
@property (copy) NSString *imageIntellectualGenre;
@property (copy) NSString *imageScenes;
@property (copy) NSString *imageLocation;
@property (copy) NSString *imageCity;
@property (copy) NSString *imageState;
@property (copy) NSString *imageCountry;
@property (copy) NSString *imageCountryCode;
@property (copy) NSString *statusTitle;
@property (copy) NSString *statusJobIdentifier;
@property (copy) NSString *statusInstructions;
@property (copy) NSString *statusProvider;
@property (copy) NSString *statusSource;
@property (copy) NSString *statusCopyrightNotice;
@property (copy) NSString *statusRightsUsageTerms;
@property (copy) NSString *GettyPersonalities;
@property (copy) NSString *GettyOriginalFilename;
@property (copy) NSString *GettyParentMEID;
@property (readonly) double latitude;
@property (readonly) double longitude;
@property (readonly) double altitude;
@property (copy) CaptureOneLensCorrectionSettings *lensCorrection;
@property (copy, readonly) NSString *appliedLCCName;  // The name of the image used to create the lens cast correction applied to this variant.
@property BOOL LCCColorCast;  // Does the variant use lens cast correction to improve color cast.
@property BOOL LCCDustRemoval;  // Does the variant use lens cast correction to remove dust.
@property BOOL LCCUniformLight;  // Does the variant use lens cast correction to improve light uniformity.
@property NSInteger LCCUniformLightAmount;  // The percentage of light uniformity improvement from lens cast correction.
@property NSRect crop;  // The variant's crop rectangle {centerX, centerY, width, height}
@property (copy, readonly) NSArray<NSString *> *availableCropAspectRatios;
@property (copy) NSString *cropAspectRatio;
@property CaptureOneCropAspectRatioOrientation cropOrientation;
@property NSPoint cropSize;  // The size of the crop in pixels {width, height}
@property NSInteger cropWidth;  // The width (in pixels) of the variant's crop
@property NSInteger cropHeight;  // The height (in pixels) of the variant's crop
@property NSPoint cropCenter;  // The center of the crop in pixels {x, y} Bottom Left is the origin
@property NSInteger cropCenterX;  // The horizontal center (in pixels) of the variant's crop (relative to Left edge)
@property NSInteger cropCenterY;  // The vertical center (in pixels) of the variant's crop (relative to bottom edge)
@property BOOL cropOutsideImage;  // Is crop outside image enabled.

- (NSString *) processRecipe:(NSString *)recipe;  // (PRO Only) Process a variant, or the variants of a RAW file
- (void) autocrop;  // (CH Only) Auto crop a variant
- (CaptureOneVariant *) cloneVariantAdditiveSelect:(BOOL)additiveSelect;  // Clone a variant
- (void) upgradeEngine;  // Upgrade a variant's processing engine to the current version.  Warning: cannot be undone.
- (void) copyAdjustments NS_RETURNS_NOT_RETAINED;  // Copy a variant's adjustments to its parent document's settings clipboard.
- (void) applyAdjustments;  // Apply adjustments to a variant from its parent document's settings clipboard.
- (void) reloadMetadata;  // Reload a variant's source file metadata.
- (void) syncMetadata;  // Sync a variant's metadata back to its source file.
- (void) promote;  // Promote a variant among its clones.
- (void) demote;  // Demote a variant among its clones.
- (void) createLCCDustRemoval:(BOOL)dustRemoval wideAngle:(BOOL)wideAngle;  // Create lens cast correction from this variant.
- (void) applyLCCTo:(NSArray<CaptureOneVariant *> *)to;  // Apply lens cast correction from a variant to one or more other variants.
- (void) resetAdjustments;  // Reset the adjustment settings of a variant.
- (void) pickNormalizeAt:(NSPoint)at;  // Set the document's “normalize target color” from a point on a variant.
- (void) applyNormalizeAt:(NSPoint)at adjustWhiteBalance:(BOOL)adjustWhiteBalance adjustExposure:(BOOL)adjustExposure;  // Apply the document's “normalize target color” to a point on a variant.  The default normalization types are as defined in the UI, but may be overridden using the below optional parameters.
- (void) autoadjustAdjustWhiteBalance:(BOOL)adjustWhiteBalance adjustExposure:(BOOL)adjustExposure adjustContrastBrightness:(BOOL)adjustContrastBrightness adjustHdr:(BOOL)adjustHdr adjustLevels:(BOOL)adjustLevels adjustRotation:(BOOL)adjustRotation adjustKeystone:(BOOL)adjustKeystone;  // Automatically adjust a variant's settings. The default types of adjustments that will be performed are as defined in the UI, but may be overridden using the below optional parameters.
- (NSRect) maximumCropHorizontal:(BOOL)horizontal vertical:(BOOL)vertical apply:(BOOL)apply;  // Determine the maximum crop for a variant.
- (void) rotateLeft;  // Rotate the variant left 90 degrees.
- (void) rotateRight;  // Rotate the variant right 90 degrees.

@end

// Settings used to correct for lens distortion.
@interface CaptureOneLensCorrectionSettings : SBObject <CaptureOneGenericMethods>

@property (copy) NSString *lensProfile;  // The name of the current lens correction profile.
@property BOOL chromaticAberration;  // Is chromatic aberration being corrected.
@property BOOL customChromaticAberration;  // Is this image's data being used to improve chromatic correction.
@property BOOL diffractionCorrection;  // Is diffraction being corrected.
@property BOOL hideDistortedAreas;  // Are distorted areas being hidden.
@property double distortion;  // The amount of distortion correction being applied.
@property double sharpnessFalloff;  // The amount of sharpness compensation being applied.
@property double lightFalloff;  // The amount of vignetting compensation being applied.
@property NSInteger focalLength;
@property double aperture;
@property double tilt;
@property double tiltDirection;
@property double shift;
@property double shiftDirection;
@property NSInteger shiftX;
@property NSInteger shiftY;


@end

// A collection of points affecting the exposure gradient of an image.
@interface CaptureOneCurve : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneCurvePoint *> *) curvePoints;


@end

// A curve level adjustment point.
@interface CaptureOneCurvePoint : SBObject <CaptureOneGenericMethods>

@property double brightness;  // Corresponds to the horizontal position of the point in the UI (0 to 100, from shadow on the left to highlight on the right).
@property double amount;  // Corresponds to the vertical position of the point in the UI (0 to 100).


@end

// Settings that adjust the appearance of a variant.
@interface CaptureOneAdjustmentSettings : SBObject <CaptureOneGenericMethods>

@property NSInteger orientation;
@property double rotation;
@property CaptureOneFlipType flip;
@property NSInteger keystoneAmount;
@property double keystoneVertical;
@property double keystoneHorizontal;
@property double keystoneSkew;
@property double keystoneAspect;
@property (copy) NSString *colorProfile;
@property (copy) NSString *filmCurve;
@property (copy) NSString *whiteBalancePreset;
@property double temperature;
@property double tint;
@property double exposure;
@property double brightness;
@property double contrast;
@property double saturation;
@property double colorBalanceMasterHue;
@property double colorBalanceMasterSaturation;
@property double colorBalanceShadowHue;
@property double colorBalanceShadowSaturation;
@property double colorBalanceShadowLightness;
@property double colorBalanceMidtoneHue;
@property double colorBalanceMidtoneSaturation;
@property double colorBalanceMidtoneLightness;
@property double colorBalanceHighlightHue;
@property double colorBalanceHighlightSaturation;
@property double colorBalanceHighlightLightness;
@property BOOL blackAndWhite;
@property NSInteger blackAndWhiteRedSensitivity;
@property NSInteger blackAndWhiteYellowSensitivity;
@property NSInteger blackAndWhiteGreenSensitivity;
@property NSInteger blackAndWhiteCyanSensitivity;
@property NSInteger blackAndWhiteBlueSensitivity;
@property NSInteger blackAndWhiteMagentaSensitivity;
@property NSInteger blackAndWhiteSplitHighlightHue;
@property NSInteger blackAndWhiteSplitHighlightSaturation;
@property NSInteger blackAndWhiteSplitShadowHue;
@property NSInteger blackAndWhiteSplitShadowSaturation;
@property (copy) CaptureOneColorEditorOptions *colorEditorSettings;
@property double levelHighlightRgb;
@property double levelShadowRgb;
@property double levelHighlightRed;
@property double levelShadowRed;
@property double levelHighlightGreen;
@property double levelShadowGreen;
@property double levelHighlightBlue;
@property double levelShadowBlue;
@property double levelTargetHighlightRgb;
@property double levelTargetShadowRgb;
@property double levelTargetHighlightRed;
@property double levelTargetShadowRed;
@property double levelTargetHighlightGreen;
@property double levelTargetShadowGreen;
@property double levelTargetHighlightBlue;
@property double levelTargetShadowBlue;
@property double levelMidtoneRgb;
@property double levelMidtoneRed;
@property double levelMidtoneGreen;
@property double levelMidtoneBlue;
@property (copy) CaptureOneCurve *rgbCurve;
@property (copy) CaptureOneCurve *lumaCurve;
@property (copy) CaptureOneCurve *redCurve;
@property (copy) CaptureOneCurve *greenCurve;
@property (copy) CaptureOneCurve *blueCurve;
@property double highlightAdjustment;
@property double shadowRecovery;
@property double whiteRecovery;
@property double blackRecovery;
@property CaptureOneClarityMethod clarityMethod;
@property double clarityAmount;
@property double clarityStructure;
@property double dehazeAmount;
@property (copy) NSColor *dehazeColor;
@property double vignettingAmount;
@property CaptureOneVignetteMethod vignettingMethod;
@property double sharpeningAmount;
@property double sharpeningRadius;
@property double sharpeningThreshold;
@property double sharpeningHaloSuppression;
@property double noiseReductionLuminance;
@property NSInteger noiseReductionDetails;
@property double noiseReductionColor;
@property double noiseReductionSinglePixel;
@property CaptureOneGrainType filmGrainType;
@property double filmGrainImpact;
@property double filmGrainGranularity;
@property double moireAmount;
@property NSInteger moirePattern;

- (void) pickDehazeAt:(NSPoint)at;  // Set the adjustment “dehaze color” from a point on a variant.
- (void) recalculateDehaze;  // Set the adjustment “dehaze color” automatically.

@end

// Encapsulates all settings available in the Color Editor tool.
@interface CaptureOneColorEditorOptions : SBObject <CaptureOneGenericMethods>


@end

// Settings affecting the tools.
@interface CaptureOneToolsConfiguration : SBObject <CaptureOneGenericMethods>

@property BOOL visible;
@property NSInteger size;
@property BOOL autoHide;
@property CaptureOneToolPlacement placement;


@end

// Settings affecting a viewer. Some elements and properties are only relevant for the standalone Viewer.
@interface CaptureOneViewerConfiguration : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneToolTab *> *) toolTabs;
- (SBElementArray<CaptureOneToolbarItem *> *) toolbarItems;

@property (copy) CaptureOneWindow *viewerWindow;  // The associated window, if this is the standalone Viewer.
@property (copy) CaptureOneToolsConfiguration *toolSettings;  // Settings for the tools associated with this viewer.
@property BOOL visible;
@property NSInteger zoom;
@property BOOL multiView;
@property BOOL proofMargin;
@property BOOL labels;
@property CaptureOneToolbarDisplayMode windowToolbarMode;
@property BOOL viewerToolbar;


@end

// Settings affecting a document's browser.
@interface CaptureOneBrowserConfiguration : SBObject <CaptureOneGenericMethods>

@property BOOL visible;
@property NSInteger size;
@property BOOL autoHide;
@property CaptureOneBrowserPlacement placement;
@property BOOL toolbar;
@property CaptureOneBrowserMode mode;
@property NSInteger thumbnailZoom;
@property CaptureOneBrowserLabel labelMode;


@end

// Settings defining all aspects of the image import process for a document. Tell the document to import in order to use these settings.
@interface CaptureOneImportOptions : SBObject <CaptureOneGenericMethods>

@property BOOL includeSubfolders;
@property BOOL excludeDuplicates;
@property CaptureOneImportDestinationType destinationType;  // All values other than 'custom' apply strictly to either sessions or catalogs only.
@property (copy) id destinationFolder;  // The import folder according to the current destination type. Can only be changed when the destination type is 'custom'.
@property (copy) NSString *destinationSubFolder;  // Folder name with tokens in brackets e.g. [Rating].  Only applies to sessions.
@property CaptureOneImportDestinationCollection destinationCollection;
@property BOOL backup;
@property (copy) id backupFolder;
@property (copy) NSString *importNamingFormat;  // Name format with tokens in brackets e.g. [Rating].  Has no effect if the destination type is 'current location'.
@property (copy) NSString *importJobName;  // Has no effect if the destination type is 'current location'.
@property NSInteger importCounter;  // The counter used by appropriate naming format tokens.  The next item imported will be incremented from this.
@property NSInteger importCounterIncrement;  // The amount by which the import counter is incremented for every item imported.
@property (copy) NSString *importCopyright;
@property (copy) NSString *importDescription;
@property (copy) NSArray<NSString *> *applyStyles;  // The name(s) of style adjustments to be applied to imported images.
@property BOOL autoAdjust;
@property BOOL includeExistingAdjustments;
@property CaptureOneImportCollectionAction importCollectionAction;
@property BOOL ejectCard;
@property BOOL eraseAfterCopy;


@end

// Settings defining all aspects of exporting original images from a document. Tell the document to 'export originals' in order to use these settings.
@interface CaptureOneExportOriginalOptions : SBObject <CaptureOneGenericMethods>

@property (copy) id destinationFolder;  // The folder to export into.
@property (copy) NSString *subFolder;  // The sub folder, with tokens in brackets e.g. [Rating].
@property CaptureOneNamingMethod namingMethod;
@property (copy) NSString *namingFormat;  // Text used for 'text and tokens' naming method, with tokens in brackets e.g. [Rating].
@property (copy) NSString *jobName;  // Job name used for 'text and tokens' naming method.
@property NSInteger exportCounter;  // Counter used for 'text and tokens' naming method.
@property NSInteger exportCounterIncrement;  // Counter increment used for 'text and tokens' naming method.
@property (copy) NSString *findText;  // Text to be found for 'find and replace' naming method.
@property (copy) NSString *replacementText;  // Text to replace the found text for 'find and replace' naming method.
@property BOOL packed;  // If exported images should be packed into Enhanced Image Package files.
@property BOOL includeAdjustments;  // If image adjustments should be also exported.
@property BOOL includeMovies;  // If movies should be also exported.
@property BOOL notify;  // If a dialog notifying when the export has completed is desired.


@end

// An output history event.
@interface CaptureOneOutputEvent : SBObject <CaptureOneGenericMethods>

- (NSString *) id;  // The unique identifier of the event.
@property (copy, readonly) NSDate *date;  // The time of the output event.
@property (copy, readonly) NSURL *file;  // The file object representing the resulting output at the time of the event.
@property (copy, readonly) NSString *path;  // The file path of the resulting output at the time of the event.
@property (readonly) BOOL exists;  // Whether or not the output file of this event currently exists.


@end

// An image file.
@interface CaptureOneImage : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneVariant *> *) variants;

@property (copy, readonly) NSString *path;  // The full path to the original image file.
@property (copy, readonly) NSString *extension;  // The file's extension (file type), in uppercase.
@property (copy, readonly) NSURL *file;  // The file of the original image file.
@property (readonly) NSInteger fileSize;  // The image's file size.
@property (copy) NSString *name;  // The name of the image file.
- (NSString *) id;  // The unique identifier of the image.
@property (readonly) NSPoint dimensions;  // The dimensions of the image in pixels {width, height}.
@property (readonly) BOOL packed;  // Is this image in an Enhanced Image Package.
@property (copy) NSDate *EXIFCaptureDate;
@property (copy, readonly) NSString *EXIFCameraMake;
@property (copy, readonly) NSString *EXIFCameraModel;
@property (copy, readonly) NSString *EXIFCameraSoftware;
@property (copy, readonly) NSString *EXIFCameraOwner;
@property (copy, readonly) NSString *EXIFISO;
@property (copy, readonly) NSString *EXIFShutterSpeed;
@property (copy, readonly) NSString *EXIFAperture;
@property (copy, readonly) NSString *EXIFExposureCompensation;
@property (copy, readonly) NSString *EXIFFlashMode;
@property (copy, readonly) NSString *EXIFExposureProgram;
@property (copy, readonly) NSString *EXIFMeteringMode;
@property (copy, readonly) NSString *EXIFFocalLength;
@property (copy, readonly) NSString *EXIFWhiteBalance;
@property (copy, readonly) NSString *EXIFLatitude;
@property (copy, readonly) NSString *EXIFLongitude;
@property (copy, readonly) NSString *EXIFAltitude;

- (BOOL) addVariantAdditiveSelect:(BOOL)additiveSelect;  // Add a new Variant eg. "tell myImage to add variant"
- (void) pack;  // Pack an image into an Enhanced Image Package file.
- (void) unpack;  // Unpack an image from an Enhanced Image Package file.
- (void) relinkToPath:(NSString *)toPath;  // Relink a catalog image file.  The file must be the exact same size and type as the originally imported image.

@end

// Settings defining all aspects of the batch rename process.
@interface CaptureOneBatchRenameOptions : SBObject <CaptureOneGenericMethods>

@property CaptureOneNamingMethod method;
@property (copy) NSString *tokenFormat;  // Text used for 'text and tokens' rename method, with tokens in brackets e.g. [Rating]
@property (copy) NSString *jobName;  // Job name used for 'text and tokens' rename method.
@property NSInteger counter;  // Counter used for 'text and tokens' rename method.
@property NSInteger counterIncrement;  // Counter increment used for 'text and tokens' rename method.
@property (copy) NSString *findText;  // Text to be found for 'find and replace' rename method.
@property (copy) NSString *replacementText;  // Text to replace the found text for 'find and replace' rename method.
@property BOOL includeFileExtension;
@property BOOL pairRAWsAndJPGs;


@end

// Settings affecting an image upon its capture in a tethered workflow.  All individual metadata properties and keywords here correspond to a 'capture metadata' mode of 'document values', which requires a Studio license.
@interface CaptureOneNextCaptureOptions : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneKeyword *> *) keywords;

@property (copy) NSString *captureProfile;  // The name of the profile to be applied.  May also be 'default', 'copy from last', or 'copy from primary'.
@property NSInteger captureOrientation;  // The orientation in degrees to be applied. Can be 0, 90, 180, 270, or -1 for default.
@property CaptureOneAdjustmentsSource captureMetadata;  // The source of metadata to be applied.  Studio exclusively uses 'document values' mode, which is unavailable to other license types.
@property CaptureOneAdjustmentsSource otherAdjustments;  // The source of all other adjustments to be applied.
@property (copy) NSArray<NSString *> *applyStyles;  // The name(s) of style adjustments to be applied.
@property BOOL autoAlignment;  // Whether or not to auto rotate and keystone captured images.
@property (copy) NSString *contactCreator;
@property (copy) NSString *contactCreatorJobTitle;
@property (copy) NSString *contactAddress;
@property (copy) NSString *contactCity;
@property (copy) NSString *contactState;
@property (copy) NSString *contactPostalCode;
@property (copy) NSString *contactCountry;
@property (copy) NSString *contactPhone;
@property (copy) NSString *contactEmail;
@property (copy) NSString *contactWebsite;
@property (copy) NSString *contentHeadline;
@property (copy) NSString *contentDescription;
@property (copy) NSString *contentCategory;
@property (copy) NSString *contentSupplementalCategories;
@property (copy) NSString *contentSubjectCodes;
@property (copy) NSString *contentDescriptionWriter;
@property (copy) NSString *imageIntellectualGenre;
@property (copy) NSString *imageScenes;
@property (copy) NSString *imageLocation;
@property (copy) NSString *imageCity;
@property (copy) NSString *imageState;
@property (copy) NSString *imageCountry;
@property (copy) NSString *imageCountryCode;
@property (copy) NSString *statusTitle;
@property (copy) NSString *statusJobIdentifier;
@property (copy) NSString *statusInstructions;
@property (copy) NSString *statusProvider;
@property (copy) NSString *statusSource;
@property (copy) NSString *statusCopyrightNotice;
@property (copy) NSString *statusRightsUsageTerms;
@property (copy) NSString *GettyPersonalities;
@property (copy) NSString *GettyOriginalFilename;
@property (copy) NSString *GettyParentMEID;
@property BOOL backup;  // (Studio Only) If the captured image should be backed up upon capture.
@property BOOL backupQueueEnabled;  // Whether or not the backup queue is running.  Can be changed.
@property (copy) id backupDestination;  // The location to which captured images should be backed up.


@end

// Settings controlling the behavior of a document's Capture Pilot server. Some properties cannot be changed while a server is running.
@interface CaptureOneServerOptions : SBObject <CaptureOneGenericMethods>

@property (copy) NSString *name;
@property (copy) CaptureOneCollection *servedCollection;  // The 'folder' of images to be served.
@property (copy) NSString *password;
@property (copy, readonly) NSString *address;  // The local IP address of the server.
@property BOOL mobileServing;  // Whether or not the mobile server is running.
@property NSInteger mobilePort;  // The TCP port used for the mobile server. Set to 0 to use the default.
@property BOOL mobileRate;
@property BOOL mobileColorTag;
@property BOOL mobileAdjust;
@property BOOL mobileCapture;
@property BOOL webServing;  // Whether or not the web server is running. Note that starting the web server will require the entry of an administrator password in the Capture One user interface.
@property NSInteger webPort;  // The TCP port used for the web server. Set to 0 to use the default.
@property (copy) NSString *webTheme;
@property BOOL webRate;
@property BOOL webColorTag;


@end

// Settings affecting the overlay image seen in the viewer.
@interface CaptureOneOverlayOptions : SBObject <CaptureOneGenericMethods>

@property BOOL visible;  // Whether or not the overlay is shown.
@property BOOL followCrop;  // Whether or not the scale and position are relative to the crop.
@property (copy) NSString *imagePath;  // The path to the image file.
@property NSInteger opacity;  // The opacity (1 to 100).
@property NSInteger scale;  // The scale (25 to 400).
@property double horizontalPosition;  // The horizontal position (-50 to 50).
@property double verticalPosition;  // The vertical position (-50 to 50).


@end

// Settings affecting a client viewer window (Studio only).
@interface CaptureOneClientViewer : SBObject <CaptureOneGenericMethods>

@property (copy, readonly) NSString *name;
@property CaptureOneClientViewerMode mode;


@end

// Settings affecting the grid display in the viewer.
@interface CaptureOneGridOptions : SBObject <CaptureOneGenericMethods>

@property BOOL visible;  // Whether or not the grid is shown.
@property BOOL followCrop;  // Whether or not the grid is relative to the crop.
@property NSInteger color;
@property CaptureOneGridType kind;
@property NSInteger longEdge;  // The number of divided units along the long dimension of the image (rectangular kind only).
@property NSInteger shortEdge;  // The number of divided units along the short dimension of the image (rectangular kind only).
@property BOOL clockwise;  // The direction of the spiral (fibonacci spiral kind only).
@property BOOL mirror;  // Whether or not to flip the spiral (fibonacci spiral kind only).


@end

// Settings affecting the guides display in the viewer.
@interface CaptureOneGuideOptions : SBObject <CaptureOneGenericMethods>

- (SBElementArray<CaptureOneGuide *> *) guides;

@property BOOL visible;  // Whether or not the guides are shown.
@property BOOL followCrop;  // Whether or not the guides are positioned relative to the crop.
@property NSInteger color;


@end

// A guide to be shown in the viewer.
@interface CaptureOneGuide : SBObject <CaptureOneGenericMethods>

@property double distance;  // How far inside the image the guide appears relative to the edge.
@property CaptureOneMeasurementUnit units;  // The unit type used by the distance property.
@property CaptureOneEdgeType edge;  // The image edge to which this guide is related.


@end

