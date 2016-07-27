# SANetwork

## 简述
此类库是对[AFNetworking](https://github.com/AFNetworking/AFNetworking)的二次封装，主要思想是参照[RTNetworking](https://github.com/casatwy/RTNetworking)扩展书写的。  
若您对此类库问题有什么看法或建议，欢迎您的反馈！  

添加到你的工程：
<pre>
pod 'SANetwork'
</pre>

----
## 使用
#### 全局配置
你可能需要设定的全局配置，设置之后使用起来会更方便

##### 设定自己需要请求的URL

```
[SANetworkConfig sharedInstance].mainBaseUrlString = @"你的主URL";
[SANetworkConfig sharedInstance].viceBaseUrlString = @"你的备用URL";
```
当使用 `viceBaseUrlString` 时，请设定请求的 SANetworkRequestConfigProtocol 中的 `useViceURL` 为 YES 。		

##### 统一设定请求头(部分)参数

```
[[SANetworkConfig sharedInstance] setBaseHTTPRequestHeadersBlock:^ NSDictionary *(){
    return @{
             @"system" : @"iOS 9.0",
             @"version" : @"1.0.0",
             @"time" : @"2016-06-04 14:18:05",
             @"token" : @"8046DB4D7844617E0F9EC72A46CE4317",
             };
}];
```
一旦设定有值，默认每个请求都会合并使用这个请求头参数，你可通过 SANetworkRequestConfigProtocol 中的 `useBaseHTTPRequestHeaders` 方法来决定单个的请求是否使用。
你也可以通过 SANetworkRequestConfigProtocol 中的 `customHTTPRequestHeaders` 来定制单个请求的请求头。最终的请求头将会合并你所设定的值。

##### 统一设定请求(部分)参数

```
[[SANetworkConfig sharedInstance] setBaseParamSourceBlock:^NSDictionary *(){
    //根据自己的接口中大部分接口所必须的参数，进行统一设定
    return @{
             @"username" : @"001",
             @"password" : @"123"
             };
}];
```
一旦设定有值，默认每个请求都会合并使用这个基础请求参数，你可以通过 SANetworkRequestConfigProtocol 中的 `useBaseRequestParamSource` 方法来决定是否合并使用这里设定的基础参数。

##### 统一验证响应数据是否有效

```
[[SANetworkConfig sharedInstance] setBaseAuthenticationBlock:^BOOL(SANetworkRequest *networkRequest, id response){
    //可根据networkRequest、response进行验证。这里书写你的验证逻辑标准。
    if(response[@"sign"] == nil) {
        return NO;
    }
    return YES;
}];
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
[SANetworkConfig sharedInstance].responseMessageKey = @"msg";
[SANetworkConfig sharedInstance].responseCodeKey = @"code";
[SANetworkConfig sharedInstance].responseContentDataKey = @"data";
```
这样设定之后，你就可以通过 SANetworkResponse 对象直接拿到你想要的数据（responseContentData、responseCode、responseMessage）。

请根据自己需求灵活运用这些全局的配置，你可以将这些配置放在 AppDelegate 里的 `didFinishLaunchingWithOptions` 中

----
#### 解读Protocol

##### SANetworkConfigProtocol  每个请求类都必须实现此协议！

说明一下请求必须实现的两个方法：

1、设定请求的方法名

```
- (NSString *)requestMethodName;
```
你可以理解为请求的路径。你也可以设定为完整的带有http的请求地址，若设定为带有http的请求地址，请求将会忽略SANetworkConfig设置的url。

2、验证返回的数据是否正确

```
- (BOOL)isCorrectWithResponseData:(id)responseData;
```
返回数据在这里处理好，将可以让你在调用接口时，更加方便，处理的事务更少。

此协议还可配置

```
- (SARequestMethod)requestMethod;                           //请求方式
- (BOOL)shouldCacheResponse;                                //是否缓存
- (NSTimeInterval)requestTimeoutInterval;                   //请求超时时间
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;  //请求参数是否正确
- (SARequestSerializerType)requestSerializerType;           //请求的requestSerializerType
- (SAResponseSerializerType)responseSerializerType;         //请求的responseSerializerType
- (AFConstructingBlock)constructingBodyBlock;               //文件等富文本的上传
- (BOOL)shouldCancelPreviousRequest;                        //是否取消正在执行的前一个相同方法的请求（参数可能不同）
- (BOOL)useViceURL;                                         //是否使用副Url
- (BOOL)useBaseRequestParamSource;                          //是否使用基础参数
- (BOOL)useBaseHTTPRequestHeaders;                          //是否使用基础的请求头参数
- (NSDictionary *)customHTTPRequestHeaders;                 //定制请求头
- (BOOL)useBaseAuthentication;                              //是否使用基础的请求验证
```

##### SANetworkRequestParamSourceProtocol
配置请求参数

```
- (NSDictionary *)requestParamDictionary;
```
将一个参数配置单独使用一个协议来定义，是为了你可以在请求类中去实现或是在其他类(比如控制器类)中实现，这样你可能会觉得配置参数更加灵活一些。

##### SANetworkResponseProtocol

请求的回调，主要说下请求成功的回调


	- (void)networkRequest:(SANetworkRequest *)networkRequest succeedByResponse:(SANetworkResponse *)response;

当请求允许缓存的话，此回调方法在有缓存并请求成功的情况下，会调用两次，请在此回调中根据 response 的isCache 或 networkStatus 属性 做判断处理。

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
	
	- (void)networkRequestAccessoryDidStop {
	    [self.hud hide:YES afterDelay:0.3f];
	}
	
	@end
	

#####SANetworkInterceptorProtocol

这是一个请求返回之后，针对请求**成功之前**、**成功之后**、**失败之前**、**失败之后**进行拦截，你可以在这些拦截方法处理你的事务。

---
#### 构建请求
此类库是以离散式方式做的二次封装，需要针对每个请求创建一个请求类。

##### 书写请求
请求类需要继承`SANetworkRequest`并必须实现协议`SANetworkConfigProtocol`！  
对于请求参数的配置，你可以在SANetworkRequest的子类中配置，亦可以在业务中配置，配置需要实现`SANetworkRequestParamSourceProtocol`


就像这样（在Bejson上找的两个接口）

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	    [SANetworkConfig sharedInstance].mainBaseUrlString = @"http://www.kuaidi100.com";
	    [SANetworkConfig sharedInstance].enableDebug = YES;  //允许后台打印输出
	}  
	
快递100的查询：

	@interface ExpressRequest : SANetworkRequest<SANetworkConfigProtocol,SANetworkParamSourceProtocol>
	@property (nonatomic, copy) NSString *type;
	@property (nonatomic, copy) NSString *postId;
	@end			

	@implementation ExpressRequest
	
	- (instancetype)init
	{
	    self = [super init];
	    if (self) {
	        self.requestParamSourceDelegate = self;
	    }
	    return self;
	}
	
	- (NSString *)requestMethodName {
	    return @"query";
	}
	
	- (BOOL)isCorrectWithResponseData:(id)responseData {
	    if (responseData) {
	        return YES;
	    }
	    return NO;
	}
	
	- (SARequestMethod)requestMethod {
	    return SARequestMethodPost;
	}
	
	- (SAResponseSerializerType)responseSerializerType {
	    return SAResponseSerializerTypeHTTP;
	}
	
	- (NSDictionary *)requestParamDictionary {
	    return @{
	             @"type" : self.type,
	             @"postid" : self.postId
	             };
	}
	
	@end
	
淘宝手机号信息的查询：

	@interface UserInfoRequest : SANetworkRequest<SANetworkRequestConfigProtocol,SANetworkRequestParamSourceProtocol>
	@property (nonnull, nonatomic, strong) NSString *mobile;
	@end

	
	@implementation UserInfoRequest
	
	- (instancetype)init
	{
	    self = [super init];
	    if (self) {
	        self.requestParamSourceDelegate = self;
	    }
	    return self;
	}
	
	- (NSString *)requestMethodName {
	    return @"http://chengdu.fbbfc.com/api/getUserInfo";
	}
	
	- (BOOL)isCorrectWithResponseData:(id)responseData {
	    if (responseData) {
	        return YES;
	    }
	    return NO;
	}
	
	- (SARequestMethod)requestMethod {
	    return SARequestMethodPost;
	}
	
	- (NSDictionary *)requestParamDictionary {
	    return @{
	             @"mobile" : self.mobile,
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
批量请求的对象，请务必将批量请求对象创建为类的一个属性，并将创建的批量请求对象赋给定义的属性。

    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Batch Loading..."];
    UserInfoRequest *userInfoRequest = [[UserInfoRequest alloc] init];
    userInfoRequest.mobile = @"13173610819";
    
    ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
    expressRequest.type = @"yuantong";
    expressRequest.postId = @"881443775034378914";
    
    SANetworkBatchRequest *batchRequest = [[SANetworkBatchRequest alloc] initWithRequestArray:@[userInfoRequest,expressRequest]];
    [batchRequest addNetworkAccessoryObject:hudAccessory];
    [batchRequest startBatchRequest];
    _batchRequest = batchRequest;

将要发起的请求装载到一个数组中，然后作为初始化的参数来完成批量请求对象的创建。你可以通过 `isContinueByFailResponse` 属性的设定，来决定当某一个请求错误时，其他请求是否继续。

##### 发起链式请求
与批量一样，链式请求的对象，请务必将链式请求对象创建为类的一个属性，并将创建的链式请求对象赋给定义的属性。
对于链式请求，说一个场景便于大家理解：用户登录，登录成功之后获取用户关联的信息。若在登录成功之后就想获取到用户关联的信息，就可以使用链式请求。

    SANetworkHUDAccessory *hudAccessory = [[SANetworkHUDAccessory alloc] initWithShowInView:self.view text:@"Chain Loading..."];
    UserInfoRequest *userInfoRequest = [[UserInfoRequest alloc] init];
    userInfoRequest.mobile = @"13173610819";
    SANetworkChainRequest *chainRequest = [[SANetworkChainRequest alloc] initWithRootNetworkRequest:userInfoRequest];
    chainRequest.delegate = self;
    [chainRequest addNetworkAccessoryObject:hudAccessory];
    [chainRequest startChainRequest];
    _chainRequest = chainRequest;
  
  用要发起的第一个请求作为链式请求初始化的参数来完成链式请求对象的创建。第二请求或之后的请求，是通过链式请求的代理返回的。
    
	- (__kindof SANetworkRequest *)networkChainRequest:(SANetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof SANetworkRequest *)request finishedByResponse:(SANetworkResponse *)response {
	    //这里的判断逻辑请求根据自己的业务逻辑灵活处理
	    if (response != nil && [request isKindOfClass:[UserInfoRequest class]]) {
	        ExpressRequest *expressRequest = [[ExpressRequest alloc] init];
	        expressRequest.type = @"yuantong";
	        expressRequest.postId = @"881443775034378914";
	        return expressRequest;
	    }
	    return nil;
	}
	
 这个回调是早前一个请求成功时被触发，你可以在这个回调里你决定你下一个要执行的请求。失败会调用另一个代理方法。
 
-----	
## 写出你们能看懂的代码（而不只是机器能读懂的代码）

封装的批量请求和链式请求的根本还是单个的请求，所以不要一味去思考要不要用这两种类型的请求。

我只想大家用着舒服，用着没问题就好！大家有问题或建议，请与我沟通。
