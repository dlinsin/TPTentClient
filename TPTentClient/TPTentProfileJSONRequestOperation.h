// Simply adds Tent's application/vnd.tent.v0+json to the acceptable content types

#import "AFNetworking.h"

@interface TPTentProfileJSONRequestOperation : AFJSONRequestOperation

+ (TPTentProfileJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure;

@end