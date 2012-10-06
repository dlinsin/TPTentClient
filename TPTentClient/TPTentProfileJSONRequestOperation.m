#import "TPTentProfileJSONRequestOperation.h"

@implementation TPTentProfileJSONRequestOperation

+ (NSSet *)acceptableContentTypes {
    NSMutableSet *acceptableContentType = [NSMutableSet setWithSet:[super acceptableContentTypes]];
    [acceptableContentType addObject:@"application/vnd.tent.v0+json"];
    return acceptableContentType;
}


+ (TPTentProfileJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure {
    TPTentProfileJSONRequestOperation *requestOperation = [[self alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    }                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error, [(AFJSONRequestOperation *) operation responseJSON]);
        }
    }];

    return requestOperation;
}

@end