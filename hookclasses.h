#ifndef __HOOKCLASSES_H
#define __HOOKCLASSES_H

#import <OpenGLES/ES1/gl.h>

// ---------------------------
// Cocos2D Classes and Structs
// ---------------------------
typedef struct _ccColor3B {
    GLubyte r;
    GLubyte g;
    GLubyte b;
} ccColor3B;

static inline ccColor3B
ccc3(const GLubyte r, const GLubyte g, const GLubyte b) {
    ccColor3B c = {r, g, b};
    return c;
}

//ccColor3B predefined colors {
#define ccWHITE ccc3(255,255,255)
#define ccYELLOW ccc3(255,255,0)
#define ccBLUE ccc3(0,0,255)
#define ccGREEN ccc3(0,255,0)
#define ccRED ccc3(255,0,0)
#define ccMAGENTA ccc3(255,0,255)
#define ccBLACK ccc3(0,0,0)
#define ccORANGE ccc3(255,127,0)
#define ccGRAY ccc3(166,166,166)
//}

#define kEventHandled YES

@interface CCDirector : NSObject
-(CGPoint)convertToUI:(CGPoint)ui;
-(CGPoint)convertToGL:(CGPoint)gl;
@end

@interface CCArray : NSObject
@end

@interface CCCamera : NSObject 
@end

@interface CCGridBase : NSObject 
@end

@interface CCNode : NSObject
@property(assign, nonatomic) BOOL isRelativeAnchorPoint;
@property(assign, nonatomic) BOOL visible;
@property(assign, nonatomic) CCNode* parent;
@property(assign, nonatomic) CGPoint anchorPoint;
@property(assign, nonatomic) CGPoint position;
@property(assign, nonatomic) CGPoint positionInPixels;
@property(assign, nonatomic) CGSize contentSize;
@property(assign, nonatomic) CGSize contentSizeInPixels;
@property(assign, nonatomic) float rotation;
@property(assign, nonatomic) float scale;
@property(assign, nonatomic) float scaleX;
@property(assign, nonatomic) float scaleY;
@property(assign, nonatomic) float skewX;
@property(assign, nonatomic) float skewY;
@property(assign, nonatomic) float vertexZ;
@property(assign, nonatomic) int tag;
@property(assign, nonatomic) void* userData;
@property(readonly, assign, nonatomic) BOOL isRunning;
@property(readonly, assign, nonatomic) CCArray* children;
@property(readonly, assign, nonatomic) CCCamera* camera;
@property(readonly, assign, nonatomic) CGPoint anchorPointInPixels;
@property(readonly, assign, nonatomic) int zOrder;
@property(retain, nonatomic) CCGridBase* grid;
-(CGPoint)convertToNodeSpace:(CGPoint)nodeSpace;
-(CGPoint)convertToNodeSpaceAR:(CGPoint)nodeSpaceAR;
-(CGPoint)convertTouchToNodeSpace:(id)nodeSpace;
-(CGPoint)convertTouchToNodeSpaceAR:(id)nodeSpaceAR;
-(CGPoint)convertToWindowSpace:(CGPoint)windowSpace;
-(CGPoint)convertToWorldSpace:(CGPoint)worldSpace;
-(CGPoint)convertToWorldSpaceAR:(CGPoint)worldSpaceAR;
-(CGRect)boundingBox;
-(CGRect)boundingBoxInPixels;
@end

@interface CCLayer : CCNode
@end

@interface CCSpriteBatchNode : CCNode 
@end

@interface CCSprite : CCNode
// @property(assign, nonatomic) ccBlendFunc blendFunc;
@property(readonly, assign, nonatomic) CGPoint offsetPositionInPixels;
@property(assign, nonatomic) int honorParentTransform;
@property(assign, nonatomic) CCSpriteBatchNode* batchNode;
// @property(assign, nonatomic) CCTextureAtlas* textureAtlas;
@property(assign, nonatomic) BOOL usesBatchNode;
@property(assign, nonatomic) ccColor3B color;
@property(assign, nonatomic) unsigned char opacity;
@property(assign, nonatomic) BOOL flipY;
@property(assign, nonatomic) BOOL flipX;
@property(readonly, assign, nonatomic) BOOL textureRectRotated;
@property(readonly, assign, nonatomic) CGRect textureRect;
@property(assign, nonatomic) unsigned atlasIndex;
// @property(readonly, assign, nonatomic) ccV3F_C4B_T2F_Quad quad;
@property(assign, nonatomic) BOOL dirty;
@property(retain) id texture;
@end

@interface CCLabelBMFont : CCSpriteBatchNode
@property(assign, nonatomic) ccColor3B color;
@property(assign, nonatomic) unsigned char opacity;
@property(retain) id string;
@end

@interface CCMenu : CCLayer
@end

@interface CCMenuItem : CCNode
@property(readonly, assign, nonatomic) BOOL isSelected;
@property(assign) BOOL isEnabled;
+(id)itemWithBlock:(id)block;
+(id)itemWithTarget:(id)target selector:(SEL)selector;
// declared property getter: -(BOOL)isSelected;
-(CGRect)rect;
// converted property getter: -(BOOL)isEnabled;
// converted property setter: -(void)setIsEnabled:(BOOL)enabled;
-(void)activate;
-(void)unselected;
-(void)selected;
// inherited: -(void)dealloc;
-(id)initWithBlock:(id)block;
-(id)initWithTarget:(id)target selector:(SEL)selector;
// inherited: -(id)init;
@end

// ---------------------------------
// Pocket Planes Classes and Structs
// ---------------------------------
@interface PPPlayerData : NSObject
@property(retain, nonatomic) NSMutableArray* cities;
@property(retain, nonatomic) NSMutableArray* events;
@property(retain, nonatomic) NSMutableArray* hangerPlanes;
@property(retain, nonatomic) NSMutableArray* parts;
@property(retain, nonatomic) NSMutableArray* planes;
@property(retain, nonatomic) NSMutableArray* trips;
@end

@interface PPScene : CCLayer
@property(retain) PPPlayerData* playerData;
@end

@interface PPList : CCLayer
@property(readonly, assign, getter=isDragging) BOOL dragging;	// converted property
@end

@interface PPCargoInfo : NSObject
@property(assign, nonatomic) BOOL is_vip;
@property(assign, nonatomic) BOOL on_layover;
@property(assign, nonatomic) BOOL on_plane;
@property(assign, nonatomic) double first_board;
@property(assign, nonatomic) int cargo_id;
@property(assign, nonatomic) int end_city_id;
@property(assign, nonatomic) int num_hops;
@property(assign, nonatomic) int start_city_id;
@property(assign, nonatomic) unsigned seed;
@property(retain, nonatomic) id cargo;
@property(retain, nonatomic) NSString* details;
@property(retain, nonatomic) NSString* type;
@end

@interface PPCityInfo : NSObject
@property(assign, nonatomic) BOOL hasActiveEvent;
@property(assign, nonatomic) BOOL hasEvent;
@property(assign, nonatomic) BOOL isClosed;
@property(assign, nonatomic) BOOL isDest;
@property(assign, nonatomic) BOOL isFaded;
@property(assign, nonatomic) BOOL isLocked;
@property(assign, nonatomic) BOOL needRedraw;
@property(assign, nonatomic) BOOL showPlaneCount;
@property(assign, nonatomic) CGPoint labelPos;
@property(assign, nonatomic) CGPoint position;
@property(assign, nonatomic) double lastCampaign;
@property(assign, nonatomic) double population;
@property(assign, nonatomic) int cargo_in;
@property(assign, nonatomic) int cargo_out;
@property(assign, nonatomic) int city_id;
@property(assign, nonatomic) int class_lvl;
@property(assign, nonatomic) int closureEvent;
@property(assign, nonatomic) int flights_in;
@property(assign, nonatomic) int flights_out;
@property(assign, nonatomic) int flights_total;
@property(assign, nonatomic) int level;
@property(assign, nonatomic) int pass_in;
@property(assign, nonatomic) int pass_out;
@property(assign, nonatomic) int scenery_id;
@property(retain, nonatomic) NSMutableArray* cargo;
@property(retain, nonatomic) NSString* cc;
@property(retain, nonatomic) NSString* factoid;
@property(retain, nonatomic) NSString* name;
@property(retain, nonatomic) NSString* region;
@end

@interface PPCity : CCNode
@property(readonly, assign) PPCityInfo* info;
@end

@interface PPCityEventInfo: NSObject
@property(assign, nonatomic) BOOL active;
@property(assign, nonatomic) BOOL alert;
@property(assign, nonatomic) BOOL isGlobal;
@property(assign, nonatomic) BOOL isWeather;
@property(assign, nonatomic) double chance;
@property(assign, nonatomic) double closeCity;
@property(assign, nonatomic) double endTime;
@property(assign, nonatomic) int city_id;
@property(assign, nonatomic) int duration;
@property(assign, nonatomic) int event_id;
@property(assign, nonatomic) int event_info_id;
@property(assign, nonatomic) int max_duration;
@property(assign, nonatomic) int plane_part;
@property(retain, nonatomic) NSMutableArray* zones;
@property(retain, nonatomic) NSString* airport_effects;
@property(retain, nonatomic) NSString* cargo_in;
@property(retain, nonatomic) NSString* cargo_out;
@property(retain, nonatomic) NSString* name;
@property(retain, nonatomic) NSString* pass_in;
@property(retain, nonatomic) NSString* pass_out;
@end

@interface PPMapLayer : CCLayer
@property(assign, nonatomic) BOOL tripPicker;
@end

@interface PPPlaneInfo : NSObject
@property(assign, nonatomic) CGPoint cockpit;
@property(assign, nonatomic) double distance_traveled;
@property(assign, nonatomic) double longest_flight;
@property(assign, nonatomic) double most_hops;
@property(assign, nonatomic) double most_profit;
@property(assign, nonatomic) double range;
@property(assign, nonatomic) double speed;
@property(assign, nonatomic) double total_flight_time;
@property(assign, nonatomic) double total_profit;
@property(assign, nonatomic) double total_revenue;
@property(assign, nonatomic) double weight;
@property(assign, nonatomic) float sortVal;
@property(assign, nonatomic) int cargoRows;
@property(assign, nonatomic) int class_lvl;
@property(assign, nonatomic) int engine;
@property(assign, nonatomic) int engineUpgrade;
@property(assign, nonatomic) int hotdog;
@property(assign, nonatomic) int level;
@property(assign, nonatomic) int passRows;
@property(assign, nonatomic) int plane_id;
@property(assign, nonatomic) int plane_info_id;
@property(assign, nonatomic) int price;
@property(assign, nonatomic) int tankUpgrade;
@property(assign, nonatomic) int totalRows;
@property(assign, nonatomic) int trips_complete;
@property(assign, nonatomic) int weightUpgrade;
@property(retain, nonatomic) NSMutableArray* cargo;
@property(retain, nonatomic) NSMutableArray* layout;
@property(retain, nonatomic) NSMutableArray* propellers;
@property(retain, nonatomic) NSString* cabinLayout;
@property(retain, nonatomic) NSString* costumes;
@property(retain, nonatomic) NSString* name;
@property(retain, nonatomic) NSString* paint;
@property(retain, nonatomic) NSString* planeName;
@property(retain, nonatomic) NSString* upgrades;

//%new methods
-(PPPlaneType)planeType;
@end

@interface PPPlanePartInfo : NSObject
@property(assign, nonatomic) double ship_time;
@property(assign, nonatomic) float sortVal;
@property(assign, nonatomic) int part_id;
@property(assign, nonatomic) int part_idx;
@property(assign, nonatomic) int plane_info_id;
@property(assign, nonatomic) int price;
@end

@interface PPSpriteFactory : CCSprite
// inherited: +(id)spriteWithFile:(id)file;
+(int)pointScale;
+(int)scaleFactor;
@end

@interface PPMapPlane : CCNode
@property(assign, nonatomic) BOOL showRange;
@property(readonly, assign, nonatomic) PPPlaneInfo* info;
@end
//}
#endif
