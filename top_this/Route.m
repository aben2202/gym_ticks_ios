//
//  Route.m
//  top_this
//
//  Created by Andrew Benson on 1/31/13.
//  Copyright (c) 2013 Andrew Benson. All rights reserved.
//

#import "Route.h"

@implementation Route


-(void)setRatingNumber:(NSInteger)ratingNumber{
    self.ratingNumber = ratingNumber;
}

-(NSInteger)ratingNumber{
    if ([self.routeType isEqualToString:@"Boulder"]){
        
        NSRange theRange = NSMakeRange(1, [self ratingWithoutPlusMinus].length-1);
        NSString *numberAsString = [[self ratingWithoutPlusMinus] substringWithRange:theRange];
        return [numberAsString intValue];
    }
    else{
        NSSet *numberStringSet = [[NSSet alloc] initWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]];
        NSInteger numberLength;
        if (self.rating.length > 3){
            if ([numberStringSet containsObject:[self.rating substringWithRange:NSMakeRange(3, 1)]]){
                numberLength = 2;
            }
            else{
                numberLength = 1;
            }
        }
        else{
            numberLength = 1;
        }
        NSString *theNumberString;
        if (numberLength == 1) {
            //return just the third character as an int
            theNumberString = [self.rating substringWithRange:NSMakeRange(2, 1)];
        }
        else{
            //return the third and fourth character as an int
            theNumberString = [self.rating substringWithRange:NSMakeRange(2, 2)];
        }
        return [theNumberString intValue];
    }
}

-(void)setRatingLetter:(NSString *)ratingLetter{
    self.ratingLetter = ratingLetter;
}

-(NSString *)ratingLetter{
    if (self.ratingNumber > 9){
        NSSet *letterStringSet = [[NSSet alloc] initWithArray:@[@"a",@"A",@"b",@"B",@"c",@"C",@"d",@"D"]];
        NSString *theLastChar = [self.rating substringWithRange:NSMakeRange(self.rating.length-1, 1)];
        if ([letterStringSet containsObject:theLastChar]) {
            return theLastChar;
        }
        else{
            return @"";
        }
    }
    else{
        return @"";
    }
}

-(void)setRatingArrow:(NSString *)ratingArrow{
    self.ratingArrow = ratingArrow;
}

-(NSString *)ratingArrow{
    NSSet *letterStringSet = [[NSSet alloc] initWithArray:@[@"+",@"-"]];
    NSString *theLastChar = [self.rating substringWithRange:NSMakeRange(self.rating.length-1, 1)];
    if ([letterStringSet containsObject:theLastChar]) {
        return theLastChar;
    }
    else{
        //the creation of obtaining th rating arrow is soley for the purpose of sorting and not displaying.  so if there is no arrow then we just assing a char that has an ascii value between '+' and '-', which is only the comma.
        return @",";
    }
}

-(NSString *)ratingWithoutPlusMinus{
    NSSet *arrowSet = [[NSSet alloc] initWithArray:@[@"+",@"-"]];
    NSString *theLastChar = [self.rating substringWithRange:NSMakeRange(self.rating.length-1, 1)];
    if ([arrowSet containsObject:theLastChar]) {
        //return everything but the last char
        NSString *missingArrow = [self.rating substringWithRange:NSMakeRange(0, self.rating.length-1)];
        return missingArrow;
    }
    else{
        //return the initial string
        return self.rating;
    }
}

@end
