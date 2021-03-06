
    ////////////////////////////////////////////////////////////////////////////////////////////
    //  Copyright (c) 2012 Christopher Nicholson-Sauls                                        //
    //                                                                                        //
    //  Permission is hereby granted, free of charge, to any person obtaining a copy of this  //
    //  software and associated documentation files (the "Software"), to deal in the          //
    //  Software without restriction, including without limitation the rights to use, copy,   //
    //  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,   //
    //  and to permit persons to whom the Software is furnished to do so, subject to the      //
    //  following conditions:                                                                 //
    //                                                                                        //
    //  The above copyright notice and this permission notice shall be included in all        //
    //  copies or substantial portions of the Software.                                       //
    //                                                                                        //
    //  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   //
    //  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         //
    //  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    //
    //  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  //
    //  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  //
    //  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                         //
    ////////////////////////////////////////////////////////////////////////////////////////////

module zeal.utils.singleton;


mixin template Singleton () {
	mixin .SingletonBase;
}

mixin template Singleton ( alias Ctor ) {
	mixin .SingletonBase;
	
	protected this () {
		static if ( is( typeof( super() ) ) ) {
			super();
		}
		Ctor();
	}
}

mixin template Singleton ( string CtorImpl ) {
	mixin .SingletonBase;
	
	protected this () {
		static if ( is( typeof( super() ) ) ) {
			super();
		}
		mixin( CtorImpl );
	}
}

private mixin template SingletonBase () {

	static @property RealClass instance ( this RealClass ) () {
		static RealClass self;
		
		if ( self is null ) {
			self = new RealClass;
		}
		return self;
	}
	
	alias instance opCall;
	
}
