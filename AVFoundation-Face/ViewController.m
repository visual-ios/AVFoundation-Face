//
//  ViewController.m
//  AVFoundation-Face
//
//  Created by 秦菥 on 2022/4/14.
//

#import "ViewController.h"
#import "QXPreviewView.h"
#import "QXCamera.h"
@interface ViewController ()<QXCameraDelegate>
@property (nonatomic, strong) QXCamera *camera;
@property (nonatomic, strong) QXPreviewView *previewView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.camera = [[QXCamera alloc] init];
    _camera.delegate = self;
    NSError *error;
    if ([self.camera setupSession:&error]) {
        self.previewView = [[QXPreviewView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.previewView];
        [self.previewView setSession:self.camera.captureSession];
        
        [self.camera startSession];
    }
}

- (void)didDetectFaces:(NSArray<AVMetadataFaceObject *> *)faces
{
    [_previewView didDetectFaces:faces];
}
@end
