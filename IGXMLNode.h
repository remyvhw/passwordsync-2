//
//  IGXMLNode.h
//  IGHTMLQuery
//
//  Created by Francis Chong on 20/8/13.
//  Copyright (c) 2013 Ignition Soft. All rights reserved.
//

#import <libxml2/libxml/xmlreader.h>
#import <libxml2/libxml/xmlmemory.h>
#import <libxml2/libxml/xmlerror.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#import <Foundation/Foundation.h>

#import "IGXMLNodeSet.h"
#import "IGXMLNodeManipulation.h"
#import "IGXMLNodeQuery.h"

extern NSString* const IGXMLQueryErrorDomain;
extern NSString* const IGXMLNodeException;

@class IGXMLDocument;

@interface IGXMLNode : NSObject <IGXMLNodeManipulation, IGXMLNodeQuery, NSCopying>

/**
 backed XML node,
 */
@property (nonatomic, readwrite, unsafe_unretained) xmlNodePtr node;

/**
 Create a node using a libxml node
 */
- (id)initWithXMLNode:(xmlNodePtr)node;

/**
 Create a node using a libxml node
 */
+ (id)nodeWithXMLNode:(xmlNodePtr)node;

/**
 @return get tag name of current node.
 */
- (NSString *)tag;

/**
 @param the new tag to set
 */
- (void)setTag:(NSString*)tag;

/**
 @return get text of current node.
 */
- (NSString *)text;

/**
 @param the new content of the node
 */
- (void) setText:(NSString*)text;

/**
 @return get XML of node;
 */
- (NSString *)xml;

/**
 @return get inner XML of node;
 */
- (NSString *)innerXml;

/**
 @return get last error.
 */
- (NSError*) lastError;

/**
 remove namespace of the document recursively.
 */
- (void)removeNamespaces;

@end

@interface IGXMLNode (Traversal)

/**
  @return get parent node
 */
- (IGXMLNode *) parent;

/**
 @return get next sibling node
 */
- (IGXMLNode *) nextSibling;

/**
 @return get previous sibling node
 */
- (IGXMLNode *) previousSibling;

/**
 @return get children elements of current node as {{IGXMLNodeSet}}.
 */
- (IGXMLNodeSet*) children;

/**
 @return get first child element of current node. If no child exists, return nil.
 */
- (IGXMLNode*) firstChild;

/**
 @return It returns a key guaranteed to be unique for this node, and to always be the same value for this node. In other words, two node objects return the same key if and only if isSameNode indicates that they are the same node.
 */
- (NSString*) uniqueKey;

@end

@interface IGXMLNode (Attributes)

/**
 @param attName attribute name to get
 @return attribute value
 */
- (NSString *)attribute:(NSString *)attName;

/**
 @param attName attribute name
 @param ns namespace
 @return attribute value
 */
- (NSString *)attribute:(NSString *)attName inNamespace:(NSString *)ns;

/**
 @param attName attribute name to set
 @param value value to set
 */
- (void) setAttribute:(NSString*)attName value:(NSString*)value;

/**
 @param attName attribute name to set
 @param ns namespace
 @param value value to set
 */
- (void) setAttribute:(NSString*)attName inNamespace:(NSString*)ns value:(NSString*)value;

/**
 @param attName attribute name to remove
 */
- (void) removeAttribute:(NSString*)attName;

/**
 @param attName attribute name to remove
 */
- (void) removeAttribute:(NSString*)attName inNamespace:(NSString*)ns;

- (NSArray *)attributeNames;

/**
 subscript support
 */
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end