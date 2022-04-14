//
//  QXPreviewView.m
//  AFNetworking-Code
//
//  Created by 秦菥 on 2022/4/14.
//

#import "QXPreviewView.h"

@interface QXPreviewView()
@property (strong, nonatomic) CALayer *overlayLayer;
@property (nonatomic, strong) NSMutableDictionary *faceLayers;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation QXPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    _faceLayers = [NSMutableDictionary dictionary];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    self.overlayLayer = [CALayer layer];                                    // 2
    self.overlayLayer.frame = self.bounds;
    self.overlayLayer.sublayerTransform = CATransform3DMakePerspective(1000);
    [self.previewLayer addSublayer:self.overlayLayer];
}

- (void)didDetectFaces:(NSArray *)faces
{
    NSArray *transformedFaces = [self transformedFacesFromFaces:faces];

    NSMutableArray *lostFaces = [self.faceLayers.allKeys mutableCopy];      // 1

    for (AVMetadataFaceObject *face in transformedFaces) {

        NSNumber *faceID = @(face.faceID);                                  // 2
        [lostFaces removeObject:faceID];

        CALayer *layer = [self.faceLayers objectForKey:faceID];             // 3
        if (!layer) {
            // no layer for faceID, create new face layer
            layer = [self makeFaceLayer];                                   // 4
            [self.overlayLayer addSublayer:layer];
            self.faceLayers[faceID] = layer;
        }

        layer.transform = CATransform3DIdentity;                            // 1
        layer.frame = face.bounds;

        if (face.hasRollAngle) {
            CATransform3D t = [self transformForRollAngle:face.rollAngle];  // 2
            layer.transform = CATransform3DConcat(layer.transform, t);
        }

        if (face.hasYawAngle) {
            CATransform3D t = [self transformForYawAngle:face.yawAngle];    // 4
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
    }

    for (NSNumber *faceID in lostFaces) {                                   // 6
        CALayer *layer = [self.faceLayers objectForKey:faceID];
        [layer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }
}


- (NSArray *)transformedFacesFromFaces:(NSArray *)faces {                   // 2
    NSMutableArray *transformedFaces = [NSMutableArray array];
    for (AVMetadataObject *face in faces) {
        AVMetadataObject *transformedFace =                                 // 3
            [self.previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaces addObject:transformedFace];
    }
    return transformedFaces;
}

- (CALayer *)makeFaceLayer {
    CALayer *layer = [CALayer layer];
    layer.borderWidth = 5.0f;
    layer.borderColor =
        [UIColor colorWithRed:0.188 green:0.517 blue:0.877 alpha:1.000].CGColor;
    return layer;
}

// Rotate around Z-axis
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngleInDegrees {        // 3
    CGFloat rollAngleInRadians = THDegreesToRadians(rollAngleInDegrees);
    return CATransform3DMakeRotation(rollAngleInRadians, 0.0f, 0.0f, 1.0f);
}

// Rotate around Y-axis
- (CATransform3D)transformForYawAngle:(CGFloat)yawAngleInDegrees {          // 5
    CGFloat yawAngleInRadians = THDegreesToRadians(yawAngleInDegrees);

    CATransform3D yawTransform =
        CATransform3DMakeRotation(yawAngleInRadians, 0.0f, -1.0f, 0.0f);

    return CATransform3DConcat(yawTransform, [self orientationTransform]);
}

- (CATransform3D)orientationTransform {                                     // 6
    CGFloat angle = 0.0;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
        default: // as UIDeviceOrientationPortrait
            angle = 0.0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}

static CGFloat THDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

static CATransform3D CATransform3DMakePerspective(CGFloat eyePosition) {    // 3
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}
- (AVCaptureSession *)session
{
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.previewLayer.session = session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}



@end
