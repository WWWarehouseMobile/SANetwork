# SANetwork

[![Version](https://img.shields.io/cocoapods/v/SANetwork.svg?style=flat)](http://cocoapods.org/pods/SANetwork)
[![License](https://img.shields.io/cocoapods/l/SANetwork.svg?style=flat)](http://cocoapods.org/pods/SANetwork)
[![Platform](https://img.shields.io/cocoapods/p/SANetwork.svg?style=flat)](http://cocoapods.org/pods/SANetwork)

## 简述
此库是对[AFNetworking](https://github.com/AFNetworking/AFNetworking)的二次封装，属于离散式接口封装。  
若您对此类库问题有什么看法或建议，欢迎您的反馈！  

添加到你的工程：
<pre>
pod 'SANetwork'
</pre>

----
## 使用

SANetwork大致结构
![](https://ooo.0o0.ooo/2017/06/13/593f5744482a8.png)


### 服务对象
#### 创建配置服务对象SANetworkServiceProtocol
SANetwork可配置不同服务环境的请求。这需要针对不同服务创建出不同的服务配置对象。


此服务配置对象需要实现协议`SANetworkServiceProtocol`

```
@required
- (NSString *)serviceApiBaseUrlString; // 服务接口地址的基础URL
- (NSSet<NSString *> *)serviceResponseAcceptableContentTypes; //服务接口 Acceptable-Content

@optional
- (SARequestSerializerType)serviceRequestSerializerType;
- (SAResponseSerializerType)serviceResponseSerializerType;
- (NSDictionary<NSString *,NSString *> *)serviceBaseHTTPRequestHeaders; //统一设定的请求头
- (NSDictionary<NSString *,NSString *> *)serviceBaseParamSource; //基本的请求参数
- (BOOL)serviceBaseAuthenticationWithNetworkRequest:(SANetworkRequest *)networkRequest response:(id)response; //统一验证拦截
- (NSTimeInterval)serviceRequestTimeoutInterval;

//以下特性化设置，方便从SANetworkResponse中获取值
- (NSString *)responseMessageKey;
- (NSString *)responseCodeKey;
- (NSString *)responseContentDataKey;
```

##### 统一设定请求头(部分)参数

```
- (NSDictionary<NSString *,NSString *> *)serviceBaseHTTPRequestHeaders {
    return @{
             @"system" : @"iOS 9.0",
             @"version" : @"1.0.0",
             @"time" : @"2016-06-04 14:18:05",
             @"token" : @"8046DB4D7844617E0F9EC72A46CE4317",
             };
};
```
一旦设定有值，默认每个请求都会合并使用这个请求头参数，你可通过 SANetworkRequestConfigProtocol 中的 `useBaseHTTPRequestHeaders` 方法来决定单个的请求是否使用。
你也可以通过 SANetworkRequestConfigProtocol 中的 `customHTTPRequestHeaders` 来定制单个请求的请求头。最终的请求头将会合并你所设定的值。

##### 统一设定请求(部分)参数

```
- (NSDictionary<NSString *,NSString *> *)serviceBaseParamSource{
    //根据自己的接口中大部分接口所必须的参数，进行统一设定
    return @{
             @"username" : @"001",
             @"password" : @"123"
             };
};
```
一旦设定有值，默认每个请求都会合并使用这个基础请求参数，你可以通过 SANetworkRequestConfigProtocol 中的 `useBaseRequestParamSource` 方法来决定是否合并使用这里设定的基础参数。

##### 统一验证响应数据是否有效

```
- (BOOL)serviceBaseAuthenticationWithNetworkRequest:(SANetworkRequest *)networkRequest response:(id)response{
    //可根据networkRequest、response进行验证。这里书写你的验证逻辑标准。
    if(response[@"sign"] == nil) {
        return NO;
    }
    return YES;
};
```
一旦设定有值，默认每个请求都会使用这个 Block 里的方法去验证请求到的数据，你可以通过 SANetworkRequestConfigProtocol 中的 `useBaseAuthentication` 方法来决定是否使用这个验证方法。

##### 设定返回数据第一层对应的key字段

比如服务端返回的数据：

```
{
"code" : "100",
"msg" : "请求成功",
"data" : [
			{"name" : "Paul","age" : "28"},
			{"name" : "James","age" : "27"}
		]
}

```
那么你可以做这样的设定

```
- (NSString *)responseMessageKey {
    return @"msg";
}
- (NSString *)responseCodeKey {
    return @"code";
}
- (NSString *)responseContentDataKey {
    return @"data";
}
```
这样设定之后，你就可以通过 SANetworkResponse 对象直接拿到你想要的数据（responseContentData、responseCode、responseMessage）。

请根据自己需求灵活运用这些服务的配置，你可以在 `didFinishLaunchingWithOptions` 中设置你的服务配置
    
    - (void)registerServiceObject:(NSObject<SANetworkServiceProtocol> *)serviceObject serviceIdentifier:(NSString *)serviceIdentifier;

构建服务配置对象

    @interface SATaobaoService : NSObject<SANetworkServiceProtocol>
    @end
    
    @implementation SATaobaoService
    
    - (NSString *)serviceApiBaseUrlString {
        return @"https://suggest.taobao.com/";
    }
    
    - (NSSet<NSString *> *)serviceResponseAcceptableContentTypes {
        return [NSSet setWithObjects:@"application/json",nil];
    }
    
    - (SARequestSerializerType)serviceRequestSerializerType {
        return SARequestSerializerTypeHTTP;
    }
    
    - (SAResponseSerializerType)serviceResponseSerializerType {
        return SAResponseSerializerTypeJSON;
    }
    
    - (NSDictionary<NSString *,NSString *> *)serviceBaseHTTPRequestHeaders {
        return nil;
    }
    
    - (NSDictionary<NSString *,NSString *> *)serviceBaseParamSource {
        return nil;
    }
    
    - (BOOL)serviceBaseAuthenticationWithResonse:(id)response {
        return YES;
    }
    
    - (NSTimeInterval)serviceRequestTimeoutInterval {
        return 20.0f;
    }
    
    /*******以下协议的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/
    
    - (NSString *)responseContentDataKey {
        return @"result";
    }
    @end

注册服务配置

    #import "SATaobaoService.h"
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [[SANetworkConfig sharedInstance]  registerServiceObject:[[SATaobaoService alloc] init] serviceIdentifier:@"TaoBaoIdentifierKey"];
    }

----
#### 解读SANetworkConfigProtocol  每个请求类都必须实现此协议！

说明一下请求必须实现的三个方法：
1、服务标示Key

    - (NSString *)serviceIdentifierKey;


属于哪个服务

2、设定请求的方法名

    - (NSString *)requestMethodName;

你可以理解为请求的路径。你也可以设定为完整的带有http的请求地址，若设定为带有http的请求地址，请求将会忽略SANetworkConfig设置的url。

3、验证返回的数据是否正确

```
- (BOOL)isCorrectWithResponseData:(id)responseData;
```
返回数据在这里处理好，将可以让你在调用接口时，更加方便，处理的事务更少。

此协议还可配置

```
- (SARequestMethod)requestMethod;                           //请求方式
- (NSDictionary *)requestParamDictionary;                   //配置请求参数
- (NSURLRequestCachePolicy)cachePolicy;                     //缓存策略，默认NSURLRequestUseProtocolCachePolicy
- (NSTimeInterval)requestTimeoutInterval;                   
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;  //请求参数是否正确
- (SARequestSerializerType)requestSerializerType;           
- (SAResponseSerializerType)responseSerializerType;         
- (NSSet <NSString *> *)responseAcceptableContentTypes;
- (AFConstructingBlock)constructingBodyBlock;               //文件等富文本的上传
- (SARequestHandleSameRequestType)handleSameRequestType;    //处理正在执行相同方法请求的方式
- (BOOL)useBaseRequestParamSource;                          //是否使用基础参数
- (BOOL)useBaseHTTPRequestHeaders;                          //是否使用基础的请求头参数
- (NSDictionary *)customHTTPRequestHeaders;                 //定制请求头
- (BOOL)useBaseAuthentication;                              //是否使用基础的请求验证
- (BOOL)enableDebugLog;
```

##### SANetworkResponse & SANetworkResponseProtocol

网络接口的结果数据会配置到`SANetworkResponse`对象中，SANetworkResponse对象提供属性:
    
    @property (nonatomic, copy, readonly) id responseData; //原始数据
    @property (nonatomic, assign, readonly) SANetworkStatus networkStatus; //网络接口状态
    @property (nonatomic, assign, readonly) NSInteger requestTag; //对应请求类的标示

SANetworkResponse还提供了数据改革的协议`SANetworkResponseReformerProtocol`和方法：

    @protocol SANetworkResponseReformerProtocol <NSObject>
    
    @required
    - (id)networkResponse:(SANetworkResponse *)networkResponse reformerDataWithOriginData:(id)originData;
    @end
    
    @interface SANetworkResponse : NSObject
    ...
    - (id)fetchDataWithReformer:(id<SANetworkResponseReformerProtocol>)reformer;
    ...
    @end


##### SANetworkAccessoryProtocol

我客观地定义了实现此协议的类为“插件”。这里所谓的“插件”就是跟踪请求的开始和结束，你可以插件类中实现这个协议，来处理请求开始和结束时的任务。
比如定制一个 `MBProgressHUD插件` ：

	
	@interface SANetworkHUDAccessory ()<SANetworkAccessoryProtocol>
	@property (nonatomic, strong) MBProgressHUD *hud;
	@end
	
	@implementation SANetworkHUDAccessory
	
	- (instancetype)initWithShowInView:(UIView *)view text:(NSString *)text{
	    self = [super init];
	    if (self) {
	        _hud = [[MBProgressHUD alloc] initWithView:view];
	        [view addSubview:_hud];
	        if (text) {
	            _hud.labelText = text;
	        }
	    }
	    return self;
	}
	
	- (void)networkRequestAccessoryWillStart {
	    [self.hud show:YES];
	}
	
	- (void)networkRequestAccessoryByStatus:(SANetworkStatus)networkStatus {
	    [self.hud hide:YES afterDelay:0.3f];
	}
	
	@end
	

##### SANetworkInterceptorProtocol

这是一个请求返回之后，针对请求**成功之前**、**成功之后**、**失败之前**、**失败之后**进行拦截，你可以在这些拦截方法处理你的事务。

---
#### 构建请求
此类库是以离散式方式做的二次封装，需要针对每个请求创建一个请求类。

##### 书写请求
**请求类需要继承`SANetworkRequest`并必须实现协议`SANetworkConfigProtocol`！**  



就像这样（在Bejson上找的两个接口）
	
快递100的查询：

	@interface ExpressRequest : SANetworkRequest<SANetworkConfigProtocol,SANetworkParamSourceProtocol>
	@property (nonatomic, copy) NSString *type;
	@property (nonatomic, copy) NSString *postId;
	@end			

	@implementation ExpressRequest
	
    - (NSString *)requestMethodName {
        return @"query";
    }
    
    - (NSString *)serviceIdentifierKey {
        return @"kuaidiServiceKey";
    }
    
    - (BOOL)isCorrectWithResponseData:(id)responseData {
        if (responseData) {
            return YES;
        }
        return NO;
    }
    
    - (NSDictionary *)requestParamDictionary {
        return @{
                 @"type" : self.type,
                 @"postid" : self.postId
                 };
    }
	@end
	
淘宝关键词建议查询：

    @interface TaobaoSuggestRequest : SANetworkRequest<SANetworkRequestConfigProtocol>
    /**查询条件*/
    @property (nonatomic, strong) NSString *query;
    @end

	
	@implementation TaobaoSuggestRequest

    - (NSString *)requestMethodName {
        return @"sug";
    }
    
    - (NSString *)serviceIdentifierKey {
        return @"TaoBaoIdentifierKey";
    }
    
    - (BOOL)isCorrectWithResponseData:(id)responseData {
        if (responseData) {
            return YES;
        }
        return NO;
    }
    
    - (SARequestMethod)requestMethod {
        return SARequestMethodGet;
    }
    
    - (NSSet<NSString *> *)responseAcceptableContentTypes {
        return [NSSet setWithObject:@"text/html"];
    }
    
    - (NSDictionary *)requestParamDictionary {
        return @{
                 @"code" : @"utf-8",
                 @"q" : self.query,
                 };
    }
    @end

	
##### 发起单个请求
**创建请求实例**，设置请求响应回调，执行请求

    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Loading..."];
	ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.type = @“yuantong”;
    expressRequest.postId = @"881443********8914";
    expressRequest.responseDelegate = self;
    [expressRequest addNetworkAccessoryObject:hudAccessory]; //添加hud插件
    [expressRequest startRequest];
    
 实现协议`SANetworkResponseProtocol`中的方法，处理请求的响应结果
 
##### 发起批量请求
批量请求的对象，**请务必将批量请求对象创建为类的一个属性**，并将创建的批量请求对象赋给定义的属性。

    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Batch Loading..."];
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";
      
    ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
      
    SANetworkBatchRequest *batchRequest = [[SANetworkBatchRequest alloc] initWithRequestArray:@[suggestRequest,expressRequest]];
    [batchRequest addNetworkAccessoryObject:hudAccessory];
    [batchRequest startBatchRequest];
    _batchRequest = batchRequest;

将要发起的请求装载到一个数组中，然后作为初始化的参数来完成批量请求对象的创建。

##### 发起链式请求
与批量一样，链式请求的对象，**请务必将链式请求对象创建为类的一个属性**，并将创建的链式请求对象赋给定义的属性。
对于链式请求，说一个场景便于大家理解：用户登录，登录成功之后获取用户关联的信息。若在登录成功之后就想获取到用户关联的信息，就可以使用链式请求。

    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Chain Loading..."];
    TaobaoSuggestRequest *suggestRequest = [[TaobaoSuggestRequest alloc] init];
    suggestRequest.query = @"iphone";

    SANetworkChainRequest *chainRequest = [[SANetworkChainRequest alloc] initWithRootNetworkRequest:suggestRequest];
    chainRequest.delegate = self;
    [chainRequest addNetworkAccessoryObject:hudAccessory];
    [chainRequest startChainRequest];
    _chainRequest = chainRequest;
  
  用要发起的第一个请求作为链式请求初始化的参数来完成链式请求对象的创建。第二请求或之后的请求，是通过链式请求的代理返回的。
    
	- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response {
	    //这里的判断逻辑请求根据自己的业务逻辑灵活处理
	    if (response != nil && [request isKindOfClass:[TaobaoSuggestRequest class]]) {
            ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
            expressRequest.type = @"yuantong";
            expressRequest.postId = @"881443775034378914";
            return expressRequest;
	    }
	    return nil;
	}
	
 这个回调是早前一个请求成功时被触发，你可以在这个回调里决定你下一个要执行的请求。失败会调用另一个失败的代理方法。
 
-----	

## 写出你能看懂的代码，而不只是机器能读懂的代码。


