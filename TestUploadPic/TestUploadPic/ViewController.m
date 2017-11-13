//
//  ViewController.m
//  TestUploadPic
//
//  Created by KM on 2017/11/10.
//  Copyright © 2017年 KM. All rights reserved.
//

#import "ViewController.h"

static NSString *boundry = @"----------V2ymHFg03ehbqgZCaKO6jy";//设置边界

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,NSURLSessionTaskDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-打开相册
- (IBAction)openAlbumClicked:(UIButton *)sender {
    
    UIImagePickerController *picController = [[UIImagePickerController alloc] init];
    
    picController.delegate = self;
    
    [self presentViewController:picController animated:YES
                     completion:nil];
    
    
}

#pragma mark-代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSLog(@"选择图片:\n%@",info);
    
    [self uploadDataWithImage:info[@"UIImagePickerControllerOriginalImage"]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/**
 上传图片
 */
- (void)uploadDataWithImage:(UIImage *)img{
    
    NSURL *url = [NSURL URLWithString:@"http://10.51.3.160:8888/upload_file.php"];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //设置Method
    urlRequest.HTTPMethod = @"POST";
    
    //4.设置请求头
    //在请求头中添加content-type字段
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@",boundry];
    [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NSURLSession
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    
    //定义上传操作
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:urlRequest fromData:[self getBodydataWithImage:img] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"响应结果:%@", response);
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"返回数据:\n%@",str);
    }];
    
    [uploadTask resume];
}

- (NSData *)getBodydataWithImage:(UIImage *)image
{
    //把文件转换为NSData
    NSData *fileData = UIImageJPEGRepresentation(image, 0.8);
    
    //文件名
    NSString *fileName=@"test";
    
    //1.构造body string
    NSMutableString *bodyString = [[NSMutableString alloc] init];
    
    //2.拼接body string
    //(1)file_name
    [bodyString appendFormat:@"--%@\r\n",boundry];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"FileName\"\r\n"];
    [bodyString appendFormat:@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n"];
    [bodyString appendFormat:@"aaa%@.jpg\r\n",fileName];
    
    //(2)PostID
//    [bodyString appendFormat:@"--%@\r\n",boundry];
//    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"PostID\"\r\n"];
//    [bodyString appendFormat:@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n"];
//    [bodyString appendFormat:@"%@\r\n",self.uuID];
    
    //(3)pic
    [bodyString appendFormat:@"--%@\r\n",boundry];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n",fileName];
    [bodyString appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
    //[bodyString appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    //3.string --> data
    NSMutableData *bodyData = [NSMutableData data];
    //拼接的过程
    //前面的bodyString, 其他参数
    [bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    //图片数据
    [bodyData appendData:fileData];
    
    //4.结束的分隔线
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundry];
    //拼接到bodyData最后面
    [bodyData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bodyData;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    CGFloat progress = totalBytesSent * 1.0 / totalBytesExpectedToSend;
    NSLog(@"上传进度:%f%%",progress*100);
    
}

/*
 上传成功
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"上传成功! Error:%@",error);
}

@end
