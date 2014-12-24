//
//  AGAudioPlayerUpNextQueue.m
//  AGAudioPlayer
//
//  Created by Alec Gorge on 12/19/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AGAudioPlayerUpNextQueue.h"

@interface AGAudioPlayerUpNextQueue ()

@property (nonatomic) NSMutableArray *items;

@end

@implementation AGAudioPlayerUpNextQueue

- (id)init {
    if (self = [super init]) {
        self.items = NSMutableArray.array;
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items {
    if (self = [super init]) {
        self.items = NSMutableArray.array;
        
        [self appendItems:items];
    }
    return self;
}

- (NSInteger)count {
    return self.items.count;
}

- (void)appendItem:(AGAudioItem *)item {
    if(item == nil) return;
    
    [self.items addObject:item];
    
    if([self.delegate respondsToSelector:@selector(upNextQueueChanged:)]) {
        [self.delegate upNextQueueChanged:AGAudioPlayerUpNextQueueAddedItem];
    }
    
    if([self.delegate respondsToSelector:@selector(upNextQueue:addedItem:atIndex:)]) {
        [self.delegate upNextQueue:self
                         addedItem:item
                           atIndex:self.items.count - 1];
    }
}

- (void)appendItems:(NSArray *)items {
    for (AGAudioItem *i in items) {
        [self appendItem:i];
    }
}

- (void)prependItem:(AGAudioItem *)item {
    if(item == nil) return;
    
    [self.items insertObject:item
                     atIndex:0];
    
    if([self.delegate respondsToSelector:@selector(upNextQueueChanged:)]) {
        [self.delegate upNextQueueChanged:AGAudioPlayerUpNextQueueAddedItem];
    }
    
    if([self.delegate respondsToSelector:@selector(upNextQueue:addedItem:atIndex:)]) {
        [self.delegate upNextQueue:self
                         addedItem:item
                           atIndex:0];
    }
}

- (void)prependItems:(NSArray *)items {
    for (AGAudioItem *i in items) {
        [self prependItem:i];
    }
}

- (void)moveItem:(AGAudioItem *)item
         toIndex:(NSInteger)to {
    NSInteger from = [self.items indexOfObjectIdenticalTo:item];
    [self moveItemAtIndex:from
                  toIndex:to];
}

- (void)moveItemAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    [self.items exchangeObjectAtIndex:from
                    withObjectAtIndex:to];

    if([self.delegate respondsToSelector:@selector(upNextQueueChanged:)]) {
        [self.delegate upNextQueueChanged:AGAudioPlayerUpNextQueueSwappedItems];
    }
    
    if([self.delegate respondsToSelector:@selector(upNextQueue:swappedItem:atIndex:withItem:atIndex:)]) {
        [self.delegate upNextQueue:self
                       swappedItem:self.items[to] // swap has already taken place so use flipped indices
                           atIndex:from
                          withItem:self.items[from]
                           atIndex:to];
    }
}

- (void)clear {
    [self.items removeAllObjects];

    if([self.delegate respondsToSelector:@selector(upNextQueueChanged:)]) {
        [self.delegate upNextQueueChanged:AGAudioPlayerUpNextQueueRemovedAllItems];
    }
    
    if([self.delegate respondsToSelector:@selector(upNextQueueRemovedAllItems:)]) {
        [self.delegate upNextQueueRemovedAllItems:self];
    }
}

- (void)removeItem:(AGAudioItem *)item {
    if(item == nil) return;
    
    NSInteger idx = [self.items indexOfObjectIdenticalTo:item];
    
    if(idx == NSNotFound) return;
    
    [self removeItemAtIndex:idx];
}

- (void)removeItemAtIndex:(NSInteger)indx {
    AGAudioItem *old_value = self.items[indx];
    [self.items removeObjectAtIndex:indx];
    
    if([self.delegate respondsToSelector:@selector(upNextQueueChanged:)]) {
        [self.delegate upNextQueueChanged:AGAudioPlayerUpNextQueueRemovedItem];
    }
    
    if([self.delegate respondsToSelector:@selector(upNextQueue:removedItem:fromIndex:)]) {
        [self.delegate upNextQueue:self
                       removedItem:old_value
                         fromIndex:indx];
    }
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.items[idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    if (![obj isKindOfClass:AGAudioItem.class]) {
        [NSException raise:@"Invalid assignment value"
                    format:@"%@ is not an instance or instance of a subclass of AGAudioItem", obj];
    }

    AGAudioItem *old_value = self.items[idx];
    self.items[idx] = obj;

    if([self.delegate respondsToSelector:@selector(upNextQueueChanged:)]) {
        [self.delegate upNextQueueChanged:AGAudioPlayerUpNextQueueChangedItem];
    }
    
    if([self.delegate respondsToSelector:@selector(upNextQueue:updatedItem:atIndex:withNewItem:)]) {
        [self.delegate upNextQueue:self
                       updatedItem:old_value
                           atIndex:idx
                       withNewItem:obj];
    }
}

@end
