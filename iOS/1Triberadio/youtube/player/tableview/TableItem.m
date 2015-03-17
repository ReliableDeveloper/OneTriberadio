//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "common.h"

#import "TableItem.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@implementation tableItem

@synthesize itemid, colorBack, image1, image2, image3, lines1, text1, font1, color1, lines2, text2, font2, color2, accessory, selection;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)ItemId
	 ColorBack:(UIColor *)ColorBack
		Image1:(NSString *)Image1 Image2:(NSString *)Image2 Image3:(NSString *)Image3
		Lines1:(NSInteger)Lines1 Text1:(NSString *)Text1 Font1:(UIFont *)Font1 Color1:(UIColor *)Color1
		Lines2:(NSInteger)Lines2 Text2:(NSString *)Text2 Font2:(UIFont *)Font2 Color2:(UIColor *)Color2
	 Accessory:(BOOL)Accessory Selection:(BOOL)Selection
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	itemid		= ItemId;
	colorBack	= ColorBack;
	image1		= Image1;
	image2		= Image2;
	image3		= Image3;
	lines1		= Lines1;
	text1		= Text1;
	font1		= Font1;
	color1		= Color1;
	lines2		= Lines2;
	text2		= Text2;
	font2		= Font2;
	color2		= Color2;
	accessory	= Accessory;
	selection	= Selection;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemHeader(NSString *text) {
	return [[tableItem alloc] initWith:nil
							 ColorBack:COLOR_HEADER
								Image1:nil Image2:nil Image3:nil
								Lines1:1 Text1:text Font1:[UIFont fontWithName:FONT_BOLD size:18] Color1:[UIColor whiteColor]
								Lines2:0 Text2:nil Font2:nil Color2:nil
							 Accessory:NO Selection:NO]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemMenu(NSString *text) {
	return [[tableItem alloc] initWith:nil
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:1 Text1:text Font1:[UIFont fontWithName:FONT_MEDIUM size:18] Color1:nil
								Lines2:0 Text2:nil Font2:nil Color2:nil
							 Accessory:NO Selection:YES]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemMenuIcon(NSString *text) {
	NSString *file = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"png" inDirectory:@"icon"];
	return [[tableItem alloc] initWith:nil
							 ColorBack:nil
								Image1:nil Image2:nil Image3:path
								Lines1:1 Text1:text Font1:[UIFont fontWithName:FONT_MEDIUM size:18] Color1:nil
								Lines2:0 Text2:nil Font2:nil Color2:nil
							 Accessory:NO Selection:YES]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemMenuYellow(NSString *text) {
	return [[tableItem alloc] initWith:nil
							 ColorBack:[UIColor yellowColor]
								Image1:nil Image2:nil Image3:nil
								Lines1:1 Text1:text Font1:[UIFont fontWithName:FONT_BOLD size:18] Color1:nil
								Lines2:0 Text2:nil Font2:nil Color2:nil
							 Accessory:NO Selection:YES]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemMenuId(NSString *itemid, NSString *text) {
	return [[tableItem alloc] initWith:itemid
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:1 Text1:text Font1:[UIFont fontWithName:FONT_MEDIUM size:18] Color1:nil
								Lines2:0 Text2:nil Font2:nil Color2:nil
							 Accessory:NO Selection:YES]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemApp(NSString *itemid, NSString *image, NSString *text1, NSString *text2) {
	return [[tableItem alloc] initWith:itemid
							 ColorBack:nil
								Image1:image Image2:@"blankapp" Image3:nil
								Lines1:1 Text1:text1 Font1:[UIFont fontWithName:FONT_BOLD size:14] Color1:nil
								Lines2:1 Text2:text2 Font2:[UIFont fontWithName:FONT_NORMAL size:12] Color2:[UIColor lightGrayColor]
							 Accessory:NO Selection:YES]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemAppDesc(NSInteger lines, NSString *text, BOOL select) {
	return [[tableItem alloc] initWith:@"Description"
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:lines Text1:text Font1:[UIFont fontWithName:FONT_NORMAL size:12] Color1:nil
								Lines2:0 Text2:nil Font2:nil Color2:nil
							 Accessory:NO Selection:select]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemChat(NSString *name, NSString *text, BOOL myself) {
	UIColor *color = myself ? [UIColor blueColor] : [UIColor lightGrayColor];
	return [[tableItem alloc] initWith:nil
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:1 Text1:name Font1:[UIFont fontWithName:FONT_BOLD size:12] Color1:color
								Lines2:0 Text2:text Font2:[UIFont fontWithName:FONT_NORMAL size:14] Color2:nil
							 Accessory:NO Selection:NO]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemDetail(NSString *text) {
	return [[tableItem alloc] initWith:nil
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:0 Text1:nil Font1:nil Color1:nil
								Lines2:0 Text2:text Font2:[UIFont fontWithName:FONT_NORMAL size:14] Color2:nil
							 Accessory:NO Selection:NO]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemDetailBold(NSString *text) {
	return [[tableItem alloc] initWith:nil
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:0 Text1:nil Font1:nil Color1:nil
								Lines2:0 Text2:text Font2:[UIFont fontWithName:FONT_BOLD size:14] Color2:nil
							 Accessory:NO Selection:NO]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
tableItem* itemCombined(NSString *text1, NSString *text2) {
	return [[tableItem alloc] initWith:nil
							 ColorBack:nil
								Image1:nil Image2:nil Image3:nil
								Lines1:0 Text1:text1 Font1:[UIFont fontWithName:FONT_BOLD size:14] Color1:nil
								Lines2:0 Text2:text2 Font2:[UIFont fontWithName:FONT_NORMAL size:14] Color2:nil
							 Accessory:NO Selection:NO]; }
//-------------------------------------------------------------------------------------------------------------------------------------------------
