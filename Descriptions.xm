#import "Tweak.h"

%hook CCLabelBMFont
-(NSString*)description {
    return formatString(@"<CCLabelBMFont %@(%p)", [self string], self);
}
%end

%hook PPBitizen
-(NSString*)description {
    return formatString(@"<PPBitizen: %@(%p)>", [self name], self);
}
%end

%hook PPCity
-(NSString*)description {
    return formatString(@"<PPCity: %@(%p)>", [[self info] name], self);
}
%end

%hook PPCityClosure
-(NSString*)description {
    return formatString(@"<PPCityClosure: %@(%p)>", [self name], self);
}
%end

%hook PPCityEventInfo
-(NSString*)description {
    return formatString(@"<PPCityEventInfo: %@(%p)>", [self name], self);
}
%end

%hook PPCityInfo
-(NSString*)description {
    return formatString(@"<PPCityInfo: %@(%p)>", [self name], self);
}
%end

%hook PPCostumeInfo
-(NSString*)description {
    return formatString(@"<PPCostumeInfo: %@(%p)>", [self name], self);
}
%end

%hook PPCrate
-(NSString*)description {
    return formatString(@"<PPCrate: %@(%p)>", [self name], self);
}
%end

%hook PPCrateInfo
-(NSString*)description {
    return formatString(@"<PPCrateInfo: %@(%p)>", [self name], self);
}
%end

%hook PPPlaneInfo
-(NSString*)description {
    return formatString(@"<PPPlaneInfo: %@(%p)>", [self name], self);
}
%end

%hook PPPlanePartInfo
-(NSString*)description {
    return formatString(@"<PPPlanePartInfo: %@(%p)>", [self partName], self);
}
%end
