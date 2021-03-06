
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

/**
 *
 */
module zeal.http.router;

import std.metastrings;
import std.string;

import vibe.core.log;

import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;

import zeal.config;
import zeal.inflector;

import zeal.base.controller;

import zeal.utils.singleton;
import zeal.utils.tuple;

import sass;

mixin ConfigImports;


/**
 *
 */
class ZealRouter : UrlRouter {
	mixin Singleton;
	
	protected this () {
		foreach ( _R; ArrayTuple!( ZealConfig!`resources` ) ) {
			resource!( _R );
		}
		routeAssets();
	}

	/**
	 *
	 */
	final @property typeof( this ) match ( string _Path, string _C_A, string _Via_ = "any" ) () 
	if ( _Via_ == "delete" || _Via_ == "delete_" || _Via_ == "get" || _Via_ == "post" || _Via_ == "put" || _Via_ == "any" ) {
		enum _Module		= _C_A.parentize();
		enum _Controller	= _Module.controllerize();
		enum _Action		= _C_A.childize();
		enum _Via			= _Via_ ~ ( _Via_ == "delete" ? "_" : "" );
		
		mixin(Format!(
			q{
				import controllers.%s;
				auto cb = %s().action!`%s`;
				if ( cb == null ) {
					throw new Exception( "Attempted to add route to nonexistant action: %s -> %s" );
				}
				%s( "%s", cb );
			},
			_Module,
			_Controller, _Action,
			_Path, _C_A,
			_Via, _Path
		));
		return this;
	}
	
	/**
	 *
	 */
	final @property typeof( this ) resource ( _C : Controller ) ( _C c ) {
		enum _Base	= "/" ~ _C.stringof[ 0 .. $ - 10 ].decamelize();
		enum _New	= _Base ~ "/new";
		enum _ID 	= _Base ~ "/:id";
		enum _Edit	= _ID ~ "/edit";
		
		if ( auto a = c.action!`new`     ) get    ( _New , a );
		if ( auto a = c.action!`create`  ) post   ( _Base, a );
		if ( auto a = c.action!`index`   ) get    ( _Base, a );
		if ( auto a = c.action!`show`    ) get    ( _ID  , a );
		if ( auto a = c.action!`edit`    ) get    ( _Edit, a );
		if ( auto a = c.action!`update`  ) put    ( _ID  , a );
		if ( auto a = c.action!`destroy` ) delete_( _ID  , a );
		
		static if ( is( typeof( c.route( this ) ) ) ) {
			c.route( this );
		}
		
		logInfo( "ZealRouter: added resource: %s.", _Base[ 1 .. $ ] );
		return this;
	}

	///ditto
	final @property typeof( this ) resource ( string _R ) () {
		enum _Module		= "controllers." ~ _R;
		enum _Controller	= _R.controllerize();
		
		mixin(Format!(
			q{
				import %s;
				resource!%s = %s();
			},
			_Module,
			_Controller, _Controller
		));
		return this;
	}
	
	/**
	 *
	 */
	final @property typeof( this ) root ( string _Via = "any", _Dummy = void ) ( Controller.Action cb ) {
		mixin(Format!(
			q{
				%s( "/", cb );
			},
			_Via
		));
		return this;
	}

	///ditto
	final @property typeof( this ) root ( string _C_A, string _Via = "any" ) () {
		match!( "/", _C_A, _Via );
		return this;
	}
	
	/**
	 *
	 */
	final typeof( this ) routeAssets () {
		static done = false;
		
		if ( !done ) {
			auto assets = ZealConfig!`assets`;
			
			auto dir = assets ~ `styles/`;
			foreach ( style; ZealConfig!`styles` ) {
				compileSass( dir, style );
			}
			
			get( `*`, serveStaticFiles( ZealConfig!`assets` ) );
			
			done = true;
		}
		return this;
	}
	
} // end class ZealRouter


/**
 *
 */
private mixin template ConfigImports ( alias _List ) {
	static if ( _List.length > 0 ) {
		mixin(Format!(
			`import controllers.%s;`,
			_List[ 0 ]
		));
		mixin ConfigImports!( _List[ 1 .. $ ] );
	}
}

private mixin template ConfigImports () {
	mixin ConfigImports!( ZealConfig!`resources` );
}
