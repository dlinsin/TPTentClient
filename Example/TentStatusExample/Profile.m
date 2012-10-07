#import "Profile.h"


@implementation Profile

- (id)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *basicInfo = [data objectForKey:@"https://tent.io/types/info/basic/v0.1.0"];
        self.name = [basicInfo objectForKey:@"name"];
        self.bio = [basicInfo objectForKey:@"bio"];
        self.avatar_url = [basicInfo objectForKey:@"avatar_url"];
    }
    return self;
}

@end