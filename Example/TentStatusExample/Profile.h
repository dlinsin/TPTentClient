#import <Foundation/Foundation.h>

@interface Profile : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *avatar_url;

- (id)initWithDictionary:(NSDictionary *)data;

@end