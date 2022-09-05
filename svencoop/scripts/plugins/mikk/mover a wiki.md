A entity & a plugin that will let players choose the language that they want to see in-game.

samples and supported languages:
key | value
----|------
"message" | "hello world. this is my english and default message"
"message_spanish" | "hola mundo. este es mi mensaje en español"
"message_portuguese" | "Ola Mundo. esta e minha mensagem em portugues"
"message_italian" | "Ciao mondo. questo e il mio messaggio in italiano"
"message_french" | "Bonjour le monde. c'est mon message italien"
"message_german" | "Hallo Welt. das ist meine italienische Botschaft"
"message_esperanto" | "Saluton mondo. jen mia mesago en esperanto"

HOW TO INSTALL:
as any other plugin, add multi_language.as to your default_plugins.txt. 

should look like this:
```
	"plugin"
	{
		"name" "Multi-Language"
		"script" "mikk/multi_language"
	}
```

then register the game_text_custom on the campaigns/maps you want to have localizations. 

should look like this:
```angelscript
#include "mikk/multi_language"
#include "mikk/entities/utils"
#include "mikk/entities/game_text_custom"

void MapInit()
{
	RegisterCustomTextGame();
	MultiLanguageInit();
}
```
NOTE that there are more entities that supports multi-language so if you're a server op make sure to install this plugin :D

please. if you do a localization for any maps, let me know so i add them on the list.

Please do not repack this **plugin** or **scripts/maps/mikk/entities/utils.as**
Link them to this Github's Latest release. since only this both .as are modified when a new language is added.
if not, at least keep your page updated because more languages support could be added.


Doing localizations:

1-	create a .ent file with the name of the map you want to add localization.
		see scripts/maps/multi_language/
```angelscript
"entity"
{
	"message" "damn"
	"message_spanish" "carajo"
	"message_portuguese" "caralho"
	"targetname" "scientist_die"
	"dont forget all the other values from the original text" ":p"
	"classname" "game_text_custom"
}
"entity"
{
	"more of the same" ":)"
	"classname" "game_text_custom"
}
```

-2 let me know that you did a localization.

this script will automatically delete game_text n/or env_message that have the same targetname as your new game_text_custom.

other maybe useful features that have been added is key "effect" now have two more values 3 for show a motd message and 4 for show a chat message.

Special Thanks to [Gaftherman](https://github.com/Gaftherman) & [kmkz](https://github.com/kmkz27)

Maps that uses this feature:
Multi-language support | spanish | PT/BR | german | french | italian | esperanto
-----------------------|---------|-------|--------|--------|---------|----------
[Restriction](http://scmapdb.com/map:restriction) | Mikk | Teemo | X | Loulimi | X | X
[Residual Point](http://scmapdb.com/map:residual-point) | Mikk | Mikk | X | X | X | X