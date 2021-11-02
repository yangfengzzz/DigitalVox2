//
//  external.hpp
//  external
//
//  Created by 杨丰 on 2021/11/2.
//

#ifndef external_
#define external_

/* The classes below are exported */
#pragma GCC visibility push(default)

class external
{
    public:
    void HelloWorld(const char *);
};

#pragma GCC visibility pop
#endif
