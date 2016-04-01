# SANetwork

###简述
此类库是对[AFNetworking](https://github.com/AFNetworking/AFNetworking)的二次封装，主要思想是参照[RTNetworking](https://github.com/casatwy/RTNetworking)扩展书写的。  
若您对此类库问题有什么看法或建议，欢迎您的反馈！  

添加到你的工程：
<pre>
pod 'SANetwork'
</pre>
###全局配置
你可能需要设定的全局配置，设置之后使用起来会更方便
<pre><code>
/**
*  设定自己需要请求的URL
*/
[SANetworkAgent sharedInstance].mainBaseUrlString = @"你的主URL";
/**
*  当使用viceBaseUrlString时，请设定请求的SANetworkConfigProtocol中的viceBaseUrlString为YES
*/
[SANetworkAgent sharedInstance].viceBaseUrlString = @"你的备用URL";

[[SANetworkAgent sharedInstance] setBaseArgumentBlock:^NSDictionary *(){
/**
*  根据自己的接口中大部分接口所必须的参数，进行统一设定
*/
return @{@"username" : @"001",
@"password" : @"123"};
}];
[[SANetworkAgent sharedInstance] setBaseAuthenticationBlock:^BOOL(SANetworkRequest *networkRequest, id response){
/**
*  可根据networkRequest、response进行验证
*/
return YES;
}];

/**
*  根据自己的接口返回，自定义设置
*/
[SANetworkResponse setResponseMessageKey:@"设定msg的key"];
[SANetworkResponse setResponseCodeKey:@"设定statusCode的key"];
[SANetworkResponse setResponseContentDataKey:@"设定content数据的key"];
</code></pre>
这些全局的配置，你可以放在AppDelegate里的didFinishLaunchingWithOptions中

###离散式的请求封装

#####基本的请求配置
此类库是以离散式方式做的二次封装，也就是说需要针对每个请求创建了一个这个类，这个类需要继承`SANetworkRequest`并必须实现协议`SANetworkConfigProtocol`！  
就像这样  

	@interface ExpressRequest : SANetworkRequest<SANetworkConfigProtocol>

	- (instancetype)initWithType:(NSString *)expressType postId:(NSString *)postId;
	@end			
<pre><code>@implementation ExpressRequest

- (instancetype)initWithType:(NSString *)expressType postId:(NSString *)postId
{
    self = [super init];
    if (self) {
        self.requestArgument = @{
                                 @"type" : expressType,
                                 @"postid" : postId
                                 };
    }
    return self;
}

- (SARequestMethod)requestMethod {
    return SARequestMethodPost;
}

- (NSString *)apiMethodName {
    return @"query";
}

@ende>

</code></pre>
这两个协议方法，你在创建的请求类中必须实现 

	- (SARequestMethod)requestMethod
	- (NSString *)apiMethodName
创建请求实例，设置请求响应回调，执行请求

	ExpressRequest *expressRequest = [[ExpressRequest alloc] initWithType:self.typeTextField.text postId:self.postidTextField.text];
	expressRequest.responseDelegate = self;
    [expressRequest startRequest];
    
 实现协议`SANetworkResponseProtocol`中的方法，处理请求的响应结果


#####其他
此类库简单的封装了批量请求和链式请求以及请求的插件，有兴趣或有需要的同学可以看看

