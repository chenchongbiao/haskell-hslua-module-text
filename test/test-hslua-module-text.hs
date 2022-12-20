{-
Copyright © 2017–2019 Albert Krewinkel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (void, when)
import Foreign.Lua (Lua)
import Foreign.Lua.Module.Text (preloadTextModule, pushModuleText)
import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.HUnit (assertEqual, testCase)

import qualified Foreign.Lua as Lua

main :: IO ()
main = defaultMain $ testGroup "hslua-module-text" [tests]

-- | HSpec tests
tests :: TestTree
tests = testGroup "FromLuaStack"
  [ testCase "text module can be pushed to the stack" $
      Lua.run (void pushModuleText)

  , testCase "text module can be added to the preloader" . Lua.run $ do
      Lua.openlibs
      preloadTextModule "hstext"
      assertEqual' "function not added to preloader" Lua.TypeFunction =<< do
        Lua.getglobal' "package.preload.hstext"
        Lua.ltype (-1)

  , testCase "text module can be loaded as hstext" . Lua.run $ do
      Lua.openlibs
      preloadTextModule "hstext"
      assertEqual' "loading the module fails " Lua.OK =<<
        Lua.dostring "require 'hstext'"

  , testCase "Lua tests pass" . Lua.run $ do
      Lua.openlibs
      preloadTextModule "hstext"
      assertEqual' "error while running lua tests" Lua.OK =<< do
        st <- Lua.loadfile "test/hstext-test.lua"
        when (st == Lua.OK) $ Lua.call 0 0
        return st
  ]

assertEqual' :: (Show a, Eq a) => String -> a -> a -> Lua ()
assertEqual' msg expected = Lua.liftIO . assertEqual msg expected
