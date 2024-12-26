In order to view the `.bin` files present in the regression test [fixtures](../../test/regression/fixtures/) in Visual Studio Code:

1. Add [`pkmn-debug`](../../bin/pkmn-debug) to the path `PATH`
2. Package the extension into a `.vsix`:
```sh
$ npm run extension
```
3. Install the extension in Visual Studio Code via "**Extensions: Install from VSIX...**"
4. Restart Visual Studio Code